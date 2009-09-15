/*      MODULE: zpu_core_defines
        DESCRIPTION: Contains ZPU parameters and other cpu related definitions
		AUTHOR: Antonio J. Anton (aj <at> anro-ingenieros.com)

REVISION HISTORY:
Revision 1.0, 14/09/2009
Initial public release

COPYRIGHT:
Copyright (c) 2009 Antonio J. Anton

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

/* --------------- ISA DOCUMENTATION ------------------
   stack: 	top of stack = sp, mem[sp]=valid data
			push: sp=sp-1, then mem[sp]=data
			pop: data=mem[sp], then sp=sp+1
	
   immediates: any opcode instead of im sets idim=0

   MNEMONIC		OPCODE	   HEX	OPERATION
-  im x			1_xxxxxxx		if(~idim) { idim=1; sp=sp-1; mem[sp]={{25{b[6]}},b[6:0]} }
								else { idim=1; mem[sp]={mem[sp][24:0], b[6:0]} }
-  emulate x	001_xxxxx		sp=sp-1; mem[sp]=pc+1; pc=mem[@VECTOR_EMULATE + <b>]; fetch (used only by microcode)
-  storesp x	010_xxxxx		mem[sp+x<<2] = mem[sp]; sp=sp+1
-  loadsp x		011_xxxxx		mem[sp-1] = mem [sp+x<<2]; sp=sp-1
-  addsp x		0001_xxxx (1x)	mem[sp] = mem[sp]+mem[sp+x<<2]

-  breakpoint	0000_0000 (00)	call exception vector
   shiftleft	0000_0001 (01)
-  pushsp		0000_0010 (02) 	mem[sp-1] = sp; sp = sp - 1
-  popint		0000_0011 (03)  pc=mem[sp]; sp = sp + 1 ; fetch ; decode ; clear_interrupt_flag
-  poppc		0000_0100 (04)	pc=mem[sp]; sp = sp + 1
-  add			0000_0101 (05)	mem[sp+1] = mem[sp+1] + mem[sp]; sp = sp + 1
-  and			0000_0110 (06)	mem[sp+1] = mem[sp+1] & mem[sp]; sp = sp + 1
-  or			0000_0111 (07)	mem[sp+1] = mem[sp+1] | mem[sp]; sp = sp + 1
-  load			0000_1000 (08)	mem[sp] = mem[ mem[sp] ]
-  not			0000_1001 (09)	mem[sp] = ~mem[sp]
-  flip			0000_1010 (0a)	mem[sp] = flip(mem[sp])
-  nop			0000_1011 (0b)	-
-  store		0000_1100 (0c)	mem[mem[sp]] = mem[sp+1]; sp = sp + 2
-  popsp		0000_1101 (0d)	sp = mem[sp]
   compare		0000_1110 (0e)  ???? --> opcode recycled (see below)
   popint		0000_1111 (0f)  duplicated of 0x03 ????? --> opcode recycled (see below)

-  ipsum	    0000_1110 (0e)	c=mem[sp],s=mem[sp+1]; sum=0; while(c-->0) {sum+=halfword(mem[s],s);s+=2}; sp=sp+1; mem[sp]=sum (overwrites mem[0] & mem[4] words)
-  sncpy		0000_1111 (0f)  c=mem[sp],d=mem[sp+1],s=mem[sp+2]; while( *(char*)s != 0 && c>0 ) {*((char*)d++)=*((char*)s++));c--}; sp=sp+3 (overwrites mem[0] & mem[4] words)
-  wcpy		    001_00000 (20)  c=mem[sp],d=mem[sp+1],s=mem[sp+2]; while(c-->0) mem[d++]=mem[s++]; sp=sp+3 (overwrites mem[0] & mem[4] words)
-  wset 	    001_00001 (21)  v=mem[sp],c=mem[sp+1],d=mem[sp+2]; while(c-->0) mem[d++]=v; sp=sp+3 (overwrites mem[0] & mem[4] words)
			    
-  loadh		001_00010 (22)  mem[sp] = halfword[ mem[sp] ]
-  storeh		001_00011 (23)  halfword[mem[sp]] = (mem[sp+1] & 0xFFFF); sp = sp + 2
-  lessthan		001_00100 (24)	(mem[sp]-mem[sp+1]) < 0 ? mem[sp+1]=1 : mem[sp+1]=0; sp = sp + 1
-  lessthanorequal 001_00101 (25) (mem[sp]-mem[sp+1]) <= 0 ? mem[sp+1]=1 : mem[sp+1]=0; sp = sp + 1
-  ulessthan	001_00110 (26)	(unsigned(mem[sp])-unsigned(mem[sp+1]))  < 0 ? mem[sp+1]=1 : mem[sp+1]=0; sp = sp + 1
-  ulessthanorequal 001_00111 (27) (unsigned(mem[sp])-unsigned(mem[sp+1])) <= 0 || == 0 ? mem[sp+1]=1 : mem[sp+1]=0; sp = sp + 1
   swap			001_01000 (28)
-  mult			001_01001 (29)	mem[sp+1] = mem[sp+1] * mem[sp]; sp = sp + 1
-  lshiftright	001_01010 (2a)	mem[sp+1] = mem[sp+1] >> (mem[sp] & 0x1f); sp = sp + 1
-  ashiftleft	001_01011 (2b)  mem[sp+1] = mem[sp+1] << (mem[sp] & 0x1f); sp = sp + 1
-  ashiftright	001_01100 (2c)  mem[sp+1] = mem[sp+1] signed>> (mem[sp] & 0x1f); sp = sp + 1
-  call			001_01101 (2d)  a = mem[sp]; mem[sp]=pc + 1; pc = a
-  eq			001_01110 (2e)	mem[sp+1] = (mem[sp] == mem[sp+1]) ? 1 : 0; sp = sp + 1
-  neq			001_01111 (2f)  mem[sp+1] = (mem[sp] != mem[sp+1]) ? 1 : 0; sp = sp + 1
-  neg			001_10000 (30)	mem[sp] = NOT(mem[sp])+1
-  sub			001_10001 (31)  mem[sp+1]=mem[sp+1]-mem[sp]; sp=sp+1
-  xor			001_10010 (32)	mem[sp+1]=mem[sp] ^ mem[sp+1]; sp=sp+1
-  loadb		001_10011 (33)  mem[sp] = byte[ mem[sp] ]
-  storeb		001_10100 (34)  byte[mem[sp]] = (mem[sp+1] & 0xFF); sp = sp + 2
   div			001_10101 (35)	
   mod			001_10110 (36)	
-  eqbranch		001_10111 (37)  mem[sp+1] == 0 ? pc = pc + mem[sp]; sp = sp + 2
-  neqbranch	001_11000 (38)	mem[sp+1] != 0 ? pc = pc + mem[sp]; sp = sp + 2
-  poppcrel		001_11001 (39)	pc = pc + mem[sp]; sp = sp + 1
   config		001_11010 (3a)  
-  pushpc		001_11011 (3b)	sp=sp-1; mem[sp]=pc
   syscall		001_11100 (3c)
-  pushspadd	001_11101 (3d)	mem[sp] = sp + (mem[sp] << 2)
-  halfmult		001_11110 (3e)	mem[sp+1] = 16bits(mem[sp]) * 16bits(mem[sp+1]); sp = sp + 1
-  callpcrel	001_11111 (3f)  a = mem[sp]; mem[sp]=pc+1; pc = pc + a;

   gcc seems to be using only:

   add, addsp, and, ashiftleft, ashiftright, call, callpcrel, div, eq, flip, im, lessthan, 
   lessthanorequal, loadb, loadh, load, loadsp, lshiftright, mod, mult, neg, neqbranch,
   not, or, poppc, poppcrel, popsp, pushpc, pushspadd, pushsp, storeb, storeh, store, storesp, 
   sub, ulessthan, ulessthanorequal, xor
   
   --------- memory access ----------------------------
   
   data is stored in big-endian format into memory:
   00 MSB .. .. LSB
   05 ..  .. .. ..

   ---------------------------------------------------- */
