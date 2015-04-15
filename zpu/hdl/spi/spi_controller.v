/*
 SPI flash read-only controller

 Copyright 2008 Álvaro Lopes <alvieboy@alvie.com>

 Version: 1.3

 The FreeBSD license
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above
    copyright notice, this list of conditions and the following
    disclaimer in the documentation and/or other materials
    provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Changelog:

 1.3: Remove async reset from spi_data shift register
      Fix indentation of code

 1.2: Fix read count for sequential fetch

 1.1: Move port types outside module declaration.
      Fix state machine to handle clock stop
      Remove err out report
      Fix SPI_CLK generation.
*/

module spi_controller (
   clk,        // Clock
   rst,        // Reset
   ce,         // Chip Enable
   ack,        // Acknowledge

   adr,        // Address in
   dat_o,      // Data out

   SPI_MOSI,   // Master Out/Slave In for SPI
   SPI_MISO,   // Master In/Slave Out for SPI
   SPI_CLK,    // SPI clock
   SPI_SELN    // SPI nSEL
);

parameter Tp = 0;                      // Propagation delay - for simulation
parameter INIT_CLOCK_CYCLE_WAIT = 2;   // Clock cycles to wait before init
parameter DESELECT_CYCLES = 3;         // Clock cycles to wait after deselection - should give 100ns at least
parameter SPI_REGISTER_SIZE = 40;
parameter SPI_ADDRESS_SIZE  = 24;

input       clk;
input       rst;
input       ce;
output reg    ack;

input       [SPI_ADDRESS_SIZE-1:0] adr;
output reg    [31:0] dat_o;

output reg    SPI_MOSI;
input       SPI_MISO;
output       SPI_CLK;
output reg    SPI_SELN;


// FSM states
localparam  SPI_STATE_WAIT      = 7'b0000001,
            SPI_STATE_IDLE      = 7'b0000010,
            SPI_STATE_WACK      = 7'b0000100,
            SPI_STATE_SEND      = 7'b0001000,
            SPI_STATE_BREAD     = 7'b0010000,
            SPI_STATE_READ      = 7'b0100000,
            SPI_STATE_WDES      = 7'b1000000;

// SPI commands
localparam SPI_CMD_READ_FAST = 8'b00001011;


// Shift register to hold command to be sent to SPI
reg [SPI_REGISTER_SIZE-1:0] spi_shift_register_out;

integer spi_reg_count;

reg [8:0] spi_read_count;
reg [7:0] spi_data;
reg [3:0] data_valid_window;
reg [SPI_REGISTER_SIZE-1:0] next_address;

integer dsel_dly;
integer spi_init_count;
reg spi_start_count;
reg spi_enable_clock;   // Enable SPI clock
reg [6:0] spi_state;    // SPI state machine

/*
   SPI clock generation
*/

assign SPI_CLK = spi_enable_clock?~clk:1'b0;

reg seq_read;  // Sequential read in progress

always @(posedge clk or posedge rst)
begin
   if ( rst ) begin
      spi_enable_clock  <= #Tp 1'b0;
      spi_state         <= #Tp SPI_STATE_WAIT;
      spi_init_count    <= #Tp INIT_CLOCK_CYCLE_WAIT;
      SPI_SELN          <= #Tp 1'b1;
      ack               <= #Tp 1'b0;
      spi_start_count   <= #Tp 1'b0;
      next_address      <= #Tp 32'hFFFFFFFF;
   end else begin
      
      case (spi_state)
         SPI_STATE_WAIT:
            begin
               if ( spi_init_count == 0 ) begin
                  spi_state <= SPI_STATE_IDLE;
               end else begin
                  spi_init_count <= #Tp spi_init_count - 1;
               end
            end
         SPI_STATE_IDLE:
            begin

               if ( ce ) begin
                  next_address <= { adr[SPI_ADDRESS_SIZE-1:2], 2'b0 } + 4;
                  seq_read = adr[SPI_ADDRESS_SIZE-1:2] == next_address[SPI_ADDRESS_SIZE-1:2];
                  // Latch address (24 bit wordsize)
                  spi_shift_register_out <= #Tp { SPI_CMD_READ_FAST, adr[SPI_ADDRESS_SIZE-1:2], 2'b0, 8'b0 };

                  spi_enable_clock <= #Tp 1'b1;

                  if ( seq_read ) begin
                     spi_state <= #Tp SPI_STATE_BREAD;
                  end else begin
                     SPI_SELN <= 1'b1   ;
                     spi_reg_count <= #Tp SPI_REGISTER_SIZE;
                     dsel_dly <= DESELECT_CYCLES;
                     spi_state <= #Tp SPI_STATE_WDES;
                  end
               end
            end
         SPI_STATE_WACK:
         begin
            ack <= 1'b0;
            spi_state <= SPI_STATE_IDLE;
         end
         SPI_STATE_SEND:
            begin

               SPI_SELN <=#Tp  1'b0;

               if (spi_reg_count == 0)
               begin
                  spi_state <= #Tp SPI_STATE_BREAD;
               end else begin
                  SPI_MOSI <= #Tp spi_shift_register_out[SPI_REGISTER_SIZE-1];
                  spi_shift_register_out <= #Tp { spi_shift_register_out[SPI_REGISTER_SIZE-2:0], 1'b0 };
                  spi_reg_count <= #Tp spi_reg_count - 1;
               end
            end
         SPI_STATE_BREAD:
            begin
               spi_start_count <= #Tp 1'b1;
               spi_state <= #Tp SPI_STATE_READ;
            end
         SPI_STATE_READ:
            begin
               spi_start_count <= #Tp 1'b0;

               // Stop clock a bit earlier
               if ( data_valid_window[3] && spi_read_count[1] )
                     spi_enable_clock <= 1'b0;

               if (spi_read_count[0])
               begin

                  dat_o <= #Tp { dat_o[23:0], spi_data };

                  if ( data_valid_window[3] ) begin
                     ack <= #Tp 1'b1;
                     spi_state <= #Tp SPI_STATE_WACK;
                  end 
               end
            end
         SPI_STATE_WDES:
            begin
               if ( dsel_dly == 0 )
                  spi_state <= SPI_STATE_SEND;
               else
                  dsel_dly <= dsel_dly -1;
            end
      endcase
   end
end

always @(posedge clk)
begin
   if (spi_start_count) begin
         spi_read_count <= 8'b01000000;
         data_valid_window <=  #Tp 5'b00001;
   end else begin
      if ( spi_read_count[0] ) begin
         data_valid_window <= #Tp { data_valid_window[3:0], 1'b0 };
      end
      spi_read_count <= #Tp { spi_read_count[0] ,spi_read_count[7:1] };
   end
end

// SPI data shift register

always @(negedge clk)
begin
   spi_data <= #Tp {  spi_data[6:0], SPI_MISO };
end

endmodule
