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
    output reg BAUDPULSE,
    output reg DIVPULSE,
    input CLK,
    input NRST
    );

    // Note: we only need a pulse on the rising edge, NOT on the rising AND the falling edge -> So the division by 2 is unnecessary.
    //! HOWEVER: make sure to also fix the baud rate pulse.
    parameter CLK_COUNT_DIV_MAX = (CLOCK_IN / (OVERSAMPLING_RATE * BAUD_RATE));

    reg [$clog2(CLK_COUNT_DIV_MAX-1)-1:0] divpulse_cnt;
    reg [$clog2(OVERSAMPLING_RATE-1)-1:0] baudpulse_cnt;

    always @(posedge CLK)
    begin
        if (~NRST)
            begin
            // Counters
            divpulse_cnt <= 0;
            baudpulse_cnt <= 0;
            // Clocks
            DIVPULSE <= 0;
            BAUDPULSE <= 0;
            end
        else
            begin
            if (divpulse_cnt < CLK_COUNT_DIV_MAX-1)
            begin
                DIVPULSE <= 0;
                BAUDPULSE <= 0;
                divpulse_cnt <= divpulse_cnt + 1;
            end
            else if (divpulse_cnt == CLK_COUNT_DIV_MAX-1)
            begin
                // Divided baud clock
                DIVPULSE <= 1;
                divpulse_cnt <= 0;
                // Baud clock
                if (baudpulse_cnt == OVERSAMPLING_RATE-1)
                    begin
                    BAUDPULSE <= 1;
                    baudpulse_cnt <= 0;
                    end
                else
                    baudpulse_cnt <= baudpulse_cnt + 1;
            end
        end
    end

    /**
       Clock out -> check how many times you need to tick (1 / CLOCK_IN) * 1e9 to get (1 / BAUD_RATE) * 1e9  ticks. Take 
    */


endmodule
