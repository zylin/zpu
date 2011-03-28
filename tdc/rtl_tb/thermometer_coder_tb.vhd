entity thermometer_coder_tb is
end entity thermometer_coder_tb;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tools;
use tools.tools_pkg.log2;

library tdc;
use tdc.components.thermometer_coder;



architecture testbench of thermometer_coder_tb is

    constant taps_c                        : natural := 64;

    signal   tb_clk                        : std_ulogic := '0';
    signal   tb_thermo                     : std_ulogic_vector(taps_c-1 downto 0);
    signal   thermometer_coder_i0_code_out : unsigned( log2(taps_c) downto 0);


    function generate_thermo( no: natural; max_taps: natural) return std_ulogic_vector is
        variable taps : std_ulogic_vector(max_taps-1 downto 0) := (others => '0');
    begin
        taps(no-1 downto 0) := (others => '1');
        return taps;
    end function generate_thermo;

    function generate_thermo_with_bubble( no: natural; max_taps: natural) return std_ulogic_vector is
        variable taps : std_ulogic_vector(max_taps-1 downto 0) := (others => '0');
    begin
        taps(no-1 downto 0) := (others => '1');
        if no > 1 then
            taps(no-2)      := '0';
        end if;
        return taps;
    end function generate_thermo_with_bubble;
    

begin
    
    thermometer_coder_i0: thermometer_coder
    generic map (
        thermo_in_no_g => taps_c
    )
    port map (
        clk            => tb_clk,
        thermo_in      => tb_thermo,
        code_out       => thermometer_coder_i0_code_out
    );
        

    main: process
    begin
        for i in 0 to taps_c loop
--          tb_thermo <= generate_thermo( i, taps_c);
            tb_thermo <= generate_thermo_with_bubble( i, taps_c);
            
            -- not so nice way to generate some (2) clock pulses
            tb_clk <= not tb_clk after 1 ns;
            tb_clk <= not tb_clk after 1 ns;
            tb_clk <= not tb_clk after 1 ns;
            tb_clk <= not tb_clk after 1 ns;

            report "generate code " & integer'image(i) & "  result : " & integer'image( to_integer(thermometer_coder_i0_code_out));
            wait for 1 ns;
        end loop;
        report "simulation end.";
        wait;
    end process;

end architecture testbench;
