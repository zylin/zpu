entity ringoszillator_tb is
end entity ringoszillator_tb;


library ieee;
use ieee.std_logic_1164.all;

library tdc;
use tdc.components.ring_oszillator;


architecture testbench of ringoszillator_tb is

    signal tb_reset                  : std_ulogic;
    signal ring_oszillator_i0_oscout : std_ulogic;

begin

    tb_reset <= '1', '0' after 100 ns;

    ring_oszillator_i0: ring_oszillator
    port map (
        reset  => tb_reset,
        oscout => ring_oszillator_i0_oscout
    );


end architecture testbench;
