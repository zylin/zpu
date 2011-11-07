
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package types_package is


    --constant wait_time_width : positive := 24; -- 2^24 = 16M = 1.3 s
    --constant on_time_width   : positive := 24; -- 2^24 = 16M = 1.3 s
    --constant off_time_width  : positive := 24; -- 2^24 = 16M = 1.3 s
    --constant cycles_width    : positive := 10; -- max. 1023 pulses
    -- to reduce area size
    constant wait_time_width : positive := 8;
    constant on_time_width   : positive := 8;
    constant off_time_width  : positive := 8;
    constant cycles_width    : positive := 8;



    type trigger_generator_ctrl_in_t is record
        update       : std_ulogic;
        wait_time    : unsigned(wait_time_width-1 downto 0);
        on_time      : unsigned(  on_time_width-1 downto 0);
        off_time     : unsigned( off_time_width-1 downto 0);
        cycles       : unsigned(   cycles_width-1 downto 0);
        gated_in     : std_ulogic;
    end record trigger_generator_ctrl_in_t;
    constant default_trigger_generator_ctrl_in_c : trigger_generator_ctrl_in_t := (
        update      => '0',
        wait_time   => (others => '0'),
        on_time     => (others => '0'),
        off_time    => (others => '0'),
        cycles      => (others => '0'),
        gated_in    => '0'
    );


    type trigger_generator_ctrl_out_t is record
        gated_out    : std_ulogic;
        active       : std_ulogic;
        sig_out      : std_ulogic;
    end record trigger_generator_ctrl_out_t;


    ---------------------------
    -- types for SFP connection
    type sfp_control_out_t is record
        tx_disable   : std_ulogic; -- 1 = SFP enabled, 0 = SFP disabled
        rt_sel       : std_ulogic; -- 1 = Full bandwidth, 0 = reduced bandwith !!ATTN -> Jumper
    end record sfp_control_out_t;
    constant default_sfp_control_out_c : sfp_control_out_t := (
        tx_disable => '0',
        rt_sel     => '1'
    );


    type sfp_status_in_t is record
        tx_fault     : std_ulogic; -- 1 = fault, 0 = normal operation
        mod_detect   : std_ulogic; -- 1 = module not present, 0 = module present
        los          : std_ulogic; -- 1 = Loss of Receiver Signal, 0 = normal operation
    end record sfp_status_in_t;
        


end package types_package;
