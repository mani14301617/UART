`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2024 
// Design Name: 
// Module Name: transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module reciever
    #(parameter DBIT = 8,    // # data bits
                SB_TICK = 16 // # stop bit ticks
    )
    (
        input clk, reset_n,
        input rx, s_tick,
        output reg rx_done_tick,
        output [DBIT - 1:0] rx_dout
    );
    
    localparam  s0 = 0, s1 = 1,
                s2 = 2, s3 = 3;
                
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;                // keep track of the baud rate ticks (16 total)
    reg [$clog2(DBIT) - 1:0] n_reg, n_next; // keep track of the number of data bits recieved
    reg [DBIT - 1:0] b_reg, b_next;         // stores the recieved data bits
    
    // State and other registers
    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
        begin
            state_reg <= s0;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end
        else
        begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end
    
    // Next state logic
    always @(*)
    begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        rx_done_tick = 1'b0;
        case (state_reg)
            s0:                
                if (~rx)
                begin
                    s_next = 0;
                    state_next = s1;                        
                end                 
            s1:                
                if (s_tick)
                    if (s_reg == 7)
                    begin
                        s_next = 0;
                        n_next = 0;
                        state_next = s2;
                    end
                    else                        
                        s_next = s_reg + 1;                                                                   
            s2:
                if (s_tick)
                    if(s_reg == 15)
                    begin
                        s_next = 0;
                        b_next = {rx, b_reg[DBIT - 1:1]}; // Right shift
                        if (n_reg == (DBIT - 1))
                            state_next = s3;
                        else
                            n_next = n_reg + 1;
                    end
                    else
                        s_next = s_reg + 1;
            s3:
                if (s_tick)
                    if(s_reg == (SB_TICK - 1))
                    begin
                        rx_done_tick = 1'b1;
                        state_next = s0;
                    end
                    else
                        s_next = s_reg + 1;
            default:
                state_next = s0;
        endcase
    end
    
    // output logic
    assign rx_dout = b_reg;
endmodule
