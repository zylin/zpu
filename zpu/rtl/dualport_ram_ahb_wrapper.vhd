
library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library hzdr;
use hzdr.devices_hzdr.all;


entity dualport_ram_ahb_wrapper is
    generic (
        hindex  : integer := 0;
        haddr   : integer := 0;
        hmask   : integer := 16#fff#
    );
    port (
        clk    : in std_ulogic;
        reset  : in std_ulogic;
        -- ahb
        ahbsi   : in  ahb_slv_in_type;
        ahbso   : out ahb_slv_out_type
    );
end entity dualport_ram_ahb_wrapper;



library ieee;
use ieee.std_logic_1164;

library zpu;
use zpu.zpu_config.all;
use zpu.zpupkg.all; -- wordsize
use zpu.zpupkg.dualport_ram;


architecture rtl of dualport_ram_ahb_wrapper is

    constant hconfig : ahb_config_type := (
        0 => ahb_device_reg ( VENDOR_HZDR, HZDR_ZPU_MEM_WRAPPER, 0, maxAddrBitBRAM+2, 0),
        4 => ahb_membar(haddr, '1', '1', hmask),
        others => zero32);

    type reg_t is record
        hwrite : std_ulogic;
        hready : std_ulogic;
        hsel   : std_ulogic;
        we     : std_ulogic;
        addr   : std_logic_vector(maxAddrBitBRAM downto minAddrBit);
        haddr  : std_logic_vector(maxAddrBitBRAM downto minAddrBit);
        data   : std_logic_vector(wordSize-1 downto 0);
    end record;
    constant default_reg_c : reg_t := (
        hwrite  => '0',
        hready  => '0',
        hsel    => '0',
        we      => '0',
        addr    => (others => '0'),
        haddr   => (others => '0'),
        data    => (others => '0')
    );

    type src_t is record
        data   : std_logic_vector(wordSize-1 downto 0);
    end record;

    signal r, r_in : reg_t;
    signal s       : src_t;
    signal we      : std_logic;
    signal addr    : std_logic_vector(maxAddrBitBRAM downto minAddrBit);

begin
  
  dualport_ram_i0: dualport_ram
    port map (
      clk             => clk,              -- : in  std_logic;
      memAWriteEnable => we,               -- : in  std_logic;
      memAAddr        => addr,             -- : in  std_logic_vector(maxAddrBitBRAM downto minAddrBit);
      memAWrite       => ahbsi.hwdata,     -- : in  std_logic_vector(wordSize-1 downto 0);
      memARead        => s.data,           -- : out std_logic_vector(wordSize-1 downto 0);
      memBWriteEnable => '0',              -- : in  std_logic;
      memBAddr        => (others => '0'),  -- : in  std_logic_vector(maxAddrBitBRAM downto minAddrBit);
      memBWrite       => (others => '0'),  -- : in  std_logic_vector(wordSize-1 downto 0);
      memBRead        => open              -- : out std_logic_vector(wordSize-1 downto 0)
      );

    comb: process(ahbsi, r, s)
        variable v: reg_t;
    begin
        v            := r;
        ahbso.hready <= v.hready;

        v.hready     := '1';
        v.we         := '0';

        if (r.hwrite or not r.hready) = '1' then
            v.haddr  := v.addr;
        else
            v.haddr  := ahbsi.haddr(maxAddrBitBRAM downto minAddrBit);
        end if;
                     
        if ahbsi.hready = '1' then -- react only when bus is ready
            v.hsel   := ahbsi.hsel( hindex) and ahbsi.htrans(1);
            v.hwrite := ahbsi.hwrite and v.hsel;
            v.addr   := ahbsi.haddr(maxAddrBitBRAM downto minAddrBit);
        end if;

        if r.hwrite = '1' then
            v.we     := '1';
            v.hready := not (v.hsel and not ahbsi.hwrite);
            v.hwrite := v.hwrite and v.hready;
        end if;

        v.data       := ahbsi.hwdata;
        
        ahbso.hrdata <= s.data;
        if is_x( v.haddr) then
            addr     <= (others => '0');
        else
            addr     <= v.haddr;
        end if;
        we           <= v.we;
        r_in         <= v;
    end process;

    seq: process
    begin
        wait until rising_edge( clk);
        r <= r_in;
        if reset = '1' then
            r <= default_reg_c;
        end if;
    end process;
  
    ahbso.hresp   <= "00"; 
    ahbso.hsplit  <= (others => '0'); 
    ahbso.hirq    <= (others => '0');
    ahbso.hcache  <= '1';
    ahbso.hconfig <= hconfig;
    ahbso.hindex  <= hindex;

    -- pragma translate_off
    bootmsg : report_version 
      generic map ("zpumem" & tost(hindex) &
        ": ZPU Memory AHB Wrapper, " & tost((2**(maxAddrBitBRAM + 1))/1024 ) & " kbytes addressable (" & tost( bram_words) & " words)");
    -- pragma translate_on

end architecture rtl;
