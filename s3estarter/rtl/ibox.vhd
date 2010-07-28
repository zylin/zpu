-- ibox design

library ieee;
use ieee.std_logic_1164.all;

library s3estarter;
use s3estarter.types.all;



entity ibox is
    port (
        clk             : in    std_ulogic;
        reset           : in    std_ulogic;

        fpga_button     : in    fpga_button_in_t;
        fpga_led        : out   fpga_led_out_t; 
        fpga_rotary_sw  : in    fpga_rotary_sw_in_t
    );
end entity ibox;



library ieee;
use ieee.numeric_std.all;


architecture rtl of ibox is
    
    function gen_counter_max return positive is
        variable result : positive;
    begin
        result := 5_000_000; 
        -- pragma translate_off
        result := 10;
        -- pragma translate_on
        return result;
    end function gen_counter_max;

    constant counter_width : positive := integer( ieee.math_real.ceil( ieee.math_real.log2( real( gen_counter_max+1))));
    constant counter_max   : unsigned(counter_width-1 downto 0) := to_unsigned( gen_counter_max, counter_width);
                           
                           
    signal leds            : std_ulogic_vector(7 downto 0);
    signal leds_en         : std_ulogic;
                           
    signal counter         : unsigned(counter_width-1 downto 0);

    type reg_t is record
        counter            : unsigned(counter_width-1 downto 0);
        leds_en            : std_ulogic;
        leds               : std_ulogic_vector(7 downto 0);
    end record reg_t;
    constant default_reg_c : reg_t := (
        counter  => (others => '0'),
        leds_en  => '0',
        leds     => "00000001"
    );

    signal r, r_in         : reg_t;

begin
    
    comb: process( r)
        variable v : reg_t;
    begin
        v             := r;
        fpga_led.data <= v.leds;

        if v.leds_en = '1' then
            v.leds    := v.leds( v.leds'high-1 downto 0) & v.leds( v.leds'high);
        end if;

       
        v.leds_en     := '0'; 
        v.counter     := v.counter + 1;

        if v.counter = counter_max then
            v.leds_en := '1';
            v.counter := (others => '0');
        end if;

        r_in          <= v;
    end process;

    seq: process
    begin
        wait until rising_edge(clk);

        r     <= r_in;

        if reset = '1' then
            r <= default_reg_c;
        end if;
    end process;
    

end architecture rtl;
