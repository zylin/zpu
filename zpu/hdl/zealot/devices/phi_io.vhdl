------------------------------------------------------------------------------
----                                                                      ----
----  ZPU Phi I/O                                                         ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  ZPU is a 32 bits small stack cpu. This is the minimum I/O devices   ----
----  assumed by the libc. They are a timer and an UART.@p                ----
----  Important! this is currently a simulation only model, no UART       ----
----  provided and it unconditionally generates a log.                    ----
----  Important! not all peripherals implemented!                         ----
----  Important! The enable signals assumes this is mapped @ 0x80A00xx.   ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Øyvind Harboe, oyvind.harboe zylin.com                          ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2008 Øyvind Harboe <oyvind.harboe zylin.com>           ----
---- Copyright (c) 2008 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2008 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the BSD license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      ZPUPhiIO(Behave) (Entity and architecture)         ----
---- File name:        phi_io.vhdl                                        ----
---- Note:             None                                               ----
---- Limitations:      Only for simulation.                               ----
---- Errors:           None known                                         ----
---- Library:          zpu                                                ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   std.textio                                         ----
----                   zpu.zpupkg                                         ----
----                   zpu.txt_util                                       ----
---- Target FPGA:      Spartan 3 (XC3S1500-4-FG456)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  N/A                                                ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use std.textio.all;

library zpu;
use zpu.zpupkg.timer;
use zpu.zpupkg.gpio;
use zpu.UART.all;
use zpu.txt_util.all;
 
entity ZPUPhiIO is
   generic(
      BRDIVISOR : positive:=1;   -- Baud rate divisor i.e. br_clk/9600/4
      ENA_LOG   : boolean:=true; -- Enable log
      LOG_FILE  : string:="log.txt"); -- Name for the log file
   port(
      clk_i      : in  std_logic; -- System Clock
      reset_i    : in  std_logic; -- Synchronous Reset
      busy_o     : out std_logic; -- I/O is busy
      we_i       : in  std_logic; -- Write Enable
      re_i       : in  std_logic; -- Read Enable
      data_i     : in  unsigned(31 downto 0);
      data_o     : out unsigned(31 downto 0);
      addr_i     : in  unsigned(2  downto 0); -- Address bits 4-2
      --
      rs232_rx_i : in  std_logic;  -- UART Rx input
      rs232_tx_o : out std_logic;  -- UART Tx output
      br_clk_i   : in  std_logic;  -- UART base clock (enable)
      --
      gpio_in    : in  std_logic_vector(31 downto 0);
      gpio_out   : out std_logic_vector(31 downto 0);
      gpio_dir   : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
      );
end entity ZPUPhiIO;
   
   
architecture Behave of ZPUPhiIO is
   constant LOW_BITS  : unsigned(1 downto 0):=(others=>'0');
   constant TX_FULL   : std_logic:='0';
   constant RX_EMPTY  : std_logic:='1';

   -- "000" 0x00 is CPU enable ... useful?
   constant IO_DATA   : unsigned(2 downto 0):="001"; -- 0x04
   constant IO_DIR    : unsigned(2 downto 0):="010"; -- 0x08
   constant UART_TX   : unsigned(2 downto 0):="011"; -- 0x0C
   constant UART_RX   : unsigned(2 downto 0):="100"; -- 0x10
   constant CNT_1     : unsigned(2 downto 0):="101"; -- 0x14
   constant CNT_2     : unsigned(2 downto 0):="110"; -- 0x18
   -- "111" 0x1C Unused
   -- Unimplemented: Interrupt control and timer (not counter ...?)

   signal timer_read : unsigned(31 downto 0);
   signal timer_we   : std_logic;
   signal is_timer   : std_logic;

   -- UART
   -- Rx
   signal rx_br      : std_logic; -- Rx timing
   signal uart_read  : std_logic; -- ZPU read the value
   signal rx_avail   : std_logic; -- Rx data available
   signal rx_data    : std_logic_vector(7 downto 0); -- Rx data
   -- Tx
   signal tx_br      : std_logic; -- Tx timing
   signal uart_write : std_logic; -- ZPU is writing
   signal tx_busy    : std_logic; -- Tx can't get a new value

   -- GPIO
   signal gpio_we    : std_logic;
   signal is_gpio    : std_logic;
   signal gpio_read  : unsigned(31 downto 0);

   file l_file       : text open write_mode is LOG_FILE;

