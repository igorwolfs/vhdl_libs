// reference for simulation paths
`timescale 1ns / 1ps


module top(
    input btn0,
    output led0
);

assign led0 = btn0;
endmodule
