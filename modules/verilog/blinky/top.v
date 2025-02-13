// reference for simulation paths
`timescale 1ns / 1ps


module top(
    input switch_in,
    output [3:0] led
);

assign led[3] = switch_in;
assign led[2] = switch_in;
assign led[1] = switch_in;
assign led[0] = switch_in;

endmodule
