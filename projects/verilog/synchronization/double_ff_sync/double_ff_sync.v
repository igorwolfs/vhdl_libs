`timescale 1ns/10ps

module double_ff_sync #(parameter WIDTH=8)
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
                data_out <= 0;
                data_tmp <= 0;
                end
            else
                {data_out, data_tmp} <= {data_tmp, data_in};
        end
endmodule
