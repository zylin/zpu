`timescale 1ns / 1ps
`include "zpu_core_defines.v"

/*      MODULE: zpu_core
        DESCRIPTION: Contains ZPU cpu
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

// --------- MICROPROGRAMMED ZPU CORE ---------------
// all signals are polled on clk rising edge
// all signals positive

module zpu_core (
`ifdef ENABLE_CPU_INTERRUPTS
	interrupt,		// interrupt request
`endif	
	clk,			// clock on rising edge
	reset,			// reset on rising edge
	mem_read,		// request memory read
	mem_write,		// request memory write
	mem_done,		// memory operation completed
	mem_addr,		// memory address
	mem_data_read,	// data readed
	mem_data_write,	// data written
	byte_select		// byte select on memory operation
);

input			clk;
input			reset;
output			mem_read;
output			mem_write;
input			mem_done;
input  [31:0]	mem_data_read;
output [31:0] 	mem_data_write;
output [31:0]	mem_addr;
output [3:0]	byte_select;
`ifdef ENABLE_CPU_INTERRUPTS
input			interrupt;
`endif

wire 		clk;
wire		reset;
wire		mem_read;
wire		mem_write;
wire		mem_done;
wire [31:0]	mem_data_read;
wire [31:0] mem_data_write;
wire [31:0]	mem_addr;
`ifdef ENABLE_CPU_INTERRUPTS
wire		interrupt;
`endif

`ifdef ENABLE_BYTE_SELECT
// ------ unaligned byte/halfword memory operations -----
/// TODO: think rewriting into microcode or in a less resource wasting way

reg  [3:0]	byte_select;
wire		byte_op;
wire		halfw_op;

reg  [31:0]	mem_data_read_int;	// aligned data from memory
reg  [31:0] mem_data_write_out;	// write data already aligned
wire [31:0] mem_data_write_int;	// write data from cpu to be aligned

// --- byte select logic ---
always @(mem_addr[1:0] or byte_op or halfw_op)
begin
  casez( { mem_addr[1:0], byte_op, halfw_op } )
    4'b00_1_? : byte_select <= 4'b0001;		// byte select
    4'b01_1_? : byte_select <= 4'b0010;
    4'b10_1_? : byte_select <= 4'b0100;
    4'b11_1_? : byte_select <= 4'b1000;
    4'b0?_0_1 : byte_select <= 4'b0011;		// half word select
    4'b1?_0_1 : byte_select <= 4'b1100;
    default   : byte_select <= 4'b1111;		// word select
  endcase
end

// --- input data to cpu ---
always @(mem_data_read or mem_addr[1:0] or byte_op or halfw_op)
begin
  casez( { mem_addr[1:0], byte_op, halfw_op } )
   4'b00_1_? : mem_data_read_int <= { 24'b0, mem_data_read[7:0] };	// 8 bit read
   4'b01_1_? : mem_data_read_int <= { 24'b0, mem_data_read[15:8] };
   4'b10_1_? : mem_data_read_int <= { 24'b0, mem_data_read[23:16] };
   4'b11_1_? : mem_data_read_int <= { 24'b0, mem_data_read[31:24] };
   4'b0?_0_1 : mem_data_read_int <= { 16'b0, mem_data_read[7:0], mem_data_read[15:8] };	// 16 bit read
   4'b1?_0_1 : mem_data_read_int <= { 16'b0, mem_data_read[23:16], mem_data_read[31:24] };
   default   : mem_data_read_int <= { mem_data_read[7:0], mem_data_read[15:8], mem_data_read[23:16], mem_data_read[31:24] };	// 32 bit access (default)
  endcase
end

// --- output data from cpu ---
assign mem_data_write = mem_data_write_out;

always @(mem_data_write_int or mem_addr[1:0] or byte_op or halfw_op)
begin
  casez( {mem_addr[1:0], byte_op, halfw_op } )
    4'b00_1_? : mem_data_write_out <= { 24'bX, mem_data_write_int[7:0] };		// 8 bit write
    4'b01_1_? : mem_data_write_out <= { 16'bX, mem_data_write_int[7:0], 8'bX };
    4'b10_1_? : mem_data_write_out <= { 8'bX, mem_data_write_int[7:0], 16'bX };
    4'b11_1_? : mem_data_write_out <= { mem_data_write_int[7:0], 24'bX };
    4'b0?_0_1 : mem_data_write_out <= { 16'bX, mem_data_write_int[7:0], mem_data_write_int[15:8] };		// 16 bit write
    4'b1?_0_1 : mem_data_write_out <= { mem_data_write_int[7:0], mem_data_write_int[15:8], 16'bX };
    default   : mem_data_write_out <= { mem_data_write_int[7:0], mem_data_write_int[15:8], mem_data_write_int[23:16], mem_data_write_int[31:24] };
  endcase
end
`else
// -------- only 32 bit memory access --------
wire [3:0]	byte_select = 4'b1111;			// all memory operations are 32 bit wide
wire [31:0] mem_data_read_int;				// no byte/halfword memory access by HW
wire [31:0] mem_data_write_int;				// byte and halfword memory access must be emulated

// ----- reorder bytes due to MSB-LSB configuration -----
assign mem_data_read_int = { mem_data_read[7:0], mem_data_read[15:8], mem_data_read[23:16], mem_data_read[31:24] };
assign mem_data_write = { mem_data_write_int[7:0], mem_data_write_int[15:8], mem_data_write_int[23:16], mem_data_write_int[31:24] };
`endif

// ------ datapath registers and connections -----------
reg  [31:0]	pc;				// program counter (byte align)
reg  [31:0] sp;				// stack counter (word align)
reg  [31:0]	a;				// operand (address_out, data_out, alu_in)
reg  [31:0]	b;				// operand (address_out)
reg			idim;			// im opcode being processed
reg   [7:0]	opcode;			// opcode being processed
reg  [31:2]	pc_cached;		// cached PC
reg  [31:0]	opcode_cache;	// cached opcodes (current word)
`ifdef ENABLE_CPU_INTERRUPTS
  reg		int_requested;	// interrupt has been requested
  reg		on_interrupt;	// serving interrupt
  wire		exit_interrupt;	// microcode says this is poppc_interrupt
  wire		enter_interrupt; // microcode says we are entering interrupt
`endif
wire  [1:0]	sel_opcode = pc[1:0]; 	// which opcode is selected
wire  		sel_read;		// mux for data-in
wire  [1:0]	sel_alu;		// mux for alu
wire  [1:0]	sel_addr;		// mux for addr
wire		w_pc;			// write PC
`ifdef ENABLE_PC_INCREMENT
  wire		w_pc_increment;	// write PC+1
`endif
wire		w_sp;			// write SP
wire		w_a;			// write A (from ALU result)
wire		w_a_mem;		// write A (from MEM read)
wire		w_b;			// write B
wire		w_op;			// write OPCODE (opcode cache)
wire		set_idim;		// set IDIM
wire		clear_idim;		// clear IDIM
wire		is_op_cached = (pc[31:2] == pc_cached) ? 1'b1 : 1'b0;	// is opcode available?
wire		a_is_zero;		// A == 0
wire		a_is_neg;		// A[31] == 1
wire		busy;			// busy signal to microcode sequencer (stalls cpu)

reg [`MC_MEM_BITS-1:0] 	mc_pc;		// microcode PC
initial mc_pc <= `MC_ADDR_RESET-1;
wire    [`MC_BITS-1:0]	mc_op;		// current microcode operation

// memory addr / write ports
assign mem_addr = (sel_addr == `SEL_ADDR_SP) ? sp :
			      (sel_addr == `SEL_ADDR_A)  ? a  : 
			   	  (sel_addr == `SEL_ADDR_B)  ? b  : pc;
assign mem_data_write_int = a;			// only A can be written to memory

// ------- alu instantiation -------
wire [31:0]					alu_a;
wire [31:0]					alu_b;
wire [31:0]					alu_r;
wire [`ALU_OP_WIDTH-1:0]	alu_op;
wire						alu_done;

// alu inputs multiplexors
// constant in microcode is sign extended (in order to implement substractions like adds)
assign alu_a = 	(sel_read == `SEL_READ_DATA)   ? mem_data_read_int : mem_addr;
assign alu_b = 	(sel_alu == `SEL_ALU_MC_CONST) ? { {25{mc_op[`P_ADDR+6]}} , mc_op[`P_ADDR+6:`P_ADDR] } :	// most priority
				(sel_alu == `SEL_ALU_A)		   ? a :
				(sel_alu == `SEL_ALU_B)	       ? b : { {24{1'b0}} , opcode };	// `SEL_ALU_OPCODE is less priority

zpu_core_alu alu(
	.alu_a(alu_a),
	.alu_b(alu_b),
	.alu_r(alu_r),
	.alu_op(alu_op),
	.flag_idim(idim),
	.clk(clk),
	.done(alu_done)
);

// -------- pc : program counter --------
always @(posedge clk)
begin
  if(w_pc)  pc <= alu_r;
`ifdef ENABLE_PC_INCREMENT		// microcode optimization
  else if(w_pc_increment) pc <= pc + 1;  // usually pc=pc+1
`endif
end

// -------- sp : stack pointer --------
always @(posedge clk)
begin
  if(w_sp) sp <= alu_r;
end

// -------- a : acumulator register ---------
always @(posedge clk)
begin
  if(w_a) 		   a <= alu_r;
  else if(w_a_mem) a <= mem_data_read_int;
end

// alu results over a register instead of alu result
// in order to improve speed
assign a_is_zero = (a == 0);
assign a_is_neg  = a[31];

// -------- b : auxiliary register ---------
always @(posedge clk)
begin
  if(w_b)	b <= alu_r;
end

// -------- opcode and opcode_cache  --------
always @(posedge clk)
begin
  if(w_op)
  begin
    opcode_cache <= alu_r;		// store all opcodes in the word
    pc_cached <= pc[31:2];		// store PC address of cached opcodes
  end
end

// -------- opcode : based on pc[1:0] ---------
always @(sel_opcode or opcode_cache)	// select current opcode from 
begin					// the cached opcode word
    case(sel_opcode)
	0 : opcode <= opcode_cache[31:24];
	1 : opcode <= opcode_cache[23:16];
	2 : opcode <= opcode_cache[15:8];
	3 : opcode <= opcode_cache[7:0];
    endcase
end

// ------- idim : immediate opcode handling  ----------
always @(posedge clk)
begin
  if(set_idim)   	  idim <= 1'b1;
  else if(clear_idim) idim <= 1'b0;
end

`ifdef ENABLE_CPU_INTERRUPTS
// ------ on interrupt status bit -----
always @(posedge clk)
begin
  if(reset | exit_interrupt) on_interrupt <= 1'b0;
  else if(enter_interrupt)	 on_interrupt <= 1'b1;
end
`endif

// ------ microcode execution unit --------
assign sel_read  = mc_op[`P_SEL_READ];	// map datapath signals with microcode program bits
assign sel_alu   = mc_op[`P_SEL_ALU+1:`P_SEL_ALU];
assign sel_addr  = mc_op[`P_SEL_ADDR+1:`P_SEL_ADDR];
assign alu_op    = mc_op[`P_ALU+3:`P_ALU];
assign w_sp      = mc_op[`P_W_SP] & ~busy;
assign w_pc      = mc_op[`P_W_PC] & ~busy;
assign w_a       = mc_op[`P_W_A] & ~busy;
assign w_a_mem   = mc_op[`P_W_A_MEM] & ~busy;
assign w_b	 	 = mc_op[`P_W_B] & ~busy;
assign w_op      = mc_op[`P_W_OPCODE] & ~busy;
assign mem_read  = mc_op[`P_MEM_R];
assign mem_write = mc_op[`P_MEM_W];
assign set_idim  = mc_op[`P_SET_IDIM] & ~busy;
assign clear_idim= mc_op[`P_CLEAR_IDIM] & ~busy;
`ifdef ENABLE_BYTE_SELECT
assign byte_op	 = mc_op[`P_BYTE];
assign halfw_op  = mc_op[`P_HALFWORD];
`endif
`ifdef ENABLE_PC_INCREMENT
  assign w_pc_increment = mc_op[`P_PC_INCREMENT] & ~busy;
`endif
`ifdef ENABLE_CPU_INTERRUPTS
  assign exit_interrupt  = mc_op[`P_EXIT_INT]  & ~busy;
  assign enter_interrupt = mc_op[`P_ENTER_INT] & ~busy;
`endif

wire   cond_op_not_cached = mc_op[`P_OP_NOT_CACHED];	// conditional: true if opcode not cached
wire   cond_a_zero 	  	  = mc_op[`P_A_ZERO];			// conditional: true if A is zero
wire   cond_a_neg 	  	  = mc_op[`P_A_NEG];			// conditional: true if A is negative
wire   decode 		  	  = mc_op[`P_DECODE];			// decode means jumps to apropiate microcode based on zpu opcode
wire   branch 		  	  = mc_op[`P_BRANCH];			// unconditional jump inside microcode

wire [`MC_MEM_BITS-1:0]	mc_goto  = { mc_op[`P_ADDR+6:`P_ADDR], 2'b00 };	// microcode goto (goto = high 7 bits)
wire [`MC_MEM_BITS-1:0] mc_entry = { opcode[6:0], 2'b00 };				// microcode entry point for opcode
reg  [`MC_MEM_BITS-1:0] next_mc_pc;										// next microcode operation to be executed
initial next_mc_pc <= `MC_ADDR_RESET-1;

wire cond_branch = (cond_op_not_cached & ~is_op_cached) |		// sum of all conditionals
				   (cond_a_zero & a_is_zero) |
				   (cond_a_neg & a_is_neg);

assign busy = ((mem_read | mem_write) & ~mem_done) | ~alu_done;	// busy signal for microcode sequencer

// ------- handle interrupts ---------
`ifdef ENABLE_CPU_INTERRUPTS
always @(posedge clk)
begin
  if(reset | on_interrupt) int_requested <= 0;
  else if(interrupt & ~on_interrupt & ~int_requested) int_requested <= 1;	// interrupt requested
end
`endif

// ----- calculate next microcode address (next, decode, branch, specific opcode, etc.) -----
always @(reset or mc_pc or mc_goto or opcode[7:4] or idim or 
	     decode or branch or cond_branch or mc_entry or busy
`ifdef ENABLE_CPU_INTERRUPTS
	     or int_requested
`endif
)
begin
  // default, next microcode instruction
  next_mc_pc  <= mc_pc + 1;
  if(reset)								  next_mc_pc <= `MC_ADDR_RESET;
  else if(~busy)
  begin
    // get next microcode instruction
    if(branch | cond_branch) 			  next_mc_pc <= mc_goto;
    else if(decode)						  // decode: entry point of a new zpu opcode
    begin
`ifdef ENABLE_CPU_INTERRUPTS
      if(int_requested & ~idim)			  next_mc_pc <= `MC_ADDR_INTERRUPT;	// microde to enter interrupt mode
      else
`endif
      if(opcode[7]        == `OP_IM) 	  next_mc_pc <= (idim ? `MC_ADDR_IM_IDIM : `MC_ADDR_IM_NOIDIM);
      else if(opcode[7:5] == `OP_STORESP) next_mc_pc <= `MC_ADDR_STORESP;
      else if(opcode[7:5] == `OP_LOADSP)  next_mc_pc <= `MC_ADDR_LOADSP;
      else if(opcode[7:4] == `OP_ADDSP)   next_mc_pc <= `MC_ADDR_ADDSP;
      else				  				  next_mc_pc <= mc_entry;	// includes EMULATE opcodes
    end
  end
  else next_mc_pc <= mc_pc;		// in case of cpu stalled (busy=1)
end

// set microcode program counter
always @(posedge clk) mc_pc <= next_mc_pc;

// ----- microcode program ------
zpu_core_rom microcode (
	.addr(next_mc_pc),
	.data(mc_op),
	.clk(clk)
);

// -------------- ZPU debugger --------------------
`ifdef ZPU_CORE_DEBUG
//synthesis translate_off
// ---- register operation dump ----
always @(posedge clk)
begin
  if(~reset)
  begin
    if(w_pc) $display("zpu_core: set PC=0x%h", alu.alu_r);
`ifdef ENABLE_PC_INCREMENT
    if(w_pc_increment) $display("zpu_core: set PC=0x%h (PC+1)", pc);
`endif
    if(w_sp) $display("zpu_core: set SP=0x%h", alu.alu_r);
    if(w_a) $display("zpu_core: set A=0x%h", alu.alu_r);
    if(w_a_mem) $display("zpu_core: set A=0x%h (from MEM)", mem_data_read_int);
    if(w_b)  $display("zpu_core: set B=0x%h", alu.alu_r);
    if(w_op & ~is_op_cached) $display("zpu_core: set opcode_cache=0x%h, pc_cached=0x%h", alu.alu_r, {pc[31:2], 2'b0});
`ifdef ENABLE_CPU_INTERRUPTS
    if(~busy & mc_pc == `MC_ADDR_INTERRUPT) $display("zpu_core: ***** ENTERING INTERRUPT MICROCODE ******"); 
    if(~busy & exit_interrupt)  $display("zpu_core: ***** INTERRUPT FLAG CLEARED *****");
    if(~busy & enter_interrupt) $display("zpu_core: ***** INTERRUPT FLAG SET *****");    
`endif
    if(set_idim & ~idim) $display("zpu_core: IDIM=1");
    if(clear_idim & idim) $display("zpu_core: IDIM=0");

// ---- microcode debug ----
`ifdef ZPU_CORE_DEBUG_MICROCODE
    if(~busy)
    begin
      $display("zpu_core: mc_op[%d]=0b%b", mc_pc, mc_op);
      if(branch)      $display("zpu_core: microcode: branch=%d", mc_goto);
      if(cond_branch) $display("zpu_core: microcode: CONDITION branch=%d", mc_goto);
      if(decode)      $display("zpu_core: decoding opcode=0x%h (0b%b) : branch to=%d ", opcode, opcode, mc_entry);
    end
    else $display("zpu_core: busy");
`endif

// ---- cpu abort in case of unaligned memory access ---
`ifdef ASSERT_NON_ALIGNMENT
  /* unaligned word access (except PC) */
  if(sel_addr != `SEL_ADDR_PC & mem_addr[1:0] != 2'b00 & (mem_read | mem_write) & !byte_op & !halfw_op)
  begin
    $display("zpu_core: unaligned word operation at addr=0x%x", mem_addr);
    $finish;
  end
  
  /* unaligned halfword access */
  if(mem_addr[0] & (mem_read | mem_write) & !byte_op & halfw_op)
  begin
    $display("zpu_core: unaligned halfword operation at addr=0x%x", mem_addr);
    $finish;
  end
`endif

  end
end

// ----- opcode dissasembler ------
always @(posedge clk)
begin
if(~busy)
case(mc_pc)
0 : begin
	 $display("zpu_core: ------  breakpoint ------");
	 $finish;
	end
4 : $display("zpu_core: ------  shiftleft ------");
8 : $display("zpu_core: ------  pushsp ------");
12 : $display("zpu_core: ------  popint ------");
16 : $display("zpu_core: ------  poppc ------");
20 : $display("zpu_core: ------  add ------");
24 : $display("zpu_core: ------  and ------");
28 : $display("zpu_core: ------  or ------");
32 : $display("zpu_core: ------  load ------");
36 : $display("zpu_core: ------  not ------");
40 : $display("zpu_core: ------  flip ------");
44 : $display("zpu_core: ------  nop ------");
48 : $display("zpu_core: ------  store ------");
52 : $display("zpu_core: ------  popsp ------");
56 : $display("zpu_core: ------  ipsum ------");
60 : $display("zpu_core: ------  sncpy ------");

`MC_ADDR_IM_NOIDIM : $display("zpu_core: ------  im 0x%h (1st) ------", opcode[6:0] );
`MC_ADDR_IM_IDIM   : $display("zpu_core: ------  im 0x%h (cont) ------", opcode[6:0] );
`MC_ADDR_STORESP   : $display("zpu_core: ------  storesp 0x%h ------", { ~opcode[4], opcode[3:0], 2'b0 } );
`MC_ADDR_LOADSP    : $display("zpu_core: ------  loadsp 0x%h ------", { ~opcode[4], opcode[3:0], 2'b0 } );
`MC_ADDR_ADDSP     : $display("zpu_core: ------  addsp 0x%h ------", { ~opcode[4], opcode[3:0], 2'b0 } );
`MC_ADDR_EMULATE   : $display("zpu_core: ------  emulate 0x%h ------", b[2:0]); // opcode[5:0] );

128 : $display("zpu_core: ------  mcpy ------");
132 : $display("zpu_core: ------  mset ------");
136 : $display("zpu_core: ------  loadh ------");
140 : $display("zpu_core: ------  storeh ------");
144 : $display("zpu_core: ------  lessthan ------");
148 : $display("zpu_core: ------  lessthanorequal ------");
152 : $display("zpu_core: ------  ulessthan ------");
156 : $display("zpu_core: ------  ulessthanorequal ------");
160 : $display("zpu_core: ------  swap ------");
164 : $display("zpu_core: ------  mult ------");
168 : $display("zpu_core: ------  lshiftright ------");
172 : $display("zpu_core: ------  ashiftleft ------");
176 : $display("zpu_core: ------  ashiftright ------");
180 : $display("zpu_core: ------  call ------");
184 : $display("zpu_core: ------  eq ------");
188 : $display("zpu_core: ------  neq ------");
192 : $display("zpu_core: ------  neg ------");
196 : $display("zpu_core: ------  sub ------");
200 : $display("zpu_core: ------  xor ------");
204 : $display("zpu_core: ------  loadb ------");
208 : $display("zpu_core: ------  storeb ------");
212 : $display("zpu_core: ------  div ------");
216 : $display("zpu_core: ------  mod ------");
220 : $display("zpu_core: ------  eqbranch ------");
224 : $display("zpu_core: ------  neqbranch ------");
228 : $display("zpu_core: ------  poppcrel ------");
232 : $display("zpu_core: ------  config ------");
236 : $display("zpu_core: ------  pushpc ------");
240 : $display("zpu_core: ------  syscall_emulate ------");
244 : $display("zpu_core: ------  pushspadd ------");
248 : $display("zpu_core: ------  halfmult ------");
252 : $display("zpu_core: ------  callpcrel ------");
//default : $display("zpu_core: mc_pc=0x%h", decode_mcpc);
endcase
end
//synthesis translate_on
`endif
endmodule

// --------- ZPU CORE ALU UNIT ---------------
module zpu_core_alu(
	alu_a,			// parameter A
	alu_b,			// parameter B
	alu_r,			// computed result
	flag_idim,		// for IMM alu op
	alu_op,			// ALU operation
	clk,			// clock for syncronous multicycle operations
	done			// done signal for alu operation
);

input [31:0]				alu_a;
input [31:0]				alu_b;
input [`ALU_OP_WIDTH-1:0]	alu_op;
input						flag_idim;
output [31:0]				alu_r;
input						clk;
output						done;

wire [31:0]					alu_a;
wire [31:0]					alu_b;
wire [`ALU_OP_WIDTH-1:0]	alu_op;
wire						flag_idim;
reg  [31:0]					alu_r;
wire						clk;
reg							done;

`ifdef ENABLE_MULT
// implement 32 bit pipeline multiplier
reg			mul_running;
reg	[2:0]	mul_counter;
wire		mul_done = (mul_counter == 3);
reg	[31:0]	mul_result, mul_tmp1;
reg	[31:0]	a_in, b_in;

always@(posedge clk)
begin
  a_in		  <= 0;
  b_in		  <= 0;
  mul_tmp1	  <= 0;
  mul_result  <= 0;
  mul_counter <= 0;
  if(mul_running)
  begin	// infer pipeline multiplier
    a_in		<= alu_a;
    b_in		<= alu_b;
    mul_tmp1	<= a_in * b_in;
    mul_result	<= mul_tmp1;
    mul_counter <= mul_counter + 1;
  end
end
`endif

`ifdef ENABLE_DIV
// implement 32 bit divider
// Unsigned/Signed division based on Patterson and Hennessy's algorithm.
// Description: Calculates quotient.  The "sign" input determines whether
// signs (two's complement) should be taken into consideration.
// references: http://www.ece.lsu.edu/ee3755/2002/l07.html
reg  [63:0]	  qr;
wire [33:0]	  diff;
wire [31:0]   quotient;
wire [31:0]   dividend;
wire [31:0]   divider; 	
reg  [6:0]    bit;
wire          div_done;
reg			  div_running;
reg			  divide_sign;
reg			  negative_output;

assign div_done = !bit;
assign diff = qr[63:31] - {1'b0, divider};
assign quotient  = (!negative_output) ? qr[31:0] : ~qr[31:0] + 1'b1;
assign dividend  = (!divide_sign || !alu_a[31]) ? alu_a : ~alu_a + 1'b1;
assign divider   = (!divide_sign || !alu_b[31]) ? alu_b : ~alu_b + 1'b1;
   
always@(posedge clk)
begin
	bit <= 7'b1_000000;				// divider stopped
	if(div_running)
	begin
	  if(bit[6])					// divider started: initialize registers
	  begin
		  bit             <= 7'd32;
		  qr              <= { 32'd0, dividend };
          negative_output <= divide_sign && ((alu_b[31] && !alu_a[31]) || (!alu_b[31] && alu_a[31]));
      end
      else							// step by step divide
	  begin
        if( diff[32] ) 	qr <= { qr[62:0], 1'd0 };
        else 			qr <= { diff[31:0], qr[30:0], 1'd1 };
        bit <= bit - 1;
      end
   end
end
`endif

`ifdef ENABLE_BARREL
// implement 32 bit barrel shift
// alu_b[6] == 1 ? left(only arithmetic) : right
// alu_b[5] == 1 ? logical : arithmetic
reg			  bs_running;
reg [31:0]	  bs_result;
reg  [4:0]	  bs_counter;				// 5 bits
wire		  bs_left 	 = alu_b[6];
wire		  bs_logical = alu_b[5];
wire [4:0]	  bs_moves 	 = alu_b[4:0];
wire		  bs_done	 = (bs_counter == bs_moves);

always @(posedge clk)
begin
  bs_counter <= 0;
  bs_result  <= alu_a;
  if(bs_running)
  begin
	if(bs_left) 	 bs_result <= { bs_result[30:0], 1'b0 };						// shift left
	else
	begin
	  if(bs_logical) bs_result <= { 1'b0, bs_result[31:1] };						// shift logical right
	  else			 bs_result <= { bs_result[31], bs_result[31], bs_result[30:1] };// shift arithmetic right
	end	  
	bs_counter <= bs_counter + 1;
  end
end
`endif

// ----- alu add/sub  -----
reg [31:0] alu_b_tmp;
always @(alu_b or alu_op)
begin
  alu_b_tmp <= alu_b;	// by default, ALU_B as is
  if(alu_op == `ALU_PLUS_OFFSET) alu_b_tmp <= { {25{1'b0}}, ~alu_b[4], alu_b[3:0], 2'b0 };	// ALU_B is an offset if ALU_PLUS_OFFSET operation
end

reg [31:0] alu_r_addsub;	// compute R=A+B or A-B based on opcode (ALU_PLUSxx / ALU_SUB-CMP)
always @(alu_a or alu_b_tmp or alu_op)
begin
`ifdef ENABLE_CMP  
  if(alu_op == `ALU_CMP_SIGNED || alu_op == `ALU_CMP_UNSIGNED)	// in case of sub or cmp --> operation is '-'
  begin
    alu_r_addsub <= alu_a - alu_b_tmp;
  end
  else
`endif
  begin
    alu_r_addsub <= alu_a + alu_b_tmp;	// by default '+' operation
  end
end

`ifdef ENABLE_CMP
// handle overflow/underflow exceptions in ALU_CMP_SIGNED
reg cmp_exception;
always @(alu_a[31] or alu_b[31] or alu_r_addsub[31])
begin
  cmp_exception <= 0;
  if( (alu_a[31] == 0 && alu_b[31] == 1 && alu_r_addsub[31] == 1) ||
	  (alu_a[31] == 1 && alu_b[31] == 0 && alu_r_addsub[31] == 0) ) cmp_exception <= 1;
end
`endif

// ----- alu operation selection -----
always @(alu_a or alu_b or alu_op or flag_idim or alu_r_addsub
`ifdef ENABLE_CMP
		or cmp_exception
`endif
`ifdef ENABLE_MULT
		or mul_done or mul_result
`endif
`ifdef ENABLE_BARREL
		or bs_done or bs_result
`endif
`ifdef ENABLE_DIV
		or div_done or div_result
`endif
)
begin
  done <= 1;		// default alu operations are 1 cycle
`ifdef ENABLE_MULT
  mul_running <= 0;
`endif
`ifdef ENABLE_BARREL
  bs_running <= 0;
`endif
`ifdef ENABLE_DIV
  div_running <= 0;
`endif  
  alu_r <= alu_r_addsub;	// ALU_PLUS, ALU_PLUS_OFFSET, ALU_SUB and part of ALU_CMP
  case(alu_op)
    `ALU_NOP		: alu_r <= alu_a;
    `ALU_NOP_B		: alu_r <= alu_b;   
    `ALU_AND		: alu_r <= alu_a & alu_b;
    `ALU_OR			: alu_r <= alu_a | alu_b;
    `ALU_NOT		: alu_r <= ~alu_a;
    `ALU_FLIP		: alu_r <= { alu_a[0], alu_a[1], alu_a[2], alu_a[3], alu_a[4], alu_a[5], alu_a[6], alu_a[7], 
				     	alu_a[8],alu_a[9],alu_a[10],alu_a[11],alu_a[12],alu_a[13],alu_a[14],alu_a[15],
				     	alu_a[16],alu_a[17],alu_a[18],alu_a[19],alu_a[20],alu_a[21],alu_a[22],alu_a[23],
				     	alu_a[24],alu_a[25],alu_a[26],alu_a[27],alu_a[28],alu_a[29],alu_a[30],alu_a[31] };
    `ALU_IM			: if(flag_idim) alu_r <= { alu_a[24:0], alu_b[6:0] };
			  		  else 		    alu_r <= { {25{alu_b[6]}}, alu_b[6:0] };
`ifdef ENABLE_CMP
	`ALU_CMP_UNSIGNED:if( (alu_a[31] == alu_b[31] && cmp_exception) || 
						  (alu_a[31] != alu_b[31] && ~cmp_exception) )
				      begin
				        alu_r[31] <= ~alu_r_addsub[31];
				      end
	`ALU_CMP_SIGNED	: if(cmp_exception)
				      begin
				      	alu_r[31] <= ~alu_r_addsub[31];
				      end
`endif
`ifdef ENABLE_XOR
	`ALU_XOR		: alu_r <= alu_a ^ alu_b;
`endif
`ifdef ENABLE_A_SHIFT
	`ALU_A_SHIFT_RIGHT: alu_r <= { alu_a[31], alu_a[31], alu_a[30:1] };	// arithmetic shift left
`endif
`ifdef ENABLE_MULT
	`ALU_MULT 		: begin
					    mul_running <= ~mul_done;
					    done 		<= mul_done;
					    alu_r 		<= mul_result;
					  end
`endif
`ifdef ENABLE_BARREL
	`ALU_BARREL		: begin
					    bs_running <= ~bs_done;
					    done 	   <= bs_done;
					    alu_r 	   <= bs_result;
					  end
`endif
`ifdef ENABLE_DIV
	`ALU_DIV		: begin
					    div_running<= ~div_done;
					    done 	   <= div_done;
					    alu_r 	   <= quotient;
					  end
	`ALU_MOD		: begin
					    div_running<= ~div_done;
					    done 	   <= div_done;
					    alu_r 	   <= qr[31:0];
					  end
`endif
  endcase
end

endmodule
