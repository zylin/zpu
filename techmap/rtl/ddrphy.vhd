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
-- Entity: 	ddrphy
-- File:	ddrphy.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	DDR PHY with tech mapping
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
use techmap.allddr.all;

------------------------------------------------------------------
-- DDR PHY with tech mapping  ------------------------------------
------------------------------------------------------------------

entity ddrphy is
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
 
    addr  	: in  std_logic_vector (13 downto 0); -- data mask
    ba    	: in  std_logic_vector ( 1 downto 0); -- data mask
    dqin  	: out std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dqout 	: in  std_logic_vector (dbits*2-1 downto 0); -- ddr input data
    dm    	: in  std_logic_vector (dbits/4-1 downto 0); -- data mask
    oen       	: in  std_ulogic;
    dqs       	: in  std_ulogic;
    dqsoen     	: in  std_ulogic;
    rasn      	: in  std_ulogic;
    casn      	: in  std_ulogic;
    wen       	: in  std_ulogic;
    csn       	: in  std_logic_vector(1 downto 0);
    cke       	: in  std_logic_vector(1 downto 0);
    ck          : in  std_logic_vector(2 downto 0);
    moben       : in  std_logic;
    --
    psdone      : out std_ulogic;
    psovfl      : out std_ulogic;
    psclk       : in  std_ulogic;
    psen        : in  std_ulogic;
    psincdec    : in  std_ulogic
  );
end;

architecture rtl of ddrphy is

begin

  inf : if (tech = inferred) generate
    ddr_phy0 : generic_ddr_phy
     generic map (MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
        / 200
-- pragma translate_on
        , clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, rskew => rskew, mobile => mobile
        )
     port map (
        rst, clk, clkout, lock,
        ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
        ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
        ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
        addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
        rasn, casn, wen, csn, cke, ck, moben);
     clkread <= '0';
  end generate;


  strat2 : if (tech = stratix2) generate

    ddr_phy0 : stratixii_ddr_phy 
     generic map (MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, clk_mul => clk_mul, clk_div => clk_div, dbits => dbits
	)
     port map (
	rst, clk, clkout, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke);
     clkread <= '0';

  end generate;

  cyc3 : if (tech = cyclone3) generate

    ddr_phy0 : cycloneiii_ddr_phy 
     generic map (MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, rskew => rskew
  )
     port map (
	rst, clk, clkout, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke);
     clkread <= '0';

  end generate;

  xc2v : if (tech = virtex2) or (tech = spartan3) generate

    ddr_phy0 : virtex2_ddr_phy 
     generic map (MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, rskew => rskew
	)
     port map (
	rst, clk, clkout, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke);
     clkread <= '0';

  end generate;

  xc4v : if (tech = virtex4) or (tech = virtex5) or (tech = virtex6) generate

    ddr_phy0 : virtex4_ddr_phy 
     generic map (MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, rskew => rskew
	)
     port map (
	rst, clk, clkout, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke, ck);
     clkread <= '0';

  end generate;

  xc3se : if (tech = spartan3e) or  (tech = spartan6) generate

    ddr_phy0 : spartan3e_ddr_phy 
     generic map (MHz => MHz, rstdelay => rstdelay
-- reduce 200 us start-up delay during simulation
-- pragma translate_off
	/ 200
-- pragma translate_on
	, clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, rskew => rskew
	)
     port map (
	rst, clk, clkout, clkread, lock,
	ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke, psdone, psovfl, psclk, psen, psincdec);

  end generate;

end;



------------------------------------------------------------------
-- DDR2 PHY with tech mapping  ------------------------------------
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
use techmap.allddr.all;

