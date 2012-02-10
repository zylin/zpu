--
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

library opencores;

library hzdr;
use hzdr.devices_hzdr.all;

library work;
use work.types_package.all;


entity sfp_controller_apb is
    generic (
        pindex       : integer := 0;
        paddr        : integer := 0;
        pmask        : integer := 16#fff#
    );            
    port (        
        rst          : in  std_ulogic;
        clk          : in  std_ulogic;
        apbi         : in  apb_slv_in_type;
        apbo         : out apb_slv_out_type;
        --           
        sfp_status   : in  sfp_status_in_t;
        sfp_control  : out sfp_control_out_t;
        sfp_rx       : in  std_ulogic;
        sfp_tx       : out std_ulogic
    );
end entity sfp_controller_apb;



architecture rtl of sfp_controller_apb is

    constant VENDOR   : integer := VENDOR_HZDR;
    constant DEVICE   : integer := HZDR_SFP_CONTROL;
    constant CONFIG   : integer := 0;
    constant REVISION : integer := 0;
    constant INTR     : integer := 0;

    constant pconfig  : apb_config_type := (
      0 => ahb_device_reg ( VENDOR, DEVICE, CONFIG, REVISION, INTR),
      1 => apb_iobar(paddr, pmask));

	constant K28d1 : std_ulogic_vector := "00111100"; -- Unbalanced comma
	constant K28d5 : std_ulogic_vector := "10111100"; -- Unbalanced comma
	constant K28d7 : std_ulogic_vector := "11111100"; -- Balanced comma
    
    type state_t is (IDLE, ACTIVE);

    type buffer_t is array(0 to 63) of std_ulogic_vector(31 downto 0);

    type reg_t is record
        state       : state_t;
        control     : sfp_control_out_t;
        readdata    : std_ulogic_vector(31 downto 0);
        writedata   : std_ulogic_vector(31 downto 0);
        sel         : std_ulogic_vector(1 downto 0); -- "00" reg, "10" rx_buffer, "11" tx_buffer
        buffer_addr : integer range 0 to 63;
        tx_active   : std_ulogic;
        tx_count    : integer range 0 to 255;
        tx_char     : std_ulogic_vector(7 downto 0);
        tx_comma    : std_ulogic;
        tx_bit_pos  : natural range 0 to 9;
        tx_reg      : std_ulogic_vector(9 downto 0);
        rx_count    : integer range 0 to 255;
    end record;

    constant default_reg_c : reg_t := (
        state        => IDLE,
        control      => default_sfp_control_out_c,
        readdata     => (others => '0'),
        writedata    => (others => '0'),
        sel          => "00",
        buffer_addr  => 0,
        tx_active    => '0',
        tx_count     => 0,
        tx_char      => (others => '0'),
        tx_comma     => '0',
        tx_bit_pos   => 0,
        tx_reg       => (others => '0'),
        rx_count     => 0
    );


    type source_t is record
        tx_char_encoded : std_logic_vector(9 downto 0);
    end record;

    signal r, rin    : reg_t;
    signal source    : source_t;
    signal rx_buffer : buffer_t;
    signal tx_buffer : buffer_t := (
        x"04030201",
        x"08070605",
        x"0c0b0a09",
        x"100f0e0d",
        x"14131211",
        x"18171615",
        x"1c1b1a19",
        x"201f1e1d",
        x"24232221",
        x"28272625",
        x"2c2b2a29",
        x"302f2e2d",
        others => x"ffffffff"
    );


