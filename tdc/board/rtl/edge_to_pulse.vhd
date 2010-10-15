

library ieee;
use ieee.std_logic_1164.all;


--library synplify;
--use synplify.attributes.all;


entity edge_to_pulse is

 port (
         clock : in std_logic;
         en_clk : in std_logic;
         signal_in : in std_logic;
         pulse : out std_logic
);

end edge_to_pulse;

architecture arch_edge_to_pulse of edge_to_pulse is
 signal signal_sync : std_logic;
 signal old_sync : std_logic;
 signal pulse_fsm : std_logic;
 type state is (idle, high, wait_for_low);  -- state
  signal current_state, next_state : state;

begin                                       -- arch_edge_to_pulse

  fsm : process (clock)
  begin                                     -- process fsm
    if rising_edge(clock) then              -- rising clock edge
      if en_clk = '1' then
        current_state <= next_state;
        signal_sync   <= signal_in;
        pulse <= pulse_fsm;
      end if;
    end if;
  end process fsm;


  fsm_comb : process (current_state, signal_sync)
  begin                                     -- process fsm_comb
    case current_state is
      when idle         =>
        pulse_fsm        <= '0';
        if signal_sync = '1' then
          next_state <= high;
        else
          next_state <= idle;
        end if;
      when high         =>
        pulse_fsm        <= '1';
        next_state   <= wait_for_low;
--       when wait_for_low_1 =>
--         pulse <= '1';
--         next_state <= wait_for_low;
      when wait_for_low =>
        pulse_fsm        <= '0';
        if signal_sync = '0' then
          next_state <= idle;
        else
          next_state <= wait_for_low;
        end if;
      when others       =>
        pulse_fsm        <= '0';
       next_state   <= idle;
    end case;
  end process fsm_comb;


end arch_edge_to_pulse;

