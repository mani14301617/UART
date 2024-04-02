module FIFO
    #(parameter DATA_WIDTH=8,SIZE=16)
    (
        input clk,reset,
        input rd_en,wr_en,
        input [DATA_WIDTH-1:0] din,
        output [DATA_WIDTH-1:0] dout,
        output full,empty
    );
    
    reg [DATA_WIDTH-1:0] memory [0:SIZE-1];
    reg [$clog2(SIZE)-1:0] wr_ptr,rd_ptr;
    reg [$clog2(SIZE)-1:0] number_of_elements;
    
    always @(posedge clk,negedge reset)
    begin
        if(~reset)
        begin
            rd_ptr <=0;
            wr_ptr <=0;
            number_of_elements <=0;
        end
        else
            begin
            if(rd_en)
            begin
                rd_ptr <= rd_ptr + 1;
                number_of_elements <= number_of_elements -1;
            end
            if(wr_en)
            begin
                memory[wr_ptr] <= din;
                wr_ptr <= wr_ptr+1;
                number_of_elements <= number_of_elements +1;
            end
        end
    end
    
    assign dout = memory[rd_ptr];
    assign empty = (rd_ptr==wr_ptr);
    assign full = (number_of_elements==SIZE);
    
endmodule
