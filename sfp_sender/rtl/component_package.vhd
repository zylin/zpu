
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types

library work;
use work.types_package.all;


package component_package is

    
    component box is
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
    end component box;


    component sfp_controller_apb is
        generic (
            pindex       : integer := 0;
            paddr        : integer := 0;
            pmask        : integer := 16#fff#
        );            
        port (        
            rst          : in  std_ulogic;
            clk          : in  std_ulogic;
            apbi         : in  apb_slv_in_type;
            apbo         : out apb_slv_out_type;
            --           
            sfp_status   : in  sfp_status_in_t;
            sfp_control  : out sfp_control_out_t;
            sfp_rx       : in  std_ulogic;
            sfp_tx       : out std_ulogic
        );
    end component sfp_controller_apb;



    component trigger_generator_apb is
        generic (
            pindex       : integer := 0;
            paddr        : integer := 0;
            pmask        : integer := 16#fff#;
            channels     : positive range 1 to 32
        );            
        port (        
            rst         : in  std_ulogic;
            clk         : in  std_ulogic;
            apbi        : in  apb_slv_in_type;
            apbo        : out apb_slv_out_type;
            --          
            update      : in  std_ulogic;
            gated_out   : out std_ulogic_vector(channels-1 downto 0);
            sig_out     : out std_ulogic_vector(channels-1 downto 0)
        );
    end component trigger_generator_apb;


    component trigger_generator is
        port (        
            rst          : in  std_ulogic;
            clk          : in  std_ulogic;
            --
            ctrl_in      : in  trigger_generator_ctrl_in_t;
            ctrl_out     : out trigger_generator_ctrl_out_t
        );
    end component trigger_generator;



    component debug_con_apb is
        generic (
            pindex : integer := 0;
            paddr  : integer := 0;
            pmask  : integer := 16#fff#
        );
        port (
            rst  : in  std_ulogic;
            clk  : in  std_ulogic;
            apbi : in  apb_slv_in_type;
            apbo : out apb_slv_out_type
        );
    end component debug_con_apb;



end package component_package;
