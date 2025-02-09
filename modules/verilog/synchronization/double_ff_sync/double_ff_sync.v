`timescale 1ns/10ps

/**
Make sure the NRESET_VALUE is set to 1 by default when dealing with for example a UART RX FF
*/
module double_ff_sync #(parameter WIDTH=8, parameter NRST_VAL = 0)
        (
            input clkin,
            input nrst_in,
            input [WIDTH-1:0] data_in,
            output reg [WIDTH-1:0] data_out
        );
        reg [WIDTH-1:0] data_tmp;
        always @(posedge clkin) begin
            if (~nrst_in)
                begin
                data_out <= NRST_VAL;
                data_tmp <= NRST_VAL;
                end
            else
                {data_out, data_tmp} <= {data_tmp, data_in};
        end
endmodule
