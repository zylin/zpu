
library ieee;
use ieee.std_logic_1164.all;

library rena3;


entity rena3_testboard is
    port (
        simulation_run        : boolean := true;
        fmc_lpc_row_c         : inout std_logic_vector(40 downto 1);
        fmc_lpc_row_d         : inout std_logic_vector(40 downto 1);
        fmc_lpc_row_g         : inout std_logic_vector(40 downto 1);
        fmc_lpc_row_h         : inout std_logic_vector(40 downto 1)
    );
end entity rena3_testboard;


architecture model of rena3_testboard is
    
    constant dds_clk_period                : time       := ( 1 sec/ 100_000_000); -- 100 MHz
                                           
    signal dds_clk                         : std_ulogic := '1';
    signal reset                           : std_ulogic;
                                           
    signal test_pulse_gen_i0_pulse         : real;
                                           
    signal dds_model_i0_vu                 : real;
    signal dds_model_i0_vv                 : real;

    signal rena3_model_i0_ts               : std_ulogic;
    signal rena3_model_i0_tf               : std_ulogic;
    signal rena3_model_i0_fout             : std_ulogic;
    signal rena3_model_i0_sout             : std_ulogic;
    signal rena3_model_i0_tout             : std_ulogic;

    signal rena3_model_i1_ts               : std_ulogic;
    signal rena3_model_i1_tf               : std_ulogic;
    signal rena3_model_i1_fout             : std_ulogic;
    signal rena3_model_i1_sout             : std_ulogic;
    signal rena3_model_i1_tout             : std_ulogic;
    --
    signal analog_p                        : real;
    signal analog_n                        : real;
    signal rena3_model_i0_aoutp            : real;
    signal rena3_model_i0_aoutn            : real;
    signal rena3_model_i1_aoutp            : real;
    signal rena3_model_i1_aoutn            : real;
    --
    signal adc_model_i0_digital            : std_logic_vector(13 downto 0);
    signal adc_model_i0_otr                : std_logic;

    signal controller_top_i0_rena3_cshift  : std_ulogic;
    signal controller_top_i0_rena3_cin     : std_ulogic; 
    signal controller_top_i0_rena3_cs      : std_ulogic;    
    signal controller_top_i0_rena3_read    : std_ulogic;
    signal controller_top_i0_rena3_tin     : std_ulogic;
    signal controller_top_i0_rena3_sin     : std_ulogic;
    signal controller_top_i0_rena3_fin     : std_ulogic;
    signal controller_top_i0_rena3_shrclk  : std_ulogic;
    signal controller_top_i0_rena3_fhrclk  : std_ulogic;
    signal controller_top_i0_rena3_acquire : std_ulogic;
    signal controller_top_i0_rena3_cls     : std_ulogic;
    signal controller_top_i0_rena3_clf     : std_ulogic;
    signal controller_top_i0_rena3_tclk    : std_ulogic;
    signal controller_top_i0_break         : std_ulogic;





