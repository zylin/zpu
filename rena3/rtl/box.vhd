--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce; -- by synopsis

library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.memctrl.all; -- spimctrl types

library hzdr;
use hzdr.component_package.debug_con_apb;

library zpu;
use zpu.zpu_wrapper_package.all; -- types
use zpu.zpu_config.all;
use zpu.zpupkg.all;
use zpu.zpu_wrapper_package.zpu_ahb;
use zpu.zpu_wrapper_package.dualport_ram_ahb_wrapper; -- for medium zpu

library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.memctrl.all; -- spimctrl types + spmictrl component
use gaisler.uart.apbuart;
use gaisler.misc.ahbdpram;
use gaisler.misc.gptimer;
use gaisler.misc.grgpio;
use gaisler.misc.apbvga;
use gaisler.memoryctrl.mctrl;  -- original in esa lib
use gaisler.net.greth;

library techmap;
use techmap.gencomp.all; -- constants

library rena3;
use rena3.types_package.all;
use rena3.version.all;


entity box is
    port(
        clk                       : in    std_ulogic;
        reset_n                   : in    std_ulogic;
        break                     : out   std_ulogic;
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
        dvi_i2ci                  : in    i2c_in_type;
        dvi_i2co                  : out   i2c_out_type;
        --                        
        clk_vga                   : in    std_ulogic;
        vgao                      : out   apbvga_out_type;
        --
        spmi                      : in    spimctrl_in_type;
        spmo                      : out   spimctrl_out_type;
        --
        memi                      : in    memory_in_type;
        memo                      : out   memory_out_type;
        --
        ethi                      : in    eth_in_type;
        etho                      : out   eth_out_type;
        --                        
        rena3_0_in                : in    rena3_controller_in_t;
        rena3_0_out               : out   rena3_controller_out_t;
        rena3_1_in                : in    rena3_controller_in_t;
        rena3_1_out               : out   rena3_controller_out_t;
        --
        ad9854_out                : out   ad9854_out_t;
        ad9854_in                 : in    ad9854_in_t;
        --
        clk_adc                   : out   std_ulogic;
        adc_data                  : in    std_ulogic_vector(13 downto 0);
        adc_otr                   : in    std_ulogic
        --                        
--      rena3_in                  : in    rena3_controller_in_t;
--      rena3_out                 : out   rena3_controller_out_t
    );
end entity box;




architecture rtl of box is

    signal box_reset                     : std_ulogic;
    signal box_reset_n                   : std_ulogic;
    --
    signal debug_con_apb_i0_softreset    : std_ulogic;
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
    --
    signal spii                          : spi_in_type;
    signal spictrl_i0_spio               : spi_out_type;

