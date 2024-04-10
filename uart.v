`timescale 1ns / 1ps
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
  
  
  transmitter t(.clk(clk),.reset(reset),.tx(bridge),.tx_din(trd_data),.tx_start(~tx_empty),.tx_done(trd_en));
  
  reciever r(.clk(clk),.reset(reset),.rx(bridge),.rx_dout(rwr_data),.rx_done(rwr_en));
  
  fifo r_f(.clk(clk),.reset(reset),.wr_en(rwr_en),.wr_data(rwr_data),.rd_en(rrd_en),.rd_data(rrd_data),.fifo_full(rx_full),.fifo_empty(rx_empty));
  
endmodule
