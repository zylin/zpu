
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce; -- by synopsis


entity system is
    port (
        clk                  : in  std_ulogic;
        reset_n              : in  std_ulogic;
		--                   
        channel_active_in_n  : in  std_ulogic_vector(16 downto 1);
        error_in_n           : in  std_ulogic_vector(16 downto 1);
        test_mt_in_n         : in  std_ulogic; -- modultaster
        test_sps_in_n        : in  std_ulogic;
        clear_mt_in_n        : in  std_ulogic; -- modultaster
        clear_sps_in_n       : in  std_ulogic;
        --                  
        main_error_led_out_n : out std_ulogic;
        main_ok_opto_out     : out std_ulogic;
        main_ok_led_out_n    : out std_ulogic;
        channel_ok_out       : out std_ulogic_vector(16 downto 1);
        error_out_n          : out std_ulogic_vector(16 downto 1);
        test_led1_n          : out std_ulogic;
        test_led2_n          : out std_ulogic
    );
end entity system;


architecture rtl of system is
    
    signal error_out_int      : std_ulogic_vector(16 downto 1);
    signal channel_ok_out_int : std_ulogic_vector(16 downto 1);
    --
    signal counter            : unsigned(23 downto 0) := (others => '0');
    signal blink              : std_ulogic;

begin

    channels: for i in channel_active_in_n'range generate

        channel_i: entity work.channel
            port map (
                clk                 => clk,                     --: in  std_ulogic;
                reset_n             => reset_n,                 --: in  std_ulogic;
                channel_active_in_n => channel_active_in_n(i),  --: in  std_ulogic;
                error_in_n          => error_in_n(i),           --: in  std_ulogic; -- low active
                test_in_n           => test_mt_in_n,            --: in  std_ulogic; -- low active
                test_sps_in_n       => test_sps_in_n,           --: in  std_ulogic;
                clear_n             => clear_mt_in_n,           --: in  std_ulogic;
                clear_sps_n         => clear_sps_in_n,          --: in  std_ulogic;
                --                                
                error_out           => error_out_int(i),        --: out std_ulogic;
                channel_ok_out      => channel_ok_out_int(i)    --: out std_ulogic
            );

    end generate channels;

    process( error_out_int, channel_ok_out_int, counter, test_mt_in_n, clear_mt_in_n)
    begin
        main_error_led_out_n <= not( or_reduce( error_out_int));
        error_out_n          <= not( error_out_int);

        main_ok_opto_out     <= not or_reduce( error_out_int);
        main_ok_led_out_n    <= not( or_reduce( channel_ok_out_int) and (not or_reduce( error_out_int)));
        channel_ok_out       <= channel_ok_out_int;

        -- press both (clear & test) buttons for
        -- test of all LEDs
        -- give some blinks out
        if (test_mt_in_n = '0') and (clear_mt_in_n = '0') then
            channel_ok_out       <= (others => blink);
            error_out_n          <= (others => blink);
            main_ok_opto_out     <= blink;
            main_ok_led_out_n    <= not blink;
            main_error_led_out_n <= blink;
        end if;
    end process;
    


    process
    begin
        wait until rising_edge( clk);
        counter <= counter + 1;
    end process;

    blink       <= counter( counter'high);

    test_led1_n <= not( blink);
    test_led2_n <=      blink;

end architecture rtl;
