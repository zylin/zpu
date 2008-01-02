library IEEE;
use IEEE.STD_LOGIC_1164.all;

package phi_config is

	constant		Fpga_Global_Base		: std_logic_vector(19 downto 17) 	:= "000";		-- 0x0280....
		constant	Clock_Stat_Reg_Addr		: std_logic_vector(3 downto 1)		:= "000";		-- 0x....0000
		constant	Testreg32_Lower_Addr	: std_logic_vector(3 downto 1) 		:= "110";		-- 0x....000C
		constant	Testreg32_Upper_Addr	: std_logic_vector(3 downto 1) 		:= "111";		-- 0x....000E
		
	constant		Fpga_DDR_Ctrl_Base		: std_logic_vector(19 downto 17)	:= "111";		-- 0x028E....
		constant	DDR_Ctrl_Reg_Addr		: std_logic_vector(3 downto 1)		:= "000";		-- 0x....0000
		constant	DDR_Mode_Reg_Addr		: std_logic_vector(3 downto 1)		:= "001";		-- 0x....0002
		
		-- These are temporary test registers only!
		constant	DDR_Data_Reg_Addr		: std_logic_vector(3 downto 1)		:= "100";		-- 0x....0008
		constant 	DDR_Addr_Reg_Addr		: std_logic_vector(3 downto 1) 		:= "101";		-- 0x....000A
		constant 	DDR_Req_Reg_Addr		: std_logic_vector(3 downto 1) 		:= "110";		-- 0x....000C
	
end phi_config;
