library ieee;
use ieee.std_logic_1164.all;

package types_package is

    type rena3_controller_in_t is record
        ts       : std_ulogic;
        tf       : std_ulogic;
        fout     : std_ulogic;
        sout     : std_ulogic;
        tout     : std_ulogic;
        overflow : std_ulogic;
    end record rena3_controller_in_t;
    constant default_rena3_controller_in_c : rena3_controller_in_t := (
        ts       => '0',
        tf       => '0',
        fout     => '0',
        sout     => '0',
        tout     => '0',
        overflow => '0'
    );

    type rena3_controller_out_t is record
        cshift  : std_ulogic;
        cin     : std_ulogic;
        cs_n    : std_ulogic;
        read    : std_ulogic;
        tin     : std_ulogic;
        sin     : std_ulogic;
        fin     : std_ulogic;
        shrclk  : std_ulogic;
        fhrclk  : std_ulogic;
        acquire : std_ulogic;
        cls     : std_ulogic;
        clf     : std_ulogic;
        tclk    : std_ulogic;
        test    : std_ulogic;
    end record rena3_controller_out_t;
    constant default_rena3_controller_out_c: rena3_controller_out_t := (
        cshift  => '1', 
        cin     => '0', 
        cs_n    => '1',
        read    => '0',
        tin     => '0',
        sin     => '0',
        fin     => '0',
        shrclk  => '0',
        fhrclk  => '0',
        acquire => '0',
        cls     => '0',
        clf     => '0',
        tclk    => '0',
        test    => '0'
    );


    type ad9854_out_t is record
        cs_n         : std_ulogic;
        master_res   : std_ulogic; -- active high
        sclk         : std_ulogic;
        sdio         : std_ulogic;
        sdio_en      : std_ulogic;
        io_reset     : std_ulogic; -- active high
        io_ud_clk    : std_ulogic;
        io_ud_clk_en : std_ulogic;
    end record ad9854_out_t;
    constant default_ad9854_out_c: ad9854_out_t := (
        cs_n         => '0',
        master_res   => '1',
        sclk         => '0',
        sdio         => '0',
        sdio_en      => '0',
        io_reset     => '1',
        io_ud_clk    => '0',
        io_ud_clk_en => '0'
    );

    type ad9854_in_t is record
        vout         : std_ulogic;
        sdo          : std_ulogic;
        sdio         : std_ulogic;
        io_ud_clk    : std_ulogic;
    end record ad9854_in_t;


    type sample_buffer_mem_out_type is record
        address : std_logic_vector( 7 downto 0);
        data    : std_logic_vector(31 downto 0);
        enable  : std_ulogic;	     		-- active high chip select
        write   : std_logic_vector(0 to 3);	-- active high byte write enable
    end record;
    constant default_sample_buffer_mem_out_c : sample_buffer_mem_out_type := (
        address => (others => '0'),
        data    => (others => '0'),
        enable  => '0',
        write   => (others => '0')
    );

    
    ------------------------------------------------------------
    type rena_debug_t is record
        state        : std_ulogic_vector(3 downto 0);
        fast_trigger : std_ulogic;
        slow_trigger : std_ulogic;
        overflow     : std_ulogic;
    end record rena_debug_t;


end package types_package;

