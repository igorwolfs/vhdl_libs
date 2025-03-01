`timescale 1ns/10ps

/**
Make sure the NRESET_VALUE is set to 1 by default when dealing with for example a UART RX FF
*/
module double_ff_sync #(parameter WIDTH=8, parameter NRST_VAL = 0)
        (
            input CLK,
            input NRST,
            input [WIDTH-1:0] D,
            output reg [WIDTH-1:0] Q
        );
        reg [WIDTH-1:0] qi;
        always @(posedge CLK) begin
            if (~NRST)
                begin
                Q <= NRST_VAL;
                qi <= NRST_VAL;
                end
            else
                {Q, qi} <= {qi, D};
        end
endmodule