entity ddr2pads is
  generic (tech: integer := virtex5;
           dbits: integer := 16;
           eightbanks: integer := 0;
           dqsse: integer range 0 to 1 := 0;
           abits: integer := 14;
           nclk: integer := 3;
           ncs: integer := 2;
           ctrl2en: integer := 0);
  port (
    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

    -- Copy of control signals for 2nd DIMM (if ctrl2en /= 0)
    ddr_web2       : out std_ulogic;                               -- ddr write enable
    ddr_rasb2      : out std_ulogic;                               -- ddr ras
    ddr_casb2      : out std_ulogic;                               -- ddr cas
    ddr_ad2        : out std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba2        : out std_logic_vector (1+eightbanks downto 0); -- ddr bank address        
    
    lddr_clk        : in    std_logic_vector(nclk-1 downto 0);
    lddr_clkb       : in    std_logic_vector(nclk-1 downto 0);
    lddr_clk_fb_out : in    std_logic;
    lddr_clk_fb     : out   std_logic;
    lddr_cke        : in    std_logic_vector(ncs-1 downto 0);
    lddr_csb        : in    std_logic_vector(ncs-1 downto 0);
    lddr_web        : in    std_ulogic;  -- ddr write enable
    lddr_rasb       : in    std_ulogic;  -- ddr ras
    lddr_casb       : in    std_ulogic;  -- ddr cas
    lddr_dm         : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    lddr_dqs_in     : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_dqs_out    : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_dqs_oen    : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    lddr_ad         : in    std_logic_vector (abits-1 downto 0);           -- ddr address
    lddr_ba         : in    std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    lddr_dq_in      : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_dq_out     : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_dq_oen     : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    lddr_odt        : in    std_logic_vector(ncs-1 downto 0)
    );
end;

architecture rtl of ddr2pads is
signal vcc : std_ulogic;
begin
  
  vcc <= '1';
  -- DDR clock feedback
  fbclkpadgen: if ddr2phy_has_fbclk(tech)/=0 generate
    fbclk_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_clk_fb_out, lddr_clk_fb_out);
    fbclk_in_pad : inpad generic map (tech => tech)
      port map (ddr_clk_fb, lddr_clk_fb);
  end generate;
  
  nfbclkpadgen: if ddr2phy_has_fbclk(tech)=0 generate
    ddr_clk_fb_out <= '0';
    lddr_clk_fb <= '0';
  end generate;
  
  -- External DDR clock
  ddrclocks : for i in 0 to nclk-1 generate
    -- DDR_CLK/B
    xc456v : if (tech = virtex4) or (tech = virtex5) or (tech = virtex6) generate
      ddrclk_pad : outpad_ds generic map (tech => tech, slew => 1, level => sstl18_i) 
        port map (ddr_clk(i), ddr_clkb(i), lddr_clk(i), vcc);
    end generate;
    noxc456v : if not ((tech = virtex4) or (tech = virtex5) or (tech = virtex6)) generate
    -- DDR_CLK
      ddrclk_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
        port map (ddr_clk(i), lddr_clk(i));
    -- DDR_CLKB
      ddrclkb_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
        port map (ddr_clkb(i), lddr_clkb(i));
    end generate;
  end generate;
  
  --  DDR single-edge control signals
  -- RAS
  rasn_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
    port map (ddr_rasb, lddr_rasb);
  -- CAS
  casn_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
    port map (ddr_casb, lddr_casb);
  -- WEN
  wen_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
    port map (ddr_web, lddr_web);
  -- BA
  bagen : for i in 0 to 1+eightbanks generate
    ddr_ba_pad  : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_ba(i), lddr_ba(i));
  end generate;
  -- ODT
  odtgen : for i in 0 to ncs-1 generate
    ddr_ba_pad  : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_odt(i), lddr_odt(i));
  end generate;
  -- ADDRESS
  dagen : for i in 0 to abits-1 generate
    ddr_ad_pad  : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_ad(i), lddr_ad(i));
  end generate;
  -- CSN and CKE
  ddrbanks : for i in 0 to ncs-1 generate
    csn_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_csb(i), lddr_csb(i));
    cke_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_cke(i), lddr_cke(i));
  end generate;
  
  -- DQS pads
  dqsse0 : if dqsse = 0 generate 
    dqsgen : for i in 0 to dbits/8-1 generate
      dqspn_pad : iopad_ds generic map (tech => tech, slew => 1, level => sstl18_ii)
        port map (padp => ddr_dqs(i), padn => ddr_dqsn(i), i=> lddr_dqs_out(i), en => lddr_dqs_oen(i), 
                  o => lddr_dqs_in(i));
    end generate;
  end generate;

  dqsse1 : if dqsse = 1 generate 
    dqsgen : for i in 0 to dbits/8-1 generate
      dqspn_pad : iopad generic map (tech => tech, slew => 1, level => sstl18_i)
        port map (pad => ddr_dqs(i), i=> lddr_dqs_out(i), en => lddr_dqs_oen(i), 
                  o => lddr_dqs_in(i));
    end generate;
  end generate;
  
  -- DQM pads
  dmgen : for i in 0 to dbits/8-1 generate
    ddr_bm_pad  : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_dm(i), lddr_dm(i));
  end generate;
  
  -- Data bus pads
  ddgen : for i in 0 to dbits-1 generate
    dq_pad : iopad generic map (tech => tech, slew => 1, level => sstl18_ii)
      port map (pad => ddr_dq(i), i => lddr_dq_out(i), en => lddr_dq_oen(i),
                o => lddr_dq_in(i));
  end generate;

  -- Second copy of address/data lines
  ctrl2gen: if ctrl2en/=0 generate
    rasn2_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_rasb2, lddr_rasb);
    casn2_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_casb2, lddr_casb);
    wen2_pad : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
      port map (ddr_web2, lddr_web);
    ba2gen : for i in 0 to 1+eightbanks generate
      ddr_ba_pad  : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
        port map (ddr_ba2(i), lddr_ba(i));
      da2gen : for i in 0 to abits-1 generate
        ddr_ad_pad  : outpad generic map (tech => tech, slew => 1, level => sstl18_i) 
          port map (ddr_ad2(i), lddr_ad(i));
      end generate;      
    end generate;    
  end generate;

  ctrl2ngen: if ctrl2en=0 generate
    ddr_rasb2 <= '0';
    ddr_casb2 <= '0';
    ddr_web2 <= '0';
    ddr_ba2 <= (others => '0');
    ddr_ad2 <= (others => '0');
  end generate;
  
