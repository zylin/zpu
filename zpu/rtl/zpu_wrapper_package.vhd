
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
        generic(
            hindex  : integer := 0
        );
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


    component zpu_bus_trace is
        generic (
            log_file            : string := "bus_trace.txt"
        );
        port (
            clk                 : in std_ulogic;
            reset               : in std_ulogic;
            --
            in_mem_busy         : in std_ulogic; 
            mem_read            : in std_ulogic_vector(wordSize-1 downto 0);
            mem_write           : in std_ulogic_vector(wordSize-1 downto 0);              
            out_mem_addr        : in std_ulogic_vector(maxAddrBitIncIO downto 0);
            out_mem_writeEnable : in std_ulogic; 
            out_mem_readEnable  : in std_ulogic
        );
    end component zpu_bus_trace;



end package zpu_wrapper_package;

