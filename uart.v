module fifo #(
    parameter DATA_WIDTH = 8, // Width of data in bits
    parameter FIFO_DEPTH = 16 // Number of entries in FIFO
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
        wr_ptr = 0;
        rd_ptr = 0;
        fifo_count = 0;
    end
    else begin
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
          memory[wr_ptr] <= wr_data;
            wr_ptr <= (wr_ptr + 1) % FIFO_DEPTH;
            fifo_count <= fifo_count + 1;
        end
        
       /* if (rd_en && !fifo_empty) begin
            rd_data <= memory[rd_ptr];
            rd_ptr <= (rd_ptr + 1) % FIFO_DEPTH;
            fifo_count <= fifo_count - 1;
        end*/
        end
    end


endmodule

module transmitter#(parameter nbits=8,stpbits=2)(tx,clk,reset,tx_din,tx_start,tx_done);
  input clk,reset,tx_start;
  input [nbits-1:0]tx_din;
  output reg tx;
  output reg tx_done;
  
  reg [1:0]state,next_state;
  reg [4:0]tick_count,bit_count,time_count;
  reg [nbits-1:0]b;
  wire s_tick;
  
  parameter final_ticks=16;
  parameter final_time=9;
  parameter s0=0,s1=1,s2=2,s3=3;
  
  always@(posedge clk or negedge reset)
    begin
      if(~reset)
        begin
          state<=s0;
          next_state<=s0;
          tx<=1;
          bit_count<=0;
          
        end
      else
        state<=next_state;
    end
  
  always@(posedge s_tick)
    begin
        tick_count=tick_count+1;
    end
  
  always@(posedge clk or negedge reset )
    begin
      if(~reset)
          time_count=0;
      else
        begin
          if(s_tick)
            time_count=0;
          else
            time_count=time_count+1;
        end
    end
  
  always@(*)
    begin
      //tx_done=0;
      case(state)
        s0:begin
          tx_done=0;
          if(tx_done)
            next_state=s0;
          
         else if(tx_start)
            begin
              //tx_done=0;
              next_state=s1;
              time_count=0;
              tick_count=0;
              
              b=tx_din;
            end
        end
        s1:
          begin
          tx=0;
            if(tick_count==final_ticks)
              begin
                tick_count=0;
                bit_count=0;
                next_state=s2;
              end
          end
        s2:
          begin
            tx=b[nbits-1];
        if(bit_count==nbits)
          next_state=s3;
        else
          begin
             if(tick_count==final_ticks)
              begin
                tick_count=0;
                b=b<<1;
                bit_count=bit_count+1;
              end
            
          end
          end
        s3:
          begin
          tx=1;
        if(bit_count==(nbits+stpbits))
          begin
            tx_done=1;
          next_state=s0;
            
          end
        else
          begin
            if(tick_count==final_ticks)  
             begin
             tick_count=0;
             bit_count=bit_count+1;
             end
          end
          end
          
      endcase
    end
  
 // assign tx_done=(bit_count==(nbits+stpbits));
  assign s_tick=(time_count==final_time);
  
endmodule

module reciever #(parameter nbits=8,stpbits=2)(rx,rx_dout,rx_done,clk,reset);
  input clk,reset,rx;
  output reg [nbits-1:0]rx_dout;
  output reg rx_done;
 
  reg [1:0]state,next_state;
  wire s_tick;
 
  parameter final_time=9;
  parameter nticks=16;
  parameter s0=0,s1=1,s2=2,s3=3;//idle,start,data,stop
 
  reg [4:0]count,timer;//keeping count of the ticks, count of final value
  reg [4:0]n;//no. of bits traversed
  
  always@(posedge clk or negedge reset)
    begin
      if(~reset)
        begin
          rx_dout<=0;
          state<=s0;
          count<=0;
          n<=0;
          next_state<=s0;
          rx_done<=0;
        end
      else
          state<=next_state;
    end
  
  always@(posedge s_tick)
    count=count+1;
 
  always@(*)
    begin
      //rx_done=0;
      case(state)
        s0:begin
          rx_done=0;
          if(rx==0)
            begin
              //rx_done=0;
              next_state=s1;
              count=0;
            end
        end
        s1:
          if(count==7)
            begin
              count=0;
              n=0;
              next_state=s2;
            end
        s2:
          if(n==nbits) 
            next_state=s3;
        else
          begin
            if(count==nticks)
            begin
              count=0;
              rx_dout=(rx_dout << 1) | rx;;
            
                n=n+1;
            end
          end
        s3:
          if(count==nticks)
            begin
              count=0;
              n=n+1;
              if(n==(nbits+stpbits+1))begin
                  rx_done=1;
                  next_state=s0;
                n=0;
              end
            end
      endcase
    end

  always@(posedge clk or negedge reset)
    begin
      if(~reset)
        timer=0;
      else
        begin
          if(s_tick)
            timer=0;
          else
            timer=timer+1;
        end
    end
 
  //assign rx_done=(n==(nbits+stpbits));
  assign s_tick=(timer==final_time);
  
endmodule 

module uart#(parameter nbits=8,stpbits=2)(rrd_en,twr_en,twr_data,rrd_data,tx_full,rx_full,rx_empty,clk,reset);
  input rrd_en,twr_en,clk,reset;
  input  [nbits-1:0]twr_data;
  output [nbits-1:0]rrd_data;
  output tx_full,rx_full,rx_empty;
  
  wire trd_en,rwr_en;
  wire [nbits-1:0]trd_data,rwr_data;
  wire tx_empty;
  wire bridge;
  fifo t_f(.clk(clk),.reset(reset),.wr_en(twr_en),.wr_data(twr_data),.rd_en(trd_en),.rd_data(trd_data),.fifo_full(tx_full),.fifo_empty(tx_empty));
  
  fifo r_f(.clk(clk),.reset(reset),.wr_en(rwr_en),.wr_data(rwr_data),.rd_en(rrd_en),.rd_data(rrd_data),.fifo_full(rx_full),.fifo_empty(rx_empty));
  
  transmitter t(.clk(clk),.reset(reset),.tx(bridge),.tx_din(trd_data),.tx_start(~tx_empty),.tx_done(trd_en));
  
  reciever r(.clk(clk),.reset(reset),.rx(bridge),.rx_dout(rwr_data),.rx_done(rwr_en));
endmodule