end;
  
library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
use techmap.allddr.all;
use techmap.allpads.n2x_padcontrol_none;

-- With built-in pads
entity ddr2phy is
  generic (tech : integer := virtex5; MHz : integer := 100; 
	rstdelay : integer := 200; dbits : integer := 16; 
	clk_mul : integer := 2; clk_div : integer := 2;
	ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
	ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
	ddelayb6 : integer := 0; ddelayb7 : integer := 0;
        ddelayb8: integer := 0;
	ddelayb9: integer := 0; ddelayb10: integer := 0; ddelayb11: integer := 0;        
        numidelctrl : integer := 4; norefclk : integer := 0; rskew : integer := 0;
        eightbanks  : integer  range 0 to 1 := 0; dqsse : integer range 0 to 1 := 0;
        abits       : integer := 14;   nclk: integer := 3; ncs: integer := 2;
        ctrl2en: integer := 0;
        resync: integer := 0; custombits: integer := 8; extraio: integer := 0);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref         : in    std_logic;   -- input 200MHz clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in  std_ulogic;         -- system clock returned
    clkresync      : in    std_ulogic;  -- resync clock (if resync/=0)
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs        : inout std_logic_vector (extraio+dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqsn       : inout std_logic_vector (dbits/8-1 downto 0);    -- ddr dqsn
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq         : inout std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

    addr           : in    std_logic_vector (abits-1 downto 0);
    ba             : in    std_logic_vector ( 2 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);  -- ddr output data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen            : in    std_ulogic;
    noen           : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(ncs-1 downto 0);
    cke            : in    std_logic_vector(ncs-1 downto 0);
    cal_en         : in    std_logic_vector(dbits/8-1 downto 0);
    cal_inc        : in    std_logic_vector(dbits/8-1 downto 0);
    cal_pll        : in    std_logic_vector(1 downto 0);
    cal_rst        : in    std_logic;
    odt            : in    std_logic_vector(ncs-1 downto 0);
    oct            : in    std_logic;
    read_pend      : in    std_logic_vector(7 downto 0);
    regwdata       : in    std_logic_vector(63 downto 0);
    regwrite       : in    std_logic_vector(1 downto 0);
    regrdata       : out   std_logic_vector(63 downto 0);
    dqin_valid     : out   std_ulogic;    
    
    customclk      : in    std_ulogic;
    customdin      : in    std_logic_vector(custombits-1 downto 0);
    customdout     : out   std_logic_vector(custombits-1 downto 0);

    -- Copy of control signals for 2nd DIMM
    ddr_web2       : out std_ulogic;                               -- ddr write enable
    ddr_rasb2      : out std_ulogic;                               -- ddr ras
    ddr_casb2      : out std_ulogic;                               -- ddr cas
    ddr_ad2        : out std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba2        : out std_logic_vector (1+eightbanks downto 0)  -- ddr bank address        
    );
