------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003 - 2008, Gaisler Research
--  Copyright (C) 2008 - 2012, Aeroflex Gaisler
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
library grlib;
use grlib.config.all;
use grlib.stdlib.all;

entity syncram_2p is
  generic (tech : integer := 0; abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0; testen : integer := 0;
	words : integer := 0);
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

signal gnd : std_ulogic;
signal vgnd : std_logic_vector(dbits-1 downto 0);
signal dataoutx  : std_logic_vector((dbits -1) downto 0);
signal databp, testdata : std_logic_vector((dbits -1) downto 0);
signal renable2 : std_ulogic;
constant SCANTESTBP : boolean := (testen = 1) and (tech /= 0);
constant iwrfst : integer := (1-syncram_2p_write_through(tech)) * wrfst;

begin

  gnd <= '0'; vgnd <= (others => '0');

  no_wrfst : if iwrfst = 0 generate
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
      reg : process(wclk) begin
        if rising_edge(wclk) then databp <= testdata; end if;
      end process;
      dmuxout : for i in 0 to dbits-1 generate
        x0 : grmux2 generic map (tech)
        port map (dataoutx(i), databp(i), testin(3), dataout(i));
      end generate;
    end generate;
    noscanbp : if not SCANTESTBP generate dataout <= dataoutx; end generate;
    -- Write contention check (if applicable)
    renable2 <= '0' when ((sepclk = 0 and syncram_2p_dest_rw_collision(tech) = 1) and
                          (renable and write) = '1' and raddress = waddress) else renable;
  end generate;

  wrfst_gen : if iwrfst = 1 generate
    -- No risk for read/write contention. Register addresses and mux on comparator
    no_contention_check : if syncram_2p_dest_rw_collision(tech) = 0 generate
      wfrstblocknoc : block
        type wrfst_type is record
          raddr   : std_logic_vector((abits-1) downto 0);
          waddr   : std_logic_vector((abits-1) downto 0);
          datain  : std_logic_vector((dbits-1) downto 0);
          write   : std_logic;
          renable : std_logic;
        end record;
        signal r : wrfst_type;
      begin
        comb : process(r, dataoutx, testin) begin
          if (SCANTESTBP and (testin(3) = '1')) or
            (((r.write and r.renable) = '1') and (r.raddr = r.waddr)) then
            dataout <= r.datain;
          else dataout <= dataoutx; end if;
        end process;
        reg : process(wclk) begin
          if rising_edge(wclk) then
            r.raddr <= raddress; r.waddr <= waddress;
            r.datain <= datain; r.write <= write;
            r.renable <= renable;
          end if;
        end process;
      end block wfrstblocknoc;
      renable2 <= renable;
    end generate;
    -- Risk of read/write contention. Use same comparator to gate read enable
    -- and mux data.
    contention_safe : if syncram_2p_dest_rw_collision(tech) /= 0 generate
      wfrstblockc : block
        signal col, mux : std_ulogic;
        signal rdatain : std_logic_vector((dbits-1) downto 0);
      begin
        comb : process(mux, renable, write, raddress, waddress, rdatain,
                       dataoutx, testin)
        begin
          col <= '0'; renable2 <= renable;
          if (write and renable) = '1' and raddress = waddress then
            col <= '1'; renable2 <= '0';
          end if;
          if (SCANTESTBP and (testin(3) = '1')) or mux = '1' then
            dataout <= rdatain;
          else dataout <= dataoutx; end if;
        end process;
        reg : process(wclk) begin
          if rising_edge(wclk) then
            rdatain <= datain; mux <= col;
          end if;
        end process;
      end block wfrstblockc;
    end generate;
  end generate wrfst_gen;
  
  inf : if tech = inferred generate
    x0 : generic_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, wclk, raddress, waddress, datain, write, dataoutx);
  end generate;

  xcv : if tech = virtex generate 
    x0 : virtex_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write, 
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
  end generate;

  xc2v : if (is_unisim(tech) = 1) and (tech /= virtex)generate
    x0 : unisim_syncram_2p generic map (abits, dbits, sepclk, iwrfst)
         port map (rclk, renable2, raddress, dataoutx, wclk,
		   write, waddress, datain);
  end generate;

  vir  : if tech = memvirage generate
   d39 : if dbits = 39 generate
    x0 : virage_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain);
   end generate;
   d32 : if dbits <= 32 generate
    x0 : virage_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write,
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
   end generate;
  end generate;

  atrh : if tech = atc18rha generate
    x0 : atc18rha_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain, testin);
  end generate;

  axc  : if (tech = axcel) or (tech = axdsp) generate
    x0 : axcel_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  proa : if tech = proasic generate
    x0 : proasic_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  proa3 : if tech = apa3 generate
    x0 : proasic3_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  proa3e : if tech = apa3e generate
    x0 : proasic3e_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  proa3l : if tech = apa3l generate
    x0 : proasic3l_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  fus : if tech = actfus generate
    x0 : fusion_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
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
         port map (rclk, raddress, vgnd, dataoutx, renable2, gnd,
                   wclk, waddress, datain, open, write, write);
  end generate;

  rh_lib18t0 : if tech = rhlib18t generate
    x0 : rh_lib18t_syncram_2p generic map (abits, dbits, sepclk)
         port map (rclk, renable2, raddress, dataoutx, wclk, write, waddress, datain, testin);
  end generate;

  lat : if tech = lattice generate
    x0 : ec_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write,
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
  end generate;

  ut025 : if tech = ut25 generate
    x0 : ut025crh_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  ut09 : if tech = ut90 generate
    x0 : ut90nhbd_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  ut13 : if tech = ut130 generate
    x0 : ut130hbd_syncram_2p generic map (abits, dbits, words)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  arti : if tech = memartisan generate
    x0 : artisan_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  cust1 : if tech = custom1 generate
    x0 : custom1_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  ecl : if tech = eclipse generate
    x0 : eclipse_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, waddress, datain, write);
  end generate;

  vir90  : if tech = memvirage90 generate
    x0 : virage90_syncram_dp generic map (abits, dbits)
         port map (wclk, waddress, datain, open, write, write,
                   rclk, raddress, vgnd, dataoutx, renable2, gnd);
  end generate;

  nex : if tech = easic90 generate
    x0 : nextreme_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  smic : if tech = smic013 generate
    x0 : smic13_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx,
		   wclk, write, waddress, datain);
  end generate;

  tm65gplu : if tech = tm65gpl generate 
    x0 : tm65gplus_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx, 
                   wclk, write, waddress, datain);
  end generate; 

  cmos9sfx : if tech = cmos9sf generate 
    x0 : cmos9sf_syncram_2p generic map (abits, dbits)
         port map (rclk, renable2, raddress, dataoutx, 
                   wclk, write, waddress, datain);
  end generate; 

  n2x : if tech = easic45 generate
    x0 : n2x_syncram_2p generic map (abits, dbits, sepclk, iwrfst)
      port map (rclk, renable2, raddress, dataoutx, wclk,
                write, waddress, datain);
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
  dmsg : if grlib_debug_level >= 2 generate
    x : process
    begin
      assert false report "syncram_2p: " & tost(2**abits) & "x" & tost(dbits) &
       " (" & tech_table(tech) & ")"
      severity note;
      wait;
    end process;
  end generate;
  generic_check : process
  begin
    assert sepclk = 0 or wrfst = 0
      report "syncram_2p: Write-first not supported for RAM with separate clocks"
      severity failure;
    wait;
  end process;
-- pragma translate_on

end;

