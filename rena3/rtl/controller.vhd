library ieee;
use ieee.std_logic_1164.all;

entity controller_top is
    port(
        clk:      in std_ulogic;
        reset:    in std_ulogic
    );
end entity controller_top;



library rena3;
use rena3.component_package.rena3_controller;

library zpu;
use zpu.zpu_wrapper_package.zpu_wrapper;


architecture rtl of controller_top is
begin
end architecture rtl;