end;

architecture rtl of ddr2phy is

  signal lddr_clk,lddr_clkb: std_logic_vector(nclk-1 downto 0);
  signal lddr_clk_fb_out,lddr_clk_fb: std_logic;
  signal lddr_cke, lddr_csb: std_logic_vector(ncs-1 downto 0);
  signal lddr_web,lddr_rasb,lddr_casb: std_logic;
  signal lddr_dm, lddr_dqs_in,lddr_dqs_out,lddr_dqs_oen: std_logic_vector(dbits/8-1 downto 0);
  signal lddr_dqsn_in,lddr_dqsn_out,lddr_dqsn_oen: std_logic_vector(dbits/8-1 downto 0);
  signal lddr_ad: std_logic_vector(abits-1 downto 0);
  signal lddr_ba: std_logic_vector(1+eightbanks downto 0);
  signal lddr_dq_in,lddr_dq_out,lddr_dq_oen: std_logic_vector(dbits-1 downto 0);
  signal lddr_odt: std_logic_vector(ncs-1 downto 0);

  signal customdin_exp: std_logic_vector(132 downto 0);
  
begin

  customdin_exp(custombits-1 downto 0) <= customdin;
  customdin_exp(customdin_exp'high downto custombits) <= (others => '0');
  
  -- For technologies without PHY-specific registers
  nreggen: if ddr2phy_has_reg(tech)=0 and ddr2phy_builtin_pads(tech)/=0 generate
    regrdata <= x"0000000000000000";
  end generate;
  ncustgen: if ddr2phy_has_custom(tech)=0 and ddr2phy_builtin_pads(tech)/=0 generate
    customdout <= (others => '0');
  end generate;
  
  stra2 : if (tech = stratix2) generate

      ddr_phy0 : stratixii_ddr2_phy
      generic map (MHz => MHz, rstdelay => rstdelay,
        clk_mul => clk_mul, clk_div => clk_div, dbits => dbits
      )
      port map (
        rst, clk, clkout, lock, ddr_clk, ddr_clkb,
        ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb,
        ddr_dm, ddr_dqs, ddr_ad, ddr_ba, ddr_dq, ddr_odt,
        addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
        rasn, casn, wen, csn, cke, cal_en, cal_inc, cal_rst, odt);
      dqin_valid <= '1';
                                                                                  
  end generate;

  stra3 : if (tech = stratix3) generate

    ddr_phy0 : stratixiii_ddr2_phy 
     generic map (MHz => MHz, rstdelay => rstdelay,
	clk_mul => clk_mul, clk_div => clk_div, dbits => dbits,
	ddelayb0 => ddelayb0, ddelayb1 => ddelayb1, ddelayb2 => ddelayb2, 
	ddelayb3 => ddelayb3, ddelayb4 => ddelayb4, ddelayb5 => ddelayb5, 
	ddelayb6 => ddelayb6, ddelayb7 => ddelayb7,
        numidelctrl => numidelctrl, norefclk => norefclk, 
        tech => tech, rskew => rskew, eightbanks => eightbanks
	)
     port map (
	rst, clk, clkref, clkout, lock,
	ddr_clk, ddr_clkb, 
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke, cal_en, cal_inc, cal_pll, cal_rst, odt, oct);
    dqin_valid <= '1';
    
  end generate;

  sp3a : if (tech = spartan3) generate
    ddr_phy0 : spartan3a_ddr2_phy 
     generic map (MHz => MHz, rstdelay => rstdelay,
                  clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, tech => tech, rskew => rskew,
                  eightbanks => eightbanks)
     port map (   rst, clk, clkout, lock, ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
                  ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
                  ddr_dm, ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt,
                  addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
                  rasn, casn, wen, csn, cke, cal_pll, odt);
    dqin_valid <= '1';
  end generate;

  nextreme : if (tech = easic90) generate
    ddr_phy0 : easic90_ddr2_phy
      generic map (
        tech       => tech,
        MHz        => MHz,
        clk_mul    => clk_mul,
        clk_div    => clk_div,
        dbits      => dbits,
        rstdelay   => rstdelay,
        eightbanks => eightbanks)
     port map (
	rst, clk, clkout, lock, ddr_clk, ddr_clkb, ddr_clk_fb_out,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke, odt, '1');
    dqin_valid <= '1';
  end generate;

  sp6 : if  (tech = spartan6) generate
--    ddr_phy0 : spartan6_ddr2_phy 
    ddr_phy0 : spartan3a_ddr2_phy 
     generic map (MHz => MHz, rstdelay => rstdelay,
                  clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, tech => tech, rskew => rskew,
                  eightbanks => eightbanks)
     port map (   rst, clk, clkout, lock, ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
                  ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
                  ddr_dm, ddr_dqs, ddr_dqsn, ddr_ad, ddr_ba, ddr_dq, ddr_odt,
                  addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
                  rasn, casn, wen, csn, cke, cal_pll, odt);
    dqin_valid <= '1';
  end generate;

  nextreme2 : if (tech = easic45) generate
    -- This requires dbits/8 extra bidir I/O that are suppliedd on the ddr_dqs port
    ddr_phy0 :  n2x_ddr2_phy
      generic map (
        MHz => MHz, rstdelay => rstdelay,
        dbits => dbits, clk_mul => clk_mul, clk_div => clk_div, norefclk => norefclk,
        eightbanks => eightbanks, dqsse => dqsse, abits => abits,
        nclk => nclk, ncs => ncs, ctrl2en => ctrl2en)
      port map (
        rst => rst, clk => clk, clk270d => clkref,
        clkout => clkout, clkoutret => clkoutret, lock => lock,
        ddr_clk => ddr_clk, ddr_clkb => ddr_clkb, ddr_cke => ddr_cke,
        ddr_csb => ddr_csb, ddr_web => ddr_web, ddr_rasb => ddr_rasb, ddr_casb => ddr_casb,
        ddr_dm => ddr_dm, ddr_dqs => ddr_dqs(dbits/8-1 downto 0), ddr_dqsn => ddr_dqsn, ddr_ad => ddr_ad, ddr_ba => ddr_ba,
        ddr_dq => ddr_dq, ddr_odt => ddr_odt, rden_pad => ddr_dqs(dbits/4-1 downto dbits/8),
        addr => addr, ba => ba, dqin => dqin, dqout => dqout, dm => dm,
        noen => noen,
        rasn => rasn, casn => casn, wen => wen, csn => csn, cke => cke,
        odt => odt, read_pend => read_pend, dqin_valid => dqin_valid,
        regwdata => regwdata, regwrite => regwrite, regrdata => regrdata,
        ddr_web2 => ddr_web2, ddr_rasb2 => ddr_rasb2, ddr_casb2 => ddr_casb2,
        ddr_ad2 => ddr_ad2, ddr_ba2 => ddr_ba2,
        dq_control  => customdin_exp(73 downto 56),
        dqs_control => customdin_exp(55 downto 38),
        ck_control  => customdin_exp(37 downto 20),
        cmd_control => customdin_exp(19 downto 2),
        compen => customdin_exp(0),
        compupd => customdin_exp(1)
        );
    ddr_clk_fb_out <= '0';
    customdout <= (others => '0');
  end generate;

  -----------------------------------------------------------------------------
  -- For technologies where the PHY does not have pads,
  -- instantiate ddr2phy_wo_pads + pads
  -----------------------------------------------------------------------------
  seppads: if ddr2phy_builtin_pads(tech)=0 generate
    
    phywop: ddr2phy_wo_pads
      generic map (tech,MHz,rstdelay,dbits,clk_mul,clk_div,
                   ddelayb0,ddelayb1,ddelayb2,ddelayb3,
                   ddelayb4,ddelayb5,ddelayb6,ddelayb7,
                   ddelayb8,ddelayb9,ddelayb10,ddelayb11,
                   numidelctrl,norefclk,rskew,eightbanks,dqsse,abits,nclk,ncs,
                   resync,custombits)
      port map (
        rst,clk,clkref,clkout,clkoutret,clkresync,lock,
        
        lddr_clk,lddr_clkb,lddr_clk_fb_out,lddr_clk_fb,lddr_cke,lddr_csb,
        lddr_web,lddr_rasb,lddr_casb,lddr_dm,
        lddr_dqs_in,lddr_dqs_out,lddr_dqs_oen,
        lddr_ad,lddr_ba,
        lddr_dq_in,lddr_dq_out,lddr_dq_oen,lddr_odt,
        
        addr,ba,dqin,dqout,dm,oen,noen,dqs,dqsoen,rasn,casn,wen,csn,cke,
        cal_en,cal_inc,cal_pll,cal_rst,odt,oct,
        read_pend,regwdata,regwrite,regrdata,dqin_valid,customclk,customdin,customdout);

    pads: ddr2pads
      generic map (tech,dbits,eightbanks,dqsse,abits,nclk,ncs,ctrl2en)
      port map (ddr_clk,ddr_clkb,ddr_clk_fb_out,ddr_clk_fb,
                ddr_cke,ddr_csb,ddr_web,ddr_rasb,ddr_casb,ddr_dm,ddr_dqs,ddr_dqsn,
                ddr_ad,ddr_ba,ddr_dq,ddr_odt,
                ddr_web2,ddr_rasb2,ddr_casb2,ddr_ad2,ddr_ba2,
                lddr_clk,lddr_clkb,lddr_clk_fb_out,lddr_clk_fb,
                lddr_cke,lddr_csb,lddr_web,lddr_rasb,lddr_casb,lddr_dm,
                lddr_dqs_in,lddr_dqs_out,lddr_dqs_oen,
                lddr_ad,lddr_ba,lddr_dq_in,lddr_dq_out,lddr_dq_oen,lddr_odt);
        
  end generate;

  nseppads: if ddr2phy_builtin_pads(tech)/=0 generate
    lddr_clk <= (others => '0');
    lddr_clkb <= (others => '0');
    lddr_clk_fb_out <= '0';
    lddr_clk_fb <= '0';
    lddr_cke <= (others => '0');
    lddr_csb <= (others => '0');
    lddr_web <= '0';
    lddr_rasb <= '0';
    lddr_casb <= '0';
    lddr_dm <= (others => '0');
    lddr_dqs_in <= (others => '0');
    lddr_dqs_out <= (others => '0');
    lddr_dqs_oen <= (others => '0');
    lddr_dqsn_in <= (others => '0');
    lddr_dqsn_out <= (others => '0');
    lddr_dqsn_oen <= (others => '0');
    lddr_ad <= (others => '0');
    lddr_ba <= (others => '0');
    lddr_dq_in <= (others => '0');
    lddr_dq_out <= (others => '0');
    lddr_dq_oen <= (others => '0');
    lddr_odt <= (others => '0');
  end generate;
    
end;

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library techmap;
use techmap.gencomp.all;
use techmap.allddr.all;

-- without pads (typically used for ASIC technologies)
entity ddr2phy_wo_pads is
  generic (tech : integer := virtex5; MHz : integer := 100; 
	rstdelay : integer := 200; dbits : integer := 16; 
	clk_mul : integer := 2; clk_div : integer := 2;
	ddelayb0 : integer := 0; ddelayb1 : integer := 0; ddelayb2 : integer := 0;
	ddelayb3 : integer := 0; ddelayb4 : integer := 0; ddelayb5 : integer := 0;
	ddelayb6 : integer := 0; ddelayb7 : integer := 0;
        ddelayb8: integer := 0;
	ddelayb9: integer := 0; ddelayb10: integer := 0; ddelayb11: integer := 0;        
        numidelctrl : integer := 4; norefclk : integer := 0; rskew : integer := 0;
        eightbanks  : integer  range 0 to 1 := 0; dqsse : integer range 0 to 1 := 0;
        abits       : integer := 14;   nclk: integer := 3; ncs: integer := 2;
        resync : integer := 0; custombits: integer := 8);
  port (
    rst            : in    std_ulogic;
    clk            : in    std_logic;   -- input clock
    clkref         : in    std_logic;   -- input 200MHz clock
    clkout         : out   std_ulogic;  -- system clock
    clkoutret      : in    std_ulogic;  -- system clock returned
    clkresync      : in    std_ulogic;  -- resync clock (if resync/=0)
    lock           : out   std_ulogic;  -- DCM locked

    ddr_clk        : out   std_logic_vector(nclk-1 downto 0);
    ddr_clkb       : out   std_logic_vector(nclk-1 downto 0);
    ddr_clk_fb_out : out   std_logic;
    ddr_clk_fb     : in    std_logic;
    ddr_cke        : out   std_logic_vector(ncs-1 downto 0);
    ddr_csb        : out   std_logic_vector(ncs-1 downto 0);
    ddr_web        : out   std_ulogic;  -- ddr write enable
    ddr_rasb       : out   std_ulogic;  -- ddr ras
    ddr_casb       : out   std_ulogic;  -- ddr cas
    ddr_dm         : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dm
    ddr_dqs_in     : in    std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_out    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_dqs_oen    : out   std_logic_vector (dbits/8-1 downto 0);    -- ddr dqs
    ddr_ad         : out   std_logic_vector (abits-1 downto 0);           -- ddr address
    ddr_ba         : out   std_logic_vector (1+eightbanks downto 0); -- ddr bank address
    ddr_dq_in      : in    std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_out     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_dq_oen     : out   std_logic_vector (dbits-1 downto 0);      -- ddr data
    ddr_odt        : out   std_logic_vector(ncs-1 downto 0);

    addr           : in    std_logic_vector (abits-1 downto 0);
    ba             : in    std_logic_vector ( 2 downto 0);
    dqin           : out   std_logic_vector (dbits*2-1 downto 0);  -- ddr output data
    dqout          : in    std_logic_vector (dbits*2-1 downto 0);  -- ddr input data
    dm             : in    std_logic_vector (dbits/4-1 downto 0);  -- data mask
    oen            : in    std_ulogic;
    noen           : in    std_ulogic;
    dqs            : in    std_ulogic;
    dqsoen         : in    std_ulogic;
    rasn           : in    std_ulogic;
    casn           : in    std_ulogic;
    wen            : in    std_ulogic;
    csn            : in    std_logic_vector(ncs-1 downto 0);
    cke            : in    std_logic_vector(ncs-1 downto 0);
    cal_en         : in    std_logic_vector(dbits/8-1 downto 0);
    cal_inc        : in    std_logic_vector(dbits/8-1 downto 0);
    cal_pll        : in    std_logic_vector(1 downto 0);
    cal_rst        : in    std_logic;
    odt            : in    std_logic_vector(ncs-1 downto 0);
    oct            : in    std_logic;
    read_pend      : in    std_logic_vector(7 downto 0);
    regwdata       : in    std_logic_vector(63 downto 0);
    regwrite       : in    std_logic_vector(1 downto 0);
    regrdata       : out   std_logic_vector(63 downto 0);
    dqin_valid     : out   std_ulogic;
    customclk      : in    std_ulogic;
    customdin      : in    std_logic_vector(custombits-1 downto 0);
    customdout     : out   std_logic_vector(custombits-1 downto 0)
    );
end;

architecture rtl of ddr2phy_wo_pads is
begin

  -- For technologies without PHY-specific registers
  nreggen: if ddr2phy_has_reg(tech)=0 generate
    regrdata <= x"0000000000000000";
  end generate;
  ncustgen: if ddr2phy_has_custom(tech)=0 generate
    customdout <= (others => '0');
  end generate;
  
  xc4v : if (tech = virtex4) or (tech = virtex5) or (tech = virtex6) generate

    ddr_phy0 : virtex5_ddr2_phy_wo_pads
     generic map (MHz => MHz, rstdelay => rstdelay,
	clk_mul => clk_mul, clk_div => clk_div, dbits => dbits,
	ddelayb0 => ddelayb0, ddelayb1 => ddelayb1, ddelayb2 => ddelayb2, 
	ddelayb3 => ddelayb3, ddelayb4 => ddelayb4, ddelayb5 => ddelayb5, 
	ddelayb6 => ddelayb6, ddelayb7 => ddelayb7, ddelayb8 => ddelayb8,
	ddelayb9 => ddelayb9, ddelayb10 => ddelayb10, ddelayb11 => ddelayb11,
        numidelctrl => numidelctrl, norefclk => norefclk, 
        tech => tech, eightbanks => eightbanks, dqsse => dqsse,
        abits => abits, nclk => nclk, ncs => ncs
	)
     port map (
	rst, clk, clkref, clkout, clkoutret, lock,
	ddr_clk, ddr_clkb,
	ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
	ddr_dm, ddr_dqs_in, ddr_dqs_out, ddr_dqs_oen,
        ddr_ad, ddr_ba,
        ddr_dq_in, ddr_dq_out, ddr_dq_oen,ddr_odt,
	addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
	rasn, casn, wen, csn, cke, cal_en, cal_inc, cal_rst, odt);

     ddr_clk_fb_out <= '0';
    dqin_valid <= '1';
  end generate;

  
  inf : if (has_ddr2phy(tech) = 0) generate
    ddr_phy0 : generic_ddr2_phy_wo_pads
     generic map (MHz => MHz, rstdelay => rstdelay,
        clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, rskew => rskew,
        eightbanks => eightbanks, abits => abits
        )
     port map (
        rst, clk, clkout, clkoutret, lock,
        ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
        ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
        ddr_dm, ddr_dqs_in, ddr_dqs_out, ddr_dqs_oen,        
        ddr_ad, ddr_ba,
        ddr_dq_in, ddr_dq_out, ddr_dq_oen, ddr_odt,
        addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
        rasn, casn, wen, csn, cke, "111", odt
        );
    dqin_valid <= '1';
  end generate;
    
  ut9 : if (tech = ut90) generate
    ddr_phy0 : ut90nhbd_ddr2_phy_wo_pads
     generic map (MHz => MHz, rstdelay => rstdelay,
        clk_mul => clk_mul, clk_div => clk_div, dbits => dbits, rskew => rskew,
        eightbanks => eightbanks, abits => abits
        )
     port map (
        rst, clk, clkout, clkoutret, lock,
        ddr_clk, ddr_clkb, ddr_clk_fb_out, ddr_clk_fb,
        ddr_cke, ddr_csb, ddr_web, ddr_rasb, ddr_casb, 
        ddr_dm, ddr_dqs_in, ddr_dqs_out, ddr_dqs_oen, ddr_ad, ddr_ba,
        ddr_dq_in, ddr_dq_out, ddr_dq_oen, ddr_odt,
        addr, ba, dqin, dqout, dm, oen, dqs, dqsoen,
        rasn, casn, wen, csn, cke, "111", odt
        );
    dqin_valid <= '1';
  end generate;

end;
