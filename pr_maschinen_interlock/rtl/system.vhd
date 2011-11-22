
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.or_reduce; -- by synopsis
--use ieee.std_logic_1164_additions.or_reduce;
--use ieee.numeric_std_additions.or_reduce;


entity system is
    port (
        clk               : in  std_ulogic;
        channel_active_in : in  std_ulogic_vector(16 downto 1);
        error_in_n        : in  std_ulogic_vector(16 downto 1);
        test_in_n         : in  std_ulogic;
        test_sps_in       : in  std_ulogic;
        clear             : in  std_ulogic;
        clear_sps         : in  std_ulogic;
        --
        error_out         : out std_ulogic_vector(16 downto 1);
        channel_ok_out    : out std_ulogic_vector(16 downto 1);
        main_error_out    : out std_ulogic;
        main_ok_out       : out std_ulogic
    );
end entity system;


architecture rtl of system is
    
    signal error_out_int      : std_ulogic_vector(16 downto 1);
    signal channel_ok_out_int : std_ulogic_vector(16 downto 1);

begin

    channels: for i in channel_active_in'range generate

        channel_i: entity work.channel
            port map (
                clk               => clk,                     --: in  std_ulogic;
                channel_active_in => channel_active_in(i),    --: in  std_ulogic;
                error_in_n        => error_in_n(i),           --: in  std_ulogic; -- low active
                test_in_n         => test_in_n,               --: in  std_ulogic; -- low active
                test_sps_in       => test_sps_in,             --: in  std_ulogic;
                clear             => clear,                   --: in  std_ulogic;
                clear_sps         => clear_sps,               --: in  std_ulogic;
                --                              
                error_out         => error_out_int(i),        --: out std_ulogic;
                channel_ok_out    => channel_ok_out_int(i)    --: out std_ulogic
            );

    end generate channels;

    main_error_out <= or_reduce( error_out_int);
    error_out      <= error_out_int;

    main_ok_out    <= or_reduce( channel_ok_out_int) and (not or_reduce( error_out_int));
    channel_ok_out <= channel_ok_out_int;

end architecture rtl;
