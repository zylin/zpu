------------------------------------------------------------
--
------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library zpu;
use zpu.zpu_wrapper_package.all;
use zpu.zpupkg.zpu_core;

library grlib;
use grlib.amba.all;
use grlib.stdlib.report_version;
use grlib.stdlib.tost;
use grlib.devices.all;


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
        irq    : in  std_ulogic;
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
  
    constant revision_c        : amba_version_type := 0;

    constant hconfig_c         : ahb_config_type   := (
        0      => ahb_device_reg ( VENDOR_FZD, FZD_ZPU_AHB_WRAPPER, 0, revision_c, 0),
        others => (others => '0') 
    );

    type   state_t is ( IDLE, ADDR_PHASE, DATA_PHASE, NOGRANT, WAIT_FOR_GRANT);
    signal state                : state_t;
    signal last_state           : state_t;

    signal mem_read             : std_ulogic_vector(31 downto 0);
    signal mem_write            : std_ulogic_vector(31 downto 0);
    signal out_mem_addr         : std_ulogic_vector(31 downto 0);
    signal out_mem_writeEnable  : std_ulogic;
    signal out_mem_readEnable   : std_ulogic;
    signal mem_writeMask        : std_ulogic_vector(3 downto 0);

    signal busy                 : std_ulogic;
    signal busy_to_zpu          : std_ulogic;
    signal clk_en               : std_ulogic;

    signal data_to_ahb          : std_ulogic_vector(31 downto 0);
    signal data_from_ahb        : std_ulogic_vector(31 downto 0);
    signal write_flag           : std_ulogic;

begin

    process
    begin

        wait until rising_edge( clk);
        
        --ahbo.haddr   <= std_logic_vector( out_mem_addr);    -- direct
        --ahbo.hwdata  <= std_logic_vector( mem_write);       -- direct
        --ahbo.hwrite  <= out_mem_writeEnable;                -- direct
        --ahbo.htrans  <= HTRANS_IDLE;

        ahbo.hwrite <= '0';

        case state is

            when IDLE =>
                write_flag          <= '0';
                if (out_mem_readEnable = '1')  or  (out_mem_writeEnable = '1') then
                    state           <= ADDR_PHASE;
                    ahbo.htrans     <= HTRANS_NONSEQ;
                    busy            <= '1';
                    ahbo.hbusreq    <= '1';
                    ahbo.haddr      <= std_logic_vector( out_mem_addr);
                    ahbo.hwrite     <= out_mem_writeEnable;  
                    write_flag      <= out_mem_writeEnable;
                    data_to_ahb     <= mem_write;

                    if ahbi.hgrant( hindex) = '0' then
                        clk_en          <= '0';
                        last_state      <= ADDR_PHASE;
                        state           <= WAIT_FOR_GRANT;
                    end if;

                else
                
                    if ahbi.hgrant( hindex) = '0' then
                        last_state  <= state;
                        state       <= NOGRANT;
                    end if;
                end if;


            when ADDR_PHASE =>
                state               <= DATA_PHASE;
                ahbo.htrans         <= HTRANS_IDLE;
                ahbo.hwdata         <= (others => '0');
                ahbo.hbusreq        <= '0';

                if write_flag = '1' then
                    ahbo.hwdata     <= std_logic_vector( data_to_ahb);
                end if;
                

            when DATA_PHASE =>
                if write_flag = '0' then -- read
                    data_from_ahb   <= std_ulogic_vector( ahbi.hrdata);
                end if;

                if ahbi.hready = '1' then
                    state           <= IDLE;
                    busy            <= '0';
                
                    if ahbi.hgrant( hindex) = '0' then
                        last_state  <= IDLE;
                        state       <= NOGRANT;
                    end if;

                end if;



            when NOGRANT =>
                if (out_mem_readEnable = '1')  or  (out_mem_writeEnable = '1') then
                    clk_en          <= '0';
                    state           <= WAIT_FOR_GRANT;
                    busy            <= '1';
                    ahbo.hbusreq    <= '1';
                    ahbo.haddr      <= std_logic_vector( out_mem_addr);
                    write_flag      <= out_mem_writeEnable;
                    data_to_ahb     <= mem_write;
                end if;

                if (ahbi.hgrant( hindex) = '1') and (ahbi.hready = '1') then
                    state           <= last_state;
                    if (out_mem_readEnable = '1')  or  (out_mem_writeEnable = '1') then
                        clk_en          <= '1';
                        state           <= ADDR_PHASE;
                        ahbo.htrans     <= HTRANS_NONSEQ;
                        ahbo.hwrite     <= write_flag;  
                    end if;
                end if;


            when WAIT_FOR_GRANT =>
                if (ahbi.hgrant( hindex) = '1') and (ahbi.hready = '1') then
                    clk_en          <= '1';
                    state           <= ADDR_PHASE;
                    ahbo.htrans     <= HTRANS_NONSEQ;
                    ahbo.hwrite     <= write_flag;  
                end if;

        end case;


        if reset = '1' then
            state               <= IDLE;
            busy                <= '0';
            ahbo.hbusreq        <= '0';
            ahbo.htrans         <= HTRANS_IDLE;
            clk_en              <= '1';
            write_flag          <= '0';
        end if; -- reset

    end process;
    
    -- obey the following rules:
    -- 
    -- pipeline rule
    -- stretch rule
    -- arbitration rule
    -- lock rule           --> not applicable
    -- exception rule

