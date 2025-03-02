`timescale 1ns/10ps

/**
We need
READ / WRITE
- INPUT: Data write in
- OUTPUT: Data read out
- INPUT: FULL (don't allow write)
- INPUT: empty_in (don't allow read)
- register
*/

module fifo_memory #(parameter WIDTH = 8, parameter DEPTH = 16, parameter PTR_WIDTH = 3)
    (
        input WCLK, input W_EN,
        input FULL, EMPTY,
        input [PTR_WIDTH-1:0] R_PTR, W_PTR,
        input  [WIDTH-1:0] W_DI, // No need for a register because we are saving the signal into the buffer
        output [WIDTH-1:0] R_DO); //! Removed register in-between here.

    reg [WIDTH-1:0] buffer [0:DEPTH-1];
    always @(posedge WCLK)
    begin
        if (W_EN & !FULL)
            buffer[W_PTR[PTR_WIDTH-2:0]] = W_DI;
        else;
    end
    assign R_DO = buffer[R_PTR[PTR_WIDTH-2:0]];
endmodule
