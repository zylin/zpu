library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.ibufg;
use unisim.vcomponents.srl16;
use unisim.vcomponents.dcm;
use unisim.vcomponents.bufg;


entity clocks is
    port (
        areset        : in  std_logic;
        cpu_clk_p     : in  std_logic;
        sdr_clk_fb_p  : in  std_logic;
        cpu_clk       : out std_logic;
        cpu_clk_2x    : out std_logic;
        cpu_clk_4x    : out std_logic;
        ddr_in_clk    : out std_logic;
        ddr_in_clk_2x : out std_logic;
        locked        : out std_logic_vector(2 downto 0)
        );
end entity clocks;

architecture behave of clocks is

    signal low                : std_logic;
    --
    signal cpu_clk_in         : std_logic;
    signal sdr_clk_fb_in      : std_logic;
    --
    signal dcm_cpu1           : std_logic;
    signal dcm_cpu2           : std_logic;
    signal dcm_cpu2_dum       : std_logic;
    signal dcm_cpu4           : std_logic;
    signal dcm_ddr2           : std_logic;
    signal dcm_ddr2_2x        : std_logic;
    --
    signal cpu_clk_int        : std_logic;
    signal cpu_clk_2x_int     : std_logic;
    signal cpu_clk_2x_dum_int : std_logic;
    signal cpu_clk_4x_int     : std_logic;
    signal ddr_in_clk_int     : std_logic;
    signal ddr_in_clk_2x_int  : std_logic;
    --
    signal dcm1_locked_del    : std_logic;
    signal dcm2_locked_del    : std_logic;
    signal dcm2_reset         : std_logic;
    signal dcm3_reset         : std_logic;
    --
    signal locked_int         : std_logic_vector(2 downto 0);
    signal del_addr           : std_logic_vector(3 downto 0);

begin

    low           <= '0';
    del_addr      <= "1111";
    --
    cpu_clk       <= cpu_clk_int;
    cpu_clk_2x    <= cpu_clk_2x_int;
    cpu_clk_4x    <= cpu_clk_4x_int;
    ddr_in_clk    <= ddr_in_clk_int;
    ddr_in_clk_2x <= ddr_in_clk_2x_int;
    locked        <= locked_int;


    cpu_ibufg : ibufg
        port map (
            O => cpu_clk_in,
            I => cpu_clk_p
            );

    sdr_fb_ibufg : ibufg
        port map (
            O => sdr_clk_fb_in,
            I => sdr_clk_fb_p
            );

    dcm2_rst : srl16
        generic map (
            init => x"0000"
            )
        port map (
            Q   => dcm1_locked_del,
            A0  => del_addr(0),
            A1  => del_addr(1),
            A2  => del_addr(2),
            A3  => del_addr(3),
            CLK => cpu_clk_int,
            D   => locked_int(0)
            );

    dcm2_reset <= not(dcm1_locked_del);

    dcm3_rst : srl16
        generic map (
            init => x"0000"
            )
        port map (
            Q   => dcm2_locked_del,
            A0  => del_addr(0),
            A1  => del_addr(1),
            A2  => del_addr(2),
            A3  => del_addr(3),
            CLK => cpu_clk_int,
            D   => locked_int(1)
            );

    dcm3_reset <= not(dcm2_locked_del);

    cpu1_dcm :
        dcm generic map (
            clkin_period          => 15.625,   --  Specify period of input clock
            factory_jf            => X"8080"   --  FACTORY JF Values
            )
            port map (
                clk0     => dcm_cpu1,       -- 0 degree DCM CLK ouptput
                clk2x    => dcm_cpu2,       -- 2X DCM CLK output
                locked   => locked_int(0),  -- DCM LOCK status output
                clkfb    => cpu_clk_int,    -- DCM clock feedback
                clkin    => cpu_clk_in,     -- Clock input (from IBUFG, BUFG or DCM)
                psclk    => low,            -- Dynamic phase adjust clock input
                psen     => low,            -- Dynamic phase adjust enable input
                psincdec => low,            -- Dynamic phase adjust increment/decrement
                rst      => areset          -- DCM asynchronous reset input
                );

    cpu2_dcm : dcm
        generic map (
            clkin_period          => 7.8125,  --  Specify period of input clock
            factory_jf            => X"8080"  --  FACTORY JF Values
            )
        port map (
            clk0     => dcm_cpu2_dum,        -- 0 degree DCM CLK ouptput
            clk2x    => dcm_cpu4,            -- 2X DCM CLK output
            locked   => locked_int(1),       -- DCM LOCK status output
            clkfb    => cpu_clk_2x_dum_int,  -- DCM clock feedback
            clkin    => cpu_clk_2x_int,      -- Clock input (from IBUFG, BUFG or DCM)
            psclk    => low,                 -- Dynamic phase adjust clock input
            psen     => low,                 -- Dynamic phase adjust enable input
            psincdec => low,                 -- Dynamic phase adjust increment/decrement
            rst      => dcm2_reset           -- DCM asynchronous reset input
            );

    ddr_read_dcm : dcm
        generic map (
            clkin_period          => 7.8125,   --  Specify period of input clock
            clkout_phase_shift    => "FIXED",  --  Specify phase shift of NONE, FIXED or VARIABLE
            factory_jf            => X"8080",  --  FACTORY JF Values
            phase_shift           => 103       --  Amount of fixed phase shift from -255 to 255
            )
        port map (
            clk0     => dcm_ddr2,       -- 0 degree DCM CLK ouptput
            clk2x    => dcm_ddr2_2x,    -- 2X DCM CLK output
            locked   => locked_int(2),  -- DCM LOCK status output
            clkfb    => ddr_in_clk_int, -- DCM clock feedback
            clkin    => sdr_clk_fb_in,  -- Clock input (from IBUFG, BUFG or DCM)
            psclk    => low,            -- Dynamic phase adjust clock input
            psen     => low,            -- Dynamic phase adjust enable input
            psincdec => low,            -- Dynamic phase adjust increment/decrement
            rst      => dcm3_reset      -- DCM asynchronous reset input
            );

    cpu1 : bufg
        port map (
            I => dcm_cpu1,
            O => cpu_clk_int
            );

    cpu2 : bufg
        port map (
            I => dcm_cpu2,
            O => cpu_clk_2x_int
            );

    cpu2_dum : bufg
        port map (
            i => dcm_cpu2_dum,
            o => cpu_clk_2x_dum_int
            );

    cpu4 : bufg
        port map (
            i => dcm_cpu4,
            o => cpu_clk_4x_int
            );

    ddr_clk : bufg port map (
        i => dcm_ddr2,
        o => ddr_in_clk_int
        );

    ddr_clk_2x : bufg port map (
        i => dcm_ddr2_2x,
        o => ddr_in_clk_2x_int
        );

end architecture behave;