begin

    comb : process(r, source, tx_buffer, rx_buffer, apbi, sfp_rx, sfp_status)
        variable v         : reg_t;
    begin

        v := r; 

        -- registered outputs
        sfp_control <= v.control;
        if v.control.tx_disable = '1' then
            sfp_tx  <= v.tx_reg( v.tx_reg'left);
        else
            sfp_tx  <= '0';
        end if;

        -- FSM
        case v.state is

            when IDLE =>
                -- send sync
                v.tx_char  := K28d5;
                v.tx_comma := '1';
                if v.tx_active = '1' then
                    v.state      := ACTIVE;
                    v.tx_count   := 0;
                end if;

            when ACTIVE =>
                
                if v.tx_count = 255 then
                    v.state      := IDLE;
                    v.tx_active  := '0';
                end if;
                if v.tx_bit_pos = 2 then -- preload 8b10b encoder
                    v.tx_comma := '0';
                    case v.tx_count mod 4 is
                        when 0 =>
                            v.tx_char  := tx_buffer( v.tx_count/4)( 7 downto  0);
                        when 1 =>
                            v.tx_char  := tx_buffer( v.tx_count/4)(15 downto  8);
                        when 2 =>
                            v.tx_char  := tx_buffer( v.tx_count/4)(23 downto 16);
                        when 3 =>
                            v.tx_char  := tx_buffer( v.tx_count/4)(31 downto 24);
                        when others =>
                    end case;
                    v.tx_count := v.tx_count + 1;
                end if;

        end case;

        -- output shift register
        if v.tx_bit_pos > 0 then
            v.tx_bit_pos := v.tx_bit_pos - 1;
            v.tx_reg     := v.tx_reg( v.tx_reg'left-1 downto 0) & '0';
        else
            v.tx_bit_pos := 9;
            v.tx_reg     := std_ulogic_vector( source.tx_char_encoded);
        end if;

        -- read registers
        v.readdata    := (others => '0');
        v.sel         := std_ulogic_vector( apbi.paddr(9 downto 8));
        v.buffer_addr := to_integer( to_01( unsigned( apbi.paddr(7 downto 2))));
        v.writedata   := std_ulogic_vector( apbi.pwdata);

        case v.sel is

            when "00"|"01" =>
                case apbi.paddr(3 downto 2) is
                    when "00"  =>
                        v.readdata(0)  := sfp_status.tx_fault; 
                        v.readdata(1)  := sfp_status.mod_detect; 
                        v.readdata(2)  := sfp_status.los; 
                        v.readdata(8)  := v.control.tx_disable; 
                        v.readdata(9)  := v.control.rt_sel; 
                        v.readdata(16) := v.tx_active; 
                        
                    when "10"  =>
                        v.readdata := std_ulogic_vector( to_unsigned( v.rx_count, 32));

                    when "11"  =>
                        v.readdata := std_ulogic_vector( to_unsigned( v.tx_count, 32));

                    when others =>
                end case;

            when "10" =>
                v.readdata    := rx_buffer( v.buffer_addr);

            when "11" =>
                v.readdata    := tx_buffer( v.buffer_addr);

            when others =>

        end case;

        -- write registers
        if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then

            case v.sel is
                when "00"|"01" =>
                    case apbi.paddr(3 downto 2) is
                        when "00"  =>
                            v.control.tx_disable := v.writedata(8);
                            v.control.rt_sel     := v.writedata(9);
                            v.tx_active          := v.writedata(16);

                        when others =>
                    end case;

                when "10" =>
                    rx_buffer( v.buffer_addr) <= v.writedata;

                when "11" =>
                    tx_buffer( v.buffer_addr) <= v.writedata;

                when others =>
            end case; -- v.sel
        end if; -- write

        -- unregistered outputs
        apbo.prdata             <= std_logic_vector( v.readdata); 	-- drive apb read bus
        apbo.pirq               <= (others => '0');
        apbo.pindex             <= pindex;
        apbo.pconfig            <= pconfig;
                                
        rin <= v;

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

    -- data sources
	enc_8b10b_i0: entity opencores.enc_8b10b
    	port map (
            reset    => rst,                       -- : in  std_logic;
            sbyteclk => clk,                       -- : in  std_logic;
            ki       => r.tx_comma,                -- : in  std_logic;
            ai       => r.tx_char(0),              -- : in  std_logic;
            bi       => r.tx_char(1),              -- : in  std_logic;
            ci       => r.tx_char(2),              -- : in  std_logic;
            di       => r.tx_char(3),              -- : in  std_logic;
            ei       => r.tx_char(4),              -- : in  std_logic;
            fi       => r.tx_char(5),              -- : in  std_logic;
            gi       => r.tx_char(6),              -- : in  std_logic;
            hi       => r.tx_char(7),              -- : in  std_logic;
            ao       => source.tx_char_encoded(0), -- : out std_logic;
            bo       => source.tx_char_encoded(1), -- : out std_logic;
            co       => source.tx_char_encoded(2), -- : out std_logic;
            do       => source.tx_char_encoded(3), -- : out std_logic;
            eo       => source.tx_char_encoded(4), -- : out std_logic;
            fo       => source.tx_char_encoded(5), -- : out std_logic;
            io       => source.tx_char_encoded(6), -- : out std_logic;
            go       => source.tx_char_encoded(7), -- : out std_logic;
            ho       => source.tx_char_encoded(8), -- : out std_logic;
            jo       => source.tx_char_encoded(9)  -- : out std_logic
		);
   
    -- boot message

    -- pragma translate_off
    bootmsg : report_version
        generic map ("sfp_controller_apb" & tost(pindex) &
        ": " & " rev " & tost(REVISION) );
    -- pragma translate_on

end architecture rtl;
