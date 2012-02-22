--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601_amba/rtl/box.vhd $
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.or_reduce; -- by synopsis
use ieee.numeric_std.all;

library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.memctrl.all; -- spimctrl types
use gaisler.uart.apbuart;
use gaisler.misc.ahbdpram;
use gaisler.misc.gptimer;
use gaisler.misc.grgpio;
use gaisler.misc.apbvga;
use gaisler.memoryctrl.mctrl;  -- original in esa lib

library grlib;
use grlib.amba.all;

library techmap;
use techmap.gencomp.all; -- constants


entity box is
    generic (
        time_factor               : positive
    );
    port (
        clk                       : in    std_ulogic;
        reset_n                   : in    std_ulogic;
        --                        
        uarti                     : in    uart_in_type;
        uarto                     : out   uart_out_type;
        --                        
        gpioi                     : in    gpio_in_type;
        gpioo                     : out   gpio_out_type;
        --                        
        fmc_i2ci                  : in    i2c_in_type;
        fmc_i2co                  : out   i2c_out_type;
        --
        spmi                      : in    spimctrl_in_type;
        spmo                      : out   spimctrl_out_type;
        --
        memi                      : in    memory_in_type;
        memo                      : out   memory_out_type
    );
end entity box;


library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.memctrl.all; -- spimctrl types + spmictrl component


architecture rtl of box is

    signal box_reset                     : std_ulogic;
    signal box_reset_n                   : std_ulogic;
    --
    signal ahbctrl_i0_msti               : ahb_mst_in_type;
    signal ahbmo                         : ahb_mst_out_vector := (others => ahbm_none);
    signal ahbctrl_i0_slvi               : ahb_slv_in_type;
    signal ahbso                         : ahb_slv_out_vector := (others => ahbs_none);
    signal apbctrl_i0_apbi               : apb_slv_in_type;
    signal apbo                          : apb_slv_out_vector := (others => apb_none);
    --
    signal gpti                          : gptimer_in_type;
    signal gptimer_i0_gpto               : gptimer_out_type;
    --
    signal grgpio_i0_gpioo               : gpio_out_type;
    --
    signal i2cmst_i0_i2co                : i2c_out_type;
    signal i2cmst_i1_i2co                : i2c_out_type;
    signal box_mctrl_wpo                 : wprot_out_type := (wprothit => '0');


