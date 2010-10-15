library ieee;
use ieee.std_logic_1164.all;


library unisim;
use unisim.vcomponents.dcm_base;




entity clk_manager is
    port(
      clk_in      : in  std_logic;  -- 200
      reset       : in  std_logic;        
      clk_x1_out  : out std_logic;  -- 200
      clk_x2_out  : out std_logic;  -- 400
      clk_fx_out  : out std_logic;        
      clk_dv_out  : out std_logic   -- 100
    );

end entity clk_manager;


architecture rtl of clk_manager is

    signal clk_x1_out_int : std_logic;

begin

        -- DCM_BASE: Base Digital Clock Manager Circuit
        --            Virtex-4/5
        -- Xilinx HDL Libraries Guide, version 10.1.2
        DCM_BASE_i0 : DCM_BASE
                generic map (
                        CLKDV_DIVIDE          => 2.0,                  -- Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                        --   7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
                        CLKFX_DIVIDE          => 2,                    -- Can be any integer from 1 to 32
                        CLKFX_MULTIPLY        => 2,                    -- Can be any integer from 2 to 32
                        CLKIN_DIVIDE_BY_2     => FALSE,                -- TRUE/FALSE to enable CLKIN divide by two feature
                        CLKIN_PERIOD          =>  5.0,                 -- Specify period of input clock in ns from 1.25 to 1000.00
                        CLKOUT_PHASE_SHIFT    => "NONE",               -- Specify phase shift mode of NONE or FIXED
                        CLK_FEEDBACK          => "1X",                 -- Specify clock feedback of NONE or 1X
                        DCM_AUTOCALIBRATION   => TRUE,                 -- DCM calibration circuitry TRUE/FALSE
                        DCM_PERFORMANCE_MODE  => "MAX_SPEED",          -- Can be MAX_SPEED or MAX_RANGE
                        DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS", -- SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
                                                                       --   an integer from 0 to 15
                        DFS_FREQUENCY_MODE    => "HIGH",               -- LOW or HIGH frequency mode for frequency synthesis
                        DLL_FREQUENCY_MODE    => "HIGH",               -- LOW, HIGH, or HIGH_SER frequency mode for DLL
                        DUTY_CYCLE_CORRECTION => TRUE,                 -- Duty cycle correction, TRUE or FALSE
                        FACTORY_JF            => X"F0F0",              -- FACTORY JF Values Suggested to be set to X"F0F0"
                        PHASE_SHIFT           => 0,                    -- Amount of fixed phase shift from -255 to 1023
                        STARTUP_WAIT          => FALSE                 -- Delay configuration DONE until DCM LOCK, TRUE/FALSE
                )
                port map (
                        CLK0     => clk_x1_out_int,   -- 0 degree DCM CLK ouptput
                        CLK180   => open,             -- 180 degree DCM CLK output
                        CLK270   => open,             -- 270 degree DCM CLK output
                        CLK2X    => clk_x2_out,       -- 2X DCM CLK output
                        CLK2X180 => open,             -- 2X, 180 degree DCM CLK out
                        CLK90    => open,             -- 90 degree DCM CLK output
                        CLKDV    => clk_dv_out,       -- Divided DCM CLK out (CLKDV_DIVIDE)
                        CLKFX    => clk_fx_out,       -- DCM CLK synthesis out (M/D)
                        CLKFX180 => open,             -- 180 degree CLK synthesis out
                        LOCKED   => open,             -- DCM LOCK status output
                        CLKFB    => clk_x1_out_int,   -- DCM clock feedback
                        CLKIN    => clk_in,           -- Clock input (from IBUFG, BUFG or DCM)
                        RST      => reset             -- DCM asynchronous reset input
                );
        -- End of DCM_BASE_inst instantiation

        clk_x1_out <= clk_x1_out_int;

end architecture rtl;
