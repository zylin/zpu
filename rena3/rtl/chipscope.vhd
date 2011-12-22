--------------------------------------------------------------------------------
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity chipscope is
    port (
        clk  : in std_ulogic;
        data : in std_ulogic_vector(31 downto 0);
        trig : in std_ulogic
        );
end entity chipscope;


architecture rtl of chipscope is

    constant simulation_active : boolean := false
    -- pragma translate_off
        or true
    -- pragma translate_on
        ;

    component icon port (
        control0 : inout std_logic_vector(35 downto 0));
    end component;

    component ila port (
        control : inout std_logic_vector(35 downto 0);
        clk     : in    std_logic;
        data    : in    std_logic_vector(31 downto 0);
        trig0   : in    std_logic_vector(0 downto 0));
    end component;

    signal control : std_logic_vector(35 downto 0);
    signal trig0   : std_logic_vector(0 downto 0);

begin

   
    synthesis_only: if ( not simulation_active ) generate
        icon_i0 : icon
            port map (
                control0 => control
                );

        trig0(0) <= trig;

        ila_i0 : ila
            port map (
                control => control,
                clk     => clk,
                data    => std_logic_vector( data),
                trig0   => trig0
                );
    end generate synthesis_only;

end architecture rtl;

