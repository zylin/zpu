library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
	port(
        reset_n       : in  std_ulogic;
        clk           : in  std_ulogic;
        dip_switch_n  : in  std_ulogic_vector(3 downto 0);
        button_n      : in  std_ulogic_vector(1 downto 0);		  
		led_n         : out std_ulogic_vector(7 downto 0);
        ssio_do       : in  std_ulogic;
        ssio_clk      : in  std_ulogic;
        ssio_lo       : in  std_ulogic;
        ssio_di       : out std_ulogic;
        ssio_li       : in  std_ulogic
	);
end entity top;


architecture rtl of top is

    signal rec_reg  : std_ulogic_vector(15 downto 0) := (others => '1');
    signal send_reg : std_ulogic_vector(15 downto 0);

begin

--  led_n <= (0 => '0', others => '1');

    -- catch data bits
    process
    begin
        wait until rising_edge( ssio_clk);
        rec_reg <= rec_reg( rec_reg'high - 1 downto 0) & ssio_do;
    end process;

    -- load data bits into output register
    process
    begin
        wait until rising_edge( ssio_lo);
        led_n <= not rec_reg(7 downto 0);
    end process;


    -- load data bit from input to send register
    process (ssio_li, ssio_clk, dip_switch_n, button_n)
    begin
        if rising_edge( ssio_clk) then
            send_reg <= send_reg( send_reg'high - 1 downto 0) & '0';
        end if;
        if ssio_li = '0' then
            send_reg             <= (others => '0');
            send_reg( 3 downto  0) <= not dip_switch_n;
            send_reg( 7 downto  4) <= (others => not button_n(0));
            send_reg(11 downto  8) <= not dip_switch_n;
            send_reg(15 downto 12) <= (others => not button_n(1));
        end if;
    end process;

    ssio_di <= send_reg( send_reg'high);

end architecture rtl;