`define SP_START			32'h10	// after reset change in startup code
`define EMULATION_VECTOR	32'h10	// table of emulated opcodes (interrupt & exception vectors plus up to 5 emulated opcodes)
`define RESET_VECTOR		32'h20	// reset entry point (can be moved up to 0x3c as per emulation table needs)

// ---- zpu core optimizations/features ----
`define ZPU_CORE_DEBUG
//`define ZPU_CORE_DEBUG_MICROCODE
`define	ASSERT_NON_ALIGNMENT	/* abort cpu in case of non-aligned memory access (only simulation) */

`define ENABLE_BYTE_SELECT		/* allow byte / halfword memory accesses */
`define ENABLE_CPU_INTERRUPTS	/* enable interrupts to cpu */
//`define ENABLE_PC_INCREMENT	/* gain 1 clk per opcode but requires microcode changes ** not done at the moment ** */
//`define ENABLE_A_SHIFT		/* 1 bit arithmetic shift (right) mutual exclusive with barrel shift */
//`define ENABLE_XOR			/* 1 cycle x-or */
//`define ENABLE_MULT			/* 32 bit pipelined (3 stages) multiplier */
//`define ENABLE_DIV			/* 32 bit, up to 32 cycles serial divider */
`define ENABLE_BARREL			/* n bit logical & arithmetic shift mutual exclusive with 1 bit shift */
`define ENABLE_CMP				/* enable ALU_CMP_SIGNED and ALU_CMP_UNSIGNED */

