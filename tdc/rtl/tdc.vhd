
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tdc;
use tdc.types.all;
use tdc.components.channel;


entity my_tdc is
    generic (
        no_channels_g : natural := 2
    );
    port (
        channels      : in  std_ulogic_vector(no_channels_g-1 downto 0);
        clk           : in  std_ulogic;
        results       : out unsigned_vector(no_channels_g-1 downto 0)
    );
end entity my_tdc;


architecture rtl of my_tdc is

begin
    channels_i: for i in 0 to no_channels_g-1 generate
        channel_i: channel
            generic map (
                taps_g  => taps_c,
                index_g => i
            )
            port map (
                clk     => clk,
                input   => channels(i),
                count   => results(i)
            ); 
    end generate;


end architecture rtl;
