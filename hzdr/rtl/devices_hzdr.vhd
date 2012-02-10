
library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;

-- pragma translate_off
use std.textio.all;
-- pragma translate_on

package devices_hzdr is

    -- Vendor code
    constant VENDOR_HZDR                : amba_vendor_type := 16#55#;

    -- HZDR ID'S
    constant HZDR_ZPU_AHB_WRAPPER       : amba_device_type := 16#001#;
    constant HZDR_ZPU_MEM_WRAPPER       : amba_device_type := 16#002#;
    constant HZDR_DCM_CTRL              : amba_device_type := 16#003#;
    constant HZDR_DEBUG_CON             : amba_device_type := 16#004#;
    constant HZDR_TRIGGER_GEN           : amba_device_type := 16#005#;
    constant HZDR_BEAM_POSITION_MONITOR : amba_device_type := 16#006#;
    constant HZDR_DEBUG_BUFFER_CONTROL  : amba_device_type := 16#007#;
    constant HZDR_EA_DOGS102            : amba_device_type := 16#008#;
    constant HZDR_DEBUG_TRACER          : amba_device_type := 16#009#;
    constant HZDR_DIFFERENTIAL_IMONITOR : amba_device_type := 16#00a#;
    constant HZDR_SFP_CONTROL           : amba_device_type := 16#00b#;
    constant HZDR_RENA3_CONTROLLER      : amba_device_type := 16#00c#;


-- pragma translate_off
  
    constant HZDR_DESC : vendor_description :=   "http://www.hzdr.de      ";
    constant hzdr_device_table : device_table_type := (
        HZDR_ZPU_AHB_WRAPPER        => "ZPU AHB wrapper                ",
        HZDR_ZPU_MEM_WRAPPER        => "ZPU Memory wrapper             ",
        HZDR_DCM_CTRL               => "DCM phase shift control        ",
        HZDR_DEBUG_CON              => "debug console                  ",
        HZDR_TRIGGER_GEN            => "trigger generator              ",
        HZDR_BEAM_POSITION_MONITOR  => "beam position monitor          ",
        HZDR_DEBUG_BUFFER_CONTROL   => "debug buffer control           ",
        HZDR_EA_DOGS102             => "EA DOGS 102 display driver     ",
        HZDR_DEBUG_TRACER           => "debug tracer memory            ",
        HZDR_DIFFERENTIAL_IMONITOR  => "differential current monitor   ",
        HZDR_SFP_CONTROL            => "SFP controller                 ",
        HZDR_RENA3_CONTROLLER       => "RENA3 controller               ",
        others                      => "Unknown Device                 ");
    constant hzdr_lib : vendor_library_type := (
        vendorid 	     => VENDOR_HZDR,
        vendordesc       => HZDR_DESC,
        device_table     => hzdr_device_table
        );

-- pragma translate_on

end package devices_hzdr;
