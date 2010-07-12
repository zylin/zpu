

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
        rena3_tclk        : out std_ulogic;
        -- simulation
        break             : out std_ulogic
    );
end entity controller_top;



library rena3;
use rena3.component_package.rena3_controller;
use rena3.types_package.all;


library zpu;
use zpu.zpu_wrapper_package.zpu_wrapper;
use zpu.zpu_wrapper_package.zpu_io;
use zpu.zpu_wrapper_package.all; -- types
use zpu.zpu_config.all;
use zpu.zpupkg.all;



architecture rtl of controller_top is

    signal rena3_out                     : rena3_controller_in_t;
    signal rena3_controller_io_rena3_out : rena3_controller_out_t;
    signal rena3_controller_i0_zpu_out   : zpu_in_t;
    signal zpu_i0_zpu_out                : zpu_out_t;
    
    -- zpu related signals
    signal io_busy                       : std_ulogic;
    signal io_writeEnable                : std_ulogic;
    signal io_readEnable                 : std_ulogic;
    signal io_ready                      : std_ulogic;
    signal io_read                       : std_logic_vector(wordSize-1 downto 0);
    signal io_reading                    : std_ulogic;
    signal dram_ready                    : std_ulogic;
    signal dram_read                     : std_logic_vector(wordSize-1 downto 0);

begin

    -- in mapping
    rena3_out.ts   <= rena3_ts;
    rena3_out.tf   <= rena3_tf;
    rena3_out.fout <= rena3_fout;
    rena3_out.sout <= rena3_sout;
    rena3_out.tout <= rena3_tout;
        
    rena3_controller_i0: rena3_controller
        port map (
            -- system
            clock     => clk,                           -- : std_ulogic;
            -- rena3 (connection to chip)
            rena3_in  => rena3_out,                     -- : in  rena3_controller_in_t;
            rena3_out => rena3_controller_io_rena3_out, -- : out rena3_controller_out_t;
            -- connection to soc
            zpu_in    => zpu_i0_zpu_out,                -- : in  zpu_out_t;
            zpu_out   => open --rena3_controller_i0_zpu_out    -- : out zpu_in_t
        );
   
    -- out mapping 
    rena3_chsift  <= rena3_controller_io_rena3_out.cshift;
    rena3_cin     <= rena3_controller_io_rena3_out.cin;
    rena3_cs      <= rena3_controller_io_rena3_out.cs;
    rena3_read    <= rena3_controller_io_rena3_out.read;
    rena3_tin     <= rena3_controller_io_rena3_out.tin;
    rena3_sin     <= rena3_controller_io_rena3_out.sin;
    rena3_fin     <= rena3_controller_io_rena3_out.fin;
    rena3_shrclk  <= rena3_controller_io_rena3_out.shrclk;
    rena3_fhrclk  <= rena3_controller_io_rena3_out.fhrclk;
    rena3_acquire <= rena3_controller_io_rena3_out.acquire;
    rena3_cls     <= rena3_controller_io_rena3_out.cls;
    rena3_clf     <= rena3_controller_io_rena3_out.clf;
    rena3_tclk    <= rena3_controller_io_rena3_out.tclk;


    rena3_controller_i0_zpu_out.enable      <= io_busy; -- TODO
    rena3_controller_i0_zpu_out.in_mem_busy <= io_busy; -- TODO
    rena3_controller_i0_zpu_out.mem_read    <= std_ulogic_vector(dram_read) when dram_ready = '1' else
                                               std_ulogic_vector(io_read)   when io_ready   = '1' else (others => 'U');
    rena3_controller_i0_zpu_out.interrupt   <= '0'; -- TODO

    zpu_wrapper_i0: zpu_wrapper
        port map ( 
            clk     => clk,                           -- : in  std_logic;
            -- asynchronous reset signal             
            areset  => reset,                         -- : in  std_logic;
                                                     
            zpu_in  => rena3_controller_i0_zpu_out,   -- : in  zpu_in_t;
            zpu_out => zpu_i0_zpu_out                 -- : out zpu_out_t
        );
    break <= zpu_i0_zpu_out.break;

    zpu_io_i0 : zpu_io
        port map (
            clk         => clk,
            areset      => reset,
            busy        => io_busy,
            writeEnable => io_writeEnable,
            readEnable  => io_readEnable,
            write       => std_logic_vector(zpu_i0_zpu_out.mem_write),
            read        => io_read,
            addr        => std_logic_vector(zpu_i0_zpu_out.out_mem_addr(maxAddrBit downto minAddrBit))
        );

    memyory_control_sync: process
    begin
        wait until rising_edge(clk);
        io_reading     <= io_busy or zpu_i0_zpu_out.out_mem_readEnable;
        if reset = '1' then
            io_reading <= '0';
        end if;
    end process;

    io_ready       <= (io_reading or zpu_i0_zpu_out.out_mem_readEnable) and not io_busy; 

    io_writeEnable <= zpu_i0_zpu_out.out_mem_writeEnable and zpu_i0_zpu_out.out_mem_addr(ioBit);
    io_readEnable  <= zpu_i0_zpu_out.out_mem_readEnable  and zpu_i0_zpu_out.out_mem_addr(ioBit);

end architecture rtl;
