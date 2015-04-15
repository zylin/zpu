`timescale 1ns / 1ps
`include "zpu_core_defines.v"

/*      MODULE: zpu_core_rom
        DESCRIPTION: Contains microcode program
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

module zpu_core_rom (
	clk,
	addr,
	data
);

input [`MC_MEM_BITS-1:0]	addr;
output [`MC_BITS-1:0]		data;
input 				clk;

wire [`MC_MEM_BITS-1:0]		addr;
reg  [`MC_BITS-1:0]		data;
reg  [`MC_BITS-1:0]		memory[(1<<`MC_MEM_BITS)-1:0];

initial data <= 0;
always @(posedge clk) data <= memory[addr];

// --- clear all memory at startup; for any reason, xilinx xst
// will not syntetize as block ram if not all memory is initialized ---
integer n;
initial begin
// initialize all memory array
for(n = 0; n < (1<<`MC_MEM_BITS); n = n + 1) memory[n] = 0;

// ------------------------- MICROCODE MEMORY START -----------------------------------

// As per zpu_core.v, each opcode is executed by microcode. Each opcode microcode entry point
// is at <opcode> << 2 (example pushsp = 0x02 has microcode entry point of 0x08); this leaves
// room of 4 microcode operations per opcode; if the opcode microcode needs more space,
// it can jump & link to other microcode address (with the two lower bits at 0). The lower 256 addresses
// of microcode memory are entry points and code for 0..127 opcodes; other specific opcodes like im, storesp, etc.
// are directly hardwired to specific microcode addresses at the memory end. Upper 256 addresses are
// used by microcode continuation (eg. opcodes which needs more microcode operations), entry points, initializations, etc.
// the idea is to fit the microcode program in a xilinx blockram 512x36.

// ----- OPCODES WITHOUT CONSTANT ------

// 0000_0000 (00) breakpoint -------------------------------------
memory[0] = `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST | (4 << `P_ADDR) |		// b = 4 (#1 in emulate table)
		`MC_W_B;
memory[1] = `MC_EMULATE;												// emulate #1 (exception)

// 0000_0001 (01) shiftleft  -------------------------------------
memory[4] = `MC_GO_BREAKPOINT;

// 0000_0010 (02) pushsp  -------------------------------------
//	mem[sp-1] = sp
//	sp = sp - 1
memory[8] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | 		// a = sp
		`MC_ALU_NOP | `MC_W_A;
memory[9] = `MC_SP_MINUS_4;												// sp = sp - 1
memory[10] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;					// mem[sp]=a

// 0000_0011 (03) popint  -------------------------------------
`ifdef ENABLE_CPU_INTERRUPTS
// pc=mem[sp]-1		(emulate stores pc+1 but we must return to
// sp=sp+1			 pc because interrupt takes precedence to decode)
// fetch & decode, then clear_interrupt_flag
// this guarantees that a continous interrupt allows to execute at least one
// opcode of mainstream program before reentry to interrupt handler
memory[12] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | 	// pc = mem[sp]-1
		`MC_MEM_R | `MC_ALU_PLUS | `MC_SEL_ALU_MC_CONST | 
		((-1 & 127) << `P_ADDR) | `MC_W_PC;
memory[13] = `MC_SEL_ADDR_PC | `MC_SEL_READ_DATA | `MC_MEM_R |			// opcode_cache = mem[pc]
		 `MC_W_OPCODE; 
memory[14] = `MC_SP_PLUS_4 | `MC_DECODE | `MC_EXIT_INTERRUPT;			// sp=sp+1, decode opcode, exit_interrupt
`else
memory[12] = `MC_GO_BREAKPOINT;
`endif

// 0000_0100 (04) poppc  -------------------------------------
//	pc=mem[sp]
//	sp = sp + 1
memory[16] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | 	// pc = mem[sp]
		`MC_MEM_R | `MC_W_PC; 	
memory[17] = `MC_SP_PLUS_4;												// sp = sp + 1
memory[18] = `MC_FETCH;													// opcode cached ? decode : fetch,decode

// 0000_0101 (05) add   -------------------------------------
//	mem[sp+1] = mem[sp+1] + mem[sp]
//	sp = sp + 1
memory[20] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | 			// a = mem[sp] || sp=sp+1
		`MC_W_A_MEM | `MC_SP_PLUS_4;
memory[21] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = a + mem[sp]
		 `MC_ALU_PLUS | `MC_SEL_ALU_A | `MC_W_A;
memory[22] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;					// mem[sp] = a

// 0000_0110 (06) and   -------------------------------------
//	mem[sp+1] = mem[sp+1] & mem[sp]
//	sp = sp + 1
memory[24] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |				// a = mem[sp] || sp=sp+1
		 `MC_W_A_MEM | `MC_SP_PLUS_4;
memory[25] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = a & mem[sp]
		 `MC_ALU_AND |`MC_SEL_ALU_A | `MC_W_A;
memory[26] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;					// mem[sp] = a

// 0000_0111 (07) or   -------------------------------------
//	mem[sp+1] = mem[sp+1] | mem[sp]
//	sp = sp + 1
memory[28] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |				// a = mem[sp] || sp=sp+1
		 `MC_W_A_MEM | `MC_SP_PLUS_4;
memory[29] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |	 		// a = a | mem[sp]
		`MC_ALU_OR | `MC_SEL_ALU_A | `MC_W_A;
memory[30] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;					// mem[sp] = a

// 0000_1000 (08) load   -------------------------------------
//	mem[sp] = mem[ mem[sp] ]
memory[32] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |		// a = mem[sp]
		 `MC_MEM_R | `MC_W_A;
memory[33] = `MC_SEL_ADDR_A | `MC_SEL_READ_DATA | `MC_MEM_R | `MC_W_A; 	// a = mem[a]
memory[34] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;					// mem[sp] = a

// 0000_1001 (09) not   -------------------------------------
//	mem[sp] = ~mem[sp]
memory[36] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | 	// a = ~mem[sp]
		 `MC_MEM_R | `MC_ALU_NOT | `MC_W_A; 							
memory[37] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;					// mem[sp] = a

// 0000_1010 (0a) flip   -------------------------------------
//	mem[sp] = flip(mem[sp])
memory[40] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |		// a = FLIP(mem[sp])
		 `MC_MEM_R | `MC_ALU_FLIP | `MC_W_A; 							
memory[41] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;					// mem[sp] = a

// 0000_1011 (0b) nop   -------------------------------------
memory[44] = `MC_CLEAR_IDIM | `MC_PC_PLUS_1;							// IDIM=0
memory[45] = `MC_FETCH;

// 0000_1100 (0c) store   -------------------------------------
//	mem[mem[sp]] <= mem[sp+1]
//	sp = sp + 2
memory[48] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |		// b = mem[sp]
		 `MC_MEM_R | `MC_W_B;
memory[49] = `MC_SP_PLUS_4;												// sp = sp + 1
memory[50] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM | `MC_SP_PLUS_4; // a = mem[sp] || sp = sp + 1
memory[51] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_GO_NEXT;					// mem[b] = a

// 0000_1101 (0d) popsp   -------------------------------------
//	sp = mem[sp]
memory[52] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |				// sp = mem[sp]
		 `MC_W_SP | `MC_GO_NEXT;

// 0000_1110 (0e) ipsum    ------------------------------------
// compare: opcode recycled --> ipsum
// c=mem[sp];s=mem[sp+1]; sum=0; 
// while(c-->0) {sum+=halfword(mem[s],s);s++};
// sp=sp+1; mem[sp]=sum (overwrites mem[0] & mem[4] words)
// requires HALFWORD memory access
`ifdef ENABLE_BYTE_SELECT
memory[56] = `MC_CLEAR_IDIM | `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST |	// b=0
		(0 << `P_ADDR) | `MC_W_B;
memory[57] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=pc+1	save next pc on mem[0]
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[58] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_ALU_NOP_B | `MC_W_B |		// mem[b]=a || b=4
		`MC_SEL_ALU_MC_CONST | (4 << `P_ADDR);
memory[59] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_W_A |			// a=sp || goto @ipsum_continue1
		`MC_BRANCH | ((116 >> 2) << `P_ADDR);
`else
memory[56] = `MC_GO_BREAKPOINT;
`endif

// 0000_1111 (0f) sncpy   ---------------------------------------
// c=mem[sp],d=mem[sp+1],s=mem[sp+2]; 
// while( *(char*)s != 0 && c>0 ) { *((char*)d++)=*((char*)s++)); c-- }; 
// sp=sp+1; mem[sp+1]=d; mem[sp]=c 
// (overwrites mem[0] & mem[4] words)
// requires BYTE memory access
`ifdef ENABLE_BYTE_SELECT
memory[60] = `MC_CLEAR_IDIM | `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST |	// b=0
		(0 << `P_ADDR) | `MC_W_B;
memory[61] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=pc+1	save next pc on mem[0]
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[62] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_ALU_NOP_B | `MC_W_B |		// mem[b]=a || b=4
		`MC_SEL_ALU_MC_CONST | (4 << `P_ADDR);
memory[63] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_W_A |			// a=sp || goto @sncpy_continue1
		`MC_BRANCH | ((100 >> 2) << `P_ADDR);
`else
memory[60] = `MC_GO_BREAKPOINT;
`endif

// ------------- microcode opcode continuations ---------------
// wset_continue1: ------------------------
memory[64] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=a+12	save clear stack on mem[4]
		`MC_SEL_ALU_MC_CONST | (12 << `P_ADDR) | `MC_W_A;
memory[65] = `MC_SEL_ADDR_B | `MC_MEM_W;								// mem[b]=a
memory[66] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_PC;// pc=mem[sp] (data)
memory[67] = `MC_SP_PLUS_4;												// sp=sp+4
memory[68] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_B; // b=mem[sp] (count)
memory[69] = `MC_SP_PLUS_4;												// sp=sp+4
memory[70] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_SP;// sp=mem[sp] (destination @)
memory[71] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_W_A;				// a=b (count)
// wset_loop:
memory[72] = `MC_BRANCHIF_A_ZERO | ( (80 >> 2) << `P_ADDR);					// if(a==0) goto @wset_end
memory[73] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// b=b-1 (count)
		`MC_SEL_ALU_MC_CONST | ((-1 & 127) << `P_ADDR) | `MC_W_B;
memory[74] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_W_A;				// a=pc (data)
memory[75] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_SP_PLUS_4;				// mem[sp]=a || sp=sp+4 (sp=destination@)
memory[76] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_W_A | 			// a=b (count) || goto @wset_loop
		`MC_BRANCH | ((72 >> 2) << `P_ADDR);
// wset_end: wcpy_end: sncpy_end:
memory[80] = `MC_SEL_ADDR_A | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_PC;	// pc=mem[a] (a is 0)
memory[81] = `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST | (4 << `P_ADDR) |	// b=4
		`MC_W_B;
memory[82] = `MC_SEL_ADDR_B | `MC_MEM_R | `MC_SEL_READ_DATA | 			// sp=mem[b] || goto @fetch
		`MC_W_SP | `MC_FETCH;
		
// wcpy_continue1: ------------------------
memory[84] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=a+12	save clear stack on mem[4]
		`MC_SEL_ALU_MC_CONST | (12 << `P_ADDR) | `MC_W_A;
memory[85] = `MC_SEL_ADDR_B | `MC_MEM_W;								// mem[b]=a
memory[86] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_B;	// b=mem[sp] (count)
memory[87] = `MC_SP_PLUS_4;												// sp=sp+4
memory[88] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_PC;// pc=mem[sp] (destination @)
memory[89] = `MC_SP_PLUS_4;												// sp=sp+4
memory[90] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_SP;// sp=mem[sp] (source @)
memory[91] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_W_A;				// a=b (count)
// wcpy_loop:
memory[92] = `MC_BRANCHIF_A_ZERO | ( (80 >> 2) << `P_ADDR);					// if(a==0) goto @wcpy_end
memory[93] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// b=b-1 (count)
		`MC_SEL_ALU_MC_CONST | ((-1 & 127) << `P_ADDR) | `MC_W_B;
memory[94] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |				// a=mem[sp] || sp=sp+4 (sp=source@)
		`MC_SP_PLUS_4;
memory[95] = `MC_SEL_ADDR_PC | `MC_MEM_W | `MC_SEL_READ_ADDR | 			// mem[pc]=a || pc=pc+4 (pc=destination@)
		`MC_ALU_PLUS | `MC_SEL_ALU_MC_CONST | (4 << `P_ADDR) | `MC_W_PC;
memory[96] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_W_A | 			// a=b (count) || goto @wcpy_loop
		`MC_BRANCH | ((92 >> 2) << `P_ADDR);

`ifdef ENABLE_BYTE_SELECT
// sncpy_continue1: ---------------------
memory[100] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=a+12
		`MC_SEL_ALU_MC_CONST | (12 << `P_ADDR) | `MC_W_A;
memory[101] = `MC_SEL_ADDR_B | `MC_MEM_W;								// mem[b]=a
memory[102] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_B;// b=mem[sp] (count)
memory[103] = `MC_SP_PLUS_4;											// sp=sp+4
memory[104] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_PC;// pc=mem[sp] (destination @)
memory[105] = `MC_SP_PLUS_4;											// sp=sp+4
memory[106] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | `MC_W_SP;// sp=mem[sp] (source @)
memory[107] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_W_A;				// a=b (count)
// sncpy_loop:
memory[108] = `MC_BRANCHIF_A_ZERO | ( (80 >> 2) << `P_ADDR);				// if(a==0) goto @sncpy_end  (count==0?)
memory[109] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_BYTE | `MC_W_A_MEM |	// a=BYTE(mem[sp],sp) || sp=sp+1 (sp=source@)
		`MC_SEL_READ_ADDR | `MC_ALU_PLUS | `MC_SEL_ALU_MC_CONST | 
		(1 << `P_ADDR) | `MC_W_SP;
memory[110] = `MC_SEL_ADDR_PC | `MC_MEM_W | `MC_SEL_READ_ADDR |			// BYTE(mem[pc],pc)=a || pc=pc+1 (pc=destination@)
		`MC_BYTE | `MC_ALU_PLUS | `MC_SEL_ALU_MC_CONST | 
		(1 << `P_ADDR) | `MC_W_PC;
memory[111] = `MC_BRANCHIF_A_ZERO | ( (80 >> 2) << `P_ADDR);				// if(a==0) goto @sncpy_end  (mem[src]==0?)
memory[112] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// b=b-1 (count)
		`MC_SEL_ALU_MC_CONST | ((-1 & 127) << `P_ADDR) | `MC_W_B;
memory[113] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_W_A | 			// a=b (count) || goto @sncpy_loop
		`MC_BRANCH | ((108 >> 2) << `P_ADDR);

// ipsum_continue1: -------------------
memory[116] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=a+4
		`MC_SEL_ALU_MC_CONST | (4 << `P_ADDR) | `MC_W_A;
memory[117] = `MC_SEL_ADDR_B | `MC_MEM_W;								// mem[b]=a		save return sp on mem[4]
memory[118] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | 		// pc=mem[sp] 	(count)
		`MC_W_PC;
memory[119] = `MC_SP_PLUS_4;											// sp=sp+4
memory[120] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA | 		// sp=mem[sp] 	(start @)
		`MC_W_SP;
memory[121] = `MC_SEL_ALU_MC_CONST | (0 << `P_ADDR) | `MC_W_B |			// b=0			(sum)
		`MC_ALU_NOP_B;
memory[122] = `MC_SEL_ADDR_PC | `MC_SEL_READ_DATA | `MC_W_A;			// a=pc (count)
// ipsum_loop:
memory[124] = `MC_BRANCHIF_A_ZERO | ((392 >> 2) << `P_ADDR);				// a == 0 ? goto @ipsum_end
		
memory[125] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_HALFWORD |				// b=mem[sp]+b
		`MC_SEL_READ_DATA | `MC_ALU_PLUS | `MC_SEL_ALU_B | `MC_W_B;
memory[126] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// sp=sp+2
		`MC_SEL_ALU_MC_CONST | (2 << `P_ADDR) | `MC_W_SP;
memory[127] = `MC_BRANCH | ((408 >> 2) << `P_ADDR);						// goto @ipsum_continue2
`endif

// -------------------------------------------------------------

// 001_00000 (20) wcpy -----------------------------------------
// before using this opcode you must save mem[0] & mem[4] words, then wcpy, then restore mems
// c=mem[sp],d=mem[sp+1],s=mem[sp+2]; while(c-->0) mem[d++]=mem[s++]; sp=sp+3
memory[128] = `MC_CLEAR_IDIM | `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST |	// b=0
		(0 << `P_ADDR) | `MC_W_B;
memory[129] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=pc+1
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[130] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_ALU_NOP_B | `MC_W_B |	// mem[b]=a || b=4
		`MC_SEL_ALU_MC_CONST | (4 << `P_ADDR);
memory[131] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_W_A |			// a=sp || goto @wcpy_continue1
		`MC_BRANCH | ((84 >> 2) << `P_ADDR);

// 001_00001 (21) wset ----------------------------------------
// before using this opcode you must save mem[0] & mem[4] words, then wset, then restore mems
// v=mem[sp],c=mem[sp+1],d=mem[sp+2]; while(c-->0) mem[d++]=v; sp=sp+3
memory[132] = `MC_CLEAR_IDIM | `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST |	// b=0
		(0 << `P_ADDR) | `MC_W_B;
memory[133] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a=pc+1
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[134] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_ALU_NOP_B | `MC_W_B |	// mem[b]=a || b=4
		`MC_SEL_ALU_MC_CONST | (4 << `P_ADDR);
memory[135] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_W_A |			// a=sp || goto @wset_continue1
		`MC_BRANCH | ((64 >> 2) << `P_ADDR);

// 001_00010 (22) loadh   -------------------------------------
`ifdef ENABLE_BYTE_SELECT
//	mem[sp] = HALFWORD(mem[sp], mem[mem[sp]])
memory[136] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = mem[sp]
		 `MC_MEM_R | `MC_W_A;
memory[137] = `MC_SEL_ADDR_A | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = halfword(a, mem[a])
		 `MC_W_A | `MC_HALFWORD; 
memory[138] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
memory[136] = `MC_GO_BREAKPOINT;
`endif

// 001_00011 (23) storeh   -------------------------------------
`ifdef ENABLE_BYTE_SELECT
//	HALFWORD( mem[mem[sp]] <= mem[sp+1] )
//	sp = sp + 2
memory[140] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// b = mem[sp]
		 `MC_MEM_R | `MC_W_B; 
memory[141] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[142] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |				// a = mem[sp] || sp=sp+1
		 `MC_SP_PLUS_4; 
memory[143] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_HALFWORD | `MC_GO_NEXT;	// HALFWORD(mem[b] = a)
`else
memory[140] = `MC_GO_BREAKPOINT;
`endif

// 001_00100 (24) lessthan   -------------------------------------
// (mem[sp]-mem[sp+1]) < 0 ? mem[sp+1]=1 : mem[sp+1]=0
// sp=sp+1
`ifdef ENABLE_CMP
memory[144] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |	// a=mem[sp] || sp=sp+1
	`MC_SP_PLUS_4;
memory[145] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R | `MC_W_B;	// b=mem[sp]
memory[146] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// a = (a - b) with overflow/underflow correction || goto @lessthan_check
	`MC_ALU_CMP_SIGNED | `MC_W_A | ((424>>2) << `P_ADDR) | `MC_BRANCH;
`else
memory[144] = `MC_GO_BREAKPOINT;
`endif

// 001_00101 (25) lessthanorequal   -------------------------------------
// (mem[sp]-mem[sp+1]) <= 0 ? mem[sp+1]=1 : mem[sp+1]=0
// sp=sp+1
`ifdef ENABLE_CMP
memory[148] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |	// a=mem[sp] || sp=sp+1
	`MC_SP_PLUS_4;
memory[149] = `MC_SEL_ADDR_SP | `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_B;	// b=mem[sp]
memory[150] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// a = (a - b) with overflow/underflow correction || goto @lessthanorequal_check
	`MC_ALU_CMP_SIGNED | `MC_W_A | ((420>>2) << `P_ADDR) | `MC_BRANCH;
`else
memory[148] = `MC_GO_BREAKPOINT;
`endif

// 001_00110 (26) ulessthan   -------------------------------------
// signA!=signB -> (unsigA < unsigB) == ~(sigA < sigA)
// signA==signB -> (unsigA < unsigB) ==  (sigA < sigB)
// (mem[sp]-mem[sp+1]) < 0 ? mem[sp+1]=1 : mem[sp+1]=0
// sp=sp+1
`ifdef ENABLE_CMP
memory[152] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |	// a=mem[sp] || sp=sp+1
	`MC_SP_PLUS_4;
memory[153] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R | `MC_W_B;	// b=mem[sp]
memory[154] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// a = (a - b) with overflow/underflow correction || goto @lessthan_check
	`MC_ALU_CMP_UNSIGNED | `MC_W_A | ((424>>2) << `P_ADDR) | `MC_BRANCH;
`else
memory[152] = `MC_GO_BREAKPOINT;
`endif

// 001_00111 (27) ulessthanorequal   -------------------------------------
// (mem[sp]-mem[sp+1]) <= 0 ? mem[sp+1]=1 : mem[sp+1]=0
// sp=sp+1
`ifdef ENABLE_CMP
memory[156] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |	// a=mem[sp] || sp=sp+1
	`MC_SP_PLUS_4;
memory[157] = `MC_SEL_ADDR_SP | `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_B;	// b=mem[sp]
memory[158] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// a = (a - b) with overflow/underflow correction || goto @lessthanorequal_check
	`MC_ALU_CMP_UNSIGNED | `MC_W_A | ((420>>2) << `P_ADDR) | `MC_BRANCH;
`else
memory[156] = `MC_GO_BREAKPOINT;
`endif

// 001_01000 (28) swap   -------------------------------------
memory[160] = `MC_GO_BREAKPOINT;

// 001_01001 (29) mult   -------------------------------------
`ifdef ENABLE_MULT
//	mem[sp+1] = mem[sp+1] * mem[sp]
//	sp = sp + 1
memory[164] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |			// a = mem[sp] || sp=sp+1
		 `MC_W_A_MEM | `MC_SP_PLUS_4;
memory[165] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// b = mem[sp]
		  `MC_W_B;
memory[166] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// a = a * b   DON'T COMBINE MULTICYCLE ALU
		  `MC_ALU_MULT | `MC_W_A;										// OPERATIONS WITH MEMORY READ/WRITE
memory[167] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
memory[164] = `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST | (8 << `P_ADDR) |	// b = 8 (#2 in emulate table)
		`MC_W_B;
memory[165] = `MC_EMULATE;												// emulate #2 (mult opcode)
`endif

// 001_01010 (2a) lshiftright   -------------------------------------
`ifdef ENABLE_BARREL
// b = mem[sp] & 5'b1111	: limit to 5 bits (max 31 shifts)
// b = b | 7'b01_00000		: shift right, logical
// sp=sp+1
// a = mem[sp]
// a = a >> b
// mem[sp] = a
memory[168] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// b = mem[sp] & 5'b11111
		`MC_MEM_R | `MC_ALU_AND | `MC_SEL_ALU_MC_CONST | (31 << `P_ADDR) | `MC_W_B;
memory[169] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_OR |			// b = b | 7'b01_00000 (shift right, logical)
		`MC_SEL_ALU_MC_CONST | (32 << `P_ADDR) | `MC_W_B;
memory[170] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[171] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = mem[sp] | goto @shift_cont
		`MC_W_A_MEM | `MC_BRANCH | ((432 >> 2) << `P_ADDR);
`else
 `ifdef ENABLE_A_SHIFT
// a = mem[sp] & 5'b11111
// sp=sp+1
// b = FLIP(mem[sp])
// label: a <= 0 ? goto @fin
// b = b << 1
// a = a - 1 || goto @label
// fin: a = FLIP(b)
// mem[sp]=a
memory[168] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = mem[sp] & 5'b11111
		`MC_MEM_R | `MC_ALU_AND | `MC_SEL_ALU_MC_CONST | 
		(31 << `P_ADDR) | `MC_W_A;
memory[169] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[170] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// b = FLIP(mem[sp])
		`MC_ALU_FLIP | `MC_W_B;
memory[171] = `MC_BRANCH | ((448 >> 2) << `P_ADDR);						// goto @lshiftleft_loop
 `else
 memory[168] = `MC_GO_BREAKPOINT;
 `endif
`endif

// 001_01011 (2b) ashiftleft   -------------------------------------
`ifdef ENABLE_BARREL
// b = mem[sp] & 5'b11111	: 5 bit shift
// b = b | 7'b10_00000		: shift left, arithmetic
// sp=sp+1
// a = mem[sp]
// a = a <<signed b
// mem[sp] = a
memory[172] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// b = mem[sp] & 5'b11111
		`MC_MEM_R | `MC_ALU_AND | `MC_SEL_ALU_MC_CONST |  (31 << `P_ADDR) | `MC_W_B;
memory[173] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_OR |			// b = b | 7'b10_00000 (shift left, arithmetic)
		`MC_SEL_ALU_MC_CONST | (64 << `P_ADDR) | `MC_W_B;
memory[174] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[175] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = mem[sp] | goto @shift_cont
		`MC_W_A_MEM | `MC_BRANCH | ((432 >> 2) << `P_ADDR);	
`else
// a = mem[sp] & 5'b11111
// sp = sp + 1
// b = mem[sp]
// label: a <= 0 ? goto @fin
// b = b << 1
// a = a - 1 || goto @label
// fin: a = b
// mem[sp] = a
memory[172] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = mem[sp] & 5'b11111
		`MC_MEM_R | `MC_ALU_AND | `MC_SEL_ALU_MC_CONST | 
		(31 << `P_ADDR) | `MC_W_A;
memory[173] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[174] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// b = mem[sp]
		`MC_W_B;
memory[175] = `MC_BRANCH | ((440 >> 2) << `P_ADDR);						// goto @ashiftleft_loop
`endif

// 001_01100 (2c) ashiftright   -------------------------------------
`ifdef ENABLE_BARREL
// b = mem[sp] & 5'b11111	: 5 bit shift
// b = b | 7'b00_00000		: shift right, arithmetic
// sp=sp+1
// a = mem[sp]
// a = a >>signed b
// mem[sp] = a
memory[176] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// b = mem[sp] & 5'b11111
		`MC_MEM_R | `MC_ALU_AND | `MC_SEL_ALU_MC_CONST |  (31 << `P_ADDR) | `MC_W_B;
memory[177] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[178] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = mem[sp] | goto @shift_cont
		`MC_W_A_MEM | `MC_BRANCH | ((432 >> 2) << `P_ADDR);
`else
 `ifdef ENABLE_A_SHIFT
// a = mem[sp] & 5'b11111
// sp = sp + 1
// b = FLIP(mem[sp])
// label: a <= 0 ? goto @fin
// b = b signed_<< 1
// a = a - 1 || goto @label
// fin: a = FLIP(b)
// mem[sp] = a
memory[176] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = mem[sp] & 5'b11111
		`MC_MEM_R | `MC_ALU_AND | `MC_SEL_ALU_MC_CONST | 
		(31 << `P_ADDR) | `MC_W_A;
memory[177] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[178] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// b = FLIP(mem[sp])
		`MC_ALU_FLIP | `MC_W_B;
memory[179] = `MC_BRANCH | ((432 >> 2) << `P_ADDR);						// goto @ashiftright_loop
 `else
memory[176] = `MC_GO_BREAKPOINT;
 `endif
`endif

// 001_01101 (2d) call   -------------------------------------
//	a = mem[sp]
//	mem[sp]=pc+1
//	pc = a
memory[180] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |  	// b = mem[sp]
		`MC_MEM_R | `MC_W_B;
memory[181] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_ALU_PLUS | 
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;				// a = pc + 1
memory[182] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_ALU_NOP_B | 			// mem[sp] = a || pc = b
		`MC_SEL_ALU_B | `MC_W_PC;
memory[183] = `MC_FETCH;												// op_cached? decode : goto next

// 001_01110 (2e) eq   -------------------------------------
//	a = mem[sp]
//	sp = sp + 1
//	(mem[sp] - a == 0) ? mem[sp] = 1 : mem[sp] = 0
memory[184] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | 			// a = NOT(mem[sp])
		`MC_SEL_READ_DATA | `MC_ALU_NOT | `MC_W_A;
memory[185] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR |`MC_ALU_PLUS |		// a = a + 1
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[186] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[187] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R | 		// a = mem[sp] + a || goto @eq_check
		`MC_ALU_PLUS |`MC_SEL_ALU_A | `MC_W_A | 
		( (416 >> 2) << `P_ADDR) | `MC_BRANCH;

// 001_01111 (2f) neq   -------------------------------------
//	a = mem[sp]
//	sp = sp + 1
//	(mem[sp] - a != 0) ? mem[sp] = 1 : mem[sp] = 0
memory[188] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = NOT(mem[sp])
		`MC_MEM_R | `MC_ALU_NOT | `MC_W_A;
memory[189] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR |`MC_ALU_PLUS |		// a = a + 1
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[190] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[191] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = mem[sp] + a || goto @neq_check
		`MC_ALU_PLUS | `MC_SEL_ALU_A | `MC_W_A | 
		( (412 >> 2) << `P_ADDR) | `MC_BRANCH;

// 001_10000 (30) neg   -------------------------------------
//	a = NOT(mem[sp])
//	a = a + 1
//	mem[sp] = a
memory[192] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = NOT(mem[sp])
		 `MC_MEM_R | `MC_ALU_NOT | `MC_W_A;
memory[193] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS | 		// a = a + 1
		 (1 << `P_ADDR) | `MC_SEL_ALU_MC_CONST | `MC_W_A; 				
memory[194] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a

// 001_10001 (31) sub   -------------------------------------
//	mem[sp+1] = mem[sp+1] - mem[sp]
//  sp = sp + 1
memory[196] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = NOT(mem[sp])
		`MC_MEM_R | `MC_ALU_NOT | `MC_W_A;
memory[197] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a = a + 1
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[198] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[199] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = mem[sp] + a || goto @sub_cont (set_mem[sp]=a)
		`MC_ALU_PLUS | `MC_SEL_ALU_A | `MC_W_A | ((400>>2) << `P_ADDR) |
		`MC_BRANCH;

// 001_10010 (32) xor   -------------------------------------
`ifdef ENABLE_XOR
//	mem[sp+1] = mem[sp+1] ^ mem[sp]
//	sp = sp + 1
memory[200] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |			// a = mem[sp] || sp=sp+1
		 `MC_W_A_MEM | `MC_SP_PLUS_4;
memory[201] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = a ^ mem[sp]
		 `MC_ALU_XOR |`MC_SEL_ALU_A | `MC_W_A;
memory[202] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
// ALU doesn't perform XOR operation
// mem[sp+1] = mem[sp] ^ mem[sp+1]  -> A^B=(A&~B)|(~A&B)
// a = ~mem[sp] --> a = ~A
// sp = sp + 1
// a = mem[sp] & a --> a = ~A&B
// b = ~a  --> b = A&~B
// a = a | b --> a = ~A&B | A&~B
// mem[sp] = a
memory[200] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = ~mem[sp] --> a=~A
		`MC_ALU_NOT	| `MC_W_A;
memory[201] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[202] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = mem[sp] & a --> a = ~A&B
		`MC_ALU_AND | `MC_SEL_ALU_A | `MC_W_A;
memory[203] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_NOT |		// b = ~a || goto @xor_cont --> b = A&~B
		`MC_W_B | `MC_BRANCH | ((428 >> 2) << `P_ADDR);
`endif

// 001_10011 (33) loadb   -------------------------------------
`ifdef ENABLE_BYTE_SELECT
//	mem[sp] = BYTE(mem[sp], mem[mem[sp]])
memory[204] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// a = mem[sp]
		 `MC_MEM_R | `MC_W_A;
memory[205] = `MC_SEL_ADDR_A | `MC_SEL_READ_DATA | `MC_MEM_R |			// a = byte(a, mem[a])
		 `MC_W_A | `MC_BYTE;
memory[206] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
// b=pc
// pc = mem[sp]
// opcode_cache=mem[pc]
// a = opcode
// mem[sp]=a
// pc=b
// fetch
memory[204] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR |	// b = pc
		`MC_W_B;
memory[205] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R | 		// pc = mem[sp]
		`MC_W_PC;
memory[206] = `MC_SEL_ADDR_PC | `MC_SEL_READ_DATA | `MC_MEM_R |			// opcode_cache = mem[pc]
		`MC_W_OPCODE;
memory[207] = `MC_SEL_ALU_OPCODE | `MC_ALU_NOP_B | `MC_W_A |			// a = opcode -> byte(pc, mem[pc]) || goto @loadb_continued
		`MC_BRANCH | ( (396 >> 2) << `P_ADDR);
`endif

// 001_10100 (34) storeb   -------------------------------------
`ifdef ENABLE_BYTE_SELECT
//	BYTE( mem[mem[sp]] <= mem[sp+1] )
//	sp = sp + 2
memory[208] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA |	// b = mem[sp]
		 `MC_MEM_R | `MC_W_B; 
memory[209] = `MC_SP_PLUS_4;											// sp = sp + 1
memory[210] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |				// a = mem[sp] || sp=sp+1
		 `MC_SP_PLUS_4; 
memory[211] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_BYTE | `MC_GO_NEXT;		// BYTE(mem[b] = a)
`else
memory[208] = `MC_GO_BREAKPOINT;
`endif

// 001_10101 (35) div    -------------------------------------
`ifdef ENABLE_DIV
// *** TODO: CHECK IF DIVIDE BY ZERO AND RAISE EXCEPTION ***
//	mem[sp+1] = mem[sp+1] / mem[sp]
//	sp = sp + 1
memory[212] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |			// a = mem[sp] || sp=sp+1
		 `MC_W_A_MEM | `MC_SP_PLUS_4;
memory[213] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// b = mem[sp]
		  `MC_W_B;
memory[214] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// a = a / b   DON'T COMBINE MULTICYCLE ALU
		  `MC_ALU_DIV | `MC_W_A;										// OPERATIONS WITH MEMORY READ/WRITE
memory[215] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
memory[212] = `MC_GO_BREAKPOINT;
`endif

// 001_10110 (36) mod   -------------------------------------
`ifdef ENABLE_DIV
//	mem[sp+1] = mem[sp+1] % mem[sp]
//	sp = sp + 1
memory[216] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |			// a = mem[sp] || sp=sp+1
		 `MC_W_A_MEM | `MC_SP_PLUS_4;
memory[217] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |			// b = mem[sp]
		  `MC_W_B;
memory[218] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// a = a % b   DON'T COMBINE MULTICYCLE ALU
		  `MC_ALU_MOD | `MC_W_A;										// OPERATIONS WITH MEMORY READ/WRITE
memory[219] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
memory[216] = `MC_GO_BREAKPOINT;
`endif

// 001_10111 (37) eqbranch   -------------------------------------
//	a = sp + 1
//	a = mem[a]
//	a = mem[sp] || a == 0 ? { pc = pc + a; sp = sp + 2 }
//	else { sp = sp + 2, pc = pc + 1 }
memory[220] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR |	// a = sp + 1
		  `MC_ALU_PLUS | `MC_SEL_ALU_MC_CONST | (4 << `P_ADDR) |
		  `MC_W_A;
memory[221] = `MC_SEL_ADDR_A | `MC_MEM_R | `MC_W_A;						// a = mem[a]
memory[222] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A |					// a = mem[sp] || a == 0 ? goto 456 (sp=sp+2, pc=pc+a)
		 `MC_BRANCHIF_A_ZERO | ((456>>2) << `P_ADDR);
memory[223] = `MC_BRANCH | ((460>>2) << `P_ADDR);						// else goto 460 (sp=sp+2, pc=pc+1)

// 001_11000 (38) neqbranch   -------------------------------------
//	a = sp + 1
//	a = mem[a]
//	a = mem[sp] || a == 0 ? { sp = sp + 2, pc = pc + 1 }
//	else { sp = sp + 2, pc = pc + a }
memory[224] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR |	// a = sp + 1
		  `MC_ALU_PLUS | `MC_SEL_ALU_MC_CONST | (4 << `P_ADDR) | 
		  `MC_W_A;				
memory[225] = `MC_SEL_ADDR_A | `MC_MEM_R | `MC_W_A;						// a = mem[a]
memory[226] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A | 					// a = mem[sp] || a == 0 ? goto 460 (sp=sp+2, pc=pc+1)
		 `MC_BRANCHIF_A_ZERO | ((460>>2) << `P_ADDR);	
memory[227] = `MC_BRANCH | ((456>>2) << `P_ADDR);						// else goto 456 (sp=sp+2, pc=pc+a)

// 001_11001 (39) poppcrel   -------------------------------------
//	a = mem[sp]
//	sp = sp + 1
//	pc = pc + a
memory[228] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R |			// a=mem[sp] || sp=sp+1
		 `MC_W_A_MEM | `MC_SP_PLUS_4; 
memory[229] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_SEL_ALU_A |		// pc = pc + a
		 `MC_ALU_PLUS | `MC_W_PC; 
memory[230] = `MC_FETCH;												// op_cached? decode : goto next

// 001_11010 (3a) config   -------------------------------------
memory[232] = `MC_GO_BREAKPOINT;

// 001_11011 (3b) pushpc   -------------------------------------
//	sp = sp - 1
//	mem[sp] = pc
memory[236] = `MC_CLEAR_IDIM | `MC_SP_MINUS_4 | `MC_W_A; 				// a = sp = sp - 1
memory[237] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a

// 001_11100 (3c) syscall_emulate  ------------------------------
memory[240] = `MC_GO_BREAKPOINT;

// 001_11101 (3d) pushspadd   -------------------------------------
//	a = mem[sp] << 2
//	mem[sp] = a + sp
`ifdef ENABLE_BARREL
memory[244] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | 			// a = mem[sp]
		`MC_W_A_MEM;
memory[245] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_BARREL |		// a = a << 2 (left,arithmetic->10_00010)
		`MC_SEL_ALU_MC_CONST | ( 66 << `P_ADDR) | `MC_W_A;
memory[246] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_SEL_ALU_A |		// a = a + sp
		 `MC_ALU_PLUS | `MC_W_A; 
memory[247] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
memory[244] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM; // a = mem[sp]
memory[245] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_A |		// a = a + a
		`MC_ALU_PLUS | `MC_W_A;
memory[246] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_SEL_ALU_A |		// a = a + a
		`MC_ALU_PLUS | `MC_W_A;
memory[247] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_SEL_ALU_A |		// a = a + sp || goto @cont (->mem[sp] = a)
		 `MC_ALU_PLUS | `MC_W_A | ((400>>2) << `P_ADDR) | `MC_BRANCH;
`endif

// 001_11110 (3e) halfmult   -------------------------------------
memory[248] = `MC_GO_BREAKPOINT;

// 001_11111 (3f) callpcrel   -------------------------------------
//	a = mem[sp]
//	mem[sp]=pc+1
//	pc = pc + a
memory[252] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | 	// b = mem[sp]
		`MC_MEM_R | `MC_W_B; 
memory[253] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a = pc + 1
		`MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;				
memory[254] = `MC_SEL_ADDR_SP | `MC_MEM_W; 								// mem[sp] = a;
memory[255] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_SEL_ALU_B |		// pc = pc + b, goto @fetch
		 `MC_ALU_PLUS | `MC_W_PC | `MC_GO_FETCH;

// --------------------- MICROCODE HOLE -----------------------------------




// --------------------- CONTINUATION OF COMPLEX OPCODES ------------------

`ifdef ENABLE_BYTE_SELECT
// ipsum_end: ----------
memory[392] = `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST | (0 << `P_ADDR) |	// sp=0
		`MC_W_SP;
memory[393] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA |			// pc=mem[sp]	restore next pc
		`MC_W_PC;
memory[394] = `MC_SP_PLUS_4;											// sp=sp+4
memory[395] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_SEL_READ_DATA |			// sp=mem[sp]	restore sp
		`MC_W_SP;
memory[396] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_W_A;				// a=b (sum)
memory[397] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_FETCH;					// mem[sp]=a || fetch (return sum)
`endif

`ifndef ENABLE_BYTE_SELECT
// loadb continued microcode -----
// mem[sp]=a || pc=b
// opcode_cache=mem[pc] || go next
memory[396] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_SEL_ALU_B |				// mem[sp]=a || pc=b
		`MC_ALU_NOP_B | `MC_W_PC;
memory[397] = `MC_SEL_ADDR_PC | `MC_MEM_R | `MC_W_OPCODE | `MC_GO_NEXT;	// opcode_cache=mem[pc] || go next		
`endif

// sub/pushspadd continued microcode ----------------
memory[400] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a

// ----- hole ------

`ifdef ENABLE_BYTE_SELECT
// ipsum_continue2: ------------
memory[408] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// pc=pc-1; a=pc
		`MC_SEL_ALU_MC_CONST | ((-1 & 127) << `P_ADDR) | `MC_W_PC |
		`MC_W_A;
memory[409] = `MC_BRANCH | ((124 >> 2) << `P_ADDR);						// goto @ipsum_loop
`endif

// neqcheck ----------
memory[412] = `MC_BRANCHIF_A_ZERO | ((468 >> 2) << `P_ADDR);				// a == 0 ? goto @set_mem[sp]=0
memory[413] = `MC_BRANCH | ((464 >> 2) << `P_ADDR);						// else goto @set_mem[sp]=1

// eqcheck ----------
memory[416] = `MC_BRANCHIF_A_ZERO | ((464 >> 2) << `P_ADDR);				// a == 0 ? goto @set_mem[sp]=1
memory[417] = `MC_BRANCH | ((468 >> 2) << `P_ADDR);						// else goto @set_mem[sp]=0

// lessthanorequal_check ----
memory[420] = `MC_BRANCHIF_A_ZERO | `MC_BRANCHIF_A_NEG | ((464 >> 2) << `P_ADDR); 	// a <= 0 ? goto @set_mem[sp]=1
memory[421] = `MC_BRANCH | ((468 >> 2) << `P_ADDR);						// else goto @set_mem[sp]=0

// lessthan_check ----
memory[424] = `MC_BRANCHIF_A_NEG | ((464 >> 2) << `P_ADDR);					// a < 0 ? goto @set_mem[sp]=1
memory[425] = `MC_BRANCH | ((468 >> 2) << `P_ADDR);						// else goto @set_mem[sp]=0

// xor_cont continued microcode -----------------------------------
`ifndef ENABLE_XOR
memory[428] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_OR |			// a = a | b --> a = ~A&B | A&~B
		`MC_SEL_ALU_B | `MC_W_A;
memory[429] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`endif

// ashiftright_loop continued microcode -----------------------------------
`ifdef ENABLE_BARREL
memory[432] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_BARREL |		// a = a {<<|>>} b
		`MC_SEL_ALU_B | `MC_W_A;
memory[433] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`else
 `ifdef ENABLE_A_SHIFT
memory[432] = `MC_BRANCHIF_A_ZERO | `MC_BRANCHIF_A_NEG | ((436 >> 2) << `P_ADDR); // (a <= 0) ? goto @ashiftright_exit
memory[433] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a = a + (-1)
		`MC_SEL_ALU_MC_CONST | ( (-1 & 127) << `P_ADDR) | `MC_W_A;
memory[434] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_PLUS | 		// b = b signed_<< 1 || goto @ashiftright_loop
		`MC_SEL_ALU_B | `MC_W_B | `MC_BRANCH | ((432 >>2) << `P_ADDR);
// ashiftright_exit
memory[436] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_FLIP |		// a = FLIP(b)
		`MC_W_A;
memory[437] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
 `endif
`endif

// ashiftleft_loop continued microcode -----------------------------------
`ifndef ENABLE_BARREL
memory[440] = `MC_BRANCHIF_A_ZERO | `MC_BRANCHIF_A_NEG | ((444 >> 2) << `P_ADDR);// (a <= 0) ? goto @ashiftleft_exit
memory[441] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a = a + (-1)
		`MC_SEL_ALU_MC_CONST | ( (-1 & 127) << `P_ADDR) | `MC_W_A;
memory[442] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// b = b << 1 || goto @ashiftleft_loop
		`MC_SEL_ALU_B | `MC_W_B | `MC_BRANCH | ((440 >>2) << `P_ADDR);
// ashiftleft_exit
memory[444] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_NOP |		// a = b
		`MC_W_A;
memory[445] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`endif

// lshiftright_loop continued microcode -----------------------------------
`ifdef ENABLE_A_SHIFT
memory[448] = `MC_BRANCHIF_A_ZERO | `MC_BRANCHIF_A_NEG | ((452 >> 2) << `P_ADDR);// (a <= 0) ? goto @lshiftright_exit
memory[449] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a = a + (-1)
		`MC_SEL_ALU_MC_CONST | ( (-1 & 127) << `P_ADDR) | `MC_W_A;
memory[450] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// b = b << 1 || goto @lshiftright_loop
		`MC_SEL_ALU_B | `MC_W_B | `MC_BRANCH | ((448 >>2) << `P_ADDR);
// lshiftright_exit
memory[452] = `MC_SEL_ADDR_B | `MC_SEL_READ_ADDR | `MC_ALU_FLIP |		// a = FLIP(b)
		`MC_W_A;
memory[453] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a
`endif

// neqbranch / eqbranch --- continued microcode   -------------------------------------
//	sp = sp + 2
// 	pc = pc + a
memory[456] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_ALU_PLUS | 		// sp = sp + 2
		`MC_SEL_ALU_MC_CONST | (8 << `P_ADDR) | `MC_W_SP;				
memory[457] = `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR | `MC_SEL_ALU_A |		// pc = pc + a
		 `MC_ALU_PLUS | `MC_W_PC; 
memory[458] = `MC_FETCH;												// op_cached? decode : goto fetch

// neqbranch / eqbranch  --- continued microcode   -------------------------------------
//	sp = sp + 2
//  pc = pc + 1
memory[460] = `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR | `MC_ALU_PLUS | 		// sp = sp + 2
		`MC_SEL_ALU_MC_CONST | (8 << `P_ADDR) | `MC_W_SP; 				
memory[461] = `MC_PC_PLUS_1;											// pc = pc + 1
memory[462] = `MC_FETCH;												// op_cached? decode : goto fetch

// neq / eq / lessthan_1 --- continued microcode   --------------------
// 	mem[sp] = 1
memory[464] = `MC_SEL_ALU_MC_CONST | `MC_ALU_NOP_B | (1 << `P_ADDR) |	// a = 1
		 `MC_W_A; 
memory[465] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a

// neq / eq / lessthan_0 --- continued microcode   --------------------
//	mem[sp] = 0
memory[468] = `MC_SEL_ALU_MC_CONST | `MC_ALU_NOP_B | (0 << `P_ADDR) |	// a = 0
		 `MC_W_A; 
memory[469] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a

// MICROCODE ENTRY POINT AFTER RESET   -------------------------------
// initialize cpu registers
//	sp = @SP_START
//	pc = @RESET_VECTOR
memory[473] = 0; 														// reserved and empty for correct cpu startup
memory[474] = `MC_CLEAR_IDIM |`MC_SEL_ALU_MC_CONST | `MC_ALU_NOP_B | 	// sp = @SP_START
		(`SP_START << `P_ADDR) | `MC_W_SP;
memory[475] = `MC_SEL_ALU_MC_CONST | `MC_ALU_NOP_B | `MC_W_PC |			// pc = @RESET
		(`RESET_VECTOR << `P_ADDR) | `MC_EXIT_INTERRUPT;				// enable interrupts on reset
// fall throught fetch/decode

// FETCH / DECODE   -------------------------------------
//	opcode=mem[pc]
//	decode (goto microcode entry point for opcode)
memory[476] = `MC_SEL_ADDR_PC | `MC_SEL_READ_DATA | `MC_MEM_R |			// opcode_cache = mem[pc]
		 `MC_W_OPCODE; 
memory[477] = `MC_DECODE;												// decode jump to microcode

// NEXT OPCODE   -------------------------------------
//	pc = pc + 1
//  opcode cached ? decode : goto fetch
memory[480] = `MC_PC_PLUS_1;											// pc = pc + 1
memory[481] = `MC_FETCH;												// pc_cached ? decode else fetch,decode

// INTERRUPT REQUEST   -------------------------------------
//	sp = sp - 1
//	mem[sp] = pc
//	pc = mem[EMULATED_VECTORS + 0]
memory[484] = `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST | (0 << `P_ADDR) |	// b = 0 (#0 in emulate table) || disable interrupts
		`MC_W_B | `MC_ENTER_INTERRUPT;
memory[485] = `MC_EMULATE;												// emulate #0 (interrupt)

// ---------------- OPCODES WITH PARAMETER IN OPCODE ----------------

// im x (idim=0)	1_xxxxxxx   -------------------------------------
//	sp = sp - 1
//	mem[sp] = IMM(IDIM, opcode)
//	idim = 1
memory[488] = `MC_SP_MINUS_4;											// sp = sp - 1
memory[489] = `MC_SEL_ALU_OPCODE | `MC_ALU_IM | `MC_W_A;				// a = IMM(IDIM, opcode)
memory[490] = `MC_SET_IDIM | `MC_SEL_ADDR_SP | `MC_MEM_W |				// MEM[sp] = a; IDIM=1
	 `MC_GO_NEXT;

// 1_xxxxxxx im x (idim=1)	   -------------------------------------
//	mem[sp] = IMM(IDIM, mem[sp], opcode)
memory[491] = `MC_SET_IDIM | `MC_SEL_READ_DATA | `MC_SEL_ADDR_SP |		// a = IMM(IDIM, MEM[sp], opcode)
		 `MC_MEM_R | `MC_SEL_ALU_OPCODE | `MC_ALU_IM | `MC_W_A; 		
memory[492] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// MEM[sp] = a

// 010_xxxxx storesp x	
//	mem[sp + x<<2] = mem[sp]
//	sp = sp + 1
memory[493] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR |	// b = sp + offset
		 `MC_ALU_PLUS_OFFSET | `MC_SEL_ALU_OPCODE | `MC_W_B;		
memory[494] = `MC_SEL_ADDR_SP | `MC_MEM_R | `MC_W_A_MEM |				// a=mem[sp] || sp=sp+1
		 `MC_SP_PLUS_4; 
memory[495] = `MC_SEL_ADDR_B | `MC_MEM_W | `MC_GO_NEXT;					// mem[b] = a

// 011_xxxxx loadsp x	   -------------------------------------
//	mem[sp-1] = mem [sp + x<<2]
//	sp = sp - 1
memory[496] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR |	// a = sp + offset
		 `MC_ALU_PLUS_OFFSET | `MC_SEL_ALU_OPCODE | `MC_W_A; 			
memory[497] = `MC_SEL_ADDR_A | `MC_SEL_READ_DATA | `MC_MEM_R | `MC_W_A; // a = mem[a]
memory[498] = `MC_SP_MINUS_4;								 			// sp = sp - 1
memory[499] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a

// 0001_xxxx addsp x	   -------------------------------------
// 	mem[sp] = mem[sp] + mem[sp + x<<2]
memory[500] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_SP | `MC_SEL_READ_ADDR |	// a = sp + offset
		 `MC_ALU_PLUS_OFFSET | `MC_SEL_ALU_OPCODE | `MC_W_A; 			
memory[501] = `MC_SEL_ADDR_A | `MC_SEL_READ_DATA | `MC_MEM_R | `MC_W_A; // a = mem[a]
memory[502] = `MC_SEL_ADDR_SP | `MC_SEL_READ_DATA | `MC_MEM_R |
		 `MC_ALU_PLUS | `MC_SEL_ALU_A | `MC_W_A; 						// a = a + mem[sp]
memory[503] = `MC_SEL_ADDR_SP | `MC_MEM_W | `MC_GO_NEXT;				// mem[sp] = a

// 001_xxxxx emulate x	   -------------------------------------
//  <expects b = offset into table for emulated opcode>
//	sp = sp - 1
//	mem[sp] = pc + 1				emulated opcode microcode must set b to
//  a=@EMULATION_TABLE				offset inside emulated_table prior to
//  pc = mem[a + b]					calling the emulate microcode
//  fetch
memory[504] = `MC_CLEAR_IDIM | `MC_SEL_ADDR_PC | `MC_SEL_READ_ADDR |	// a = pc + 1
		`MC_ALU_PLUS | `MC_SEL_ALU_MC_CONST | (1 << `P_ADDR) | `MC_W_A;
memory[505] = `MC_SP_MINUS_4;											// sp = sp - 1
memory[506] = `MC_SEL_ADDR_SP | `MC_MEM_W;								// mem[sp] = a
memory[507] = `MC_ALU_NOP_B | `MC_SEL_ALU_MC_CONST | `MC_W_A | 			// a = @vector_emulated
		(`EMULATION_VECTOR << `P_ADDR);
memory[508] = `MC_SEL_ADDR_A | `MC_SEL_READ_ADDR | `MC_ALU_PLUS |		// a = a + b
		`MC_SEL_ALU_B | `MC_W_A;
memory[509] = `MC_SEL_ADDR_A | `MC_MEM_R | `MC_SEL_READ_DATA | 			// pc = mem[a]
		`MC_ALU_NOP | `MC_W_PC;
memory[510] = `MC_FETCH;

// --------------------- END OF MICROCODE PROGRAM --------------------------
end

endmodule
