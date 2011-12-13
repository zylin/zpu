--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        rena3_out   : out rena3_controller_out_t
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

    type state_t is (IDLE, CONFIGURE, CLEAR_TOKEN, ACQUIRE, READOUT);

    type reg_t is record
        state      : state_t;
        timer      : integer range 0 to 2;
        readdata   : std_logic_vector(31 downto 0);
        writedata  : std_logic_vector(31 downto 0);
        configure  : std_logic_vector(40 downto 0);
        bitindex   : integer range 0 to 40;
        rena       : rena3_controller_out_t;
    end record reg_t;
    constant default_reg_c : reg_t := (
        state      => IDLE,
        timer      => 0,
        readdata   => (others => '0'),
        writedata  => (others => '0'),
        configure  => (others => '0'),
        bitindex   => 0,
        rena       => default_rena3_controller_out_c
    );

    signal r, r_in: reg_t := default_reg_c;

begin
    -- states of the rena3 controller:
    -- IDLE    (wait for configuration)
    -- ACQUIRE (wait for peaks -> send trigger event to PC)
    -- READOUT (data is ready)

    --------------------
    comb : process(r, apbi, rena3_in)
        variable v         : reg_t;
    begin
        v    := r;

        -- outputs
        rena3_out <= v.rena;

        -- read registers
        v.readdata  := (others => '0');

        case apbi.paddr(4 downto 2) is

            -- state
            when "000"  => 
                case v.state is
                    when IDLE        => v.readdata := x"00000000";
                    when CONFIGURE   => v.readdata := x"00000001";
                    when CLEAR_TOKEN => v.readdata := x"00000002";
                    when ACQUIRE     => v.readdata := x"00000003";
                    when READOUT     => v.readdata := x"00000004";
                end case;

            when "001"  =>
                    v.readdata := v.configure(31 downto 0);

            when "010"  =>
                    v.readdata(8 downto 0) := v.configure(8 downto 0);

            when others => null;
        end case;

        -- write registers
        v.writedata := apbi.pwdata;
        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
            case apbi.paddr(4 downto 2) is

                when "000"  => 
                    case to_integer( unsigned(v.writedata)) is
                        when 2      =>
                            v.rena.cls := '1'; 
                            v.timer    := 2;
                            v.state    := CLEAR_TOKEN;

                        when others =>
                            null;
                    end case;

                when "001"  => 
                    v.configure(31 downto  0) := v.writedata;

                when "010"  => 
                    v.configure(40 downto 32) := v.writedata(8 downto 0);
                    v.bitindex                := 40;
                    v.rena.cs_n               := '0';
                    v.timer                   := 2;
                    v.state                   := CONFIGURE;

                when others => null;

            end case;
        end if; -- write

        -- others

        if v.timer = 0 then
            case v.state is

                when IDLE =>
                    v.rena.cs_n := '1';

                when CONFIGURE =>
                        v.rena.cin := v.configure( v.bitindex);

                        if v.rena.cshift = '1' then
                            v.rena.cshift := '0';

                        else
                            v.rena.cshift := '1';
                            if v.bitindex > 0 then
                                v.bitindex := v.bitindex - 1;
                            else
                                v.timer     := 1;
                                v.state     := IDLE;
                            end if;
                        end if;

                when CLEAR_TOKEN =>
                    v.rena.cls := '0'; 
                    v.state    := IDLE;

                when ACQUIRE =>
                    null;

                when READOUT =>
                    null;

            end case;
        else
            v.timer := v.timer - 1;
        end if;

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
