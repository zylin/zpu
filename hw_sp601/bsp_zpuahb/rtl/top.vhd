-- toplevel
-- für SP601
-- 
-- enthält alle buffer/treiber für die FPGA-Pins
--
--

--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601_amba/rtl/top.vhd $
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.bufg;
use unisim.vcomponents.iddr2;
use unisim.vcomponents.ibufgds_diff_out;
use unisim.vcomponents.ibufgds;
use unisim.vcomponents.ibufds;
use unisim.vcomponents.dcm_sp;
use unisim.vcomponents.bufgmux;


entity top is
    port (
        -- pragma translate_off
        simulation_break          : out   std_logic;
        -- pragma translate_on
        cpu_reset                 : in    std_logic; -- SW9 pushbutton (active-high)
        --
        -- DDR2 memory 128 MB
        ddr2_a                    : out   std_logic_vector(12 downto 0);
        ddr2_ba                   : out   std_logic_vector(2 downto 0);
        ddr2_cas_b                : out   std_logic;
        ddr2_ras_b                : out   std_logic;
        ddr2_we_b                 : out   std_logic;
        ddr2_cke                  : out   std_logic;
        ddr2_clk_n                : out   std_logic; 
        ddr2_clk_p                : out   std_logic; 
        ddr2_dq                   : inout std_logic_vector(15 downto 0);
        ddr2_ldm                  : out   std_logic;
        ddr2_udm                  : out   std_logic;
        ddr2_ldqs_n               : inout std_logic;
        ddr2_ldqs_p               : inout std_logic;
        ddr2_udqs_n               : inout std_logic;
        ddr2_udqs_p               : inout std_logic;
        ddr2_odt                  : out   std_logic;
        --                                
        -- flash memory                        
        flash_a                   : out   std_logic_vector(24 downto 0);
        flash_d                   : inout std_logic_vector(7  downto 3);
        --
        fpga_d0_din_miso_miso1    : inout std_logic; -- dual use
        fpga_d1_miso2             : inout std_logic; -- dual use
        fpga_d2_miso3             : inout std_logic; -- dual use
        flash_we_b                : out   std_logic;
        flash_oe_b                : out   std_logic;
        flash_ce_b                : out   std_logic;
        --
        -- FCM connector
        -- M2C   Mezzanine to Carrier
        -- C2M   Carrier to Mezzanine
        fmc_clk0_m2c_n            : in    std_logic;
        fmc_clk0_m2c_p            : in    std_logic;
        fmc_clk1_m2c_n            : in    std_logic;
        fmc_clk1_m2c_p            : in    std_logic;
        -- IIC addresses:
        -- M24C08:                 1010100..1010111
        -- 2kb EEPROM on FMC card: 1010010
        iic_scl_main              : inout std_logic;
        iic_sda_main              : inout std_logic;
        fmc_la00_cc_n             : inout std_logic;
        fmc_la00_cc_p             : inout std_logic;
        fmc_la01_cc_n             : inout std_logic;
        fmc_la01_cc_p             : inout std_logic;
        fmc_la02_n                : inout std_logic;
        fmc_la02_p                : inout std_logic;
        fmc_la03_n                : inout std_logic;
        fmc_la03_p                : inout std_logic;
        fmc_la04_n                : inout std_logic;
        fmc_la04_p                : inout std_logic;
        fmc_la05_n                : inout std_logic;
        fmc_la05_p                : inout std_logic;
        fmc_la06_n                : inout std_logic;
        fmc_la06_p                : inout std_logic;
        fmc_la07_n                : inout std_logic;
        fmc_la07_p                : inout std_logic;
        fmc_la08_n                : inout std_logic;
        fmc_la08_p                : inout std_logic;
        fmc_la09_n                : inout std_logic;
        fmc_la09_p                : inout std_logic;
        fmc_la10_n                : inout std_logic;
        fmc_la10_p                : inout std_logic;
        fmc_la11_n                : inout std_logic;
        fmc_la11_p                : inout std_logic;
        fmc_la12_n                : inout std_logic;
        fmc_la12_p                : inout std_logic;
        fmc_la13_n                : inout std_logic;
        fmc_la13_p                : inout std_logic;
        fmc_la14_n                : inout std_logic;
        fmc_la14_p                : inout std_logic;
        fmc_la15_n                : inout std_logic;
        fmc_la15_p                : inout std_logic;
        fmc_la16_n                : inout std_logic;
        fmc_la16_p                : inout std_logic;
        fmc_la17_cc_n             : inout std_logic;
        fmc_la17_cc_p             : inout std_logic;
        fmc_la18_cc_n             : inout std_logic;
        fmc_la18_cc_p             : inout std_logic;
        fmc_la19_n                : inout std_logic;
        fmc_la19_p                : inout std_logic;
        fmc_la20_n                : inout std_logic;
        fmc_la20_p                : inout std_logic;
        fmc_la21_n                : inout std_logic;
        fmc_la21_p                : inout std_logic;
        fmc_la22_n                : inout std_logic;
        fmc_la22_p                : inout std_logic;
        fmc_la23_n                : inout std_logic;
        fmc_la23_p                : inout std_logic;
        fmc_la24_n                : inout std_logic;
        fmc_la24_p                : inout std_logic;
        fmc_la25_n                : inout std_logic;
        fmc_la25_p                : inout std_logic;
        fmc_la26_n                : inout std_logic;
        fmc_la26_p                : inout std_logic;
        fmc_la27_n                : inout std_logic;
        fmc_la27_p                : inout std_logic;
        fmc_la28_n                : inout std_logic;
        fmc_la28_p                : inout std_logic;
        fmc_la29_n                : inout std_logic;
        fmc_la29_p                : inout std_logic;
        fmc_la30_n                : inout std_logic;
        fmc_la30_p                : inout std_logic;
        fmc_la31_n                : inout std_logic;
        fmc_la31_p                : inout std_logic;
        fmc_la32_n                : inout std_logic;
        fmc_la32_p                : inout std_logic;
        fmc_la33_n                : inout std_logic;
        fmc_la33_p                : inout std_logic;
        fmc_prsnt_m2c_l           : in    std_logic;
        fmc_pwr_good_flash_rst_b  : out   std_logic; -- multiple destinations: 1 of Q2 (LED DS1 driver), U1 AB2 FPGA_PROG (through series R260 DNP), 44 of U25
        --
        fpga_awake                : out   std_logic;
        fpga_cclk                 : out   std_logic;
        fpga_cmp_clk              : in    std_logic;
        fpga_cmp_cs_b             : in    std_logic;
        fpga_cmp_mosi             : in    std_logic;
        --
        fpga_hswapen              : in    std_logic;
        fpga_init_b               : out   std_logic; -- low active
        fpga_m0_cmp_miso          : in    std_logic; -- mode DIP switch SW1 active high
        fpga_m1                   : in    std_logic; -- mode DIP switch SW1 active high
        fpga_mosi_csi_b_miso0     : inout std_logic;
        fpga_onchip_term1         : inout std_logic;
        fpga_onchip_term2         : inout std_logic;
        --fpga_suspend              : in    std_logic;
        fpga_vtemp                : in    std_logic;
        --
        -- GPIOs
        gpio_button               : in    std_logic_vector(3 downto 0); -- active high
        gpio_header_ls            : inout std_logic_vector(7 downto 0); -- 
        gpio_led                  : out   std_logic_vector(3 downto 0);
        gpio_switch               : in    std_logic_vector(3 downto 0); -- active high
        --
        -- Ethernet Gigabit PHY, 
        -- default settings:
        -- phy address    = 0b00111
        -- ANEG[3..0]     = "1111"
        -- ENA_XC         = 1
        -- DIS_125        = 1
        -- HWCFG_MD[3..0] = "1111"
        -- DIS_FC         = 1
        -- DIS_SLEEP      = 1
        -- SEL_BDT        = 0
        -- INT_POL        = 1
        -- 75/50Ohm       = 0
        phy_col                   : in    std_logic;
        phy_crs                   : in    std_logic;
        phy_int                   : out   std_logic;
        phy_mdc                   : out   std_logic;
        phy_mdio                  : inout std_logic;
        phy_reset                 : out   std_logic;
        phy_rxclk                 : in    std_logic;
        phy_rxctl_rxdv            : in    std_logic;
        phy_rxd                   : in    std_logic_vector(7 downto 0);
        phy_rxer                  : in    std_logic;
        phy_txclk                 : in    std_logic;
        phy_txctl_txen            : out   std_logic;
        phy_txc_gtxclk            : out   std_logic;
        phy_txd                   : out   std_logic_vector(7 downto 0);
        phy_txer                  : out   std_logic;
        --
        --
        spi_cs_b                  : out   std_logic;
        --
        -- 200 MHz oscillator, jitter 50 ppm
        sysclk_n                  : in    std_logic;
        sysclk_p                  : in    std_logic;
        --
        -- RS232 via USB
        usb_1_cts                 : out   std_logic;  -- function: RTS output
        usb_1_rts                 : in    std_logic;  -- function: CTS input
        usb_1_rx                  : out   std_logic;  -- function: TX data out
        usb_1_tx                  : in    std_logic;  -- function: RX data in
        --
        --  27 MHz, oscillator socket
        user_clock               : in    std_logic;
        --
        -- user clock provided per SMA
        user_sma_clock_p         : inout std_logic;
        user_sma_clock_n         : inout std_logic
    );