begin
    
    ---------------------------------------------------------------------
    --  reset generator (now in top)

    box_reset   <= (not reset_n) or debug_con_apb_i0_softreset;
    box_reset_n <= not box_reset;

    ---------------------------------------------------------------------
    --  zpu
    
    zpu_ahb_i0: zpu_ahb
    generic map (
        hindex    => 0,                            -- : integer := 0
        zpu_small => false                         -- : boolean := true
    )                                              
    port map (                                     
        clk    => clk,                             -- : in  std_ulogic;
        reset  => box_reset,                       -- : in  std_ulogic;
        ahbi   => ahbctrl_i0_msti,                 -- : in  ahb_mst_in_type; 
        ahbo   => ahbmo(0),                        -- : out ahb_mst_out_type;
        irq    => or_reduce(ahbctrl_i0_msti.hirq), -- : in  std_ulogic;
        break  => break                            -- : out std_ulogic
    );
    ---------------------------------------------------------------------
    

    ---------------------------------------------------------------------
    -- ethernet (ahb master + apb slave)

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
            phyrstadr   => 7         -- depends on used hardware
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
    ---------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------
    --  AHB CONTROLLER

    --ahbmo(0) <= (ahbm_none); -- zpu_ahb_i0
    --ahbmo(1) <= (ahbm_none); -- greth_i0 
    ahbmo(2) <= (ahbm_none);
    ahbmo(3) <= (ahbm_none);
    --
    --ahbso(0) <= (ahbs_none); -- ahbctrl
    ahbso(1) <= (ahbs_none);
    ahbso(2) <= (ahbs_none);
    --ahbso(3) <= (ahbs_none); -- dualport_ram_ahb_wrapper
    --ahbso(4) <= (ahbs_none); -- spimctrl
    --ahbso(5) <= (ahbs_none); -- mctrl
    ahbso(6) <= (ahbs_none); 
    ahbso(7) <= (ahbs_none); 

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
    --  AHB ZPU memory (instruction + data memory)

    dualport_ram_ahb_wrapper_i0 : dualport_ram_ahb_wrapper
        generic map (
            hindex   => 3,
            haddr    => 16#000#
        )
        port map (
            clk    => clk,
            reset  => box_reset,
            ahbsi  => ahbctrl_i0_slvi,
            ahbso  => ahbso(3)
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
            romasel   => 25,           -- : integer := 28;
            ram8      => 0,            -- : integer := 0;
            ram16     => 1,            -- : integer := 0;
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

    --apbo( 0) <= (apb_none); -- debug_con_apb_i0
    --apbo( 1) <= (apb_none); -- apbuart_i0
    --apbo( 2) <= (apb_none); -- gptimer_i0
    apbo( 3) <= (apb_none);
    --apbo( 4) <= (apb_none); -- grgpio_i0
    --apbo( 5) <= (apb_none); -- greth_i0
    --apbo( 6) <= (apb_none); -- apbvga_i0
    --apbo( 7) <= (apb_none); -- i2cmst_i0
    apbo( 8) <= (apb_none);
    apbo( 9) <= (apb_none);
    --apbo(10) <= (apb_none); -- i2cmst_i1
    --apbo(11) <= (apb_none); -- spictrl_i0
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
    -- debug console (for fast simulation output)
    debug_con_apb_i0: debug_con_apb
        generic map (
            pindex       => 0,             -- : integer := 0;
            paddr        => 0,             -- : integer := 0;
            version_time => version_time_c -- : string( 1 to 21)
        )
        port map (
            rst       => box_reset_n,               -- : in  std_ulogic;
            clk       => clk,                       -- : in  std_ulogic;
            apbi      => apbctrl_i0_apbi,           -- : in  apb_slv_in_type;
            apbo      => apbo(0),                   -- : out apb_slv_out_type;
            softreset => debug_con_apb_i0_softreset -- : out std_ulogic
        );
    ---------------------------------------------------------------------
    
    
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
    -- gpio.dout
    --  3 -  0  LED   
    --  7 -  4  unused
    -- 11 -  8  header  
    -- 12       unused
    -- 13       AD9854 io_update_clock
    -- 14       AD9854 io_reset
    -- 15       AD9854 master_reset
    -- 29 - 16  unused
    -- 30       clk_adc
    -- 31       testgen
    ---------------------------------------------------------------------
    

    ---------------------------------------------------------------------
    -- VGA (textmode)
    apbvga_i0: apbvga
        generic map (
            memtech => DEFMEMTECH,
            pindex  => 6,
            paddr   => 6
        )
        port map (
            rst     => '1', -- box_reset_n, better timing?
            clk     => clk,
            vgaclk  => clk_vga,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(6),
            vgao    => vgao
        );
    ---------------------------------------------------------------------
    

    ---------------------------------------------------------------------
    -- I2C for DVI channel
    i2cmst_i0: i2cmst
        generic map (
            pindex  => 7,
            paddr   => 7,
            pmask   => 16#FFF#,
            pirq    => 0
        )
        port map (
            rstn    => box_reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(7),
            i2ci    => dvi_i2ci,             --: in  i2c_in_type;
            i2co    => i2cmst_i0_i2co        --: out i2c_out_type;
        );
    dvi_i2co <= i2cmst_i0_i2co;
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- I2C for FMC connector
    i2cmst_i1: i2cmst
        generic map (
            pindex  => 10,
            paddr   => 10,
            pmask   => 16#FFF#,
            pirq    => 0
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


    ---------------------------------------------------------------------
    -- SPI for AD9854 DDS 
    -- grip.pdf p.660
    spictrl_i0: spictrl
        generic map (
            pindex   => 11,                  --: integer := 0;
            paddr    => 11,                  --: integer := 0;
            fdepth   => 3,                   --: integer range 1 to 7  := 1; -- fifo depth
            oepol    => 1,                   --: integer range 0 to 1  := 0;
            twen     => 0,                   --: integer range 0 to 1  := 1; -- four wire mode
            maxwlen  => 7                    --: integer range 0 to 15 := 0
        )
        port map (
            rstn     => box_reset_n,         --: in std_ulogic;
            clk      => clk,                 --: in std_ulogic;
            apbi     => apbctrl_i0_apbi,     --: in apb_slv_in_type;
            apbo     => apbo(11),            --: out apb_slv_out_type;
            spii     => spii,                --: in  spi_in_type;
            spio     => spictrl_i0_spio,     --: out spi_out_type;
            slvsel   => open                 --: out std_logic_vector((slvselsz-1) downto 0)
        );   
    spii.miso               <= ad9854_in.sdo;
    spii.mosi               <= '1';           -- slave mode not used
    spii.sck                <= '0';           -- slave mode not used
    spii.spisel             <= '1';           -- slave mode not used 
    spii.astart             <= '0';           -- slave mode not used 
    ad9854_out.cs_n         <= '0';
    ad9854_out.master_res   <= grgpio_i0_gpioo.dout(15);
    ad9854_out.sclk         <= spictrl_i0_spio.sck;
    ad9854_out.sdio         <= spictrl_i0_spio.mosi;
    ad9854_out.sdio_en      <= spictrl_i0_spio.mosioen;
    ad9854_out.io_reset     <= grgpio_i0_gpioo.dout(14);
    ad9854_out.io_ud_clk    <= grgpio_i0_gpioo.dout(13);
    ad9854_out.io_ud_clk_en <= '1';


    ---------------------------------------------------------------------

--  -- in mapping
--  rena3_out.ts   <= rena3_ts;
--  rena3_out.tf   <= rena3_tf;
--  rena3_out.fout <= rena3_fout;
--  rena3_out.sout <= rena3_sout;
--  rena3_out.tout <= rena3_tout;
--      
--  rena3_controller_i0: rena3_controller
--      port map (
--          -- system
--          clock     => clk,                           -- : std_ulogic;
--          -- rena3 (connection to chip)
--          rena3_in  => rena3_out,                     -- : in  rena3_controller_in_t;
--          rena3_out => rena3_controller_io_rena3_out, -- : out rena3_controller_out_t;
--          -- connection to soc
--          zpu_in    => zpu_i0_zpu_out,                -- : in  zpu_out_t;
--          zpu_out   => open --rena3_controller_i0_zpu_out    -- : out zpu_in_t
--      );
-- 
--  -- out mapping 
--  rena3_chsift  <= rena3_controller_io_rena3_out.cshift;
--  rena3_cin     <= rena3_controller_io_rena3_out.cin;
--  rena3_cs      <= rena3_controller_io_rena3_out.cs;
--  rena3_read    <= rena3_controller_io_rena3_out.read;
--  rena3_tin     <= rena3_controller_io_rena3_out.tin;
--  rena3_sin     <= rena3_controller_io_rena3_out.sin;
--  rena3_fin     <= rena3_controller_io_rena3_out.fin;
--  rena3_shrclk  <= rena3_controller_io_rena3_out.shrclk;
--  rena3_fhrclk  <= rena3_controller_io_rena3_out.fhrclk;
--  rena3_acquire <= rena3_controller_io_rena3_out.acquire;
--  rena3_cls     <= rena3_controller_io_rena3_out.cls;
--  rena3_clf     <= rena3_controller_io_rena3_out.clf;
--  rena3_tclk    <= rena3_controller_io_rena3_out.tclk;


--  rena3_controller_i0_zpu_out.enable      <= io_busy; -- TODO
--  rena3_controller_i0_zpu_out.mem_busy    <= io_busy; -- TODO
--  rena3_controller_i0_zpu_out.mem_read    <= std_ulogic_vector(dram_read) when dram_ready = '1' else
--                                             std_ulogic_vector(io_read)   when io_ready   = '1' else (others => 'U');
--  rena3_controller_i0_zpu_out.interrupt   <= '0'; -- TODO


end architecture rtl;
