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
              if(n==(nbits+stpbits))begin
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
  assign s_tick=((timer==final_time));
  
endmodule 
