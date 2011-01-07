library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package global_signals is

    type debug_signals_t is record
        r_ctrl_txen  : std_ulogic;
        r_txcnt      : std_ulogic_vector(1 downto 0);
        tmsti_grant  : std_ulogic;
        tmsti_ready  : std_ulogic;
        hgrant_0     : std_ulogic;
        hgrant_1     : std_ulogic;
        txdstate     : std_ulogic_vector(3 downto 0);
        ahbmo0_bureq : std_ulogic;
        ahbmo1_bureq : std_ulogic;
        --
        psdone       : std_ulogic;
        psovfl       : std_ulogic;
        psen         : std_ulogic;
        psincdec     : std_ulogic;
        clk_in       : std_ulogic;
        clk_out      : std_ulogic;
        --
        timeout_cnt  : unsigned(7 downto 0); 
        psready      : std_ulogic;
        pserror      : std_ulogic;
        --
        sys_clk      : std_ulogic;
        ddr_clk      : std_ulogic;
        ddr_fb_clk   : std_ulogic;
    end record debug_signals_t;
    constant default_debug_signals : debug_signals_t := (
        r_ctrl_txen  => '0',                  -- : std_ulogic;
        r_txcnt      => "00",                 -- : std_ulogic_vector(1 downto 0);
        tmsti_grant  => '0',                  -- : std_ulogic;
        tmsti_ready  => '0',                  -- : std_ulogic;
        hgrant_0     => '0',                  -- : std_ulogic;
        hgrant_1     => '0',                  -- : std_ulogic;
        txdstate     => "0000",               -- : std_ulogic_vector(3 downto 0);
        ahbmo0_bureq => '0',                  -- : std_ulogic;
        ahbmo1_bureq => '0',                  -- : std_ulogic;
        --
        psdone       => '0',                  -- : std_ulogic;
        psovfl       => '0',                  -- : std_ulogic;
        psen         => '0',                  -- : std_ulogic;
        psincdec     => '0',                  -- : std_ulogic;
        clk_in       => '0',                  -- : std_ulogic;
        clk_out      => '0',                  -- : std_ulogic;
        --
        timeout_cnt  => "00000000",           -- : unsigned(7 downto 0); 
        psready      => '0',                  -- : std_ulogic;
        pserror      => '0',                  -- : std_ulogic;
        --
        sys_clk      => '0',                  -- : std_ulogic;
        ddr_clk      => '0',                  -- : std_ulogic;
        ddr_fb_clk   => '0'                   -- : std_ulogic;
    );

    signal global_break    : std_ulogic;

end package global_signals;