begin
    
    ---------------------------------------------------------------------
    --  reset generator (now in top)

    box_reset   <= (not reset_n);
    box_reset_n <= not box_reset;


    ---------------------------------------------------------------------
    --  
    led_control_ahb_i0: entity work.led_control_ahb
    generic map (
        hindex    => 0,                            -- : integer := 0;
        count     => 20 * time_factor,           -- : natural := 0;
        gpio_data => x"00000000"                   -- : std_logic_vector(31 downto 0)
    )
    port map ( 
        -- system
        clk       => clk,                          -- : in  std_ulogic;
        -- ahb
        ahbi      => ahbctrl_i0_msti,              -- : in  ahb_mst_in_type; 
        ahbo      => ahbmo(0)                      -- : out ahb_mst_out_type
    );
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    --  
    led_control_ahb_i1: entity work.led_control_ahb
    generic map (
        hindex    => 1,                            -- : integer := 0;
        count     => 20 * time_factor + 3,       -- : natural := 0;
        gpio_data => x"0000000f"                   -- : std_logic_vector(31 downto 0)
    )
    port map ( 
        -- system
        clk       => clk,                          -- : in  std_ulogic;
        -- ahb
        ahbi      => ahbctrl_i0_msti,              -- : in  ahb_mst_in_type; 
        ahbo      => ahbmo(1)                      -- : out ahb_mst_out_type
    );
    ---------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------
    --  AHB CONTROLLER

    --ahbmo(0) <= (ahbm_none); -- led_control_ahb_i0
    --ahbmo(1) <= (ahbm_none); -- led_control_ahb_i1
    ahbmo(2) <= (ahbm_none);
    ahbmo(3) <= (ahbm_none);
    --
    --ahbso(0) <= (ahbs_none); -- ahbctrl
    ahbso(1) <= (ahbs_none);
    ahbso(2) <= (ahbs_none);
    ahbso(3) <= (ahbs_none);
    --ahbso(4) <= (ahbs_none); -- spimctrl
    --ahbso(5) <= (ahbs_none); -- mctrl
    ahbso(6) <= (ahbs_none); 
    ahbso(7) <= (ahbs_none); 

    ahbctrl_i0 : ahbctrl        -- AHB arbiter/multiplexer
        generic map (
            defmast    => 0,    -- default master
            --
            --
            rrobin     => 0,    -- round robin arbitration
            --
            --
            timeout    => 11,
            disirq     => 0,    -- enable interrupt routing
            enbusmon   => 0,    -- enable bus monitor
            assertwarn => 1,    -- enable assertions for warnings
            asserterr  => 1     -- enable assertions for errors
        )
        port map (
            rst     => box_reset_n,      -- : in  std_ulogic;
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
    ----------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- AHB SPI memory controller
    -- for SPI X4 (Winbond W25Q64VSFIG) 64-Mbit flash memory 
    spimctrl_i0 : spimctrl
        generic map (
            hindex     => 4,           -- : integer := 0;            -- AHB slave index
            faddr      => 16#E00#,     -- : integer := 16#000#;      -- Flash map base address
            fmask      => 16#FF8#,     -- : integer := 16#fff#;      -- Flash area mask
            ioaddr     => 16#002#,     -- : integer := 16#000#;      -- I/O base address
            iomask     => 16#fff#,     -- : integer := 16#fff#;      -- I/O mask
            readcmd    => 16#3b#,      -- : integer range 0 to 255 := 16#0B#;  -- Mem. dev. READ command
            dummybyte  => 1,           -- : integer range 0 to 1   := 1; -- Dummy byte after cmd
            dualoutput => 1            -- : integer range 0 to 1   := 0; -- Enable dual output
        )
        port map (
            rstn   => box_reset_n,     -- : in  std_ulogic;       
            clk    => clk,             -- : in  std_ulogic;
            ahbsi  => ahbctrl_i0_slvi, -- : in  ahb_slv_in_type;
            ahbso  => ahbso(4),        -- : out ahb_slv_out_type;
            spii   => spmi,            -- : in  spimctrl_in_type;
            spio   => spmo             -- : out spimctrl_out_type
        );
    ---------------------------------------------------------------------


    
    ---------------------------------------------------------------------
    -- AHB BPI memory controller
    mctrl_i0 : mctrl
        generic map (
            hindex    =>  5,           -- : integer := 0;
            pindex    => 15,           -- : integer := 0;
            romaddr   => 16#B00#,      -- : integer := 16#000#;
            rommask   => 16#FF0#,      -- : integer := 16#E00#;
            ioaddr    => 16#C00#,      -- : integer := 16#000#;
            iomask    => 16#FFF#,
            ramaddr   => 16#D00#,      -- : integer := 16#000#;
            rammask   => 16#FFF#,
            paddr     => 15,           -- : integer := 0;
            pmask     => 16#FFF#,      -- : integer := 16#fff#;
            romasel   => 25,           -- : integer := 28;
            ram8      => 1,            -- : integer := 0;
            ram16     => 0,            -- : integer := 0;
            syncrst   => 1,            -- : integer := 0;
            pageburst => 0,            -- : integer := 0;
            scantest  => 0             -- : integer := 0;
        )
        port map (
            rst   => box_reset_n,      -- : in  std_ulogic;
            clk   => clk,              -- : in  std_ulogic;
            memi  => memi,             -- : in  memory_in_type;
            memo  => memo,             -- : out memory_out_type;
            ahbsi => ahbctrl_i0_slvi,  -- : in  ahb_slv_in_type;
            ahbso => ahbso(5),         -- : out ahb_slv_out_type;
            apbi  => apbctrl_i0_apbi,  -- : in  apb_slv_in_type;
            apbo  => apbo(15),         -- : out apb_slv_out_type;
            wpo   => box_mctrl_wpo,    -- : in  wprot_out_type; -- unused
            sdo   => open              -- : out sdram_out_type
        );
    ---------------------------------------------------------------------




    ---------------------------------------------------------------------
    --  AHB/APB bridge

    apbo( 0) <= (apb_none);
    --apbo( 1) <= (apb_none); -- apbuart_i0
    --apbo( 2) <= (apb_none); -- gptimer_i0
    apbo( 3) <= (apb_none);
    --apbo( 4) <= (apb_none); -- grgpio_i0
    apbo( 5) <= (apb_none);
    apbo( 6) <= (apb_none);   -- no apbvga_i0
    apbo( 7) <= (apb_none);   -- no i2cmst_i0
    apbo( 8) <= (apb_none);
    apbo( 9) <= (apb_none);
    --apbo(10) <= (apb_none); -- i2cmst_i1
    apbo(11) <= (apb_none);
    apbo(12) <= (apb_none);
    apbo(13) <= (apb_none);
    apbo(14) <= (apb_none);
    --apbo(15) <= (apb_none); -- mctrl_i0

    apbctrl_i0: apbctrl
        generic map (
            hindex      => 0,            -- : integer := 0;
            haddr       => 16#800#,      -- : integer := 0;
            nslaves     => 16,           -- : integer range 1 to NAPBSLV := NAPBSLV;
            asserterr   => 1,    
            assertwarn  => 1    
        )                                
        port map (                       
            rst   => box_reset_n,        -- : in  std_ulogic;
            clk   => clk,                -- : in  std_ulogic;
            ahbi  => ahbctrl_i0_slvi,    -- : in  ahb_slv_in_type;
            ahbo  => ahbso(0),           -- : out ahb_slv_out_type;
            apbi  => apbctrl_i0_apbi,    -- : out apb_slv_in_type;
            apbo  => apbo                -- : in  apb_slv_out_vector                
        );
    ----------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------
    -- uart
    apbuart_i0: apbuart
        generic map (
            pindex     => 1,
            paddr      => 1,
            console    => 1, -- fast simulation output
            parity     => 0, -- no parity
            flow       => 1, -- hardware handshake
            fifosize   => 16
        )
        port map (
            rst   => box_reset_n,        -- : in  std_ulogic;
            clk   => clk,                -- : in  std_ulogic;
            apbi  => apbctrl_i0_apbi,    -- : in  apb_slv_in_type;
            apbo  => apbo(1),            -- : out apb_slv_out_type;
            uarti => uarti,              -- : in  uart_in_type;
            uarto => uarto               -- : out uart_out_type);
        );
    ---------------------------------------------------------------------

    
    ---------------------------------------------------------------------
    -- GP timer (grip.pdf p. 279)
    
    gpti.extclk <= '0'; -- alternativ timer clock
    gpti.dhalt  <= '0'; -- debug halt

    gptimer_i0: gptimer
        generic map (
            pindex  => 2,
            paddr   => 2,
            pirq    => 3,
            sepirq  => 0, -- use separate interupts for each timer
            sbits   => 8, -- prescaler bits
            ntimers => 2, -- number of timers
            nbits   => 20 -- timer bits
        )
        port map (
            rst     => box_reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(2),
            gpti    => gpti,
            gpto    => gptimer_i0_gpto
        );
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- GPIO
    grgpio_i0: grgpio
        generic map (
            pindex  => 4, 
            paddr   => 4, 
--          imask   => 16#00000FF0#, -- interrupt mask (+ enable per software)
            syncrst => 1,            -- only synchronous reset
            nbits   => 32            -- number of port bits
        )
        port map (
            rst    => box_reset_n, 
            clk    => clk, 
            apbi   => apbctrl_i0_apbi, 
            apbo   => apbo(4),
            gpioi  => gpioi, 
            gpioo  => grgpio_i0_gpioo
        );
    gpioo <= grgpio_i0_gpioo;
    --          gpio.dout                         gpio.din
    ---------------------------------------------------------------------
    --  3 -  0  LED                               gpio_switch
    --  7 -  4  unused                            gpio_button
    -- 15 -  8  header                            gpio_header_ls
    -- 30 - 16  unused
    -- 31       unused                            simulation_active
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- I2C for FMC connector
    i2cmst_i1: i2cmst
        generic map (
            pindex  => 10,
            paddr   => 10,
            pmask   => 16#FFF#,
            pirq    => 15          -- TODO: check this
        )
        port map (
            rstn    => box_reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(10),
            i2ci    => fmc_i2ci,             --: in  i2c_in_type;
            i2co    => i2cmst_i1_i2co        --: out i2c_out_type;
        );
    fmc_i2co <= i2cmst_i1_i2co;
    ---------------------------------------------------------------------


end architecture rtl;
