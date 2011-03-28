------------------------------------------------------------
--
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpu_wrapper_package.all;
use zpu.zpupkg.zpu_core_small;


entity zpu_wrapper is
    Port ( 
        clk     : in  std_ulogic;
    	-- reset signal
	 	reset   : in  std_ulogic;

        zpu_in  : in  zpu_in_t;
        zpu_out : out zpu_out_t
        );
end zpu_wrapper;


architecture rtl of zpu_wrapper is

    signal mem_write           : std_ulogic_vector(zpu_out.mem_write'range);
    signal out_mem_addr        : std_ulogic_vector(zpu_out.mem_addr'range);
    signal out_mem_writeEnable : std_ulogic;
    signal out_mem_readEnable  : std_ulogic;
    signal mem_writeMask       : std_ulogic_vector(zpu_out.mem_writeMask'range);

begin

    zpu_i0: zpu_core_small 
        port map (
            clk                 => clk,
            reset               => reset,
            --
            in_mem_busy         => zpu_in.mem_busy,
            mem_read            => std_ulogic_vector(zpu_in.mem_read),
            interrupt           => zpu_in.interrupt,
            --
            mem_write           => mem_write,
            out_mem_addr        => out_mem_addr,
            out_mem_writeEnable => out_mem_writeEnable,
            out_mem_readEnable  => out_mem_readEnable,
            mem_writeMask       => mem_writeMask,
            break               => zpu_out.break
        );

    zpu_out.mem_write           <= std_ulogic_vector(mem_write);
    zpu_out.mem_addr            <= std_ulogic_vector(out_mem_addr);
    zpu_out.mem_writeEnable     <= std_ulogic(out_mem_writeEnable);
    zpu_out.mem_readEnable      <= std_ulogic(out_mem_readEnable);
    zpu_out.mem_writeMask       <= std_ulogic_vector(mem_writeMask);

end architecture rtl;

