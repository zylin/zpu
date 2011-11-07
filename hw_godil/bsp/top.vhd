-- top module of
-- GODIL


library ieee;
use ieee.std_logic_1164.all;


entity top is
  port (
    m49   : in    std_logic;            -- oscillator input
    -- GPIO
    sw1   : in    std_logic;            -- switch 1, high active
    sw2   : in    std_logic;            -- switch 2, low active
    -- TUSB3410
    sin   : inout std_logic;            -- M0 configuration pin, TUSB3410 serial data input, LED3
    sout  : in    std_logic;            -- TUSB3410 serial data out
    rts   : in    std_logic;            -- TUSB3410 ready to send (LED5)
    cts   : inout std_logic;            -- TUSB3410 clear to send (and LED6)
    vs2   : inout std_logic;            -- TUSB3410 I2C connection, LED8
    tvs1  : inout std_logic;            -- TUSB3410 I2C connector (and E2)
    -- SPI flash
    cso   : inout std_logic;            -- SPI memory chip select
    tmosi : inout std_logic;            -- SPI memory mosi (and E4)
    tdin  : inout std_logic;            -- SPI memory data out (and E5)
    tcclk : inout std_logic;            -- SPI memory clock (and E6)
    -- remaining IO pins
    c13   : in    std_logic;            -- external input (pin 49)
    d13   : in    std_logic;            -- external input (pin 50)
    tvs0  : inout std_logic;            -- E3
    tm1   : inout std_logic;            -- M1 configuration pin (and E7)
    thsw  : inout std_logic;            -- HSWAP configuration pin (and E8)
    -- I/O's for DIL / main connector
    pin   : inout std_logic_vector(48 downto 1)
    );
end entity top;


architecture rtl of top is

begin
end architecture rtl;
