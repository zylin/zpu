library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
--use work.phi_config.all;
use work.wishbone_pkg.all;

entity atomic32_access is
	port (	cpu_clk			: in std_logic;
			areset			: in std_logic;
	
			-- Wishbone from CPU interface
			wb_16_i			: in wishbone_bus_in;
			wb_16_o     	: out wishbone_bus_out;
			
			-- Wishbone to FPGA registers and ethernet core
			wb_32_i			: in wishbone_bus_out;
			wb_32_o			: out wishbone_bus_in);
end atomic32_access;

architecture behave of atomic32_access is

type eth_state_wr_type is (idle, lsb_msb, lsb, msb, write, ack, wait_st);
signal	eth_state_wr : eth_state_wr_type;				
type eth_state_rd_type is (idle, lsb_msb, lsb_read, lsb, wait_st2, msb);
signal eth_state_rd : eth_state_rd_type;			
signal core_data : std_logic_vector(31 downto 0);
signal core_addr : std_logic_vector(31 downto 0);

begin
	process(cpu_clk, areset)
	begin
		if areset = '1' then
			eth_state_wr <= idle;
			eth_state_rd <= idle;
			wb_32_o.stb <= '0';
			wb_32_o.cyc <= '0';
			wb_16_o.ack <= '0';
			core_data <= (others => '0');
			core_addr <= (others => '0');
		elsif (rising_edge(cpu_clk)) then
			
			case eth_state_wr is						--write cycle
				when idle =>
					if wb_16_i.cyc = '1' and wb_16_i.we = '1' then
						eth_state_wr <= lsb_msb;						
					end if;					
				when lsb_msb =>
					if wb_16_i.adr(1) = '0' then
						eth_state_wr <= lsb;
					end if;
					if wb_16_i.adr(1) = '1' then
						eth_state_wr <= msb;
					end if;
				when lsb =>
					core_data(15 downto 0) <= wb_16_i.dat(15 downto 0);
					wb_16_o.ack <= '1';
					eth_state_wr <= wait_st;
				when msb =>
					core_data(31 downto 16) <= wb_16_i.dat(31 downto 16);
					core_addr <= wb_16_i.adr(31 downto 2) & "00";
					eth_state_wr <= write;
				when write =>
					wb_32_o.dat <= core_data;
					wb_32_o.adr <= core_addr;
					wb_32_o.sel <= "1111";
					wb_32_o.we <= '1';
					wb_32_o.stb <= '1';
					wb_32_o.cyc <= '1';
					eth_state_wr <= ack;
				when ack =>
					if wb_32_i.ack = '1' then
						wb_16_o.ack <= '1';
						eth_state_wr <= wait_st;
						wb_32_o.stb <= '0';	
						wb_32_o.cyc <= '0';		
						wb_32_o.sel <= "0000";	
						wb_32_o.we <= '0';	
					end if;
				when wait_st =>
					wb_16_o.ack <= '0';
					eth_state_wr <= idle;
				when others =>
					eth_state_wr <= idle;
			end case;
	
			case eth_state_rd is						--read cycle
				when idle =>
					if wb_16_i.cyc = '1' and wb_16_i.we = '0' then
						core_addr <= wb_16_i.adr(31 downto 2) & "00";	
						eth_state_rd <= lsb_msb;
					end if;
				when lsb_msb =>
					if wb_16_i.adr(1) = '0' then
						wb_32_o.adr <= core_addr;
						eth_state_rd <= lsb_read;
					end if;
					if wb_16_i.adr(1) = '1' then
						wb_32_o.adr <= core_addr;
						eth_state_rd <= msb;
					end if;
				when lsb_read =>
					wb_32_o.sel <= "1111";
					wb_32_o.we <= '0';
					wb_32_o.stb <= '1';
					wb_32_o.cyc <= '1';							
                	eth_state_rd <= lsb;
				when lsb =>
					if wb_32_i.ack = '1' then									
						wb_32_o.sel <= "0000";
						wb_32_o.stb <= '0';
						wb_32_o.cyc <= '0';
						core_data <= wb_32_i.dat;
						wb_16_o.dat <= x"0000" & wb_32_i.dat(15 downto 0);							
						wb_16_o.ack <= '1';
						eth_state_rd <= wait_st2;
					end if;
				when wait_st2 =>
					wb_16_o.ack <= '0';
					eth_state_rd <= idle;
				when msb =>
					wb_16_o.ack <= '1';
					wb_16_o.dat <= core_data(31 downto 16) & x"0000";
					eth_state_rd <= wait_st2;
				when others =>
					eth_state_rd <= idle;
			end case;
		end if;
	end process;

end behave;