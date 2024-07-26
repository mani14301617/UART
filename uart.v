`timescale 1ns / 1ps
module uart
    #(
        parameter DBIT = 8,     // # data bits
                  SB_TICK = 16  // # stop bit ticks                  
     )     
  (rrd_en,twr_en,twr_data,rrd_data,tx_full,rx_full,rx_empty,clk,reset,final);
  
  input rrd_en,twr_en,clk,reset;
  input  [DBIT-1:0]twr_data;
  output [DBIT-1:0]rrd_data;
  output tx_full,rx_full,rx_empty;
  input [10:0]final;
  wire trd_en,rwr_en;
  wire [DBIT-1:0]trd_data,rwr_data;
  wire tx_empty;
  wire bridge;
  wire bridge_tick;
  
  timer_input brg(.clk(clk),.reset_n(reset),.enable(1'b1),.done(bridge_tick),.FINAL_VALUE(final));
  
  fifo t_f(.clk(clk),.reset(reset),.wr_en(twr_en),.wr_data(twr_data),.rd_en(trd_en),.rd_data(trd_data),.fifo_full(tx_full),.fifo_empty(tx_empty));
   
  transmitter t(.clk(clk),.reset_n(reset),.tx(bridge),.tx_din(trd_data),.tx_start(~tx_empty),.tx_done_tick(trd_en),.s_tick(bridge_tick));
 
  reciever r(.clk(clk),.reset_n(reset),.rx(bridge),.s_tick(bridge_tick),.rx_dout(rwr_data),.rx_done_tick(rwr_en));
  
  fifo r_f(.clk(clk),.reset(reset),.wr_en(rwr_en),.wr_data(rwr_data),.rd_en(rrd_en),.rd_data(rrd_data),.fifo_full(rx_full),.fifo_empty(rx_empty));
  
endmodule
