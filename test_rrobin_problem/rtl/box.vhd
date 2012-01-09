--------------------------------------------------------------------------------
-- $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/hardware/board_sp601_amba/rtl/box.vhd $
-- $Date$
-- $Author$
-- $Revision$
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library gaisler;
use gaisler.misc.all;    -- types
use gaisler.uart.all;    -- types
use gaisler.net.all;     -- types
use gaisler.uart.apbuart;
use gaisler.misc.grgpio;

library grlib;
use grlib.amba.all;

library techmap;
use techmap.gencomp.all; -- constants


entity box is
    generic (
        time_factor               : positive
    );
    port (
        clk                       : in    std_ulogic;
        reset_n                   : in    std_ulogic;
        --                        
        uarti                     : in    uart_in_type;
        uarto                     : out   uart_out_type;
        --                        
        gpioi                     : in    gpio_in_type;
        gpioo                     : out   gpio_out_type
    );
end entity box;


architecture rtl of box is

    signal box_reset                     : std_ulogic;
    signal box_reset_n                   : std_ulogic;
    --
    signal ahbctrl_i0_msti               : ahb_mst_in_type;
    signal ahbmo                         : ahb_mst_out_vector := (others => ahbm_none);
    signal ahbctrl_i0_slvi               : ahb_slv_in_type;
    signal ahbso                         : ahb_slv_out_vector := (others => ahbs_none);
    signal apbctrl_i0_apbi               : apb_slv_in_type;
    signal apbo                          : apb_slv_out_vector := (others => apb_none);
    --
    signal grgpio_i0_gpioo               : gpio_out_type;


begin
    
    ---------------------------------------------------------------------
    --  reset generator (now in top)

    box_reset   <= (not reset_n);
    box_reset_n <= not box_reset;


    ---------------------------------------------------------------------
    --  
    led_control_ahb_i0: entity work.led_control_ahb
    generic map (
        hindex    => 0,                            -- : integer := 0;
        count     => 20 * time_factor,           -- : natural := 0;
        gpio_data => x"00000000"                   -- : std_logic_vector(31 downto 0)
    )
    port map ( 
        -- system
        clk       => clk,                          -- : in  std_ulogic;
        -- ahb
        ahbi      => ahbctrl_i0_msti,              -- : in  ahb_mst_in_type; 
        ahbo      => ahbmo(0)                      -- : out ahb_mst_out_type
    );
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    --  
    led_control_ahb_i1: entity work.led_control_ahb
    generic map (
        hindex    => 1,                            -- : integer := 0;
        count     => 20 * time_factor + 3,       -- : natural := 0;
        gpio_data => x"0000000f"                   -- : std_logic_vector(31 downto 0)
    )
    port map ( 
        -- system
        clk       => clk,                          -- : in  std_ulogic;
        -- ahb
        ahbi      => ahbctrl_i0_msti,              -- : in  ahb_mst_in_type; 
        ahbo      => ahbmo(1)                      -- : out ahb_mst_out_type
    );
    ---------------------------------------------------------------------

