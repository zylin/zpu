library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library gaisler;
use gaisler.misc.all;

--pragma translate_off
use std.textio.all;
--pragma translate_on

library global;
use global.global_signals.all;


entity dds_ad9854_apb is
    generic (
        pindex       : integer := 0;
        paddr        : integer := 0;
        pmask        : integer := 16#fff#
    );            
    port (        
        reset       : in  std_ulogic;
        clk         : in  std_ulogic;
        apbi        : in  apb_slv_in_type;
        apbo        : out apb_slv_out_type;
        --
        ad9854_out  : out ad9854_out_t;
        ad9854_in   : in  ad9854_in_t;
    );
end entity dds_ad9854_apb;



architecture rtl of dds_ad9854_apb is

    constant VENDOR   : integer := VENDOR_HZDR;
    constant DEVICE   : integer := HZDR_DDS_AD9854_CONTROL; -- obsolet
    constant CONFIG   : integer := 0;
    constant REVISION : integer := 0;
    constant INTR     : integer := 0;

    constant pconfig  : apb_config_type := (
      0 => ahb_device_reg ( VENDOR, DEVICE, CONFIG, REVISION, INTR),
      1 => apb_iobar(paddr, pmask));


    -- counter limitations
    constant wait_width_c   : positive := 24; -- 2^24 = 16M = 1.3 s
    constant on_width_c     : positive := 24; -- 2^24 = 16M = 1.3 s
    constant off_width_c    : positive := 24; -- 2^24 = 16M = 1.3 s
    constant count_width_c  : positive := 10; -- max. 1023 pulses

    type state_t is (IDLE, WAIT_S, ON_S, OFF_S);

    type reg_t is record
        state                : state_t;
        update               : std_ulogic;
        prepare_wait_pulses  : unsigned(  wait_width_c-1 downto 0);
        prepare_on_pulses    : unsigned(    on_width_c-1 downto 0);
        prepare_off_pulses   : unsigned(   off_width_c-1 downto 0);
        prepare_count_pulses : unsigned( count_width_c-1 downto 0);
        on_pulses            : unsigned(    on_width_c-1 downto 0);
        off_pulses           : unsigned(   off_width_c-1 downto 0);
        count_pulses         : unsigned( count_width_c-1 downto 0);
        wait_counter         : unsigned(  wait_width_c-1 downto 0);
        on_counter           : unsigned(    on_width_c-1 downto 0);
        off_counter          : unsigned(   off_width_c-1 downto 0);
        counter              : unsigned( count_width_c-1 downto 0);
        gated                : std_ulogic;
        prepare_gated        : std_ulogic;
    end record;

    constant default_reg_c : reg_t := (
        state                     => IDLE,
        update                    => '0',
        prepare_wait_pulses       => to_unsigned( 0, wait_width_c),
        prepare_on_pulses         => to_unsigned( 0, on_width_c),
        prepare_off_pulses        => to_unsigned( 0, off_width_c),
        prepare_count_pulses      => to_unsigned( 0, count_width_c),
        on_pulses                 => to_unsigned( 0, on_width_c),
        off_pulses                => to_unsigned( 0, off_width_c),
        count_pulses              => to_unsigned( 0, count_width_c),
        wait_counter              => (others => '0'), 
        on_counter                => (others => '0'), 
        off_counter               => (others => '0'), 
        counter                   => (others => '0'),
        gated                     => '0',
        prepare_gated             => '0'
    );

    signal r, rin : reg_t;


begin

  comb : process(r, apbi, update)
    variable v        : reg_t;
    variable readdata  : std_logic_vector(31 downto 0);
    variable writedata : std_logic_vector(31 downto 0);
  begin


    v := r; 

    -- outputs
    sig_out <= '0';
    if v.state = ON_S then
        sig_out <= '1';
    end if;
    gated_out <= v.gated;


    -- read registers
    readdata  := (others => '0');
    writedata := apbi.pwdata;

    case apbi.paddr(4 downto 2) is
        when "000"  =>  -- decode state as numbers
            case v.state is
                when IDLE   =>
                    readdata := std_logic_vector( to_unsigned( 0, 32));
                when WAIT_S =>
                    readdata := std_logic_vector( to_unsigned( 2, 32));
                when ON_S   =>
                    readdata := std_logic_vector( to_unsigned( 3, 32));
                when OFF_S  =>
                    readdata := std_logic_vector( to_unsigned( 3, 32));
                when others =>
                    null;

            end case;

        when "001"  => 
            readdata := std_logic_vector( resize( v.prepare_wait_pulses, 32));

