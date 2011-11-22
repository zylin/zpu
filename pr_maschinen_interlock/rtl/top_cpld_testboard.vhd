library ieee;
use ieee.std_logic_1164.all;

entity top_cpld_testboard is
	port(
        reset         : in  std_logic;
        clk           : in  std_logic;
        bcd_switch_n  : in  std_logic_vector(3 downto 0);
	 	led_n         : out std_logic_vector(7 downto 0)
	);
end top_cpld_testboard;

architecture rtl of top_cpld_testboard is
        
    signal bcd_switch             : std_logic_vector(3 downto 0);

    signal channel_i0_error       : std_ulogic;
    signal channel_i0_channel_ok  : std_ulogic;

begin

    bcd_switch <= not bcd_switch_n;

    channel_i0: entity work.channel
    port map (
	 	  clk               => clk,                   --: in  std_ulogic;
        channel_active_in => bcd_switch(3),         --: in  std_ulogic;
        error_in_n        => bcd_switch_n(2),       --: in  std_ulogic; -- low active
        test_in_n         => '1',                   --: in  std_ulogic; -- low active
        test_sps_in       => bcd_switch(1),         --: in  std_ulogic;
        clear             => '0',                   --: in  std_ulogic;
        clear_sps         => bcd_switch(0),         --: in  std_ulogic;
        --                                          
        error_out         => channel_i0_error,      --: out std_ulogic;
        channel_ok_out    => channel_i0_channel_ok  --: out std_ulogic
    );

--    led_n(0) <= not channel_i0_channel_ok;
--    led_n(1) <= not channel_i0_error;
--    led_n(2) <= '1';
--    led_n(3) <= '1';
--    led_n(7 downto 4) <= bcd_switch_n;
    led_n(3 downto 0) <= not (3 downto 0 => channel_i0_channel_ok);
    led_n(7 downto 4) <= not (3 downto 0 => channel_i0_error);

end architecture rtl;

