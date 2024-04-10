`timescale 1ns / 1ps
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
          time_count<=0;
      else
        begin
          if(s_tick)
            time_count<=0;
          else
            time_count<=time_count+1;
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
              
              //b=tx_din;
            end
        end
        s1:
          begin
          b=tx_din;
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

