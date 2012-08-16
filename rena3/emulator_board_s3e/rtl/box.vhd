--------------------------------------------------------------------------------
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.types.all;


library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types

library global;
use global.global_signals.all;

library hzdr;
use hzdr.component_package.debug_con_apb;


entity box is
    generic (
        system_frequency  : integer;
        use_ahbuart_g     : boolean := false;
        use_ethernet_g    : boolean := false
    );
    port (
        fpga_clk        : in    std_ulogic;
        fpga_rotary_sw  : in    fpga_rotary_sw_in_t;
        --
        uarti           : in    uart_in_type;
        uarto           : out   uart_out_type;
        --
        gpioi           : in    gpio_in_type;
        gpioo           : out   gpio_out_type;
        --                        
        i2ci            : in    i2c_in_type;
        i2co            : out   i2c_out_type;
        --
        ethi            : in    eth_in_type;
        etho            : out   eth_out_type;
        --
        vgao            : out   apbvga_out_type;
        --
        ddr_clk         : out   std_logic_vector(2 downto 0);
        ddr_clkb        : out   std_logic_vector(2 downto 0);
        ddr_clk_fb      : in    std_logic;
        ddr_cke         : out   std_logic_vector(1 downto 0);
        ddr_csb         : out   std_logic_vector(1 downto 0);
        ddr_web         : out   std_ulogic;                     -- ddr write enable
        ddr_rasb        : out   std_ulogic;                     -- ddr ras
        ddr_casb        : out   std_ulogic;                     -- ddr cas
        ddr_dm          : out   std_logic_vector (1 downto 0);  -- ddr dm
        ddr_dqs         : inout std_logic_vector (1 downto 0);  -- ddr dqs
        ddr_ad          : out   std_logic_vector (13 downto 0); -- ddr address
        ddr_ba          : out   std_logic_vector (1 downto 0);  -- ddr bank address
        ddr_dq          : inout std_logic_vector (15 downto 0); -- ddr data
        --                                 
        debug_trace     : out   debug_signals_t := default_debug_signals;
        debug_trace_box : out   debug_signals_t;
        debug_trace_dcm : out   debug_signals_t;
        -- to stop simulation
        break           : out   std_ulogic

    );
end entity box;



library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce; -- synopsis


library zpu;
use zpu.zpu_wrapper_package.all; -- types
use zpu.zpu_config.all;
use zpu.zpupkg.all;
use zpu.zpu_wrapper_package.zpu_ahb;
use zpu.zpu_wrapper_package.dualport_ram_ahb_wrapper; -- for big zpu


library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.all;  -- types
use gaisler.uart.all;  -- types
use gaisler.net.all;   -- types
use gaisler.leon3.all; -- types
--use gaisler.leon3.irqmp;
use gaisler.misc.gptimer;
use gaisler.misc.grgpio;
use gaisler.misc.ahbram;
use gaisler.misc.apbvga;
use gaisler.uart.apbuart;
use gaisler.net.greth;
use gaisler.memctrl.ddrspa;

library techmap;
use techmap.gencomp.all;

library work;
use work.version.all;



architecture rtl of box is

    signal clk                           : std_ulogic;
    signal clk_gen_i0_clk_dv             : std_ulogic;
    signal clk_gen_i0_clk_fx             : std_ulogic;
    signal clk_gen_i0_clk_ready          : std_ulogic;
    signal ddrspa_i0_clkddro             : std_ulogic;

    signal reset                         : std_ulogic;
                                         
    signal reset_shiftreg                : std_ulogic_vector(3 downto 0) := (others => '1');

--  signal rena3_out                     : rena3_controller_in_t;
--  signal rena3_controller_io_rena3_out : rena3_controller_out_t;
    signal rena3_controller_i0_zpu_out   : zpu_in_t;
    signal zpu_i0_zpu_out                : zpu_out_t;
    signal reset_n                       : std_ulogic;

    signal ahbctrl_i0_msti               : ahb_mst_in_type;
    signal ahbmo                         : ahb_mst_out_vector := (others => ahbm_none);
    signal ahbctrl_i0_slvi               : ahb_slv_in_type;
    signal ahbso                         : ahb_slv_out_vector := (others => ahbs_none);
    signal apbctrl_i0_apbi               : apb_slv_in_type;
    signal apbo                          : apb_slv_out_vector := (others => apb_none);
    
    signal gpti                          : gptimer_in_type;
    signal gptimer_i0_gpto               : gptimer_out_type;
            
    signal ddrspa_i0_psdone		         : std_ulogic;
    signal ddrspa_i0_psovfl		         : std_ulogic;
    signal dcm_ctrl_apb_i0_psen          : std_ulogic;
    signal dcm_ctrl_apb_i0_psincdec      : std_ulogic;

    signal stati                         : ahbstat_in_type;

