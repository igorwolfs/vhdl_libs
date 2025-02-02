`timescale 1ns / 10ps

/**
- Outputs: a clock signal at the valid baud rate, which has to somehow be a division of the input clock rate.
- Inputs: 
    - clkin: An input clock signal
        - Can vary from MHz to 100s of MHz
    - baud: The desired baud rate
    - enable: enables the baud generator
The clock period of clk_out x 2 should be the baud rate.
*/

module baud_generator
    #(parameter BAUD_RATE = 230_400,
     parameter CLOCK_IN = 100_000_000,
     parameter OVERSAMPLING = 8) // 3 bits
    (
    output clk_out,
    input clk_in,
    input nrst_in
    );

    parameter CLOCK_TOGGLE_COUNT = (CLOCK_IN / (2 * OVERSAMPLING * BAUD_RATE)) - 1;
    reg [$clog2(CLOCK_TOGGLE_COUNT):0] clk_out_count;
    reg clk_reg;

    always @(posedge clk_in)
    begin
        if (~nrst_in)
        begin
            clk_reg = 0;
            clk_out_count = 0;
        end
        else
        begin
            if (clk_out_count < CLOCK_TOGGLE_COUNT)
            begin
                clk_out_count = clk_out_count + 1;
            end
            else if (clk_out_count == CLOCK_TOGGLE_COUNT)
            begin
                clk_reg = ~clk_reg;
                clk_out_count = 0;
            end
        end
    end

    assign clk_out = clk_reg;

    /**
       Clock out -> check how many times you need to tick (1 / CLOCK_IN) * 1e9 to get (1 / BAUD_RATE) * 1e9  ticks. Take 
    */


    
endmodule
