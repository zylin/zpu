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
-------------------------------------------------------------------------------
-- Entity:     spictrl
-- File:       spictrl.vhd
-- Author:     Jan Andersson - Aeroflex Gaisler AB
--             jan@gaisler.com
--
-- Description: SPI controller with an interface compatible with MPC83xx SPI.
--              Relies on APB's wait state between back-to-back transfers.
--
-- Revision 1 of this core introduced the following changes:
--
-- 3-wire mode. The core can be placed in 3-wire mode by writing bit 15 in the
-- mode register.
--
-- Revision 2 of this core introduced the following changes:
--
-- Added synhronization register on input data line so that asynchronous signals
-- will not cause glitches in the combinational logic assigning position 0 in
-- the shift tregisters. Precautionary action, no issues have been observed.
--
-- Open drain mode - requries that odmode generic is set to 1 and that the core
-- is connected to I/O or OD pads.
--
-- asvsel generic that decides if the core should use automatic slave select
--
-- A field called FACT has been added to the Mode register. This field decides
-- if the highest attainable SCK frequenecy (in master mode) should be SYSFREQ/2
-- or SYSFREQ/4. If FACT is set to 1 the core's register interface is no longer
-- compatible with the interface found in MPC83xx SoCs.
--
-- Event register now has status bit for when core has transfer in progress
--
-- Support for automatic periodic transfers has been added, see the GRIP
-- documentation for details.
--
-- Enhancements after revision 2
-- 
-- Configurable maximum word length via the maxwlen generic
-- 

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.misc.all;

entity spictrl is
  generic (
    -- APB generics
    pindex : integer := 0;                -- slave bus index
    paddr  : integer := 0;                -- APB address
    pmask  : integer := 16#fff#;          -- APB mask
    pirq   : integer := 0;                -- interrupt index
    
    -- SPI controller configuration
    fdepth    : integer range 1 to 7  := 1;  -- FIFO depth is 2^fdepth
    slvselen  : integer range 0 to 1  := 0;  -- Slave select register enable
    slvselsz  : integer range 1 to 32 := 1;  -- Number of slave select signals
    oepol     : integer range 0 to 1  := 0;  -- Output enable polarity
    odmode    : integer range 0 to 1  := 0;  -- Support open drain mode, only
                                             -- set if pads are i/o or od pads.
    automode  : integer range 0 to 1  := 0;  -- Enable automated transfer mode
    acntbits  : integer range 1 to 32 := 32; -- # Bits in am period counter 
    aslvsel   : integer range 0 to 1  := 0;  -- Automatic slave select
    twen      : integer range 0 to 1  := 1;  -- Enable three wire mode
    maxwlen   : integer range 0 to 15 := 0   -- Maximum word length
    );
  port (
    rstn   : in std_ulogic;
    clk    : in std_ulogic;
    
    -- APB signals
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;

    -- SPI signals
    spii   : in  spi_in_type;
    spio   : out spi_out_type;
    slvsel : out std_logic_vector((slvselsz-1) downto 0)
    );
end entity spictrl;

