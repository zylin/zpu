library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity clocks is
	port (	areset			: in std_logic;
			cpu_clk_p		: in std_logic;
			sdr_clk_fb_p	: in std_logic;
			cpu_clk			: out std_logic;
			cpu_clk_2x		: out std_logic;
			cpu_clk_4x		: out std_logic;
			ddr_in_clk		: out std_logic;
			ddr_in_clk_2x	: out std_logic;
			locked			: out std_logic_vector(2 downto 0));
end clocks;

architecture behave of clocks is

signal	low					: std_logic;

signal	cpu_clk_in			: std_logic;
signal	sdr_clk_fb_in		: std_logic;

signal	dcm_cpu1			: std_logic;
signal	dcm_cpu2			: std_logic;
signal	dcm_cpu2_dum		: std_logic;
signal	dcm_cpu4			: std_logic;
signal	dcm_ddr2			: std_logic;
signal	dcm_ddr2_2x			: std_logic;

signal	cpu_clk_int			: std_logic;
signal	cpu_clk_2x_int		: std_logic;
signal	cpu_clk_2x_dum_int	: std_logic;
signal	cpu_clk_4x_int		: std_logic;
signal	ddr_in_clk_int		: std_logic;
signal	ddr_in_clk_2x_int	: std_logic;

signal	dcm1_locked_del		: std_logic;
signal	dcm2_locked_del		: std_logic;
signal	dcm2_reset			: std_logic;
signal	dcm3_reset			: std_logic;

signal	locked_int			: std_logic_vector(2 downto 0);
signal	del_addr			: std_logic_vector(3 downto 0);