--  chipscope_i0 : chipscope
--      port map (
--          clk  => clk,                                --: in std_ulogic;
--          data => std_ulogic_vector( ahbmo(0).haddr), --: in std_ulogic_vector(31 downto 0);
--          trig => ahbmo(0).hbusreq                    --: in std_ulogic
--          );

    
    
    ---------------------------------------------------------------------
    --  AHB CONTROLLER

    --ahbmo(0) <= (ahbm_none);
    --ahbmo(1) <= (ahbm_none);
    ahbmo(2) <= (ahbm_none);
    ahbmo(3) <= (ahbm_none);
    --
    --ahbso(0) <= (ahbs_none); -- ahbctrl
    ahbso(1) <= (ahbs_none);
    ahbso(2) <= (ahbs_none);
    ahbso(3) <= (ahbs_none);
    ahbso(4) <= (ahbs_none); -- spimctrl
    ahbso(5) <= (ahbs_none); -- mctrl
    ahbso(6) <= (ahbs_none); 
    ahbso(7) <= (ahbs_none); 

    ahbctrl_i0 : ahbctrl        -- AHB arbiter/multiplexer
        generic map (
            defmast    => 0,    -- default master
            --
            --
            rrobin     => 0,    -- round robin arbitration
            --
            --
            timeout    => 11,
            disirq     => 0,    -- enable interrupt routing
            enbusmon   => 0,    -- enable bus monitor
            assertwarn => 1,    -- enable assertions for warnings
            asserterr  => 1     -- enable assertions for errors
        )
        port map (
            rst     => box_reset_n,      -- : in  std_ulogic;
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
    ----------------------------------------------------------------------




    ---------------------------------------------------------------------
    --  AHB/APB bridge

    apbo( 0) <= (apb_none);
    --apbo( 1) <= (apb_none); -- apbuart_i0
    apbo( 2) <= (apb_none); -- gptimer_i0
    apbo( 3) <= (apb_none);
    --apbo( 4) <= (apb_none); -- grgpio_i0
    --apbo( 5) <= (apb_none);
    apbo( 6) <= (apb_none);   -- no apbvga_i0
    apbo( 7) <= (apb_none);   -- no i2cmst_i0
    apbo( 8) <= (apb_none);
    apbo( 9) <= (apb_none);
    apbo(10) <= (apb_none); -- i2cmst_i1
    apbo(11) <= (apb_none);
    apbo(12) <= (apb_none);
    apbo(13) <= (apb_none);
    apbo(14) <= (apb_none);
    apbo(15) <= (apb_none); -- mctrl_i0

    apbctrl_i0: apbctrl
        generic map (
            hindex      => 0,            -- : integer := 0;
            haddr       => 16#800#,      -- : integer := 0;
            nslaves     => 16,           -- : integer range 1 to NAPBSLV := NAPBSLV;
            asserterr   => 1,    
            assertwarn  => 1    
        )                                
        port map (                       
            rst   => box_reset_n,        -- : in  std_ulogic;
            clk   => clk,                -- : in  std_ulogic;
            ahbi  => ahbctrl_i0_slvi,    -- : in  ahb_slv_in_type;
            ahbo  => ahbso(0),           -- : out ahb_slv_out_type;
            apbi  => apbctrl_i0_apbi,    -- : out apb_slv_in_type;
            apbo  => apbo                -- : in  apb_slv_out_vector                
        );
    ----------------------------------------------------------------------
    
    
    ---------------------------------------------------------------------
    -- uart
    apbuart_i0: apbuart
        generic map (
            pindex     => 1,
            paddr      => 1,
            console    => 1, -- fast simulation output
            parity     => 0, -- no parity
            flow       => 1, -- hardware handshake
            fifosize   => 16
        )
        port map (
            rst   => box_reset_n,        -- : in  std_ulogic;
            clk   => clk,                -- : in  std_ulogic;
            apbi  => apbctrl_i0_apbi,    -- : in  apb_slv_in_type;
            apbo  => apbo(1),            -- : out apb_slv_out_type;
            uarti => uarti,              -- : in  uart_in_type;
            uarto => uarto               -- : out uart_out_type);
        );
    ---------------------------------------------------------------------


    ---------------------------------------------------------------------
    -- GPIO
    grgpio_i0: grgpio
        generic map (
            pindex  => 4, 
            paddr   => 4, 
--          imask   => 16#00000FF0#, -- interrupt mask (+ enable per software)
            syncrst => 1,            -- only synchronous reset
            nbits   => 32            -- number of port bits
        )
        port map (
            rst    => box_reset_n, 
            clk    => clk, 
            apbi   => apbctrl_i0_apbi, 
            apbo   => apbo(4),
            gpioi  => gpioi, 
            gpioo  => grgpio_i0_gpioo
        );
    gpioo <= grgpio_i0_gpioo;
    --          gpio.dout                         gpio.din
    ---------------------------------------------------------------------
    --  3 -  0  LED                               gpio_switch
    --  7 -  4  unused                            gpio_button
    -- 15 -  8  header                            gpio_header_ls
    -- 30 - 16  unused
    -- 31       unused                            simulation_active
    ---------------------------------------------------------------------


    freqctr_i0: entity work.freqctr
        generic map (
             pindex => 5,                    -- : integer               := 0;
             paddr  => 5                     -- : integer               := 0;
--           pmask  =>                       -- : integer               := 16#fff#;
--           nbits  =>                       -- : integer range 1 to 32 := 16
        )                                    
        port map (                           
             rst    => box_reset_n,          -- : in  std_ulogic;
             clk    => clk,                  -- : in  std_ulogic;
             apbi   => apbctrl_i0_apbi,      -- : in  apb_slv_in_type;
             apbo   => apbo(5),              -- : out apb_slv_out_type;
             tick   => '0',                  -- : in  std_logic;
             sig    => '0'                   -- : in  std_logic
        );

end architecture rtl;
