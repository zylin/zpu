----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:04:05 06/28/2010 
-- Design Name: 
-- Module Name:    sr - Behavioral 
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

entity sr is
    generic (
	    port_count_in  : positive := 100;
	    port_count_out : positive := 20
    );
    Port ( 
	    di             : in  std_logic;
        do             : out std_logic;
        clk            : in  std_logic;
        latch_or_shift : in  std_logic; -- 1=latch, 0=shift
		port_in        : in  std_ulogic_vector( port_count_in -1 downto 0);
		port_out       : out std_ulogic_vector( port_count_out-1 downto 0)
	);
end sr;

architecture rtl of sr is

    constant port_count : positive := port_count_in + port_count_out;

    signal out_latch : std_ulogic_vector(port_count_out-1 downto 0);
    signal sr        : std_ulogic_vector(port_count-1 downto 0);

begin

    process
    begin
        wait until rising_edge(clk);
        if latch_or_shift = '1' then -- latch 
            out_latch                    <= sr(sr'high downto sr'high-port_count_out+1);
            sr(port_count_in-1 downto 0) <= port_in;
        else -- shift
            sr <= di & sr(port_count-1 downto 1);
            do <= sr(0);
        end if;
    end process;

    port_out <= out_latch;

end rtl;

