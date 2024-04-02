module Reciever
    #(parameter DATA_WIDTH=8,TIME=16)
    (
    input rx,s_tick,reset,
    input clk,
    output [DATA_WIDTH-1:0] rx_out,
    output rx_done_tick
    );
    
    localparam s_idle=0,s_start=1,s_data=2,s_stop=3;
    reg [1:0] current_state,next_state;                             // to store the state in ehich the Reciever is present in
    reg [DATA_WIDTH-1:0] data;                                      // ro Store the Data Elements
    reg done;                                                       // to Store the time when the reciever is done getting the data
    reg [$clog2(TIME):0] iterator_current,iterator_next;            // to keeo count of the number of clock ticks
    reg [$clog2(DATA_WIDTH):0] bits_current,bits_next;              // to keep count of the number of bits that are recieved
    
    always @(posedge clk,negedge reset)
    begin
        if(~reset)
        begin
            data <= 0;
            done <= 0;
            iterator_current <=0;
            iterator_next <= 0;
            current_state <= s_idle;
        end
        else
        begin
            current_state <=next_state;
            iterator_current<=iterator_next;
            bits_current<=bits_next;
        end
    end
    
    always @(*)
    begin
        case(current_state)
            s_idle:
            begin
                if(rx==0)
                begin
                    next_state = s_start;
                    iterator_next = 0;
                end
                else
                begin
                    next_state = s_idle;
                end
            end
            s_start:
            begin
                if(s_tick==1)
                begin
                    if(iterator_current==(TIME/2)-1)
                    begin
                        done = 0;
                        iterator_next = 0;
                        bits_next = 0;
                        next_state = s_data;
                    end
                    else
                    begin
                        iterator_next = iterator_current + 1;
                        next_state = s_start;
                    end
                end
                else
                begin
                    next_state = s_start;
                end
            end
            s_data:
            begin
                if(s_tick==1)
                begin
                    if(iterator_current == TIME-1)
                    begin
                        iterator_next =0;
                        data[bits_current] = rx;
                        if(bits_current==DATA_WIDTH-1)
                        begin
                            next_state = s_stop;
                        end
                        else
                        begin
                            bits_next = bits_current + 1;
                            next_state = s_data;
                        end
                    end
                    else
                    begin
                        iterator_next = iterator_current + 1;
                        next_state = s_data;
                    end
                end
                else
                begin
                    next_state= s_data;
                end
            end 
            s_stop:
            begin
                if(s_tick==1)
                begin
                    if(iterator_next == TIME-1)
                    begin
                        done = 1;
                        next_state = s_idle;
                    end
                    else
                    begin
                        iterator_next = iterator_current + 1;
                        next_state = s_stop;
                        
                    end
                end
                else
                begin
                    next_state = s_stop;
                end
            end   
        endcase
    end
    
    assign rx_done_tick = done;
    assign rx_out = data;
    
endmodule
