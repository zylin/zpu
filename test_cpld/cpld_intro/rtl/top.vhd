----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:38:26 11/11/2011 
-- Design Name: 
-- Module Name:    top - rtl 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
	port(
        RESET         : in  std_logic;
        CLK           : in  std_logic;
        SPS_A         : in  std_logic;
        SPS_B         : in  std_logic;
        SPS_C         : in  std_logic;
        SPS_D         : in  std_logic;
        bcd_out       : out std_logic_vector(3 downto 0);
        HexSW_A       : in  std_logic;
        HexSW_B       : in  std_logic;
        HexSW_C       : in  std_logic;
        HexSW_D       : in  std_logic;
        direct_switch : in  std_logic;
		LED           : out std_logic_vector(7 downto 0)
	);
end top;

architecture rtl of top is

    constant an  : std_logic := '0';
    constant aus : std_logic := '1';

    constant led_null : std_logic_vector(7 downto 0) := "11000000";
    constant led_eins : std_logic_vector(7 downto 0) := "11111001";

begin


    process( SPS_A, SPS_B, SPS_C, SPS_D)
    begin
        
        LED        <= led_null; 

        if SPS_A = '0' then
            LED    <= led_eins;
        end if;
    end process;

end architecture rtl;