end entity top;




library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.memctrl.all; -- spimctrl types


architecture rtl of top is

    constant system_frequency_c : natural := 200_000_000;

    function simulation_active return std_ulogic is
        variable result : std_ulogic;
    begin
        result := '0';
        -- pragma translate_off
        result := '1';
        -- pragma translate_on
        return result;
    end function simulation_active;

    --
    -- signal definitions to resolve inout signals
    --
    signal sys_clk                            : std_ulogic;
    signal clk_box                            : std_ulogic;
    signal clk_gtx_125                        : std_ulogic;
    --
    signal reset_shreg                        : std_ulogic_vector(3 downto 0) := (others => '1');
    signal reset                              : std_ulogic := '1';
    signal reset_n                            : std_ulogic := '0';
    --
    -- box input signals
    signal uarti                              : uart_in_type;
    signal gpioi                              : gpio_in_type;
    signal fmc_i2ci                           : i2c_in_type;
    signal spmi                               : spimctrl_in_type;
    signal memi                               : memory_in_type;
    signal ethi                               : eth_in_type;
    --
    -- box output signals
    signal box_i0_break                       : std_ulogic;
    signal box_i0_uarto                       : uart_out_type;
    signal box_i0_gpioo                       : gpio_out_type;
    signal box_i0_fmc_i2co                    : i2c_out_type;
    signal box_i0_spmo                        : spimctrl_out_type;
    signal box_i0_memo                        : memory_out_type;
    signal box_i0_etho                        : eth_out_type;


