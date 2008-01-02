library IEEE;
use IEEE.STD_LOGIC_1164.all;

package phi_config is

	constant		Fpga_Global_Base		: std_logic_vector(19 downto 17) 	:= "000";		-- 0x0800....
		constant	Clock_Stat_Reg_Addr		: std_logic_vector(5 downto 2)		:= "0000";		-- 0x....0000
		constant	Ctrl_Reg_Addr			: std_logic_vector(5 downto 2)		:= "0001";		-- 0x....0004
		constant	output_enable			: std_logic_vector(5 downto 2)		:= "0010";		-- 0x....0008
		constant	output_disable			: std_logic_vector(5 downto 2)		:= "0011";		-- 0x....000C
		constant	data_status				: std_logic_vector(5 downto 2)		:= "0100";		-- 0x....0010
		constant	set_output_data			: std_logic_vector(5 downto 2)		:= "0101";		-- 0x....0014
		constant	clear_output_data		: std_logic_vector(5 downto 2)		:= "0110";		-- 0x....0018
		constant	data_in_read			: std_logic_vector(5 downto 2)		:= "0111";		-- 0x....001C
		constant	output_status			: std_logic_vector(5 downto 2)		:= "1000";		-- 0x....0020
		constant	cpu_access_address		: std_logic_vector(5 downto 2)		:= "1001";		-- 0x....0024
				
	constant		Fpga_Ethernet_Reg_Base 	: std_logic_vector(19 downto 17) 	:= "110";		-- 0x080C0000

	constant		Fpga_DDR_Ctrl_Base		: std_logic_vector(19 downto 17)	:= "111";		-- 0x080E....
		constant	DDR_Ctrl_Reg_Addr		: std_logic_vector(3 downto 2)		:= "00";		-- 0x....0000
		constant	DDR_Mode_Reg_Addr		: std_logic_vector(3 downto 2)		:= "01";		-- 0x....0004
		constant	DDR_Page_Select_Addr	: std_logic_vector(3 downto 2)		:= "10";		-- 0x....0008
		
	
end phi_config;
