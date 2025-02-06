`timescale 1ns/10ps

/**
We need
READ / WRITE
- INPUT: Data write in
- OUTPUT: Data read out
- INPUT: full_in (don't allow write)
- INPUT: empty_in (don't allow read)
- register
*/

module fifo_memory #(parameter WIDTH = 8, parameter DEPTH = 16, parameter PTR_WIDTH = 3)
    (
        input w_clk, input write_in,
        input read_in,
        input full_in, empty_in,
        input [PTR_WIDTH-1:0] read_ptr_in, write_ptr_in,
        input  [WIDTH-1:0] data_write_in, // No need for a register because we are saving the signal into the buffer
        output [WIDTH-1:0] data_read_out); //! Removed register in-between here.

    reg [WIDTH-1:0] buffer [0:DEPTH-1];
    always @(posedge w_clk)
    begin
        if (write_in & !full_in)
            buffer[write_ptr_in[PTR_WIDTH-2:0]] = data_write_in;
    end
    assign data_read_out = buffer[read_ptr_in[PTR_WIDTH-2:0]];
endmodule