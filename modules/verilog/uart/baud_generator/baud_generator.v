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
     parameter OVERSAMPLING_RATE = 8) // 3 bits
    (
    output reg baudclk_out,
    output reg divclk_out,
    input clk_in,
    input nrst_in
    );

    parameter CLK_COUNT_DIV_MAX = (CLOCK_IN / (2 * OVERSAMPLING_RATE * BAUD_RATE));
    reg [$clog2(CLK_COUNT_DIV_MAX-1):0] divclk_cnt;
    
    reg [$clog2(OVERSAMPLING_RATE-1):0] baudclk_cnt;

    always @(posedge clk_in)
    begin
        if (~nrst_in)
            begin
            // Counters
            divclk_cnt <= 0;
            baudclk_cnt <= 0;
            // Clocks
            divclk_out <= 0;
            baudclk_out <= 0;
            end
        else
            begin
            if (divclk_cnt < CLK_COUNT_DIV_MAX-1)
            begin
                divclk_cnt = divclk_cnt + 1;
            end
            else if (divclk_cnt == CLK_COUNT_DIV_MAX-1)
            begin
                // Divided baud clock
                divclk_out = ~divclk_out;
                divclk_cnt = 0;
                // Baud clock
                if (baudclk_cnt == OVERSAMPLING_RATE-1)
                    begin
                    baudclk_out <= ~baudclk_out;
                    baudclk_cnt <= 0;
                    end
                else
                    baudclk_cnt <= baudclk_cnt + 1;
            end
        end
    end

    /**
       Clock out -> check how many times you need to tick (1 / CLOCK_IN) * 1e9 to get (1 / BAUD_RATE) * 1e9  ticks. Take 
    */


    
endmodule