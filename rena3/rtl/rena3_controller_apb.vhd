--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library rena3;
use rena3.types_package.all;


entity rena3_controller_apb is
    generic (
        pindex      : integer := 0;
        paddr       : integer := 0;
        pmask       : integer := 16#fff#
    );            
    port (
        -- system
        clk         : in  std_ulogic;
        -- connection to soc
        apbi        : in  apb_slv_in_type;
        apbo        : out apb_slv_out_type;
        -- rena3 (connection to chip)
        rena3_in    : in  rena3_controller_in_t;
        rena3_out   : out rena3_controller_out_t;
        --
        clk_adc     : out std_ulogic;
        adc_data    : in  std_ulogic_vector(13 downto 0);
        adc_otr     : in  std_ulogic;
        --
        sample_mem  : out sample_buffer_mem_out_type
    );
end entity rena3_controller_apb;


architecture rtl of rena3_controller_apb is

    constant VENDOR   : integer := VENDOR_HZDR;
    constant DEVICE   : integer := HZDR_RENA3_CONTROLLER;
    constant CONFIG   : integer := 0;
    constant REVISION : integer := 0;
    constant INTR     : integer := 0;

    constant pconfig  : apb_config_type := (
      0 => ahb_device_reg ( VENDOR, DEVICE, CONFIG, REVISION, INTR),
      1 => apb_iobar(paddr, pmask));

    type state_t is (IDLE, CONFIGURE, CLEAR, DETECT, ACQUIRE, ANALYZE, DESIRE, READOUT, FOLLOW_UP);

    type reg_t is record
        state          : state_t;
        timer          : integer range 0 to 100;
        readdata       : std_logic_vector(31 downto 0);
        writedata      : std_logic_vector(31 downto 0);
        configure      : std_logic_vector(40 downto 0);
        bitindex       : integer range 0 to 40;
        acquire_time   : unsigned(31 downto 0);
        channel_mask   : std_ulogic_vector(35 downto 0);
        fast_chain     : std_ulogic_vector(35 downto 0);
        slow_chain     : std_ulogic_vector(35 downto 0);
        token_count    : unsigned(7 downto 0);
        sample_valid   : std_ulogic_vector(3 downto 0);
        sample_address : unsigned(7 downto 0);
        rena           : rena3_controller_out_t;
        rena_in        : rena3_controller_in_t;
        clk_adc        : std_ulogic;
        clk_adc_old    : std_ulogic;
        sample_mem     : sample_buffer_mem_out_type;
    end record reg_t;
    constant default_reg_c : reg_t := (
        state          => IDLE,
        timer          => 0,
        readdata       => (others => '0'),
        writedata      => (others => '0'),
        configure      => (others => '0'),
        bitindex       => 0,
        acquire_time   => (others => '0'),
        channel_mask   => (others => '1'),
        fast_chain     => (others => '0'),
        slow_chain     => (others => '0'),
        token_count    => (others => '0'),
        sample_valid   => (others => '0'),
        sample_address => (others => '0'),
        rena           => default_rena3_controller_out_c,
        rena_in        => default_rena3_controller_in_c,
        clk_adc        => '0',
        clk_adc_old    => '0',
        sample_mem     => default_sample_buffer_mem_out_c
    );

    signal r, r_in: reg_t := default_reg_c;

