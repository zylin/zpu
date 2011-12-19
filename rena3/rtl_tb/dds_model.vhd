entity dds_model is
    port (
        run : in  boolean;
        vu  : out real;
        vv  : out real
    );
end entity dds_model;

library ieee;
use ieee.math_real.sin;
use ieee.math_real.cos;
use ieee.math_real.math_pi;

----------------------------------------
architecture behave of dds_model is

    constant time_scale : time := 1 ns;
    --
    constant frequency  : real := 2.0 * math_pi * real( 10_000_000) / real( 1 sec / time_scale); -- 10 MHz
    constant amplitude  : real := 0.5; -- zero to peak
    constant offset     : real := 2.5;

begin

    -------------------- 
    gen: process
    --------------------
        variable t : real;
    begin
        t  := real( now / time_scale);
        vu <= sin( frequency * t) * amplitude + offset;
        vv <= cos( frequency * t) * amplitude + offset;
        wait for time_scale;
        if not run then
            wait; --forever
        end if;
    end process;

end architecture behave;
