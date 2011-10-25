-- testbench for
-- Digilent Spartan 3E Starter Board
--
-- includes "model" for clock generation
-- simulate press on Rotary Pushbutton Switch as reset
--
-- place models for external components (PHY, SDRAM) in this file
--


library ieee;
use ieee.std_logic_1164.all;


entity top_tb is
end entity top_tb;

architecture testbench of top_tb is

    ---------------------------
    -- constant declarations
    constant clk_50mhz_period : time := 1 sec / 50_000_000;  -- 50 MHz


    ---------------------------
    -- signal declarations
    signal simulation_run     : boolean                      := true;
    signal tb_stop_simulation : std_logic;
    --
    -- Analog-to-Digital Converter (ADC)
    signal tb_ad_conv         : std_logic;
    -- Programmable Gain Amplifier (AMP)
    signal tb_amp_cs          : std_logic;  -- active low chip select
    signal tb_amp_dout        : std_logic                    := '1';
    signal tb_amp_shdn        : std_logic;  -- active high shutdown, reset
    -- Pushbuttons (BTN)
    signal tb_btn_east        : std_logic                    := '0';
    signal tb_btn_north       : std_logic                    := '0';
    signal tb_btn_south       : std_logic                    := '0';
    signal tb_btn_west        : std_logic                    := '0';
    -- Clock inputs (CLK)
    signal tb_clk_50mhz       : std_logic                    := '0';
    signal tb_clk_aux         : std_logic                    := '0';
    signal tb_clk_sma         : std_logic                    := '0';
    -- Digital-to-Analog Converter (DAC)
    signal tb_dac_clr         : std_logic;  -- async, active low reset input
    signal tb_dac_cs          : std_logic;  -- active low chip select, conv start with rising edge
    -- 1-Wire Secure EEPROM (DS)
    signal tb_ds_wire         : std_logic;
    -- Ethernet PHY (E)
    signal tb_e_col           : std_logic                    := '0';  -- MII collision detect
    signal tb_e_crs           : std_logic                    := '0';  -- carrier sense
    signal tb_e_mdc           : std_logic;  -- management clock
    signal tb_e_mdio          : std_logic;  -- management data io
    signal tb_e_rx_clk        : std_logic                    := '0';  -- receive clock 25MHz@100BaseTx or 2.5MHz@10Base-T
    signal tb_e_rx_dv         : std_logic                    := '0';  -- receive data valid
    signal tb_e_rxd           : std_logic_vector(3 downto 0) := (others => '0');
    signal tb_e_rx_er         : std_logic                    := '0';
    signal tb_e_tx_clk        : std_logic                    := '0';  -- transmit clock 25MHz@100BaseTx or 2.5MHz@10Base-T
    signal tb_e_tx_en         : std_logic;  -- transmit enable
    signal tb_e_txd           : std_logic_vector(3 downto 0);
    signal tb_e_tx_er         : std_logic;
    -- FPGA Configuration Mode, INIT_B Pins (FPGA)
    signal tb_fpga_m0         : std_logic;
    signal tb_fpga_m1         : std_logic;
    signal tb_fpga_m2         : std_logic;
    signal tb_fpga_init_b     : std_logic;
    signal tb_fpga_rdwr_b     : std_logic                    := '0';
    signal tb_fpga_hswap      : std_logic                    := '0';
    -- FX2 Connector (FX2)
    signal tb_fx2_clkin       : std_logic;
    signal tb_fx2_clkio       : std_logic;
    signal tb_fx2_clkout      : std_logic;
    signal tb_fx2_io          : std_logic_vector(40 downto 1);
    -- Character LCD (LCD)
    signal tb_lcd_e           : std_logic;
    signal tb_lcd_rs          : std_logic;
    signal tb_lcd_rw          : std_logic;
    -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
    -- PS/2 Mouse/Keyboard Port (PS2)
    signal tb_ps2_clk         : std_logic;
    signal tb_ps2_data        : std_logic;
    -- Rotary Pushbutton Switch (ROT)
    signal tb_rot_a           : std_logic                    := '0';
    signal tb_rot_b           : std_logic                    := '0';
    signal tb_rot_center      : std_logic;  -- use as reset
    -- RS-232 Serial Ports (RS232)
    signal tb_rs232_dce_rxd   : std_logic                    := '1';
    signal tb_rs232_dce_txd   : std_logic;
    signal tb_rs232_dte_rxd   : std_logic                    := '1';
    signal tb_rs232_dte_txd   : std_logic;
    -- DDR SDRAM (SD) (I/O Bank 3, VCCO=2.5V)
    signal tb_sd_a            : std_logic_vector(12 downto 0);  -- address inputs
    signal tb_sd_dq           : std_logic_vector(15 downto 0);  -- data io
    signal tb_sd_ba           : std_logic_vector(1 downto 0);  -- bank address inputs
    signal tb_sd_ras          : std_logic;  -- command output
    signal tb_sd_cas          : std_logic;  -- command output
    signal tb_sd_we           : std_logic;  -- command output 
    signal tb_sd_udm          : std_logic;  -- data mask
    signal tb_sd_ldm          : std_logic;  -- data mask
    signal tb_sd_udqs         : std_logic;  -- data strobe
    signal tb_sd_ldqs         : std_logic;  -- data strobe
    signal tb_sd_cs           : std_logic;  -- active low chip select
    signal tb_sd_cke          : std_logic;  -- active high clock enable
    signal tb_sd_ck_n         : std_logic;  -- differential clock
    signal tb_sd_ck_p         : std_logic;  -- differential clock
    -- Path to allow connection to top DCM connection
    signal tb_sd_ck_fb        : std_logic;
    -- Intel StrataFlash Parallel NOR Flash (SF)
    signal tb_sf_a            : std_logic_vector(23 downto 0);  -- sf_a<24> = fx_io32 :-(
    signal tb_sf_byte         : std_logic;
    signal tb_sf_ce0          : std_logic;
    signal tb_sf_d            : std_logic_vector(15 downto 1);
    signal tb_sf_oe           : std_logic;
    signal tb_sf_sts          : std_logic                    := '0';
    signal tb_sf_we           : std_logic;
    -- STMicro SPI serial Flash (SPI)
    signal tb_spi_mosi        : std_logic;  -- master out slave in
    signal tb_spi_miso        : std_logic                    := '0';  -- master in  slave out
    signal tb_spi_sck         : std_logic;  -- clock
    signal tb_spi_ss_b        : std_logic;  -- active low slave select
    signal tb_spi_alt_cs_jp11 : std_logic;
    -- Slide Switches (SW)
    signal tb_sw              : std_logic_vector(3 downto 0) := (others => '0');
    -- VGA Port (VGA)
    signal tb_vga_blue        : std_logic;
    signal tb_vga_green       : std_logic;
    signal tb_vga_hsync       : std_logic;
    signal tb_vga_red         : std_logic;
    signal tb_vga_vsync       : std_logic;
    -- Xilinx CPLD (XC)
    signal tb_xc_cmd          : std_logic_vector(1 downto 0);
    signal tb_xc_cpld_en      : std_logic;
    signal tb_xc_d            : std_logic_vector(2 downto 0);
    signal tb_xc_trig         : std_logic                    := '0';
    signal tb_xc_gck0         : std_logic;
    signal tb_gclk10          : std_logic;


begin


    -- generate clock
    tb_clk_50mhz <= not tb_clk_50mhz after clk_50mhz_period / 2 when simulation_run;

    -- generate reset
    tb_rot_center <= '1', '0' after 6.66 * clk_50mhz_period;


    -- clock feedback for SD-RAM (on board)
    tb_sd_ck_fb <= tb_sd_ck_p;

    -- simulate keypress
    tb_btn_north <= '0', '1' after 55 us, '0' after 56 us;

    -- dut
    top_i0 : entity work.top
        port map (
            stop_simulation => tb_stop_simulation,  -- : out   std_logic;
            -- Analog-to-Digital Converter (ADC)
            ad_conv         => tb_ad_conv,          -- : out   std_logic;
            -- Programmable Gain Amplifier (AMP)
            amp_cs          => tb_amp_cs,           -- : out   std_logic;
            amp_dout        => tb_amp_dout,         -- : in    std_logic;
            amp_shdn        => tb_amp_shdn,         -- : out   std_logic;
            -- Pushbuttons (BTN)
            btn_east        => tb_btn_east,         -- : in    std_logic;
            btn_north       => tb_btn_north,        -- : in    std_logic;
            btn_south       => tb_btn_south,        -- : in    std_logic;
            btn_west        => tb_btn_west,         -- : in    std_logic;
            -- Clock inputs (CLK)
            clk_50mhz       => tb_clk_50mhz,        -- : in    std_logic;
            clk_aux         => tb_clk_aux,          -- : in    std_logic;
            clk_sma         => tb_clk_sma,          -- : in    std_logic;
            -- Digital-to-Analog Converter (DAC)
            dac_clr         => tb_dac_clr,          -- : out   std_logic;
            dac_cs          => tb_dac_cs,           -- : out   std_logic;
            -- 1-Wire Secure EEPROM (DS)
            ds_wire         => tb_ds_wire,          -- : inout std_logic;
            -- Ethernet PHY (E)
            e_col           => tb_e_col,            -- : in    std_logic;
            e_crs           => tb_e_crs,            -- : in    std_logic;
            e_mdc           => tb_e_mdc,            -- : out   std_logic;
            e_mdio          => tb_e_mdio,           -- : inout std_logic;
            e_rx_clk        => tb_e_rx_clk,         -- : in    std_logic;
            e_rx_dv         => tb_e_rx_dv,          -- : in    std_logic;
            e_rxd           => tb_e_rxd,            -- : in    std_logic_vector(3 downto 0);
            e_rx_er         => tb_e_rx_er,          -- : in    std_logic;
            e_tx_clk        => tb_e_tx_clk,         -- : in    std_logic;
            e_tx_en         => tb_e_tx_en,          -- : out   std_logic;
            e_txd           => tb_e_txd,            -- : out   std_logic_vector(3 downto 0);
            e_tx_er         => tb_e_tx_er,          -- : out   std_logic;
            -- FPGA Configuration Mode, INIT_B Pins (FPGA)
            fpga_m0         => tb_fpga_m0,          -- : inout std_logic;
            fpga_m1         => tb_fpga_m1,          -- : inout std_logic;
            fpga_m2         => tb_fpga_m2,          -- : inout std_logic;
            fpga_init_b     => tb_fpga_init_b,      -- : inout std_logic;
            fpga_rdwr_b     => tb_fpga_rdwr_b,      -- : in    std_logic;
            fpga_hswap      => tb_fpga_hswap,       -- : in    std_logic;
            -- FX2 Connector (FX2)
            fx2_clkin       => tb_fx2_clkin,        -- : inout std_logic;
            fx2_clkio       => tb_fx2_clkio,        -- : inout std_logic;
            fx2_clkout      => tb_fx2_clkout,       -- : inout std_logic;
            fx2_io          => tb_fx2_io,           -- : inout std_logic_vector(40 downto 1);
            -- Character LCD (LCD)
            lcd_e           => tb_lcd_e,            -- : out   std_logic;
            lcd_rs          => tb_lcd_rs,           -- : out   std_logic;
            lcd_rw          => tb_lcd_rw,           -- : out   std_logic;
            -- LCD data connections are shared with StrataFlash connections SF_D<11:8>
            -- PS/2 Mouse/Keyboard Port (PS2)
            ps2_clk         => tb_ps2_clk,          -- : inout std_logic;
            ps2_data        => tb_ps2_data,         -- : inout std_logic;
            -- Rotary Pushbutton Switch (ROT)
            rot_a           => tb_rot_a,            -- : in    std_logic;
            rot_b           => tb_rot_b,            -- : in    std_logic;
            rot_center      => tb_rot_center,       -- : in    std_logic;
            -- RS-232 Serial Ports (RS232)
            rs232_dce_rxd   => tb_rs232_dce_rxd,    -- : in    std_logic;
            rs232_dce_txd   => tb_rs232_dce_txd,    -- : out   std_logic;
            rs232_dte_rxd   => tb_rs232_dte_rxd,    -- : in    std_logic;
            rs232_dte_txd   => tb_rs232_dte_txd,    -- : out   std_logic;
            -- DDR SDRAM (SD) (I/O Bank 3, VCCO=2.5V)
            sd_a            => tb_sd_a,             -- : out   std_logic_vector(12 downto 0);
            sd_dq           => tb_sd_dq,            -- : inout std_logic_vector(15 downto 0);
            sd_ba           => tb_sd_ba,            -- : out   std_logic_vector(1 downto 0);
            sd_ras          => tb_sd_ras,           -- : out   std_logic;
            sd_cas          => tb_sd_cas,           -- : out   std_logic;
            sd_we           => tb_sd_we,            -- : out   std_logic;
            sd_udm          => tb_sd_udm,           -- : out   std_logic;
            sd_ldm          => tb_sd_ldm,           -- : out   std_logic;
            sd_udqs         => tb_sd_udqs,          -- : inout std_logic;
            sd_ldqs         => tb_sd_ldqs,          -- : inout std_logic;
            sd_cs           => tb_sd_cs,            -- : out   std_logic;
            sd_cke          => tb_sd_cke,           -- : out   std_logic;
            sd_ck_n         => tb_sd_ck_n,          -- : out   std_logic;
            sd_ck_p         => tb_sd_ck_p,          -- : out   std_logic;
            -- Path to allow connection to top DCM connection
            sd_ck_fb        => tb_sd_ck_fb,         -- : in    std_logic;
            -- Intel StrataFlash Parallel NOR Flash (SF)
            sf_a            => tb_sf_a,             -- : out   std_logic_vector(23 downto 0);
            sf_byte         => tb_sf_byte,          -- : out   std_logic;
            sf_ce0          => tb_sf_ce0,           -- : out   std_logic;
            sf_d            => tb_sf_d,             -- : inout std_logic_vector(15 downto 1);
            sf_oe           => tb_sf_oe,            -- : out   std_logic;
            sf_sts          => tb_sf_sts,           -- : in    std_logic;
            sf_we           => tb_sf_we,            -- : out   std_logic;
            -- STMicro SPI serial Flash (SPI)
            spi_mosi        => tb_spi_mosi,         -- : out   std_logic;
            spi_miso        => tb_spi_miso,         -- : in    std_logic;
            spi_sck         => tb_spi_sck,          -- : out   std_logic;
            spi_ss_b        => tb_spi_ss_b,         -- : out   std_logic;
            spi_alt_cs_jp11 => tb_spi_alt_cs_jp11,  -- : out   std_logic;
            -- Slide Switches (SW)
            sw              => tb_sw,               -- : in    std_logic_vector(3 downto 0);
            -- VGA Port (VGA)
            vga_blue        => tb_vga_blue,         -- : out   std_logic;
            vga_green       => tb_vga_green,        -- : out   std_logic;
            vga_hsync       => tb_vga_hsync,        -- : out   std_logic;
            vga_red         => tb_vga_red,          -- : out   std_logic;
            vga_vsync       => tb_vga_vsync,        -- : out   std_logic;
            -- Xilinx CPLD (XC)
            xc_cmd          => tb_xc_cmd,           -- : out   std_logic_vector(1 downto 0);
            xc_cpld_en      => tb_xc_cpld_en,       -- : out   std_logic;
            xc_d            => tb_xc_d,             -- : inout std_logic_vector(2 downto 0);
            xc_trig         => tb_xc_trig,          -- : in    std_logic;
            xc_gck0         => tb_xc_gck0,          -- : inout std_logic;
            gclk10          => tb_gclk10            -- : inout std_logic
            );


    -- check for simulation stopping
    process (tb_stop_simulation)
    begin
        if tb_stop_simulation = '1' then
            report "Simulation end." severity note;
            simulation_run <= false;
        end if;
    end process;


end architecture testbench;
