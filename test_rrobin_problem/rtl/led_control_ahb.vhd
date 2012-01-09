--------------------------------------------------------------------------------
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;


entity led_control_ahb is
    generic(
        hindex    : integer := 0;
        count     : natural := 0;
        gpio_data : std_logic_vector(31 downto 0)
    );
    port ( 
        -- system
        clk       : in  std_ulogic;
        -- ahb
        ahbi      : in  ahb_mst_in_type; 
        ahbo      : out ahb_mst_out_type
    );
end entity led_control_ahb;


architecture rtl of led_control_ahb is
    
    constant revision_c : integer           := 0;
    constant hconfig_c  : ahb_config_type   := (
        0      => ahb_device_reg ( VENDOR_HZDR, 255, 0, revision_c, 0),
        others => (others => '0') 
    );

    constant gpio_addr_c : std_ulogic_vector(31 downto 0) := x"80000404";

    constant default_ahb_mst_out_c : ahb_mst_out_type := (
        hbusreq => '0',
        hlock   => '0',
        htrans  => HTRANS_IDLE, 
        haddr   => (others => '0'),
        hwrite  => '0',
        hsize   => HSIZE_WORD,
        hburst  => HBURST_SINGLE,
        hprot   => "0001",
        hwdata  => (others => '0'),
        hirq    => (others => '0'), 
        hconfig => hconfig_c,
        hindex  => hindex
    );

    type state_t is (IDLE, ADDR_PHASE, DATA_PHASE);

    type reg_t is record
        state   : state_t;
        counter : natural;
        ahbo    : ahb_mst_out_type;
    end record;
    constant default_reg_c : reg_t := (
        state   => IDLE,
        counter => 0,
        ahbo    => default_ahb_mst_out_c
    );

    signal r    : reg_t := default_reg_c;
    signal r_in : reg_t;

begin

    comb: process(r, ahbi)
        variable v : reg_t;
    begin
        ahbo <= r.ahbo; 
        v    := r;

        case v.state is
            when IDLE =>
                -- have reach right time?
                if v.counter < count then
                    v.counter      := v.counter + 1;
                else
                    -- bus write request
                    v.ahbo.hbusreq := '1';
                    v.ahbo.htrans  := HTRANS_NONSEQ;
                    v.ahbo.haddr   := std_logic_vector( gpio_addr_c);
                    v.ahbo.hwrite  := '1';
                    -- have grant?
                    if ahbi.hgrant( hindex) = '1' then
                        v.state    := ADDR_PHASE;
                    end if;
                end if;

            when ADDR_PHASE =>
                v.ahbo.hbusreq     := '0';
                v.ahbo.htrans      := HTRANS_IDLE;
                v.ahbo.haddr       := (others => '0');
                v.ahbo.hwrite      := '0';
                v.ahbo.hwdata      := gpio_data;
                v.state            := DATA_PHASE;


            when DATA_PHASE =>
                v.ahbo.hwdata      := (others => '0');
                v.counter          := 0;
                v.state            := IDLE;

        end case;

        r_in <= v;
    end process comb;


    seq: process
    begin
        wait until rising_edge( clk);
        r <= r_in;
    end process seq;


    -- pragma translate_off
    bootmsg : report_version
    generic map (
        "led_control_ahb" & tost( hindex) & ": rev " & tost( revision_c) & ", gpio_data: " & tost( gpio_data)
    );
    -- pragma translate_on


end architecture rtl;

