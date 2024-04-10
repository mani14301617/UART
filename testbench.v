`timescale 1ns / 1ps
module t_uart();
  localparam nbits=8;
  reg  rrd_en,twr_en,clk,reset;
  reg  [nbits-1:0]twr_data;
  wire [nbits-1:0]rrd_data;
  wire tx_full,rx_full,rx_empty;
  
  uart u(.clk(clk),.reset(reset),.rrd_en(rrd_en),.twr_en(twr_en),.twr_data(twr_data),.rrd_data(rrd_data),.tx_full(tx_full),.rx_full(rx_full),.rx_empty(rx_empty));
  
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0,t_uart);
      #0 clk=0;
      repeat(200000)
        #5 clk=~clk;
    end
  initial
    begin
      #0 reset=1;rrd_en=0;twr_en=0;
      #1 reset=0;
      #1 reset=1;twr_en=1;//rrd_en=1;
      #1twr_data=8'b10101010;
;      #10 twr_data=8'b10000010;
      #10 twr_data=8'b11100010;
      #10 twr_data=8'b10010010;
      #10 twr_data=8'b10001010;
      #10 twr_data=8'b10000110;
      #10 twr_data=8'b10000011;
      #10 twr_en=0;

   

      #5 rrd_en=1;
      #1000000 $finish;
    end
endmodule
