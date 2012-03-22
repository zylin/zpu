
library ieee;
use ieee.std_logic_1164.all;


entity channel is
    port (
        reset_n             : in  std_ulogic;  -- low active
        clk                 : in  std_ulogic;
        channel_active_in_n : in  std_ulogic;  -- low active
        error_in_n          : in  std_ulogic;  -- low active
        test_in_n           : in  std_ulogic;  -- low active
        test_sps_in_n       : in  std_ulogic;  -- low active
        clear_n             : in  std_ulogic;  -- low active
        clear_sps_n         : in  std_ulogic;  -- low active
        --                  
        error_out           : out std_ulogic;
        channel_ok_out      : out std_ulogic
        );
end entity channel;


architecture rtl of channel is

    signal error_combined : std_ulogic;

    signal channel_active : std_ulogic := '0';
    signal channel_error  : std_ulogic := '0';
    signal channel_ok     : std_ulogic := '0';

begin


    error_combined <= (not test_sps_in_n) or (not test_in_n) or (not error_in_n);

    process (reset_n, clk)
    begin
        if reset_n = '0' then
            channel_active <= '0';
            channel_error  <= '0';
            channel_ok     <= '0';
        elsif rising_edge(clk) then
            
            if channel_active_in_n = '0' then

                -- activate channel
                if channel_active = '0' then
                    channel_active <= '1';
                    channel_error  <= '1';
                    channel_ok     <= '0';
                end if;

                -- clear error state
                if clear_n = '0' or clear_sps_n = '0' then
                    channel_error <= '0';
                    channel_ok    <= '1';
                end if;

                -- check for error or test input
                if error_combined = '1' then
                    channel_error <= '1';
                    channel_ok    <= '0';
                end if;

            else
                channel_ok     <= '0';
                channel_error  <= '0';
                channel_active <= '0';
            end if;

        end if;

    end process;


    process(channel_active, channel_error, channel_ok)
    begin
        -- defaults
        error_out      <= '0';
        channel_ok_out <= '0';

        if channel_active = '1' then

            if channel_error = '1' then
                error_out <= '1';
            end if;

            if channel_ok = '1' then
                channel_ok_out <= '1';
            end if;

        end if;
    end process;


end architecture rtl;
