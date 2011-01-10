library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity singlepulser is
  generic (
 -- counter_width : natural := 21 -- 100 ms  10 Hz
    counter_width : natural := 17 -- 10 ms  100 Hz
  );
  port (
    clk       : in  std_logic;
    pulse_in  : in  std_logic;          -- 13 MHz
    pulse_out : out std_logic           -- 50 us
    );
end entity singlepulser;

-- pin constraints:
--
-- singlepulser.ucf

--NET "clk"  LOC = "P6"  ;
--NET "pulse_in"  LOC = "P7"  ;
--NET "pulse_out"  LOC = "P19"  ;

architecture rtl of singlepulser is
  
  constant pulse_counter_max_c    : unsigned(counter_width-1 downto 0) := to_unsigned(13 * 10_000, counter_width);
  constant pulse_counter_switch_c : unsigned(counter_width-1 downto 0) := to_unsigned(13 *     50, counter_width);

  signal pulse_reg     : std_logic_vector(1 downto 0);
  signal pulse_counter : unsigned(counter_width-1 downto 0) := to_unsigned(0, counter_width);
  signal pulse_out_int : std_logic := '0';

begin

  process
  begin
    wait until rising_edge(clk);

    -- schieberegister
    pulse_reg <= pulse_reg(0) & pulse_in;

    if pulse_reg = "01" then            -- 13 MHz detected

      -- counter
      if pulse_counter < pulse_counter_max_c then
        pulse_counter <= pulse_counter + 1;
      else
        pulse_counter <= to_unsigned(1, pulse_counter'length);
        pulse_out_int <= '1';
      end if;
      
      -- pwm light
      if pulse_counter = pulse_counter_switch_c then
        pulse_out_int <= '0';
      end if;

    end if;

  end process;

  -- synchronize output with 13 MHz
  process
  begin
    wait until rising_edge(pulse_in);
    pulse_out <= pulse_out_int;
  end process;

end architecture rtl;
