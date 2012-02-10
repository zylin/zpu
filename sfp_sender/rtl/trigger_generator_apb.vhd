--
-- revision 2 --> multiple channel (in one module) support, state: beta
--

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

library hzdr;
use hzdr.devices_hzdr.all;

library work;
use work.types_package.all;
use work.component_package.trigger_generator;


entity trigger_generator_apb is
    generic (
        pindex       : integer := 0;
        paddr        : integer := 0;
        pmask        : integer := 16#fff#;
        channels     : positive range 1 to 32
    );            
    port (        
        rst         : in  std_ulogic;
        clk         : in  std_ulogic;
        apbi        : in  apb_slv_in_type;
        apbo        : out apb_slv_out_type;
        --          
        update      : in  std_ulogic;
        gated_out   : out std_ulogic_vector(channels-1 downto 0);
        sig_out     : out std_ulogic_vector(channels-1 downto 0)
    );
end entity trigger_generator_apb;



architecture rtl of trigger_generator_apb is

    constant VENDOR   : integer := VENDOR_HZDR;
    constant DEVICE   : integer := HZDR_TRIGGER_GEN;
    constant CONFIG   : integer := 0;
    constant REVISION : integer := 2;
    constant INTR     : integer := 0;

    constant pconfig  : apb_config_type := (
      0 => ahb_device_reg ( VENDOR, DEVICE, CONFIG, REVISION, INTR),
      1 => apb_iobar(paddr, pmask));


    -- counter limitations
    constant wait_width_c   : positive := 24; -- 2^24 = 16M = 1.3 s
    constant on_width_c     : positive := 24; -- 2^24 = 16M = 1.3 s
    constant off_width_c    : positive := 24; -- 2^24 = 16M = 1.3 s
    constant count_width_c  : positive := 10; -- max. 1023 pulses

    type ctrl_in_array_t  is array(0 to channels-1) of trigger_generator_ctrl_in_t;
    type ctrl_out_array_t is array(0 to channels-1) of trigger_generator_ctrl_out_t;

    type reg_t is record
        ctrl        : ctrl_in_array_t;
        readdata    : std_logic_vector(31 downto 0);
        writedata   : std_logic_vector(31 downto 0);
        channel     : natural range 0 to 31;
    end record;

    constant default_reg_c : reg_t := (
        ctrl       => (others => default_trigger_generator_ctrl_in_c),
        readdata   => (others => '0'),
        writedata  => (others => '0'),
        channel    => 0
    );

    type src_t is record
        channel : ctrl_out_array_t;
    end record;

    signal r, rin : reg_t;
    signal src : src_t;


begin

  comb : process(r, src, apbi, update)
    variable v         : reg_t;
  begin

    v := r; 

    -- read registers
    v.readdata  := (others => '0');
    v.writedata := apbi.pwdata;
    v.channel   := 0;
    if (apbi.psel(pindex) and apbi.penable) = '1' then
        v.channel   := to_integer( unsigned( apbi.paddr(8 downto 4)));
    end if;

    case apbi.paddr(3 downto 2) is
        when "00"  =>
            v.readdata(29 downto 0) := std_logic_vector( resize( v.ctrl( v.channel).cycles, 30));
            v.readdata(30)          := v.ctrl( v.channel).gated_in;
            v.readdata(31)          := src.channel( v.channel).active; 
            
        when "01"  => 
            v.readdata := std_logic_vector( resize( v.ctrl( v.channel).wait_time, 32));

        when "10"  => 
            v.readdata := std_logic_vector( resize( v.ctrl( v.channel).on_time, 32));
            
        when "11"  => 
            v.readdata := std_logic_vector( resize( v.ctrl( v.channel).off_time, 32));

        when others =>
            null;
    end case;


    -- write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
        case apbi.paddr(3 downto 2) is
            when "00"  =>
                v.ctrl( v.channel).cycles    := resize( unsigned( v.writedata(29 downto 0)), cycles_width);
                v.ctrl( v.channel).gated_in  := v.writedata(30);

            when "01"  => 
                v.ctrl( v.channel).wait_time := resize( unsigned( v.writedata), wait_time_width);

            when "10"  => 
                v.ctrl( v.channel).on_time   := resize( unsigned( v.writedata), on_time_width);

            when "11"  => 
                v.ctrl( v.channel).off_time  := resize( unsigned( v.writedata), off_time_width);

            when others =>
        end case;
    end if; -- write

    -- distribute update signal
    for index in 0 to channels-1 loop
        v.ctrl( index).update := update;
    end loop;

    rin <= v;

    apbo.prdata             <= v.readdata; 	-- drive apb read bus
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
        if rst = '1' then
            r <= default_reg_c;
        end if;
    end process;

   
    gen_trigger_generator: for index in 0 to channels-1 generate
        trigger_generator_ix : trigger_generator
            port map (        
                rst      => rst,                          -- : in  std_ulogic;
                clk      => clk,                          -- : in  std_ulogic;
                --
                ctrl_in  => r.ctrl( index),               -- : in  trigger_generator_ctrl_in_t;
                ctrl_out => src.channel( index)           -- : out trigger_generator_ctrl_out_t
            );

        sig_out(   index) <= src.channel( index).sig_out;
        gated_out( index) <= src.channel( index).gated_out;
    end generate gen_trigger_generator;


    -- boot message

    -- pragma translate_off
    bootmsg : report_version
        generic map ("trigger_generator_apb" & tost(pindex) &
        ": " & "trigger generator rev " & tost(REVISION) &
        " with " & tost(channels) & " channels");
    -- pragma translate_on

end;
