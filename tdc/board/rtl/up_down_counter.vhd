library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity up_down_counter is
  
  generic (
    NUMBER_OF_BITS : positive
    );
  port (
    CLK : in std_logic;
    RESET : in std_logic;
    COUNT_OUT : out std_logic_vector(NUMBER_OF_BITS-1 downto 0);
    UP_IN : in std_logic;
    DOWN_IN : in std_logic
    );
  
end up_down_counter;

architecture up_down_counter of up_down_counter is

signal counter: unsigned (NUMBER_OF_BITS-1 downto 0);

begin
  
  COUNTER_PROC : process (CLK)
  begin
    if rising_edge(clk) then
      if RESET = '1' then
        counter <= (others => '0');
      elsif UP_IN = '1' and DOWN_IN = '0' then
        counter <= counter + 1;
      elsif UP_IN = '0' and DOWN_IN = '1' then
        counter <= counter - 1;
      else
        counter <= counter;
      end if;
    end if;
  end process COUNTER_PROC;

  COUNT_OUT <= std_logic_vector( counter);

  

end up_down_counter;
