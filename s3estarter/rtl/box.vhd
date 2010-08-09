-- box design

library ieee;
use ieee.std_logic_1164.all;

library s3estarter;
use s3estarter.types.all;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types


entity box is
    port (
        fpga_clk        : in    fpga_clk_in_t;
        fpga_rotary_sw  : in    fpga_rotary_sw_in_t;
    
        uarti           : in    uart_in_type;
        uarto           : out   uart_out_type;

        gpioi           : in    gpio_in_type;
        gpioo           : out   gpio_out_type;

        ethi            : in    eth_in_type;
        etho            : out   eth_out_type;
                                         
        -- to stop simulation
        break           : out   std_ulogic

    );
end entity box;



library ieee;
use ieee.numeric_std.all;


library zpu;
use zpu.zpu_wrapper_package.zpu_wrapper;
use zpu.zpu_wrapper_package.zpu_io;
use zpu.zpu_wrapper_package.zpu_ahb;
use zpu.zpu_wrapper_package.all; -- types
use zpu.zpu_config.all;
use zpu.zpupkg.all;


library grlib;
use grlib.amba.all;

library gaisler;
use gaisler.misc.all; -- types
use gaisler.uart.all; -- types
use gaisler.net.all;  -- types
use gaisler.misc.gptimer;
use gaisler.misc.grgpio;
use gaisler.misc.ahbram;
use gaisler.uart.apbuart;
use gaisler.net.greth;

library techmap;
use techmap.gencomp.all;

architecture rtl of box is
    
    signal clk                           : std_ulogic;
    signal reset                         : std_ulogic;
    signal reset_async                   : std_ulogic;
                                         
    signal reset_shiftreg                : std_ulogic_vector(3 downto 0) := (others => '1');

--  signal rena3_out                     : rena3_controller_in_t;
--  signal rena3_controller_io_rena3_out : rena3_controller_out_t;
    signal rena3_controller_i0_zpu_out   : zpu_in_t;
    signal zpu_i0_zpu_out                : zpu_out_t;
    signal reset_n                       : std_ulogic;

    signal ahbctrl_i0_msti               : ahb_mst_in_type;
    signal ahbmo                         : ahb_mst_out_vector := (others => ahbm_none);
    signal ahbctrl_i0_slvi               : ahb_slv_in_type;
    signal ahbso                         : ahb_slv_out_vector := (others => ahbs_none);
    signal apbctrl_i0_apbi               : apb_slv_in_type;
    signal apbo                          : apb_slv_out_vector := (others => apb_none);
    
    signal gpti                          : gptimer_in_type;
    signal gptimer_i0_gpto               : gptimer_out_type;
                                         
    signal stati                         : ahbstat_in_type;

