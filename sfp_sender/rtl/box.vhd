
library ieee;
use ieee.std_logic_1164.all;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types

library work;
use work.types_package.all;


entity box is
    port (
        simulation_break : out   std_ulogic;
        clk              : in    std_ulogic;
        reset_n          : in    std_ulogic;
        --               
        uarti            : in    uart_in_type;
        uarto            : out   uart_out_type;
        --               
        gpioi            : in    gpio_in_type;
        gpioo            : out   gpio_out_type;
        --                        
        fmc_i2ci         : in    i2c_in_type;
        fmc_i2co         : out   i2c_out_type;
        --
        sfp_status       : in    sfp_status_in_t;
        sfp_control      : out   sfp_control_out_t;
        sfp_rx           : in    std_ulogic;
        sfp_tx           : out   std_ulogic;
        --               
        trigger_signals  : out   std_ulogic_vector(9 downto 0)
    );
end entity box;


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce; -- by synopsis

library work;
use work.component_package.trigger_generator_apb;
use work.component_package.sfp_controller_apb;
use work.version.all;

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
use gaisler.uart.apbuart;
use gaisler.misc.gptimer;
use gaisler.misc.grgpio;

library techmap;
use techmap.gencomp.all; -- constants

library hzdr;
use hzdr.component_package.debug_con_apb;


architecture rtl of box is

    constant trigger_channels            : positive := 8;

    signal reset                         : std_ulogic;
    signal reset_shreg                   : std_ulogic_vector(3 downto 0) := "1111";
    --
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
    signal channel_update                : std_ulogic;
    signal trigger_signals_gated         : std_ulogic_vector(9 downto 0);
    signal trigger_signals_ungated       : std_ulogic_vector(9 downto 0);

begin
    
    ---------------------------------------------------------------------
    --  reset generator (now in top)

    reset <= not reset_n;


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
        break  => simulation_break                 -- : out std_ulogic
    );
    ---------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------
    --  AHB CONTROLLER

    -- slow down syntesis, but avoid synthesis warnings
    --ahbmo(0) <= (ahbm_none); -- zpu_ahb_i0
    ahbmo(1) <= (ahbm_none);
    ahbmo(2) <= (ahbm_none);
    ahbmo(3) <= (ahbm_none);
    --ahbso(0) <= (ahbs_none); -- apbctrl_i0
    ahbso(1) <= (ahbs_none);
    ahbso(2) <= (ahbs_none);
    --ahbso(3) <= (ahbs_none); -- dualport_ram_ahb_wrapper_i0 
    ahbso(4) <= (ahbs_none);
    ahbso(5) <= (ahbs_none);
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
            reset  => reset,
            ahbsi  => ahbctrl_i0_slvi,
            ahbso  => ahbso(3)
        );
    ----------------------------------------------------------------------


    ---------------------------------------------------------------------
    --  AHB/APB bridge

    -- slow down syntesis, but avoid synthesis warnings
    --apbo( 0) <= (apb_none); -- debug_con_apb_i0
    --apbo( 1) <= (apb_none); -- apbuart_i0
    --apbo( 2) <= (apb_none); -- gptimer_i0
    apbo( 3) <= (apb_none);
    --apbo( 4) <= (apb_none); -- grgpio_i0
    apbo( 5) <= (apb_none);
    apbo( 6) <= (apb_none);
    apbo( 7) <= (apb_none);   -- no i2cmst_i1
    --apbo( 8) <= (apb_none); -- trigger_generator_apb_i0
    --apbo( 9) <= (apb_none); -- sfp_controller_apb_i0
    --apbo(10) <= (apb_none); -- i2cmst_i0
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
            pindex       => 0,               -- : integer := 0;
            paddr        => 0,               -- : integer := 0;
            pmask        => 16#fff#,         -- : integer := 16#fff#
            version_time => version_time_c   -- : string( 1 to 21) := "undefined version    "
        )
        port map (
            rst    => reset_n,               -- : in  std_ulogic;
            clk    => clk,                   -- : in  std_ulogic;
            apbi   => apbctrl_i0_apbi,       -- : in  apb_slv_in_type;
            apbo   => apbo(0)                -- : out apb_slv_out_type
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
            gpioo  => grgpio_i0_gpioo
        );
    gpioo <= grgpio_i0_gpioo;
    -- gpio.din
    -- top_fpga_gpioi.din( 3 downto  0) <= std_logic_vector( gpio_switch);
    -- top_fpga_gpioi.din( 7 downto  4) <= gpio_button;
    -- top_fpga_gpioi.din(15 downto  8) <= gpio_header_ls;
    -- top_fpga_gpioi.din(29 downto 16) <= (others => '0');
    -- top_fpga_gpioi.din(31)           <= simulation_active;

    -- gpio.dout
    --  7 - 0   gating with channel 0
    -- 31       channel update
    --gpio_led       <= box_i0_gpioo.dout( 3 downto 0);
    --gpio_header_ls <= box_i0_gpioo.dout(15 downto 8);
    ---------------------------------------------------------------------

    channel_update <= grgpio_i0_gpioo.dout(31);


    ---------------------------------------------------------------------
    -- trigger generator instance 0 .. 7