-- to much slices
        when "010"  => 
            readdata := std_logic_vector( resize( v.prepare_on_pulses, 32));

-- to much slices
        when "011"  => 
            readdata := std_logic_vector( resize( v.prepare_off_pulses, 32));

-- to much slices
        when "100"  => 
            readdata := std_logic_vector( resize( v.prepare_count_pulses, 32));

        when "101"  => 
            readdata(0) := v.prepare_gated;

        when others =>
    end case;


    -- write registers

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
        case apbi.paddr(4 downto 2) is

            when "001"  => 
                v.prepare_wait_pulses  := resize( unsigned( writedata), wait_width_c);

            when "010"  => 
                v.prepare_on_pulses    := resize( unsigned( writedata), on_width_c);

            when "011"  => 
                v.prepare_off_pulses   := resize( unsigned( writedata), off_width_c);

            when "100"  => 
                v.prepare_count_pulses := resize( unsigned( writedata), count_width_c);

            when "101"  =>
                v.prepare_gated       := writedata(0);

            when others =>
        end case;
    end if; -- write



    case v.state is
        
        when WAIT_S =>
            if v.wait_counter > 0 then
                v.wait_counter := v.wait_counter - 1;
            else
                v.state        := ON_S;
                v.on_counter   := v.on_pulses;
                v.off_counter  := v.off_pulses;
                if (v.on_counter = 0) and (v.off_counter = 0) then
                    v.state := IDLE;
                end if;
            end if;

        when ON_S =>
            if v.on_counter > 1 then
                v.on_counter := v.on_counter - 1;
            else
                v.state := OFF_S;
            end if;

        when OFF_S =>
            if v.off_counter > 1 then
                v.off_counter := v.off_counter - 1;
            else
                if v.counter > 1 then
                    v.counter      := v.counter - 1;
                    v.on_counter   := v.on_pulses;
                    v.off_counter  := v.off_pulses;
                    v.state        := ON_S;
                else
                    v.state := IDLE;
                    -- count endless
                    if v.counter = 0 then
                        v.on_counter   := v.on_pulses;
                        v.off_counter  := v.off_pulses;
                        v.state        := ON_S;
                    end if;
                end if;
            end if;

        
        when others =>
            null;

    end case;

    -- check for rising edge on update
    if update = '1' and v.update = '0' then
        if v.state = IDLE then
            v.state       := ON_S;
            v.on_counter  := v.prepare_on_pulses;
            v.off_counter := v.prepare_off_pulses;
        end if;
        if v.prepare_wait_pulses > 0 then
            v.state    := WAIT_S;
        end if;
        v.on_pulses    := v.prepare_on_pulses;
        v.off_pulses   := v.prepare_off_pulses;
        v.wait_counter := v.prepare_wait_pulses;
        v.counter      := v.prepare_count_pulses;
        v.gated        := v.prepare_gated;
    end if;
    v.update := update;
   
    rin <= v;

    apbo.prdata             <= readdata; 	-- drive apb read bus
    apbo.pirq               <= (others => '0');
    apbo.pindex             <= pindex;
    apbo.pconfig            <= pconfig;
--  apbo <= (prdata => readdata, pirq => (others => '0'), pindex => pindex, pconfig => pconfig);
                            
  end process;



  -- registers

  regs : process
  begin
    wait until rising_edge(clk);
    r <= rin;
    if rst_n = '0' then
      r <= default_reg_c;
    end if;
  end process;

-- boot message

-- pragma translate_off
    bootmsg : report_version
    generic map ("dds_ad9854_apb" & tost(pindex) &
	": " & "DDS controller rev " & tost(REVISION));
-- pragma translate_on

end;
