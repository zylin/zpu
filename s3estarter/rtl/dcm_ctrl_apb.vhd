library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library gaisler;
use gaisler.misc.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

entity dcm_ctrl_apb is
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#
  );
  port (
    rst_n    : in  std_ulogic;
    clk      : in  std_ulogic;
    apbi     : in  apb_slv_in_type;
    apbo     : out apb_slv_out_type;

    psdone   : in  std_ulogic;
    psen     : out std_ulogic;
    psincdec : out std_ulogic
  );
end;

architecture rtl of dcm_ctrl_apb is

constant VENDOR   : integer := 16#ff#;
constant DEVICE   : integer := 16#01#;
constant CONFIG   : integer := 0;
constant REVISION : integer := 0;
constant INTR     : integer := 0;


constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR, DEVICE, CONFIG, REVISION, INTR),
  1 => apb_iobar(paddr, pmask));

type registers is record
    psvalue   : signed(8 downto 0);
    psen      : std_ulogic;
    psincdec  : std_ulogic;
    psready   : std_ulogic;
end record;

signal r, rin : registers;

begin

  comb : process(r, apbi, psdone)
    variable v        : registers;
    variable readdata : std_logic_vector(31 downto 0);
  begin


    v := r; 

    -- read registers

    readdata := (others => '0');
    case apbi.paddr(4 downto 2) is
        when "000"  => readdata(0) := v.psready;
        when "001"  => readdata(31 downto 0) := std_logic_vector( resize( v.psvalue, 32));
        when "010"  => readdata(31 downto 0) := std_logic_vector( resize( v.psvalue, 32));
        when others =>
    end case;

    -- write registers

    v.psen   := '0';
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(4 downto 2) is
          when "000" => v.psready := '0';
          when "001" => v.psready := '0'; v.psen := '1'; v.psincdec := '0'; v.psvalue := v.psvalue - 1;
          when "010" => v.psready := '0'; v.psen := '1'; v.psincdec := '1'; v.psvalue := v.psvalue + 1;
          when others =>
      end case;
    end if;

    if psdone = '1' then
        v.psready := '1';
    end if;

    rin <= v;

    apbo.prdata <= readdata; 	-- drive apb read bus
    apbo.pirq   <= (others => '0');

    psen        <= v.psen;
    psincdec    <= v.psincdec;

  end process;

  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;


  -- registers

  regs : process
  begin
    wait until rising_edge(clk);
    r <= rin;
    if rst_n = '0' then
      r.psvalue  <= (others => '0');
      r.psincdec <= '0';
      r.psen     <= '0';
      r.psready  <= '1';
    end if;
  end process;

-- boot message

-- pragma translate_off
    bootmsg : report_version
    generic map ("dcm_ctrl_apb" & tost(pindex) &
	": " & "DCM control rev " & tost(REVISION));
-- pragma translate_on

end;