begin

	low <= '0';				
	del_addr <= "1111";
	
	cpu_clk <= cpu_clk_int;
	cpu_clk_2x <= cpu_clk_2x_int;
	cpu_clk_4x <= cpu_clk_4x_int;
	ddr_in_clk <= ddr_in_clk_int;
	ddr_in_clk_2x <= ddr_in_clk_2x_int;
	locked <= locked_int;
	

   	CPU_IBUFG: 
   	IBUFG port map (
      	O => cpu_clk_in,
      	I => cpu_clk_p);
	
   	SDR_FB_IBUFG: 
   	IBUFG port map (
      	O => sdr_clk_fb_in,
      	I => sdr_clk_fb_p);
      	
   dcm2_rst: 
   SRL16 generic map (
      	INIT => X"0000")
   port map (
      	Q => dcm1_locked_del,
      	A0 => del_addr(0),
      	A1 => del_addr(1),
      	A2 => del_addr(2),
      	A3 => del_addr(3),
      	CLK => cpu_clk_int,
      	D => locked_int(0));
      	
	dcm2_reset <= not(dcm1_locked_del);      	
	
   dcm3_rst: 
   SRL16 generic map (
      	INIT => X"0000")
   port map (
      	Q => dcm2_locked_del,
      	A0 => del_addr(0),
      	A1 => del_addr(1),
      	A2 => del_addr(2),
      	A3 => del_addr(3),
      	CLK => cpu_clk_int,
      	D => locked_int(1));
      	
	dcm3_reset <= not(dcm2_locked_del);      	
	
   	cpu1_dcm: 
   	DCM generic map (
      	CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      	CLKFX_DIVIDE => 1,   --  Can be any interger from 1 to 32
      	CLKFX_MULTIPLY => 4, --  Can be any integer from 1 to 32
      	CLKIN_DIVIDE_BY_2 => FALSE, --  TRUE/FALSE to enable CLKIN divide by two feature
      	CLKIN_PERIOD => 15.625,          --  Specify period of input clock
      	CLKOUT_PHASE_SHIFT => "NONE", --  Specify phase shift of NONE, FIXED or VARIABLE
      	CLK_FEEDBACK => "1X",         --  Specify clock feedback of NONE, 1X or 2X
      	DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", --  SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                             --     an integer from 0 to 15
      	DFS_FREQUENCY_MODE => "LOW",     --  HIGH or LOW frequency mode for frequency synthesis
      	DLL_FREQUENCY_MODE => "LOW",     --  HIGH or LOW frequency mode for DLL
      	DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
      	FACTORY_JF => X"8080",          --  FACTORY JF Values
      	PHASE_SHIFT => 0,        --  Amount of fixed phase shift from -255 to 255
      	STARTUP_WAIT => FALSE) --  Delay configuration DONE until DCM LOCK, TRUE/FALSE
   	port map (
      	CLK0 => dcm_cpu1,   -- 0 degree DCM CLK ouptput
      	CLK180 => open, 	-- 180 degree DCM CLK output
      	CLK270 => open,	 	-- 270 degree DCM CLK output
      	CLK2X => dcm_cpu2, 	-- 2X DCM CLK output
      	CLK2X180 => open, -- 2X, 180 degree DCM CLK out
      	CLK90 => open,   	-- 90 degree DCM CLK output
      	CLKDV => open,   	-- Divided DCM CLK out (CLKDV_DIVIDE)
      	CLKFX => open,   	-- DCM CLK synthesis out (M/D)
      	CLKFX180 => open, 	-- 180 degree CLK synthesis out
      	LOCKED => locked_int(0), -- DCM LOCK status output
      	PSDONE => open, 	-- Dynamic phase adjust done output
      	STATUS => open, 	-- 8-bit DCM status bits output
      	CLKFB => cpu_clk_int,   -- DCM clock feedback
      	CLKIN => cpu_clk_in,   -- Clock input (from IBUFG, BUFG or DCM)
      	PSCLK => low,   	-- Dynamic phase adjust clock input
      	PSEN => low,     	-- Dynamic phase adjust enable input
      	PSINCDEC => low, 	-- Dynamic phase adjust increment/decrement
      	RST => areset);     -- DCM asynchronous reset input
   
   	cpu2_dcm: 
   	DCM generic map (
      	CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      	CLKFX_DIVIDE => 1,   --  Can be any interger from 1 to 32
      	CLKFX_MULTIPLY => 4, --  Can be any integer from 1 to 32
      	CLKIN_DIVIDE_BY_2 => FALSE, --  TRUE/FALSE to enable CLKIN divide by two feature
      	CLKIN_PERIOD => 7.8125,          --  Specify period of input clock
      	CLKOUT_PHASE_SHIFT => "NONE", --  Specify phase shift of NONE, FIXED or VARIABLE
      	CLK_FEEDBACK => "1X",         --  Specify clock feedback of NONE, 1X or 2X
      	DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", --  SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                             --     an integer from 0 to 15
      	DFS_FREQUENCY_MODE => "LOW",     --  HIGH or LOW frequency mode for frequency synthesis
      	DLL_FREQUENCY_MODE => "LOW",     --  HIGH or LOW frequency mode for DLL
      	DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
      	FACTORY_JF => X"8080",          --  FACTORY JF Values
      	PHASE_SHIFT => 0,        --  Amount of fixed phase shift from -255 to 255
      	STARTUP_WAIT => FALSE) --  Delay configuration DONE until DCM LOCK, TRUE/FALSE
   	port map (
      	CLK0 => dcm_cpu2_dum,     	-- 0 degree DCM CLK ouptput
      	CLK180 => open,		 -- 180 degree DCM CLK output
      	CLK270 => open,	 	-- 270 degree DCM CLK output
      	CLK2X => dcm_cpu4,  -- 2X DCM CLK output
      	CLK2X180 => open, 	-- 2X, 180 degree DCM CLK out
      	CLK90 => open,   	-- 90 degree DCM CLK output
      	CLKDV => open,   	-- Divided DCM CLK out (CLKDV_DIVIDE)
      	CLKFX => open,   	-- DCM CLK synthesis out (M/D)
      	CLKFX180 => open, 	-- 180 degree CLK synthesis out
      	LOCKED => locked_int(1), -- DCM LOCK status output
      	PSDONE => open, 	-- Dynamic phase adjust done output
      	STATUS => open, 	-- 8-bit DCM status bits output
      	CLKFB => cpu_clk_2x_dum_int,   -- DCM clock feedback
      	CLKIN => cpu_clk_2x_int,   -- Clock input (from IBUFG, BUFG or DCM)
      	PSCLK => low,   	-- Dynamic phase adjust clock input
      	PSEN => low,     	-- Dynamic phase adjust enable input
      	PSINCDEC => low, 	-- Dynamic phase adjust increment/decrement
      	RST => dcm2_reset);     -- DCM asynchronous reset input
   
   	ddr_read_dcm: 
   	DCM generic map (
      	CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      	CLKFX_DIVIDE => 1,   --  Can be any interger from 1 to 32
      	CLKFX_MULTIPLY => 4, --  Can be any integer from 1 to 32
      	CLKIN_DIVIDE_BY_2 => FALSE, --  TRUE/FALSE to enable CLKIN divide by two feature
      	CLKIN_PERIOD => 7.8125,          --  Specify period of input clock
     	CLKOUT_PHASE_SHIFT => "FIXED", --  Specify phase shift of NONE, FIXED or VARIABLE
--      	CLKOUT_PHASE_SHIFT => "NONE", --  Specify phase shift of NONE, FIXED or VARIABLE
      	CLK_FEEDBACK => "1X",         --  Specify clock feedback of NONE, 1X or 2X
      	DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", --  SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                             --     an integer from 0 to 15
      	DFS_FREQUENCY_MODE => "LOW",     --  HIGH or LOW frequency mode for frequency synthesis
      	DLL_FREQUENCY_MODE => "LOW",     --  HIGH or LOW frequency mode for DLL
      	DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
      	FACTORY_JF => X"8080",          --  FACTORY JF Values
      	PHASE_SHIFT => 103,        --  Amount of fixed phase shift from -255 to 255
--      	PHASE_SHIFT => 0,        --  Amount of fixed phase shift from -255 to 255
      	STARTUP_WAIT => FALSE) --  Delay configuration DONE until DCM LOCK, TRUE/FALSE
   	port map (
      	CLK0 => dcm_ddr2,     	-- 0 degree DCM CLK ouptput
      	CLK180 => open,		 -- 180 degree DCM CLK output
      	CLK270 => open,	 	-- 270 degree DCM CLK output
      	CLK2X => dcm_ddr2_2x,  -- 2X DCM CLK output
      	CLK2X180 => open, 	-- 2X, 180 degree DCM CLK out
      	CLK90 => open,   	-- 90 degree DCM CLK output
      	CLKDV => open,   	-- Divided DCM CLK out (CLKDV_DIVIDE)
      	CLKFX => open,   	-- DCM CLK synthesis out (M/D)
      	CLKFX180 => open, 	-- 180 degree CLK synthesis out
      	LOCKED => locked_int(2), -- DCM LOCK status output
      	PSDONE => open, 	-- Dynamic phase adjust done output
      	STATUS => open, 	-- 8-bit DCM status bits output
      	CLKFB => ddr_in_clk_int,   -- DCM clock feedback
      	CLKIN => sdr_clk_fb_in, -- Clock input (from IBUFG, BUFG or DCM)
      	PSCLK => low,   	-- Dynamic phase adjust clock input
      	PSEN => low,     	-- Dynamic phase adjust enable input
      	PSINCDEC => low, 	-- Dynamic phase adjust increment/decrement
      	RST => dcm3_reset);     -- DCM asynchronous reset input
   
   	cpu1:
	BUFG port map (
		I => dcm_cpu1,
		O => cpu_clk_int);
		
   	cpu2:
	BUFG port map (
		I => dcm_cpu2,
		O => cpu_clk_2x_int);
		
   	cpu2_dum:
	BUFG port map (
		I => dcm_cpu2_dum,
		O => cpu_clk_2x_dum_int);
		
   	cpu4:
	BUFG port map (
		I => dcm_cpu4,
		O => cpu_clk_4x_int);
		
   	ddr_clk:
	BUFG port map (
		I => dcm_ddr2,
		O => ddr_in_clk_int);

   	ddr_clk_2x:
	BUFG port map (
		I => dcm_ddr2_2x,
		O => ddr_in_clk_2x_int);

end behave;