--  check: process( ahbi)
--  begin
--      -- check only if we have the grant
--      if ahbi.hgrant( hindex) = '1' then
--          
--          case ahbi.hresp is
--              when HRESP_OKAY =>
--                   null;
--              when HRESP_ERROR =>
--                  report me_c & "HRESP_ERROR" severity error;
--              when HRESP_SPLIT =>
--                  report me_c & "HRESP_SPLIT";
--              when HRESP_RETRY =>
--                  report me_c & "HRESP_RETRY"; 
--              when others =>
--                  if now /= (0 ps) then
--                      report me_c & "unknown ahbi.hresp" severity warning;
--                  end if;
--          end case;
--      end if;
--  end process check;

    -- inputs to zpu core

    -- hgrant
    -- hresp
    -- hready
    -- hrdata

    --busy <= out_mem_readEnable or ( (not ahbi.hready)  or  (not ahbi.hgrant( hindex)) );
    --busy <= ( out_mem_readEnable or  (not ahbi.hready) ) and  (not ahbi.hgrant( hindex)) ;
    --busy <=  out_mem_readEnable or (not ahbi.hready); --original

    mem_read    <= data_from_ahb;
    busy_to_zpu <= busy or out_mem_readEnable or out_mem_writeEnable;

    zpu_i0: zpu_core 
        port map (
            clk                 => clk,
            clk_en              => clk_en,
            reset               => reset,
            --
            in_mem_busy         => busy_to_zpu,
            mem_read            => mem_read,
            interrupt           => irq,
            --
            mem_write           => mem_write,
            out_mem_addr        => out_mem_addr,
            out_mem_writeEnable => out_mem_writeEnable,
            out_mem_readEnable  => out_mem_readEnable,
            mem_writeMask       => mem_writeMask,
            break               => break
        );

    -- outputs to master interface
    --ahbo.htrans  <= HTRANS_NONSEQ when (out_mem_readEnable = '1') or (out_mem_writeEnable = '1') else HTRANS_IDLE;
    

    ahbo.hsize   <= HSIZE_WORD;                         -- constant
    ahbo.hburst  <= HBURST_SINGLE;                      -- constant 
    ahbo.hprot   <= "0001";                             -- constant

    ahbo.hlock   <= '0';                                -- constant
    
    ahbo.hirq    <= (others => '0');
    ahbo.hconfig <= hconfig_c; 
    ahbo.hindex  <= 0;

    --zpu_out.mem_writeMask       <= std_ulogic_vector(mem_writeMask);




    ---------------------------------------------------------------------------
    -- checks

    -- pragma translate_off
    check_busy_stuck_on_high: process
        variable high_count: natural;
    begin
        wait until rising_edge( clk);
        if busy_to_zpu = '0' then
            high_count := 0;
        else
            high_count := high_count + 1;
        end if;

        assert high_count < 200
            report me_c & "busy to zpu stuck high"
            severity error;
    end process;

    -- pragma translate_on



    ---------------------------------------------------------------------------
    -- zpu bus tracer

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
        "zpu" & tost( hindex) & ": Zylin CPU rev " & tost( revision_c)
      );
    -- pragma translate_on



end architecture rtl;
