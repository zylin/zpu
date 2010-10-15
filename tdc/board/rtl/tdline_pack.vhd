--      Package File Template
--
--      Purpose: This package defines supplemental types, subtypes, 
--               constants, and functions 



package tdline_pack is


-- Declare constants
  constant CHANNEL_NUMBER     : integer := 16;
  constant TRBV2_TYPE         : integer := 0;
  constant USE_EXTERNAL_SDRAM : integer := 0;

  constant CHAIN_LENGTH        : integer := 128;
  constant WAVE_LENGTH         : integer := 30;
  constant RW_SYSTEM           : integer := 1;  --(range: 0 to 5)  --1 -trb, 2 -addon with portE 9 8 as rw
  constant ENABLE_DMA          : integer := 2;  --(range 1 to 2)  --1- DMA , 2 - no DMA
  constant RW_REGISTERS_NUMBER : integer := 7;  --(range 0 to 40)  --32 bit registers
                                        --accesed by trbnet or
                                        --etrax (read/write) -
                                        --control

  constant R_REGISTERS_NUMBER : integer := 5;  --(range 0 to 40)  --only read  - status


  constant TRBNET_ENABLE       : integer := 0;
  constant NUMBER_OFF_ADD_DATA : integer := 0;


end tdline_pack;


package body tdline_pack is

end tdline_pack;
