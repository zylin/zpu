library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library tools;
use tools.tools_pkg.log2;

library tdc;
use tdc.components.thermometer_coder;

library unisim;
use unisim.vcomponents.muxcy;
use unisim.vcomponents.xorcy;



entity channel is
    generic (
        taps_g  : natural;
        index_g : natural
    );
    port (
        clk    : in  std_ulogic;
        input  : in  std_ulogic;
        count  : out unsigned( log2( taps_g) downto 0)
    );
end entity channel;


architecture rtl of channel is
    
    signal taps            : unsigned( taps_g-1 downto 0);
    signal taps_int        : unsigned( taps_g-1 downto 0);
    signal tapsr1          : unsigned( taps_g-1 downto 0) := (others => '0');
    signal tapsr2          : unsigned( taps_g-1 downto 0) := (others => '0');

    attribute loc   : string;
    attribute rloc  : string;

begin


    ----------------------------------------
    --  variant with shift register (only simulated)
--  process
--  begin
--      if enable /= '0' then
--          taps <= taps( taps_g-2 downto 0) & input after 60 ps;
--          wait for 1 ps;
--      else
--          wait;
--      end if;
--  end process;

    ----------------------------------------
    --  variant with added (optimized away)    
--  ones    <= (others => '1');
--  tadd    <= (0 => input, others => '0');

--  taps    <= ones + tadd;-- after 60 ps;


    -----------------------------------------
    -- variant with direct instantiatet carry muxes
    taps_int(0) <= input;

    carrys_i : for i in 0 to taps_g-2 generate

           constant  x               : natural := 12 + 10*index_g; -- >>>>
           constant  y               : natural := i/2;             -- ^^^^  2
           constant  loc_str         : string  := "SLICE_X" & integer'image(x) & "Y" & integer'image(y);
           attribute LOC of muxcy_i  : label is loc_str;
           attribute LOC of xorcy_i  : label is loc_str;

           begin
    
           muxcy_i:  muxcy
               port map (
                   CI => taps_int(i),  -- Carry input signal
                   O  => taps_int(i+1),  -- Carry output signal
                   DI => '-',          -- Data input signal
                   S  => '1'           -- MUX select, tie to ?1? or LUT4 out
               );
           xorcy_i :  xorcy
               port map (
                   O  => taps(i),      -- XOR output signal
                   ci => taps_int(i),  --  Carry input signal
                   li => '1'           --   LUT4 input signal
               );

    end generate carrys_i;


    -- register chain to synchronize
    tapsr1  <= taps   when rising_edge( clk);
    tapsr2  <= tapsr1 when rising_edge( clk);

    -------------------- 
    thermometer_coder_i0 : thermometer_coder
    generic map (
        thermo_in_no_g => taps_g
    )
    port map (
        clk            => clk,
        thermo_in      => std_ulogic_vector( tapsr2),
        code_out       => count
    );

end architecture rtl;
