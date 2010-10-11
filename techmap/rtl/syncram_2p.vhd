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
-- Entity: 	syncram_2p
-- File:	syncram_2p.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	syncronous 2-port ram with tech selection
------------------------------------------------------------------------------

library ieee;
library techmap;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use work.allmem.all;

entity syncram_2p is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; testen : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    testin   : in std_logic_vector(3 downto 0) := "0000");
end;

architecture rtl of syncram_2p is

constant nctrl : integer := abits*2 + 4;
type wrfst_type is record
  raddr   : std_logic_vector(abits-1 downto 0);
  waddr   : std_logic_vector(abits-1 downto 0);
  datain  : std_logic_vector((dbits -1) downto 0);
  write   : std_logic;
  renable : std_logic;
end record;

type wrfst_type2 is record
  waddr   : std_logic_vector(abits-1 downto 0);
  datain  : std_logic_vector((dbits -1) downto 0);
  write   : std_logic;
end record;

signal vcc, gnd : std_ulogic;
signal vgnd : std_logic_vector(dbits-1 downto 0);
signal r : wrfst_type;
signal r2 : wrfst_type2;
signal dataoutx  : std_logic_vector((dbits -1) downto 0);
signal databp, testdata : std_logic_vector((dbits -1) downto 0);
constant SCANTESTBP : boolean := (testen = 1) and (tech /= 0);

begin

  vcc <= '1'; gnd <= '0'; vgnd <= (others => '0');

  no_wrfst : if wrfst = 0 generate
    scanbp : if SCANTESTBP generate
      comb : process (waddress, raddress, datain, renable, write, testin)
      variable tmp : std_logic_vector((dbits -1) downto 0);
      variable ctrlsigs : std_logic_vector((nctrl -1) downto 0);
      begin
        ctrlsigs := testin(1 downto 0) & write & renable & raddress & waddress;
        tmp := datain;
        for i in 0 to nctrl-1 loop
	  tmp(i mod dbits) := tmp(i mod dbits) xor ctrlsigs(i);
        end loop;
        testdata <= tmp;
      end process;
      reg : process(rclk) begin
        if rising_edge(rclk) then databp <= testdata; end if;
      end process;
      dmuxout : for i in 0 to dbits-1 generate
        x0 : grmux2 generic map (tech)
        port map (dataoutx(i), databp(i), testin(3), dataout(i));
      end generate;
    end generate;
    noscanbp : if not SCANTESTBP generate dataout <= dataoutx; end generate;
  end generate;

  wrfst_gen : if wrfst = 1 generate
    comb : process(r, r2, dataoutx, testin) begin
      if (SCANTESTBP and (testin(3) = '1')) or
	(((r.write and r.renable) = '1') and (r.raddr = r.waddr)) then
	dataout <= r.datain;
      elsif ((sepclk = 1) and ((r2.write and r.renable) = '1') and (r.raddr = r2.waddr)) then
	dataout <= r2.datain;
      else dataout <= dataoutx; end if;
    end process;
    reg : process(rclk) begin
      if rising_edge(rclk) then
	r.raddr <= raddress; r.waddr <= waddress;
	r.datain <= datain; r.write <= write;
	r.renable <= renable;
      end if;
    end process;
    reg2gen : if sepclk = 1 generate
      reg2 : process(wclk) begin
        if rising_edge(wclk) then
	  r2.waddr <= waddress;
	  r2.datain <= datain; r2.write <= write;
        end if;
      end process;
    end generate;
    noreg2gen : if sepclk = 0 generate
      r2.waddr <= (others => '0');
      r2.datain <= (others => '0'); r2.write <= '0';
    end generate;
  end generate;

  inf : if tech = inferred generate
    x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, write, dataoutx);
  end generate;

  xcv : if tech = virtex generate 
    x0 : virtex_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write, 
                   rclk, raddress, vgnd, dataoutx, renable, gnd);
  end generate;

  xc2v : if (is_unisim(tech) = 1) and (tech /= virtex)generate
    x0 : unisim_syncram_2p generic map (abits, dbits, sepclk, wrfst)
         port map (rclk, renable, raddress, dataoutx, wclk,
		   write, waddress, datain);
  end generate;

  vir  : if tech = memvirage generate
   d39 : if dbits = 39 generate
    x0 : virage_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, write, waddress, datain);
   end generate;
   d32 : if dbits <= 32 generate
    x0 : virage_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write,
                   rclk, raddress, vgnd, dataoutx, renable, gnd);
   end generate;
  end generate;

  atrh : if tech = atc18rha generate
    x0 : atc18rha_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, write, waddress, datain, testin);
  end generate;

  axc  : if (tech = axcel) or (tech = axdsp) generate
    x0 : axcel_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  proa : if tech = proasic generate
    x0 : proasic_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  proa3 : if tech = apa3 generate
    x0 : proasic3_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  fus : if tech = actfus generate
    x0 : fusion_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  ihp : if tech = ihp25 generate
    x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, write, dataoutx);
  end generate;

-- NOTE: port 1 on altsyncram must be a read port due to Cyclone II M4K write issue
  alt : if (tech = altera) or (tech = stratix1) or (tech = stratix2) or
	(tech = stratix3) or (tech = cyclone3) generate
    x0 : altera_syncram_dp generic map (abits, dbits)
         port map (rclk, raddress, vgnd, dataoutx, renable, gnd,
                   wclk, waddress, datain, open, write, write);
  end generate;

  rh_lib18t0 : if tech = rhlib18t generate
    x0 : rh_lib18t_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable, raddress, dataoutx, wclk, write, waddress, datain, testin);
  end generate;

  lat : if tech = lattice generate
    x0 : ec_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write,
                   rclk, raddress, vgnd, dataoutx, renable, gnd);
  end generate;

  ut025 : if tech = ut25 generate
    x0 : ut025crh_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  arti : if tech = memartisan generate
    x0 : artisan_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  cust1 : if tech = custom1 generate
    x0 : custom1_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  ecl : if tech = eclipse generate
    x0 : eclipse_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  vir90  : if tech = memvirage90 generate
    x0 : virage90_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write,
                   rclk, raddress, vgnd, dataoutx, renable, gnd);
  end generate;

  nex : if tech = easic90 generate
    x0 : nextreme_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  smic : if tech = smic013 generate
    x0 : smic13_syncram_2p generic map (abits, dbits)
         port map (rclk, renable, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

-- pragma translate_off
  noram : if has_2pram(tech) = 0 generate
    x : process
    begin
      assert false report "synram_2p: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;