begin
    
    -- select clk and reset source 
    clk             <= fpga_clk.clk50;
    reset_async     <= fpga_rotary_sw.center; 


    -- generate synchronous reset
    reset_synchronizer : process
    begin
        wait until rising_edge( clk);
        reset_shiftreg <= reset_shiftreg( reset_shiftreg'high-1 downto 0) & reset_async;
    end process;

    reset           <= reset_shiftreg( reset_shiftreg'high);
    reset_n         <= not reset;
    
--  zpu_i0_zpu_out <= default_zpu_out_c;
--  rena3_out      <= default_rena3_controller_in_c; 
--  rena3_controller_i0: rena3_controller
--      port map (
--          -- system
--          clock          => clk,                           -- : std_ulogic;
--          -- rena3 (connection to chip)
--          rena3_in       => rena3_out,                     -- : in  rena3_controller_in_t;
--          rena3_out      => rena3_controller_io_rena3_out, -- : out rena3_controller_out_t;
--          -- connection to soc
--          zpu_in         => zpu_i0_zpu_out,                -- : in  zpu_out_t;
--          zpu_out        => rena3_controller_i0_zpu_out    -- : out zpu_in_t
--      );
    
    zpu_ahb_i0: zpu_ahb
    port map (
        clk    => clk,             -- : in  std_ulogic;
     	reset  => reset,           -- : in  std_ulogic;
        ahbi   => ahbctrl_i0_msti, -- : in  ahb_mst_in_type; 
        ahbo   => ahbmo(0),        -- : out ahb_mst_out_type;
        break  => break            -- : out std_ulogic
    );
    
    ---------------------------------------------------------------------
    --  AHB CONTROLLER
    ----------------------------------------------------------------------

    --ahbmo(15 downto 1) <= (others => ahbm_none); -- slow down syntesis
    --ahbso(15 downto 1) <= (others => ahbs_none); -- slow down syntesis

    ahbctrl_i0 : ahbctrl        -- AHB arbiter/multiplexer
        generic map (
            timeout    => 11,
            nahbm      => 2, 
            nahbs      => 2,
            disirq     => 1,    -- disable interrupt routing
            enbusmon   => 0,    -- enable bus monitor
            assertwarn => 1,    -- enable assertions for warnings
            asserterr  => 1     -- enable assertions for errors
        )
        port map (
            rst     => reset_n,          -- : in  std_ulogic;
            clk     => clk,              -- : in  std_ulogic;
            msti    => ahbctrl_i0_msti,  -- : out ahb_mst_in_type;
            msto    => ahbmo,            -- : in  ahb_mst_out_vector;
            slvi    => ahbctrl_i0_slvi,  -- : out ahb_slv_in_type;
            slvo    => ahbso,            -- : in  ahb_slv_out_vector;
            testen  => '0',
            testrst => '1',
            scanen  => '0',
            testoen => '1'
        );

    ahbram_i0 : ahbram
        generic map (
            hindex   => 1,
            haddr    => 16#a00#,
            hmask    => 16#FFF#,
            tech     => inferred,
            kbytes   => 4
        )
        port map (
            rst    => reset_n,
            clk    => clk,
            ahbsi  => ahbctrl_i0_slvi,
            ahbso  => ahbso(1)
        );

    ---------------------------------------------------------------------
    --  AHB/APB bridge
    ----------------------------------------------------------------------

    --apbo(5 to 15) <= (others => apb_none); -- slow down syntesis

    apbctrl_i0: apbctrl
        generic map (
            hindex      => 0,            -- : integer := 0;
            haddr       => 16#800#,      -- : integer := 0;
            nslaves     => 16,           -- : integer range 1 to NAPBSLV := NAPBSLV;
            asserterr   => 1,    
            assertwarn  => 1    
        )                                
        port map (                       
            rst   => reset_n,            -- : in  std_ulogic;
            clk   => clk,                -- : in  std_ulogic;
            ahbi  => ahbctrl_i0_slvi,    -- : in  ahb_slv_in_type;
            ahbo  => ahbso(0),           -- : out ahb_slv_out_type;
            apbi  => apbctrl_i0_apbi,    -- : out apb_slv_in_type;
            apbo  => apbo                -- : in  apb_slv_out_vector                
        );
    
    -- uart
    apbuart_i0: apbuart
        generic map (
            pindex     => 1,
            paddr      => 1,
            console    => 1, -- fast simulation output
            parity     => 0, -- no parity
            flow       => 0, -- no hardware handshake
            fifosize   => 32
        )
        port map (
            rst   => reset_n,
            clk   => clk,
            apbi  => apbctrl_i0_apbi,
            apbo  => apbo(1),
            uarti => uarti,
            uarto => uarto
        );


    gpti.extclk <= '0'; -- alternativ timer clock
    gpti.dhalt  <= '0'; -- debug halt
    -- GP timer (grip.pdf p. 279)
    gptimer_i0: gptimer
        generic map (
            pindex  => 2,
            paddr   => 2,
            pirq    => 3,
            sepirq  => 0, -- use separate interupts for each timer
            sbits   => 8, -- prescaler bits
            ntimers => 2, -- number of timers
            nbits   => 32 -- timer bits
        )
        port map (
            rst     => reset_n,
            clk     => clk,
            apbi    => apbctrl_i0_apbi,
            apbo    => apbo(2),
            gpti    => gpti,
            gpto    => gptimer_i0_gpto
        );

    -- GPIO
    grgpio_i0: grgpio
        generic map (
            pindex  => 8, 
            paddr   => 8, 
            imask   => 16#0000#, -- interrupt mask (+ enable per software)
            syncrst => 1,        -- only synchronous reset
            nbits   => 32        -- number of port bits
        )
        port map (
            rst    => reset_n, 
            clk    => clk, 
            apbi   => apbctrl_i0_apbi, 
            apbo   => apbo(8),
            gpioi  => gpioi, 
            gpioo  => gpioo
        );

    -- ethernet
    greth_i0: greth
        generic map (
            hindex      => 1, 
            pindex      => 12,
            paddr       => 12,
            pirq        => 12,
            memtech     => inferred,
            mdcscaler   => 20,
            enable_mdio => 1,
            fifosize    => 4,
            nsync       => 1
        )
        port map (
            rst         => reset_n,
            clk         => clk,
            ahbmi       => ahbctrl_i0_msti,
            ahbmo       => ahbmo(1),
            apbi        => apbctrl_i0_apbi,
            apbo        => apbo(12),
            ethi        => ethi,
            etho        => etho
        );

    stati.cerror <= (others => '0');
    -- AHB status register
    ahbstat_i0: ahbstat
        generic map (
            pindex => 15, 
            paddr  => 15, 
            pirq   => 7 
        ) 
        port map (
            rst   => reset_n,
            clk   => clk, 
            ahbmi => ahbctrl_i0_msti, 
            ahbsi => ahbctrl_i0_slvi, 
            stati => stati, 
            apbi  => apbctrl_i0_apbi, 
            apbo  => apbo(15)
        );

    

end architecture rtl;
