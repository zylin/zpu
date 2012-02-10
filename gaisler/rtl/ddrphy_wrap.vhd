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
-- Entity: 	ddr_phy
-- File:	ddr_phy.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Wrapper entities for techmap ddrphy/ddr2phy
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;

------------------------------------------------------------------
-- DDR1 PHY wrapper -------------------------------------------------------
------------------------------------------------------------------

entity ddrphy_wrap is
  generic (tech : integer := virtex2; MHz : integer := 100; 
	rstdelay : integer := 200; dbits : integer := 16; 
	clk_mul : integer := 2 ; clk_div : integer := 2;
	rskew : integer :=0; mobile : integer := 0);
  port (
    rst       : in  std_ulogic;
    clk       : in  std_logic;          	-- input clock
    clkout    : out std_ulogic;			-- system clock
    clkread   : out std_ulogic;			-- read clock
    lock      : out std_ulogic;			-- DCM locked

    ddr_clk 	: out std_logic_vector(2 downto 0);
    ddr_clkb	: out std_logic_vector(2 downto 0);
    ddr_clk_fb_out  : out std_logic;
    ddr_clk_fb  : in std_logic;
    ddr_cke  	: out std_logic_vector(1 downto 0);
    ddr_csb  	: out std_logic_vector(1 downto 0);
    ddr_web  	: out std_ulogic;                       -- ddr write enable
    ddr_rasb  	: out std_ulogic;                       -- ddr ras
    ddr_casb  	: out std_ulogic;                       -- ddr cas
    ddr_dm   	: out std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs  	: inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad      : out std_logic_vector (13 downto 0);   -- ddr address
    ddr_ba      : out std_logic_vector (1 downto 0);    -- ddr bank address
    ddr_dq    	: inout  std_logic_vector (dbits-1 downto 0); -- ddr data
 
    sdi         : out sdctrl_in_type;
    sdo         : in  sdctrl_out_type;
    --
    psdone      : out std_ulogic;
    psovfl      : out std_ulogic;
    psclk       : in  std_ulogic;
    psen        : in  std_ulogic;
    psincdec    : in  std_ulogic
  );
end;

architecture rtl of ddrphy_wrap is

begin

    ddr_phy0 : ddrphy 
     generic map (tech => tech, MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, dbits => dbits, clk_mul => clk_mul, clk_div => clk_div, 
	rskew => rskew, mobile => mobile)
     port map (
	rst, clk, clkout, clkread, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
	sdo.address(15 downto 2), sdo.ba(1 downto 0),
	sdi.data(dbits*2-1 downto 0), sdo.data(dbits*2-1 downto 0), 
	sdo.dqm(dbits/4-1 downto 0), sdo.bdrive, sdo.bdrive, sdo.qdrive, 
	sdo.rasn, sdo.casn, sdo.sdwen, sdo.sdcsn, sdo.sdcke, sdo.sdck, sdo.moben, psdone, psovfl, psclk, psen, psincdec);

    drvdata : if dbits < 64 generate
      sdi.data(127 downto dbits*2) <= (others => '0');
    end generate;
    sdi.cb <= (others => '0'); sdi.regrdata <= (others => '0');
    sdi.wprot <= '0';
end;

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;

------------------------------------------------------------------
-- DDR2 PHY wrapper -----------------------------------------------
------------------------------------------------------------------

-------------------------------------------------------------------------------
-- There are three variants of the PHY wrapper depending on pads/checkbits:
-- 1. ddr2phy_wrap:
--       This provides pads and outputs checkbits on separate vectors
-- 2. ddr2phy_wrap_cbd:
--       This provides pads and merges checkbits+data on same vector
-- 3. ddr2phy_wrap_cbd_wo_pads:
--       This does not provide pads and merges checkbits+data on same vectors
--
-- Variants (1),(3) can not be used when ddr2phy_builtin_pads(tech)=1
-------------------------------------------------------------------------------

