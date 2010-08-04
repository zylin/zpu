
library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpupkg.all;
use zpu.zpu_config.all;

library grlib;
use grlib.amba.all;

package zpu_wrapper_package is

    type zpu_in_t is record
        -- this particular implementation of the ZPU does not
        -- have a clocked enable signal
        enable      : std_ulogic; 

        mem_busy    : std_ulogic; 
        mem_read    : std_ulogic_vector(wordSize-1 downto 0);
                  
        -- Set to one to jump to interrupt vector
        -- The ZPU will communicate with the hardware that caused the
        -- interrupt via memory mapped IO or the interrupt flag can
        -- be cleared automatically
        interrupt   : std_ulogic;
    end record;
    constant default_zpu_in_c: zpu_in_t := (
        enable    => '0',
        mem_busy  => '0',
        mem_read  => (others => '0'),
        interrupt => '0'
    );

    type zpu_out_t is record
        mem_write           : std_ulogic_vector(wordSize-1 downto 0);			  
        mem_addr            : std_ulogic_vector(maxAddrBitIncIO downto 0);
        mem_writeEnable     : std_ulogic; 
        mem_readEnable      : std_ulogic;
                  
        -- this implementation of the ZPU *always* reads and writes entire
        -- 32 bit words, so mem_writeMask is tied to (others => '1').
        mem_writeMask       : std_ulogic_vector(wordBytes-1 downto 0);
                  
        -- Signal that the break instruction is executed, normally only used
        -- in simulation to stop simulation
        break               : std_ulogic;
    end record;
    constant default_zpu_out_c : zpu_out_t := (
        mem_write       => (others => '0'), 
        mem_addr        => (others => '0'),
        mem_writeEnable => '0',
        mem_readEnable  => '0',
        mem_writeMask   => (others => '0'),
        break           => '0'
    );

    component zpu_wrapper is
        Port ( 
            clk     : in  std_ulogic;
            -- asynchronous reset signal
            reset   : in  std_ulogic;

            zpu_in  : in  zpu_in_t;
            zpu_out : out zpu_out_t
            );
    end component zpu_wrapper;

    component  zpu_io is
        generic (
            log_file    : string  := "log.txt"
        );
        port(
            clk         : in  std_logic;
            areset      : in  std_logic; 
            busy        : out std_logic; 
            writeEnable : in  std_logic; 
            readEnable  : in  std_logic; 
            write       : in  std_logic_vector(wordSize-1 downto 0); 
            read        : out std_logic_vector(wordSize-1 downto 0); 
            addr        : in  std_logic_vector(maxAddrBit downto minAddrBit) 
        ); 
    end component;

    component zpu_ahb is
        port ( 
            clk     : in  std_ulogic;
            -- asynchronous reset signal
            reset   : in  std_ulogic;

            -- ahb
            ahbi   : in  ahb_mst_in_type; 
            ahbo   : out ahb_mst_out_type;
            -- system
            break  : out std_ulogic
        );
    end component zpu_ahb;


end package zpu_wrapper_package;




------------------------------------------------------------
--
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpu_wrapper_package.all;
use zpu.zpupkg.zpu_core;


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

    signal mem_write           : std_logic_vector(zpu_out.mem_write'range);
    signal out_mem_addr        : std_logic_vector(zpu_out.mem_addr'range);
    signal out_mem_writeEnable : std_logic;
    signal out_mem_readEnable  : std_logic;
    signal mem_writeMask       : std_logic_vector(zpu_out.mem_writeMask'range);

begin

    zpu_i0: zpu_core 
        port map (
            clk                 => clk,
            reset               => reset,
            --
            in_mem_busy         => zpu_in.mem_busy,
            mem_read            => std_logic_vector(zpu_in.mem_read),
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



------------------------------------------------------------
--
------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.or_reduce; -- synopsys stuff

library zpu;
use zpu.zpu_wrapper_package.all;
use zpu.zpupkg.zpu_core;

library grlib;
use grlib.amba.all;


entity zpu_ahb is
    Port ( 
        clk     : in  std_ulogic;
    	-- asynchronous reset signal
	 	reset   : in  std_ulogic;

        -- ahb
        ahbi   : in  ahb_mst_in_type; 
        ahbo   : out ahb_mst_out_type;
        -- system
        break  : out std_ulogic
        );
end zpu_ahb;


architecture rtl of zpu_ahb is

    constant me_c              : string  :=
    -- pragma translate_off
   	 rtl'path_name &
    -- pragma translate_on
	 "";

    signal mem_write           : std_logic_vector(31 downto 0);
    signal out_mem_addr        : std_logic_vector(31 downto 0);
    signal out_mem_writeEnable : std_logic;
    signal out_mem_readEnable  : std_logic;
    signal mem_writeMask       : std_logic_vector(3 downto 0);

    signal busy                : std_logic;

begin

    -- TODO ahbi.hgrant
    -- TODO ahbi.hready
    -- TODO ahbi.hresp
    -- TODO ahbi.cache
    -- TODO ahbi.hirq
    -- TODO ahbi.testen
    -- TODO ahbi.testrst
    -- TODO ahbi.scanen
    -- TODO ahbi.testoen

    check: process( ahbi)
    begin
        case ahbi.hresp is
            when HRESP_OKAY =>
                 null;
            when HRESP_ERROR =>
                report me_c & "HRESP_ERROR" severity error;
            when HRESP_SPLIT =>
                report me_c & "HRESP_SPLIT";
            when HRESP_RETRY =>
                report me_c & "HRESP_RETRY"; 
            when others =>
                if now /= (0 ps) then
                    report me_c & "unknown ahbi.hresp" severity warning;
                end if;
        end case;
    end process check;

    busy <= out_mem_readEnable or not ahbi.hready;

    zpu_i0: zpu_core 
        port map (
            clk                 => clk,
            reset               => reset,
            --
            in_mem_busy         => busy,
            mem_read            => ahbi.hrdata,
            interrupt           => or_reduce(ahbi.hirq),
            --
            mem_write           => mem_write,
            out_mem_addr        => out_mem_addr,
            out_mem_writeEnable => out_mem_writeEnable,
            out_mem_readEnable  => out_mem_readEnable,
            mem_writeMask       => mem_writeMask,
            break               => break
        );

    ahbo.hbusreq <= '1';
    ahbo.hlock   <= '1';
    ahbo.htrans  <= HTRANS_NONSEQ when (out_mem_readEnable = '1') or (out_mem_writeEnable = '1') else HTRANS_IDLE;
    ahbo.haddr   <= out_mem_addr;-- & "0000";
    ahbo.hwrite  <= out_mem_writeEnable;
    ahbo.hsize   <= HSIZE_WORD;
    ahbo.hburst  <= HBURST_SINGLE;
    ahbo.hprot   <= (others => '0');
    ahbo.hwdata  <= mem_write;
    ahbo.hirq    <= (others => '0');
    ahbo.hconfig <= (others => (others => '0')); 
    ahbo.hindex  <= 0;

    --zpu_out.mem_writeMask       <= std_ulogic_vector(mem_writeMask);

end architecture rtl;
