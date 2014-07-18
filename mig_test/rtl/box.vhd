--------------------------------------------------------------------------------
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.or_reduce; -- by synopsis
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.memctrl.all; -- spimctrl types + spmictrl component

-- components
library gaisler;
use gaisler.uart.apbuart;
use gaisler.misc.ahbdpram;
use gaisler.misc.gptimer;
use gaisler.misc.grgpio;
use gaisler.misc.apbvga;
use gaisler.misc.ahbram;
use gaisler.memoryctrl.mctrl;  -- original in esa lib
use gaisler.net.greth;

library techmap;
use techmap.gencomp.all; -- constants

library zpu;
use zpu.zpu_wrapper_package.all; -- types
use zpu.zpu_config.all;
use zpu.zpupkg.all;
use zpu.zpu_wrapper_package.zpu_ahb;
use zpu.zpu_wrapper_package.dualport_ram_ahb_wrapper; -- for medium zpu

library hzdr;
use hzdr.component_package.debug_con_apb;

library work;
use work.timestamp.all;



entity box is
    generic (
        system_frequency    : integer;
        simulation_active   : std_ulogic 
    );
    port (
        clk                 : in    std_ulogic;        -- clock
        reset_n             : in    std_ulogic;        -- synchronous reset (low active)
        break               : out   std_ulogic;        -- to stop simulation
        --                  
        uarti               : in    uart_in_type;      -- UART
        uarto               : out   uart_out_type;
        --                  
        gpioi               : in    gpio_in_type;      -- GPIO (button, switches, LED, header pins)
        gpioo               : out   gpio_out_type
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
    signal box_mctrl_wpo                 : wprot_out_type := (wprothit => '0');
    --
    -- put these signals in entity (later)
    signal ethi                          : eth_in_type;         -- ethernet PHY
    signal etho                          : eth_out_type;

begin
    
    ---------------------------------------------------------------------
    --  reset

    box_reset   <= (not reset_n) or debug_con_apb_i0_softreset;
    box_reset_n <= not box_reset;

    ---------------------------------------------------------------------
    --  AHB bus masters
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
    ahbmo( 2) <= ahbm_none;
    ahbmo( 3) <= ahbm_none;
    ahbmo( 4) <= ahbm_none;
    ahbmo( 5) <= ahbm_none;
    ahbmo( 6) <= ahbm_none;
    ahbmo( 7) <= ahbm_none;
    ahbmo( 8) <= ahbm_none;
    ahbmo( 9) <= ahbm_none;
    ahbmo(10) <= ahbm_none;
    ahbmo(11) <= ahbm_none;
    ahbmo(12) <= ahbm_none;
    ahbmo(13) <= ahbm_none;
    ahbmo(14) <= ahbm_none;
    ahbmo(15) <= ahbm_none;
    --
    --ahbso(0) <= (ahbs_none); -- apbctrl_i0
    --ahbso(1) <= (ahbs_none); -- ahbram_i0
    ahbso( 2) <= (ahbs_none);
    --ahbso(3) <= (ahbs_none); -- dualport_ram_ahb_wrapper_i0
    ahbso( 4) <= (ahbs_none); -- spimctrl
    ahbso( 5) <= (ahbs_none);
    ahbso( 6) <= (ahbs_none); 
    ahbso( 7) <= (ahbs_none); 
    ahbso( 8) <= (ahbs_none); 
    ahbso( 9) <= (ahbs_none); 
    ahbso(10) <= (ahbs_none); 
    ahbso(11) <= (ahbs_none); 
    ahbso(12) <= (ahbs_none); 
    ahbso(13) <= (ahbs_none); 
    ahbso(14) <= (ahbs_none); 
    ahbso(15) <= (ahbs_none); 

    ahbctrl_i0 : ahbctrl        -- AHB arbiter/multiplexer
        generic map (
            defmast    => 0,    -- default master
            timeout    => 11,
            disirq     => 0,    -- enable interrupt routing
            enbusmon   => 0,    -- enable bus monitor
            rrobin     => 0,
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
    --  AHB bus slaves
    ---------------------------------------------------------------------


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
            rst    => box_reset_n,
            clk    => clk,
            ahbsi  => ahbctrl_i0_slvi,
            ahbso  => ahbso(1)
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


--  ---------------------------------------------------------------------
--  -- AHB SPI memory controller
--  -- for SPI X4 (Winbond W25Q64VSFIG) 64-Mbit flash memory 
--  spimctrl_i0 : spimctrl
--      generic map (
--          hindex     => 4,           -- : integer := 0;            -- AHB slave index
--          faddr      => 16#E00#,     -- : integer := 16#000#;      -- Flash map base address
--          fmask      => 16#FF8#,     -- : integer := 16#fff#;      -- Flash area mask
--          ioaddr     => 16#002#,     -- : integer := 16#000#;      -- I/O base address
--          iomask     => 16#fff#,     -- : integer := 16#fff#;      -- I/O mask
--          readcmd    => 16#3b#,      -- : integer range 0 to 255 := 16#0B#;  -- Mem. dev. READ command
--          dummybyte  => 1,           -- : integer range 0 to 1   := 1; -- Dummy byte after cmd
--          dualoutput => 1            -- : integer range 0 to 1   := 0; -- Enable dual output
--      )
--      port map (
--          rstn   => box_reset_n,     -- : in  std_ulogic;       
--          clk    => clk,             -- : in  std_ulogic;
--          ahbsi  => ahbctrl_i0_slvi, -- : in  ahb_slv_in_type;
--          ahbso  => ahbso(4),        -- : out ahb_slv_out_type;
--          spii   => spmi,            -- : in  spimctrl_in_type;
--          spio   => spmo             -- : out spimctrl_out_type
--      );
--  ---------------------------------------------------------------------




    ---------------------------------------------------------------------
    --  AHB/APB bridge

    --apbo( 0) <= (apb_none); -- debug_con_apb_i0
    --apbo( 1) <= (apb_none); -- apbuart_i0
    --apbo( 2) <= (apb_none); -- gptimer_i0
    apbo( 3) <= (apb_none);
    --apbo( 4) <= (apb_none); -- grgpio_i0
    --apbo( 5) <= (apb_none); -- greth_i0
    apbo( 6) <= (apb_none);   -- no apbvga_i0
    apbo( 7) <= (apb_none);   -- no i2cmst_i0
    apbo( 8) <= (apb_none);
    apbo( 9) <= (apb_none);
    apbo(10) <= (apb_none);
    apbo(11) <= (apb_none);
    apbo(12) <= (apb_none);
    apbo(13) <= (apb_none);
    apbo(14) <= (apb_none);
    apbo(15) <= (apb_none);

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
    --  APB bus slaves
    ---------------------------------------------------------------------

    
    ---------------------------------------------------------------------
    -- debug console (for fast simulation output)
    debug_con_apb_i0: debug_con_apb
        generic map (
            pindex           => 0,                  -- : integer := 0;
            paddr            => 0,                  -- : integer := 0;
            -- values taken from timestamp.vhd:
            svnrevision      => svnrevision_c,      -- : string( 1 to 21) := "unknown SVN revision ";
            version_time     => version_time_c,     -- : string( 1 to 21) := "undefined version    "
            system_frequency => system_frequency    -- : integer 
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
    gpti.wdogen <= '0'; -- watchdog enable

    gptimer_i0: gptimer
        generic map (
            pindex  => 2,
            paddr   => 2,
            pirq    => 3,
            sepirq  => 0, -- use separate interupts for each timer
            sbits   => 8, -- prescaler bits
            ntimers => 2, -- number of timers
            nbits   => 24 -- timer bits
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
    --  3 -  0  LED                               unused
    --       4  MAC_DATA                          MAC_DATA
    --       5  user_led                          unused
    -- 15 -  8  unused                            unused
    -- 30 - 16  unused                            unused
    -- 31       unused                            simulation_active
    ---------------------------------------------------------------------


end architecture rtl;
