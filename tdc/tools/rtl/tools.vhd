

package tools_pkg is

       function log2 (x : positive) return natural;

end package tools_pkg;



package body tools_pkg is

       function log2 (x : positive) return natural is 
       begin
         if x <= 1 then
           return 0;
         else
           return log2 (x / 2) + 1;
         end if;
       end function log2;

--    function log2 (x : positive) return natural is
--       variable temp, log: natural;
--     begin
--       temp := x / 2;
--       log := 0;
--       while (temp /= 0) loop
--         temp := temp/2;
--         log := log + 1;
--       end loop;
--       return log;
--     end function log2;

end package body tools_pkg;