begin
    -- states of the rena3 controller:
    -- IDLE    (wait for configuration)
    -- DETECT  (wait for events)
    -- ACQUIRE (wait for additional events)
    -- ANALYZE (read trigger chains)
    -- READOUT (data is ready)

    --------------------
    comb : process(r, apbi, rena3_in, adc_data, adc_otr)
        variable v         : reg_t;
    begin
        v    := r;

        -- outputs
        rena3_out  <= v.rena;
        clk_adc    <= v.clk_adc;
        sample_mem <= v.sample_mem;

        -- read registers
        v.readdata  := (others => '0');

        case apbi.paddr(4 downto 2) is

            -- state
            when "000"  => 
                case v.state is
                    when IDLE        => v.readdata := x"00000000";
                    when CONFIGURE   => v.readdata := x"00000001";
                    when CLEAR       => v.readdata := x"00000002";
                    when DETECT      => v.readdata := x"00000003";
                    when ACQUIRE     => v.readdata := x"00000004";
                    when ANALYZE     => v.readdata := x"00000005";
                    when DESIRE      => v.readdata := x"00000006";
                    when READOUT     => v.readdata := x"00000007";
                    when FOLLOW_UP   => v.readdata := x"00000007";
                end case;


            when "001"  =>
                v.readdata(0)  := v.rena_in.overflow;
                v.readdata(1)  := v.rena_in.ts;
                v.readdata(2)  := v.rena_in.tf;

            when "010"  =>
                v.readdata                       := v.configure(31 downto 0);
                
            when "011" =>
                v.readdata(8 downto 0)           := v.configure(8 downto 0);

            -- acquire time
            when "100" =>
                v.readdata(v.acquire_time'range) := std_logic_vector( v.acquire_time);
                
            -- lower channel mask
            when "101" =>
                v.readdata(17 downto 0)          := std_logic_vector( v.channel_mask(17 downto 0));

            -- higher channel mask
            when "110" =>
                v.readdata(17 downto 0)          := std_logic_vector( v.channel_mask(35 downto 18));
                
            -- number of sampled tokens
            when "111" =>
                v.readdata( v.token_count'range) := std_logic_vector( v.token_count);
            when others => null;
        end case;


        -- write registers
        v.writedata := apbi.pwdata;
        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
            case apbi.paddr(4 downto 2) is

                -- state
                when "000"  => 
                    case to_integer( unsigned(v.writedata)) is
                        when 0      =>
                            v.state              := IDLE;
                        when 2      =>
                            v.rena.clf           := '1';
                            v.rena.cls           := '1'; 
                            v.rena.acquire       := '1';
                            v.timer              := 2;     -- 20 ns
                            v.state              := CLEAR;

                        when others =>
                            null;
                    end case;

                when "001"  => 
                    null;

                -- configure low word
                when "010"  => 
                    v.configure(31 downto  0)    := v.writedata;

                -- configure high bits, start rena configure
                when "011" =>
                    v.configure(40 downto 32)    := v.writedata(8 downto 0);
                    v.bitindex                   := 40;
                    v.rena.cs_n                  := '0';
                    v.timer                      := 2;
                    v.state                      := CONFIGURE;

                -- acquire time
                when "100" =>
                    v.acquire_time               := unsigned( v.writedata( v.acquire_time'range));

                -- lower channel mask
                when "101" =>
                    v.channel_mask(17 downto 0)  := std_ulogic_vector( v.writedata(17 downto 0));

                -- higher channel mask
                when "110" =>
                    v.channel_mask(35 downto 18) := std_ulogic_vector( v.writedata(17 downto 0));
            
                -- number of sampled tokens
                when "111" =>
                    null;

                when others => null;

            end case;
        end if; -- write

        -- main state machine 

        if v.timer = 0 then
            case v.state is

                when IDLE =>
                    v.rena.cs_n             := '1';
                    v.rena.cls              := '0'; 

                when CONFIGURE =>
                        v.rena.cin := v.configure( v.bitindex);

                        if v.rena.cshift = '1' then
                            v.rena.cshift   := '0';

                        else
                            v.rena.cshift   := '1';
                            if v.bitindex > 0 then
                                v.bitindex  := v.bitindex - 1;
                            else
                                v.timer     := 1;
                                v.state     := IDLE;
                            end if;
                        end if;

                when CLEAR =>
                    v.rena.clf              := '0'; 
                    v.timer                 := 97;   -- 1000 ns 
                    v.state                 := DETECT;

                when DETECT =>
                    v.rena.cls              := '0'; 
                    -- event detected
                    if (v.rena_in.ts = '1') or (v.rena_in.tf = '1') then
                        v.state             := ACQUIRE;    
                    end if;

                when ACQUIRE =>
                    if v.acquire_time > 0 then
                        v.acquire_time      := v.acquire_time - 1;
                    else
                        v.rena.acquire      := '0';
                        v.state             := ANALYZE;
                        v.bitindex          := 35;
                    end if;

                when ANALYZE =>
                    if v.rena.fhrclk = '0' then
                        -- rise fhrclk
                        v.rena.fhrclk       := '1';
                        v.rena.shrclk       := '1';
                    else
                        -- fall fhrclk
                        v.rena.fhrclk       := '0';
                        v.rena.shrclk       := '0';
                        v.fast_chain        := v.fast_chain( v.fast_chain'high-1 downto 0) & v.rena_in.fout;
                        v.slow_chain        := v.slow_chain( v.slow_chain'high-1 downto 0) & v.rena_in.sout;

                        if v.bitindex > 0 then
                            v.bitindex      := v.bitindex - 1;
                        else
                            v.state         := DESIRE;
                            v.bitindex      := 35;
                            v.fast_chain    := v.fast_chain and v.channel_mask;
                            v.slow_chain    := v.slow_chain and v.channel_mask;
                        end if;
                    end if;

                when DESIRE =>
                    v.rena.fin              := v.fast_chain( v.fast_chain'high);
                    v.rena.sin              := v.slow_chain( v.slow_chain'high);
                    if v.rena.fhrclk = '0' then
                        -- rise fhrclk
                        v.rena.fhrclk       := '1';
                        v.rena.shrclk       := '1';

                        v.fast_chain        := v.fast_chain( v.fast_chain'high-1 downto 0) & v.rena_in.fout;
                        v.slow_chain        := v.slow_chain( v.slow_chain'high-1 downto 0) & v.rena_in.sout;
                    else
                        -- fall fhrclk
                        v.rena.fhrclk       := '0';
                        v.rena.shrclk       := '0';

                        if v.bitindex > 0 then
                            v.bitindex      := v.bitindex - 1;
                        else
                            v.state         := READOUT;
                            v.token_count   := (others => '0');
                            v.sample_valid  := (others => '0');
                            v.rena.tin      := '1';
                            v.rena.read     := '1';
                            v.timer         := 99;  -- 1 us
                        end if;
                    end if;

                when READOUT =>
                    if v.rena_in.tout = '1' then
                        -- no more token in chain
                        v.rena.tclk         := '0';
                        v.rena.tin          := '0';
                        v.rena.read         := '0';
                        v.state             := FOLLOW_UP;
                    else
                        if v.clk_adc = '0' then
                            v.rena.tclk     := '0';
                            v.clk_adc       := '1';
                            v.timer         := 16;
                        else
                            v.token_count   := v.token_count + 1;
                            v.rena.tclk     := '1';
                            v.clk_adc       := '0';
                            v.timer         := 16;
                            v.sample_valid  := v.sample_valid( v.sample_valid'high-1 downto 0) & '1';
                        end if;
                    end if;

                when FOLLOW_UP =>
                    if or_reduce( v.sample_valid( v.sample_valid'high-1 downto 0)) = '0' then
                        v.rena.cls          := '1'; 
                        v.timer             := 1;
                        v.state             := IDLE;
                    else
                        if v.clk_adc = '0' then
                            v.clk_adc       := '1';
                            v.timer         := 16;
                        else
                            v.clk_adc       := '0';
                            v.timer         := 16;
                            v.sample_valid  := v.sample_valid( v.sample_valid'high-1 downto 0) & '0';
                        end if;
                    end if;

            end case;
        else
            v.timer := v.timer - 1;
        end if;

        v.sample_mem := default_sample_buffer_mem_out_c;

        if v.sample_valid( v.sample_valid'high) = '1' then
            if (v.clk_adc_old = '1') and (v.clk_adc = '0') then
                v.sample_mem.address := std_logic_vector( v.sample_address);
                v.sample_mem.data    := x"0000" & std_logic( adc_otr) & '0' & std_logic_vector( adc_data);
                v.sample_mem.enable  := '1';
                v.sample_mem.write   := "1111";
                --
                v.sample_address     := v.sample_address + 1;
            end if;
        end if;

        v.clk_adc_old := v.clk_adc;

        -- register inputs
        v.rena_in := rena3_in;

        r_in <= v;

        apbo.prdata    <= v.readdata; 	-- drive apb read bus
        apbo.pirq      <= (others => '0');
        apbo.pindex    <= pindex;
        apbo.pconfig   <= pconfig;

    end process;


    --------------------
    seq : process
    begin
        wait until rising_edge(clk);
        r <= r_in;
    end process;


    -- boot message

    -- pragma translate_off
    bootmsg : report_version
    generic map ("rena3_controller" & tost(pindex) &
	": " & "RENA3 controller rev " & tost(REVISION));
    -- pragma translate_on

end architecture rtl;
