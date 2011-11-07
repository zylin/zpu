--
--  single pulse train generator
--
--
--        wait pulses   ______  off   ______  off   .......
--  |___________________| on |________| on |________.     .......
--                      |  1st cycle  |  2nd cycle  |
--
--
--  input parameters:
--
--  on_time    - number of cycles which the pulse is on
--  off_time   - number of cycles which the pulse is off
--  wait_time  - number of cycles for the first pulses
--  cycles     - number of pulses
--  gated_in TODO check this

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types_package.all;


entity trigger_generator is
    port (        
        rst          : in  std_ulogic;
        clk          : in  std_ulogic;
        --
        ctrl_in      : in  trigger_generator_ctrl_in_t;
        ctrl_out     : out trigger_generator_ctrl_out_t
    );
end entity trigger_generator;



architecture rtl of trigger_generator is

    -- counter limitations

    type state_t is (IDLE, WAIT_S, ON_S, OFF_S);

    type reg_t is record
        state                : state_t;
        update               : std_ulogic;
        on_pulses            : unsigned(    on_time_width-1 downto 0);
        off_pulses           : unsigned(   off_time_width-1 downto 0);
        count_pulses         : unsigned( cycles_width-1 downto 0);
        wait_counter         : unsigned(  wait_time_width-1 downto 0);
        on_counter           : unsigned(    on_time_width-1 downto 0);
        off_counter          : unsigned(   off_time_width-1 downto 0);
        counter              : unsigned( cycles_width-1 downto 0);
        gated                : std_ulogic;
        prepare_gated        : std_ulogic;
    end record;

    constant default_reg_c : reg_t := (
        state                     => IDLE,
        update                    => '0',
        on_pulses                 => to_unsigned( 0, on_time_width),
        off_pulses                => to_unsigned( 0, off_time_width),
        count_pulses              => to_unsigned( 0, cycles_width),
        wait_counter              => (others => '0'), 
        on_counter                => (others => '0'), 
        off_counter               => (others => '0'), 
        counter                   => (others => '0'),
        gated                     => '0',
        prepare_gated             => '0'
    );

    signal r, rin : reg_t;


begin

  comb : process(r, ctrl_in)
    variable v        : reg_t;
    variable readdata  : std_logic_vector(31 downto 0);
    variable writedata : std_logic_vector(31 downto 0);
  begin


    v := r; 

    -- outputs
    ctrl_out.sig_out <= '0';
    if v.state = ON_S then
        ctrl_out.sig_out <= '1';
    end if;

    ctrl_out.gated_out <= v.gated;

    case v.state is
        when IDLE   =>
            ctrl_out.active <= '0';
        when others =>
            ctrl_out.active <= '1';
    end case;

    
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
    if ctrl_in.update = '1' and v.update = '0' then
        if v.state = IDLE then
            v.state       := ON_S;
            v.on_counter  := ctrl_in.on_time;
            v.off_counter := ctrl_in.off_time;
        end if;
        if ctrl_in.wait_time > 0 then
            v.state    := WAIT_S;
        end if;
        v.on_pulses    := ctrl_in.on_time;
        v.off_pulses   := ctrl_in.off_time;
        v.wait_counter := ctrl_in.wait_time;
        v.counter      := ctrl_in.cycles;
        v.gated        := ctrl_in.gated_in;
    end if;
    v.update := ctrl_in.update;
   
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

end architecture rtl;