// ------- microcode zpu core datapath selectors --------
`define SEL_READ_DATA		0
`define SEL_READ_ADDR		1

`define SEL_ALU_A			0
`define SEL_ALU_OPCODE		1
`define SEL_ALU_MC_CONST	2
`define SEL_ALU_B			3

`define SEL_ADDR_PC			0
`define SEL_ADDR_SP			1
`define SEL_ADDR_A			2
`define SEL_ADDR_B			3

`define ALU_OP_WIDTH		4	// alu operation is 4 bits

`define ALU_NOP				0	// r = a
`define ALU_NOP_B			1	// r = b
`define ALU_PLUS			2	// r = a + b
`define ALU_PLUS_OFFSET		3	// r = a + { 27'b0, ~b[4], b[3:0] }
`define ALU_AND				4	// r = a AND b
`define ALU_OR				5	// r = a OR b
`define ALU_NOT				6	// r = NOT a
`define ALU_FLIP			7	// r = FLIP a
`define ALU_IM				8	// r = IDIM ? { a[24:0], b[6:0] } : { 25{b[6]}, b[6:0] }
`ifdef ENABLE_CMP
  `define ALU_CMP_UNSIGNED	9	// r = (unsigned)a - (unsigned)b (r[31] is overflow/underflow adjusted)
  `define ALU_CMP_SIGNED	10	// r = (signed)a - (signed)b (r[31] is overflow/underflow adjusted)
`endif
`ifdef ENABLE_BARREL
  `define ALU_BARREL		11	// r = a <<|>> b (logical, arithmetical)
`endif
`ifdef ENABLE_A_SHIFT
  `define ALU_A_SHIFT_RIGHT	11	// r = { a[31], a[31], a[30:29] }  = (signed)a >> 1
`endif
`ifdef ENABLE_XOR
  `define ALU_XOR			12	// r = a XOR b
`endif
`ifdef ENABLE_MULT
  `define ALU_MULT			13	// r = a * b
`endif
`ifdef ENABLE_DIV
  `define ALU_DIV			14	// r = a / b
  `define ALU_MOD			15	// r = a mod b
`endif

// ------- special zpu opcodes ------
`define OP_NOP				8'b0000_1011 // default value for opcode cache on reset
`define OP_IM				1'b1
`define OP_EMULATE			3'b001
`define OP_STORESP			3'b010
`define OP_LOADSP			3'b011
`define OP_ADDSP			4'b0001

// ------- microcode memory settings ------
`define MC_MEM_BITS			9		// 512 microcode operations
`define MC_BITS				36		// microcode opcode width

// ------- microcode labels for opcode execution -------
// based on microcode program
`define MC_ADDR_IM_NOIDIM	488
`define MC_ADDR_IM_IDIM		491
`define MC_ADDR_STORESP		493
`define MC_ADDR_LOADSP		496
`define MC_ADDR_ADDSP		500
`define MC_ADDR_EMULATE		504
`define MC_ADDR_INTERRUPT	484
`define MC_ADDR_FETCH_NEXT	480
`define MC_ADDR_FETCH		476
`define MC_ADDR_RESET		474