entity ddr2phy_wrap is
  generic (tech     : integer := virtex2; MHz        : integer := 100; 
	rstdelay    : integer := 200;     dbits      : integer := 16;  padbits  : integer := 0;
	clk_mul     : integer := 2 ;      clk_div    : integer := 2;
	ddelayb0    : integer := 0;       ddelayb1   : integer := 0;   ddelayb2 : integer := 0;
	ddelayb3    : integer := 0;       ddelayb4   : integer := 0;   ddelayb5 : integer := 0;
	ddelayb6    : integer := 0;       ddelayb7   : integer := 0;
        cbdelayb0   : integer := 0;       cbdelayb1: integer := 0;     cbdelayb2: integer := 0;
        cbdelayb3   : integer := 0;
        numidelctrl : integer := 4;       norefclk   : integer := 0;   odten    : integer := 0;
        rskew       : integer := 0;       eightbanks : integer range 0 to 1 := 0;
        dqsse       : integer range 0 to 1 := 0;
        abits       : integer := 14;      nclk     : integer := 3;     ncs      : integer := 2;
        cben        : integer := 0;       chkbits  : integer := 8;     ctrl2en  : integer := 0;
        resync      : integer := 0;       custombits: integer := 8);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref200      : in    std_logic;   -- input 200MHz clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in    std_ulogic;  -- system clock return
    clkresync      : in    std_ulogic;  -- resync clock (if resync/=0)
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;                               -- ddr write enable
    ddr_rasb       : out   std_ulogic;                               -- ddr ras
    ddr_casb       : out   std_ulogic;                               -- ddr cas
    ddr_dm         : out   std_logic_vector ((dbits+padbits)/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector ((dbits+padbits)/8-1 downto 0);    -- ddr dqs
    ddr_dqsn       : inout std_logic_vector ((dbits+padbits)/8-1 downto 0);    -- ddr dqs
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector ((dbits+padbits)-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);
    ddr_cbdm       : out   std_logic_vector(chkbits/8-1 downto 0);
    ddr_cbdqs      : inout std_logic_vector(chkbits/8-1 downto 0);
    ddr_cbdqsn     : inout std_logic_vector(chkbits/8-1 downto 0);
    ddr_cbdq       : inout std_logic_vector(chkbits-1 downto 0);
    ddr_web2       : out   std_ulogic;                               -- ddr write enable
    ddr_rasb2      : out   std_ulogic;                               -- ddr ras
    ddr_casb2      : out   std_ulogic;                               -- ddr cas
    ddr_ad2        : out   std_logic_vector (abits-1 downto 0);      -- ddr address
    ddr_ba2        : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    
    sdi            : out   sdctrl_in_type;
    sdo            : in    sdctrl_out_type;

    customclk      : in    std_ulogic;
    customdin      : in    std_logic_vector(custombits-1 downto 0);
    customdout     : out   std_logic_vector(custombits-1 downto 0)
    );
end;

architecture rtl of ddr2phy_wrap is

  signal lddr_clk,lddr_clkb: std_logic_vector(nclk-1 downto 0);
  signal lddr_clk_fb_out,lddr_clk_fb: std_ulogic;
  signal lddr_cke,lddr_csb,lddr_odt: std_logic_vector(ncs-1 downto 0);
  signal lddr_web,lddr_rasb,lddr_casb: std_ulogic;
  signal lddr_dm,lddr_dqs_in,lddr_dqs_out,lddr_dqs_oen: std_logic_vector((dbits+padbits+chkbits)/8-1 downto 0);
  signal lddr_ad: std_logic_vector(abits-1 downto 0);
  signal lddr_ba: std_logic_vector(1+eightbanks downto 0);
  signal lddr_dq_in,lddr_dq_out,lddr_dq_oen: std_logic_vector(dbits+padbits+chkbits-1 downto 0);
  
  
