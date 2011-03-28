---------------------------------------------------------------
-- http://www.lothar-miller.de/s9y/categories/29-Ringoszillator
--
library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;


entity ring_oszillator is
    port (
        reset  : in  std_ulogic;
        oscout : out std_ulogic
    );
end ring_oszillator;

architecture rtl of ring_oszillator is

  constant  length       : positive   := 8;
                         
  signal    oscff        : std_ulogic := '0';
  signal    ring         : std_ulogic_vector(length-1 downto 0);

  attribute keep         : string; 
  attribute keep of ring : signal is "true"; 

begin
    -- die Gatterkette
    ring <= ring( length-2 downto 0) & not ring( length-1) when reset='0' else ( others=>'0');

    -- das Symmetrier-Flipflop
    process
    begin
        wait until rising_edge( ring( length-1));
        oscff <= not oscff;
    end process;

    -- die Ausgangszuweisung
    oscout <= oscff;

end architecture rtl;
