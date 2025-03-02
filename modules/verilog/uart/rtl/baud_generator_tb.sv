`timescale 1ns / 10ps

module baud_generator_tb();

    localparam BAUD_RATE = 230_400;
    localparam SYSCLOCK = 100_000_000;
    localparam OVERSAMPLING = 8;

    reg NRST = 1'b0;
    reg clk = 1'b0;
    wire BAUDPULSE, DIVPULSE;

    baud_generator #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(SYSCLOCK), .OVERSAMPLING_RATE(OVERSAMPLING) // 100 MHz, assumed clock period
    ) baud_generator_inst
    (
    .NRST(NRST),
    .CLK(clk),
    .BAUDPULSE(BAUDPULSE), .DIVPULSE(DIVPULSE)
    );

    always
        #5 clk = ~clk;

    always
    begin
        NRST <= 1;
        #20
        NRST <= 0;
        #20
        NRST <= 1;
      #100000;
        $finish;
    end
endmodule
