module UART(
        input [7:0] din,
        input wr_uart,
        input clk,reset,
        input rd_uart,
        output [7:0]out
    );
    
    localparam FINAL_VALUE = 853;
    wire [7:0] dout,dout2,dout3;
    wire tx_done_tick,rx_done_tick;
    wire empty_tx,full_tx,empty_rx,full_rx,s_tick;
    wire rx;
    
    FIFO 
    #(
        .DATA_WIDTH(8),
        .SIZE(16)
    )
    F_TX
    (
        .din(din),
        .empty(empty_tx),
        .full(full_tx),
        .clk(clk),
        .reset(reset),
        .dout(dout),
        .rd_en(tx_done_tick),
        .wr_en(wr_uart)
    );
    FIFO 
    #(
        .DATA_WIDTH(8),
        .SIZE(16)
    )
    F_RX
    (
        .din(dout2),
        .empty(empty_rx),
        .full(full_rx),
        .clk(clk),
        .reset(reset),
        .dout(dout3),
        .rd_en(rd_uart),
        .wr_en(rx_done_tick)
    );
    
    baud_rate_generator 
    #(
        .FINAL_VALUE_BITS($clog2(FINAL_VALUE))
     )
    B
    (
        .FINAL_VALUE(FINAL_VALUE),
        .clk(clk),
        .reset(reset),
        .done(s_tick)
    );
    
    Transmitter 
    #(
        .DATA_WIDTH(8),
        .TIME(16)
    )
    T
    (
        .tx_start(~empty_tx),
        .din(dout),
        .clk(clk),
        .s_tick(s_tick),
        .reset(reset),
        .tx(rx),
        .tx_done_tick(tx_done_tick)
    );
    
    Reciever
    #(
        .DATA_WIDTH(8),
        .TIME(16)
    )
    R
    (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .s_tick(s_tick),
        .rx_done_tick(rx_done_tick),
        .rx_out(dout2)
    );
    
    assign out = dout3;
    
endmodule