begin
   -----------
   -- Timer --
   -----------
   timerinst: Timer
      port map(
         clk_i => clk_i, reset_i => reset_i, we_i => timer_we,
         data_i => data_i, addr_i => addr_i(1 downto 1),
         data_o => timer_read);
   
   busy_o   <= we_i or re_i;
   is_timer <= '1' when to_01(addr_i)=CNT_1 or to_01(addr_i)=CNT_2 else '0'; -- 0x80A0014/8
   timer_we <= we_i and is_timer;

   ----------
   -- UART --
   ----------
   -- Rx section
   rx_core : RxUnit
      port map(
         clk_i => clk_i, reset_i => reset_i, enable_i => rx_br,
         read_i => uart_read, rxd_i => rs232_rx_i, rxav_o => rx_avail,
         datao_o => rx_data);
   uart_read <= '1' when re_i='1' and addr_i=UART_RX else '0';

   -- Tx section
   tx_core : TxUnit
      port map(
         clk_i => clk_i, reset_i => reset_i, enable_i => tx_br,
         load_i => uart_write, txd_o => rs232_tx_o, busy_o => tx_busy,
         datai_i => std_logic_vector(data_i(7 downto 0)));
   uart_write <= '1' when we_i='1' and addr_i=UART_TX else '0';

   -- Rx timing
   rx_timer : BRGen
      generic map(COUNT => BRDIVISOR)
      port map(
         clk_i => clk_i, reset_i => reset_i, ce_i => br_clk_i, o_o => rx_br);

   -- Tx timing
   tx_timer : BRGen -- 4 Divider for Tx
      generic map(COUNT => 4)  
      port map(
         clk_i => clk_i, reset_i => reset_i, ce_i => rx_br, o_o => tx_br);
   
   ----------
   -- GPIO --
   ----------
   gpio_i0: gpio
      port map(
          clk_i    => clk_i,              -- : in  std_logic;
          reset_i  => reset_i,            -- : in  std_logic;
          --                              
          we_i     => gpio_we,            -- : in  std_logic;
          data_i   => data_i,             -- : in  unsigned(31 downto 0);
          addr_i   => addr_i(1 downto 1), -- : in  unsigned( 0 downto 0);
          data_o   => gpio_read,          -- : out unsigned(31 downto 0);
          --                              
          port_in  => gpio_in,            -- : std_logic_vector(31 downto 0);
          port_out => gpio_out,           -- : std_logic_vector(31 downto 0);
          port_dir => gpio_dir            -- : std_logic_vector(31 downto 0);
          );
   is_gpio <= '1' when to_01(addr_i) = IO_DATA or to_01(addr_i) = IO_DIR else '0'; -- 0x80A0004/8
   gpio_we <= we_i and is_gpio;


   do_io:
   process(clk_i)
        --synopsys translate off
        variable line_out : line := new string'("");
        variable char     : character;
        --synopsys translate on
   begin
      if rising_edge(clk_i) then
         if reset_i/='1' then
            --synopsys translate off
            if we_i='1' then
               if addr_i=UART_TX and ENA_LOG then -- 0x80a000c
                  -- Write to UART
                  print("- Write to UART Tx: 0x" &hstr(data_i)&" ("&
                        character'val(to_integer(data_i) mod 256)&")");
                    char := character'val(to_integer(data_i));
                    if char = lf then
                        std.textio.writeline(l_file, line_out);
                    else
                        std.textio.write(line_out, char);
                    end if;
               elsif is_gpio = '1' and ENA_LOG then
                  print("- Write GPIO: 0x" & hstr(data_i));
               elsif is_timer='1' and ENA_LOG then
                  print("- Write to TIMER: 0x" & hstr(data_i));
               else
                  --print(l_file,character'val(to_integer(data_i)));
                  report "Illegal IO data_i=0x"&hstr(data_i)&" @0x"&
                     hstr(x"80a00"&"000"&addr_i&"00") severity warning;
               end if;
            end if;
            --synopsys translate on
            data_o <= (others => '0');
            if re_i='1' then
               if is_gpio = '1' then
                  if ENA_LOG then
                     print("- Read  GPIO: 0x" & hstr(gpio_read));
                  end if;
                  data_o <= gpio_read;
               elsif addr_i=UART_TX then
                  if ENA_LOG then
                     print("- Read UART Tx");
                  end if;
                  data_o(8) <= not(tx_busy); -- output fifo not full
               elsif addr_i=UART_RX then
                  if ENA_LOG then
                     print("- Read UART Rx");
                  end if;
                  data_o(8) <= rx_avail; -- receiver not empty
                  data_o(7 downto 0) <= unsigned(rx_data);
               elsif is_timer='1' then
                  if ENA_LOG then
                     print("- Read TIMER: 0x" & hstr(timer_read));
                  end if;
                  data_o <= timer_read;
               else
                  report "Illegal IO data_o @0x"&
                     hstr(x"80a00"&"000"&addr_i&"00") severity warning;
               end if;
            end if; -- re_i='1'
         end if; -- reset_i/='1'
      end if; -- rising_edge(clk_i)
   end process do_io;
end Behave;
 
