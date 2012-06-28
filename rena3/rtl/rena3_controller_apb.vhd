--------------------------------------------------------------------------------
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.or_reduce;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library hzdr;
use hzdr.devices_hzdr.all;

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
        sample_mem  : out sample_buffer_mem_out_type;
        --
        rena_debug  : out rena_debug_t
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

    type state_t is (IDLE, CONFIGURE, CONFIGURE_END, CLEAR, TRAP, DETECT, ACQUIRE, ANALYZE, PRE_DESIRE, DESIRE, READOUT, READLAG, FOLLOW);

    type reg_t is record
        state              : state_t;
        state_after_desire : state_t;
        timer              : integer range 0 to 65535;
        readdata           : std_logic_vector(31 downto 0);
        writedata          : std_logic_vector(31 downto 0);
        configure          : std_logic_vector(40 downto 0);
        bitindex           : integer range 0 to 40;
        acquire_time       : unsigned(31 downto 0);
        trap_count         : unsigned(15 downto 0);
        fast_trigger       : std_ulogic;
        slow_trigger       : std_ulogic;
        overflow           : std_ulogic;
        slow_channel_mask  : std_ulogic_vector(35 downto 0);
        slow_force_mask    : std_ulogic_vector(35 downto 0);
        slow_chain         : std_ulogic_vector(35 downto 0);
        slow_trigger_chain : std_ulogic_vector(35 downto 0);
        fast_channel_mask  : std_ulogic_vector(35 downto 0);
        fast_force_mask    : std_ulogic_vector(35 downto 0);
        fast_chain         : std_ulogic_vector(35 downto 0);
        fast_trigger_chain : std_ulogic_vector(35 downto 0);
        token_count        : unsigned(7 downto 0);
        sample_valid       : std_ulogic_vector(3 downto 0);
        sample_address     : unsigned(7 downto 0);
        rena               : rena3_controller_out_t;
        rena_in            : rena3_controller_in_t;
        clk_adc            : std_ulogic;
        clk_adc_old        : std_ulogic;
        sample_mem         : sample_buffer_mem_out_type;
        test_length        : unsigned(15 downto 0);
        test_polarity      : std_ulogic;
    end record reg_t;
    constant default_reg_c : reg_t := (
        state              => IDLE,
        state_after_desire => READOUT,
        timer              => 0,
        readdata           => (others => '0'),
        writedata          => (others => '0'),
        configure          => (others => '0'),
        bitindex           => 0,
        acquire_time       => (others => '0'),
        trap_count         => (others => '0'),
        fast_trigger       => '0',
        slow_trigger       => '0',
        overflow           => '0',
        slow_channel_mask  => (others => '1'),
        slow_force_mask    => (others => '0'),
        slow_chain         => (others => '0'),
        slow_trigger_chain => (others => '0'),
        fast_channel_mask  => (others => '1'),
        fast_force_mask    => (others => '0'),
        fast_chain         => (others => '0'),
        fast_trigger_chain => (others => '0'),
        token_count        => (others => '0'),
        sample_valid       => (others => '0'),
        sample_address     => (others => '0'),
        rena               => default_rena3_controller_out_c,
        rena_in            => default_rena3_controller_in_c,
        clk_adc            => '0',
        clk_adc_old        => '0',
        sample_mem         => default_sample_buffer_mem_out_c,
        test_length        => (others => '0'),
        test_polarity      => '1'
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

        case apbi.paddr(6 downto 2) is

            -- controller state          // 0x00
            when "00000"  =>
                case v.state is
                    when IDLE          => v.readdata := x"00000000";
                    when CONFIGURE     => v.readdata := x"00000001";
                    when CONFIGURE_END => v.readdata := x"00000001";
                    when CLEAR         => v.readdata := x"00000002";
                    when TRAP          => v.readdata := x"0000000A";
                    when DETECT        => v.readdata := x"00000003";
                    when ACQUIRE       => v.readdata := x"00000004";
                    when ANALYZE       => v.readdata := x"00000005";
                    when PRE_DESIRE    => v.readdata := x"00000006";
                    when DESIRE        => v.readdata := x"00000006";
                    when READOUT       => v.readdata := x"00000007";
                    when READLAG       => v.readdata := x"00000008";
                    when FOLLOW        => v.readdata := x"00000009";
                end case;


            -- rena state                // 0x04
            when "00001"  =>
                v.readdata(0)  := v.overflow;
                v.readdata(1)  := v.slow_trigger;
                v.readdata(2)  := v.fast_trigger;

            -- config low                // 0x08
            when "00010"  =>
                v.readdata                       := v.configure(31 downto 0);
                
            -- config high               // 0x0C
            when "00011" =>
                v.readdata(8 downto 0)           := v.configure(40 downto 32);

            -- acquire time              // 0x10
            when "00100" =>
                v.readdata(v.acquire_time'range) := std_logic_vector( v.acquire_time);
                
            -- slow lower channel mask   // 0x14
            when "00101" =>
                v.readdata(31 downto 0)          := std_logic_vector( v.slow_channel_mask(31 downto 0));

            -- slow higher channel mask  // 0x18
            when "00110" =>
                v.readdata( 3 downto 0)          := std_logic_vector( v.slow_channel_mask(35 downto 32));
                
            -- number of sampled tokens  // 0x1C
            when "00111" =>
                v.readdata( v.token_count'range) := std_logic_vector( v.token_count);

            -- fast_trigger_chain low    // 0x20
            when "01000" =>
                v.readdata(31 downto 0)          := std_logic_vector( v.fast_trigger_chain(31 downto 0));

            -- fast_trigger_chain high   // 0x24
            when "01001" =>
                v.readdata( 3 downto 0)          := std_logic_vector( v.fast_trigger_chain(35 downto 32));

            -- slow_trigger_chain low    // 0x28
            when "01010" =>
                v.readdata(31 downto 0)          := std_logic_vector( v.slow_trigger_chain(31 downto 0));

            -- slow_trigger_chain high   // 0x2C
            when "01011" =>
                v.readdata( 3 downto 0)          := std_logic_vector( v.slow_trigger_chain(35 downto 32));
                
            -- slow lower channel force mask  // 0x30
            when "01100" =>
                v.readdata(31 downto 0)          := std_logic_vector( v.slow_force_mask(31 downto 0));

            -- slow higher channel force mask // 0x34
            when "01101" =>
                v.readdata( 3 downto 0)          := std_logic_vector( v.slow_force_mask(35 downto 32));


            -- unused                    // 0x38
            when "01110" =>
                null;


            -- test pulse generator      // 0x3C
            when "01111" =>
                v.readdata(31)                   := v.test_polarity;
                v.readdata(15 downto 0)          := std_logic_vector( v.test_length);
                
            -- fast lower channel mask   // 0x40
            when "10000" =>
                v.readdata(31 downto 0)          := std_logic_vector( v.fast_channel_mask(31 downto 0));

            -- fast higher channel mask  // 0x44
            when "10001" =>
                v.readdata( 3 downto 0)          := std_logic_vector( v.fast_channel_mask(35 downto 32));
                
            -- fast lower channel force mask  // 0x48
            when "10010" =>
                v.readdata(31 downto 0)          := std_logic_vector( v.fast_force_mask(31 downto 0));

            -- fast higher channel force mask // 0x4c
            when "10011" =>
                v.readdata( 3 downto 0)          := std_logic_vector( v.fast_force_mask(35 downto 32));

            -- trap counter                   // 0x50
            when "10100" =>
                v.readdata(15 downto 0)          := std_logic_vector( v.trap_count);

            when others => 
                null;

        end case;


        -- write registers
        v.writedata := apbi.pwdata;
        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
            case apbi.paddr(6 downto 2) is

                -- state                    0x00
                when "00000"  => 
                    case to_integer( unsigned(v.writedata)) is
                        -- idle state
                        when 0 =>
                            v.state              := IDLE;

                        -- acqire mode
                        when 2 =>
                            v.rena.clf           := '1';
                            v.rena.cls           := '1'; 
                            v.rena.acquire       := '1';
                            v.timer              := 2;     -- 20 ns
                            v.state              := CLEAR;

                        -- folower mode
                        when 9 =>
                            v.rena.cls           := '1';

                            v.timer              := 2;     -- 20 ns for cls
                            v.state              := PRE_DESIRE;

                        when others =>
                            null;
                    end case;

                -- rena state read only     0x04
                when "00001"  => 
                    null;

                -- configure low word       0x08
                when "00010"  => 
                    v.configure(31 downto  0)    := v.writedata;

                -- configure high bits, start rena configure 0x10
                when "00011" =>
                    v.configure(40 downto 32)    := v.writedata(8 downto 0);
                    v.bitindex                   := 40;
                    v.rena.cin                   := v.configure( v.bitindex);
                    v.timer                      := 1;
                    v.state                      := CONFIGURE;

                -- acquire time             0x10
                when "00100" =>
                    v.acquire_time               := unsigned( v.writedata( v.acquire_time'range));

                -- slow lower channel mask       0x14
                when "00101" =>
                    v.slow_channel_mask(31 downto 0)  := std_ulogic_vector( v.writedata(31 downto 0));

                -- slow higher channel mask      0x18
                when "00110" =>
                    v.slow_channel_mask(35 downto 32) := std_ulogic_vector( v.writedata( 3 downto 0));
            
                -- number of sampled tokens 0x1C
                -- read only
                when "00111" =>
                    null;

                -- fast trigger chain low   0x20
                -- read only
                when "01000" =>
                    null;

                -- fast trigger chain high  0x24
                -- read only
                when "01001" =>
                    null;

                -- slow trigger chain low   0x28
                -- read only
                when "01010" =>
                    null;

                -- slow trigger chain high  0x2C
                -- read only
                when "01011" =>
                    null;

                -- slow lower channel force mask 0x30
                when "01100" =>
                    v.slow_force_mask(31 downto 0)    := std_ulogic_vector( v.writedata(31 downto 0));

                -- slow higher channel force mask 0x34
                when "01101" =>
                    v.slow_force_mask(35 downto 32)   := std_ulogic_vector( v.writedata( 3 downto 0));
                

                -- test pulse generator      0x3C
                when "01111" =>
                    v.test_polarity              := v.writedata(31);
                    v.rena.test                  := v.test_polarity;
                    v.test_length                := unsigned( v.writedata( v.test_length'range));

                -- fast lower channel mask       0x40
                when "10000" =>
                    v.fast_channel_mask(31 downto 0)  := std_ulogic_vector( v.writedata(31 downto 0));

                -- fast higher channel mask      0x44
                when "10001" =>
                    v.fast_channel_mask(35 downto 32) := std_ulogic_vector( v.writedata( 3 downto 0));

                -- fast lower channel force mask 0x48
                when "10010" =>
                    v.fast_force_mask(31 downto 0)    := std_ulogic_vector( v.writedata(31 downto 0));

                -- fast higher channel force mask 0x4C
                when "10011" =>
                    v.fast_force_mask(35 downto 32)   := std_ulogic_vector( v.writedata( 3 downto 0));

                -- trap counter                   // 0x50
                when "10100" =>
                    v.trap_count                      := unsigned( v.writedata(15 downto 0));

                when others => 
                    null;

            end case;
        end if; -- write



        -- main state machine 

        if v.timer = 0 then
            case v.state is


                -- reset relevant signals
                when IDLE =>
                    v.rena.cs_n             := '0';
                    v.rena.cshift           := '0';
                    v.rena.acquire          := '0';
                    v.rena.read             := '0';
                    v.rena.cls              := '0'; 
                    v.rena.clf              := '0'; 


                -- start toggeling the configuration chain
                when CONFIGURE =>

                        if v.rena.cshift = '1' then
                            v.rena.cshift   := '0';
                            if v.bitindex > 0 then
                                v.bitindex  := v.bitindex - 1;
                            else
                                v.timer     := 1;
                                v.state     := CONFIGURE_END;
                            end if;
                            v.rena.cin      := v.configure( v.bitindex);

                        else
                            v.rena.cshift   := '1';
                        end if;

                -- clean up configuration
                when CONFIGURE_END =>
                    v.rena.cs_n             := '1';
                    v.rena.cin              := '0';
                    v.timer                 := 1;
                    v.state                 := IDLE;



                -- reset detector triggers
                when CLEAR =>
                    v.fast_trigger_chain    := (others => '0');
                    v.slow_trigger_chain    := (others => '0'); 
                    v.token_count           := (others => '0');
                    v.sample_valid          := (others => '0');
                    v.sample_address        := (others => '0');
                    v.timer                 := 97;   -- 1000 ns 
                    v.state                 := TRAP;

                when TRAP =>
                    v.timer                 := to_integer( v.trap_count);
                    v.rena.clf              := '0'; 
                    v.rena.cls              := '0'; 
                    v.state                 := DETECT;

                -- wait for trigger event (TS/TF)
                when DETECT =>
                    v.slow_trigger          := '0';
                    v.fast_trigger          := '0';
                    v.overflow              := '0';
                    
                    -- catch trigger events
                    if v.rena_in.ts = '1' then
                        v.slow_trigger      := '1';
                    end if;
                    if v.rena_in.tf = '1' then
                        v.fast_trigger      := '1';
                    end if;
                    if v.rena_in.overflow = '1' then
                        v.overflow          := '1';
                    end if;

                    -- event detected
                    if (v.slow_trigger = '1') or (v.fast_trigger = '1') then
                        v.state             := ACQUIRE;    
                    end if;

                    -- run test pulse generator
                    if v.test_length > 0 then
                        v.test_length := v.test_length - 1;
                    else
                        v.rena.test   := not v.test_polarity;
                    end if;

                -- wait a given aquire time
                -- after a tigger event occure
                when ACQUIRE =>
                    if v.acquire_time > 0 then
                        v.acquire_time      := v.acquire_time - 1;
                    else
                        v.rena.acquire      := '0';
                        v.state             := ANALYZE;
                        v.bitindex          := 35;
                    end if;

                
                -- check which channel has triggered
                when ANALYZE =>
                    v.timer                 := 4; -- no timing in datasheet given
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
                            v.timer              := 10; -- just to see a gap
                            v.state              := DESIRE;
                            v.state_after_desire := READOUT;
                            v.bitindex           := 35;
                            v.fast_trigger_chain := v.fast_chain;
                            v.slow_trigger_chain := v.slow_chain;
                            v.fast_chain         := (v.fast_chain and v.fast_channel_mask) or v.fast_force_mask;
                            v.slow_chain         := (v.slow_chain and v.slow_channel_mask) or v.slow_force_mask;
                            v.rena.fin           := v.fast_chain( v.fast_chain'high);
                            v.rena.sin           := v.slow_chain( v.slow_chain'high);
                        end if;
                    end if;


                -- this state is only for follower mode
                when PRE_DESIRE =>
                    v.rena.cls               := '0';

                    v.fast_chain             := (others => '0');
                    v.slow_chain             := v.slow_force_mask;

                    v.rena.fin               := v.fast_chain( v.fast_chain'high);
                    v.rena.sin               := v.slow_chain( v.slow_chain'high);

                    v.bitindex               := 35;

                    v.timer                  := 1;
                    v.state                  := DESIRE;
                    v.state_after_desire     := FOLLOW;


                when DESIRE =>
                    v.timer                  := 4; -- no timing in datasheet given
                    v.rena.fin               := v.fast_chain( v.fast_chain'high);
                    v.rena.sin               := v.slow_chain( v.slow_chain'high);
                    if v.rena.fhrclk = '0' then
                        -- rise fhrclk
                        v.rena.fhrclk        := '1';
                        v.rena.shrclk        := '1';

                        v.fast_chain         := v.fast_chain( v.fast_chain'high-1 downto 0) & v.rena_in.fout;
                        v.slow_chain         := v.slow_chain( v.slow_chain'high-1 downto 0) & v.rena_in.sout;
                    else
                        -- fall fhrclk
                        v.rena.fhrclk        := '0';
                        v.rena.shrclk        := '0';

                        if v.bitindex > 0 then
                            v.bitindex       := v.bitindex - 1;
                        else
                            v.rena.fin       := '0';
                            v.rena.sin       := '0';
                            v.state          := v.state_after_desire;
                            v.rena.tin       := '1';
                            v.rena.read      := '1';
                            if v.state_after_desire = READOUT then
                                v.timer      := 199;  -- 2 us
                            end if;
                        end if;
                    end if;

                -- start token/ADC readout
                when READOUT =>
                    if v.rena_in.tout = '1' then
                        -- no more token in chain
                        v.rena.tclk          := '0';
                        v.rena.tin           := '0';
                        v.rena.read          := '0';
                        v.state              := READLAG;
                    else
                        if v.clk_adc = '0' then
                            v.rena.tclk      := '0';
                            v.clk_adc        := '1';
                            v.timer          := 16;
                        else
                            v.token_count    := v.token_count + 1;
                            v.rena.tclk      := '1';
                            v.clk_adc        := '0';
                            v.timer          := 16;
                            v.sample_valid   := v.sample_valid( v.sample_valid'high-1 downto 0) & '1';
                        end if;
                    end if;


                when READLAG =>
                    if or_reduce( v.sample_valid( v.sample_valid'high-1 downto 0)) = '0' then
                        v.rena.cls           := '1'; 
                        v.timer              := 1;
                        v.state              := IDLE;
                    else
                        if v.clk_adc = '0' then
                            v.clk_adc        := '1';
                            v.timer          := 16;
                        else
                            v.clk_adc        := '0';
                            v.timer          := 16;
                            v.sample_valid   := v.sample_valid( v.sample_valid'high-1 downto 0) & '0';
                        end if;
                    end if;


                when FOLLOW =>
                    v.rena.read              := '1';
                    v.rena.acquire           := '1';

                    -- run test pulse generator
                    if v.test_length > 0 then
                        v.test_length := v.test_length - 1;
                    else
                        v.rena.test   := not v.test_polarity;
                    end if;

            end case;
        else
            v.timer := v.timer - 1;
        end if;


        -- sample memory

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
        v.rena_in      := rena3_in;

        r_in           <= v;

        apbo.prdata    <= v.readdata; 	-- drive apb read bus
        apbo.pirq      <= (others => '0');
        apbo.pindex    <= pindex;
        apbo.pconfig   <= pconfig;


        -- code debug output
        case v.state is
            when IDLE          => rena_debug.state <= x"0";
            when CONFIGURE     => rena_debug.state <= x"1";
            when CONFIGURE_END => rena_debug.state <= x"1";
            when CLEAR         => rena_debug.state <= x"2";
            when TRAP          => rena_debug.state <= x"A";
            when DETECT        => rena_debug.state <= x"3";
            when ACQUIRE       => rena_debug.state <= x"4";
            when ANALYZE       => rena_debug.state <= x"5";
            when PRE_DESIRE    => rena_debug.state <= x"6";
            when DESIRE        => rena_debug.state <= x"6";
            when READOUT       => rena_debug.state <= x"7";
            when READLAG       => rena_debug.state <= x"8";
            when FOLLOW        => rena_debug.state <= x"9";
        end case;

        rena_debug.fast_trigger <= v.fast_trigger;
        rena_debug.slow_trigger <= v.slow_trigger;
        rena_debug.overflow     <= v.overflow;


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
