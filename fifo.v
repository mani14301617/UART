`timescale 1ns / 1ps
module fifo #(
    parameter DATA_WIDTH = 8, // Width of data in bits
    parameter FIFO_DEPTH = 7 // Number of entries in FIFO
)(
    input wire clk, // Clock signal
    input wire reset, // Reset signal, active low
    input wire wr_en, // Write enable
    input wire rd_en, // Read enable
    input wire [DATA_WIDTH-1:0] wr_data, // Data to write
    output reg [DATA_WIDTH-1:0] rd_data, // Data to read
    output wire fifo_full, // FIFO full flag
    output wire fifo_empty // FIFO empty flag
);

// Internal parameters
localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

// FIFO storage
reg [DATA_WIDTH-1:0] memory [0:FIFO_DEPTH-1];

// Read and write pointers
reg [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;

// FIFO count to keep track of the number of items
reg [ADDR_WIDTH :0] fifo_count;

assign fifo_full = (fifo_count == FIFO_DEPTH);
assign fifo_empty = (fifo_count == 0);

  always @(posedge clk or negedge reset) begin
    if (~reset) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        fifo_count <= 0;
    end
    else begin
    //rd_data <= memory[rd_ptr];
      if(!fifo_empty)
        begin
          rd_data = memory[rd_ptr];
          if(rd_en)
            begin
             rd_ptr = (rd_ptr + 1) % FIFO_DEPTH;
             fifo_count = fifo_count - 1;
            end
        end
        if (wr_en && !fifo_full) begin
          //rd_data <= memory[rd_ptr];
          memory[wr_ptr] = wr_data;
         // rd_data <= memory[rd_ptr];
            wr_ptr = (wr_ptr + 1) % FIFO_DEPTH;
            fifo_count = fifo_count + 1;
        end
        
       /* if (rd_en && !fifo_empty) begin
            rd_data <= memory[rd_ptr];
            rd_ptr <= (rd_ptr + 1) % FIFO_DEPTH;
            fifo_count <= fifo_count - 1;
        end*/
        end
    end


endmodule
