
library ieee;
use ieee.std_logic_1164.all;

library rena3;
use rena3.types_package.all;

library zpu;
use zpu.zpu_wrapper_package.all; -- type definitions


entity rena3_controller is
    port (
        -- system
        clock     : std_ulogic;
        -- rena3 (connection to chip)
        rena3_in  : in  rena3_controller_in_t;
        rena3_out : out rena3_controller_out_t;
        -- connection to soc
        zpu_in    : in  zpu_out_t;
        zpu_out   : out zpu_in_t
    );
end entity rena3_controller;


architecture rtl of rena3_controller is

    type state_t is (IDLE, ACQUIRE, READOUT);

    type reg_t is record
        state : state_t;
    end record reg_t;
    constant default_reg_c : reg_t := (
        state => IDLE
    );

    signal r, r_in: reg_t;

begin
    -- states of the rena3 controller:
    -- IDLE    (wait for configuration)
    -- ACQUIRE (wait for peaks -> send trigger event to PC)
    -- READOUT (send data to PC)
    --
    -- optional -> automatic readout after defined acquire time


    --------------------
    comb : process(r)
    --------------------
        variable v : reg_t;
    begin
        v    := r;

        case v.state is

            when IDLE =>
                null;

            when ACQUIRE =>
                null;

            when READOUT =>
                null;

        end case;

        r_in <= v;
    end process;

    --------------------
    seq : process
    --------------------
    begin
        wait until rising_edge(clock);
        r <= r_in;
    end process;
end;
