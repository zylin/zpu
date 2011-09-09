--
-- only for putchar redirection to simulator console
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

--library gaisler;
--use gaisler.misc.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

entity debug_con_apb is
  generic (
    pindex : integer := 0;
    paddr  : integer := 0;
    pmask  : integer := 16#fff#
    );
  port (
    rst  : in  std_ulogic;
    clk  : in  std_ulogic;
    apbi : in  apb_slv_in_type;
    apbo : out apb_slv_out_type
    );
end entity debug_con_apb;



architecture rtl of debug_con_apb is

  constant REVISION : integer := 0;

  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (VENDOR_HZDR, HZDR_DEBUG_CON, 0, REVISION, 0),
    1 => apb_iobar(paddr, pmask));

--type registers is record
--end record;

--signal r, rin : registers;

begin

  comb : process(apbi)
    --variable v     : registers;
    --pragma translate_off
    variable l1    : line;
    --pragma translate_on
    variable first : boolean := true;
    variable ch    : character;
  begin


--  v := r;

    -- write registers

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(4 downto 2) is

        when "000" =>
          --pragma translate_off
          if first then
            l1    := new string'("");
            first := false;
          end if;
          if apbi.penable'event then
            ch := character'val( to_integer( unsigned( apbi.pwdata(7 downto 0))));
            if ch = lf then
              std.textio.writeline(output, l1);
            elsif ch /= lf then
              std.textio.write(l1, ch);
            end if;
          end if;  -- event
          --pragma translate_on

        when others =>
      end case;
    end if;

--  rin <= v;

    apbo.prdata <= (others => '0');     -- drive apb read bus
    apbo.pirq   <= (others => '0');

  end process;

  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;


--seq : process
--begin
--  wait until rising_edge(clk);
--  r <= rin;
--end process;


-- boot message

-- pragma translate_off
  bootmsg : report_version
    generic map ("debug console" & tost(pindex) &
                 ": rev " & tost(REVISION));
-- pragma translate_on

end;