--  signal irqi                          : irq_out_vector(0 to 0);
--  signal irqmp_i0_irqo                 : irq_in_vector(0 to 0);

    signal tck                           : std_ulogic := '0';
    signal tms                           : std_ulogic := '0';
    signal tdi                           : std_ulogic := '0';
    signal tdo                           : std_ulogic := '0';

begin
    
    ---------------------------------------------------------------------
    -- select clk and reset source 
    clk <= fpga_clk;

    -- generate synchronous reset
    reset_synchronizer : process
    begin
        wait until rising_edge( clk);
        reset_shiftreg <= reset_shiftreg( reset_shiftreg'high-1 downto 0) & '0';
        if fpga_rotary_sw.center = '1' then
            reset_shiftreg <= (others => '1');
        end if;
    end process;

    reset           <= reset_shiftreg( reset_shiftreg'high);
    reset_n         <= not reset;
    ---------------------------------------------------------------------
    

    ---------------------------------------------------------------------
    --  zpu
    
    zpu_ahb_i0: zpu_ahb
    generic map (
        hindex    => 0,                            -- : integer := 0
        zpu_small => false                         -- : boolean := true
    )                                              
    port map (                                     
        clk    => clk,                             -- : in  std_ulogic;
        reset  => reset,                           -- : in  std_ulogic;
        ahbi   => ahbctrl_i0_msti,                 -- : in  ahb_mst_in_type; 
        ahbo   => ahbmo(0),                        -- : out ahb_mst_out_type;
        irq    => or_reduce(ahbctrl_i0_msti.hirq), -- : in  std_ulogic;
        break  => break                            -- : out std_ulogic
    );
    ---------------------------------------------------------------------
    

    ---------------------------------------------------------------------
    --  AHB CONTROLLER

    --ahbmo(0) <= ahbm_none; -- zpu_ahb_i0
    --ahbmo(1) <= ahbm_none; -- greth_i0 
    ahbmo(2) <= ahbm_none;
    ahbmo(3) <= ahbm_none;
    --
    --ahbso(0) <= ahbs_none; -- apbctrl_i0
    --ahbso(1) <= ahbs_none; -- ahbram_i0
    --ahbso(2) <= ahbs_none; -- ddrspa_i0
    --ahbso(3) <= ahbs_none; -- dualport_ram_ahb_wrapper_i0

    ahbctrl_i0 : ahbctrl        -- AHB arbiter/multiplexer
        generic map (
            defmast    => 0,    -- default master
            rrobin     => 1,    -- round robin arbitration
            timeout    => 11,
            disirq     => 0,    -- enable interrupt routing
            enbusmon   => 0,    -- enable bus monitor
            assertwarn => 1,    -- enable assertions for warnings
            asserterr  => 1     -- enable assertions for errors
        )
        port map (
            rst     => reset_n,          -- : in  std_ulogic;
            clk     => clk,              -- : in  std_ulogic;
            msti    => ahbctrl_i0_msti,  -- : out ahb_mst_in_type;
            msto    => ahbmo,            -- : in  ahb_mst_out_vector;
            slvi    => ahbctrl_i0_slvi,  -- : out ahb_slv_in_type;
            slvo    => ahbso,            -- : in  ahb_slv_out_vector;
            testen  => '0',
            testrst => '1',
            scanen  => '0',
            testoen => '1'
        );

    debug_trace_box.hgrant_0 <= ahbctrl_i0_msti.hgrant(0);
    debug_trace_box.hgrant_1 <= ahbctrl_i0_msti.hgrant(1); 
    debug_trace_box.ahbmo0_bureq <= ahbmo(0).hbusreq;
    debug_trace_box.ahbmo1_bureq <= ahbmo(1).hbusreq;
    ----------------------------------------------------------------------

    
    ---------------------------------------------------------------------
    --  AHB UART (for grmon debug support)

    which_uart_0 : if use_ahbuart_g generate
        ahbuart_i0 : ahbuart
        generic map (
          hindex    => 2,                -- : integer := 0;
          pindex    => 1,                -- : integer := 0;
          paddr     => 1                 -- : integer := 0;
        )                                
        port map (                       
          rst       => reset_n,          -- : in  std_ulogic;
          clk       => clk,              -- : in  std_ulogic;
          uarti     => uarti,            -- : in  uart_in_type;
          uarto     => uarto,            -- : out uart_out_type;
          apbi      => apbctrl_i0_apbi,  -- : in  apb_slv_in_type;
          apbo      => apbo(1),          -- : out apb_slv_out_type;
          ahbi      => ahbctrl_i0_msti,  -- : in  ahb_mst_in_type;
          ahbo      => ahbmo(2)          -- : out ahb_mst_out_type
        );
    end generate which_uart_0;

    ---------------------------------------------------------------------
    --  AHB RAM (internal 4k BRAM)

    ahbram_i0 : ahbram
        generic map (
            hindex   => 1,
            haddr    => 16#a00#,
            hmask    => 16#FFF#,
            tech     => inferred,
            kbytes   => 4
        )
        port map (
            rst    => reset_n,
            clk    => clk,
            ahbsi  => ahbctrl_i0_slvi,
            ahbso  => ahbso(1)
        );
    ----------------------------------------------------------------------


    ----------------------------------------------------------------------
    ----------------------------------------------------------------------
    --  AHB ZPU memory (instruction+data memory)

    dualport_ram_ahb_wrapper_i0 : dualport_ram_ahb_wrapper
        generic map (
            hindex   => 3,
            haddr    => 16#000#
        )
        port map (
            clk    => clk,
            reset  => reset,
            ahbsi  => ahbctrl_i0_slvi,
            ahbso  => ahbso(3)
        );
    ----------------------------------------------------------------------


    ---------------------------------------------------------------------
    --  DDR SDRAM controller (external RAM 32 MByte)

    -- fpga filled around 78%, clk (50 MHz after DCM)
    -- frequency  relation     timing score   test
    --    75 MHz   3:2                14657   ok
    --   100 MHz   4:2                  350   failed completly
    --   100 MHz   2:1                  350   failed completly
    --   120 MHz  12:5                78434   failed completly
    --   133 MHz   8:3                95169   failed completly
    --   150 MHz   3:1                 4817   failed completly
    
    -- fpga filled around 78%, fpga_clk.clk50 (before DCM
    -- frequency  relation     timing score   test
    --    75 MHz   3:2         routing failed
    --   100 MHz   2:1                  913   failed completly
    
    -- fpga filled around 78%, clk100 (100 MHz after DCM)
    -- frequency  relation     timing score   test
    --   133 MHz   4:3                96809   failed
    
    -- fpga filled around 79%, direct from DCM, many TIG
    -- frequency  relation     timing score   test
    --    75 MHz    3:2                   0   ok
    --    80 MHz    8:5                   0   ok
    --    90 MHz    9:5                   0   ok
    --   100 MHz    2:1                   0   ok 
    --   120 MHz   12:5                   0   ok
    --   125 MHz    5:2                   0   ok
    --   130 MHz   13:5                   0   failed

    -- fpga filled around 63%, direct from DCM, many TIG
    -- frequency  relation     timing score   test
    --    75 MHz    3:2                   0   ok
    --    80 MHz    8:5                   0   ok
    --    90 MHz    9:5                   0   ok
    --   100 MHz    2:1                   0   ok 
    --   110 MHz   11:5  
    --   120 MHz   12:5                   0   partly errors
    --   125 MHz    5:2                   0   failed
    --   130 MHz   13:5                   0   failed

    ddrspa_i0: ddrspa
        generic map (
            fabtech        => spartan3e,
            memtech        => DEFMEMTECH,
            hindex         => 2,
            haddr          => 16#400#,
            hmask          => 16#F00#,
            ddrbits        => 16,     
            MHz            => 100,
            clkmul         => 1,       -- for clk_ddr
            clkdiv         => 1,       -- for clk_ddr
            col            => 10,      -- column address: 1024
            Mbyte          => 32,
            pwron          => 1
        )
        port map (
            rst_ddr        => '1',                   -- in  std_ulogic;
            rst_ahb        => reset_n,               -- in  std_ulogic;
            clk_ddr        => clk_gen_i0_clk_fx,     -- in  std_ulogic;
            clk_ahb        => clk,                   -- in  std_ulogic;
            lock           => open,                  -- out std_ulogic; -- DCM locked
            clkddro        => ddrspa_i0_clkddro,     -- out std_ulogic;
            clkddri        => ddrspa_i0_clkddro,     -- in  std_ulogic;

            ahbsi          => ahbctrl_i0_slvi, -- in  ahb_slv_in_type;
            ahbso          => ahbso(2),        -- out ahb_slv_out_type;

            ddr_clk        => ddr_clk,         -- out std_logic_vector(2 downto 0);
            ddr_clkb       => ddr_clkb,        -- out std_logic_vector(2 downto 0);
            ddr_clk_fb_out => open,            -- out std_logic;
            ddr_clk_fb     => ddr_clk_fb,      -- in std_logic;
            ddr_cke        => ddr_cke,         -- out std_logic_vector(1 downto 0);
            ddr_csb        => ddr_csb,         -- out std_logic_vector(1 downto 0);
            ddr_web        => ddr_web,         -- out std_ulogic;                       -- ddr write enable
            ddr_rasb       => ddr_rasb,        -- out std_ulogic;                       -- ddr ras
            ddr_casb       => ddr_casb,        -- out std_ulogic;                       -- ddr cas
            ddr_dm         => ddr_dm,          -- out std_logic_vector (ddrbits/8-1 downto 0);    -- ddr dm
            ddr_dqs        => ddr_dqs,         -- inout std_logic_vector (ddrbits/8-1 downto 0);    -- ddr dqs
            ddr_ad         => ddr_ad,          -- out std_logic_vector (13 downto 0);   -- ddr address
            ddr_ba         => ddr_ba,          -- out std_logic_vector (1 downto 0);    -- ddr bank address
            ddr_dq         => ddr_dq,          -- inout  std_logic_vector (ddrbits-1 downto 0) -- ddr data
            --
            psclk          => clk,
            psdone         => ddrspa_i0_psdone,
            psovfl         => ddrspa_i0_psovfl,
            psen           => dcm_ctrl_apb_i0_psen,
            psincdec       => dcm_ctrl_apb_i0_psincdec
        );

    debug_trace_box.sys_clk    <= clk;
    debug_trace_box.ddr_clk    <= clk_gen_i0_clk_fx;
    debug_trace_box.ddr_fb_clk <= ddrspa_i0_clkddro;
    ---------------------------------------------------------------------
            
    
    ---------------------------------------------------------------------
    -- ethernet (takes also an APB port)

    use_ethernet : if use_ethernet_g generate
        greth_i0: greth
            generic map (
                hindex      => 1, 
                pindex      => 5,
                paddr       => 5,
                pirq        => 5,
                memtech     => inferred,
                mdcscaler   => 20,
                enable_mdio => 1,
                fifosize    => 32,
                nsync       => 1,
                phyrstadr   => 31        -- depends on used hardware
            )
            port map (
                rst         => reset_n,
                clk         => clk,
                ahbmi       => ahbctrl_i0_msti,
                ahbmo       => ahbmo(1),
                apbi        => apbctrl_i0_apbi,
                apbo        => apbo(5),
                ethi        => ethi,
                etho        => etho
            );
    end generate use_ethernet;
    use_no_ethernet : if use_ethernet_g = false generate
        ahbmo(1)     <= ahbm_none;
        apbo(5)      <= apb_none;
        etho.mdio_oe <= '1';
        etho.mdio_o  <= '0';
        etho.mdc     <= '0';
        etho.tx_er   <= '0';
        etho.tx_en   <= '0';
        etho.txd     <= (others => '0');
    end generate use_no_ethernet;
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    --  AHB/APB bridge

    --apbo(0)  <= apb_none; -- debug_con_apb_i0
    --apbo(1)  <= apb_none; -- apbuart_i0
    --apbo(2)  <= apb_none; -- gptimer_i0
    apbo(3)  <= apb_none; -- irqmp_i0
    --apbo(4)  <= apb_none; -- grgpio_i0
    --apbo(5)  <= apb_none; -- greth_i0
    --apbo(6)  <= apb_none; -- apbvga_i0
    apbo(7)  <= apb_none;
    apbo(8)  <= apb_none;
    apbo(9)  <= apb_none;
    --apbo(10) <= apb_none; -- i2cmst_i0
    apbo(11) <= apb_none;
    apbo(12) <= apb_none;
    apbo(13) <= apb_none;
    apbo(14) <= apb_none;
    apbo(15) <= apb_none;

    apbctrl_i0: apbctrl
        generic map (
            hindex      => 0,            -- : integer := 0;
            haddr       => 16#800#,      -- : integer := 0;
            nslaves     => 16,           -- : integer range 1 to NAPBSLV := NAPBSLV;
            asserterr   => 1,    
            assertwarn  => 1    
        )                                
        port map (                       
            rst   => reset_n,            -- : in  std_ulogic;
            clk   => clk,                -- : in  std_ulogic;
            ahbi  => ahbctrl_i0_slvi,    -- : in  ahb_slv_in_type;
            ahbo  => ahbso(0),           -- : out ahb_slv_out_type;
            apbi  => apbctrl_i0_apbi,    -- : out apb_slv_in_type;
            apbo  => apbo                -- : in  apb_slv_out_vector                
        );
    ----------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------
    -- debug console (for fast simulation output)
    debug_con_apb_i0: debug_con_apb
        generic map (
            pindex           => 0,               -- : integer := 0;
            paddr            => 0,               -- : integer := 0;
            version_time     => version_time_c,  -- : string( 1 to 21) := "undefined version    "
            svnrevision      => svnrevision_c,   -- : string( 1 to 21) := "unknown SVN revision ";
            system_frequency => system_frequency -- : integer 
        )
        port map (
            rst       => reset_n,               -- : in  std_ulogic;
            clk       => clk,                   -- : in  std_ulogic;
            apbi      => apbctrl_i0_apbi,       -- : in  apb_slv_in_type;
            apbo      => apbo(0),               -- : out apb_slv_out_type
            softreset => open                   -- : out std_ulogic
        );
    ---------------------------------------------------------------------
    

    ---------------------------------------------------------------------
    -- uart
    -- apb slot 1 is switched with ahbuart

    which_uart_1 : if use_ahbuart_g = false generate
        apbuart_i0: apbuart
            generic map (
                pindex     => 1,
                paddr      => 1,
                console    => 1, -- fast simulation output
                parity     => 0, -- no parity
                flow       => 0, -- no hardware handshake
                fifosize   => 16
            )
            port map (
                rst   => reset_n,
                clk   => clk,
                apbi  => apbctrl_i0_apbi,
                apbo  => apbo(1),
                uarti => uarti,
                uarto => uarto
            );
    end generate which_uart_1;
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- GP timer (grip.pdf p. 279)
    
    gpti.extclk <= '0'; -- alternativ timer clock
    gpti.dhalt  <= '0'; -- debug halt
    gpti.wdogen <= '0'; -- watchdog enable

    gptimer_i0: gptimer
        generic map (
            pindex  => 2,
            paddr   => 2,
            pirq    => 3,
            sepirq  => 0, -- use separate interupts for each timer
            sbits   => 8, -- prescaler bits
            ntimers => 3, -- number of timers
            nbits   => 20 -- timer bits
        )
        port map (
            rst     => reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(2),
            gpti    => gpti,
            gpto    => gptimer_i0_gpto
        );
    ---------------------------------------------------------------------
   

--  ---------------------------------------------------------------------
--  -- Interrupt controller
--  irqi(0) <= (pwd => '0', irl => "0000", intack => '0', fpen => '0', idle => '0');
--  irqmp_i0 : irqmp
--      generic map (
--          pindex  => 3,
--          paddr   => 3
--      )
--      port map (
--          rst     => reset_n,         -- : in  std_ulogic;
--          clk     => clk,             -- : in  std_ulogic;
--          apbi    => apbctrl_i0_apbi, -- : in  apb_slv_in_type;
--          apbo    => apbo(3),         -- : out apb_slv_out_type;
--          irqi    => irqi,            -- : in  irq_out_vector(0 to ncpu-1);
--          irqo    => irqmp_i0_irqo    -- : out irq_in_vector(0 to ncpu-1)
--      );


    ---------------------------------------------------------------------
    -- GPIO
    grgpio_i0: grgpio
        generic map (
            pindex  => 4, 
            paddr   => 4, 
            imask   => 16#00000FF0#, -- interrupt mask (+ enable per software)
            syncrst => 1,            -- only synchronous reset
            nbits   => 32            -- number of port bits
        )
        port map (
            rst    => reset_n, 
            clk    => clk, 
            apbi   => apbctrl_i0_apbi, 
            apbo   => apbo(4),
            gpioi  => gpioi, 
            gpioo  => gpioo
        );
    ---------------------------------------------------------------------
            

    ---------------------------------------------------------------------
    -- SVGA (textmode)
    apbvga_i0: apbvga
        generic map (
            memtech => DEFMEMTECH,
            pindex  => 6,
            paddr   => 6
        )
        port map (
            rst     => reset_n,
            clk     => clk,
            vgaclk  => clk_gen_i0_clk_dv,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(6),
            vgao    => vgao
        );
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- I2C for any connector
    i2cmst_i0: i2cmst
        generic map (
            pindex  => 10,
            paddr   => 10,
            pmask   => 16#FFF#,
            pirq    => 0
        )
        port map (
            rstn    => reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(10),
            i2ci    => i2ci,             --: in  i2c_in_type;
            i2co    => i2co              --: out i2c_out_type;
        );
    ---------------------------------------------------------------------

    
end architecture rtl;
