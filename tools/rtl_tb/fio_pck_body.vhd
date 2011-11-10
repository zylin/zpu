----  $Id: PCK_FIO_1993_BODY.vhd,v 1.9 2001/10/04 16:48:12 jand Exp $
----
----  PCK_FIO: a VHDL package for C-style formatted file output
----  Copyright (C) 1995, 2001 Easics NV 
----
----  This library is free software; you can redistribute it and/or
----  modify it under the terms of the GNU Lesser General Public
----  License as published by the Free Software Foundation; either
----  version 2.1 of the License, or (at your option) any later version.
----
----  This library is distributed in the hope that it will be useful,
----  but WITHOUT ANY WARRANTY; without even the implied warranty of
----  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
----  Lesser General Public License for more details.
----
----  You should have received a copy of the GNU Lesser General Public
----  License along with this library; if not, write to the Free Software
----  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
---- 
----  For suggestions, bug reports, enhancement requests, and info about  
----  our design services, you can contact us at the following address: 
----     http://www.easics.com
----     Easics NV, Interleuvenlaan 86, B-3001 Leuven, Belgium
----     tel.: +32 16 395 600   fax : +32 16 395 619 
----     e-mail: jand@easics.be (Jan Decaluwe)
----


 package body fio_pkg is
              
  --------------------------
  -- FIO Warnings support --
  --------------------------

  procedure FIO_Warning_Fsbla (file F:  text;
		               L:       inout line; 
                               Format:  in    string;  
			       Pointer: in    positive) is
  begin
    fprint (F, L, "\n** Warning: FIO_PrintLastValue: " &
        	  "Format specifier beyond last argument\n"); 
    fprint (F, L, "**  in format string: ""%s""\n", Format); 
    fprint (F, L, "**                     ");                     
    for i in 1 to Pointer-1 loop
      fprint (F, L, "-"); 
    end loop;
    fprint (F, L, "^\n"); 
  end FIO_Warning_Fsbla;

  procedure FIO_Warning_Ufs   (file F:  text;
		               L:       inout line; 
                               Format:  in    string;  
			       Pointer: in    positive;
			       Char:    in    character) is
  begin
    fprint (F, L, "\n** Warning: FIO_PrintArg: " &
		  "Unexpected format specifier '%r'\n",
		  fo(Char));
    fprint (F, L, "**   in format string: ""%s""\n", Format) ; 
    fprint (F, L, "**                      ");                     
    for i in 1 to Pointer-1 loop
      fprint (F, L, "-"); 
    end loop;
    fprint (F, L, "^\n**   Assuming 'q' to proceed: "); 
  end FIO_Warning_Ufs;


  ----------------------------------
  -- bit conversion support --
  ----------------------------------

  type T_bit_map is array(bit) of character;  
  
  constant C_BIT_MAP: T_bit_map 
             := ('0', '1');

  ----------------------------------
  -- std_logic conversion support --
  ----------------------------------

  type T_std_logic_map is array(std_ulogic) of character;  
  
  constant C_STD_LOGIC_MAP: T_std_logic_map 
             := ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');

  ------------------------------
  -- Digit conversion support --  
  ------------------------------

  -- types & constants

  subtype S_digit_chars is character range '0' to '9';
  subtype S_digits      is integer   range  0  to  9 ; 

  type T_digit_chars_map is array(S_digit_chars) of S_digits; 

  constant C_DIGIT_CHARS_MAP: T_digit_chars_map 
    := (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

  type T_digits_map is array(S_digits) of S_digit_chars; 

  constant C_DIGITS_MAP: T_digits_map  
    := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');


  --------------------------------
  -- Decimal conversion support --
  --------------------------------

  -- unsigned to decimal
  
  function U_To_d (Arg: string) return integer is
    constant Argument: string(Arg'length downto 1) := Arg;
    variable Result: integer := 0;
  begin
    for i in Argument'range loop
      case Argument(i) is when '1'    => Result := 2**(i-1) + Result;   
	                  when '0'    => null;
                          when others => return(-1); 
      end case;
    end loop;
    return (Result);
  end U_To_d;

  -- signed to decimal
  
  function S_To_d (Arg: string) return integer is
    constant Argument: string(Arg'length downto 1) := Arg;
    variable Result: integer := 0; 
  begin
    case Argument(Argument'left) is 
      when '1' =>    Result := - 2**(Argument'left-1);   
      when '0' =>    Result := 0;
      when others => return (integer'low); 
    end case;
    for i in Argument'left-1 downto 1 loop
      case Argument(i) is when '1'    => Result := 2**(i-1) + Result;   
	                  when '0'    => null;
                          when others => return(integer'low); 
      end case;
    end loop; 
    return (Result);
  end S_To_d;

  -- string  to decimal

  function I_To_d (Arg: string(1 to FIO_d_WIDTH+1)) return integer is
    constant Sign: character := Arg(1);
    constant Value: string(Arg'length-1 downto 1) := Arg(2 to Arg'length);
    variable Char: character;
    variable Result: integer := 0;
  begin
    Result := 0;
    for i in Value'range loop
      Result := Result * 10;
      Char := Value(i);
      if (Char /= ' ') then
        Result := Result + C_DIGIT_CHARS_MAP(Char);
      end if;
    end loop;
    case Sign is when '-'    => return(-Result);
		 when others => return(Result);
    end case;
  end I_To_d;

  -- boolean (0,1) to decimal

  function B_To_d (Arg: string(1 to 1)) return integer is
  begin
    case Arg is when "1"    => return(1);
                when "0"    => return(0);
                when others => return(-1);
    end case;
  end B_To_d;

  -- boolean (T,F) to decimal
  
  function L_To_d (Arg: string(1 to 1)) return integer is
  begin
    case Arg is when "T"    => return(1);
                when others => return(0);
    end case;
  end L_To_d;



  ----------------------------
  -- Hex conversion support --
  ----------------------------

  -- Constants & types

  constant C_HEX_CHARS: string(1 to 17) := "0123456789ABCDEF?";

  -- Function to return Hex index of a nibble  

  function U_To_h_Index(Arg: string(4 downto 1)) return integer is
    variable Index: integer := 0;
  begin
    for i in Arg'range loop
      case Arg(i) is when '1'    => Index := 2**(i-1) + Index;   
	             when '0'    => null;
                     when others => return (17); 
      end case;
    end loop;
    return (Index+1);
  end U_To_h_Index;

  -- Hex conversion  

  function U_To_h (Arg: string) return string is
    variable Result: string((Arg'length-1)/4 +1 downto 1);
    variable ExtArg: string(Result'length*4 downto 1) := (others => '0'); 
  begin
    ExtArg(Arg'length downto 1) := Arg;
    for i in Result'range loop
      Result(i) := C_HEX_CHARS(U_To_h_Index( ExtArg(i*4 downto i*4 -3) ));     
    end loop;
    return (FIO_h_PRE & Result & FIO_h_POST);
  end U_To_h;



  ----------------------------
  -- Bit conversion support --
  ----------------------------

  function L_To_b (Arg: string(1 to 1)) return string is
    variable Result: string(1 to 1); 
  begin
    case Arg is when "T"    => Result := "1";
                when others => Result := "0";
    end case;
    return(FIO_b_PRE & Result & FIO_b_POST);
  end L_To_b;


  function I_To_b (Arg: string(1 to FIO_d_WIDTH+1);
	           Justified: side;
		   Width: integer) return string is

    variable IntValue: integer := I_To_d(Arg);
    variable BitValue: string(1 to FIO_b_WIDTH) := (others => ' '); 
    variable Sign: character := ' ';
    constant Blanks: string(1 to FIO_b_WIDTH) := (others => ' ');
    variable BitWidth: integer range 0 to FIO_b_WIDTH;
    variable MsPos: integer range 1 to BitValue'length; 
    variable BitValueExtended: string(1 to 2*FIO_b_WIDTH); 

  begin

    if (IntValue < 0) then
      Sign := '-';
      IntValue := -IntValue;
    end if;

    for i in BitValue'reverse_range loop 
      BitValue(i) := C_DIGITS_MAP(IntValue mod 2); 
      IntValue := IntValue / 2;
      exit when (IntValue = 0);
    end loop;

    BitValueExtended := BitValue & Blanks; 

    if (Width = 0) or (Width > FIO_b_WIDTH+1) then
       BitWidth := FIO_b_WIDTH;   
    else
       BitWidth := Width-1;   
    end if;

    if (Justified = RIGHT) then
      return (FIO_bv_PRE & 
	      Sign & BitValue(BitValue'length-BitWidth+1 to BitValue'length) & 
	      FIO_bv_POST);    
    else
      for i in BitValue'range loop 
        if BitValue(i) /= ' ' then
	  MSPos := i;
	  exit;
	end if;
      end loop;
      return (FIO_bv_PRE & 
 	      Sign & BitValueExtended(MSPos to MSPos+BitWidth-1) & 
	      FIO_bv_POST);
    end if;

  end I_To_b;


  -----------------------------------
  -- Reasonable conversion support --
  -----------------------------------

  function I_To_r (Arg: string(1 to FIO_d_WIDTH+1); 
	           Justified: side;
		   Width: integer) return string is
    constant Value: string(1 to FIO_d_WIDTH) := Arg(2 to FIO_d_WIDTH+1);
    constant Sign: character := Arg(1);
    constant Blanks: string(1 to FIO_d_WIDTH) := (others => ' ');
    variable IntWidth: integer range 0 to FIO_d_WIDTH;
    variable MsPos: integer range 1 to Value'length; 
    variable ValueExtended: string(1 to 2*FIO_d_WIDTH) := Value & Blanks; 
  begin
    if (Width = 0) or (Width > FIO_d_WIDTH+1) then
       IntWidth := FIO_d_WIDTH;   
    else
       IntWidth := Width-1;   
    end if;
    if (Justified = RIGHT) then
      return (Sign & Value(Value'length-IntWidth+1 to Value'length));    
    else
      for i in Value'range loop 
        if Value(i) /= ' ' then
	  MSPos := i;
	  exit;
	end if;
      end loop;
      return (Sign & ValueExtended(MSPos to MSPos+IntWidth-1));
    end if;
  end I_To_r;


  -------------------------------------------
  -- Reasonable output conversion function --
  -------------------------------------------

  function ReasonableOutput (Arg: string;
			     Justified: side;
		             Width: integer) return string is
    constant Argument: string(1 to Arg'length) := Arg;
    constant TypeSpec: string (1 to 2) := Argument(1 to 2);
    constant Value: string(1 to Arg'length-2) := Argument(3 to Arg'length);
  begin
    case TypeSpec is
      when "U:" | "S:" | "V:" => 
        return U_To_h(Value);  
      when "I:" =>
	return I_To_r(Value, Justified, Width);
      when "B:" | "L:" | "C:" =>
        return Value;     
      when others => 
	return Argument;  
    end case;

  end ReasonableOutput;


  ------------------------------------
  -- Bit output conversion function --
  ------------------------------------

  function BitOutput (Arg: string;
		      Justified: side;
		      Width: integer) return string is
    constant Argument: string(1 to Arg'length) := Arg;
    constant TypeSpec: string (1 to 2) := Argument(1 to 2);
    constant Value: string(1 to Arg'length-2) := Argument(3 to Arg'length);
  begin
    case TypeSpec is
      when "U:" | "S:" | "V:" => 
        return (FIO_bv_PRE & Value & FIO_bv_POST);  
      when "B:" =>
        -- Value(1 to 1) instead of Value for LeapFrog
        return (FIO_b_PRE & Value(1 to 1) & FIO_b_POST);  
      when "I:" =>
	return I_To_b(Value, Justified, Width);
      when "L:"  =>
        -- Value(1 to 1) instead of Value for LeapFrog
	return L_To_b(Value(1 to 1));
      when others => 
	return Argument;  
    end case;

  end BitOutput;


  -------------------------------------------
  -- Decimal output conversion function --
  -------------------------------------------

  function DecimalOutput (Arg: string) return integer is
    constant Argument: string(1 to Arg'length) := Arg;
    constant TypeSpec: string (1 to 2) := Argument(1 to 2);
    constant Value: string(1 to Arg'length-2) := Argument(3 to Arg'length);
  begin
    case TypeSpec is
      when "U:"| "V:" =>
	return U_To_d(Value);
      when "S:" =>
	return S_To_d(Value);
      when "I:" =>
	return I_To_d(Value);
      when "B:" =>
	return B_To_d(Value);
      when "L:" =>
	return L_To_d(Value);
      when others => 
	return integer'low;  
    end case;

  end DecimalOutput;


  ----------------------------
  -- Atomic print functions --  
  ----------------------------

  -- test for end of format string
  
  function FIO_EOS (Format: in string;
		    Pointer: in integer) 
	   return boolean is 
  begin
    return (Pointer > Format'length);
  end FIO_EOS; 


  -- Atomic value print function

  procedure FIO_PrintValue (file F:  text;
			    L:       inout line; 
			    Format:  in    string; 
			    Pointer: inout integer;
			    Last:    in    boolean := FALSE) is
    variable Char: character;  
  begin
    while (not FIO_EOS(Format, Pointer)) loop 
      Char := Format(Pointer);
      case Char is
	when '\' =>
	  Pointer := Pointer + 1;
	  exit when (FIO_EOS(Format, Pointer));
          Char := Format(Pointer);
	  case Char is when 'n'    => writeline(F, L); 
	               when others => write(L, Char);
	  end case;
	when '%' => 
	  if Last then
	    FIO_Warning_Fsbla(F, L, Format, Pointer);
	  end if;
	  Pointer := Pointer + 1; 
	  exit;
	when others  => 
	  write(L, char); 
      end case;
      Pointer := Pointer + 1;
    end loop;
  end FIO_PrintValue; 


  ---- Atomic argument print function

  procedure FIO_PrintArg (file F:  text;
			  L:       inout line; 
			  Format:  in    string; 
			  Pointer: inout integer;
			  Arg:     in    string) is
    variable Char: character;  
    variable Justified: side;  
    variable Width: integer;

  begin

    FIO_PrintValue(F, L, Format, Pointer);

    Justified := RIGHT;  
    Width := 0; 
    while (not FIO_EOS(Format, Pointer)) loop 
      Char := Format(Pointer);
      case Char is
	when '-' =>
	  Justified := LEFT;  
          Pointer := Pointer + 1;
	when '0' to '9' =>
	  Width := Width*10 + C_DIGIT_CHARS_MAP(Char);
          Pointer := Pointer + 1;
	when 'r' => 
	  write(L, ReasonableOutput(Arg, Justified, Width), Justified, Width);  
          Pointer := Pointer + 1;
	  exit;
	when 'b' => 
	  write(L, BitOutput(Arg, Justified, Width), Justified, Width);  
          Pointer := Pointer + 1;
	  exit;
	when 'd' => 
	  write(L, DecimalOutput(Arg), Justified, Width);  
          Pointer := Pointer + 1;
	  exit;
	when 'q' | 's' => 
	  write(L, Arg, Justified, Width);  
          Pointer := Pointer + 1;
	  exit;
	when others  => 
          FIO_Warning_Ufs(F, L, Format, Pointer, Char);
	  write(L, Arg, Justified, Width);  
          Pointer := Pointer + 1;
	  exit;
      end case;
    end loop;  
  end FIO_PrintArg; 


  -----------------------------------------------------
  -- The format string iteration expansion procedure --
  -----------------------------------------------------

  procedure FIO_FormatExpand (FMT:          inout line; 
			      Format:       in    string; 
			      StartPointer: in    positive) is

    variable Pointer: positive := StartPointer;
    variable TokenStart: positive;
    variable IterStringStart: positive;
    variable IterStringEnd: positive;
    variable IterCount: natural;
    variable OpenBrackets: natural;
    variable L: line;

  begin

    FORMAT_SEARCH: while not FIO_EOS(Format, Pointer) loop 

      case Format(Pointer) is

        -- look for format specifier
	when '%' => 

          -- initialize iteration token search 
	  TokenStart := Pointer;
          IterCount := 0; 
	  Pointer := Pointer + 1;

          -- start iteration token search
	  TOKEN_READ: while not FIO_EOS(Format, Pointer) loop 
             
	    case Format(Pointer) is
                
              -- read iteration counter
	      when '0' to '9' =>
		IterCount := IterCount*10 + C_DIGIT_CHARS_MAP(Format(Pointer)); 
                Pointer := Pointer + 1;
               
              -- expect open bracket
	      when '{' => 

		-- initialize iteration string read
		OpenBrackets := 1;
		IterStringStart := Pointer + 1;
                Pointer := Pointer + 1;
		-- quit prematurely when iteration count is 0
		next FORMAT_SEARCH when (IterCount = 0);

                -- start iteration string read
	        ITER_STRING_READ: while not FIO_EOS(Format, Pointer) loop 

	          case Format(Pointer) is
                    -- keep track of open brackets
		    when '{' => 
		      OpenBrackets := OpenBrackets + 1;
	              Pointer := Pointer + 1;
                    -- when closing bracket is found, process iteration string      
		    when '}' => 
	 	      OpenBrackets := OpenBrackets - 1;
		      if (OpenBrackets = 0) then
			IterStringEnd := Pointer-1;
			if (TokenStart /= 1) then
			  write(L, Format(1 to TokenStart-1)); 
			end if;
			for i in 1 to IterCount loop
			  write(L,  Format(IterStringStart to IterStringEnd));
			end loop;
			if (IterStringEnd /= Format'length) then
			  write(L, Format(IterStringEnd+2 to Format'length)); 
			end if;
			-- call expansion procedure recursively on expanded format
			FIO_FormatExpand(FMT, L.all, TokenStart);
                        deallocate(L);
                        return; 
		      end if;
	              Pointer := Pointer + 1;
                    -- skip escaped characters
	            when '\' => 
	              Pointer := Pointer + 2;
                    -- read iteration string  
	            when others => 
	              Pointer := Pointer + 1;

		  end case; 

		end loop ITER_STRING_READ;

              -- stop iteration token search when no opening bracket found 
	      when others => 
                Pointer := Pointer + 1;
		next FORMAT_SEARCH;

	    end case;

	  end loop TOKEN_READ;

        -- skip escaped characters
	when '\' => 
	  Pointer := Pointer + 2;

        -- read other characters
	when others => 
          Pointer := Pointer + 1;

      end case;

    end loop FORMAT_SEARCH;

    write(FMT, Format);
    deallocate(L);

  end FIO_FormatExpand;



  --------------------------
  -- The fprint procedure --
  --------------------------

  procedure fprint 
	     (file F:  text;
	      L:       inout line; 
	      Format:  in    string;  
	      A1 , A2 , A3 , A4 , A5 , A6 , A7 , A8 : in string := FIO_NIL;
	      A9 , A10, A11, A12, A13, A14, A15, A16: in string := FIO_NIL;
	      A17, A18, A19, A20, A21, A22, A23, A24: in string := FIO_NIL;
	      A25, A26, A27, A28, A29, A30, A31, A32: in string := FIO_NIL
	     ) is

    variable Pointer: integer;
    variable FMT: line;
		    
  begin

    Pointer := 1;

    FIO_FormatExpand (FMT, Format, Format'low);

    if (A1  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A1 );
    if (A2  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A2 );
    if (A3  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A3 );
    if (A4  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A4 );
    if (A5  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A5 );
    if (A6  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A6 );
    if (A7  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A7 );
    if (A8  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A8 );
    if (A9  /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A9 );
    if (A10 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A10);
    if (A11 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A11);
    if (A12 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A12);
    if (A13 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A13);
    if (A14 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A14);
    if (A15 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A15);
    if (A16 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A16);
    if (A17 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A17);
    if (A18 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A18);
    if (A19 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A19);
    if (A20 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A20);
    if (A21 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A21);
    if (A22 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A22);
    if (A23 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A23);
    if (A24 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A24);
    if (A25 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A25);
    if (A26 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A26);
    if (A27 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A27);
    if (A28 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A28);
    if (A29 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A29);
    if (A30 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A30);
    if (A31 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A31);
    if (A32 /= FIO_NIL) then FIO_PrintArg(F, L, FMT.all, Pointer, A32);
    end if; end if; end if; end if; end if; end if; end if; end if; 
    end if; end if; end if; end if; end if; end if; end if; end if; 
    end if; end if; end if; end if; end if; end if; end if; end if; 
    end if; end if; end if; end if; end if; end if; end if; end if; 

    FIO_PrintValue(F, L, FMT.all, Pointer, Last => TRUE);

    deallocate(FMT);

  end fprint;
  

  -------------------------------------------
  -- Formatted output conversion functions --
  -------------------------------------------

  function fo (Arg: unsigned) return string is
    constant Argument: unsigned(1 to Arg'length) := Arg;
    variable Result: string(1 to Arg'length); 
  begin
    for i in Argument'range loop
      Result(i) := C_STD_LOGIC_MAP(Argument(i));
    end loop;
    return ("U:" & Result);
  end fo;

  function fo (Arg: signed) return string is
    constant Argument: signed(1 to Arg'length) := Arg;
    variable Result: string(1 to Arg'length); 
  begin
    for i in Argument'range loop
      Result(i) := C_STD_LOGIC_MAP(Argument(i));
    end loop;
    return ("S:" & Result);
  end fo;

--function fo (Arg: std_logic_vector) return string is
--  constant Argument: std_logic_vector(1 to Arg'length) := Arg;
--  variable Result: string(1 to Arg'length); 
--begin
--  for i in Argument'range loop
--    Result(i) := C_STD_LOGIC_MAP(Argument(i));
--  end loop;
--  return ("V:" & Result);
--end fo;

  function fo (Arg: std_ulogic_vector) return string is
    constant Argument: std_ulogic_vector(1 to Arg'length) := Arg;
    variable Result: string(1 to Arg'length); 
  begin
    for i in Argument'range loop
      Result(i) := C_STD_LOGIC_MAP(Argument(i));
    end loop;
    return ("V:" & Result);
  end fo;

  function fo (Arg: bit_vector) return string is
    constant Argument: bit_vector(1 to Arg'length) := Arg;
    variable Result: string(1 to Arg'length); 
  begin
    for i in Argument'range loop
      Result(i) := C_BIT_MAP(Argument(i));
    end loop;
    return ("V:" & Result);
  end fo;

  function fo (Arg: integer) return string is
    variable Argument: integer := Arg;
    variable Result: string(1 to FIO_d_WIDTH) := (others => ' '); 
    variable Sign: character := ' ';
  begin
    if (Argument < 0) and (Argument /= integer'low) then
      Sign := '-';
      Argument := -Argument;
    end if;
    for i in Result'reverse_range loop 
      Result(i) := C_DIGITS_MAP(Argument mod 10); 
      Argument := Argument / 10;
      exit when (Argument = 0);
    end loop;
    return ("I:" & Sign & Result);
  end fo;

  function fo (Arg: std_ulogic) return string is
  begin
    return ("B:" & C_STD_LOGIC_MAP(Arg));
  end fo;

  function fo (Arg: bit) return string is
  begin
    return ("B:" & C_BIT_MAP(Arg));
  end fo;

  function fo (Arg: boolean) return string is
  begin
    if (ARG = TRUE) then
      return ("L:T");
    else 
      return ("L:F");
    end if;
  end fo;

  function fo (Arg: character) return string is
  begin
    return ("C:" & Arg);   
  end fo;

  -- auxilary function fgets(Arg :string)
  -- returns index of first NUL in Arg or if no NUL is present just Arg'length
  -- goes through Arg from 1 to Arg'length
  function fgets (Arg: string) return integer is
    variable index: integer := Arg'length;
  begin
      for i in 1 to Arg'length loop
        if Arg(i) = NUL then
          index := i - 1;
          exit;
         else
           null;
        end if;  
      end loop;
        return index;
    end fgets;
      
   -- returns the Arg string until the first NUL was encountered
   -- if fo is used on a string with NUL in it it will stop reading the rest
   -- of the string, even if a larger field width has been supplied.  fo will
   -- then just pad the remaining characters with blanco's
   function fo (Arg: string) return string is   
   begin
     return Arg(1 to fgets(Arg));
   end fo;

  function fo (Arg: time) return string is
  begin
    return fo (integer (Arg / 1 ns));   
  end fo;

end fio_pkg;

