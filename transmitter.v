module Transmitter
    #(parameter DATA_WIDTH=4,TIME=16)
    (
        input [DATA_WIDTH-1:0] din,
        input clk,reset,
        input s_tick,
        input tx_start,
        output tx_done_tick,
        output tx
    );
    
    reg [DATA_WIDTH-1:0] data;
    reg tx_hold;
    localparam s_idle=0,s_start=1,s_data=2,s_stop=3;
    reg [1:0] current_state,next_state;
    reg done;
    reg [$clog2(TIME):0] iterator_current,iterator_next;
    reg [$clog2(DATA_WIDTH):0] bits_current,bits_next;
    
    always @(posedge clk,negedge reset)
    begin
        if(~reset)
        begin
            tx_hold<=0;
            data <= 0;
            current_state <= s_idle;
            next_state <= s_idle;
            done <= 0;
            iterator_current<=0;
            iterator_next<=0;
            bits_current<=0;
            bits_next<=0;
        end
        else
        begin
            current_state <= next_state;
            iterator_current <= iterator_next;
            bits_current <= bits_next;
        end
    end
    
    always @(*)
    begin
        case(current_state)
            s_idle:
            begin
                tx_hold=1;
                done=0;
                if(tx_start==1)
                begin
                    data = din;
                    next_state = s_start;
                end
                else
                begin
                    next_state = s_idle;
                end
            end
            s_start:
            begin
                tx_hold = 0;
                if(s_tick==1)
                begin
                    if(iterator_current==TIME-1)
                    begin
                        next_state = s_data;
                        iterator_next = 0;
                        bits_next =0;
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
                tx_hold = data[0];
                if(s_tick==1)
                begin
                    if(iterator_current==(TIME-1))
                    begin
                        iterator_next = 0;
                        if(bits_current==DATA_WIDTH-1)
                        begin
                            next_state = s_stop;
                            bits_next = 0;
                            iterator_next =0;
                        end
                        else
                        begin
                            data = data>>1;
                            next_state = s_data;
                            bits_next = bits_current +1;
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
                    next_state = s_data;
                end
            end
            s_stop:
            begin
                tx_hold = 1;
                if(s_tick == 1)
                begin
                    if(iterator_current == TIME-1)
                    begin
                        iterator_next = 0;
                        bits_next = 0;
                        next_state = s_idle;
                        done = 1;
                    end
                    else
                    begin
                        next_state = s_stop;
                        iterator_next=iterator_current + 1;
                    end
                end
                else
                begin
                    next_state = s_stop;
                end
            end
        endcase
    end
    
    assign tx = tx_hold;
    assign tx_done_tick = done;
    endmodule