begin

  -- Instantiate PHY without pads via other wrapper
  w0: ddr2phy_wrap_cbd_wo_pads
    generic map (tech,MHz,rstdelay,dbits,padbits,clk_mul,clk_div,
                 ddelayb0,ddelayb1,ddelayb2,ddelayb3,ddelayb4,ddelayb5,ddelayb6,ddelayb7,
                 cbdelayb0,cbdelayb1,cbdelayb2,cbdelayb3,
                 numidelctrl,norefclk,odten,rskew,
                 eightbanks,dqsse,abits,nclk,ncs,chkbits,resync,custombits)
    port map (
      rst,clk,clkref200,clkout,clkoutret,clkresync,lock,
      lddr_clk,lddr_clkb,lddr_clk_fb_out,lddr_clk_fb,
      lddr_cke,lddr_csb,lddr_web,lddr_rasb,lddr_casb,lddr_dm,
      lddr_dqs_in,lddr_dqs_out,lddr_dqs_oen,
      lddr_ad,lddr_ba,lddr_dq_in,lddr_dq_out,lddr_dq_oen,
      lddr_odt,
      sdi,sdo,customclk,customdin,customdout);

  -- Instantiate pads for control signals and data bus
  p0: ddr2pads
    generic map (tech,dbits+padbits,eightbanks,dqsse,abits,nclk,ncs,ctrl2en)
    port map (
      ddr_clk,ddr_clkb,ddr_clk_fb_out,ddr_clk_fb,
      ddr_cke,ddr_csb,ddr_web,ddr_rasb,ddr_casb,
      ddr_dm,ddr_dqs,ddr_dqsn,ddr_ad,ddr_ba,ddr_dq,ddr_odt,
      ddr_web2,ddr_rasb2,ddr_casb2,ddr_ad2,ddr_ba2,

      lddr_clk,lddr_clkb,lddr_clk_fb_out,lddr_clk_fb,
      lddr_cke,lddr_csb,lddr_web,lddr_rasb,lddr_casb,
      lddr_dm(dbits/8+padbits/8-1 downto 0),
      lddr_dqs_in(dbits/8+padbits/8-1 downto 0),
      lddr_dqs_out(dbits/8+padbits/8-1 downto 0),
      lddr_dqs_oen(dbits/8+padbits/8-1 downto 0),
      lddr_ad,lddr_ba,
      lddr_dq_in(dbits+padbits-1 downto 0),
      lddr_dq_out(dbits+padbits-1 downto 0),
      lddr_dq_oen(dbits+padbits-1 downto 0),
      lddr_odt);
      
  -- Instantiate pads for checkbit bus
  cbpadgen: for x in 0 to chkbits-1 generate
    cbdqpad: iopadvv
      generic map (tech => tech, slew => 1, level => sstl18_ii, width => chkbits)
      port map (pad => ddr_cbdq,
                i => lddr_dq_out(dbits+padbits+chkbits-1 downto dbits+padbits),
                en => lddr_dq_oen(dbits+padbits+chkbits-1 downto dbits+padbits),
                o => lddr_dq_in(dbits+padbits+chkbits-1 downto dbits+padbits));
    cbdqmpad: outpadv
      generic map (tech => tech, slew => 1, level => sstl18_i, width => chkbits/8)
      port map (pad => ddr_cbdm,
                i => lddr_dm(dbits/8+padbits/8+chkbits/8-1 downto dbits/8+padbits/8));
    cbdqspad: iopad_dsvv
      generic map (tech => tech, slew => 1, level => sstl18_ii, width => chkbits/8)
      port map (padp => ddr_cbdqs, padn => ddr_cbdqsn,
                i => lddr_dqs_out(dbits/8+padbits/8+chkbits/8-1 downto dbits/8+padbits/8),
                en => lddr_dqs_oen(dbits/8+padbits/8+chkbits/8-1 downto dbits/8+padbits/8),
                o => lddr_dqs_in(dbits/8+padbits/8+chkbits/8-1 downto dbits/8+padbits/8));
  end generate;

end;

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;

------------------------------------------------------------------
-- DDR2 PHY with checkbits merged on data bus --------------------
------------------------------------------------------------------

