--
-- putchar redirection to simulator console (rev 0)
-- reset register                           (rev 1)
-- HW synthesis date support                (rev 2)
--
--------------------------------------------------------------------------------
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------


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

library work;
use work.version.all;



entity debug_con_apb is
    generic (
        pindex : integer := 0;
        paddr  : integer := 0;
        pmask  : integer := 16#fff#
    );
    port (
        rst       : in  std_ulogic;
        clk       : in  std_ulogic;
        apbi      : in  apb_slv_in_type;
        apbo      : out apb_slv_out_type;
        softreset : out std_ulogic
    );
end entity debug_con_apb;



architecture rtl of debug_con_apb is

    constant REVISION : integer := 2;

    constant pconfig  : apb_config_type := (
        0 => ahb_device_reg (VENDOR_HZDR, HZDR_DEBUG_CON, 0, REVISION, 0),
        1 => apb_iobar(paddr, pmask));


    -- convert ascii from given string to slv
    function to_slv( s : string; pos : natural) return std_logic_vector is
        variable result : std_logic_vector(7 downto 0);
    begin
        result := (others => '0');
        if pos < s'length then
            result := std_logic_vector( to_unsigned( character'pos( s( pos + 1)), 8));
        end if;
        return result;
    end function to_slv;
    
    -- combine 4 bytes to one 32 bit word
    function slv8_to_slv32( addr : natural) return std_logic_vector is
        variable result  : std_logic_vector(31 downto 0);
    begin
        result :=  to_slv( version_time_c, 4 * addr + 0) & 
                   to_slv( version_time_c, 4 * addr + 1) & 
                   to_slv( version_time_c, 4 * addr + 2) & 
                   to_slv( version_time_c, 4 * addr + 3);
        return result;
    end function slv8_to_slv32;


    -- 8 values = 32 chars
    type version_memory_t is array(0 to 7) of std_logic_vector(31 downto 0);
    constant version_memory_c : version_memory_t := (
        0 => slv8_to_slv32( 0),
        1 => slv8_to_slv32( 1),
        2 => slv8_to_slv32( 2),
        3 => slv8_to_slv32( 3),
        4 => slv8_to_slv32( 4),
        5 => slv8_to_slv32( 5),
        6 => slv8_to_slv32( 6),
        7 => slv8_to_slv32( 7));

    type reg_t is record
        softreset : std_ulogic;
    end record;
    constant default_reg_c : reg_t := (
        softreset => '0'
    );

    signal r, rin : reg_t;

begin

    comb : process(apbi, r)
        variable v     : reg_t;
        -- pragma translate_off
        variable l1    : line;
        -- pragma translate_on
        variable first : boolean := true;
        variable ch    : character;
    begin

        apbo.prdata <= (others => '0');     -- drive apb read bus
        apbo.pirq   <= (others => '0');

        v := r;
 
        v.softreset := '0';
 
        -- read registers
        apbo.prdata <= version_memory_c( to_integer( to_01( unsigned( apbi.paddr(4 downto 2)))));

        -- write registers
        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
          case apbi.paddr(4 downto 2) is
 
            -- console register (00)
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
 
            -- reset register (04)
            when "001" =>
                if apbi.pwdata = x"87654321" then
                    v.softreset := '1';
                end if;
 
            when others =>
          end case;
        end if;
 
        rin <= v;
 
        -- outputs
        softreset   <= r.softreset;
 
    end process comb;

    apbo.pindex  <= pindex;
    apbo.pconfig <= pconfig;


    seq : process
    begin
        wait until rising_edge(clk);
        r     <= rin;
        if rst = '0' then
            r <= default_reg_c;
        end if;
    end process seq;


-- boot message

-- pragma translate_off
    bootmsg : report_version
      generic map ("debug console" & tost(pindex) &
                   ": rev " & tost(REVISION));
-- pragma translate_on

end architecture rtl;
