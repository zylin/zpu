

library ieee;
use ieee.std_logic_1164.all;

entity controller_top is
    port(
        clk               : in  std_ulogic;
        reset             : in  std_ulogic;
        -- rena 3 
        rena3_ts          : in  std_ulogic;
        rena3_tf          : in  std_ulogic; 
        rena3_fout        : in  std_ulogic; 
        rena3_sout        : in  std_ulogic; 
        rena3_tout        : in  std_ulogic; 
        --
        rena3_chsift      : out std_ulogic;
        rena3_cin         : out std_ulogic;
        rena3_cs          : out std_ulogic; 
        rena3_read        : out std_ulogic; 
        rena3_tin         : out std_ulogic; 
        rena3_sin         : out std_ulogic; 
        rena3_fin         : out std_ulogic; 
        rena3_shrclk      : out std_ulogic; 
        rena3_fhrclk      : out std_ulogic; 
        rena3_acquire     : out std_ulogic; 
        rena3_cls         : out std_ulogic; 
        rena3_clf         : out std_ulogic; 
        rena3_tclk        : out std_ulogic 
    );
end entity controller_top;



library rena3;
use rena3.component_package.rena3_controller;
use rena3.types_package.all;


library zpu;
use zpu.zpu_wrapper_package.zpu_wrapper;
use zpu.zpu_wrapper_package.all; -- types



architecture rtl of controller_top is

    signal rena3_out                     : rena3_controller_in_t;
    signal rena3_controller_io_rena3_out : rena3_controller_out_t;
    signal rena3_controller_i0_zpu_out   : zpu_in_t;
    signal zpu_i0_zpu_out                : zpu_out_t;

begin

    -- in mapping
    rena3_out.ts <= rena3_ts;
        
    rena3_controller_i0: rena3_controller
        port map (
            -- system
            clock     => clk,                           -- : std_ulogic;
            -- rena3 (connection to chip)
            rena3_in  => rena3_out,                     -- : in  rena3_controller_in_t;
            rena3_out => rena3_controller_io_rena3_out, -- : out rena3_controller_out_t;
            -- connection to soc
            zpu_in    => zpu_i0_zpu_out,                -- : in  zpu_out_t;
            zpu_out   => rena3_controller_i0_zpu_out    -- : out zpu_in_t
        );
   
    -- out mapping 
    rena3_chsift <= rena3_controller_io_rena3_out.cshift;
    rena3_cin    <= rena3_controller_io_rena3_out.cin;
        
    zpu_i0: zpu_wrapper
        port map ( 
            clk     => clk,                           -- : in  std_logic;
            -- asynchronous reset signal             
            areset  => reset,                         -- : in  std_logic;
                                                     
            zpu_in  => rena3_controller_i0_zpu_out,   -- : in  zpu_in_t;
            zpu_out => zpu_i0_zpu_out                 -- : out zpu_out_t
            );
end architecture rtl;