begin


    ------------------------------------------------------------ 
    -- clock stuff
    --
    clk_driver_b : block
        signal clk_fb0           : std_ulogic;
        signal dcm_sp_i0_clk0    : std_ulogic;
        signal dcm_sp_i0_clkfx   : std_ulogic;
        signal dcm_sp_i0_clkdv   : std_ulogic;
        signal dcm_sp_i0_clkdv_n : std_ulogic;
        --
        signal clk_fb1           : std_ulogic;
        signal dcm_sp_i1_clk0    : std_ulogic;
        signal dcm_sp_i1_clkfx   : std_ulogic;

    begin

        -- global differential input buffer 
        ibufgds_i0 : ibufgds
            generic map (
                diff_term => true
            )
            port map (
                i  => sysclk_p,
                ib => sysclk_n,
                o  => sys_clk
            );
        
        -- DCM
        dcm_sp_i0: dcm_sp
            generic map (
                clkin_divide_by_2 => false,
                clkdv_divide      => 8.0,
                clkfx_multiply    => 3,
                clkfx_divide      => 4,
                clk_feedback      => "1x"
            )
            port map (
                clkin => sys_clk,
                clk0  => dcm_sp_i0_clk0,
                clkdv => dcm_sp_i0_clkdv,
                clkfx => dcm_sp_i0_clkfx,
                clkfb => clk_fb0
            );
        
        clk_fb0   <= dcm_sp_i0_clk0;
        

        -- DCM for GTX clock (ethernet)
        dcm_sp_i1: dcm_sp
        generic map (
            startup_wait      => true, -- wait with DONE till locked
            clkfx_multiply    => 5,
            clkfx_divide      => 8,
            clk_feedback      => "1x"
        )
        port map (
            clkin => sys_clk,
            clk0  => dcm_sp_i1_clk0,
            clkfx => dcm_sp_i1_clkfx,
            clkfb => clk_fb1
        );
        
        clk_fb1     <= dcm_sp_i1_clk0;
        
        -- resulting clocks

        --clk_box     <= dcm_sp_i0_clk0;   -- 200 MHz, is to much
        clk_box     <= dcm_sp_i1_clkfx;    -- 125 MHz
        clk_gtx_125 <= dcm_sp_i1_clkfx;    -- 125 MHz
       
    end block;


    ------------------------------------------------------------ 
    -- reset generation
    reset_generator_p: process
    begin
        wait until rising_edge( clk_box);
        reset_shreg <= reset_shreg(reset_shreg'left-1 downto 0) & '0';
        reset       <= reset_shreg(reset_shreg'left);
        if cpu_reset = '1' then
            reset_shreg <= (others => '1');
        end if;
    end process;
    reset_n <= not reset;




--  chipscope_i0 : chipscope
--      port map (
--          clk  => adc_clk_buf,                          --: in std_ulogic;
--          data => adc_debug & x"00" & adc_data_16bit,   --: in std_ulogic_vector(31 downto 0);
--          trig => '1'                                   --: in std_ulogic
--          );


    -- default output drivers
    --
    fmc_la00_cc_n            <= 'Z';
    fmc_la00_cc_p            <= 'Z';
    fmc_la01_cc_n            <= 'Z';
    fmc_la01_cc_p            <= 'Z';
    fmc_la02_n               <= 'Z';
    fmc_la02_p               <= 'Z';
    fmc_la03_n               <= 'Z';
    fmc_la03_p               <= 'Z';
    fmc_la04_n               <= 'Z';
    fmc_la04_p               <= 'Z';
    fmc_la05_n               <= 'Z';
    fmc_la05_p               <= 'Z';
    fmc_la06_n               <= 'Z';
    fmc_la06_p               <= 'Z';
    fmc_la07_n               <= 'Z';
    fmc_la07_p               <= 'Z';
    fmc_la08_n               <= 'Z';
    fmc_la08_p               <= 'Z';
    fmc_la09_n               <= 'Z';
    fmc_la09_p               <= 'Z';
    fmc_la10_n               <= 'Z';
    fmc_la10_p               <= 'Z';
    fmc_la11_n               <= 'Z';
    fmc_la11_p               <= 'Z';
    fmc_la12_n               <= 'Z';
    fmc_la12_p               <= 'Z';
    fmc_la13_n               <= 'Z';
    fmc_la13_p               <= 'Z';
    fmc_la14_n               <= 'Z';
    fmc_la14_p               <= 'Z';
    fmc_la15_n               <= 'Z';
    fmc_la15_p               <= 'Z';
    fmc_la16_n               <= 'Z';
    fmc_la16_p               <= 'Z';
    fmc_la17_cc_n            <= 'Z';
    fmc_la17_cc_p            <= 'Z';
    fmc_la18_cc_n            <= 'Z';
    fmc_la18_cc_p            <= 'Z';
    fmc_la19_n               <= 'Z';
    fmc_la19_p               <= 'Z';
    fmc_la20_n               <= 'Z';
    fmc_la20_p               <= 'Z';
    fmc_la21_n               <= 'Z';
    fmc_la21_p               <= 'Z';
    fmc_la22_n               <= 'Z';
    fmc_la22_p               <= 'Z';
    fmc_la23_n               <= 'Z';
    fmc_la23_p               <= 'Z';
    fmc_la24_n               <= 'Z';
    fmc_la24_p               <= 'Z';
    fmc_la25_n               <= 'Z';
    fmc_la25_p               <= 'Z';
    fmc_la26_n               <= 'Z';
    fmc_la26_p               <= 'Z';
    fmc_la27_n               <= 'Z';
    fmc_la27_p               <= 'Z';
    fmc_la28_n               <= 'Z';
    fmc_la28_p               <= 'Z';
    fmc_la29_n               <= 'Z';
    fmc_la29_p               <= 'Z';
    fmc_la30_n               <= 'Z';
    fmc_la30_p               <= 'Z';
    fmc_la31_n               <= 'Z';
    fmc_la31_p               <= 'Z';
    fmc_la32_n               <= 'Z';
    fmc_la32_p               <= 'Z';
    fmc_la33_n               <= 'Z';
    fmc_la33_p               <= 'Z';
    fpga_awake               <= 'Z';
    fpga_init_b              <= '1';
    fpga_onchip_term1        <= 'Z';
    fpga_onchip_term2        <= 'Z';
    --
    ddr2_a                   <= (others => '1');
    ddr2_ba                  <= (others => '1');
    ddr2_cas_b               <= '1';
    ddr2_ras_b               <= '1';
    ddr2_we_b                <= '1';
    ddr2_cke                 <= '0';
    ddr2_clk_n               <= '0';
    ddr2_clk_p               <= '1';
    ddr2_dq                  <= (others => 'Z');
    ddr2_ldm                 <= '0';
    ddr2_udm                 <= '0';
    ddr2_ldqs_n              <= 'Z';
    ddr2_ldqs_p              <= 'Z';
    ddr2_udqs_n              <= 'Z';
    ddr2_udqs_p              <= 'Z';
    ddr2_odt                 <= '1';
    --
    -- controlled by greth
    --phy_int                  <= 'Z';
    --phy_mdc                  <= '0';
    --phy_mdio                 <= 'Z';
    --phy_reset                <= '0';
    --phy_txc_gtxclk           <= '0';
    --phy_txctl_txen           <= '0';
    --phy_txd                  <= (others => '1');
    --phy_txer                 <= '0';
    --
    user_sma_clock_p         <= 'Z';
    user_sma_clock_n         <= 'Z';

    
    ------------------------------------------------------------ 
    -- uart input
    uarti.rxd    <= usb_1_tx;  -- function: RX data in
    uarti.ctsn   <= usb_1_rts; -- not( usb_1_rts); function: CTS input
    uarti.extclk <= '0';
    -- uart output
    usb_1_rx   <= box_i0_uarto.txd;  -- function: TX data out
    usb_1_cts  <= box_i0_uarto.rtsn; -- function: RTS
   

    ------------------------------------------------------------ 
    -- gpio pads
    -- input
    gpioi.sig_in            <= (others => '0');
    gpioi.sig_en            <= (others => '0');
    gpioi.din( 3 downto  0) <= std_logic_vector( gpio_switch);
    gpioi.din( 7 downto  4) <= gpio_button;
    gpioi.din(15 downto  8) <= gpio_header_ls;
    gpioi.din(30 downto 16) <= (others => '0');
    gpioi.din(31)           <= simulation_active;
    -- output
    -- placement on board: LED0, LED1, LED2, LED3
    gpio_led       <= box_i0_gpioo.dout( 3 downto 0);
    gpio_header_ls <= box_i0_gpioo.dout(15 downto 8);
    fpga_awake     <= not box_i0_gpioo.dout( 0);
   

    ------------------------------------------------------------ 
    -- fmc/main i2c io pads
    fmc_i2ci.scl  <= iic_scl_main;
    iic_scl_main  <= box_i0_fmc_i2co.scl when box_i0_fmc_i2co.scloen = '0' else 'Z';

    fmc_i2ci.sda  <= iic_sda_main;
    iic_sda_main  <= box_i0_fmc_i2co.sda when box_i0_fmc_i2co.sdaoen = '0' else 'Z';
   

    ------------------------------------------------------------ 
    -- SPI memory pads
    -- SPI X4 (Winbond W25Q64VSFIG) 64-Mbit flash memory 
    -- in
    spmi.miso             <= fpga_d0_din_miso_miso1;  -- shared with flash data
    spmi.mosi             <= fpga_mosi_csi_b_miso0;   -- bidi for 2x mode
    spmi.cd               <= '0';        -- card detection
    -- out
    fpga_d2_miso3         <= '1' when box_i0_spmo.csn = '0' else 'Z'; -- /hold
    fpga_d1_miso2         <= '0' when box_i0_spmo.csn = '0' else 'Z'; -- /write_protect
    fpga_cclk             <= box_i0_spmo.sck;
    fpga_mosi_csi_b_miso0 <= box_i0_spmo.mosi when box_i0_spmo.mosioen = '0' else 'Z';
    spi_cs_b              <= '0'              when box_i0_spmo.csn     = '0' else 'Z';


    ------------------------------------------------------------ 
    -- BPI parallel flash
    -- in
    memi.brdyn               <= '1';               -- bus ready strobe
    memi.bexcn               <= '1';               -- bus exception
    memi.wrn(3 downto 0)     <= "1111";            -- sram write enable feedback
    memi.bwidth(1 downto 0)  <= "00";              -- data width of prom area = 8 bit
    memi.sd                  <= (others => '1');   -- sdram separate data bus
    memi.data                <= flash_d & fpga_d2_miso3 & fpga_d1_miso2 & fpga_d0_din_miso_miso1 & x"000000";
    memi.cb                  <= (others => '1');
    memi.scb                 <= (others => '1');
    memi.writen              <= '1';
    memi.edac                <= '1';

    -- inout
    fpga_d0_din_miso_miso1   <= box_i0_memo.data(24)           when box_i0_memo.bdrive(0) = '0' else 'Z';
    fpga_d1_miso2            <= box_i0_memo.data(25)           when box_i0_memo.bdrive(0) = '0' else 'Z'; 
    fpga_d2_miso3            <= box_i0_memo.data(26)           when box_i0_memo.bdrive(0) = '0' else 'Z'; 
    flash_d(7 downto 3)      <= box_i0_memo.data(31 downto 27) when box_i0_memo.bdrive(0) = '0' else "ZZZZZ";
    -- out
    fmc_pwr_good_flash_rst_b <= reset_n;
    flash_ce_b               <= box_i0_memo.romsn(0);
    flash_oe_b               <= box_i0_memo.oen;
    flash_we_b               <= box_i0_memo.writen;

    flash_a                  <= box_i0_memo.address(24 downto 0);


    ------------------------------------------------------------ 
    -- ethernet (10/100/1000)
    -- in
    ethi.gtx_clk     <= clk_gtx_125;
    ethi.rmii_clk    <= '0';
    ethi.tx_clk      <= phy_txclk;
    ethi.rx_clk      <= phy_rxclk;
    ethi.rxd         <= phy_rxd;
    ethi.rx_dv       <= phy_rxctl_rxdv;
    ethi.rx_er       <= phy_rxer;
    ethi.rx_col      <= phy_col;
    ethi.rx_crs      <= phy_crs;
    ethi.mdio_i      <= phy_mdio;
    ethi.mdint       <= '0';
    ethi.phyrstaddr  <= "00111";
    ethi.edcladdr    <= (others => '0');
    ethi.edclsepahb  <= '0';
    ethi.edcldisable <= '0';
    -- out
    phy_reset        <= '0';
    phy_int          <= 'Z';
    phy_txc_gtxclk   <= clk_gtx_125;
    phy_txd          <= box_i0_etho.txd;
    phy_txctl_txen   <= box_i0_etho.tx_en;
    phy_txer         <= box_i0_etho.tx_er;
    phy_mdc          <= box_i0_etho.mdc;
    -- inout         
    phy_mdio         <= box_i0_etho.mdio_o when box_i0_etho.mdio_oe = '0' else 'Z';


    ------------------------------------------------------------ 
    -- box system
    box_i0: entity work.box
        port map (
            clk          => clk_box,            --: in    std_ulogic;
            reset_n      => reset_n,            --: in    std_ulogic;
            break        => box_i0_break,       --: out   std_ulogic;        -- to stop simulation
            --                                  
            uarti        => uarti,              --: in    uart_in_type;
            uarto        => box_i0_uarto,       --: out   uart_out_type;
            --                                  
            gpioi        => gpioi,              --: in    gpio_in_type;
            gpioo        => box_i0_gpioo,       --: out   gpio_out_type;
            --                                  
            fmc_i2ci     => fmc_i2ci,           --: in    i2c_in_type;
            fmc_i2co     => box_i0_fmc_i2co,    --: out   i2c_out_type;
            --
            spmi         => spmi,               --: in    spmictrl_in_type;
            spmo         => box_i0_spmo,        --: out   spmictrl_out_type;
            --  
            memi         => memi,               --: in    memory_in_type;
            memo         => box_i0_memo,        --: out   memory_out_type;
            --
            ethi         => ethi,               --: in    eth_in_type;       -- ethernet PHY
            etho         => box_i0_etho         --: out   eth_out_type
        );
        
    ------------------------------------------------------------ 
    -- break for simulation
    --
    -- pragma translate_off
    simulation_break <= box_i0_break;
    -- pragma translate_on

    
end architecture rtl;
