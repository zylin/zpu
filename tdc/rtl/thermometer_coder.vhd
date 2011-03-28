------------------------------------------------------------
-- here some synthesis results:
-- variant                         no of slices              logic_levels         frequency
-- prioity decoder  256 taps       135                        86                   13
-- adder_method     256 taps       135                                              8
-- adder_pipeline_2 256 taps
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tools;
use tools.tools_pkg.log2;

entity thermometer_coder is
    generic (
        thermo_in_no_g : natural                                            -- number of thermometer taps
    );
    port (
        clk            : in  std_ulogic;                                    -- system clock
        thermo_in      : in  std_ulogic_vector( thermo_in_no_g-1 downto 0); -- input taps
        code_out       : out unsigned( log2( thermo_in_no_g) downto 0)      -- coded output
    );
end entity thermometer_coder;


architecture rtl of thermometer_coder is
    signal temp0 : unsigned( code_out'range);
    signal temp1 : unsigned( code_out'range);
    signal temp2 : unsigned( code_out'range);
    signal temp3 : unsigned( code_out'range);
    signal temp4 : unsigned( code_out'range);
    signal temp5 : unsigned( code_out'range);
    signal temp6 : unsigned( code_out'range);
    signal temp7 : unsigned( code_out'range);
    signal temp8 : unsigned( code_out'range);
    signal temp9 : unsigned( code_out'range);
    signal tempa : unsigned( code_out'range);
    signal tempb : unsigned( code_out'range);
    signal tempc : unsigned( code_out'range);
    signal tempd : unsigned( code_out'range);
    signal tempe : unsigned( code_out'range);
    signal tempf : unsigned( code_out'range);

    function c (value: std_ulogic) return unsigned is
        variable result : unsigned(0 downto 0);
    begin
        result(0) := value;
        return result;
    end function c;

    signal thermo_code_127_i : std_ulogic_vector( 126 downto 0);
    signal thermo_code_63_i  : std_ulogic_vector(  62 downto 0);
    signal thermo_code_31_i  : std_ulogic_vector(  30 downto 0);
    signal thermo_code_15_i  : std_ulogic_vector(  14 downto 0);
    signal thermo_code_7_i   : std_ulogic_vector(   6 downto 0);
    signal thermo_code_3_i   : std_ulogic_vector(   2 downto 0);
    signal thermo_code_1_i   : std_ulogic_vector(   0 downto 0);



begin

--  adder_pipeline_2: process
--  begin
--      wait until rising_edge( clk);
--      -- stage 2
--      code_out <= temp0 + temp1 + temp2 + temp3 + temp4 + temp5 + temp6 + temp7 + temp8 + temp9 + tempa + tempb + tempc + tempd + tempe + tempf;

--      -- stage 1
--      temp0    <= resize( c( thermo_in(   0)), temp0'length) + c( thermo_in(   1)) + c( thermo_in(   2)) + c( thermo_in(   3)) + c( thermo_in(   4)) + c( thermo_in(   5)) + c( thermo_in(   6)) + c( thermo_in(   7)) + c( thermo_in(   8)) + c( thermo_in(   9)) + c( thermo_in(  10)) + c( thermo_in(  11)) + c( thermo_in(  12)) + c( thermo_in(  13)) + c( thermo_in(  14)) + c( thermo_in(  15));

--      temp1    <= resize( c( thermo_in(  16)), temp0'length) + c( thermo_in(  17)) + c( thermo_in(  18)) + c( thermo_in(  19)) + c( thermo_in(  20)) + c( thermo_in(  21)) + c( thermo_in(  22)) + c( thermo_in(  23)) + c( thermo_in(  24)) + c( thermo_in(  25)) + c( thermo_in(  26)) + c( thermo_in(  27)) + c( thermo_in(  28)) + c( thermo_in(  29)) + c( thermo_in(  30)) + c( thermo_in(  31));

--      temp2    <= resize( c( thermo_in(  32)), temp0'length) + c( thermo_in(  33)) + c( thermo_in(  34)) + c( thermo_in(  35)) + c( thermo_in(  36)) + c( thermo_in(  37)) + c( thermo_in(  38)) + c( thermo_in(  39)) + c( thermo_in(  40)) + c( thermo_in(  41)) + c( thermo_in(  42)) + c( thermo_in(  43)) + c( thermo_in(  44)) + c( thermo_in(  45)) + c( thermo_in(  46)) + c( thermo_in(  47));

--      temp3    <= resize( c( thermo_in(  48)), temp0'length) + c( thermo_in(  49)) + c( thermo_in(  50)) + c( thermo_in(  51)) + c( thermo_in(  52)) + c( thermo_in(  53)) + c( thermo_in(  54)) + c( thermo_in(  55)) + c( thermo_in(  56)) + c( thermo_in(  57)) + c( thermo_in(  58)) + c( thermo_in(  59)) + c( thermo_in(  60)) + c( thermo_in(  61)) + c( thermo_in(  62)) + c( thermo_in(  63));

--      temp4    <= resize( c( thermo_in(  64)), temp0'length) + c( thermo_in(  65)) + c( thermo_in(  66)) + c( thermo_in(  67)) + c( thermo_in(  68)) + c( thermo_in(  69)) + c( thermo_in(  70)) + c( thermo_in(  71)) + c( thermo_in(  72)) + c( thermo_in(  73)) + c( thermo_in(  74)) + c( thermo_in(  75)) + c( thermo_in(  76)) + c( thermo_in(  77)) + c( thermo_in(  78)) + c( thermo_in(  79));

--      temp5    <= resize( c( thermo_in(  80)), temp0'length) + c( thermo_in(  81)) + c( thermo_in(  82)) + c( thermo_in(  83)) + c( thermo_in(  84)) + c( thermo_in(  85)) + c( thermo_in(  86)) + c( thermo_in(  87)) + c( thermo_in(  88)) + c( thermo_in(  89)) + c( thermo_in(  90)) + c( thermo_in(  91)) + c( thermo_in(  92)) + c( thermo_in(  93)) + c( thermo_in(  94)) + c( thermo_in(  95));

--      temp6    <= resize( c( thermo_in(  96)), temp0'length) + c( thermo_in(  97)) + c( thermo_in(  98)) + c( thermo_in(  99)) + c( thermo_in( 100)) + c( thermo_in( 101)) + c( thermo_in( 102)) + c( thermo_in( 103)) + c( thermo_in( 104)) + c( thermo_in( 105)) + c( thermo_in( 106)) + c( thermo_in( 107)) + c( thermo_in( 108)) + c( thermo_in( 109)) + c( thermo_in( 110)) + c( thermo_in( 111));

--      temp7    <= resize( c( thermo_in( 112)), temp0'length) + c( thermo_in( 113)) + c( thermo_in( 114)) + c( thermo_in( 115)) + c( thermo_in( 116)) + c( thermo_in( 117)) + c( thermo_in( 118)) + c( thermo_in( 119)) + c( thermo_in( 120)) + c( thermo_in( 121)) + c( thermo_in( 122)) + c( thermo_in( 123)) + c( thermo_in( 124)) + c( thermo_in( 125)) + c( thermo_in( 126)) + c( thermo_in( 127));

--      temp8    <= resize( c( thermo_in( 128)), temp0'length) + c( thermo_in( 129)) + c( thermo_in( 130)) + c( thermo_in( 131)) + c( thermo_in( 132)) + c( thermo_in( 133)) + c( thermo_in( 134)) + c( thermo_in( 135)) + c( thermo_in( 136)) + c( thermo_in( 137)) + c( thermo_in( 138)) + c( thermo_in( 139)) + c( thermo_in( 140)) + c( thermo_in( 141)) + c( thermo_in( 142)) + c( thermo_in( 143));

--      temp9    <= resize( c( thermo_in( 144)), temp0'length) + c( thermo_in( 145)) + c( thermo_in( 146)) + c( thermo_in( 147)) + c( thermo_in( 148)) + c( thermo_in( 149)) + c( thermo_in( 150)) + c( thermo_in( 151)) + c( thermo_in( 152)) + c( thermo_in( 153)) + c( thermo_in( 154)) + c( thermo_in( 155)) + c( thermo_in( 156)) + c( thermo_in( 157)) + c( thermo_in( 158)) + c( thermo_in( 159));

--      tempa    <= resize( c( thermo_in( 160)), temp0'length) + c( thermo_in( 161)) + c( thermo_in( 162)) + c( thermo_in( 163)) + c( thermo_in( 164)) + c( thermo_in( 165)) + c( thermo_in( 166)) + c( thermo_in( 167)) + c( thermo_in( 168)) + c( thermo_in( 169)) + c( thermo_in( 170)) + c( thermo_in( 171)) + c( thermo_in( 172)) + c( thermo_in( 173)) + c( thermo_in( 174)) + c( thermo_in( 175));

--      tempb    <= resize( c( thermo_in( 176)), temp0'length) + c( thermo_in( 177)) + c( thermo_in( 178)) + c( thermo_in( 179)) + c( thermo_in( 180)) + c( thermo_in( 181)) + c( thermo_in( 182)) + c( thermo_in( 183)) + c( thermo_in( 184)) + c( thermo_in( 185)) + c( thermo_in( 186)) + c( thermo_in( 187)) + c( thermo_in( 188)) + c( thermo_in( 189)) + c( thermo_in( 190)) + c( thermo_in( 191));
--      
--      tempc    <= resize( c( thermo_in( 192)), temp0'length) + c( thermo_in( 193)) + c( thermo_in( 194)) + c( thermo_in( 195)) + c( thermo_in( 196)) + c( thermo_in( 197)) + c( thermo_in( 198)) + c( thermo_in( 199)) + c( thermo_in( 200)) + c( thermo_in( 201)) + c( thermo_in( 202)) + c( thermo_in( 203)) + c( thermo_in( 204)) + c( thermo_in( 205)) + c( thermo_in( 206)) + c( thermo_in( 207));
--      
--      tempd    <= resize( c( thermo_in( 208)), temp0'length) + c( thermo_in( 209)) + c( thermo_in( 210)) + c( thermo_in( 211)) + c( thermo_in( 212)) + c( thermo_in( 213)) + c( thermo_in( 214)) + c( thermo_in( 215)) + c( thermo_in( 216)) + c( thermo_in( 217)) + c( thermo_in( 218)) + c( thermo_in( 219)) + c( thermo_in( 220)) + c( thermo_in( 221)) + c( thermo_in( 222)) + c( thermo_in( 223));
--      
--      tempe    <= resize( c( thermo_in( 224)), temp0'length) + c( thermo_in( 225)) + c( thermo_in( 226)) + c( thermo_in( 227)) + c( thermo_in( 228)) + c( thermo_in( 229)) + c( thermo_in( 230)) + c( thermo_in( 231)) + c( thermo_in( 232)) + c( thermo_in( 233)) + c( thermo_in( 234)) + c( thermo_in( 235)) + c( thermo_in( 236)) + c( thermo_in( 237)) + c( thermo_in( 238)) + c( thermo_in( 239));

--      tempf    <= resize( c( thermo_in( 240)), temp0'length) + c( thermo_in( 241)) + c( thermo_in( 242)) + c( thermo_in( 243)) + c( thermo_in( 244)) + c( thermo_in( 245)) + c( thermo_in( 246)) + c( thermo_in( 247)) + c( thermo_in( 248)) + c( thermo_in( 249)) + c( thermo_in( 250)) + c( thermo_in( 251)) + c( thermo_in( 252)) + c( thermo_in( 253)) + c( thermo_in( 254)) + c( thermo_in( 255));
--      
--  end process adder_pipeline_2;

--  adder_method: process( thermo_in)
--      variable code  : unsigned(code_out'range);
--      variable value : unsigned(0 downto 0);
--  begin
--      code := to_unsigned( 0, code_out'length);
--      for i in 0 to thermo_in_no_g-1 loop
--          value(0) := thermo_in( i);
--          code     := code + value;
--      end loop;
--      code_out <= code;
--  end process adder_method;

--  priority_decoder: process( thermo_in)
--  begin

--      code_out <= to_unsigned( 0, code_out'length);

--      for i in 0 to thermo_in_no_g-1 loop
--          if thermo_in( i) = '1' then
--              code_out <= to_unsigned( i+1, code_out'length);
--          end if; 
--      end loop;

--  end process;
    


   MUX : process (CLK)
   begin
     if rising_edge(CLK) then
--     if RESET = '1' then
--       thermo_code_127_i   <= (others => '1');
--       thermo_code_63_i    <= (others => '1');
--       thermo_code_31_i    <= (others => '1');
--       thermo_code_15_i    <= (others => '1');
--       thermo_code_7_i     <= (others => '1');
--       thermo_code_3_i     <= (others => '1');
--       thermo_code_1_i     <= '1';
--       sum_i               <= (others => '0');
--     else
         if thermo_in(127) = '0' then
           thermo_code_127_i <= thermo_in(254 downto 128);
         else
           thermo_code_127_i <= thermo_in(126 downto 0);
         end if;
         if thermo_code_127_i(63) = '0' then
           thermo_code_63_i  <= thermo_code_127_i(126 downto 64);
         else
           thermo_code_63_i  <= thermo_code_127_i(62 downto 0);
         end if;
         if thermo_code_63_i(31) = '0' then
           thermo_code_31_i  <= thermo_code_63_i(62 downto 32);
         else
           thermo_code_31_i  <= thermo_code_63_i(30 downto 0);
         end if;
         if thermo_code_31_i(15) = '0' then
           thermo_code_15_i  <= thermo_code_31_i(30 downto 16);
         else
           thermo_code_15_i  <= thermo_code_31_i(14 downto 0);
         end if;
         if thermo_code_15_i(7) = '0' then
           thermo_code_7_i   <= thermo_code_15_i(14 downto 8);
         else
           thermo_code_7_i   <= thermo_code_15_i(6 downto 0);
         end if;
         if thermo_code_7_i(3) = '0' then
           thermo_code_3_i   <= thermo_code_7_i(6 downto 4);
         else
           thermo_code_3_i   <= thermo_code_7_i(2 downto 0);
         end if;
         if thermo_code_3_i(1) = '0' then
           thermo_code_1_i(0)<= thermo_code_3_i(2);
         else
           thermo_code_1_i(0)<= thermo_code_3_i(0);
         end if;
--       code_out(9)            <= '0';
         code_out(8)            <= '0';
         code_out(7)            <= not(thermo_in(127));
         code_out(6)            <= not(thermo_code_127_i(63));
         code_out(5)            <= not(thermo_code_63_i(31));
         code_out(4)            <= not(thermo_code_31_i(15));
         code_out(3)            <= not(thermo_code_15_i(7));
         code_out(2)            <= not(thermo_code_7_i(3));
         code_out(1)            <= not(thermo_code_3_i(1));
         code_out(0)            <= not(thermo_code_1_i(0));
       end if;
--   end if;
   end process MUX; 







end architecture rtl;
