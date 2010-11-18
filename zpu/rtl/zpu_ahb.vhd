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
use grlib.stdlib.report_version;
use grlib.stdlib.tost;


entity zpu_ahb is
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
end zpu_ahb;


architecture rtl of zpu_ahb is

    constant me_c              : string  :=
    -- pragma translate_off
   	 rtl'path_name &
    -- pragma translate_on
	 "";
  
    constant REVISION          : amba_version_type := 0;

    signal mem_read            : std_ulogic_vector(31 downto 0);
    signal mem_write           : std_ulogic_vector(31 downto 0);
    signal out_mem_addr        : std_ulogic_vector(31 downto 0);
    signal out_mem_writeEnable : std_ulogic;
    signal out_mem_readEnable  : std_ulogic;
    signal mem_writeMask       : std_ulogic_vector(3 downto 0);

    signal busy                : std_ulogic;

begin

    -- TODO ahbi.hgrant
    -- TODO ahbi.cache
    -- TODO ahbi.hirq
    -- TODO ahbi.testen
    -- TODO ahbi.testrst
    -- TODO ahbi.scanen
    -- TODO ahbi.testoen

    check: process( ahbi)
    begin
        -- check only if we have the grant
        if ahbi.hgrant(hindex) = '1' then
            
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
        end if;
    end process check;

    busy <= out_mem_readEnable or ( (not ahbi.hready)  or  (not ahbi.hgrant(hindex)) );
    --busy <= ( out_mem_readEnable or  (not ahbi.hready) ) and  (not ahbi.hgrant(hindex)) ;
    --busy <=  out_mem_readEnable or (not ahbi.hready); --original

    mem_read <= std_ulogic_vector( ahbi.hrdata);

    zpu_i0: zpu_core 
        port map (
            clk                 => clk,
            clk_en              => '1',
            reset               => reset,
            --
            in_mem_busy         => busy,
            mem_read            => mem_read,
            interrupt           => or_reduce(ahbi.hirq),
            --
            mem_write           => mem_write,
            out_mem_addr        => out_mem_addr,
            out_mem_writeEnable => out_mem_writeEnable,
            out_mem_readEnable  => out_mem_readEnable,
            mem_writeMask       => mem_writeMask,
            break               => break
        );

    ahbo.hbusreq <= out_mem_readEnable or out_mem_writeEnable;
    ahbo.hlock   <= '0';
    ahbo.htrans  <= HTRANS_NONSEQ when (out_mem_readEnable = '1') or (out_mem_writeEnable = '1') else HTRANS_IDLE;
    ahbo.haddr   <= std_logic_vector( out_mem_addr);
    ahbo.hwrite  <= out_mem_writeEnable;
    ahbo.hsize   <= HSIZE_WORD;
    ahbo.hburst  <= HBURST_SINGLE;
    ahbo.hprot   <= "0001";
    ahbo.hwdata  <= std_logic_vector( mem_write);
    ahbo.hirq    <= (others => '0');
    ahbo.hconfig <= (others => (others => '0')); 
    ahbo.hindex  <= 0;

    --zpu_out.mem_writeMask       <= std_ulogic_vector(mem_writeMask);

    -- pragma translate_off
    zpu_bus_trace_i0: zpu_bus_trace
    port map (
        clk                     => clk,                 -- : in std_ulogic;
        reset                   => reset,               -- : in std_ulogic;
        --
        in_mem_busy             => busy,                -- : in std_ulogic; 
        mem_read                => mem_read,            -- : in std_ulogic_vector(wordSize-1 downto 0);
        mem_write               => mem_write,           -- : in std_ulogic_vector(wordSize-1 downto 0);              
        out_mem_addr            => out_mem_addr,        -- : in std_ulogic_vector(maxAddrBitIncIO downto 0);
        out_mem_writeEnable     => out_mem_writeEnable, -- : in std_ulogic; 
        out_mem_readEnable      => out_mem_readEnable   -- : in std_ulogic
    );
    -- pragma translate_on

    -- pragma translate_off
      bootmsg : report_version
      generic map (
        "zpu" & tost(hindex) & ": Zylin CPU rev " & tost(REVISION)
      );
    -- pragma translate_on



end architecture rtl;
