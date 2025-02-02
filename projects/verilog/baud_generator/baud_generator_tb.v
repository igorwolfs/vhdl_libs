`timescale 1ns / 10ps

module baud_generator_tb();

    reg nrst_in = 0;
    reg clk = 0;
    wire clk_out;
    
    baud_generator baud_generator_inst
    (
    .nrst_in(nrst_in),
    .clk_in(clk),
    .clk_out(clk_out)
    );
    
    always
        #5 clk = ~clk;

    initial
        begin
            nrst_in = 1;
            #20
            nrst_in = 0;
            #20
            nrst_in = 1;
        #100000;
        end

endmodule
