
library ieee;
use ieee.std_logic_1164.all;


library unisim;
use unisim.vcomponents.dcm_sp; -- spartan 3e specific

entity clk_gen is
    port (
        clk       : in  std_ulogic;
        arst      : in  std_ulogic;
        clk_50MHz : out std_ulogic;
        clk_25MHz : out std_ulogic;
        clk_ready : out std_ulogic
    );
end entity clk_gen;



architecture rtl of clk_gen is

    signal clk2x : std_ulogic;

begin
    
    dcm_sp_i0: dcm_sp
        generic map (
            CLKDV_DIVIDE            => 2.0,     -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                                -- 7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
            CLKFX_DIVIDE            => 1,       -- Can be any interger from 1 to 32
            CLKFX_MULTIPLY          => 4,       -- Can be any integer from 1 to 32
            CLKIN_DIVIDE_BY_2       => FALSE,   -- TRUE/FALSE to enable CLKIN divide by two feature
            CLKIN_PERIOD            => 20.0,    -- Specify period of input clock
            CLKOUT_PHASE_SHIFT      => "NONE",  -- Specify phase shift of "NONE", "FIXED" or "VARIABLE"
            CLK_FEEDBACK            => "2X",    -- Specify clock feedback of "NONE", "1X" or "2X"
            DESKEW_ADJUST           => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                                             -- an integer from 0 to 15
            DLL_FREQUENCY_MODE      => "LOW",   -- "HIGH" or "LOW" frequency mode for DLL
            DUTY_CYCLE_CORRECTION   => TRUE,    -- Duty cycle correction, TRUE or FALSE
            PHASE_SHIFT             => 0,       -- Amount of fixed phase shift from -255 to 255
            STARTUP_WAIT            => TRUE     -- Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
        )
        port map (
            CLK0        => clk_50MHz, -- 0 degree DCM CLK ouptput
            CLK180      => open,      -- 180 degree DCM CLK output
            CLK270      => open,      -- 270 degree DCM CLK output
            CLK2X       => clk2x,     -- 2X DCM CLK output
            CLK2X180    => open,      -- 2X, 180 degree DCM CLK out
            CLK90       => open,      -- 90 degree DCM CLK output
            CLKDV       => clk_25MHz, -- Divided DCM CLK out (CLKDV_DIVIDE)
            CLKFX       => open,      -- DCM CLK synthesis out (M/D)
            CLKFX180    => open,      -- 180 degree CLK synthesis out
            LOCKED      => clk_ready, -- DCM LOCK status output
            PSDONE      => open,      -- Dynamic phase adjust done output
            STATUS      => open,      -- 8-bit DCM status bits output
            CLKFB       => clk2x,     -- DCM clock feedback
            CLKIN       => clk,       -- Clock input (from IBUFG, BUFG or DCM)
            PSCLK       => '0',       -- Dynamic phase adjust clock input
            PSEN        => '0',       -- Dynamic phase adjust enable input
            PSINCDEC    => '0',       -- Dynamic phase adjust increment/decrement
            RST         => arst       -- DCM asynchronous reset input
        );

end architecture rtl;