entity ddr2phy_wrap_cbd is
  generic (tech     : integer := virtex2; MHz        : integer := 100; 
	rstdelay    : integer := 200;     dbits      : integer := 16;  padbits  : integer := 0;
	clk_mul     : integer := 2 ;      clk_div    : integer := 2;
	ddelayb0    : integer := 0;       ddelayb1   : integer := 0;   ddelayb2 : integer := 0;
	ddelayb3    : integer := 0;       ddelayb4   : integer := 0;   ddelayb5 : integer := 0;
	ddelayb6    : integer := 0;       ddelayb7   : integer := 0;
        cbdelayb0   : integer := 0;       cbdelayb1: integer := 0;     cbdelayb2: integer := 0;
        cbdelayb3   : integer := 0;
        numidelctrl : integer := 4;       norefclk   : integer := 0;   odten    : integer := 0;
        rskew       : integer := 0;       eightbanks : integer range 0 to 1 := 0;
        dqsse       : integer range 0 to 1 := 0;
        abits       : integer := 14;      nclk     : integer := 3;     ncs      : integer := 2;
        chkbits  : integer := 0;          ctrl2en  : integer := 0;
        resync      : integer := 0;       custombits: integer := 8;    extraio  : integer := 0);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref200      : in    std_logic;   -- input 200MHz clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in    std_ulogic;  -- system clock return
    clkresync      : in    std_ulogic;
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;                               -- ddr write enable
    ddr_rasb       : out   std_ulogic;                               -- ddr ras
    ddr_casb       : out   std_ulogic;                               -- ddr cas
    ddr_dm         : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (extraio+(dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
    ddr_dqsn       : inout std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web2       : out   std_ulogic;                               -- ddr write enable
    ddr_rasb2      : out   std_ulogic;                               -- ddr ras
    ddr_casb2      : out   std_ulogic;                               -- ddr cas
    ddr_ad2        : out   std_logic_vector (abits-1 downto 0);      -- ddr address
    ddr_ba2        : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    
    sdi            : out   sdctrl_in_type;
    sdo            : in    sdctrl_out_type;

    customclk      : in    std_ulogic;
    customdin      : in    std_logic_vector(custombits-1 downto 0);
    customdout     : out   std_logic_vector(custombits-1 downto 0)
    );
end;

architecture rtl of ddr2phy_wrap_cbd is

  function ddr_widthconv(x: std_logic_vector; ow: integer) return std_logic_vector is
    variable r: std_logic_vector(2*ow-1 downto 0);
    constant iw: integer := x'length/2;
  begin
    r := (others => '0');
    if iw <= ow then
      r(iw+ow-1 downto ow) := x(2*iw-1 downto iw);
      r(iw-1 downto 0) := x(iw-1 downto 0);
    else
      r := x(iw+ow-1 downto iw) & x(ow-1 downto 0);
    end if;
    return r;
  end;

  function sdr_widthconv(x: std_logic_vector; ow: integer) return std_logic_vector is
    variable r: std_logic_vector(ow-1 downto 0);
    constant iw: integer := x'length;
    variable xd : std_logic_vector(iw-1 downto 0);
  begin
    r := (others => '0'); xd := x;
    if iw >= ow then
      r := xd(ow-1 downto 0);
    else
      r(iw-1 downto 0) := xd;
    end if;
    return r;
  end;

  function ddrmerge(a,b: std_logic_vector) return std_logic_vector is
    constant aw: integer := a'length/2;
    constant bw: integer := b'length/2;
  begin
    return a(2*aw-1 downto aw) & b(2*bw-1 downto bw) & a(aw-1 downto 0) & b(bw-1 downto 0);
  end;

  type int_array is array (natural range <>) of integer;
  constant delays: int_array(0 to 7) := (ddelayb0,ddelayb1,ddelayb2,ddelayb3,
                                         ddelayb4,ddelayb5,ddelayb6,ddelayb7);
  constant cbdelays: int_array(0 to 11) := (cbdelayb0,cbdelayb1,cbdelayb2,cbdelayb3,0,0,0,0,0,0,0,0);
  constant cbddelays: int_array(0 to 11) :=
    delays(0 to (dbits+padbits)/8-1) & cbdelays(0 to 11-(dbits+padbits)/8);
  
  signal dqin: std_logic_vector(2*(chkbits+dbits+padbits)-1 downto 0);
  signal dqout: std_logic_vector(2*(chkbits+dbits+padbits)-1 downto 0);
  signal dqm: std_logic_vector((chkbits+dbits+padbits)/4-1 downto 0);
  signal cal_en: std_logic_vector((chkbits+dbits+padbits)/8-1 downto 0);
  signal cal_inc: std_logic_vector((chkbits+dbits+padbits)/8-1 downto 0);

  signal odt,csn,cke: std_logic_vector(ncs-1 downto 0);
  
begin

  -- Merge checkbit and data buses
  comb: process(sdo,dqin)
    variable dq: std_logic_vector(2*dbits-1 downto 0);
    variable dqpad: std_logic_vector(2*(dbits+padbits)-1 downto 0);
    variable cb: std_logic_vector(dbits-1 downto 0);
    variable cbpad: std_logic_vector(2*chkbits downto 0);  -- Extra bit to handle chkbits=0
    variable dqcb: std_logic_vector(2*(dbits+padbits+chkbits)-1 downto 0);
    variable dm: std_logic_vector(dbits/4-1 downto 0);
    variable dmpad: std_logic_vector((dbits+padbits)/4-1 downto 0);
    variable cbdm: std_logic_vector(dbits/8-1 downto 0);
    variable cbdmpad: std_logic_vector(chkbits/4 downto 0);
    variable dqcbdm: std_logic_vector((dbits+padbits+chkbits)/4-1 downto 0);
    variable vcsn,vodt,vcke: std_logic_vector(ncs-1 downto 0);
  begin

    dq := sdo.data(2*dbits-1 downto 0);
    dqpad := ddr_widthconv(dq, dbits+padbits );
    if chkbits > 0 then
      cb    := sdo.cb(dbits-1 downto 0);
      cbpad := '0' & ddr_widthconv(cb, chkbits);
      dqcb  := ddrmerge(cbpad(2*chkbits-1 downto 0), dqpad);
    else
      dqcb  := dqpad;
    end if;
    dqout <= dqcb;

    dqcb := dqin;
    if chkbits > 0 then
      cbpad := '0' & dqin(2*(chkbits+dbits+padbits)-1 downto 2*(dbits+padbits)+chkbits) &
               dqin(chkbits+dbits+padbits-1 downto dbits+padbits);
      cb := ddr_widthconv(cbpad(2*chkbits-1 downto 0), dbits/2);
    else
      cb := (others => '0');
    end if;
    dq := dqcb(2*dbits+chkbits+padbits-1 downto dbits+chkbits+padbits) &
          dqcb(dbits-1 downto 0);    
    sdi.cb(dbits-1 downto 0) <= cb;
    sdi.data(2*dbits-1 downto 0) <= dq;
    if sdi.cb'length > dbits then
      sdi.cb(sdi.cb'length-1 downto dbits) <= (others => '0');
    end if;
    if sdi.data'length > 2*dbits then
      sdi.data(sdi.data'length-1 downto 2*dbits) <= (others => '0');
    end if;
    sdi.wprot <= '0';
    dm := sdo.dqm(dbits/4-1 downto 0);
    dmpad := ddr_widthconv(dm, (dbits+padbits)/8);
    if chkbits > 0 then
      cbdm := sdo.cbdqm(dbits/8-1 downto 0);
      cbdmpad := '0' & ddr_widthconv(cbdm(dbits/8-1 downto 0), chkbits/8);
      dqcbdm := ddrmerge(cbdmpad(chkbits/4-1 downto 0), dmpad);
    else
      dqcbdm := dmpad;
    end if;
    dqm <= dqcbdm;

    cal_en  <= sdr_widthconv(sdo.cbcal_en (dbits/16-1 downto 0) &
                             sdo.cal_en (dbits/8-1 downto 0), (dbits+padbits+chkbits)/8 );
    cal_inc <= sdr_widthconv(sdo.cbcal_inc(dbits/16-1 downto 0) &
                             sdo.cal_inc(dbits/8-1 downto 0), (dbits+padbits+chkbits)/8 );
        
    vcsn := (others => '1');
    for x in 0 to ncs-1 loop
      if x<2 then
        vcsn(x) := sdo.sdcsn(x);
      end if;
      vodt(x) := sdo.odt(x mod 2);
      vcke(x) := sdo.sdcke(x mod 2);
    end loop;
    csn <= vcsn;
    odt <= vodt;
    cke <= vcke;
    
  end process;
  
  -- Phy instantiation
    ddr_phy0 : ddr2phy 
     generic map (tech => tech, MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, dbits     => dbits+padbits+chkbits,clk_mul  => clk_mul,  clk_div  => clk_div, 
	ddelayb0    => cbddelays(0),    ddelayb1 => cbddelays(1), ddelayb2 => cbddelays(2),
	ddelayb3    => cbddelays(3),    ddelayb4 => cbddelays(4), ddelayb5 => cbddelays(5),
	ddelayb6    => cbddelays(6),    ddelayb7 => cbddelays(7), ddelayb8 => cbddelays(8),
        ddelayb9 => cbddelays(9), ddelayb10 => cbddelays(10), ddelayb11 => cbddelays(11),
        numidelctrl => numidelctrl, norefclk => norefclk, rskew    => rskew,
        eightbanks  => eightbanks,  dqsse => dqsse,
        abits       => abits,       nclk    => nclk,      ncs      => ncs,
        ctrl2en  => ctrl2en, resync => resync, custombits => custombits, extraio => extraio)
     port map (
	rst, clk, clkref200, clkout, clkoutret, clkresync, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt,
        
	sdo.address(1+abits downto 2), sdo.ba,
	dqin, dqout, 
	dqm, sdo.bdrive, sdo.nbdrive, sdo.bdrive, sdo.qdrive, 
	sdo.rasn, sdo.casn, sdo.sdwen, csn, cke, 
	cal_en, cal_inc, 
        sdo.cal_pll, sdo.cal_rst, odt, sdo.oct, sdo.read_pend,
        sdo.regwdata, sdo.regwrite, sdi.regrdata, sdi.datavalid,
        customclk, customdin, customdout,
        
        ddr_web2, ddr_rasb2, ddr_casb2, ddr_ad2, ddr_ba2
        );
end;

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.memctrl.all;

------------------------------------------------------------------
-- DDR2 PHY with checkbits merged on data bus, pads not in phy --
------------------------------------------------------------------

entity ddr2phy_wrap_cbd_wo_pads is
  generic (tech     : integer := virtex2; MHz        : integer := 100; 
	rstdelay    : integer := 200;     dbits      : integer := 16;  padbits  : integer := 0;
	clk_mul     : integer := 2 ;      clk_div    : integer := 2;
	ddelayb0    : integer := 0;       ddelayb1   : integer := 0;   ddelayb2 : integer := 0;
	ddelayb3    : integer := 0;       ddelayb4   : integer := 0;   ddelayb5 : integer := 0;
	ddelayb6    : integer := 0;       ddelayb7   : integer := 0;
        cbdelayb0   : integer := 0;       cbdelayb1: integer := 0;     cbdelayb2: integer := 0;
        cbdelayb3   : integer := 0;
        numidelctrl : integer := 4;       norefclk   : integer := 0;   odten    : integer := 0;
        rskew       : integer := 0;       eightbanks : integer range 0 to 1 := 0;
        dqsse       : integer range 0 to 1 := 0;
        abits       : integer := 14;      nclk     : integer := 3;     ncs      : integer := 2;
        chkbits  : integer := 0;          resync     : integer := 0;   custombits: integer := 8);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref200      : in    std_logic;   -- input 200MHz clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in    std_ulogic;  -- system clock return
    clkresync      : in    std_ulogic;
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;                               -- ddr write enable
    ddr_rasb       : out   std_ulogic;                               -- ddr ras
    ddr_casb       : out   std_ulogic;                               -- ddr cas
    ddr_dm         : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen    : out   std_logic_vector ((dbits+padbits+chkbits)/8-1 downto 0);    -- ddr dqs
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq_in      : in    std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
    ddr_dq_out     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
    ddr_dq_oen     : out   std_logic_vector (dbits+padbits+chkbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);
    
    sdi            : out   sdctrl_in_type;
    sdo            : in    sdctrl_out_type;

    customclk      : in    std_ulogic;
    customdin      : in    std_logic_vector(custombits-1 downto 0);
    customdout     : out   std_logic_vector(custombits-1 downto 0)
    );
end;

architecture rtl of ddr2phy_wrap_cbd_wo_pads is

  function ddr_widthconv(x: std_logic_vector; ow: integer) return std_logic_vector is
    variable r: std_logic_vector(2*ow-1 downto 0);
    constant iw: integer := x'length/2;
  begin
    r := (others => '0');
    if iw <= ow then
      r(iw+ow-1 downto ow) := x(2*iw-1 downto iw);
      r(iw-1 downto 0) := x(iw-1 downto 0);
    else
      r := x(iw+ow-1 downto iw) & x(ow-1 downto 0);
    end if;
    return r;
  end;

  function sdr_widthconv(x: std_logic_vector; ow: integer) return std_logic_vector is
    variable r: std_logic_vector(ow-1 downto 0);
    constant iw: integer := x'length;
    variable xd : std_logic_vector(iw-1 downto 0);
  begin
    r := (others => '0'); xd := x;
    if iw >= ow then
      r := xd(ow-1 downto 0);
    else
      r(iw-1 downto 0) := xd;
    end if;
    return r;
  end;

  function ddrmerge(a,b: std_logic_vector) return std_logic_vector is
    constant aw: integer := a'length/2;
    constant bw: integer := b'length/2;
  begin
    return a(2*aw-1 downto aw) & b(2*bw-1 downto bw) & a(aw-1 downto 0) & b(bw-1 downto 0);
  end;

  type int_array is array (natural range <>) of integer;
  constant delays: int_array(0 to 7) := (ddelayb0,ddelayb1,ddelayb2,ddelayb3,
                                         ddelayb4,ddelayb5,ddelayb6,ddelayb7);
  constant cbdelays: int_array(0 to 11) := (cbdelayb0,cbdelayb1,cbdelayb2,cbdelayb3,0,0,0,0,0,0,0,0);
  constant cbddelays: int_array(0 to 11) :=
    delays(0 to (dbits+padbits)/8-1) & cbdelays(0 to 11-(dbits+padbits)/8);
  
  signal dqin: std_logic_vector(2*(chkbits+dbits+padbits)-1 downto 0);
  signal dqout: std_logic_vector(2*(chkbits+dbits+padbits)-1 downto 0);
  signal dqm: std_logic_vector((chkbits+dbits+padbits)/4-1 downto 0);
  signal cal_en: std_logic_vector((chkbits+dbits+padbits)/8-1 downto 0);
  signal cal_inc: std_logic_vector((chkbits+dbits+padbits)/8-1 downto 0);
  
  signal odt,csn,cke: std_logic_vector(ncs-1 downto 0);

  signal gnd : std_logic_vector(chkbits*2-1 downto 0);
  
begin

  gnd <= (others => '0');
  
  -- Merge checkbit and data buses
  comb: process(sdo,dqin)
    variable dq: std_logic_vector(2*dbits-1 downto 0);
    variable dqpad: std_logic_vector(2*(dbits+padbits)-1 downto 0);
    variable cb: std_logic_vector(dbits-1 downto 0);
    variable cbpad: std_logic_vector(2*chkbits downto 0);  -- Extra bit to handle chkbits=0
    variable dqcb: std_logic_vector(2*(dbits+padbits+chkbits)-1 downto 0);
    variable dm: std_logic_vector(dbits/4-1 downto 0);
    variable dmpad: std_logic_vector((dbits+padbits)/4-1 downto 0);
    variable cbdm: std_logic_vector(dbits/8-1 downto 0);
    variable cbdmpad: std_logic_vector(chkbits/4 downto 0);
    variable dqcbdm: std_logic_vector((dbits+padbits+chkbits)/4-1 downto 0);
    variable vcsn,vodt,vcke: std_logic_vector(ncs-1 downto 0);
  begin

    dq := sdo.data(2*dbits-1 downto 0);
    dqpad := ddr_widthconv(dq, dbits+padbits );
    if chkbits > 0 then
      cb    := sdo.cb(dbits-1 downto 0);
      cbpad := '0' & ddr_widthconv(cb, chkbits);
      dqcb  := ddrmerge(cbpad(2*chkbits-1 downto 0), dqpad);
    else
      dqcb  := dqpad;
    end if;
    dqout <= dqcb;

    dqcb := dqin;
    if chkbits > 0 then
      cbpad := '0' & dqin(2*(chkbits+dbits+padbits)-1 downto 2*(dbits+padbits)+chkbits) &
               dqin(chkbits+dbits+padbits-1 downto dbits+padbits);
      cb := ddr_widthconv(cbpad(2*chkbits-1 downto 0), dbits/2);
    else
      cb := (others => '0');
    end if;
    dq := dqcb(2*dbits+chkbits+padbits-1 downto dbits+chkbits+padbits) &
          dqcb(dbits-1 downto 0);    
    sdi.cb(dbits-1 downto 0) <= cb;
    sdi.data(2*dbits-1 downto 0) <= dq;
    if sdi.cb'length > dbits then
      sdi.cb(sdi.cb'length-1 downto dbits) <= (others => '0');
    end if;
    if sdi.data'length > 2*dbits then
      sdi.data(sdi.data'length-1 downto 2*dbits) <= (others => '0');
    end if;
    sdi.wprot <= '0';
    dm := sdo.dqm(dbits/4-1 downto 0);
    dmpad := ddr_widthconv(dm, (dbits+padbits)/8);
    if chkbits > 0 then
      cbdm := sdo.cbdqm(dbits/8-1 downto 0);
      cbdmpad := '0' & ddr_widthconv(cbdm(dbits/8-1 downto 0), chkbits/8);
      dqcbdm := ddrmerge(cbdmpad(chkbits/4-1 downto 0), dmpad);
    else
      dqcbdm := dmpad;
    end if;
    dqm <= dqcbdm;

    cal_en  <= sdr_widthconv(sdo.cbcal_en (dbits/16-1 downto 0) &
                             sdo.cal_en (dbits/8-1 downto 0), (dbits+padbits+chkbits)/8 );
    cal_inc <= sdr_widthconv(sdo.cbcal_inc(dbits/16-1 downto 0) &
                             sdo.cal_inc(dbits/8-1 downto 0), (dbits+padbits+chkbits)/8 );
        
    vcsn := (others => '1');
    for x in 0 to ncs-1 loop
      if x<2 then
        vcsn(x) := sdo.sdcsn(x);
      end if;
      vodt(x) := sdo.odt(x mod 2);
      vcke(x) := sdo.sdcke(x mod 2);
    end loop;
    csn <= vcsn;
    odt <= vodt;
    cke <= vcke;
    
  end process;
  
  -- Phy instantiation
  ddr_phy0 : ddr2phy_wo_pads
    generic map (tech => tech, MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
       / 200
-- pragma translate_on
       , dbits     => dbits+padbits+chkbits,clk_mul  => clk_mul,  clk_div  => clk_div, 
	ddelayb0    => cbddelays(0),    ddelayb1 => cbddelays(1), ddelayb2 => cbddelays(2),
	ddelayb3    => cbddelays(3),    ddelayb4 => cbddelays(4), ddelayb5 => cbddelays(5),
	ddelayb6    => cbddelays(6),    ddelayb7 => cbddelays(7), ddelayb8 => cbddelays(8),
        ddelayb9 => cbddelays(9), ddelayb10 => cbddelays(10), ddelayb11 => cbddelays(11),
       numidelctrl => numidelctrl, norefclk => norefclk, rskew    => rskew,
       eightbanks  => eightbanks,  dqsse => dqsse,
       abits       => abits,       nclk    => nclk,      ncs      => ncs, resync => resync, custombits => custombits)
     port map (
	rst => rst, clk => clk, clkref => clkref200, clkout => clkout, clkoutret => clkoutret,
        clkresync => clkresync, lock => lock,
        
	ddr_clk => ddr_clk, ddr_clkb => ddr_clkb, ddr_clk_fb_out => ddr_clk_fb_out, ddr_clk_fb => ddr_clk_fb,
	ddr_cke => ddr_cke, ddr_csb => ddr_csb, ddr_web => ddr_web, ddr_rasb => ddr_rasb, ddr_casb => ddr_casb, 
	ddr_dm => ddr_dm, ddr_dqs_in => ddr_dqs_in, ddr_dqs_out => ddr_dqs_out, ddr_dqs_oen => ddr_dqs_oen,
        ddr_ad => ddr_ad, ddr_ba => ddr_ba, ddr_dq_in => ddr_dq_in, ddr_dq_out => ddr_dq_out, ddr_dq_oen => ddr_dq_oen,
        ddr_odt => ddr_odt,
        
	addr => sdo.address(1+abits downto 2), ba => sdo.ba, dqin => dqin, dqout => dqout, dm => dqm,
        oen => sdo.bdrive, noen => sdo.nbdrive,
        dqs => sdo.bdrive, dqsoen => sdo.qdrive, rasn => sdo.rasn, casn => sdo.casn, wen => sdo.sdwen, csn => csn,
        cke => cke, cal_en => cal_en, cal_inc => cal_inc, cal_pll => sdo.cal_pll, cal_rst => sdo.cal_rst, odt => odt,
        oct => sdo.oct, read_pend => sdo.read_pend, regwdata => sdo.regwdata, regwrite => sdo.regwrite,
        regrdata => sdi.regrdata, dqin_valid => sdi.datavalid,
        customclk => customclk, customdin => customdin, customdout => customdout
        );
end;
