------------------------------------------------------------------------------
-- "numeric_std_additions" package contains the additions to the standard
-- "numeric_std" package proposed by the VHDL-200X-ft working group.
-- This package should be compiled into "ieee_proposed" and used as follows:
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
-- use ieee_proposed.numeric_std_additions.all;
-- (this package is independant of "std_logic_1164_additions")
-- Last Modified: $Date: 2007/09/27 14:46:32 $
-- RCS ID: $Id: numeric_std_additions.vhdl,v 1.9 2007/09/27 14:46:32 l435385 Exp $
--
--  Created for VHDL-200X par, David Bishop (dbishop@vhdl.org)
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package numeric_std_additions is
  -- Make these a subtype of "signed" and "unsigned" for compatability
--  type UNRESOLVED_UNSIGNED is array (NATURAL range <>) of STD_ULOGIC;
--  type UNRESOLVED_SIGNED is array (NATURAL range <>) of STD_ULOGIC;

  subtype UNRESOLVED_UNSIGNED is UNSIGNED;
  subtype UNRESOLVED_SIGNED is SIGNED;
--  alias U_UNSIGNED is UNRESOLVED_UNSIGNED;
--  alias U_SIGNED is UNRESOLVED_SIGNED;
  subtype U_UNSIGNED is UNSIGNED;
  subtype U_SIGNED is SIGNED;  

  -- Id: A.3R
  function "+"(L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;
  -- Result subtype: UNSIGNED(L'RANGE)
  -- Result: Similar to A.3 where R is a one bit UNSIGNED

  -- Id: A.3L
  function "+"(L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;
  -- Result subtype: UNSIGNED(R'RANGE)
  -- Result: Similar to A.3 where L is a one bit UNSIGNED

  -- Id: A.4R
  function "+"(L : SIGNED; R : STD_ULOGIC) return SIGNED;
  -- Result subtype: SIGNED(L'RANGE)
  -- Result: Similar to A.4 where R is bit 0 of a non-negative
  --         SIGNED

  -- Id: A.4L
  function "+"(L : STD_ULOGIC; R : SIGNED) return SIGNED;
  -- Result subtype: UNSIGNED(R'RANGE)
  -- Result: Similar to A.4 where L is bit 0 of a non-negative
  --         SIGNED
  -- Id: A.9R
  function "-"(L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;
  -- Result subtype: UNSIGNED(L'RANGE)
  -- Result: Similar to A.9 where R is a one bit UNSIGNED

  -- Id: A.9L
  function "-"(L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;
  -- Result subtype: UNSIGNED(R'RANGE)
  -- Result: Similar to A.9 where L is a one bit UNSIGNED

  -- Id: A.10R
  function "-"(L : SIGNED; R : STD_ULOGIC) return SIGNED;
  -- Result subtype: SIGNED(L'RANGE)
  -- Result: Similar to A.10 where R is bit 0 of a non-negative
  --         SIGNED

  -- Id: A.10L
  function "-"(L : STD_ULOGIC; R : SIGNED) return SIGNED;
  -- Result subtype: UNSIGNED(R'RANGE)
  -- Result: Similar to A.10 where R is bit 0 of a non-negative
  --         SIGNED

  -- Id: M.2B
  -- %%% function "?=" (L, R : UNSIGNED) return std_ulogic;
  -- %%% function "?/=" (L, R : UNSIGNED) return std_ulogic;
  -- %%% function "?>" (L, R : UNSIGNED) return std_ulogic;
  -- %%% function "?>=" (L, R : UNSIGNED) return std_ulogic;
  -- %%% function "?<" (L, R : UNSIGNED) return std_ulogic;
  -- %%% function "?<=" (L, R : UNSIGNED) return std_ulogic;
--  function \?=\ (L, R : UNSIGNED) return STD_ULOGIC;
--  function \?/=\ (L, R : UNSIGNED) return STD_ULOGIC;
  function \?>\ (L, R : UNSIGNED) return STD_ULOGIC;
  function \?>=\ (L, R : UNSIGNED) return STD_ULOGIC;
  function \?<\ (L, R : UNSIGNED) return STD_ULOGIC;
  function \?<=\ (L, R : UNSIGNED) return STD_ULOGIC;
--  function \?=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC;
--  function \?/=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC;
  function \?>\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC;
  function \?>=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC;
  function \?<\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC;
  function \?<=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC;
--  function \?=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC;
--  function \?/=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC;
  function \?>\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC;
  function \?>=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC;
  function \?<\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC;
  function \?<=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC;
  -- Result subtype: STD_ULOGIC
  -- Result: terms compared per STD_LOGIC_1164 intent,
  -- returns an 'X' if a metavalue is passed

  -- Id: M.3B
  -- %%% function "?=" (L, R : SIGNED) return std_ulogic;
  -- %%% function "?/=" (L, R : SIGNED) return std_ulogic;
  -- %%% function "?>" (L, R : SIGNED) return std_ulogic;
  -- %%% function "?>=" (L, R : SIGNED) return std_ulogic;
  -- %%% function "?<" (L, R : SIGNED) return std_ulogic;
  -- %%% function "?<=" (L, R : SIGNED) return std_ulogic;
--  function \?=\ (L, R : SIGNED) return STD_ULOGIC;
--  function \?/=\ (L, R : SIGNED) return STD_ULOGIC;
  function \?>\ (L, R : SIGNED) return STD_ULOGIC;
  function \?>=\ (L, R : SIGNED) return STD_ULOGIC;
  function \?<\ (L, R : SIGNED) return STD_ULOGIC;
  function \?<=\ (L, R : SIGNED) return STD_ULOGIC;
--  function \?=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC;
--  function \?/=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC;
  function \?>\ (L : SIGNED; R : INTEGER) return STD_ULOGIC;
  function \?>=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC;
  function \?<\ (L : SIGNED; R : INTEGER) return STD_ULOGIC;
  function \?<=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC;
--  function \?=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC;
--  function \?/=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC;
  function \?>\ (L : INTEGER; R : SIGNED) return STD_ULOGIC;
  function \?>=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC;
  function \?<\ (L : INTEGER; R : SIGNED) return STD_ULOGIC;
  function \?<=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC;  
  -- Result subtype: std_ulogic
  -- Result: terms compared per STD_LOGIC_1164 intent,
  -- returns an 'X' if a metavalue is passed

  -- size_res versions of these functions (Bugzilla 165)
  function TO_UNSIGNED (ARG : NATURAL; SIZE_RES : UNSIGNED) return UNSIGNED;
  -- Result subtype: UNRESOLVED_UNSIGNED(SIZE_RES'length-1 downto 0)
  function TO_SIGNED (ARG : INTEGER; SIZE_RES : SIGNED) return SIGNED;
  -- Result subtype: UNRESOLVED_SIGNED(SIZE_RES'length-1 downto 0)
  function RESIZE (ARG, SIZE_RES : UNSIGNED) return UNSIGNED;
  -- Result subtype: UNRESOLVED_UNSIGNED (SIZE_RES'length-1 downto 0)
  function RESIZE (ARG, SIZE_RES : SIGNED) return SIGNED;
  -- Result subtype: UNRESOLVED_SIGNED (SIZE_RES'length-1 downto 0)
  -----------------------------------------------------------------------------
  -- New/updated funcitons for VHDL-200X fast track
  -----------------------------------------------------------------------------

  -- Overloaded functions from "std_logic_1164"
  function To_X01 (s : UNSIGNED) return UNSIGNED;
  function To_X01 (s : SIGNED) return SIGNED;

  function To_X01Z (s : UNSIGNED) return UNSIGNED;
  function To_X01Z (s : SIGNED) return SIGNED;

  function To_UX01 (s : UNSIGNED) return UNSIGNED;
  function To_UX01 (s : SIGNED) return SIGNED;

  function Is_X (s : UNSIGNED) return BOOLEAN;
  function Is_X (s : SIGNED) return BOOLEAN;

  function "sla" (ARG : SIGNED; COUNT : INTEGER) return SIGNED;
  function "sla" (ARG : UNSIGNED; COUNT : INTEGER) return UNSIGNED;

  function "sra" (ARG : SIGNED; COUNT : INTEGER) return SIGNED;
  function "sra" (ARG : UNSIGNED; COUNT : INTEGER) return UNSIGNED;

  -- Returns the maximum (or minimum) of the two numbers provided.
  -- All types (both inputs and the output) must be the same.
  -- These override the implicit funcitons, using the local ">" operator
  function maximum (
    l, r : UNSIGNED)                    -- inputs
    return UNSIGNED;

  function maximum (
    l, r : SIGNED)                      -- inputs
    return SIGNED;

  function minimum (
    l, r : UNSIGNED)                    -- inputs
    return UNSIGNED;

  function minimum (
    l, r : SIGNED)                      -- inputs
    return SIGNED;

  function maximum (
    l : UNSIGNED; r : NATURAL)                    -- inputs
    return UNSIGNED;

  function maximum (
    l : SIGNED; r : INTEGER)                    -- inputs
    return SIGNED;

  function minimum (
    l : UNSIGNED; r : NATURAL)                    -- inputs
    return UNSIGNED;

  function minimum (
    l : SIGNED; r : INTEGER)                    -- inputs
    return SIGNED;

  function maximum (
    l : NATURAL; r : UNSIGNED)                    -- inputs
    return UNSIGNED;

  function maximum (
    l : INTEGER; r : SIGNED)                    -- inputs
    return SIGNED;

  function minimum (
    l : NATURAL; r : UNSIGNED)                    -- inputs
    return UNSIGNED;

  function minimum (
    l : INTEGER; r : SIGNED)                    -- inputs
    return SIGNED;
  -- Finds the first "Y" in the input string. Returns an integer index
  -- into that string.  If "Y" does not exist in the string, then the
  -- "find_rightmost" returns arg'low -1, and "find_leftmost" returns -1
  function find_rightmost (
    arg : UNSIGNED;                     -- vector argument
    y   : STD_ULOGIC)                   -- look for this bit
    return INTEGER;
  
  function find_rightmost (
    arg : SIGNED;                       -- vector argument
    y   : STD_ULOGIC)                   -- look for this bit
    return INTEGER;
  
  function find_leftmost (
    arg : UNSIGNED;                     -- vector argument
    y   : STD_ULOGIC)                   -- look for this bit
    return INTEGER;
  
  function find_leftmost (
    arg : SIGNED;                       -- vector argument
    y   : STD_ULOGIC)                   -- look for this bit
    return INTEGER;

  function TO_UNRESOLVED_UNSIGNED (ARG, SIZE : NATURAL) return UNRESOLVED_UNSIGNED;
  -- Result subtype: UNRESOLVED_UNSIGNED(SIZE-1 downto 0)
  -- Result: Converts a nonnegative INTEGER to an UNRESOLVED_UNSIGNED vector with
  --         the specified SIZE.

  alias TO_U_UNSIGNED is
    TO_UNRESOLVED_UNSIGNED[NATURAL, NATURAL return UNRESOLVED_UNSIGNED];

  function TO_UNRESOLVED_SIGNED (ARG : INTEGER; SIZE : NATURAL) return UNRESOLVED_SIGNED;
  -- Result subtype: UNRESOLVED_SIGNED(SIZE-1 downto 0)
  -- Result: Converts an INTEGER to an UNRESOLVED_SIGNED vector of the specified SIZE.

  alias TO_U_SIGNED is
    TO_UNRESOLVED_SIGNED[NATURAL, NATURAL return UNRESOLVED_SIGNED];

  -- L.15 
  function "and" (L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;

-- L.16 
  function "and" (L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;

-- L.17 
  function "or" (L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;

-- L.18 
  function "or" (L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;

-- L.19 
  function "nand" (L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;

-- L.20 
  function "nand" (L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;

-- L.21 
  function "nor" (L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;

-- L.22 
  function "nor" (L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;

-- L.23 
  function "xor" (L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;

-- L.24 
  function "xor" (L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;

-- L.25 
  function "xnor" (L : STD_ULOGIC; R : UNSIGNED) return UNSIGNED;

-- L.26 
  function "xnor" (L : UNSIGNED; R : STD_ULOGIC) return UNSIGNED;

-- L.27 
  function "and" (L : STD_ULOGIC; R : SIGNED) return SIGNED;

-- L.28 
  function "and" (L : SIGNED; R : STD_ULOGIC) return SIGNED;

-- L.29 
  function "or" (L : STD_ULOGIC; R : SIGNED) return SIGNED;

-- L.30 
  function "or" (L : SIGNED; R : STD_ULOGIC) return SIGNED;

-- L.31 
  function "nand" (L : STD_ULOGIC; R : SIGNED) return SIGNED;

-- L.32 
  function "nand" (L : SIGNED; R : STD_ULOGIC) return SIGNED;

-- L.33 
  function "nor" (L : STD_ULOGIC; R : SIGNED) return SIGNED;

-- L.34 
  function "nor" (L : SIGNED; R : STD_ULOGIC) return SIGNED;

-- L.35 
  function "xor" (L : STD_ULOGIC; R : SIGNED) return SIGNED;

-- L.36 
  function "xor" (L : SIGNED; R : STD_ULOGIC) return SIGNED;

-- L.37 
  function "xnor" (L : STD_ULOGIC; R : SIGNED) return SIGNED;

-- L.38 
  function "xnor" (L : SIGNED; R : STD_ULOGIC) return SIGNED;

  -- %%% remove 12 functions (old syntax)
  function and_reduce(l : SIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of and'ing all of the bits of the vector. 

  function nand_reduce(l : SIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of nand'ing all of the bits of the vector. 

  function or_reduce(l : SIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of or'ing all of the bits of the vector. 

  function nor_reduce(l : SIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of nor'ing all of the bits of the vector. 

  function xor_reduce(l : SIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of xor'ing all of the bits of the vector. 

  function xnor_reduce(l : SIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of xnor'ing all of the bits of the vector. 

  function and_reduce(l : UNSIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of and'ing all of the bits of the vector. 

  function nand_reduce(l : UNSIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of nand'ing all of the bits of the vector. 

  function or_reduce(l : UNSIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of or'ing all of the bits of the vector. 

  function nor_reduce(l : UNSIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of nor'ing all of the bits of the vector. 

  function xor_reduce(l : UNSIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of xor'ing all of the bits of the vector. 

  function xnor_reduce(l : UNSIGNED) return STD_ULOGIC;
  -- Result subtype: STD_LOGIC. 
  -- Result: Result of xnor'ing all of the bits of the vector.

  -- %%% Uncomment the following 12 functions (new syntax)
  -- function "and" ( l  : SIGNED ) RETURN std_ulogic;
  -- function "nand" ( l  : SIGNED ) RETURN std_ulogic;
  -- function "or" ( l  : SIGNED ) RETURN std_ulogic;
  -- function "nor" ( l  : SIGNED ) RETURN std_ulogic;
  -- function "xor" ( l  : SIGNED ) RETURN std_ulogic;
  -- function "xnor" ( l  : SIGNED ) RETURN std_ulogic;
  -- function "and" ( l  : UNSIGNED ) RETURN std_ulogic;
  -- function "nand" ( l  : UNSIGNED ) RETURN std_ulogic;
  -- function "or" ( l  : UNSIGNED ) RETURN std_ulogic;
  -- function "nor" ( l  : UNSIGNED ) RETURN std_ulogic;
  -- function "xor" ( l  : UNSIGNED ) RETURN std_ulogic;
  -- function "xnor" ( l  : UNSIGNED ) RETURN std_ulogic;

  -- rtl_synthesis off
-- pragma synthesis_off
  -------------------------------------------------------------------    
  -- string functions
  -------------------------------------------------------------------   
  function to_string (value : UNSIGNED) return STRING;
  function to_string (value : SIGNED) return STRING;

  -- explicitly defined operations

  alias to_bstring is to_string [UNSIGNED return STRING];
  alias to_bstring is to_string [SIGNED return STRING];
  alias to_binary_string is to_string [UNSIGNED return STRING];
  alias to_binary_string is to_string [SIGNED return STRING];

  function to_ostring (value : UNSIGNED) return STRING;
  function to_ostring (value : SIGNED) return STRING;
  alias to_octal_string is to_ostring [UNSIGNED return STRING];
  alias to_octal_string is to_ostring [SIGNED return STRING];

  function to_hstring (value : UNSIGNED) return STRING;
  function to_hstring (value : SIGNED) return STRING;
  alias to_hex_string is to_hstring [UNSIGNED return STRING];
  alias to_hex_string is to_hstring [SIGNED return STRING];

  procedure READ(L : inout LINE; VALUE : out UNSIGNED; GOOD : out BOOLEAN);

  procedure READ(L : inout LINE; VALUE : out UNSIGNED);

  procedure READ(L : inout LINE; VALUE : out SIGNED; GOOD : out BOOLEAN);

  procedure READ(L : inout LINE; VALUE : out SIGNED);

  procedure WRITE (L         : inout LINE; VALUE : in UNSIGNED;
                   JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);

  procedure WRITE (L         : inout LINE; VALUE : in SIGNED;
                   JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);

  alias BREAD is READ [LINE, UNSIGNED, BOOLEAN];
  alias BREAD is READ [LINE, SIGNED, BOOLEAN];

  alias BREAD is READ [LINE, UNSIGNED];
  alias BREAD is READ [LINE, SIGNED];

  alias BINARY_READ is READ [LINE, UNSIGNED, BOOLEAN];
  alias BINARY_READ is READ [LINE, SIGNED, BOOLEAN];

  alias BINARY_READ is READ [LINE, UNSIGNED];
  alias BINARY_READ is READ [LINE, SIGNED];

  procedure OREAD (L : inout LINE; VALUE : out UNSIGNED; GOOD : out BOOLEAN);
  procedure OREAD (L : inout LINE; VALUE : out SIGNED; GOOD : out BOOLEAN);

  procedure OREAD (L : inout LINE; VALUE : out UNSIGNED);
  procedure OREAD (L : inout LINE; VALUE : out SIGNED);

  alias OCTAL_READ is OREAD [LINE, UNSIGNED, BOOLEAN];
  alias OCTAL_READ is OREAD [LINE, SIGNED, BOOLEAN];

  alias OCTAL_READ is OREAD [LINE, UNSIGNED];
  alias OCTAL_READ is OREAD [LINE, SIGNED];

  procedure HREAD (L : inout LINE; VALUE : out UNSIGNED; GOOD : out BOOLEAN);
  procedure HREAD (L : inout LINE; VALUE : out SIGNED; GOOD : out BOOLEAN);

  procedure HREAD (L : inout LINE; VALUE : out UNSIGNED);
  procedure HREAD (L : inout LINE; VALUE : out SIGNED);

  alias HEX_READ is HREAD [LINE, UNSIGNED, BOOLEAN];
  alias HEX_READ is HREAD [LINE, SIGNED, BOOLEAN];

  alias HEX_READ is HREAD [LINE, UNSIGNED];
  alias HEX_READ is HREAD [LINE, SIGNED];

  alias BWRITE is WRITE [LINE, UNSIGNED, SIDE, WIDTH];
  alias BWRITE is WRITE [LINE, SIGNED, SIDE, WIDTH];

  alias BINARY_WRITE is WRITE [LINE, UNSIGNED, SIDE, WIDTH];
  alias BINARY_WRITE is WRITE [LINE, SIGNED, SIDE, WIDTH];

  procedure OWRITE (L         : inout LINE; VALUE : in UNSIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);

  procedure OWRITE (L         : inout LINE; VALUE : in SIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);

  alias OCTAL_WRITE is OWRITE [LINE, UNSIGNED, SIDE, WIDTH];
  alias OCTAL_WRITE is OWRITE [LINE, SIGNED, SIDE, WIDTH];

  procedure HWRITE (L         : inout LINE; VALUE : in UNSIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);

  procedure HWRITE (L         : inout LINE; VALUE : in SIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0);

  alias HEX_WRITE is HWRITE [LINE, UNSIGNED, SIDE, WIDTH];
  alias HEX_WRITE is HWRITE [LINE, SIGNED, SIDE, WIDTH];

  -- rtl_synthesis on 
-- pragma synthesis_on
end package numeric_std_additions;

package body numeric_std_additions is
  constant NAU : UNSIGNED(0 downto 1) := (others => '0');
  constant NAS : SIGNED(0 downto 1)   := (others => '0');
  constant NO_WARNING : BOOLEAN := false;  -- default to emit warnings
  function MAX (left, right : INTEGER) return INTEGER is
  begin
    if left > right then return left;
    else return right;
    end if;
  end function MAX;

  -- Id: A.3R
  function "+"(L : UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    variable XR : UNSIGNED(L'length-1 downto 0) := (others => '0');
  begin
    XR(0) := R;
    return (L + XR);
  end function "+";

  -- Id: A.3L
  function "+"(L : STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    variable XL : UNSIGNED(R'length-1 downto 0) := (others => '0');
  begin
    XL(0) := L;
    return (XL + R);
  end function "+";

  -- Id: A.4R
  function "+"(L : SIGNED; R: STD_ULOGIC) return SIGNED is
    variable XR : SIGNED(L'length-1 downto 0) := (others => '0');
  begin
    XR(0) := R;
    return (L + XR);
  end function "+";

  -- Id: A.4L
  function "+"(L : STD_ULOGIC; R: SIGNED) return SIGNED is
    variable XL : SIGNED(R'length-1 downto 0) := (others => '0');
  begin
    XL(0) := L;
    return (XL + R);
  end function "+";

  -- Id: A.9R
  function "-"(L : UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    variable XR : UNSIGNED(L'length-1 downto 0) := (others => '0');
  begin
    XR(0) := R;
    return (L - XR);
  end function "-";

  -- Id: A.9L
  function "-"(L : STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    variable XL : UNSIGNED(R'length-1 downto 0) := (others => '0');
  begin
    XL(0) := L;
    return (XL - R);
  end function "-";

  -- Id: A.10R
  function "-"(L : SIGNED; R: STD_ULOGIC) return SIGNED is
    variable XR : SIGNED(L'length-1 downto 0) := (others => '0');
  begin
    XR(0) := R;
    return (L - XR);
  end function "-";

  -- Id: A.10L
  function "-"(L : STD_ULOGIC; R: SIGNED) return SIGNED is
    variable XL : SIGNED(R'length-1 downto 0) := (others => '0');
  begin
    XL(0) := L;
    return (XL - R);
  end function "-";

--  type stdlogic_table is array(STD_ULOGIC, STD_ULOGIC) of STD_ULOGIC;
--  constant match_logic_table : stdlogic_table := (
--    -----------------------------------------------------
--    -- U    X    0    1    Z    W    L    H    -         |   |  
--    -----------------------------------------------------
--    ( 'U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', '1' ),  -- | U |
--    ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1' ),  -- | X |
--    ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '1' ),  -- | 0 |
--    ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '1' ),  -- | 1 |
--    ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1' ),  -- | Z |
--    ( 'U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '1' ),  -- | W |
--    ( 'U', 'X', '1', '0', 'X', 'X', '1', '0', '1' ),  -- | L |
--    ( 'U', 'X', '0', '1', 'X', 'X', '0', '1', '1' ),  -- | H |
--    ( '1', '1', '1', '1', '1', '1', '1', '1', '1' )   -- | - |
--    );
--  constant no_match_logic_table : stdlogic_table := (
--    -----------------------------------------------------
--    -- U    X    0    1    Z    W    L    H    -         |   |  
--    -----------------------------------------------------
--    ('U', 'U', 'U', 'U', 'U', 'U', 'U', 'U', '0'),  -- | U |
--    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '0'),  -- | X |
--    ('U', 'X', '0', '1', 'X', 'X', '0', '1', '0'),  -- | 0 |
--    ('U', 'X', '1', '0', 'X', 'X', '1', '0', '0'),  -- | 1 |
--    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '0'),  -- | Z |
--    ('U', 'X', 'X', 'X', 'X', 'X', 'X', 'X', '0'),  -- | W |
--    ('U', 'X', '0', '1', 'X', 'X', '0', '1', '0'),  -- | L |
--    ('U', 'X', '1', '0', 'X', 'X', '1', '0', '0'),  -- | H |
--    ('0', '0', '0', '0', '0', '0', '0', '0', '0')   -- | - |
--    );

-- %%% FUNCTION "?=" ( l, r : std_ulogic ) RETURN std_ulogic IS
--  function \?=\ ( l, r : STD_ULOGIC ) return STD_ULOGIC is
--    variable value : STD_ULOGIC;
--  begin
--    return match_logic_table (l, r);
--  end function \?=\;
--  function \?/=\ (l, r : STD_ULOGIC) return STD_ULOGIC is
--  begin
--    return no_match_logic_table (l, r);
--  end function \?/=\;

  -- "?=" operator is similar to "std_match", but returns a std_ulogic..
  -- Id: M.2B
--  function \?=\ (L, R: UNSIGNED) return STD_ULOGIC is
--    constant L_LEFT : INTEGER := L'length-1;
--    constant R_LEFT : INTEGER := R'length-1;
--    alias XL        : UNSIGNED(L_LEFT downto 0) is L;
--    alias XR        : UNSIGNED(R_LEFT downto 0) is R;
--    constant SIZE   : NATURAL := MAX(L'length, R'length);
--    variable LX     : UNSIGNED(SIZE-1 downto 0);
--    variable RX     : UNSIGNED(SIZE-1 downto 0);
--    variable result, result1 : STD_ULOGIC;          -- result
--  begin
--    -- Logically identical to an "=" operator.
--    if ((L'length < 1) or (R'length < 1)) then
--      assert NO_WARNING
--        report "NUMERIC_STD.""?="": null detected, returning X"
--        severity warning;
--      return 'X';
--    else
--      LX := RESIZE(XL, SIZE);
--      RX := RESIZE(XR, SIZE);
--      result := '1';
--      for i in LX'low to LX'high loop
--        result1 := \?=\(LX(i), RX(i));
--        if result1 = 'U' then
--          return 'U';
--        elsif result1 = 'X' or result = 'X' then
--          result := 'X';
--        else
--          result := result and result1;
--        end if;
--      end loop;
--      return result;
--    end if;
--  end function \?=\;

--  -- %%% Replace with the following function
--  -- function "?=" (L, R: UNSIGNED) return std_ulogic is
--  -- end function "?=";
  
--  -- Id: M.3B
--  function \?=\ (L, R: SIGNED) return STD_ULOGIC is
--    constant L_LEFT : INTEGER := L'length-1;
--    constant R_LEFT : INTEGER := R'length-1;
--    alias XL        : SIGNED(L_LEFT downto 0) is L;
--    alias XR        : SIGNED(R_LEFT downto 0) is R;
--    constant SIZE   : NATURAL := MAX(L'length, R'length);
--    variable LX     : SIGNED(SIZE-1 downto 0);
--    variable RX     : SIGNED(SIZE-1 downto 0);
--    variable result, result1 : STD_ULOGIC;          -- result
--  begin                                 -- ?=
--    if ((L'length < 1) or (R'length < 1)) then
--      assert NO_WARNING
--        report "NUMERIC_STD.""?="": null detected, returning X"
--        severity warning;
--      return 'X';
--    else
--      LX := RESIZE(XL, SIZE);
--      RX := RESIZE(XR, SIZE);
--      result := '1';
--      for i in LX'low to LX'high loop
--        result1 := \?=\ (LX(i), RX(i));
--        if result1 = 'U' then
--          return 'U';
--        elsif result1 = 'X' or result = 'X' then
--          result := 'X';
--        else
--          result := result and result1;
--        end if;
--      end loop;
--      return result;
--    end if;
--  end function \?=\;
  -- %%% Replace with the following function
--  function "?=" (L, R: signed) return std_ulogic is
--  end function "?=";

  -- Id: C.75
--  function \?=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC is
--  begin
--    return \?=\ (TO_UNSIGNED(L, R'length), R);
--  end function \?=\;

--  -- Id: C.76
--  function \?=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC is
--  begin
--    return \?=\ (TO_SIGNED(L, R'length), R);
--  end function \?=\;

--  -- Id: C.77
--  function \?=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC is
--  begin
--    return \?=\ (L, TO_UNSIGNED(R, L'length));
--  end function \?=\;

--  -- Id: C.78
--  function \?=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC is
--  begin
--    return \?=\ (L, TO_SIGNED(R, L'length));
--  end function \?=\;

--  function \?/=\ (L, R : UNSIGNED) return STD_ULOGIC is
--    constant L_LEFT : INTEGER := L'length-1;
--    constant R_LEFT : INTEGER := R'length-1;
--    alias XL        : UNSIGNED(L_LEFT downto 0) is L;
--    alias XR        : UNSIGNED(R_LEFT downto 0) is R;
--    constant SIZE   : NATURAL := MAX(L'length, R'length);
--    variable LX     : UNSIGNED(SIZE-1 downto 0);
--    variable RX     : UNSIGNED(SIZE-1 downto 0);
--    variable result, result1 : STD_ULOGIC;             -- result
--  begin                                 -- ?=
--    if ((L'length < 1) or (R'length < 1)) then
--      assert NO_WARNING
--        report "NUMERIC_STD.""?/="": null detected, returning X"
--        severity warning;
--      return 'X';
--    else
--      LX := RESIZE(XL, SIZE);
--      RX := RESIZE(XR, SIZE);
--      result := '0';
--      for i in LX'low to LX'high loop
--        result1 := \?/=\ (LX(i), RX(i));
--        if result1 = 'U' then
--          return 'U';
--        elsif result1 = 'X' or result = 'X' then
--          result := 'X';
--        else
--          result := result or result1;
--        end if;
--      end loop;
--      return result;
--    end if;
--  end function \?/=\;
--  -- %%% function "?/=" (L, R : UNSIGNED) return std_ulogic is
--  -- %%% end function "?/=";
--  function \?/=\ (L, R : SIGNED) return STD_ULOGIC is
--    constant L_LEFT : INTEGER := L'length-1;
--    constant R_LEFT : INTEGER := R'length-1;
--    alias XL        : SIGNED(L_LEFT downto 0) is L;
--    alias XR        : SIGNED(R_LEFT downto 0) is R;
--    constant SIZE   : NATURAL := MAX(L'length, R'length);
--    variable LX     : SIGNED(SIZE-1 downto 0);
--    variable RX     : SIGNED(SIZE-1 downto 0);
--    variable result, result1 : STD_ULOGIC;                   -- result
--  begin                                 -- ?=
--    if ((L'length < 1) or (R'length < 1)) then
--      assert NO_WARNING
--        report "NUMERIC_STD.""?/="": null detected, returning X"
--        severity warning;
--      return 'X';
--    else
--      LX := RESIZE(XL, SIZE);
--      RX := RESIZE(XR, SIZE);
--      result := '0';
--      for i in LX'low to LX'high loop
--        result1 := \?/=\ (LX(i), RX(i));
--        if result1 = 'U' then
--          return 'U';
--        elsif result1 = 'X' or result = 'X' then
--          result := 'X';
--        else
--          result := result or result1;
--        end if;
--      end loop;
--      return result;
--    end if;
--  end function \?/=\;
--  -- %%% function "?/=" (L, R : SIGNED) return std_ulogic is
--  -- %%% end function "?/=";

--  -- Id: C.75
--  function \?/=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC is
--  begin
--    return \?/=\ (TO_UNSIGNED(L, R'length), R);
--  end function \?/=\;

--  -- Id: C.76
--  function \?/=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC is
--  begin
--    return \?/=\ (TO_SIGNED(L, R'length), R);
--  end function \?/=\;

--  -- Id: C.77
--  function \?/=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC is
--  begin
--    return \?/=\ (L, TO_UNSIGNED(R, L'length));
--  end function \?/=\;

--  -- Id: C.78
--  function \?/=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC is
--  begin
--    return \?/=\ (L, TO_SIGNED(R, L'length));
--  end function \?/=\;
  
  function \?>\ (L, R : UNSIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?>"": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?>"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?>"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l > r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?>\;
  -- %%% function "?>" (L, R : UNSIGNED) return std_ulogic is
  -- %%% end function "?>"\;
  function \?>\ (L, R : SIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?>"": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?>"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?>"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l > r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?>\;
  -- %%% function "?>" (L, R : SIGNED) return std_ulogic is
  -- %%% end function "?>";
  -- Id: C.57
  function \?>\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC is
  begin
    return \?>\ (TO_UNSIGNED(L, R'length), R);
  end function \?>\;

  -- Id: C.58
  function \?>\ (L : INTEGER; R : SIGNED) return STD_ULOGIC is
  begin
    return \?>\ (TO_SIGNED(L, R'length),R);
  end function \?>\;

  -- Id: C.59
  function \?>\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC is
  begin
    return \?>\ (L, TO_UNSIGNED(R, L'length));
  end function \?>\;

  -- Id: C.60
  function \?>\ (L : SIGNED; R : INTEGER) return STD_ULOGIC is
  begin
    return \?>\ (L, TO_SIGNED(R, L'length));
  end function \?>\;
  
  function \?>=\ (L, R : UNSIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?>="": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?>="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?>="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l >= r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?>=\;
  -- %%% function "?>=" (L, R : UNSIGNED) return std_ulogic is
  -- %%% end function "?>=";
  function \?>=\ (L, R : SIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?>="": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?>="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?>="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l >= r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?>=\;
  -- %%% function "?>=" (L, R : SIGNED) return std_ulogic is
  -- %%% end function "?>=";

  function \?>=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC is
  begin
    return \?>=\ (TO_UNSIGNED(L, R'length), R);
  end function \?>=\;

  -- Id: C.64
  function \?>=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC is
  begin
    return \?>=\ (TO_SIGNED(L, R'length),R);
  end function \?>=\;

  -- Id: C.65
  function \?>=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC is
  begin
    return \?>=\ (L, TO_UNSIGNED(R, L'length));
  end function \?>=\;

  -- Id: C.66
  function \?>=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC is
  begin
    return \?>=\ (L, TO_SIGNED(R, L'length));
  end function \?>=\;
  
  function \?<\ (L, R : UNSIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?<"": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?<"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?<"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l < r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?<\;
  -- %%% function "?<" (L, R : UNSIGNED) return std_ulogic is
  -- %%% end function "?<";
  function \?<\ (L, R : SIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?<"": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?<"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?<"": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l < r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?<\;
  -- %%% function "?<" (L, R : SIGNED) return std_ulogic is
  -- %%% end function "?<";

  -- Id: C.57
  function \?<\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC is
  begin
    return \?<\ (TO_UNSIGNED(L, R'length), R);
  end function \?<\;

  -- Id: C.58
  function \?<\ (L : INTEGER; R : SIGNED) return STD_ULOGIC is
  begin
    return \?<\ (TO_SIGNED(L, R'length),R);
  end function \?<\;

  -- Id: C.59
  function \?<\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC is
  begin
    return \?<\ (L, TO_UNSIGNED(R, L'length));
  end function \?<\;

  -- Id: C.60
  function \?<\ (L : SIGNED; R : INTEGER) return STD_ULOGIC is
  begin
    return \?<\ (L, TO_SIGNED(R, L'length));
  end function \?<\;

  function \?<=\ (L, R : UNSIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?<="": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?<="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?<="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l <= r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?<=\;
  -- %%% function "?<=" (L, R : UNSIGNED) return std_ulogic is
  -- %%% end function "?<=";
  function \?<=\ (L, R : SIGNED) return STD_ULOGIC is
  begin
    if ((l'length < 1) or (r'length < 1)) then
      assert NO_WARNING
        report "NUMERIC_STD.""?<="": null detected, returning X"
        severity warning;
      return 'X';
    else
      for i in L'range loop
        if L(i) = '-' then
          report "NUMERIC_STD.""?<="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      for i in R'range loop
        if R(i) = '-' then
          report "NUMERIC_STD.""?<="": '-' found in compare string"
            severity error;
          return 'X';
        end if;
      end loop;
      if is_x(l) or is_x(r) then
        return 'X';
      elsif l <= r then
        return '1';
      else
        return '0';
      end if;
    end if;
  end function \?<=\;
  -- %%% function "?<=" (L, R : SIGNED) return std_ulogic is
  -- %%% end function "?<=";
  -- Id: C.63
  function \?<=\ (L : NATURAL; R : UNSIGNED) return STD_ULOGIC is
  begin
    return \?<=\ (TO_UNSIGNED(L, R'length), R);
  end function \?<=\;

  -- Id: C.64
  function \?<=\ (L : INTEGER; R : SIGNED) return STD_ULOGIC is
  begin
    return \?<=\ (TO_SIGNED(L, R'length),R);
  end function \?<=\;

  -- Id: C.65
  function \?<=\ (L : UNSIGNED; R : NATURAL) return STD_ULOGIC is
  begin
    return \?<=\ (L, TO_UNSIGNED(R, L'length));
  end function \?<=\;

  -- Id: C.66
  function \?<=\ (L : SIGNED; R : INTEGER) return STD_ULOGIC is
  begin
    return \?<=\ (L, TO_SIGNED(R, L'length));
  end function \?<=\;

  -- size_res versions of these functions (Bugzilla 165)
  function TO_UNSIGNED (ARG : NATURAL; SIZE_RES : UNSIGNED)
    return UNSIGNED is
  begin
    return TO_UNSIGNED (ARG  => ARG,
                        SIZE => SIZE_RES'length);
  end function TO_UNSIGNED;

  function TO_SIGNED (ARG : INTEGER; SIZE_RES : SIGNED)
    return SIGNED is
  begin
    return TO_SIGNED (ARG  => ARG,
                      SIZE => SIZE_RES'length);
  end function TO_SIGNED;

  function RESIZE (ARG, SIZE_RES : SIGNED)
    return SIGNED is
  begin
    return RESIZE (ARG      => ARG,
                   NEW_SIZE => SIZE_RES'length);
  end function RESIZE;

  function RESIZE (ARG, SIZE_RES : UNSIGNED)
    return UNSIGNED is
  begin
    return RESIZE (ARG      => ARG,
                   NEW_SIZE => SIZE_RES'length);
  end function RESIZE;

  -- Id: S.9
  function "sll" (ARG : UNSIGNED; COUNT : INTEGER)
    return UNSIGNED is
  begin
    if (COUNT >= 0) then
      return SHIFT_LEFT(ARG, COUNT);
    else
      return SHIFT_RIGHT(ARG, -COUNT);
    end if;
  end function "sll";

  ------------------------------------------------------------------------------
  --   Note: Function S.10 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.10
  function "sll" (ARG : SIGNED; COUNT : INTEGER)
    return SIGNED is
  begin
    if (COUNT >= 0) then
      return SHIFT_LEFT(ARG, COUNT);
    else
      return SIGNED(SHIFT_RIGHT(UNSIGNED(ARG), -COUNT));
    end if;
  end function "sll";

  ------------------------------------------------------------------------------
  --   Note: Function S.11 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.11
  function "srl" (ARG : UNSIGNED; COUNT : INTEGER)
    return UNSIGNED is
  begin
    if (COUNT >= 0) then
      return SHIFT_RIGHT(ARG, COUNT);
    else
      return SHIFT_LEFT(ARG, -COUNT);
    end if;
  end function "srl";

  ------------------------------------------------------------------------------
  --   Note: Function S.12 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.12
  function "srl" (ARG : SIGNED; COUNT : INTEGER)
    return SIGNED is
  begin
    if (COUNT >= 0) then
      return SIGNED(SHIFT_RIGHT(UNSIGNED(ARG), COUNT));
    else
      return SHIFT_LEFT(ARG, -COUNT);
    end if;
  end function "srl";

  ------------------------------------------------------------------------------
  -- Note: Function S.13 is not compatible with IEEE Std 1076-1987. Comment
  --   out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.13
  function "rol" (ARG : UNSIGNED; COUNT : INTEGER)
    return UNSIGNED is
  begin
    if (COUNT >= 0) then
      return ROTATE_LEFT(ARG, COUNT);
    else
      return ROTATE_RIGHT(ARG, -COUNT);
    end if;
  end function "rol";

  ------------------------------------------------------------------------------
  --   Note: Function S.14 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.14
  function "rol" (ARG : SIGNED; COUNT : INTEGER)
    return SIGNED is
  begin
    if (COUNT >= 0) then
      return ROTATE_LEFT(ARG, COUNT);
    else
      return ROTATE_RIGHT(ARG, -COUNT);
    end if;
  end function "rol";

  ------------------------------------------------------------------------------
  --   Note: Function S.15 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.15
  function "ror" (ARG : UNSIGNED; COUNT : INTEGER)
    return UNSIGNED is
  begin
    if (COUNT >= 0) then
      return ROTATE_RIGHT(ARG, COUNT);
    else
      return ROTATE_LEFT(ARG, -COUNT);
    end if;
  end function "ror";

  ------------------------------------------------------------------------------
  -- Note: Function S.16 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.16
  function "ror" (ARG : SIGNED; COUNT : INTEGER)
    return SIGNED is
  begin
    if (COUNT >= 0) then
      return ROTATE_RIGHT(ARG, COUNT);
    else
      return ROTATE_LEFT(ARG, -COUNT);
    end if;
  end function "ror";

-- begin LCS-2006-120

  ------------------------------------------------------------------------------
  -- Note: Function S.17 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.17
  function "sla" (ARG : UNSIGNED; COUNT : INTEGER)
    return UNSIGNED is
  begin
    if (COUNT >= 0) then
      return SHIFT_LEFT(ARG, COUNT);
    else
      return SHIFT_RIGHT(ARG, -COUNT);
    end if;
  end function "sla";

  ------------------------------------------------------------------------------
  -- Note: Function S.18 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.18
  function "sla" (ARG : SIGNED; COUNT : INTEGER)
    return SIGNED is
  begin
    if (COUNT >= 0) then
      return SHIFT_LEFT(ARG, COUNT);
    else
      return SHIFT_RIGHT(ARG, -COUNT);
    end if;
  end function "sla";

  ------------------------------------------------------------------------------
  -- Note: Function S.19 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.19
  function "sra" (ARG : UNSIGNED; COUNT : INTEGER)
    return UNSIGNED is
  begin
    if (COUNT >= 0) then
      return SHIFT_RIGHT(ARG, COUNT);
    else
      return SHIFT_LEFT(ARG, -COUNT);
    end if;
  end function "sra";

  ------------------------------------------------------------------------------
  -- Note: Function S.20 is not compatible with IEEE Std 1076-1987. Comment
  -- out the function (declaration and body) for IEEE Std 1076-1987 compatibility.
  ------------------------------------------------------------------------------
  -- Id: S.20
  function "sra" (ARG : SIGNED; COUNT : INTEGER)
    return SIGNED is
  begin
    if (COUNT >= 0) then
      return SHIFT_RIGHT(ARG, COUNT);
    else
      return SHIFT_LEFT(ARG, -COUNT);
    end if;
  end function "sra";

  -- These functions are in std_logic_1164 and are defined for
  -- std_logic_vector.  They are overloaded here.
  function To_X01 ( s : UNSIGNED ) return UNSIGNED is
  begin
    return UNSIGNED (To_X01 (STD_LOGIC_VECTOR (s)));
  end function To_X01;
  
  function To_X01 ( s : SIGNED ) return SIGNED is
  begin
    return SIGNED (To_X01 (STD_LOGIC_VECTOR (s)));
  end function To_X01;
  
  function To_X01Z ( s : UNSIGNED ) return UNSIGNED is
  begin
    return UNSIGNED (To_X01Z (STD_LOGIC_VECTOR (s)));
  end function To_X01Z;

  function To_X01Z ( s : SIGNED ) return SIGNED is
  begin
    return SIGNED (To_X01Z (STD_LOGIC_VECTOR (s)));
  end function To_X01Z;
  
  function To_UX01 ( s : UNSIGNED ) return UNSIGNED is
  begin
    return UNSIGNED (To_UX01 (STD_LOGIC_VECTOR (s)));
  end function To_UX01;
  
  function To_UX01 ( s : SIGNED ) return SIGNED is
  begin
    return SIGNED (To_UX01 (STD_LOGIC_VECTOR (s)));
  end function To_UX01;

  function Is_X ( s : UNSIGNED ) return BOOLEAN is
  begin
    return Is_X (STD_LOGIC_VECTOR (s));
  end function Is_X;
  
  function Is_X ( s : SIGNED ) return BOOLEAN is
  begin
    return Is_X (STD_LOGIC_VECTOR (s));
  end function Is_X;

  -----------------------------------------------------------------------------
  -- New/updated functions for VHDL-200X fast track
  -----------------------------------------------------------------------------

  -- Returns the maximum (or minimum) of the two numbers provided.
  -- All types (both inputs and the output) must be the same.
  -- These override the implicit functions, using the local ">" operator
  -- UNSIGNED output
  function MAXIMUM (L, R : UNSIGNED) return UNSIGNED is
    constant SIZE : NATURAL := MAX(L'length, R'length);
    variable L01  : UNSIGNED(SIZE-1 downto 0);
    variable R01  : UNSIGNED(SIZE-1 downto 0);
  begin
    if ((L'length < 1) or (R'length < 1)) then return NAU;
    end if;
    L01 := TO_01(RESIZE(L, SIZE), 'X');
    if (L01(L01'left) = 'X') then return L01;
    end if;
    R01 := TO_01(RESIZE(R, SIZE), 'X');
    if (R01(R01'left) = 'X') then return R01;
    end if;
    if L01 < R01 then
      return R01;
    else
      return L01;
    end if;
  end function MAXIMUM;

  -- signed output
  function MAXIMUM (L, R : SIGNED) return SIGNED is
    constant SIZE : NATURAL := MAX(L'length, R'length);
    variable L01  : SIGNED(SIZE-1 downto 0);
    variable R01  : SIGNED(SIZE-1 downto 0);
  begin
    if ((L'length < 1) or (R'length < 1)) then return NAS;
    end if;
    L01 := TO_01(RESIZE(L, SIZE), 'X');
    if (L01(L01'left) = 'X') then return L01;
    end if;
    R01 := TO_01(RESIZE(R, SIZE), 'X');
    if (R01(R01'left) = 'X') then return R01;
    end if;
    if L01 < R01 then
      return R01;
    else
      return L01;
    end if;
  end function MAXIMUM;

  -- UNSIGNED output
  function MINIMUM (L, R : UNSIGNED) return UNSIGNED is
    constant SIZE : NATURAL := MAX(L'length, R'length);
    variable L01  : UNSIGNED(SIZE-1 downto 0);
    variable R01  : UNSIGNED(SIZE-1 downto 0);
  begin
    if ((L'length < 1) or (R'length < 1)) then return NAU;
    end if;
    L01 := TO_01(RESIZE(L, SIZE), 'X');
    if (L01(L01'left) = 'X') then return L01;
    end if;
    R01 := TO_01(RESIZE(R, SIZE), 'X');
    if (R01(R01'left) = 'X') then return R01;
    end if;
    if L01 < R01 then
      return L01;
    else
      return R01;
    end if;
  end function MINIMUM;


  -- signed output
  function MINIMUM (L, R : SIGNED) return SIGNED is
    constant SIZE : NATURAL := MAX(L'length, R'length);
    variable L01  : SIGNED(SIZE-1 downto 0);
    variable R01  : SIGNED(SIZE-1 downto 0);
  begin
    if ((L'length < 1) or (R'length < 1)) then return NAS;
    end if;
    L01 := TO_01(RESIZE(L, SIZE), 'X');
    if (L01(L01'left) = 'X') then return L01;
    end if;
    R01 := TO_01(RESIZE(R, SIZE), 'X');
    if (R01(R01'left) = 'X') then return R01;
    end if;
    if L01 < R01 then
      return L01;
    else
      return R01;
    end if;
  end function MINIMUM;

  -- Id: C.39
  function MINIMUM (L : NATURAL; R : UNSIGNED)
    return UNSIGNED is
  begin
    return MINIMUM(TO_UNSIGNED(L, R'length), R);
  end function MINIMUM;

  -- Id: C.40
  function MINIMUM (L : INTEGER; R : SIGNED)
    return SIGNED is
  begin
    return MINIMUM(TO_SIGNED(L, R'length), R);
  end function MINIMUM;

  -- Id: C.41
  function MINIMUM (L : UNSIGNED; R : NATURAL)
    return UNSIGNED is
  begin
    return MINIMUM(L, TO_UNSIGNED(R, L'length));
  end function MINIMUM;

  -- Id: C.42
  function MINIMUM (L : SIGNED; R : INTEGER)
    return SIGNED is
  begin
    return MINIMUM(L, TO_SIGNED(R, L'length));
  end function MINIMUM;
  
  -- Id: C.45
  function MAXIMUM (L : NATURAL; R : UNSIGNED)
    return UNSIGNED is
  begin
    return MAXIMUM(TO_UNSIGNED(L, R'length), R);
  end function MAXIMUM;

  -- Id: C.46
  function MAXIMUM (L : INTEGER; R : SIGNED)
    return SIGNED is
  begin
    return MAXIMUM(TO_SIGNED(L, R'length), R);
  end function MAXIMUM;

  -- Id: C.47
  function MAXIMUM (L : UNSIGNED; R : NATURAL)
    return UNSIGNED is
  begin
    return MAXIMUM(L, TO_UNSIGNED(R, L'length));
  end function MAXIMUM;

  -- Id: C.48
  function MAXIMUM (L : SIGNED; R : INTEGER)
    return SIGNED is
  begin
    return MAXIMUM(L, TO_SIGNED(R, L'length));
  end function MAXIMUM;

  function find_rightmost (
    arg : UNSIGNED;                         -- vector argument
    y   : STD_ULOGIC)                       -- look for this bit
    return INTEGER is
    alias xarg : UNSIGNED(arg'length-1 downto 0) is arg;
  begin
    for_loop: for i in xarg'reverse_range loop
      if xarg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_rightmost;

  function find_rightmost (
    arg : SIGNED;                           -- vector argument
    y   : STD_ULOGIC)                       -- look for this bit
    return INTEGER is
    alias xarg : SIGNED(arg'length-1 downto 0) is arg;
  begin
    for_loop: for i in xarg'reverse_range loop
      if xarg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_rightmost;

  function find_leftmost (
    arg : UNSIGNED;                        -- vector argument
    y   : STD_ULOGIC)                      -- look for this bit
    return INTEGER is
    alias xarg : UNSIGNED(arg'length-1 downto 0) is arg;
  begin
    for_loop: for i in xarg'range loop
      if xarg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_leftmost;

  function find_leftmost (
    arg : SIGNED;                          -- vector argument
    y   : STD_ULOGIC)                      -- look for this bit
    return INTEGER is
    alias xarg : SIGNED(arg'length-1 downto 0) is arg;
  begin
    for_loop: for i in xarg'range loop
      if xarg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_leftmost;

  function TO_UNRESOLVED_UNSIGNED (ARG, SIZE : NATURAL)
    return UNRESOLVED_UNSIGNED is
  begin
    return UNRESOLVED_UNSIGNED(to_unsigned (arg, size));
  end function TO_UNRESOLVED_UNSIGNED;
  -- Result subtype: UNRESOLVED_UNSIGNED(SIZE-1 downto 0)
  -- Result: Converts a nonnegative INTEGER to an UNRESOLVED_UNSIGNED vector with
  --         the specified SIZE.


  function TO_UNRESOLVED_SIGNED (ARG : INTEGER; SIZE : NATURAL)
    return UNRESOLVED_SIGNED is
  begin
    return UNRESOLVED_SIGNED(to_signed (arg, size));
  end function TO_UNRESOLVED_SIGNED;
  -- Result subtype: UNRESOLVED_SIGNED(SIZE-1 downto 0)
  -- Result: Converts an INTEGER to an UNRESOLVED_SIGNED vector of the specified SIZE.

  -- Performs the boolean operation on every bit in the vector
-- L.15 
  function "and" (L: STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    alias rv        : UNSIGNED ( 1 to r'length ) is r;
    variable result : UNSIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "and" (l, rv(i));
    end loop;
    return result;
  end function "and";

-- L.16 
  function "and" (L: UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    alias lv        : UNSIGNED ( 1 to l'length ) is l;
    variable result : UNSIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "and" (lv(i), r);
    end loop;
    return result;
  end function "and";

-- L.17 
  function "or" (L: STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    alias rv        : UNSIGNED ( 1 to r'length ) is r;
    variable result : UNSIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "or" (l, rv(i));
    end loop;
    return result;
  end function "or";

-- L.18 
  function "or" (L: UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    alias lv        : UNSIGNED ( 1 to l'length ) is l;
    variable result : UNSIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "or" (lv(i), r);
    end loop;
    return result;
  end function "or";

-- L.19 
  function "nand" (L: STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    alias rv        : UNSIGNED ( 1 to r'length ) is r;
    variable result : UNSIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "not"("and" (l, rv(i)));
    end loop;
    return result;
  end function "nand";

-- L.20 
  function "nand" (L: UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    alias lv        : UNSIGNED ( 1 to l'length ) is l;
    variable result : UNSIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "not"("and" (lv(i), r));
    end loop;
    return result;
  end function "nand";

-- L.21 
  function "nor" (L: STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    alias rv        : UNSIGNED ( 1 to r'length ) is r;
    variable result : UNSIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "not"("or" (l, rv(i)));
    end loop;
    return result;
  end function "nor";

-- L.22 
  function "nor" (L: UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    alias lv        : UNSIGNED ( 1 to l'length ) is l;
    variable result : UNSIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "not"("or" (lv(i), r));
    end loop;
    return result;
  end function "nor";

-- L.23 
  function "xor" (L: STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    alias rv        : UNSIGNED ( 1 to r'length ) is r;
    variable result : UNSIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "xor" (l, rv(i));
    end loop;
    return result;
  end function "xor";

-- L.24 
  function "xor" (L: UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    alias lv        : UNSIGNED ( 1 to l'length ) is l;
    variable result : UNSIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "xor" (lv(i), r);
    end loop;
    return result;
  end function "xor";

-- L.25 
  function "xnor" (L: STD_ULOGIC; R: UNSIGNED) return UNSIGNED is
    alias rv        : UNSIGNED ( 1 to r'length ) is r;
    variable result : UNSIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "not"("xor" (l, rv(i)));
    end loop;
    return result;
  end function "xnor";

-- L.26 
  function "xnor" (L: UNSIGNED; R: STD_ULOGIC) return UNSIGNED is
    alias lv        : UNSIGNED ( 1 to l'length ) is l;
    variable result : UNSIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "not"("xor" (lv(i), r));
    end loop;
    return result;
  end function "xnor";

-- L.27 
  function "and" (L: STD_ULOGIC; R: SIGNED) return SIGNED is
    alias rv        : SIGNED ( 1 to r'length ) is r;
    variable result : SIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "and" (l, rv(i));
    end loop;
    return result;
  end function "and";

-- L.28 
  function "and" (L: SIGNED; R: STD_ULOGIC) return SIGNED is
    alias lv        : SIGNED ( 1 to l'length ) is l;
    variable result : SIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "and" (lv(i), r);
    end loop;
    return result;
  end function "and";

-- L.29 
  function "or" (L: STD_ULOGIC; R: SIGNED) return SIGNED is
    alias rv        : SIGNED ( 1 to r'length ) is r;
    variable result : SIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "or" (l, rv(i));
    end loop;
    return result;
  end function "or";

-- L.30 
  function "or" (L: SIGNED; R: STD_ULOGIC) return SIGNED is
    alias lv        : SIGNED ( 1 to l'length ) is l;
    variable result : SIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "or" (lv(i), r);
    end loop;
    return result;
  end function "or";

-- L.31 
  function "nand" (L: STD_ULOGIC; R: SIGNED) return SIGNED is
    alias rv        : SIGNED ( 1 to r'length ) is r;
    variable result : SIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "not"("and" (l, rv(i)));
    end loop;
    return result;
  end function "nand";

-- L.32 
  function "nand" (L: SIGNED; R: STD_ULOGIC) return SIGNED is
    alias lv        : SIGNED ( 1 to l'length ) is l;
    variable result : SIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "not"("and" (lv(i), r));
    end loop;
    return result;
  end function "nand";

-- L.33 
  function "nor" (L: STD_ULOGIC; R: SIGNED) return SIGNED is
    alias rv        : SIGNED ( 1 to r'length ) is r;
    variable result : SIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "not"("or" (l, rv(i)));
    end loop;
    return result;
  end function "nor";

-- L.34 
  function "nor" (L: SIGNED; R: STD_ULOGIC) return SIGNED is
    alias lv        : SIGNED ( 1 to l'length ) is l;
    variable result : SIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "not"("or" (lv(i), r));
    end loop;
    return result;
  end function "nor";

-- L.35 
  function "xor" (L: STD_ULOGIC; R: SIGNED) return SIGNED is
    alias rv        : SIGNED ( 1 to r'length ) is r;
    variable result : SIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "xor" (l, rv(i));
    end loop;
    return result;
  end function "xor";

-- L.36 
  function "xor" (L: SIGNED; R: STD_ULOGIC) return SIGNED is
    alias lv        : SIGNED ( 1 to l'length ) is l;
    variable result : SIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "xor" (lv(i), r);
    end loop;
    return result;
  end function "xor";

-- L.37 
  function "xnor" (L: STD_ULOGIC; R: SIGNED) return SIGNED is
    alias rv        : SIGNED ( 1 to r'length ) is r;
    variable result : SIGNED ( 1 to r'length );
  begin
    for i in result'range loop
      result(i) := "not"("xor" (l, rv(i)));
    end loop;
    return result;
  end function "xnor";

-- L.38 
  function "xnor" (L: SIGNED; R: STD_ULOGIC) return SIGNED is
    alias lv        : SIGNED ( 1 to l'length ) is l;
    variable result : SIGNED ( 1 to l'length );
  begin
    for i in result'range loop
      result(i) := "not"("xor" (lv(i), r));
    end loop;
    return result;
  end function "xnor";
  
  --------------------------------------------------------------------------
  -- Reduction operations
  --------------------------------------------------------------------------
  -- %%% Remove the following 12 funcitons (old syntax)
  function and_reduce (l : SIGNED ) return STD_ULOGIC is
  begin
    return and_reduce (UNSIGNED ( l ));
  end function and_reduce;

  function and_reduce ( l : UNSIGNED ) return STD_ULOGIC is
    variable Upper, Lower : STD_ULOGIC;
    variable Half : INTEGER;
    variable BUS_int : UNSIGNED ( l'length - 1 downto 0 );
    variable Result : STD_ULOGIC := '1';    -- In the case of a NULL range
  begin
    if (l'length >= 1) then
      BUS_int := to_ux01 (l);
      if ( BUS_int'length = 1 ) then
        Result := BUS_int ( BUS_int'left );
      elsif ( BUS_int'length = 2 ) then
        Result := "and" (BUS_int(BUS_int'right),BUS_int(BUS_int'left));
      else
        Half := ( BUS_int'length + 1 ) / 2 + BUS_int'right;
        Upper := and_reduce ( BUS_int ( BUS_int'left downto Half ));
        Lower := and_reduce ( BUS_int ( Half - 1 downto BUS_int'right ));
        Result := "and" (Upper, Lower);
      end if;
    end if;
    return Result;
  end function and_reduce;

  function nand_reduce (l : SIGNED ) return STD_ULOGIC is
  begin
    return "not" (and_reduce ( l ));
  end function nand_reduce;

  function nand_reduce (l : UNSIGNED ) return STD_ULOGIC is
  begin
    return "not" (and_reduce (l ));
  end function nand_reduce;
  
  function or_reduce (l : SIGNED ) return STD_ULOGIC is
  begin
    return or_reduce (UNSIGNED ( l ));
  end function or_reduce;

  function or_reduce (l : UNSIGNED ) return STD_ULOGIC is
    variable Upper, Lower : STD_ULOGIC;
    variable Half : INTEGER;
    variable BUS_int : UNSIGNED ( l'length - 1 downto 0 );
    variable Result : STD_ULOGIC := '0';    -- In the case of a NULL range
  begin
    if (l'length >= 1) then
      BUS_int := to_ux01 (l);
      if ( BUS_int'length = 1 ) then
        Result := BUS_int ( BUS_int'left );
      elsif ( BUS_int'length = 2 ) then
        Result := "or" (BUS_int(BUS_int'right), BUS_int(BUS_int'left));
      else
        Half := ( BUS_int'length + 1 ) / 2 + BUS_int'right;
        Upper := or_reduce ( BUS_int ( BUS_int'left downto Half ));
        Lower := or_reduce ( BUS_int ( Half - 1 downto BUS_int'right ));
        Result := "or" (Upper, Lower);
      end if;
    end if;
    return Result;
  end function or_reduce;

  function nor_reduce (l : SIGNED ) return STD_ULOGIC is
  begin
    return "not"(or_reduce(l));
  end function nor_reduce;

  function nor_reduce (l : UNSIGNED ) return STD_ULOGIC is
  begin
    return "not"(or_reduce(l));
  end function nor_reduce;

  function xor_reduce (l : SIGNED ) return STD_ULOGIC is
  begin
    return xor_reduce (UNSIGNED ( l ));
  end function xor_reduce;

  function xor_reduce (l : UNSIGNED ) return STD_ULOGIC is
    variable Upper, Lower : STD_ULOGIC;
    variable Half : INTEGER;
    variable BUS_int : UNSIGNED ( l'length - 1 downto 0 );
    variable Result : STD_ULOGIC := '0';    -- In the case of a NULL range
  begin
    if (l'length >= 1) then
      BUS_int := to_ux01 (l);
      if ( BUS_int'length = 1 ) then
        Result := BUS_int ( BUS_int'left );
      elsif ( BUS_int'length = 2 ) then
        Result := "xor" (BUS_int(BUS_int'right), BUS_int(BUS_int'left));
      else
        Half := ( BUS_int'length + 1 ) / 2 + BUS_int'right;
        Upper := xor_reduce ( BUS_int ( BUS_int'left downto Half ));
        Lower := xor_reduce ( BUS_int ( Half - 1 downto BUS_int'right ));
        Result := "xor" (Upper, Lower);
      end if;
    end if;
    return Result;
  end function xor_reduce;

  function xnor_reduce (l : SIGNED ) return STD_ULOGIC is
  begin
    return "not"(xor_reduce(l));
  end function xnor_reduce;

  function xnor_reduce (l : UNSIGNED ) return STD_ULOGIC is
  begin
    return "not"(xor_reduce(l));
  end function xnor_reduce;

  -- %%% Replace the above with the following 12 functions (New syntax)
--  function "and" ( l  : SIGNED ) return std_ulogic is
--  begin
--    return and (std_logic_vector ( l ));
--  end function "and";

--  function "and" ( l  : UNSIGNED ) return std_ulogic is
--  begin
--    return and (std_logic_vector ( l ));
--  end function "and";

--  function "nand" ( l  : SIGNED ) return std_ulogic is
--  begin
--    return nand (std_logic_vector ( l ));
--  end function "nand";

--  function "nand" ( l  : UNSIGNED ) return std_ulogic is
--  begin
--    return nand (std_logic_vector ( l ));
--  end function "nand";
  
--  function "or" ( l  : SIGNED ) return std_ulogic is
--  begin
--    return or (std_logic_vector ( l ));
--  end function "or";

--  function "or" ( l  : UNSIGNED ) return std_ulogic is
--  begin
--    return or (std_logic_vector ( l ));
--  end function "or";

--  function "nor" ( l  : SIGNED ) return std_ulogic is
--  begin
--    return nor (std_logic_vector ( l ));
--  end function "nor";

--  function "nor" ( l  : UNSIGNED ) return std_ulogic is
--  begin
--    return nor (std_logic_vector ( l ));
--  end function "nor";

--  function "xor" ( l  : SIGNED ) return std_ulogic is
--  begin
--    return xor (std_logic_vector ( l ));
--  end function "xor";

--  function "xor" ( l  : UNSIGNED ) return std_ulogic is
--  begin
--    return xor (std_logic_vector ( l ));
--  end function "xor";

--  function "xnor" ( l  : SIGNED ) return std_ulogic is
--  begin
--    return xnor (std_logic_vector ( l ));
--  end function "xnor";

--  function "xnor" ( l  : UNSIGNED ) return std_ulogic is
--  begin
--    return xnor (std_logic_vector ( l ));
--  end function "xnor";
  
  -- rtl_synthesis off
-- pragma synthesis_off
  -------------------------------------------------------------------    
  -- TO_STRING
  -------------------------------------------------------------------
  -- Type and constant definitions used to map STD_ULOGIC values 
  -- into/from character values.
  type     MVL9plus is ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-', error);
  type     char_indexed_by_MVL9 is array (STD_ULOGIC) of CHARACTER;
  type     MVL9_indexed_by_char is array (CHARACTER) of STD_ULOGIC;
  type     MVL9plus_indexed_by_char is array (CHARACTER) of MVL9plus;
  constant MVL9_to_char : char_indexed_by_MVL9 := "UX01ZWLH-";
  constant char_to_MVL9 : MVL9_indexed_by_char :=
    ('U' => 'U', 'X' => 'X', '0' => '0', '1' => '1', 'Z' => 'Z',
     'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-', others => 'U');
  constant char_to_MVL9plus : MVL9plus_indexed_by_char :=
    ('U' => 'U', 'X' => 'X', '0' => '0', '1' => '1', 'Z' => 'Z',
     'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-', others => error);

  constant NBSP : CHARACTER := CHARACTER'val(160);  -- space character
  constant NUS : STRING(2 to 1)   := (others => ' ');  -- NULL array
  
  function to_string (value     : UNSIGNED) return STRING is
    alias ivalue    : UNSIGNED(1 to value'length) is value;
    variable result : STRING(1 to value'length);
  begin
    if value'length < 1 then
      return NUS;
    else
      for i in ivalue'range loop
        result(i) := MVL9_to_char( iValue(i) );
      end loop;
      return result;
    end if;
  end function to_string;

  function to_string (value     : SIGNED) return STRING is
    alias ivalue    : SIGNED(1 to value'length) is value;
    variable result : STRING(1 to value'length);
  begin
    if value'length < 1 then
      return NUS;
    else
      for i in ivalue'range loop
        result(i) := MVL9_to_char( iValue(i) );
      end loop;
      return result;
    end if;
  end function to_string;
  
  function to_hstring (value     : SIGNED) return STRING is
    constant ne     : INTEGER  := (value'length+3)/4;
    variable pad    : STD_LOGIC_VECTOR(0 to (ne*4 - value'length) - 1);
    variable ivalue : STD_LOGIC_VECTOR(0 to ne*4 - 1);
    variable result : STRING(1 to ne);
    variable quad   : STD_LOGIC_VECTOR(0 to 3);
  begin
    if value'length < 1 then
      return NUS;
    else
      if value (value'left) = 'Z' then
        pad := (others => 'Z');
      else
        pad := (others => value(value'high));  -- Extend sign bit
      end if;
      ivalue := pad & STD_LOGIC_VECTOR (value);
      for i in 0 to ne-1 loop
        quad := To_X01Z(ivalue(4*i to 4*i+3));
        case quad is
          when x"0"   => result(i+1) := '0';
          when x"1"   => result(i+1) := '1';
          when x"2"   => result(i+1) := '2';
          when x"3"   => result(i+1) := '3';
          when x"4"   => result(i+1) := '4';
          when x"5"   => result(i+1) := '5';
          when x"6"   => result(i+1) := '6';
          when x"7"   => result(i+1) := '7';
          when x"8"   => result(i+1) := '8';
          when x"9"   => result(i+1) := '9';
          when x"A"   => result(i+1) := 'A';
          when x"B"   => result(i+1) := 'B';
          when x"C"   => result(i+1) := 'C';
          when x"D"   => result(i+1) := 'D';
          when x"E"   => result(i+1) := 'E';
          when x"F"   => result(i+1) := 'F';
          when "ZZZZ" => result(i+1) := 'Z';
          when others => result(i+1) := 'X';
        end case;
      end loop;
      return result;
    end if;
  end function to_hstring;

  function to_ostring (value     : SIGNED) return STRING is
    constant ne     : INTEGER := (value'length+2)/3;
    variable pad    : STD_LOGIC_VECTOR(0 to (ne*3 - value'length) - 1);
    variable ivalue : STD_LOGIC_VECTOR(0 to ne*3 - 1);
    variable result : STRING(1 to ne);
    variable tri    : STD_LOGIC_VECTOR(0 to 2);
  begin
    if value'length < 1 then
      return NUS;
    else
      if value (value'left) = 'Z' then
        pad := (others => 'Z');
      else
        pad := (others => value (value'high));  -- Extend sign bit
      end if;
      ivalue := pad & STD_LOGIC_VECTOR (value);
      for i in 0 to ne-1 loop
        tri := To_X01Z(ivalue(3*i to 3*i+2));
        case tri is
          when o"0"   => result(i+1) := '0';
          when o"1"   => result(i+1) := '1';
          when o"2"   => result(i+1) := '2';
          when o"3"   => result(i+1) := '3';
          when o"4"   => result(i+1) := '4';
          when o"5"   => result(i+1) := '5';
          when o"6"   => result(i+1) := '6';
          when o"7"   => result(i+1) := '7';
          when "ZZZ"  => result(i+1) := 'Z';
          when others => result(i+1) := 'X';
        end case;
      end loop;
      return result;
    end if;
  end function to_ostring;
  
  function to_hstring (value     : UNSIGNED) return STRING is
    constant ne     : INTEGER  := (value'length+3)/4;
    variable pad    : STD_LOGIC_VECTOR(0 to (ne*4 - value'length) - 1);
    variable ivalue : STD_LOGIC_VECTOR(0 to ne*4 - 1);
    variable result : STRING(1 to ne);
    variable quad   : STD_LOGIC_VECTOR(0 to 3);
  begin
    if value'length < 1 then
      return NUS;
    else
      if value (value'left) = 'Z' then
        pad := (others => 'Z');
      else
        pad := (others => '0');
      end if;
      ivalue := pad & STD_LOGIC_VECTOR (value);
      for i in 0 to ne-1 loop
        quad := To_X01Z(ivalue(4*i to 4*i+3));
        case quad is
          when x"0"   => result(i+1) := '0';
          when x"1"   => result(i+1) := '1';
          when x"2"   => result(i+1) := '2';
          when x"3"   => result(i+1) := '3';
          when x"4"   => result(i+1) := '4';
          when x"5"   => result(i+1) := '5';
          when x"6"   => result(i+1) := '6';
          when x"7"   => result(i+1) := '7';
          when x"8"   => result(i+1) := '8';
          when x"9"   => result(i+1) := '9';
          when x"A"   => result(i+1) := 'A';
          when x"B"   => result(i+1) := 'B';
          when x"C"   => result(i+1) := 'C';
          when x"D"   => result(i+1) := 'D';
          when x"E"   => result(i+1) := 'E';
          when x"F"   => result(i+1) := 'F';
          when "ZZZZ" => result(i+1) := 'Z';
          when others => result(i+1) := 'X';
        end case;
      end loop;
      return result;
    end if;
  end function to_hstring;

  function to_ostring (value     : UNSIGNED) return STRING is
    constant ne     : INTEGER := (value'length+2)/3;
    variable pad    : STD_LOGIC_VECTOR(0 to (ne*3 - value'length) - 1);
    variable ivalue : STD_LOGIC_VECTOR(0 to ne*3 - 1);
    variable result : STRING(1 to ne);
    variable tri    : STD_LOGIC_VECTOR(0 to 2);
  begin
    if value'length < 1 then
      return NUS;
    else
      if value (value'left) = 'Z' then
        pad := (others => 'Z');
      else
        pad := (others => '0');
      end if;
      ivalue := pad & STD_LOGIC_VECTOR (value);
      for i in 0 to ne-1 loop
        tri := To_X01Z(ivalue(3*i to 3*i+2));
        case tri is
          when o"0"   => result(i+1) := '0';
          when o"1"   => result(i+1) := '1';
          when o"2"   => result(i+1) := '2';
          when o"3"   => result(i+1) := '3';
          when o"4"   => result(i+1) := '4';
          when o"5"   => result(i+1) := '5';
          when o"6"   => result(i+1) := '6';
          when o"7"   => result(i+1) := '7';
          when "ZZZ"  => result(i+1) := 'Z';
          when others => result(i+1) := 'X';
        end case;
      end loop;
      return result;
    end if;
  end function to_ostring;

  -----------------------------------------------------------------------------
  -- Read and Write routines
  -----------------------------------------------------------------------------

  -- Routines copied from the "std_logic_1164_additions" package
  -- purpose: Skips white space
  procedure skip_whitespace (
    L : inout LINE) is
    variable readOk : BOOLEAN;
    variable c : CHARACTER;
  begin
    while L /= null and L.all'length /= 0 loop
      if (L.all(1) = ' ' or L.all(1) = NBSP or L.all(1) = HT) then
        read (l, c, readOk);
      else
        exit;
      end if;
    end loop;
  end procedure skip_whitespace;
  procedure READ (L    : inout LINE; VALUE : out STD_ULOGIC_VECTOR;
                  GOOD : out   BOOLEAN) is
    variable m      : STD_ULOGIC;
    variable c      : CHARACTER;
    variable mv     : STD_ULOGIC_VECTOR(0 to VALUE'length-1);
    variable readOk : BOOLEAN;
    variable i      : INTEGER;
    variable lastu  : BOOLEAN := false;       -- last character was an "_"
  begin
    VALUE := (VALUE'range => 'U'); -- initialize to a "U"
    Skip_whitespace (L);
    if VALUE'length > 0 then
      read (l, c, readOk);
      i := 0;
      good := true;
      while i < VALUE'length loop
        if not readOk then     -- Bail out if there was a bad read
          good := false;
          return;
        elsif c = '_' then
          if i = 0 then
            good := false;                -- Begins with an "_"
            return;
          elsif lastu then
            good := false;                -- "__" detected
            return;
          else
            lastu := true;
          end if;
        elsif (char_to_MVL9plus(c) = error) then
          good := false;                  -- Illegal character
          return;
        else
          mv(i) := char_to_MVL9(c);
          i := i + 1;
          if i > mv'high then             -- reading done
            VALUE := mv;
            return;
          end if;
          lastu := false;
        end if;
        read(L, c, readOk);
      end loop;
    else
      good := true;                   -- read into a null array
    end if;
  end procedure READ;

  procedure READ (L : inout LINE; VALUE : out STD_ULOGIC_VECTOR) is
    variable m      : STD_ULOGIC;
    variable c      : CHARACTER;
    variable readOk : BOOLEAN;
    variable mv     : STD_ULOGIC_VECTOR(0 to VALUE'length-1);
    variable i      : INTEGER;
    variable lastu  : BOOLEAN := false;       -- last character was an "_"
  begin
    VALUE := (VALUE'range => 'U'); -- initialize to a "U"
    Skip_whitespace (L);
    if VALUE'length > 0 then            -- non Null input string
      read (l, c, readOk);
      i := 0;
      while i < VALUE'length loop
        if readOk = false then              -- Bail out if there was a bad read
          report "STD_LOGIC_1164.READ(STD_ULOGIC_VECTOR) "
            & "End of string encountered"
            severity error;
          return;
        elsif c = '_' then
          if i = 0 then
            report "STD_LOGIC_1164.READ(STD_ULOGIC_VECTOR) "
              & "String begins with an ""_""" severity error;
            return;
          elsif lastu then
            report "STD_LOGIC_1164.READ(STD_ULOGIC_VECTOR) "
              & "Two underscores detected in input string ""__"""
              severity error;
            return;
          else
            lastu := true;
          end if;
        elsif char_to_MVL9plus(c) = error then
          report
            "STD_LOGIC_1164.READ(STD_ULOGIC_VECTOR) Error: Character '" &
            c & "' read, expected STD_ULOGIC literal."
            severity error;
          return;
        else
          mv(i) := char_to_MVL9(c);
          i := i + 1;
          if i > mv'high then
            VALUE := mv;
            return;
          end if;
          lastu := false;
        end if;
        read(L, c, readOk);
      end loop;
    end if;
  end procedure READ;

  -- purpose: or reduction
  function or_reduce (
    arg : STD_ULOGIC_VECTOR)
    return STD_ULOGIC is
    variable uarg : UNSIGNED (arg'range);
  begin
    uarg := unsigned(arg);
    return or_reduce (uarg);
  end function or_reduce;

  procedure Char2QuadBits (C           :     CHARACTER;
                           RESULT      : out STD_ULOGIC_VECTOR(3 downto 0);
                           GOOD        : out BOOLEAN;
                           ISSUE_ERROR : in  BOOLEAN) is
  begin
    case c is
      when '0'       => result := x"0"; good := true;
      when '1'       => result := x"1"; good := true;
      when '2'       => result := x"2"; good := true;
      when '3'       => result := x"3"; good := true;
      when '4'       => result := x"4"; good := true;
      when '5'       => result := x"5"; good := true;
      when '6'       => result := x"6"; good := true;
      when '7'       => result := x"7"; good := true;
      when '8'       => result := x"8"; good := true;
      when '9'       => result := x"9"; good := true;
      when 'A' | 'a' => result := x"A"; good := true;
      when 'B' | 'b' => result := x"B"; good := true;
      when 'C' | 'c' => result := x"C"; good := true;
      when 'D' | 'd' => result := x"D"; good := true;
      when 'E' | 'e' => result := x"E"; good := true;
      when 'F' | 'f' => result := x"F"; good := true;
      when 'Z'       => result := "ZZZZ"; good := true;
      when 'X'       => result := "XXXX"; good := true;
      when others =>
        assert not ISSUE_ERROR
          report
          "STD_LOGIC_1164.HREAD Read a '" & c &
          "', expected a Hex character (0-F)."
          severity error;
        good := false;
    end case;
  end procedure Char2QuadBits;

  procedure HREAD (L    : inout LINE; VALUE : out STD_ULOGIC_VECTOR;
                   GOOD : out   BOOLEAN) is
    variable ok  : BOOLEAN;
    variable c   : CHARACTER;
    constant ne  : INTEGER := (VALUE'length+3)/4;
    constant pad : INTEGER := ne*4 - VALUE'length;
    variable sv  : STD_ULOGIC_VECTOR(0 to ne*4 - 1);
    variable i   : INTEGER;
    variable lastu  : BOOLEAN := false;       -- last character was an "_"
  begin
    VALUE := (VALUE'range => 'U'); -- initialize to a "U"
    Skip_whitespace (L);
    if VALUE'length > 0 then
      read (l, c, ok);
      i := 0;
      while i < ne loop
        -- Bail out if there was a bad read
        if not ok then
          good := false;
          return;
        elsif c = '_' then
          if i = 0 then
            good := false;                -- Begins with an "_"
            return;
          elsif lastu then
            good := false;                -- "__" detected
            return;
          else
            lastu := true;
          end if;
        else
          Char2QuadBits(c, sv(4*i to 4*i+3), ok, false);
          if not ok then
            good := false;
            return;
          end if;
          i := i + 1;
          lastu := false;
        end if;
        if i < ne then
          read(L, c, ok);
        end if;
      end loop;
      if or_reduce (sv (0 to pad-1)) = '1' then  -- %%% replace with "or"
        good := false;                           -- vector was truncated.
      else
        good  := true;
        VALUE := sv (pad to sv'high);
      end if;
    else
      good := true;                     -- Null input string, skips whitespace
    end if;
  end procedure HREAD;

  procedure HREAD (L : inout LINE; VALUE : out STD_ULOGIC_VECTOR) is
    variable ok  : BOOLEAN;
    variable c   : CHARACTER;
    constant ne  : INTEGER := (VALUE'length+3)/4;
    constant pad : INTEGER := ne*4 - VALUE'length;
    variable sv  : STD_ULOGIC_VECTOR(0 to ne*4 - 1);
    variable i   : INTEGER;
    variable lastu  : BOOLEAN := false;       -- last character was an "_"
  begin
    VALUE := (VALUE'range => 'U'); -- initialize to a "U"
    Skip_whitespace (L);
    if VALUE'length > 0 then           -- non Null input string
      read (l, c, ok);
      i := 0;
      while i < ne loop
        -- Bail out if there was a bad read
        if not ok then
          report "STD_LOGIC_1164.HREAD "
            & "End of string encountered"
            severity error;
          return;
        end if;
        if c = '_' then
          if i = 0 then
            report "STD_LOGIC_1164.HREAD "
              & "String begins with an ""_""" severity error;
            return;
          elsif lastu then
            report "STD_LOGIC_1164.HREAD "
              & "Two underscores detected in input string ""__"""
              severity error;
            return;
          else
            lastu := true;
          end if;
        else
          Char2QuadBits(c, sv(4*i to 4*i+3), ok, true);
          if not ok then
            return;
          end if;
          i := i + 1;
          lastu := false;
        end if;
        if i < ne then
          read(L, c, ok);
        end if;
      end loop;
      if or_reduce (sv (0 to pad-1)) = '1' then  -- %%% replace with "or"
        report "STD_LOGIC_1164.HREAD Vector truncated"
          severity error;
      else
        VALUE := sv (pad to sv'high);
      end if;
    end if;
  end procedure HREAD;

  -- Octal Read and Write procedures for STD_ULOGIC_VECTOR.
  -- Modified from the original to be more forgiving.

  procedure Char2TriBits (C           :     CHARACTER;
                          RESULT      : out STD_ULOGIC_VECTOR(2 downto 0);
                          GOOD        : out BOOLEAN;
                          ISSUE_ERROR : in  BOOLEAN) is
  begin
    case c is
      when '0' => result := o"0"; good := true;
      when '1' => result := o"1"; good := true;
      when '2' => result := o"2"; good := true;
      when '3' => result := o"3"; good := true;
      when '4' => result := o"4"; good := true;
      when '5' => result := o"5"; good := true;
      when '6' => result := o"6"; good := true;
      when '7' => result := o"7"; good := true;
      when 'Z' => result := "ZZZ"; good := true;
      when 'X' => result := "XXX"; good := true;
      when others =>
        assert not ISSUE_ERROR
          report
          "STD_LOGIC_1164.OREAD Error: Read a '" & c &
          "', expected an Octal character (0-7)."
          severity error;
        good := false;
    end case;
  end procedure Char2TriBits;

  procedure OREAD (L    : inout LINE; VALUE : out STD_ULOGIC_VECTOR;
                   GOOD : out   BOOLEAN) is
    variable ok  : BOOLEAN;
    variable c   : CHARACTER;
    constant ne  : INTEGER := (VALUE'length+2)/3;
    constant pad : INTEGER := ne*3 - VALUE'length;
    variable sv  : STD_ULOGIC_VECTOR(0 to ne*3 - 1);
    variable i   : INTEGER;
    variable lastu  : BOOLEAN := false;       -- last character was an "_"
  begin
    VALUE := (VALUE'range => 'U'); -- initialize to a "U"
    Skip_whitespace (L);
    if VALUE'length > 0 then
      read (l, c, ok);
      i := 0;
      while i < ne loop
        -- Bail out if there was a bad read
        if not ok then
          good := false;
          return;
        elsif c = '_' then
          if i = 0 then
            good := false;                -- Begins with an "_"
            return;
          elsif lastu then
            good := false;                -- "__" detected
            return;
          else
            lastu := true;
          end if;
        else
          Char2TriBits(c, sv(3*i to 3*i+2), ok, false);
          if not ok then
            good := false;
            return;
          end if;
          i := i + 1;
          lastu := false;
        end if;
        if i < ne then
          read(L, c, ok);
        end if;
      end loop;
      if or_reduce (sv (0 to pad-1)) = '1' then  -- %%% replace with "or"
        good := false;                           -- vector was truncated.
      else
        good  := true;
        VALUE := sv (pad to sv'high);
      end if;
    else
      good := true;                  -- read into a null array
    end if;
  end procedure OREAD;

  procedure OREAD (L : inout LINE; VALUE : out STD_ULOGIC_VECTOR) is
    variable c   : CHARACTER;
    variable ok  : BOOLEAN;
    constant ne  : INTEGER := (VALUE'length+2)/3;
    constant pad : INTEGER := ne*3 - VALUE'length;
    variable sv  : STD_ULOGIC_VECTOR(0 to ne*3 - 1);
    variable i   : INTEGER;
    variable lastu  : BOOLEAN := false;       -- last character was an "_"
  begin
    VALUE := (VALUE'range => 'U'); -- initialize to a "U"
    Skip_whitespace (L);
    if VALUE'length > 0 then
      read (l, c, ok);
      i := 0;
      while i < ne loop
        -- Bail out if there was a bad read
        if not ok then
          report "STD_LOGIC_1164.OREAD "
            & "End of string encountered"
            severity error;
          return;
        elsif c = '_' then
          if i = 0 then
            report "STD_LOGIC_1164.OREAD "
              & "String begins with an ""_""" severity error;
            return;
          elsif lastu then
            report "STD_LOGIC_1164.OREAD "
              & "Two underscores detected in input string ""__"""
              severity error;
            return;
          else
            lastu := true;
          end if;
        else
          Char2TriBits(c, sv(3*i to 3*i+2), ok, true);
          if not ok then
            return;
          end if;
          i := i + 1;
          lastu := false;
        end if;
        if i < ne then
          read(L, c, ok);
        end if;
      end loop;
      if or_reduce (sv (0 to pad-1)) = '1' then  -- %%% replace with "or"
        report "STD_LOGIC_1164.OREAD Vector truncated"
          severity error;
      else
        VALUE := sv (pad to sv'high);
      end if;
    end if;
  end procedure OREAD;
  -- End copied code.

  procedure READ (L    : inout LINE; VALUE : out UNSIGNED;
                  GOOD : out BOOLEAN) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    READ (L     => L,
          VALUE => ivalue,
          GOOD  => GOOD);
    VALUE := UNSIGNED(ivalue);
  end procedure READ;

  procedure READ (L : inout LINE; VALUE : out UNSIGNED) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    READ (L      => L,
           VALUE => ivalue);
    VALUE := UNSIGNED (ivalue);
  end procedure READ;

  procedure READ (L    : inout LINE; VALUE : out SIGNED;
                  GOOD : out BOOLEAN) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    READ (L     => L,
          VALUE => ivalue,
          GOOD  => GOOD);
    VALUE := SIGNED(ivalue);
  end procedure READ;

  procedure READ (L : inout LINE; VALUE : out SIGNED) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    READ (L      => L,
           VALUE => ivalue);
    VALUE := SIGNED (ivalue);
  end procedure READ;

  procedure WRITE (L         : inout LINE; VALUE : in UNSIGNED;
                   JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
  begin
    write (L, to_string(VALUE), JUSTIFIED, FIELD);
  end procedure WRITE;

  procedure WRITE (L         : inout LINE; VALUE : in SIGNED;
                   JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
  begin
    write (L, to_string(VALUE), JUSTIFIED, FIELD);
  end procedure WRITE;

  procedure OREAD (L    : inout LINE; VALUE : out UNSIGNED;
                   GOOD : out BOOLEAN) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    OREAD (L     => L,
           VALUE => ivalue,
           GOOD  => GOOD);
    VALUE := UNSIGNED(ivalue);
  end procedure OREAD;

  procedure OREAD (L    : inout LINE; VALUE : out SIGNED;
                   GOOD : out BOOLEAN) is
    constant ne               : INTEGER := (value'length+2)/3;
    constant pad              : INTEGER := ne*3 - value'length;
    variable ivalue           : STD_ULOGIC_VECTOR(0 to ne*3-1);
    variable ok               : BOOLEAN;
    variable expected_padding : STD_ULOGIC_VECTOR(0 to pad-1);
  begin
    OREAD (L      => L,
            VALUE => ivalue,            -- Read padded STRING
            GOOD  => ok);
    -- Bail out if there was a bad read
    if not ok then
      GOOD := false;
      return;
    end if;
    expected_padding := (others => ivalue(pad));
    if ivalue(0 to pad-1) /= expected_padding then
      GOOD := false;
    else
      GOOD  := true;
      VALUE := UNRESOLVED_SIGNED (ivalue (pad to ivalue'high));
    end if;
  end procedure OREAD;

  procedure OREAD (L : inout LINE; VALUE : out UNSIGNED) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    OREAD (L     => L,
           VALUE => ivalue);
    VALUE := UNSIGNED (ivalue);
  end procedure OREAD;

  procedure OREAD (L : inout LINE; VALUE : out SIGNED) is
    constant ne               : INTEGER := (value'length+2)/3;
    constant pad              : INTEGER := ne*3 - value'length;
    variable ivalue           : STD_ULOGIC_VECTOR(0 to ne*3-1);
    variable expected_padding : STD_ULOGIC_VECTOR(0 to pad-1);
  begin
    OREAD (L      => L,
            VALUE => ivalue);           -- Read padded string
    expected_padding := (others => ivalue(pad));
    if ivalue(0 to pad-1) /= expected_padding then
      assert false
        report "NUMERIC_STD.OREAD Error: Signed vector truncated"
        severity error;
    else
      VALUE := UNRESOLVED_SIGNED (ivalue (pad to ivalue'high));
    end if;
  end procedure OREAD;

  procedure HREAD (L    : inout LINE; VALUE : out UNSIGNED;
                   GOOD : out BOOLEAN) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    HREAD (L     => L,
           VALUE => ivalue,
           GOOD  => GOOD);
    VALUE := UNSIGNED(ivalue);
  end procedure HREAD;

  procedure HREAD (L    : inout LINE; VALUE : out SIGNED;
                   GOOD : out BOOLEAN) is
    constant ne               : INTEGER := (value'length+3)/4;
    constant pad              : INTEGER := ne*4 - value'length;
    variable ivalue           : STD_ULOGIC_VECTOR(0 to ne*4-1);
    variable ok               : BOOLEAN;
    variable expected_padding : STD_ULOGIC_VECTOR(0 to pad-1);
  begin
    HREAD (L      => L,
            VALUE => ivalue,            -- Read padded STRING
            GOOD  => ok);
    if not ok then
      GOOD := false;
      return;
    end if;
    expected_padding := (others => ivalue(pad));
    if ivalue(0 to pad-1) /= expected_padding then
      GOOD := false;
    else
      GOOD  := true;
      VALUE := UNRESOLVED_SIGNED (ivalue (pad to ivalue'high));
    end if;
  end procedure HREAD;

  procedure HREAD (L : inout LINE; VALUE : out UNSIGNED) is
    variable ivalue : STD_ULOGIC_VECTOR(value'range);
  begin
    HREAD (L     => L,
           VALUE => ivalue);
    VALUE := UNSIGNED (ivalue);
  end procedure HREAD;

  procedure HREAD (L : inout LINE; VALUE : out SIGNED) is
    constant ne               : INTEGER := (value'length+3)/4;
    constant pad              : INTEGER := ne*4 - value'length;
    variable ivalue           : STD_ULOGIC_VECTOR(0 to ne*4-1);
    variable expected_padding : STD_ULOGIC_VECTOR(0 to pad-1);
  begin
    HREAD (L      => L,
            VALUE => ivalue);           -- Read padded string
    expected_padding := (others => ivalue(pad));
    if ivalue(0 to pad-1) /= expected_padding then
      assert false
        report "NUMERIC_STD.HREAD Error: Signed vector truncated"
        severity error;
    else
      VALUE := UNRESOLVED_SIGNED (ivalue (pad to ivalue'high));
    end if;
  end procedure HREAD;

  procedure OWRITE (L         : inout LINE; VALUE : in UNSIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
  begin
    write (L, to_ostring(VALUE), JUSTIFIED, FIELD);
  end procedure OWRITE;

  procedure OWRITE (L         : inout LINE; VALUE : in SIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
  begin
    write (L, to_ostring(VALUE), JUSTIFIED, FIELD);
  end procedure OWRITE;

  procedure HWRITE (L         : inout LINE; VALUE : in UNSIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
  begin
    write (L, to_hstring (VALUE), JUSTIFIED, FIELD);
  end procedure HWRITE;

  procedure HWRITE (L         : inout LINE; VALUE : in SIGNED;
                    JUSTIFIED : in    SIDE := right; FIELD : in WIDTH := 0) is
  begin
    write (L, to_hstring (VALUE), JUSTIFIED, FIELD);
  end procedure HWRITE;

  -- rtl_synthesis on
-- pragma synthesis_on
end package body numeric_std_additions;
