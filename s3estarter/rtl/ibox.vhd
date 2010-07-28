-- ibox design

library ieee;
use ieee.std_logic_1164.all;

library s3estarter;
use s3estarter.types.all;



entity ibox is
    port (
        clk             : in    std_ulogic;
        reset           : in    std_ulogic;

        fpga_button     : in    fpga_button_in_t;
        fpga_led        : out   fpga_led_out_t; 
        fpga_rotary_sw  : in    fpga_rotary_sw_in_t;
        -- to stop simulation
        break           : out   std_ulogic

    );
end entity ibox;



library ieee;
use ieee.numeric_std.all;


library zpu;
use zpu.zpu_wrapper_package.zpu_wrapper;
use zpu.zpu_wrapper_package.zpu_io;
use zpu.zpu_wrapper_package.zpu_ahb;
use zpu.zpu_wrapper_package.all; -- types
use zpu.zpu_config.all;
use zpu.zpupkg.all;


library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.gptimer;
use gaisler.misc.grgpio;
use gaisler.misc.all; -- types
use gaisler.uart.apbuart;
use gaisler.uart.all; -- types


architecture rtl of ibox is
    
    signal reset_n                       : std_ulogic;

    signal ahbctrl_i0_msti               : ahb_mst_in_type;
    signal ahbmo                         : ahb_mst_out_vector := (others => ahbm_none);
    signal ahbctrl_i0_slvi               : ahb_slv_in_type;
    signal ahbso                         : ahb_slv_out_vector := (others => ahbs_none);
    signal apbctrl_i0_apbi               : apb_slv_in_type;
    signal apbo                          : apb_slv_out_vector := (others => apb_none);
    
    signal uarti                         : uart_in_type;
    signal uarto                         : uart_out_type;
                                         
    signal gpti                          : gptimer_in_type;
    signal gpto                          : gptimer_out_type;
                                         
    signal gpioi                         : gpio_in_type;
    signal gpioo                         : gpio_out_type;
                                         
    signal stati                         : ahbstat_in_type;

begin
    
    reset_n        <= not reset;
    
    zpu_ahb_i0: zpu_ahb
    port map (
        clk    => clk,             -- : in  std_ulogic;
	 	areset => reset,           -- : in  std_ulogic;
        ahbi   => ahbctrl_i0_msti, -- : in  ahb_mst_in_type; 
        ahbo   => ahbmo(0),        -- : out ahb_mst_out_type;
        break  => break            -- : out std_ulogic
    );
    
    ---------------------------------------------------------------------
    --  AHB CONTROLLER
    ----------------------------------------------------------------------

    ahbctrl_i0 : ahbctrl        -- AHB arbiter/multiplexer
        generic map (
            timeout    => 11,
            nahbm      => 1, 
            nahbs      => 2,
            disirq     => 1,    -- disable interrupt routing
            enbusmon   => 0,    -- enable bus monitor
            assertwarn => 1,    -- enable assertions for warnings
            asserterr  => 1     -- enable assertions for errors
        )
        port map (
            rst  => reset_n,          -- : in  std_ulogic;
            clk  => clk,              -- : in  std_ulogic;
            msti => ahbctrl_i0_msti,  -- : out ahb_mst_in_type;
            msto => ahbmo,            -- : in  ahb_mst_out_vector;
            slvi => ahbctrl_i0_slvi,  -- : out ahb_slv_in_type;
            slvo => ahbso             -- : in  ahb_slv_out_vector;
        );

    ---------------------------------------------------------------------
    --  AHB/APB bridge
    ----------------------------------------------------------------------
    apbctrl_i0: apbctrl
        generic map (
            hindex      => 1,            -- : integer := 0;
            haddr       => 16#800#,      -- : integer := 0;
            nslaves     => 16            -- : integer range 1 to NAPBSLV := NAPBSLV;
        )                                
        port map (                       
            rst   => reset_n,            -- : in  std_ulogic;
            clk   => clk,                -- : in  std_ulogic;
            ahbi  => ahbctrl_i0_slvi,    -- : in  ahb_slv_in_type;
            ahbo  => ahbso(1),           -- : out ahb_slv_out_type;
            apbi  => apbctrl_i0_apbi,    -- : out apb_slv_in_type;
            apbo  => apbo                -- : in  apb_slv_out_vector                
        );
    
    -- uart
    apbuart_i0: apbuart
        generic map (
            pindex     => 1,
            paddr      => 1
        )
        port map (
            rst   => reset_n,
            clk   => clk,
            apbi  => apbctrl_i0_apbi,
            apbo  => apbo(1),
            uarti => uarti,
            uarto => uarto
        );


    -- GP timer
    gptimer_i0: gptimer
        generic map (
            pindex  => 2,
            paddr   => 2,
            pirq    => 3,
            sepirq  => 0, -- use separate interupts for each timer
            ntimers => 1, -- number of timers
            nbits   => 32 -- timer bits
        )
        port map (
            rst     => reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(2),
            gpti    => gpti,
            gpto    => gpto
        );

    -- GPIO
    grgpio_i0: grgpio
        generic map (
            pindex => 8, 
            paddr  => 8, 
            imask  => 16#00F0#, 
            nbits  => 14
        )
        port map (
            rst    => reset_n, 
            clk    => clk, 
            apbi   => apbctrl_i0_apbi, 
            apbo   => apbo(8),
            gpioi  => gpioi, 
            gpioo  => gpioo
        );

    -- AHB status register
    ahbstat_i0: ahbstat
        generic map (
            pindex => 15, 
            paddr  => 15, 
            pirq   => 7 
        ) 
        port map (
            rst   => reset_n,
            clk   => clk, 
            ahbmi => ahbctrl_i0_msti, 
            ahbsi => ahbctrl_i0_slvi, 
            stati => stati, 
            apbi  => apbctrl_i0_apbi, 
            apbo  => apbo(15)
        );

    

end architecture rtl;
