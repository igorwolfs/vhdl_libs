`timescale 1ns / 10ps

module baud_generator_tb();

    localparam BAUD_RATE = 230_400;
    localparam SYSCLOCK = 100_000_000;
    localparam OVERSAMPLING = 8;

    reg nrst_in = 0;
    reg clk = 0;
    wire baudpulse_out, divpulse_out;

    baud_generator #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(SYSCLOCK), .OVERSAMPLING_RATE(OVERSAMPLING) // 100 MHz, assumed clock period
    ) baud_generator_inst
    (
    .nrst_in(nrst_in),
    .clk_in(clk),
    .baudpulse_out(baudpulse_out), .divpulse_out(divpulse_out)
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
