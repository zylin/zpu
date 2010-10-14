
library ieee;
use ieee.std_logic_1164.all;


library unisim;
use unisim.vcomponents.dcm_sp; -- spartan 3e specific

entity clk_gen is
    generic (
        fx_mul     : integer := 1;
        fx_div     : integer := 1
    );
    port (
        clk        : in  std_ulogic;
        arst       : in  std_ulogic;
        --
        clkfx      : out std_ulogic;
        clk50      : out std_ulogic;
        clkdv      : out std_ulogic;
        clk_ready  : out std_ulogic;
        --
        psdone     : out std_ulogic;
        psovfl     : out std_ulogic;
        psen       : in  std_ulogic := '0';
        psincdec   : in  std_ulogic := '0'
    );
end entity clk_gen;



architecture rtl of clk_gen is

    signal clk0             : std_ulogic;
    signal clk90            : std_ulogic;
    signal clk180           : std_ulogic;
    signal clk270           : std_ulogic;
    signal clk2x            : std_ulogic;
    signal clkfx_int        : std_ulogic;
    signal clkdv_int        : std_ulogic;
    signal dcm_sp_i0_status : std_logic_vector(7 downto 0);

begin
    
    dcm_sp_i0: dcm_sp
        generic map (
            CLKDV_DIVIDE            => 2.0,     -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                                                -- 7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
            CLKFX_MULTIPLY          => fx_mul,  -- Can be any integer from 2 to 32
            CLKFX_DIVIDE            => fx_div,  -- Can be any integer from 1 to 32
            CLKIN_DIVIDE_BY_2       => FALSE,   -- TRUE/FALSE to enable CLKIN divide by two feature
            CLKIN_PERIOD            => 20.0,    -- Specify period of input clock
            CLKOUT_PHASE_SHIFT      => "NONE",  -- Specify phase shift of "NONE", "FIXED" or "VARIABLE"
            CLK_FEEDBACK            => "1X",    -- Specify clock feedback of "NONE", "1X" or "2X"
            DESKEW_ADJUST           => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                                             -- an integer from 0 to 15
            DLL_FREQUENCY_MODE      => "LOW",   -- "HIGH" or "LOW" frequency mode for DLL
            DUTY_CYCLE_CORRECTION   => TRUE,    -- Duty cycle correction, TRUE or FALSE
            PHASE_SHIFT             =>    0,    -- Amount of fixed phase shift from -255 to 255
            STARTUP_WAIT            => TRUE     -- Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
        )
        port map (
            CLK0        => clk0,             -- 0 degree DCM CLK ouptput
            CLK90       => clk90,            -- 90 degree DCM CLK output
            CLK180      => clk180,           -- 180 degree DCM CLK output
            CLK270      => clk270,           -- 270 degree DCM CLK output
            CLK2X       => clk2x,            -- 2X DCM CLK output
            CLK2X180    => open,             -- 2X, 180 degree DCM CLK out
            CLKDV       => clkdv_int,        -- Divided DCM CLK out (CLKDV_DIVIDE)
            CLKFX       => clkfx_int,        -- DCM CLK synthesis out (M/D)
            CLKFX180    => open,             -- 180 degree CLK synthesis out
            LOCKED      => clk_ready,        -- DCM LOCK status output
            PSDONE      => psdone,           -- Dynamic phase adjust done output
            STATUS      => dcm_sp_i0_status, -- 8-bit DCM status bits output
            CLKFB       => clk0,             -- DCM clock feedback
            CLKIN       => clk,              -- Clock input (from IBUFG, BUFG or DCM)
            PSCLK       => clk,              -- Dynamic phase adjust clock input
            PSEN        => psen,             -- Dynamic phase adjust enable input
            PSINCDEC    => psincdec,         -- Dynamic phase adjust increment/decrement
            RST         => arst              -- DCM asynchronous reset input
        );
        psovfl     <= dcm_sp_i0_status(0);
        clkdv      <= clkdv_int;
        clkfx      <= clkfx_int;
        clk50      <= clk0;

end architecture rtl;
