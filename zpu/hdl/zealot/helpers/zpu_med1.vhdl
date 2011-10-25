------------------------------------------------------------------------------
----                                                                      ----
----  ZPU Medium + PHI I/O + BRAM                                         ----
----                                                                      ----
----  http://www.opencores.org/                                           ----
----                                                                      ----
----  Description:                                                        ----
----  ZPU is a 32 bits small stack cpu. This is a helper that joins the   ----
----  medium version, the PHI I/O basic layout and a program BRAM.        ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2008 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2008 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the BSD license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      ZPU_Med1(Structural) (Entity and architecture)     ----
---- File name:        zpu_med1.vhdl                                      ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   zpu.zpupkg                                         ----
----                   work.zpu_memory                                    ----
---- Target FPGA:      Spartan 3 (XC3S1500-4-FG456)                       ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Xilinx Release 9.2.03i - xst J.39                  ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library zpu;
use zpu.zpupkg.all;

-- RAM declaration
library work;
use work.zpu_memory.all;

entity ZPU_Med1 is
   generic(
      WORD_SIZE  : natural:=32;  -- 32 bits data path
      D_CARE_VAL : std_logic:='X'; -- Fill value
      CLK_FREQ   : positive:=50; -- 50 MHz clock
      BRATE      : positive:=9600; -- RS232 baudrate
      ADDR_W     : natural:=18;  -- 18 bits address space=256 kB, 128 kB I/O
      BRAM_W     : natural:=15); -- 15 bits RAM space=32 kB
   port(
      clk_i      : in  std_logic;  -- CPU clock
      rst_i      : in  std_logic;  -- Reset
      break_o    : out std_logic;  -- Break executed
      dbg_o      : out zpu_dbgo_t; -- Debug info
      rs232_tx_o : out std_logic;  -- UART Tx
      rs232_rx_i : in  std_logic;  -- UART Rx
      gpio_in    : in  std_logic_vector(31 downto 0);
      gpio_out   : out std_logic_vector(31 downto 0);
      gpio_dir   : out std_logic_vector(31 downto 0)  -- 1 = in, 0 = out
      );
end entity ZPU_Med1;

architecture Structural of ZPU_Med1 is
   constant BYTE_BITS  : integer:=WORD_SIZE/16; -- # of bits in a word that addresses bytes
   constant IO_BIT     : integer:=ADDR_W-1; -- Address bit to determine this is an I/O
   constant BRDIVISOR  : positive:=CLK_FREQ*1e6/BRATE/4;

   -- I/O & memory (ZPU)
   signal mem_busy     : std_logic;
   signal mem_read     : unsigned(WORD_SIZE-1 downto 0);
   signal mem_write    : unsigned(WORD_SIZE-1 downto 0);
   signal mem_addr     : unsigned(ADDR_W-1 downto 0);
   signal mem_we       : std_logic;
   signal mem_re       : std_logic;

   -- Memory (SinglePort_RAM)
   signal ram_busy     : std_logic;
   signal ram_read     : unsigned(WORD_SIZE-1 downto 0);
   signal ram_addr     : unsigned(BRAM_W-1 downto BYTE_BITS);
   signal ram_we       : std_logic;
   signal ram_re       : std_logic;
   signal ram_ready_r  : std_logic:='0';

   -- I/O (ZPU_IO)
   signal io_busy      : std_logic;
   signal io_re        : std_logic;
   signal io_we        : std_logic;
   signal io_read      : unsigned(WORD_SIZE-1 downto 0);
   signal io_ready     : std_logic;
   signal io_reading_r : std_logic:='0';
   signal io_addr      : unsigned(2 downto 0);
begin
   memory: SinglePortRAM
      generic map(
         WORD_SIZE => WORD_SIZE, BYTE_BITS => BYTE_BITS, BRAM_W => BRAM_W)
      port map(
         clk_i => clk_i,
         we_i => ram_we, re_i => ram_re, addr_i => ram_addr,
         write_i => mem_write, read_o => ram_read, busy_o => ram_busy);
   ram_addr <= mem_addr(BRAM_W-1 downto BYTE_BITS);
   ram_we   <= mem_we and not(mem_addr(IO_BIT));
   ram_re   <= mem_re and not(mem_addr(IO_BIT));

   -- I/O: Phi layout
   io_map: ZPUPhiIO
      generic map(
         BRDIVISOR => BRDIVISOR, 
         LOG_FILE  => "zpu_med1_io.log"
         )
      port map(
         clk_i      => clk_i, 
         reset_i    => rst_i, 
         busy_o     => io_busy, 
         we_i       => io_we,
         re_i       => io_re, 
         data_i     => mem_write, 
         data_o     => io_read,
         addr_i     => io_addr, 
         rs232_rx_i => rs232_rx_i, 
         rs232_tx_o => rs232_tx_o,
         br_clk_i   => '1',
         gpio_in    => gpio_in,
         gpio_out   => gpio_out,
         gpio_dir   => gpio_dir
         );
   io_addr  <= mem_addr(4 downto 2);
   -- Here we decode 0x8xxxx as I/O and not just 0x80A00xx
   -- Note: We define the address space as 256 kB, so writing to 0x80A00xx
   -- will be as wrting to 0x200xx and hence we decode it as I/O space.
   io_we    <= mem_we and mem_addr(IO_BIT);
   io_re    <= mem_re and mem_addr(IO_BIT);
   io_ready <= (io_reading_r or io_re) and not io_busy;

   zpu : ZPUMediumCore
      generic map(
         WORD_SIZE => WORD_SIZE, ADDR_W => ADDR_W, MEM_W => BRAM_W,
         D_CARE_VAL => D_CARE_VAL)
      port map(
         clk_i => clk_i, reset_i => rst_i, enable_i => '1',
         break_o => break_o, dbg_o => dbg_o,
         -- Memory
         mem_busy_i => mem_busy, data_i => mem_read, data_o => mem_write,
         addr_o => mem_addr, write_en_o => mem_we, read_en_o => mem_re);
   mem_busy <= io_busy or ram_busy;

   -- Memory reads either come from IO or DRAM. We need to pick the right one.
   memory_control:
   process (ram_read, ram_ready_r, io_ready, io_read)
   begin
      mem_read <= (others => '0');
      if ram_ready_r='1' then
         mem_read <= ram_read;
      end if;
      if io_ready='1' then
         mem_read <= io_read;
      end if;
   end process memory_control;

   memory_control_sync:
   process (clk_i)
   begin
      if rising_edge(clk_i) then
         if rst_i='1' then
            io_reading_r <= '0';
            ram_ready_r  <= '0';
         else
            io_reading_r <= io_busy or io_re;
            ram_ready_r  <= ram_re;
         end if;
      end if;
   end process memory_control_sync;
end architecture Structural; -- Entity: ZPU_Med1

