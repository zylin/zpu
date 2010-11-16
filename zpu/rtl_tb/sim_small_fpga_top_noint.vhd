-- ZPU
--
-- Copyright 2004-2008 oharboe - Øyvind Harboe - oyvind.harboe@zylin.com
-- 
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library zpu;
use zpu.zpu_config.all;
use zpu.zpupkg.all;

entity fpga_top is
end fpga_top;


architecture behave of fpga_top is


  signal clk   : std_ulogic;
  signal reset : std_ulogic := '1';


  component zpu_io is
    generic (
      log_file : string := "log.txt"
      );
    port(
      clk         : in  std_ulogic;
      reset       : in  std_ulogic;
      --
      busy        : out std_ulogic;
      writeEnable : in  std_ulogic;
      readEnable  : in  std_ulogic;
      write       : in  std_ulogic_vector(wordSize-1 downto 0);
      read        : out std_ulogic_vector(wordSize-1 downto 0);
      addr        : in  std_ulogic_vector(maxAddrBit downto minAddrBit)
      );
  end component;


  signal mem_busy             : std_ulogic;
  signal mem_read             : std_ulogic_vector(wordSize-1 downto 0);
  signal mem_write            : std_ulogic_vector(wordSize-1 downto 0);
  signal mem_addr             : std_ulogic_vector(maxAddrBitIncIO downto 0);
  signal mem_writeEnable      : std_ulogic;
  signal mem_readEnable       : std_ulogic;
  signal mem_writeMask        : std_ulogic_vector(wordBytes-1 downto 0);
  --
  signal dram_mem_busy        : std_ulogic;
  signal dram_mem_read        : std_ulogic_vector(wordSize-1 downto 0);
  signal dram_mem_write       : std_ulogic_vector(wordSize-1 downto 0);
  signal dram_mem_writeEnable : std_ulogic;
  signal dram_mem_readEnable  : std_ulogic;
  signal dram_mem_writeMask   : std_ulogic_vector(wordBytes-1 downto 0);
  --
  --
  signal io_busy              : std_ulogic;
  --
  signal io_mem_read          : std_ulogic_vector(wordSize-1 downto 0);
  signal io_mem_writeEnable   : std_ulogic;
  signal io_mem_readEnable    : std_ulogic;
  --
  --
  signal dram_ready           : std_ulogic;
  signal io_ready             : std_ulogic;
  signal io_reading           : std_ulogic;
  --
  --
  signal break                : std_ulogic;


begin

  zpu : zpu_core port map (
    clk                 => clk ,
    reset               => reset,
    in_mem_busy         => mem_busy,
    mem_read            => mem_read,
    mem_write           => mem_write,
    out_mem_addr        => mem_addr,
    out_mem_writeEnable => mem_writeEnable,
    out_mem_readEnable  => mem_readEnable,
    mem_writeMask       => mem_writeMask,
    interrupt           => '0',
    break               => break
);


  ioMap : zpu_io port map (
    clk         => clk,
    reset       => reset,
    busy        => io_busy,
    writeEnable => io_mem_writeEnable,
    readEnable  => io_mem_readEnable,
    write       => mem_write,
    read        => io_mem_read,
    addr        => mem_addr(maxAddrBit downto minAddrBit)
    );

  dram_mem_writeEnable <= mem_writeEnable and not mem_addr(ioBit);
  dram_mem_readEnable  <= mem_readEnable and not mem_addr(ioBit);
  io_mem_writeEnable   <= mem_writeEnable and mem_addr(ioBit);
  io_mem_readEnable    <= mem_readEnable and mem_addr(ioBit);
  mem_busy             <= io_busy;



  -- Memory reads either come from IO or DRAM. We need to pick the right one.
  memorycontrol :  process(dram_mem_read, dram_ready, io_ready, io_mem_read)
  begin
    mem_read <= (others => 'U');
    if dram_ready = '1' then
      mem_read <= dram_mem_read;
    end if;

    if io_ready = '1' then
      mem_read <= (others => '0');
      mem_read <= io_mem_read;
    end if;
  end process;



  io_ready <= (io_reading or io_mem_readEnable) and not io_busy;

  memoryControlSync :  process
  begin
    wait until rising_edge(clk);
    io_reading <= io_busy or io_mem_readEnable;
    dram_ready <= dram_mem_readEnable;

    if reset = '1' then
      io_reading <= '0';
      dram_ready <= '0';
    end if;

  end process;

  -- wiggle the clock @ 100MHz
  clock : process
  begin
    clk   <= '0';
    wait for 5 ns;
    clk   <= '1';
    wait for 5 ns;
    reset <= '0';
  end process clock;


end behave;
