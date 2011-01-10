--
-- simulation commands for modelsim:
-- 
-- vlib work
-- vcom singlepulser.vhd
-- vcom testbench.vhd
-- vsim -t ps testbench
-- do wave.do
-- run 250 ms

library ieee;
use ieee.std_logic_1164.all;


entity testbench is
end entity testbench;


architecture testbench of testbench is

  constant tb_pulse_13_period : time := 1 sec / (13_000_000);
  constant tb_clk_period      : time := 1 sec / (40_000_000);

  component singlepulser is
    port (
      clk       : in  std_logic;
      pulse_in  : in  std_logic;        -- 13 MHz
      pulse_out : out std_logic := '0'  -- 50 us
      );
  end component;

  signal tb_pulse_13                : std_logic := '0';  -- 13 MHz
  signal tb_pulse_13_duty_cycle     : real      := 0.5;
  signal tb_clk                     : std_logic := '0';  -- 40 MHz
  --
  signal singlepulser_i0_pulse_out  : std_logic;

begin

  tb_clk <= not tb_clk after tb_clk_period / 2;

  process
  begin
    tb_pulse_13 <= '1';
    wait for tb_pulse_13_period * tb_pulse_13_duty_cycle;
    tb_pulse_13 <= '0';
    wait for tb_pulse_13_period * (1.0 - tb_pulse_13_duty_cycle);
  end process;

  singlepulser_i0 : singlepulser
    port map (
      clk       => tb_clk,                      -- : in  std_logic;
      pulse_in  => tb_pulse_13,                 -- : in  std_logic;   -- 13 MHz
      pulse_out => singlepulser_i0_pulse_out    -- : out std_logic    -- 50 us
      );

  -- measure high phase of pulse out 
  process
    variable start_time : time;
    variable stop_time  : time;
    variable diff_time  : time;
  begin
    wait until rising_edge(singlepulser_i0_pulse_out);
    start_time := now;
    wait until falling_edge(singlepulser_i0_pulse_out);
    stop_time  := now;
   
    diff_time := stop_time - start_time;

    assert (diff_time = 50_000_600 ps)
    report "pulse high phase: " & time'image( diff_time);
  end process;

end architecture testbench;
