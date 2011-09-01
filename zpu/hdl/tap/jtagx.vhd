----------------------------------------------------------------------------
-- Simple JTAG controller, enhanced version
--
-- $Id: jtag.vhdl 35 2008-09-05 23:31:00Z strubi $
--
-- (c) 2005, 2006, 2011
-- Martin Strubel // <hackfin@section5.ch>
----------------------------------------------------------------------------

-- Functionality:
--
-- This module implements a JTAG controller with a instruction register (IR)
-- and a data register (DR).
-- Data is clocked into the IR register MSB first,
--                 into the DR register LSB first.
--
-- The reason for this inconsistent behaviour is, that this controller
-- allows variable sizes of data registers, depending on the IR value.
-- 
-- (Actually, the Blackfin CPU JTAG controller does it the same odd way)
--
-- The IR and DR register size is specified in the parameters:
--
-- IRSIZE (default 4)
-- DRSIZE (default 8)
--
-- All special functionality must be encoded outside this module, using
-- the IR values.
-- There is one exception: The Instruction "1111" is reserved for the 
-- IR_BYPASS mode. In this mode, the TDI bit is passed onto TDO with a delay
-- of one bit, according to the JTAG standard.
--
-- The design is tested using the JTAG library coming with the ICEbear
-- USB JTAG adapter.
--

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; -- TO_INTEGER

library work;
use work.jtag.all;

entity JtagController is
	generic (IRSIZE : natural := 4;
	         DRSIZE : natural := 8);
	port (
		tck,                           -- Tap Clock
		trst,                          -- Tap Reset
		tms,                           -- Tap mode select
		tdi   : in std_logic;          -- Tap data in
		tdo   : out std_logic;         -- Tap data out
		state : out jtag_state_type;   -- JTAG machine state
-- Data register input:
		dr_in  : in std_logic_vector (DRSIZE-1 downto 0);
-- Configureable DR size:
		msbpos : in bitpos_type;
-- Data register output:
		dr_out : out std_logic_vector (DRSIZE-1 downto 0);
-- Instruction register:
		ir_out : out std_logic_vector (IRSIZE-1 downto 0)
	);
end JtagController;

architecture behaviour of JtagController is

-- The only fixed instruction: All ones. Reserved for bypassing.
	constant IR_BYPASS : std_logic_vector (IRSIZE-1 downto 0) :=
		(others => '1');

	signal mystate : jtag_state_type  := TEST_LOGIC_RESET;
	signal next_state : jtag_state_type;

	signal s_dr         : std_logic_vector (DRSIZE-1 downto 0);
	signal s_ir         : std_logic_vector (IRSIZE-1 downto 0) :=
		(others => '1');

	signal msb          : bitpos_type;

	-- Disabled: Buffered register
	-- signal ir           : std_logic_vector (IRSIZE-1 downto 0);

begin

nextstate_decode:
	process (mystate, tms)
	begin
		case mystate is
			when CAPTURE_DR =>
				if (tms = '1') then
					next_state <= EXIT1_DR;
				else
					next_state <= SHIFT_DR;
				end if;
			when CAPTURE_IR =>
				if (tms = '1') then
					next_state <= EXIT1_IR;
				else
					next_state <= SHIFT_IR;
				end if;
			when EXIT1_DR =>
				if (tms = '1') then
					next_state <= UPDATE_DR;
				else
					next_state <= PAUSE_DR;
				end if;
			when EXIT1_IR =>
				if (tms = '1') then
					next_state <= UPDATE_IR;
				else
					next_state <= PAUSE_IR;
				end if;
			when EXIT2_DR =>
				if (tms = '1') then
					next_state <= UPDATE_DR;
				else
					next_state <= SHIFT_DR;
				end if;
			when EXIT2_IR =>
				if (tms = '1') then
					next_state <= UPDATE_IR;
				else
					next_state <= SHIFT_IR;
				end if;
			when PAUSE_DR =>
				if (tms = '1') then
					next_state <= EXIT2_DR;
				else
					next_state <= PAUSE_DR;
				end if;
			when PAUSE_IR =>
				if (tms = '1') then
					next_state <= EXIT2_IR;
				else
					next_state <= PAUSE_IR;
				end if;
			when RUN_TEST_IDLE =>
				if (tms = '1') then
					next_state <= SELECT_DR;
				else
					next_state <= RUN_TEST_IDLE;
				end if;
			when SELECT_DR =>
				if (tms = '1') then
					next_state <= SELECT_IR;
				else
					next_state <= CAPTURE_DR;
				end if;
			when SELECT_IR =>
				if (tms = '1') then
					next_state <= TEST_LOGIC_RESET;
				else
					next_state <= CAPTURE_IR;
				end if;
			when SHIFT_DR =>
				if (tms = '1') then
					next_state <= EXIT1_DR;
				else
					next_state <= SHIFT_DR;
				end if;
			when SHIFT_IR =>
				if (tms = '1') then
					next_state <= EXIT1_IR;
				else
					next_state <= SHIFT_IR;
				end if;
			when TEST_LOGIC_RESET =>
				if (tms = '1') then
					next_state <= TEST_LOGIC_RESET;
				else
					next_state <= RUN_TEST_IDLE;
				end if;
			when UPDATE_DR =>
				if (tms = '1') then
					next_state <= SELECT_DR;
				else
					next_state <= RUN_TEST_IDLE;
				end if;
			when UPDATE_IR =>
				if (tms = '1') then
					next_state <= SELECT_DR;
				else
					next_state <= RUN_TEST_IDLE;
				end if;
			when others =>
		end case;
	end process;

-- When we're in BYPASS, use MSB 0
	msb <= 0 when s_ir = IR_BYPASS else msbpos;

tdo_encode:
	process (mystate, s_ir, s_dr)
	begin
		case mystate is
		when SHIFT_IR =>
			tdo <= s_ir(0);                  -- Shift out LSB
		when SHIFT_DR =>
			tdo <= s_dr(msb);                -- Take MSB
		when others =>
			tdo <= '1';
		end case;
	end process;

state_advance:
	process (tck, trst)
	begin
		if (trst = '0') then
			mystate <= TEST_LOGIC_RESET;
		elsif rising_edge(tck) then
			mystate <= next_state;  -- Advance to next state
		end if;
	end process;

process_ir_dr:
	process (tck)
	begin
		if rising_edge(tck) then
-- takes effect when entering the concerning state
			case next_state is 
			-- When resetting, go into BYPASS mode
			when TEST_LOGIC_RESET =>
				s_ir <= (others => '1');
				s_dr <= (others => '0');
			when others =>
			end case;

-- Mystate is the current state, process takes effect on rising TCK when IN
-- the concerning state.
			case mystate is
			when SHIFT_IR =>
				s_ir <= tdi & s_ir(IRSIZE-1 downto 1);  -- Shift in from MSB
			when SHIFT_DR =>
				s_dr <= s_dr(DRSIZE-2 downto 0) & tdi;  -- likewise from LSB 
			when CAPTURE_DR =>
-- We could move this BYPASS check to a higher level module. But since
-- it's a reserved command, we leave it in here.
				if (s_ir /= IR_BYPASS) then
					s_dr <= dr_in; -- Latch!
				end if;
			when others =>
			end case;	
		end if;
	end process;

	-- always assign state to output
	-- We assign nextstate which is valid on the rising_edge of tck
	state <= next_state;

	ir_out <= s_ir;
	dr_out <= s_dr;

end behaviour;
