
library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpupkg.all;
use zpu.zpu_config.all;

package zpu_wrapper_package is

    type zpu_in_t is record
        -- this particular implementation of the ZPU does not
        -- have a clocked enable signal
        enable      : std_ulogic; 

        in_mem_busy : std_ulogic; 
        mem_read    : std_ulogic_vector(wordSize-1 downto 0);
                  
        -- Set to one to jump to interrupt vector
        -- The ZPU will communicate with the hardware that caused the
        -- interrupt via memory mapped IO or the interrupt flag can
        -- be cleared automatically
        interrupt   : std_ulogic;
    end record;

    type zpu_out_t is record
        mem_write           : std_ulogic_vector(wordSize-1 downto 0);			  
        out_mem_addr        : std_ulogic_vector(maxAddrBitIncIO downto 0);
        out_mem_writeEnable : std_ulogic; 
        out_mem_readEnable  : std_ulogic;
                  
        -- this implementation of the ZPU *always* reads and writes entire
        -- 32 bit words, so mem_writeMask is tied to (others => '1').
        mem_writeMask       : std_ulogic_vector(wordBytes-1 downto 0);
                  
        -- Signal that the break instruction is executed, normally only used
        -- in simulation to stop simulation
        break               : std_ulogic;
    end record;

    component zpu_wrapper is
        Port ( 
            clk     : in  std_logic;
            -- asynchronous reset signal
            areset  : in  std_logic;

            zpu_in  : in  zpu_in_t;
            zpu_out : out zpu_out_t
            );
    end component zpu_wrapper;

end package zpu_wrapper_package;



library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpu_wrapper_package.all;
use zpu.zpupkg.zpu_core;



entity zpu_wrapper is
    Port ( 
        clk     : in  std_logic;
    	-- asynchronous reset signal
	 	areset  : in  std_logic;

        zpu_in  : in  zpu_in_t;
        zpu_out : out zpu_out_t
        );
end zpu_wrapper;


architecture rtl of zpu_wrapper is
begin

end architecture;
