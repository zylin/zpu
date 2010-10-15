library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tdc;
use tdc.types.all;


package components is


    -------------------- 
    component my_tdc is
        generic (
            no_channels_g : natural
        );
        port (
            channels      : in  std_ulogic_vector(no_channels_g-1 downto 0);
            clk           : in  std_ulogic;
            results       : out unsigned_vector(no_channels_g-1 downto 0)
        );
    end component my_tdc;


    -------------------- 
    component channel is
        generic (
            taps_g   : natural;
            index_g  : natural
        );
        port (
            input    : in  std_ulogic;
            clk      : in  std_ulogic;
            count    : out unsigned
        );
    end component channel;
    
    -------------------- 
    component thermometer_coder is
        generic (
            thermo_in_no_g : natural
        );
        port (
            clk            : in  std_ulogic;
            thermo_in      : in  std_ulogic_vector;
            code_out       : out unsigned
        );
    end component thermometer_coder;

    -------------------- 
    component ring_oszillator is
        port (
            reset  : in  std_ulogic;
            oscout : out std_ulogic
        );
    end component ring_oszillator;



end package components;