--  trigger_generator_apb_instances: for i in 8 to (8 + trigger_channels - 1) generate
    trigger_generator_apb_i0: trigger_generator_apb
        generic map (
            pindex       => 8,                               -- : integer := 0;
            paddr        => 8,                               -- : integer := 0;
            channels     => 10                               -- : positive
          )
        port map (
            rst          => reset,                           -- : in  std_ulogic;
            clk          => clk,                             -- : in  std_ulogic;
            apbi         => apbctrl_i0_apbi,                 -- : in  apb_slv_in_type;
            apbo         => apbo(8),                         -- : out apb_slv_out_type;
            --
            update       => channel_update,                  -- : in  std_ulogic;
            gated_out    => trigger_signals_gated,           ---: out std_ulogic;
            sig_out      => trigger_signals_ungated          -- : out std_ulogic
        );


    ---------------------------------------------------------------------
    -- programmable gating with channel 0
    gating_loop: for i in trigger_signals_ungated'range generate
        gating_p: process
        begin
            wait until rising_edge( clk);
                if trigger_signals_gated(i) = '1' then
                    -- gated
                    trigger_signals(i) <= trigger_signals_ungated(i) and trigger_signals_ungated(0);
                else
                    -- ungated
                    trigger_signals(i) <= trigger_signals_ungated(i);
                end if;
        end process;
    end generate gating_loop;


    ---------------------------------------------------------------------
    -- SFP controller
    sfp_controller_apb_i0: sfp_controller_apb
        generic map (
            pindex      => 9,               -- : integer := 0;
            paddr       => 9                -- : integer := 0;
        )
        port map (        
            rst         => reset,           -- : in  std_ulogic;
            clk         => clk,             -- : in  std_ulogic;
            apbi        => apbctrl_i0_apbi, -- : in  apb_slv_in_type;
            apbo        => apbo(9),         -- : out apb_slv_out_type;
            --                              
            sfp_status  => sfp_status,      -- : in  sfp_status_in_t;
            sfp_control => sfp_control,     -- : out sfp_control_out_t;
            sfp_rx      => sfp_rx,          -- : in  std_ulogic;
            sfp_tx      => sfp_tx           -- : out std_ulogic
        );
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- I2C for FMC connector
    i2cmst_i0: i2cmst
        generic map (
            pindex  => 10,
            paddr   => 10,
            pmask   => 16#FFF#,
            pirq    => 15          -- TODO: check this
        )
        port map (
            rstn    => reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(10),
            i2ci    => fmc_i2ci,             --: in  i2c_in_type;
            i2co    => fmc_i2co              --: out i2c_out_type;
        );
    ---------------------------------------------------------------------


end architecture rtl;
