-------------------------------------------------------------------------------
-- Copyright (c) 2012 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 13.3
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : chipscope.vhd
-- /___/   /\     Timestamp  : Fri Mar 09 08:11:54 Mitteleuropäische Zeit 2012
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY chipscope IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    DATA: in std_logic_vector(31 downto 0);
    TRIG0: in std_logic_vector(7 downto 0));
END chipscope;

ARCHITECTURE chipscope_a OF chipscope IS
BEGIN

END chipscope_a;
