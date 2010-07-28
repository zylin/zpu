
library ieee;
use ieee.std_logic_1164.all;


package types is

    type fpga_button_in_t is record
        east  : std_ulogic;
        north : std_ulogic;
        south : std_ulogic;
        west  : std_ulogic;
    end record fpga_button_in_t;


    type fpga_clk_in_t is record
        clk50 : std_ulogic;
        aux   : std_ulogic;
        sma   : std_ulogic;
    end record fpga_clk_in_t;

    type fpga_led_out_t is record
        data  : std_ulogic_vector(7 downto 0);
    end record fpga_led_out_t;


end package types;
