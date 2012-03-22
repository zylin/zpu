library ieee;
use ieee.std_logic_1164.all;


entity top_cpld_testboard is
	port(
        reset_n       : in  std_logic;
        clk           : in  std_logic;
        dip_switch_n  : in  std_logic_vector(3 downto 0);
        button_n      : in  std_logic_vector(1 downto 0);		  
	 	  led_n         : out std_logic_vector(7 downto 0)
	);
end top_cpld_testboard;

architecture rtl of top_cpld_testboard is
        
    signal dip_switch             : std_logic_vector(3 downto 0);
	 signal button                 : std_logic_vector(1 downto 0);

    signal channel_i0_error       : std_ulogic;
    signal channel_i0_channel_ok  : std_ulogic;

begin

    dip_switch <= not dip_switch_n;
	 button     <= not button_n;

    channel_i0: entity work.channel
    port map (
	 	  reset_n           => reset_n,               --: in  std_ulogic;	 
	 	  clk               => clk,                   --: in  std_ulogic;
        channel_active_in => dip_switch(3),         --: in  std_ulogic;
        error_in_n        => dip_switch_n(2),       --: in  std_ulogic; -- low active
        test_in_n      => dip_switch_n(1),       --: in  std_ulogic; -- low active
        test_sps_in       => button(1),             --: in  std_ulogic;
        clear             => dip_switch(0),         --: in  std_ulogic;
        clear_sps         => button(0),             --: in  std_ulogic;
        --                                          
        error_out         => channel_i0_error,      --: out std_ulogic;
        channel_ok_out    => channel_i0_channel_ok  --: out std_ulogic
    );


    led_n(3 downto 0) <= not (3 downto 0 => channel_i0_channel_ok);
    led_n(7 downto 4) <= not (3 downto 0 => channel_i0_error);

end architecture rtl;

