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

----------------------------------------
architecture behave of dds_model is

    constant time_scale : time := 1 ns;

begin

    -------------------- 
    gen: process
    --------------------
        variable t : real;
    begin
        t  := real( now / time_scale);
        vu <= sin(t);
        vv <= cos(t);
        wait for time_scale;
        if not run then
            wait; --forever
        end if;
    end process;

end architecture behave;
