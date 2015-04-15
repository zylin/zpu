--
-- this module desribes a simple GPIO interface
--
-- data on port_in is synhronized to clk_i and can be read at
-- address 0
--
-- any write to address 0 is mapped to port_out
--
-- at address 1 is a direction register (port_dir)
-- initialized with '1's, what mean direction = in
-- this register is useful for bidirectional pins, e.g. headers
--
--
-- some examples:
--
-- to connect 4 buttons:
-- port_in( 3 downto  0) <= gpio_button;
--
--
-- to connect 8 LEDs:
-- gpio_led <= port_out(7 downto 0); 
--
--
-- to connect 2 bidirectional header pins:
-- port_in(8)  <= gpio_pin(0);
-- gpio_pin(0) <= port_out(8) when port_dir(8) = '0' else 'Z';
--
-- port_in(9)  <= gpio_pin(1);
-- gpio_pin(1) <= port_out(9) when port_dir(9) = '0' else 'Z';
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity gpio is
    port(
        clk_i    : in  std_logic;
        reset_i  : in  std_logic;
        --
        we_i     : in  std_logic;
        data_i   : in  unsigned(31 downto 0);
        addr_i   : in  unsigned( 0 downto 0);
        data_o   : out unsigned(31 downto 0);
        --
        port_in  : in  std_logic_vector(31 downto 0);
        port_out : out std_logic_vector(31 downto 0);
        port_dir : out std_logic_vector(31 downto 0)
    );
end entity gpio;


architecture rtl of gpio is

    signal port_in_reg  : std_logic_vector(31 downto 0);
    signal port_in_sync : std_logic_vector(31 downto 0);
    --
    signal direction    : std_logic_vector(31 downto 0) := (others => '1');

begin

    process
    begin
        wait until rising_edge( clk_i);
        
        -- synchronize all inputs with two registers
        -- to avoid metastability
        port_in_reg  <= port_in;
        port_in_sync <= port_in_reg;

        -- write access to gpio
        if we_i = '1' then
            -- data
            if addr_i = "0" then
                port_out  <= std_logic_vector( data_i);
            end if;
            -- direction
            if addr_i = "1" then
                direction <= std_logic_vector( data_i);
            end if;
        end if;

        -- read access to gpio
        -- data
        if addr_i = "0" then
            data_o <= unsigned( port_in_sync);
        end if;
        -- direction
        if addr_i = "1" then
            data_o <= unsigned( direction);
        end if;

        -- outputs
        port_dir <= direction;

        -- sync reset
        if reset_i = '1' then
            direction    <= (others => '1');
            port_in_reg  <= (others => '0');
            port_in_sync <= (others => '0');
        end if;

    end process;


end architecture rtl;
