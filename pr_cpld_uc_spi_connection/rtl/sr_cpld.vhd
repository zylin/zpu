----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:04:05 06/28/2010 
-- Design Name: 
-- Module Name:    sr_cpld - Behavioral 
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
library ieee;
use ieee.std_logic_1164.all;

entity sr_cpld is
    generic (
	    port_count_in  : positive := 8;
	    port_count_out : positive := 8
    );
    Port ( 
	    sdi            : in  std_logic;
        sdo            : out std_logic;
        clk            : in  std_logic;
        cs_n           : in  std_logic; -- edge sensitive chip select
		port_in        : in  std_ulogic_vector( port_count_in -1 downto 0);
		port_out       : out std_ulogic_vector( port_count_out-1 downto 0)
	);
end entity sr_cpld;

architecture rtl of sr_cpld is

    constant port_count : positive := port_count_in + port_count_out;

    signal sr        : std_ulogic_vector(port_count-1 downto 0);

begin

    shift_p: process
    begin
        wait until rising_edge(clk);
        sr  <= sdi & sr(port_count-1 downto 1);
        sdo <= sr(0);
    end process;

    out_p: process
    begin
        wait until rising_edge( cs_n);
        port_out <= sr(sr'high downto sr'high-port_count_out+1);
    end process;

--  in_p: process
--  begin
--      wait until falling_edge( cs_n);
--      sr(port_count_in-1 downto 0) <= port_in;
--  end process;

end architecture rtl;