// ---------- microcode settings --------------------
`define P_SEL_READ		0	// alu-A multiplexor between data-in and addr-out (1 bit)
`define P_SEL_ALU		1	// alu-B multiplexor between a, b, mc_const or opcode (2 bits)
`define P_SEL_ADDR		3	// addr-out multiplexor between sp, pc, a, b (2 bits)
`define P_ALU			5	// alu operation (4 bits)
`define P_W_SP			9	// write sp (from alu-out)
`define P_W_PC			10	// write pc (from alu-out)
`define P_W_A			11	// write a (from alu-out)
`define P_W_B			12	// write b (from alu-out)
`define P_SET_IDIM		13	// set idim flag
`define P_CLEAR_IDIM	14	// clear idim flag
`define P_W_OPCODE		15	// write opcode  (from alu-out) : check if can be written directly from data-in
`define P_DECODE		16	// jump to microcode entry point based on current opcode
`define P_MEM_R			17	// request memory read
`define P_MEM_W			18	// request memory write
`define P_ADDR			19	// microcode address (7 bits (granularity is 4 words)) or constant to be used at microcode level
`define P_BRANCH		26	// microcode inconditional branch to address
`define P_OP_NOT_CACHED	27	// microcode branch if byte[pc] is not cached at opcode
`define P_A_ZERO		28	// microcode branch if a is zero
`define P_A_NEG			29	// microcode branch if a is negative a[31]=1
`define P_W_A_MEM		30	// write a directly from data-in (alu datapath is free to perform any other operation in parallel)
`ifdef ENABLE_BYTE_SELECT
  `define P_BYTE			31	// byte memory operation
  `define P_HALFWORD		32	// half word memory operation
`endif
`ifdef ENABLE_PC_INCREMENT
  `define P_PC_INCREMENT	33	// autoincrement PC bypassing ALU (1 clock gain per opcode) : not implemented at microcode level
`endif
`ifdef ENABLE_CPU_INTERRUPTS
  `define P_EXIT_INT		34	// clear interrupt flag (exit from interrupt)
  `define P_ENTER_INT		35	// set interrupt flag (enter interrupt)
`endif

`define MC_SEL_READ_DATA		(`SEL_READ_DATA << `P_SEL_READ)		// 1 bit
`define MC_SEL_READ_ADDR		(`SEL_READ_ADDR << `P_SEL_READ)

`define MC_SEL_ALU_A			(`SEL_ALU_A << `P_SEL_ALU)			// 2 bit
`define MC_SEL_ALU_OPCODE		(`SEL_ALU_OPCODE << `P_SEL_ALU)
`define MC_SEL_ALU_MC_CONST		(`SEL_ALU_MC_CONST << `P_SEL_ALU)
`define MC_SEL_ALU_B			(`SEL_ALU_B << `P_SEL_ALU)

`define MC_SEL_ADDR_PC			(`SEL_ADDR_PC << `P_SEL_ADDR)		// 2 bits
`define MC_SEL_ADDR_SP			(`SEL_ADDR_SP << `P_SEL_ADDR)
`define MC_SEL_ADDR_A			(`SEL_ADDR_A <<  `P_SEL_ADDR)
`define MC_SEL_ADDR_B			(`SEL_ADDR_B << `P_SEL_ADDR)

`define MC_ALU_NOP				(`ALU_NOP << `P_ALU)				// 4 bits
`define MC_ALU_NOP_B			(`ALU_NOP_B << `P_ALU)
`define MC_ALU_PLUS				(`ALU_PLUS << `P_ALU)
`define MC_ALU_AND				(`ALU_AND << `P_ALU)
`define MC_ALU_OR				(`ALU_OR << `P_ALU)
`define MC_ALU_NOT				(`ALU_NOT << `P_ALU)
`define MC_ALU_FLIP				(`ALU_FLIP << `P_ALU)
`define MC_ALU_IM				(`ALU_IM << `P_ALU)
`define MC_ALU_PLUS_OFFSET		(`ALU_PLUS_OFFSET << `P_ALU)
`ifdef ENABLE_CMP
  `define MC_ALU_CMP_SIGNED		(`ALU_CMP_SIGNED << `P_ALU)
  `define MC_ALU_CMP_UNSIGNED	(`ALU_CMP_UNSIGNED << `P_ALU)
`endif
`ifdef ENABLE_XOR
  `define MC_ALU_XOR			(`ALU_XOR << `P_ALU)
