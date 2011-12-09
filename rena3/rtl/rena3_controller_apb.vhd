--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601/rtl/teilerregister.vhd $
-- $Date: 2010-10-29 15:57:42 +0200 (Fr, 29 Okt 2010) $
-- $Author: lange $
-- $Revision: 659 $
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

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

    type state_t is (IDLE, ACQUIRE, READOUT);

    type reg_t is record
        state     : state_t;
        readdata  : std_logic_vector(31 downto 0);
        writedata : std_logic_vector(31 downto 0);
    end record reg_t;
    constant default_reg_c : reg_t := (
        state     => IDLE,
        readdata  => (others => '0'),
        writedata => (others => '0')
    );

    signal r, r_in: reg_t;

begin
    -- states of the rena3 controller:
    -- IDLE    (wait for configuration)
    -- ACQUIRE (wait for peaks -> send trigger event to PC)
    -- READOUT (data is ready)

    rena3_out <= default_rena3_controller_out_c;

    --------------------
    comb : process(r, apbi)
        variable v         : reg_t;
    begin
        v    := r;

        -- outputs

        -- read registers
        v.readdata  := (others => '0');

        case apbi.paddr(4 downto 2) is

            -- state
            when "000"  => 
                case v.state is
                    when IDLE    => v.readdata := x"00000000";
                    when ACQUIRE => v.readdata := x"00000001";
                    when READOUT => v.readdata := x"00000002";
                end case;

            when "001"  => null; 
            when others => null;
        end case;

        -- write registers
        v.writedata := apbi.pwdata;
        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
            case apbi.paddr(4 downto 2) is

                when "000"  => null;
                when "001"  => null;
                when others => null;

            end case;
        end if; -- write

        -- others

        case v.state is

            when IDLE =>
                null;

            when ACQUIRE =>
                null;

            when READOUT =>
                null;

        end case;

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