begin
   
    -- dds clock generator 
    dds_clk <= not dds_clk after dds_clk_period/2 when simulation_run;

    --------------------
    test_pulse_gen_i0: entity work.test_pulse_gen
        port map(
            trigger => fmc_lpc_row_c(27), -- fmc_testgen
            pulse   => test_pulse_gen_i0_pulse 
        );

    --------------------
    dds_model_i0: entity work.dds_model
        port map(
            run     => simulation_run,
        --  clk     => dds_clk, -- TODO: add
            vu      => dds_model_i0_vu,
            vv      => dds_model_i0_vv
        );
   
    --------------------
    -- TODO generate C* stimuli from FPGA
    -- TODO generate CLF stimuli from FPGA
    -- TODO generate slow token register stimuli from FPGA
    -- TODO generate fast token register stimuli from FPGA
    -- TODO generate token stuff stimuli from FPGA
    rena3_model_i0: entity work.rena3_model
        port map(
            TEST        => test_pulse_gen_i0_pulse, --   : in  real;
            VU          => dds_model_i0_vu,         --   : in  real;
            VV          => dds_model_i0_vv,         --   : in  real;
            DETECTOR_IN => (others => 0.0),         --   : in  real_array(0 to 35); -- Detector inputs pins
            AOUTP       => rena3_model_i0_aoutp,    --   : out real;
            AOUTN       => rena3_model_i0_aoutn,    --   : out real;
            CSHIFT      => fmc_lpc_row_c(19),       --   : in  std_ulogic; -- fmc_rena_01_cshift
            CIN         => fmc_lpc_row_d(20),       --   : in  std_ulogic; -- fmc_rena_01_cin
            CS          => fmc_lpc_row_c(18),       --   : in  std_ulogic; -- fmc_rena_0_cs
            TS_N        => fmc_lpc_row_d(09),       --   : out std_ulogic;
            TS_P        => fmc_lpc_row_d(08),       --   : out std_ulogic;
            TF_N        => fmc_lpc_row_c(11),       --   : out std_ulogic;
            TF_P        => fmc_lpc_row_c(10),       --   : out std_ulogic;
            FOUT        => fmc_lpc_row_c(15),       --   : out std_ulogic;
            SOUT        => fmc_lpc_row_d(18),       --   : out std_ulogic;
            TOUT        => fmc_lpc_row_c(14),       --   : out std_ulogic;
            READ        => fmc_lpc_row_c(23),       --   : in  std_ulogic; -- fmc_rena_0_read
            TIN         => fmc_lpc_row_c(26),       --   : in  std_ulogic;
            SIN         => fmc_lpc_row_d(27),       --   : in  std_ulogic;
            FIN         => fmc_lpc_row_d(28),       --   : in  std_ulogic;
            SHRCLK      => fmc_lpc_row_d(24),       --   : in  std_ulogic;
            FHRCLK      => fmc_lpc_row_d(23),       --   : in  std_ulogic;
            ACQUIRE_P   => fmc_lpc_row_d(11),       --   : in  std_ulogic;
            ACQUIRE_N   => fmc_lpc_row_d(12),       --   : in  std_ulogic;
            CLS_P       => fmc_lpc_row_d(14),       --   : in  std_ulogic;
            CLS_N       => fmc_lpc_row_d(15),       --   : in  std_ulogic;
            CLF         => fmc_lpc_row_d(21),       --   : in  std_ulogic
            TCLK        => fmc_lpc_row_c(22)        --   : in  std_ulogic
        );


    rena3_model_i1: entity work.rena3_model
        port map(
            TEST        => test_pulse_gen_i0_pulse, --   : in  real;
            VU          => dds_model_i0_vu,         --   : in  real;
            VV          => dds_model_i0_vv,         --   : in  real;
            DETECTOR_IN => (others => 0.0),         --   : in  real_array(0 to 35);
            AOUTP       => rena3_model_i1_aoutp,    --   : out real;
            AOUTN       => rena3_model_i1_aoutn,    --   : out real;
            CSHIFT      => fmc_lpc_row_c(19),       --   : in  std_ulogic; -- fmc_rena_01_cshift
            CIN         => fmc_lpc_row_d(20),       --   : in  std_ulogic; -- fmc_rena_01_cin
            CS          => fmc_lpc_row_h(23),       --   : in  std_ulogic; -- fmc_rena_1_cs
            TS_N        => fmc_lpc_row_g(28),       --   : out std_ulogic;
            TS_P        => fmc_lpc_row_g(27),       --   : out std_ulogic;
            TF_N        => fmc_lpc_row_h(29),       --   : out std_ulogic;
            TF_P        => fmc_lpc_row_h(28),       --   : out std_ulogic;
            FOUT        => open,                    --   : out std_ulogic;
            SOUT        => open,                    --   : out std_ulogic;
            TOUT        => open,                    --   : out std_ulogic;
            READ        => fmc_lpc_row_h(31),       --   : in  std_ulogic; -- fmc_rena_1_read
            TIN         => '0',                     --   : in  std_ulogic; -- chain with rena_0
            SIN         => '0',                     --   : in  std_ulogic; -- chain with rena_0
            FIN         => '0',                     --   : in  std_ulogic; -- chain with rena_0
            SHRCLK      => fmc_lpc_row_d(24),       --   : in  std_ulogic;
            FHRCLK      => fmc_lpc_row_d(23),       --   : in  std_ulogic;
            ACQUIRE_P   => fmc_lpc_row_h(25),       --   : in  std_ulogic;
            ACQUIRE_N   => fmc_lpc_row_h(26),       --   : in  std_ulogic;
            CLS_P       => fmc_lpc_row_g(24),       --   : in  std_ulogic;
            CLS_N       => fmc_lpc_row_g(25),       --   : in  std_ulogic;
            CLF         => fmc_lpc_row_g(30),       --   : in  std_ulogic;
            TCLK        => fmc_lpc_row_c(22)        --   : in  std_ulogic
        );


