library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

library work;
use work.zpu_config.all;
use work.zpupkg.all;
use work.txt_util.all;

entity zpu_io is
  generic
    (
      log_file : string := "log.txt"
      );
  port
    (
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
end zpu_io;


architecture behave of zpu_io is



  signal timer_read : std_ulogic_vector(7 downto 0);
--signal timer_write : std_logic_vector(7 downto 0);
  signal timer_we   : std_ulogic;

  signal serving : std_logic;

  file l_file          : text open write_mode is log_file;
  constant lowAddrBits : std_ulogic_vector(minAddrBit-1 downto 0) := (others => '0');
  constant tx_full     : std_ulogic                               := '0';
  constant rx_empty    : std_ulogic                               := '1';

begin

  
  timerinst : timer port map
    (
      clk   => clk,
      reset => reset,
      --
      we    => timer_we,
      din   => write(7 downto 0),
      adr   => addr(4 downto 2),
      dout  => timer_read
      );

  busy     <= writeEnable or readEnable;
  timer_we <= writeEnable and addr(12);

  process
    variable taddr         : std_ulogic_vector(maxAddrBit downto 0);
    variable outstr        : string(1 to 200);
    variable outstr_length : natural := 0;
  begin
    wait until rising_edge(clk);

    if (reset = '1') then
--                      timer_we <= '0';
      null;
    else
--                      timer_we <= '0';
      taddr                               := (others => '0');
      taddr(maxAddrBit downto minAddrBit) := addr;

      if writeEnable = '1' then
        -- external interface (fixed address)
        --<JK> extend compare to avoid waring messages
        if ("1" & addr & lowAddrBits) = x"080a000c" then
                                        --report "Write to UART[0]" & " :0x" & hstr(write);
                                        -- Write to UART
          --report "" & character'val(to_integer(unsigned(write))) severity note;
          -- collect to complete string until 0x0A
          outstr_length         := outstr_length + 1;
          outstr(outstr_length) := character'val(to_integer(unsigned(write)));
          if unsigned(write) = 10 then
            if outstr_length > 1 then
              report "UART[0]: " & outstr(1 to outstr_length-1) severity note;
            end if;
            outstr_length := 0;
          end if;
          --
          print(l_file, character'val(to_integer(unsigned(write))));
        elsif addr(12) = '1' then
          report "Write to TIMER" & " :0x" & hstr(write);
--                                  report "xxx" severity failure;
--                                      timer_we <= '1';
        else
          print(l_file, character'val(to_integer(unsigned(write))));
          report "Illegal IO write @" & "0x" & hstr(taddr) severity warning;
        end if;
        
      end if;
      read <= (others => '0');
      if (readEnable = '1') then
        --<JK> extend compare to avoid waring messages
        if ("1" & addr & lowAddrBits) = x"080a000c" then
                                             --report "Read UART[0]";
          read(8) <= not tx_full;            -- output fifo not full
          read(9) <= not rx_empty;           -- receiver not empty
        elsif ("1" & addr & lowAddrBits) = x"080a0010" then
          report "Read UART[1]";
          read(8)          <= not rx_empty;  -- receiver not empty
          read(7 downto 0) <= (others => '0');
        elsif addr(12) = '1' then
          report "Read TIMER";
          read(7 downto 0) <= timer_read;
        elsif addr(11) = '1' then
          report "Read ZPU Freq";
          read(7 downto 0) <= ZPU_Frequency;
        else
          report "Illegal IO read @" & "0x" & hstr(taddr) severity warning;
        end if;
      end if;
    end if;
  end process;


end behave;

