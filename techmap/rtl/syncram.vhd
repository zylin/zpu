------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2010, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	syncram
-- File:	syncram.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous 1-port ram with tech selection
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allmem.all;

entity syncram is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	testen : integer := 0);
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic;
    testin   : in std_logic_vector(3 downto 0) := "0000");
end;

architecture rtl of syncram is
  constant nctrl : integer := abits + 4;
  signal rena, wena : std_logic;
  signal dataoutx, databp, testdata : std_logic_vector((dbits -1) downto 0);
  constant SCANTESTBP : boolean := (testen = 1) and (tech /= 0);
begin


  -- RAM bypass for scan
  scanbp : if SCANTESTBP generate
    comb : process (address, datain, enable, write, testin)
    variable tmp : std_logic_vector((dbits -1) downto 0);
    variable ctrlsigs : std_logic_vector((nctrl -1) downto 0);
    begin
      ctrlsigs := testin(1 downto 0) & write & enable & address;
      tmp := datain;
      for i in 0 to nctrl-1 loop
	tmp(i mod dbits) := tmp(i mod dbits) xor ctrlsigs(i);
      end loop;
      testdata <= tmp;
    end process;

    reg : process (clk)
    begin
      if rising_edge(clk) then
	databp <= testdata;
      end if;
    end process;
    dmuxout : for i in 0 to dbits-1 generate
      x0: grmux2 generic map (tech)
      port map (dataoutx(i), databp(i), testin(3), dataout(i));
    end generate;
  end generate;

  noscanbp : if not SCANTESTBP generate dataout <= dataoutx; end generate;

  inf : if tech = inferred generate
    x0 : generic_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, write);
  end generate;

  xcv : if (tech = virtex) generate
    x0 : virtex_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  xc2v : if (is_unisim(tech) = 1) and (tech /= virtex) generate
    x0 : unisim_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  vir  : if tech = memvirage generate
    x0 : virage_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  atrh : if tech = atc18rha generate
    x0 : atc18rha_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write, testin);
  end generate;

  axc  : if (tech = axcel) or (tech = axdsp) generate
    x0 : axcel_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  proa : if tech = proasic generate
    x0 : proasic_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  umc18  : if tech = umc generate
    x0 : umc_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  rhu  : if tech = rhumc generate
    x0 : rhumc_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  proa3 : if tech = apa3 generate
    x0 : proasic3_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  fus : if tech = actfus generate
    x0 : fusion_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  ihp : if tech = ihp25 generate
    x0 : ihp25_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, enable, write);
  end generate;

  ihprh : if tech = ihp25rh generate
    x0 : ihp25rh_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, enable, write);
  end generate;

  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = cyclone3) generate
    x0 : altera_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, enable, write);
  end generate;

  rht : if tech = rhlib18t generate
    x0 : rh_lib18t_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, enable, write, testin(1 downto 0));
  end generate;

  lat : if tech = lattice generate
    x0 : ec_syncram generic map(abits, dbits)
         port map(clk, address, datain, dataoutx, enable, write);
  end generate;

  ut025 : if tech = ut25 generate
    x0 : ut025crh_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  pere : if tech = peregrine generate
    x0 : peregrine_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  arti : if tech = memartisan generate
    x0 : artisan_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  cust1 : if tech = custom1 generate
    x0 : custom1_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  ecl : if tech = eclipse generate
    rena <= enable and not write;
    wena <= enable and write;
    x0 : eclipse_syncram_2p generic map(abits, dbits)
         port map(clk, rena, address, dataoutx, clk, address,
	          datain, wena);
  end generate;

  virage90 : if tech = memvirage90 generate
    x0 : virage90_syncram generic map(abits, dbits)
      port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  nex : if tech = easic90 generate
    x0 : nextreme_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

  smic : if tech = smic013 generate
    x0 : smic13_syncram generic map (abits, dbits)
         port map (clk, address, datain, dataoutx, enable, write);
  end generate;

-- pragma translate_off
  noram : if has_sram(tech) = 0 generate
    x : process
    begin
      assert false report "synram: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on
end;