--  controller_top_i0: controller_top
--      port map (
--      clk            => clk,                             --   : in  std_ulogic;
--      reset          => reset,                           --   : in  std_ulogic;
--      -- rena 3                                          
--      rena3_ts       => rena3_model_i0_ts,               --   : in  std_ulogic;
--      rena3_tf       => rena3_model_i0_tf,               --   : in  std_ulogic;
--      rena3_fout     => rena3_model_i0_fout,             --   : in  std_ulogic;
--      rena3_sout     => rena3_model_i0_sout,             --   : in  std_ulogic;
--      rena3_tout     => rena3_model_i0_tout,             --   : in  std_ulogic;
--      --                                                 
--      rena3_chsift   => controller_top_i0_rena3_cshift,  --   : out std_ulogic;
--      rena3_cin      => controller_top_i0_rena3_cin,     --   : out std_ulogic;
--      rena3_cs       => controller_top_i0_rena3_cs,      --   : out std_ulogic;
--      rena3_read     => controller_top_i0_rena3_read,    --   : out std_ulogic;
--      rena3_tin      => controller_top_i0_rena3_tin,     --   : out std_ulogic;
--      rena3_sin      => controller_top_i0_rena3_sin,     --   : out std_ulogic;
--      rena3_fin      => controller_top_i0_rena3_fin,     --   : out std_ulogic;
--      rena3_shrclk   => controller_top_i0_rena3_shrclk,  --   : out std_ulogic;
--      rena3_fhrclk   => controller_top_i0_rena3_fhrclk,  --   : out std_ulogic;
--      rena3_acquire  => controller_top_i0_rena3_acquire, --   : out std_ulogic;
--      rena3_cls      => controller_top_i0_rena3_cls,     --   : out std_ulogic;
--      rena3_clf      => controller_top_i0_rena3_clf,     --   : out std_ulogic;
--      rena3_tclk     => controller_top_i0_rena3_tclk,    --   : out std_ulogic;
--      --
--      break          => controller_top_i0_break          --   : out std_ulogic
--  );

    -- add values from both renas
    analog_p <= rena3_model_i0_aoutp + rena3_model_i1_aoutp;
    analog_n <= rena3_model_i0_aoutn + rena3_model_i1_aoutn;

    adc_model_i0: entity work.adc_model
        port map (
            clk      => fmc_lpc_row_h(11),    -- : in std_logic;
            analog_p => rena3_model_i0_aoutp, -- : in real;
            analog_n => rena3_model_i0_aoutn, -- : in real;
            digital  => adc_model_i0_digital, -- : out std_logic_vector(13 downto 0);
            otr      => adc_model_i0_otr      -- : out std_logic;
        );
    fmc_lpc_row_g(12) <= adc_model_i0_digital(13);
    fmc_lpc_row_g(13) <= adc_model_i0_digital(12);
    fmc_lpc_row_h(13) <= adc_model_i0_digital(11);
    fmc_lpc_row_h(14) <= adc_model_i0_digital(10);
    fmc_lpc_row_g(15) <= adc_model_i0_digital( 9);
    fmc_lpc_row_g(16) <= adc_model_i0_digital( 8);
    fmc_lpc_row_h(16) <= adc_model_i0_digital( 7);
    fmc_lpc_row_h(17) <= adc_model_i0_digital( 6);
    fmc_lpc_row_g(18) <= adc_model_i0_digital( 5);
    fmc_lpc_row_g(19) <= adc_model_i0_digital( 4);
    fmc_lpc_row_h(19) <= adc_model_i0_digital( 3);
    fmc_lpc_row_h(20) <= adc_model_i0_digital( 2);
    fmc_lpc_row_g(21) <= adc_model_i0_digital( 1);
    fmc_lpc_row_g(22) <= adc_model_i0_digital( 0);
    fmc_lpc_row_h(22) <= adc_model_i0_otr;



    -- avoid simulation warnings
    fmc_lpc_row_c <= (others => 'Z');
    fmc_lpc_row_d <= (others => 'Z');
    fmc_lpc_row_g <= (others => 'Z');
    fmc_lpc_row_h <= (others => 'Z');

end architecture model;