`endif
`ifdef ENABLE_A_SHIFT
  `define MC_ALU_A_SHIFT_RIGHT	(`ALU_A_SHIFT_RIGHT << `P_ALU)
`endif
`ifdef ENABLE_MULT
  `define MC_ALU_MULT			(`ALU_MULT << `P_ALU)
`endif
`ifdef ENABLE_DIV
  `define MC_ALU_DIV			(`ALU_DIV << `P_ALU)
  `define MC_ALU_MOD			(`ALU_MOD << `P_ALU)
`endif
`ifdef ENABLE_BARREL
  `define MC_ALU_BARREL			(`ALU_BARREL << `P_ALU)
`endif

`define MC_W_SP					(1 << `P_W_SP)
`define MC_W_PC					(1 << `P_W_PC)
`define MC_W_A					(1 << `P_W_A)
`define MC_W_A_MEM				(1 << `P_W_A_MEM)
`define MC_W_B					(1 << `P_W_B)
`define MC_W_OPCODE				(1 << `P_W_OPCODE)
`define MC_SET_IDIM				(1 << `P_SET_IDIM)
`define MC_CLEAR_IDIM			(1 << `P_CLEAR_IDIM)
`ifdef ENABLE_BYTE_SELECT
  `define MC_BYTE				(1 << `P_BYTE)
  `define MC_HALFWORD			(1 << `P_HALFWORD)
`endif
`ifdef ENABLE_PC_INCREMENT
  `define MC_PC_INCREMENT		(1 << `P_PC_INCREMENT)
`endif
`ifdef ENABLE_CPU_INTERRUPTS
  `define MC_EXIT_INTERRUPT		(1 << `P_EXIT_INT)
  `define MC_ENTER_INTERRUPT	(1 << `P_ENTER_INT)
`endif

`define MC_MEM_R				(1 << `P_MEM_R)
`define MC_MEM_W				(1 << `P_MEM_W)

`define MC_DECODE				(1 << `P_DECODE)
`define MC_BRANCH				(1 << `P_BRANCH)
`define MC_BRANCHIF_OP_NOT_CACHED	(1 << `P_OP_NOT_CACHED)
`define MC_BRANCHIF_A_ZERO		(1 << `P_A_ZERO)
`define MC_BRANCHIF_A_NEG		(1 << `P_A_NEG)

// microcode common operations

`define MC_ADDR_FETCH_OP	( (`MC_ADDR_FETCH >> 2) << `P_ADDR)			// fetch opcode from memory then decode
`define MC_ADDR_NEXT_OP		( (`MC_ADDR_FETCH_NEXT >> 2) << `P_ADDR)	// go to next opcode
`define MC_ADDR_EMULATE_OP	( (`MC_ADDR_EMULATE >> 2) << `P_ADDR)		// EMULATE opcode

`define MC_PC_PLUS_1	(`MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_SEL_ALU_MC_CONST | `MC_ALU_PLUS  | (1 << `P_ADDR) | `MC_W_PC)
`define MC_SP_MINUS_4	(`MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_SEL_ALU_MC_CONST | `MC_ALU_PLUS  | ((-4 & 127) << `P_ADDR) | `MC_W_SP)
`define MC_SP_PLUS_4	(`MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_SEL_ALU_MC_CONST | `MC_ALU_PLUS  | (4 << `P_ADDR) | `MC_W_SP)
`define MC_EMULATE		(`MC_BRANCH | `MC_ADDR_EMULATE_OP)

`define MC_FETCH		(`MC_BRANCHIF_OP_NOT_CACHED | `MC_ADDR_FETCH_OP | `MC_DECODE)	// fetch and decode current PC opcode
`define MC_GO_NEXT		(`MC_BRANCH | `MC_ADDR_NEXT_OP)				// go to next opcode (PC=PC+1, fetch, decode)
`define MC_GO_FETCH		(`MC_BRANCH | `MC_ADDR_FETCH_OP)			// go to fetch opcode at PC, then decode
`define MC_GO_BREAKPOINT (`MC_BRANCH | ((0 >> 2) << `P_ADDR))		// go to breakpoint opcode