architecture rtl of spictrl is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------
  constant SPICTRL_REV : integer := 2;

  constant PCONFIG : apb_config_type := (
  0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_SPICTRL, 0, SPICTRL_REV, pirq),
  1 => apb_iobar(paddr, pmask));

  constant OEPOL_LEVEL : std_ulogic := conv_std_logic(oepol = 1);
  
  constant OUTPUT : std_ulogic := OEPOL_LEVEL;      -- Enable outputs
  constant INPUT : std_ulogic := not OEPOL_LEVEL;   -- Tri-state outputs
  
  constant FIFO_DEPTH  : integer := 2**fdepth;
  constant SLVSEL_EN   : integer := slvselen;
  constant SLVSEL_SZ   : integer := slvselsz;
  constant ASEL_EN     : integer := aslvsel * slvselen;
  constant AM_EN       : integer := automode;
  constant AM_CNT_BITS : integer := acntbits;
  constant OD_EN       : integer := odmode;
  constant TW_EN       : integer := twen;
  constant MAX_WLEN    : integer := maxwlen;
  
  constant CAP_ADDR    : std_logic_vector(7 downto 2) := "000000";  -- 0x00

  constant MODE_ADDR   : std_logic_vector(7 downto 2) := "001000";  -- 0x20
  constant EVENT_ADDR  : std_logic_vector(7 downto 2) := "001001";  -- 0x24
  constant MASK_ADDR   : std_logic_vector(7 downto 2) := "001010";  -- 0x28
  constant COM_ADDR    : std_logic_vector(7 downto 2) := "001011";  -- 0x2C
  constant TD_ADDR     : std_logic_vector(7 downto 2) := "001100";  -- 0x30
  constant RD_ADDR     : std_logic_vector(7 downto 2) := "001101";  -- 0x34
  constant SLVSEL_ADDR : std_logic_vector(7 downto 2) := "001110";  -- 0x38
  constant ASEL_ADDR   : std_logic_vector(7 downto 2) := "001111";  -- 0x3C
  
  constant AMCFG_ADDR  : std_logic_vector(7 downto 2) := "010000";  -- 0x40
  constant AMPER_ADDR  : std_logic_vector(7 downto 2) := "010001";  -- 0x44
  
  constant SPICTRLCAPREG : std_logic_vector(31 downto 0) :=
    conv_std_logic_vector(SLVSEL_SZ,8) & conv_std_logic_vector(MAX_WLEN,4) &
    conv_std_logic_vector(TW_EN,1) & conv_std_logic_vector(AM_EN,1) &
    conv_std_logic_vector(ASEL_EN,1) & conv_std_logic_vector(SLVSEL_EN,1) &
    conv_std_logic_vector(FIFO_DEPTH,8) & conv_std_logic_vector(SPICTRL_REV,8);

  -- Returns an integer containing the maximum characted length - 1 as
  -- restricted by the maxwlen VHDL generic.
  function wlen return integer is
  begin  -- maxwlen
    if MAX_WLEN = 0 then return 31; end if;
    return MAX_WLEN;
  end wlen;
  
  -----------------------------------------------------------------------------
  -- Types
  -----------------------------------------------------------------------------
  type spi_mode_rec is record           -- SPI Mode register
    amen    : std_ulogic;
    loopb   : std_ulogic;  -- loopback mode
    cpol    : std_ulogic;  -- clock polarity
    cpha    : std_ulogic;  -- clock phase
    div16   : std_ulogic;  -- Divide by 16
    rev     : std_ulogic;  -- Reverse data mode
    ms      : std_ulogic;  -- Master/slave
    en      : std_ulogic;  -- Enable SPI
    len     : std_logic_vector(3 downto 0);  -- Bits per character
    pm      : std_logic_vector(3 downto 0);  -- Prescale modulus
    tw      : std_ulogic;  -- 3-wire mode
    asel    : std_ulogic;  -- Automatic slave select
    fact    : std_ulogic;  -- PM multiplication factor
    od      : std_ulogic;  -- Open drain mode
    cg      : std_logic_vector(4 downto 0);  -- Clock gap
    aseldel : std_logic_vector(1 downto 0);  -- Asel delay
    tac     : std_ulogic;
  end record;

  type spi_em_rec is record             -- SPI Event and Mask registers
    tip : std_ulogic;  -- Transfer in progress/Clock generated
    lt  : std_ulogic;  -- last character transmitted
    ov  : std_ulogic;  -- slave/master overrun
    un  : std_ulogic;  -- slave/master underrun
    mme : std_ulogic;  -- Multiple-master error
    ne  : std_ulogic;  -- Not empty
    nf  : std_ulogic;  -- Not full
  end record;
  
  type spi_fifo is array (0 to (FIFO_DEPTH-1)) of std_logic_vector(wlen downto 0);

  type spi_amcfg_rec is record          -- AM config register
    seq    : std_ulogic;  -- Data must always be read out of receive queue
    strict : std_ulogic;  -- Strict period
    ovtb   : std_ulogic;  -- Perform transfer on OV
    ovdb   : std_ulogic;  -- Skip data on OV
    act    : std_ulogic;  -- Start immediately
    eact   : std_ulogic;  -- Activate on external event
  end record;
  
  type spi_am_rec is record             -- Automode state
    -- Register interface
    cfg      : spi_amcfg_rec;  -- AM config register
    per      : std_logic_vector((AM_CNT_BITS-1)*AM_EN downto 0);  -- AM period
    --
    active   : std_ulogic; -- Auto mode active
    lock     : std_ulogic;
    cnt      : unsigned((AM_CNT_BITS-1)*AM_EN downto 0);
    --
    skipdata : std_ulogic;
    rxfull   : std_ulogic;  -- AM RX FIFO is filled
    rxfifo   : spi_fifo;    -- Receive data FIFO
    rfreecnt : integer range 0 to FIFO_DEPTH; -- free rx fifo slots
    tfreecnt : integer range 0 to FIFO_DEPTH; -- free td fifo slots
  end record;
       
  -- Two stage synchronizers on each input coming from off-chip
  type spi_in_local_type is record
    miso    : std_ulogic;
    mosi    : std_ulogic;
    sck     : std_ulogic;
    spisel  : std_ulogic;
  end record;  

  type spi_in_array is array (1 downto 0) of spi_in_local_type;
  
  type spi_reg_type is record
    -- SPI registers
    mode     : spi_mode_rec;  -- Mode register
    event    : spi_em_rec;    -- Event register
    mask     : spi_em_rec;    -- Mask register
    lst      : std_ulogic;    -- Only field on command register
    td       : std_logic_vector(31 downto 0);  -- Transmit register
    rd       : std_logic_vector(31 downto 0);  -- Receive register
    slvsel   : std_logic_vector((SLVSEL_SZ-1) downto 0);  -- Slave select register
    aslvsel  : std_logic_vector((SLVSEL_SZ-1) downto 0);  -- Automatic slave select
    --
    uf       : std_ulogic;    -- Slave in underflow condition 
    ov       : std_ulogic;    -- Receive overflow condition 
    td_occ   : std_ulogic;    -- Transmit register occupied
    rd_free  : std_ulogic;    -- Receive register free (empty)
    txfifo   : spi_fifo;      -- Transmit data FIFO
    rxfifo   : spi_fifo;      -- Receive data FIFO
    rxd      : std_logic_vector(wlen downto 0);  -- Shift register
    toggle   : std_ulogic;    -- SCK has toggled 
    samp     : std_ulogic;    -- Sample
    chng     : std_ulogic;    -- Change
    psck     : std_ulogic;    -- Previous value of SC
    twdir    : std_ulogic;    -- Direction in 3-wire mode
    syncsamp : std_logic_vector(1 downto 0);    -- Sample synchronized input
    incrdli  : std_ulogic;
    rxdone   : std_ulogic;
    running  : std_ulogic;
    -- counters
    tfreecnt : integer range 0 to FIFO_DEPTH; -- free td fifo slots
    rfreecnt : integer range 0 to FIFO_DEPTH; -- free td fifo slots
    tdfi     : integer range 0 to (FIFO_DEPTH-1);  -- First tx queue element
    rdfi     : integer range 0 to (FIFO_DEPTH-1);  -- First rx queue element
    tdli     : integer range 0 to (FIFO_DEPTH-1);  -- Last tx queue element
    rdli     : integer range 0 to (FIFO_DEPTH-1);  -- Last rx queue element
    rbitcnt  : integer range 0 to wlen;  -- Current receive bit
    tbitcnt  : integer range 0 to wlen;  -- Current transmit bit
    divcnt   : unsigned(9 downto 0);   -- Clock scaler
    cgcnt    : unsigned(5 downto 0);   -- Clock gap counter
    aselcnt  : unsigned(1 downto 0);   -- ASEL delay
    cgasel   : std_ulogic;             -- ASEL when entering CG
    --
    irq      :  std_ulogic;
    -- Automode
    am       : spi_am_rec;
    -- Sync registers for inputs
    spii     : spi_in_array;
    -- Output
    spio     : spi_out_type;
 end record;

  -----------------------------------------------------------------------------
  -- Sub programs
  -----------------------------------------------------------------------------
  -- Returns a vector containing the character length - 1 in bits as selected
  -- by the Mode field LEN. 
  function spilen (
    len : std_logic_vector(3 downto 0))
    return std_logic_vector is
  begin  -- spilen
    if len = zero32(3 downto 0) then
      return "11111";
    else
      return "0" & len;
    end if;
  end spilen;
  
  -- Write clear
  procedure wc (
    reg_o : out std_ulogic;
    reg_i : in  std_ulogic;
    b     : in  std_ulogic) is
  begin
    reg_o := reg_i and not b;
  end procedure wc;

  -- Reverses string. After this function has been called the first bit
  -- to send is always at position 0.
  function reverse(
    data : std_logic_vector)
    return std_logic_vector is
    variable rdata: std_logic_vector(data'reverse_range);
  begin
    for i in data'range loop
      rdata(i) := data(i);
    end loop;
    return rdata; 
  end function reverse;

  -- Performs a HWORD swap if len /= 0
  function condhwordswap (
    data : std_logic_vector(31 downto 0);
    len  : std_logic_vector(4 downto 0))
    return std_logic_vector is
    variable rdata : std_logic_vector(31 downto 0);
  begin  -- condhwordswap
    if len = one32(4 downto 0) then
      rdata := data;
    else
      rdata := data(15 downto 0) & data(31 downto 16);
    end if;
    return rdata;
  end condhwordswap;

  -- Zeroes out unused part of receive vector.
  function select_data (
    data : std_logic_vector(wlen downto 0);
    len  : std_logic_vector(4 downto 0))
    return std_logic_vector is
    variable rdata : std_logic_vector(31 downto 0) := (others => '0');
    variable length : integer range 0 to 31 := conv_integer(len);
    variable sdata : std_logic_vector(31 downto 0) := (others => '0');
  begin  -- select_data
    -- Quartus can not handle variable ranges
    -- rdata(conv_integer(len) downto 0) := data(conv_integer(len) downto 0);
    sdata := (others => '0'); sdata(wlen downto 0) := data;
    
    case length is
      when 31 => rdata := sdata;
      when 30 => rdata(30 downto 0) := sdata(30 downto 0);
      when 29 => rdata(29 downto 0) := sdata(29 downto 0);
      when 28 => rdata(28 downto 0) := sdata(28 downto 0);
      when 27 => rdata(27 downto 0) := sdata(27 downto 0);
      when 26 => rdata(26 downto 0) := sdata(26 downto 0);
      when 25 => rdata(25 downto 0) := sdata(25 downto 0);
      when 24 => rdata(24 downto 0) := sdata(24 downto 0);
      when 23 => rdata(23 downto 0) := sdata(23 downto 0);
      when 22 => rdata(22 downto 0) := sdata(22 downto 0);
      when 21 => rdata(21 downto 0) := sdata(21 downto 0);
      when 20 => rdata(20 downto 0) := sdata(20 downto 0);
      when 19 => rdata(19 downto 0) := sdata(19 downto 0);
      when 18 => rdata(18 downto 0) := sdata(18 downto 0);
      when 17 => rdata(17 downto 0) := sdata(17 downto 0);
      when 16 => rdata(16 downto 0) := sdata(16 downto 0);
      when 15 => rdata(15 downto 0) := sdata(15 downto 0);
      when 14 => rdata(14 downto 0) := sdata(14 downto 0);
      when 13 => rdata(13 downto 0) := sdata(13 downto 0);
      when 12 => rdata(12 downto 0) := sdata(12 downto 0);
      when 11 => rdata(11 downto 0) := sdata(11 downto 0);
      when 10 => rdata(10 downto 0) := sdata(10 downto 0);
      when 9 => rdata(9 downto 0) := sdata(9 downto 0);
      when 8 => rdata(8 downto 0) := sdata(8 downto 0);
      when 7 => rdata(7 downto 0) := sdata(7 downto 0);
      when 6 => rdata(6 downto 0) := sdata(6 downto 0);
      when 5 => rdata(5 downto 0) := sdata(5 downto 0);
      when 4 => rdata(4 downto 0) := sdata(4 downto 0);
      when 3 => rdata(3 downto 0) := sdata(3 downto 0);
      when 2 => rdata(2 downto 0) := sdata(2 downto 0);
      when 1 => rdata(1 downto 0) := sdata(1 downto 0);
      when others => rdata(0) := sdata(0);
    end case;
    return rdata;
  end select_data;
    
   -- purpose: Returns true when a slave is selected and the clock starts
  function slv_start (
    signal spisel  : std_ulogic;
    signal cpol    : std_ulogic;
    signal sck     : std_ulogic;
    signal prevsck : std_ulogic)
    return boolean is
  begin  -- slv_start
    if spisel = '0' then          -- Slave is selected
      if (sck xor prevsck) = '1' then  -- The clock has changed
        return (cpol xor sck) = '1';    -- The clock is not idle 
      end if;
    end if;
    return false;
  end slv_start;
  
  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------
  
  signal r, rin : spi_reg_type;
  
begin

  -- SPI controller, register interface and related logic
  comb: process (r, rstn, apbi, spii)
    variable v       : spi_reg_type;
    variable irq     : std_logic_vector((NAHBIRQ-1) downto 0);
    variable apbaddr : std_logic_vector(7 downto 2);
    variable apbout  : std_logic_vector(31 downto 0);
    variable len     : std_logic_vector(4 downto 0);
    variable indata  : std_ulogic;
    variable change  : std_ulogic;
    variable update  : std_ulogic;
    variable sample  : std_ulogic;
    variable reload  : std_ulogic;
    variable cgasel  : std_ulogic;
    variable tindex  : integer range 0 to 31;
  begin  -- process comb
    v := r;  v.irq := '0'; irq := (others=>'0'); irq(pirq) := r.irq;
    apbaddr := apbi.paddr(7 downto 2); apbout := (others => '0');
    len := spilen(r.mode.len); v.toggle := '0'; tindex := r.tbitcnt;
    v.syncsamp := r.syncsamp(0) & '0'; update := '0'; v.rxdone := '0';
    indata := '0'; sample := '0'; change := '0'; reload := '0';
    v.spio.astart := '0'; cgasel := '0';
    
    if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
      case apbaddr is
        when CAP_ADDR =>
          apbout := SPICTRLCAPREG;
        when MODE_ADDR =>
          apbout := r.mode.amen & r.mode.loopb & r.mode.cpol & r.mode.cpha &
                    r.mode.div16 & r.mode.rev & r.mode.ms & r.mode.en &
                    r.mode.len & r.mode.pm & r.mode.tw & r.mode.asel &
                    r.mode.fact & r.mode.od & r.mode.cg & r.mode.aseldel &
                    r.mode.tac & zero32(3 downto 0);
        when EVENT_ADDR =>
          apbout := r.event.tip & zero32(30 downto 15) & r.event.lt &
                    zero32(13) & r.event.ov & r.event.un & r.event.mme &
                    r.event.ne & r.event.nf & zero32(7 downto 0);
        when MASK_ADDR =>
          apbout := r.mask.tip & zero32(30 downto 15) & r.mask.lt &
                    zero32(13) & r.mask.ov & r.mask.un & r.mask.mme &
                    r.mask.ne & r.mask.nf & zero32(7 downto 0);
        when RD_ADDR  =>
          apbout := condhwordswap(r.rd, len);
          v.rd_free := '1';
          if AM_EN = 1 then v.am.lock := '1'; end if;
        when SLVSEL_ADDR =>
         if SLVSEL_EN /= 0 then apbout((SLVSEL_SZ-1) downto 0) := r.slvsel;
         else null; end if;
        when ASEL_ADDR =>
         if ASEL_EN /= 0 then
           apbout((SLVSEL_SZ-1) downto 0) := r.aslvsel;
         else null; end if;
        when others => null;
      end case;
    end if;
    
    -- write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbaddr is
        when MODE_ADDR =>
          if AM_EN = 1 then v.mode.amen := apbi.pwdata(31); end if;
          v.mode.loopb := apbi.pwdata(30);
          v.mode.cpol  := apbi.pwdata(29);
          v.mode.cpha  := apbi.pwdata(28);
          v.mode.div16 := apbi.pwdata(27);
          v.mode.rev   := apbi.pwdata(26);
          v.mode.ms    := apbi.pwdata(25);
          v.mode.en    := apbi.pwdata(24);
          v.mode.len   := apbi.pwdata(23 downto 20);
          v.mode.pm    := apbi.pwdata(19 downto 16);
          if TW_EN = 1 then v.mode.tw := apbi.pwdata(15); end if;
          if ASEL_EN = 1 then v.mode.asel := apbi.pwdata(14); end if;          
          v.mode.fact  := apbi.pwdata(13);
          if OD_EN = 1 then v.mode.od := apbi.pwdata(12); end if;
          v.mode.cg    := apbi.pwdata(11 downto 7);
          if ASEL_EN = 1 then
            v.mode.aseldel := apbi.pwdata(6 downto 5);
            v.mode.tac     := apbi.pwdata(4);
          end if;
        when EVENT_ADDR =>
          wc(v.event.lt, r.event.lt, apbi.pwdata(14));
          wc(v.event.ov, r.event.ov, apbi.pwdata(12));
          wc(v.event.un, r.event.un, apbi.pwdata(11));
          wc(v.event.mme, r.event.mme, apbi.pwdata(10));
        when MASK_ADDR =>
          v.mask.tip := apbi.pwdata(31);
          v.mask.lt  := apbi.pwdata(14);
          v.mask.ov  := apbi.pwdata(12);
          v.mask.un  := apbi.pwdata(11);
          v.mask.mme := apbi.pwdata(10);
          v.mask.ne  := apbi.pwdata(9);
          v.mask.nf  := apbi.pwdata(8);
        when COM_ADDR =>
          v.lst := apbi.pwdata(22);
        when TD_ADDR =>
          -- The write is lost if the transmit register is written when
          -- the not full bit is zero.
          if r.event.nf = '1' then
            v.td := apbi.pwdata;
            v.td_occ := '1';
          end if;
        when SLVSEL_ADDR =>
          if SLVSEL_EN /= 0 then v.slvsel := apbi.pwdata((SLVSEL_SZ-1) downto 0);
          else null; end if;
        when ASEL_ADDR =>
          if ASEL_EN /= 0 then
            v.aslvsel := apbi.pwdata((SLVSEL_SZ-1) downto 0);
          else null; end if;
        when others => null;
      end case;
    end if;

    -- Automode register interface
    if AM_EN /= 0 then
      if (apbi.psel(pindex) and apbi.penable) = '1' then
        case apbaddr is
          when AMCFG_ADDR =>
            apbout := zero32(31 downto 6) & r.am.cfg.seq & r.am.cfg.strict &
                      r.am.cfg.ovtb & r.am.cfg.ovdb &
                      r.am.active & r.am.cfg.eact;
            if apbi.pwrite = '1' then
              v.am.cfg.seq  := apbi.pwdata(5);
              v.am.cfg.strict := apbi.pwdata(4);
              v.am.cfg.ovtb := apbi.pwdata(3);
              v.am.cfg.ovdb := apbi.pwdata(2);
              v.am.cfg.act  := apbi.pwdata(1);
              v.spio.astart := apbi.pwdata(1);
              v.am.cfg.eact := apbi.pwdata(0);
            end if;
          when AMPER_ADDR =>
            apbout((AM_CNT_BITS-1)*AM_EN downto 0) := r.am.per;
            if apbi.pwrite = '1' then
              v.am.per := apbi.pwdata((AM_CNT_BITS-1)*AM_EN downto 0);
            end if;
          when others => null;
        end case;
      end if;
    end if;
    
    -- Handle transmit FIFO
    if r.td_occ = '1' and r.tfreecnt /= 0 then
      if r.mode.rev = '0' then
        v.txfifo(r.tdli) := r.td(wlen downto 0);
      else
        v.txfifo(r.tdli) := reverse(r.td)(31-wlen to 31);
      end if;
      v.tdli := (r.tdli + 1) mod FIFO_DEPTH;
      v.tfreecnt := r.tfreecnt - 1;
      v.td_occ := '0';
    end if;
    
    -- Update receive register and FIFO
    if r.rd_free = '1' and r.rfreecnt /= FIFO_DEPTH then
      if r.mode.rev = '0' then
        v.rd := reverse(select_data(r.rxfifo(r.rdfi), len));
      else
        v.rd := select_data(r.rxfifo(r.rdfi), len);
      end if;
      v.rdfi := (r.rdfi + 1) mod FIFO_DEPTH;
      v.rfreecnt := r.rfreecnt + 1;
      v.rd_free := '0';
    end if;
    
    if r.mode.en = '1' then             -- Core is enabled
      -- Not full detection
      if r.tfreecnt /= 0 or r.td_occ /= '1' then
        v.event.nf := '1';
        if (r.mask.nf and not r.event.nf) = '1' then
          v.irq := '1';
        end if;
      else
        v.event.nf := '0';
      end if;
      
      -- Not empty detection
      if r.rfreecnt /= FIFO_DEPTH or r.rd_free /= '1' then
        v.event.ne := '1';
        if (r.mask.ne and not r.event.ne) = '1' then
          v.irq := '1';
        end if;
      else
        v.event.ne := '0';
        if AM_EN = 1 then v.am.lock := '0'; end if;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Automated periodic transfer control
    ---------------------------------------------------------------------------
    if AM_EN = 1 and r.mode.amen = '1' then
      if r.am.active = '0' then
        -- Activation either from register write or external event.
        v.am.active := r.spio.astart or (spii.astart and r.am.cfg.eact);
        v.am.cfg.act := v.am.active;
        v.am.rfreecnt := FIFO_DEPTH;
        v.am.tfreecnt := r.tfreecnt;
        if v.am.active = '1' then
          v.tfreecnt := FIFO_DEPTH;
        end if;
        v.am.skipdata := '0'; v.am.rxfull := '0';
        v.am.cnt := unsigned(r.am.per);
      else
        -- Receive fifo handling
        if r.am.rxfull = '1' then           -- AM RX fifo is filled
          -- Move to receive queue if the queue is empty or if there is no
          -- requirement on sequential transfers and the queue is not locked.
          if (r.event.ne and (v.am.lock or r.am.cfg.seq)) = '0' then 
            -- Queue is empty
            v.rxfifo := r.am.rxfifo;
            v.rdfi := 0;
            v.rfreecnt := r.am.rfreecnt;
            v.rd_free := '1';           -- Reload receive register
            v.am.rxfull := '0';
          end if;
        end if;
        if r.am.cfg.act = '0' then v.am.active := r.running; end if;
        v.am.cfg.eact := '0';
        if r.am.cnt = 0 then
          -- Only allowed to start new transfer if previous transfer(s) is finished
          if r.event.tip = '0' then
            if (not v.am.rxfull or r.am.cfg.strict) = '1' then
              v.am.cnt := unsigned(r.am.per);
            end if;
            if (not v.am.rxfull or (r.am.cfg.strict and not r.am.cfg.ovtb)) = '1' then
              -- Start transfer. Initialize indexes and fifo counter
              v.am.cnt := unsigned(r.am.per);
              v.tdfi := 0;
              v.rdli := 0;
              v.tfreecnt := r.am.tfreecnt;
              -- Skip incoming data if receive FIFO is full and OVDB is '1'.
              v.am.skipdata := v.am.rxfull and r.am.cfg.ovdb;
              if v.am.skipdata = '0' then
                -- Clear AM receive fifo if we will overwrite it.
                v.am.rfreecnt := FIFO_DEPTH;
                v.am.rxfull := '0';
              end if;
            end if;
          end if;
        else
          v.am.cnt := r.am.cnt - 1;
        end if;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- SPI bus control
    ---------------------------------------------------------------------------
    if (r.mode.en and not r.running) = '1' then
      if r.mode.ms = '1' then
        if r.divcnt = 0 then
          v.spio.sck := r.mode.cpol;
        end if;
        v.spio.misooen := INPUT;
        if TW_EN = 0 or r.mode.tw = '0' then
          if OD_EN = 0 or r.mode.od = '0' then
            v.spio.mosioen := OUTPUT;
          end if;
        else
          v.spio.mosioen := INPUT;
        end if;
        v.spio.sckoen := OUTPUT; 
        v.twdir := OUTPUT;
      else
        if (r.spii(1).spisel or r.mode.tw) = '0' then
          v.spio.misooen := OUTPUT;
        else
          v.spio.misooen := INPUT;
        end if;
        v.spio.mosioen := INPUT; 
        v.spio.sckoen := INPUT;
        v.twdir := INPUT;
      end if;
      if ((((AM_EN = 0 or r.mode.amen = '0') or
            (AM_EN = 1 and r.mode.amen = '1' and r.am.active = '1')) and
           r.mode.ms = '1' and r.tfreecnt /= FIFO_DEPTH) or 
          slv_start(r.spii(1).spisel, r.mode.cpol, r.spii(1).sck, r.psck)) then
        -- Slave underrun detection
        if r.tfreecnt = FIFO_DEPTH then
          v.uf := '1';
          if (r.mask.un and not v.event.un) = '1' then
            v.irq := '1';
          end if;
          v.event.un := '1';
        end if;
        v.running := '1';
        if r.mode.ms = '1' then
          v.spio.mosioen := OUTPUT;
          change := not r.mode.cpha;
          -- Insert cycles when cpha = '0' to ensure proper setup
          -- time for first MOSI value in master mode.
          reload := not r.mode.cpha;
        end if;
      end if;
      v.cgcnt := (others => '0');
      v.rbitcnt := 0; v.tbitcnt := 0;
      if r.mode.ms = '0' then
        update := not (r.mode.cpha or (r.spii(1).sck xor r.mode.cpol));
        if r.mode.cpha = '0' then v.tbitcnt := 1; end if;
        tindex := 0;
      end if;
      
      -- samp and chng should not be changed on b2b
      if r.spii(1).spisel /= '0' then
        v.samp := not r.mode.cpha;
        v.chng := r.mode.cpha;
        v.psck := r.mode.cpol;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Clock generation, only in master mode
    ---------------------------------------------------------------------------
    if r.mode.ms = '1' and (r.running = '1' or r.divcnt /= 0) then
      -- The frequency of the SPI clock relative to the system clock is
      -- determined by the fact, div16 and pm register fields.
      --
      -- With fact = 0 the fields have the same meaning as in the MPC83xx
      -- register interface. The clock is divided by 4*([PM]+1) and if div16
      -- is set the clock is divided by 16*(4*([PM]+1)).
      --
      -- With fact = 1 the core's register i/f is no longer compatible with
      -- the MPC83xx register interface. The clock is divided by 2*([PM]+1) and
      -- if div16 is set the clock is divided by 16*(2*([PM]+1)).
      --
      -- The generated clock's duty cycle is always 50%.
      -- 
      if r.divcnt = 0 then
        -- Do not toggle if in automatic slave select delay slot
        if ASEL_EN = 0 or r.aselcnt = 0 then
          -- Toggle SCK unless we are in a clock gap
          if r.cgcnt = 0 or r.spio.sck /= r.mode.cpol then
            v.spio.sck := not r.spio.sck;
            v.toggle := r.running;
          end if;
          if r.cgcnt /= 0 then
            v.cgcnt := r.cgcnt - 1;
            if ASEL_EN /= 0 and r.cgcnt = 1 then
              cgasel := r.mode.tac;
            end if;
          end if;
        elsif ASEL_EN = 1 then
          v.aselcnt := r.aselcnt - 1;
        end if;
        reload := '1';
      else
        v.divcnt := r.divcnt - 1;
      end if;
    else
      v.divcnt := (others => '0');
    end if;

    if reload = '1' then
      -- Reload clock scale counter
      v.divcnt(4 downto 0) := unsigned('0' & r.mode.pm) + 1;
      if r.mode.fact = '0' then
        if r.mode.div16 = '1' then
          v.divcnt := shift_left(v.divcnt, 5) - 1;
        else
          v.divcnt := shift_left(v.divcnt, 1) - 1;
        end if;
      else
        if r.mode.div16 = '1' then
          v.divcnt := shift_left(v.divcnt, 4) - 1;
        else
          v.divcnt(9 downto 4) := (others => '0');
          v.divcnt(3 downto 0) := unsigned(r.mode.pm);
        end if;
      end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- Handle master operation.
    ---------------------------------------------------------------------------
    if r.mode.ms = '1' then
      -- Sample data
      if r.toggle = '1' then
        v.samp := not r.samp;
        sample := r.samp;
      end if;

      -- Change data on the clock flank...
      if v.toggle  = '1' then
        v.chng := not r.chng;
        change := r.chng;
      end if;
      
      -- Detect multiple-master errors (mode-fault)
      if r.spii(1).spisel = '0' then
        v.mode.en := '0';
        v.mode.ms := '0';
        v.event.mme := '1';
        if (r.mask.mme and not r.event.mme) = '1' then
          v.irq := '1';
        end if;
        v.running := '0';
        v.event.tip := '0';
      end if;

      -- Select input data
      if r.mode.loopb = '1' then
        indata := r.spio.mosi;
      elsif TW_EN = 1 and r.mode.tw = '1' then
        indata := r.spii(1).mosi;
      else
        indata := r.spii(1).miso;
      end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- Handle slave operation
    ---------------------------------------------------------------------------
    if (r.mode.en and not r.mode.ms) = '1' then
      if r.spii(1).spisel = '0' then
        v.psck := r.spii(1).sck;
        if (r.psck xor r.spii(1).sck) = '1' then
          sample := r.samp; v.samp := not r.samp;
          change := r.chng; v.chng := not r.chng;
        end if;
        indata := r.spii(1).mosi;
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- Used in both master and slave operation
    ---------------------------------------------------------------------------
    if sample = '1' then
      -- Detect receive overflow
      if (r.rfreecnt = 0 and r.rd_free = '0') or r.ov = '1' then
        if TW_EN = 0 or r.mode.tw = '0' or r.twdir = INPUT then
          -- Overflow event and IRQ
          v.ov := '1';
          if r.ov = '0' then
            if (r.mask.ov and not r.event.ov) = '1' then
              v.irq := '1';
            end if;
            v.event.ov := '1';
          end if;
        end if;
        sample := '0';                  -- Prevent sample below
      else
        sample := not r.mode.ms or r.mode.loopb;
        v.syncsamp(0) := not sample;
      end if;
      if r.rbitcnt = conv_integer(len) then  
        v.rbitcnt := 0;
--        if r.mode.ms = '1' then
        if TW_EN = 1 then
          v.twdir := r.twdir xor not r.mode.loopb;
        end if;
--        end if;
        if (TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or
            (r.mode.tw = '1' and r.twdir = INPUT)) then
          v.incrdli := not r.ov;
        end if;
        if (TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or
            (TW_EN = 1 and r.mode.tw = '1' and
             ((r.mode.ms = '1' and r.twdir = INPUT) or
              (r.mode.ms = '0' and r.twdir = OUTPUT)))) then
          if r.mode.cpha = '0' then
            v.cgcnt := unsigned(r.mode.cg & '0');
            if ASEL_EN /= 0 then v.cgasel := r.mode.tac; end if;
          end if;
          v.ov := '0';
          if v.tfreecnt = FIFO_DEPTH then
            v.running := '0';
          end if;
          v.uf := '0';
        end if;
      else
        v.rbitcnt := r.rbitcnt + 1;
      end if;      
    end if;

    -- Sample data line and put into shift register.
    if (r.syncsamp(1) or sample) = '1' then
      v.rxd := r.rxd(wlen-1 downto 0) & indata;
      if ((r.syncsamp(1) and r.incrdli) or (sample and v.incrdli)) = '1' then
        v.rxdone := '1';
        v.incrdli := '0';
      end if;
    end if;

    -- Put data into receive queue
    if ((AM_EN = 0 or (r.mode.amen and r.am.skipdata) = '0') and
        r.rxdone = '1') then
      v.rdli := (r.rdli + 1) mod FIFO_DEPTH;
      if AM_EN = 1 and r.am.active = '1'then
        v.am.rxfifo(r.rdli) := r.rxd;
        v.am.rfreecnt := v.am.rfreecnt - 1;
      else
        v.rxfifo(r.rdli) := r.rxd;
        v.rfreecnt := v.rfreecnt - 1;
      end if;
      if r.running = '0' then
        if AM_EN = 1 then v.am.rxfull := r.am.active; end if;
      end if;
    end if;

    -- Advance transmit queue
    if change = '1' then
      if TW_EN = 1 and r.mode.tw = '1' then
        if OD_EN = 0 or r.mode.od = '0' then
          v.spio.mosioen := r.twdir;
        elsif r.twdir = INPUT then
          v.spio.mosioen := INPUT;
        end if;
      end if;
      if r.tbitcnt = conv_integer(len) then
        if r.mode.cpha = '1' then
          v.cgcnt := unsigned(r.mode.cg & '0');
          if ASEL_EN /= 0 then v.cgasel := r.mode.tac; end if;
        end if;
--        if r.mode.ms = '0' then
--          v.twdir := r.twdir xor not r.mode.loopb;
--        end if;
        if ((TW_EN = 0 or r.mode.tw = '0' or r.mode.loopb = '1' or r.twdir = OUTPUT) and
            r.uf = '0') then
          v.tfreecnt := v.tfreecnt + 1;
          v.tdfi := (v.tdfi + 1) mod FIFO_DEPTH;
          if AM_EN = 0 or r.mode.amen = '0' then
            v.txfifo(r.tdfi)(0) := '1';
          end if;
        end if;
        v.tbitcnt := 0;
      else
        v.tbitcnt := r.tbitcnt + 1;
      end if;
    end if;

    -- Transmit bit
    if (change or update) = '1' then
      if v.uf = '0' then
        v.spio.miso := r.txfifo(r.tdfi)(tindex);
        v.spio.mosi := r.txfifo(r.tdfi)(tindex);
        if OD_EN = 1 and r.mode.od = '1' then
          if (r.mode.ms or r.mode.tw) = '1' then
            v.spio.mosioen := r.txfifo(r.tdfi)(tindex) xor OUTPUT;
          else
            v.spio.misooen := r.txfifo(r.tdfi)(tindex) xor OUTPUT;
          end if;
        end if;
      else
        v.spio.miso := '1';
        v.spio.mosi := '1';
        if OD_EN = 1 and r.mode.od = '1' then
          v.spio.misooen := INPUT;
          v.spio.mosioen := INPUT;
        end if;
      end if;
    end if;
    
    -- Transfer in progress interrupt generation
    if (not r.running and (r.rxdone or (not r.mode.ms and r.mode.tw))) = '1' then
      v.event.tip := '0';
    end if;
    if v.running = '1' then v.event.tip := '1'; end if;
    if (v.running and not r.event.tip and r.mask.tip and r.mode.en) = '1' then
      v.irq := '1';
    end if;

    -- LST detection and interrupt generation
    if v.running = '0' and v.tfreecnt = FIFO_DEPTH and r.lst = '1' then
      v.event.lt := '1'; v.lst := '0';
      if (r.mask.lt and not r.event.lt) = '1' then v.irq := '1'; end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- Automatic slave select, only in master mode
    ---------------------------------------------------------------------------
    if ASEL_EN /= 0 then
      if (r.mode.ms and r.mode.asel) = '1' then
        if ((not r.running and v.running) or  -- Transfer start or
            (r.event.tip and not v.event.tip) or  -- transfer end or
            (v.running and (cgasel or   -- End or start of CG
            (r.cgasel and not (r.spio.sck xor r.mode.cpol))))) = '1'
        then  
          v.slvsel := r.aslvsel;
          v.aslvsel := r.slvsel;
          v.cgasel := '0';
        end if;
        -- May need to delay start of transfer
        if ((not r.running and v.running) or cgasel) = '1' then  -- Transfer start
          v.aselcnt := unsigned(r.mode.aseldel);
        end if;
      else
        v.cgasel := '0';
        v.aselcnt := (others => '0');
      end if;
    end if;
    
    -- Do not toggle outputs in loopback mode
    if (r.mode.loopb = '1' or
        (r.mode.tw = '1' and TW_EN = 1 and r.twdir = INPUT)) then
      v.spio.mosioen := INPUT; v.spio.misooen := INPUT;
    end if;
    if r.mode.loopb = '1' then v.spio.sckoen  := INPUT; end if;
    
    -- When driving in OD mode, always drive low.
    if OD_EN = 1 and (r.mode.od and not r.mode.loopb) = '1' then
      v.spio.miso := v.spio.miso and not r.mode.od;
      v.spio.mosi := v.spio.mosi and not r.mode.od;
    end if;

    -- Core is disabled
    if r.mode.en = '0' then
      v.tfreecnt := FIFO_DEPTH;
      v.rfreecnt := FIFO_DEPTH;
      v.tdfi := 0; v.rdfi := 0;
      v.tdli := 0; v.rdli := 0;
      v.rd_free := '1';
      v.td_occ := '0';
      v.lst := '0';
      v.uf := '0';
      v.ov := '0';
      v.running := '0';
      v.event.tip := '0';
      v.incrdli := '0';
      if TW_EN = 1 then
        v.twdir := INPUT;
      end if;
      v.spio.miso := '1';
      v.spio.mosi := '1';
      v.spio.misooen := INPUT;
      v.spio.mosioen := INPUT;
      v.spio.sckoen  := INPUT;
      -- Need to assign samp, chng and psck here if spisel is low when the
      -- core is enabled
      v.samp := not r.mode.cpha;
      v.chng := r.mode.cpha;
      v.psck := r.mode.cpol;
      -- Set all first bits in txfifo to idle value
      for i in 0 to (FIFO_DEPTH-1) loop
        v.txfifo(i)(0) := '1';
      end loop;  -- i
      if AM_EN = 1 then
        v.am.active := '0';
        v.am.cfg.act := '0';
        v.am.cfg.eact := '0';
      end if;
    end if;

    -- Chip reset
    if rstn = '0' then
      v.mode := ('0','0','0','0','0','0','0','0',"0000","0000",
                 '0','0','0','0',"00000","00", '0');
      v.event := ('0','0','0','0','0','0','0');
      v.mask := ('0','0','0','0','0','0','0');
      v.lst := '0';
      v.slvsel := (others => '1');
    end if;

    -- SSN output is not used by this core
    v.spio.ssn := (others => '0');  
    
    -- Drive unused bit if open drain mode is not supported
    if OD_EN = 0 then v.mode.od := '0'; end if;

    -- Drive unused bits if automode is not supported
    if AM_EN = 0 then
      v.mode.amen := '0';
      --
      v.am.cfg := ('0','0','0','0','0','0');
      v.am.per := (others => '0');
      v.am.active := '0';
      v.am.lock := '0';
      v.am.cnt := (others => '0');
      v.am.skipdata := '0';
      v.am.rxfull := '0';
      for i in 0 to (FIFO_DEPTH-1) loop
        v.am.rxfifo(i) := (others => '0');
      end loop;  -- i
      v.am.rfreecnt := 0;
      v.am.tfreecnt := 0;
    end if;

    -- Drive unused bits if automatic slave select is not enabled
    if ASEL_EN = 0 then
      v.mode.asel := '0';
      v.aslvsel := (others => '0');
      v.mode.aseldel := (others => '0');
      v.mode.tac := '0';
      v.aselcnt := (others => '0');
      v.cgasel := '0';
    end if;

    -- Drive unused bits if three-wire mode is not enabled
    if TW_EN = 0 then
      v.mode.tw := '0';
      v.twdir := INPUT;
    end if;
    
    -- Propagate core enable bit
    v.spio.enable := r.mode.en;
    
    -- Synchronize inputs coming from off-chip
    v.spii(0) := (spii.miso, spii.mosi, spii.sck, spii.spisel);
    v.spii(1) := r.spii(0);
    
    -- Update registers
    rin <= v;

    -- Update outputs
    apbo.prdata <= apbout;
    apbo.pirq <= irq;
    apbo.pconfig <= PCONFIG;
    apbo.pindex <= pindex;
        
    slvsel <= r.slvsel;
    
    spio <= r.spio;
    
  end process comb;

  reg: process (clk)
  begin  -- process reg
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process reg;

  -- Boot message
  -- pragma translate_off
  bootmsg : report_version 
    generic map (
      "spictrl" & tost(pindex) & ": SPI controller rev " &
      tost(SPICTRL_REV) & ", irq " & tost(pirq));
  -- pragma translate_on
  
end architecture rtl;
