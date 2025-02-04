`timescale 1ns/10ps

/**
# Inputs and ouptus
Check draw-io diagram

ALWAYS EXTERNALLY
// * RESET BUFFER
- Buffer should be emptied
- read and write ptr should be put at same place (e.g.: 0)
- can_read and can_write should be low
// * SIGNAL READ
- read_en_in should be pulled high
- if readable_out is enabled
- sample value at data_write_in
- toggle read_en_in low -> high -> low to load next value
// * SIGNAL WRITE
- write_en_in should be pulled high
- if writable_out is enabled
- toggle write_en_in low -> high -> low to load next value

NOTE: we need to know whether the buffer is empty or full.
    - Since when the read and write pointer are on the same place we don't know.
    - FULL can only be set in read
    - EMPTY can only be set in write
*/

module fifo_async_circular
    #(parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 8)
(
    input read_clk,
    input write_clk,
    input [DATA_WIDTH-1:0] data_write_in,
    input write_en_in,
    input read_en_in,
    input nrst_in,
    output [DATA_WIDTH-1:0] data_read_out,
    output reg writable_out,
    output reg readable_out
);

    reg [DATA_DEPTH-1:0] buffer[DATA_WIDTH-1:0];
    reg [$clog2(DATA_DEPTH-1):0] read_ptr;
    reg [$clog2(DATA_DEPTH-1):0] write_ptr;

    reg full; // Saves whether buffer is full or empty

    // *** READ SIGNAL
    @(posedge write_clk, nrst_in)
    begin
        if (~nrst_in)
            begin
            // Set all read-related variables
            write_ptr <= 0;
            writable_out <= 0;
            full <= 0;
            end
        else
            begin
            if (writable_out && write_en_in)
            begin
                // Check if write_ptr is == depth-1
                // If it is write data to 0 and set the write_ptr to 0
                if (write_ptr == DATA_DEPTH-1)
                    begin
                    buffer[0] = data_write_in;
                    if (read_ptr == 0)
                    begin
                        full <= 1;
                    end
                else // Note that we are writing into 1 when write location is 0
                    begin
                        buffer[write_ptr+1] <= data_write_in;
                        if (read_ptr == write_ptr+1)
                        begin
                            
                        end
                    end
            end
            if (write_ptr != read_ptr)
                writable_out <= 1;
            else
                writable_out <= 0;
            // if the write pointer catches UP to the read pointer -> make sure to trigger the read_disabled
            if (write_ptr == )
            begin
                
            end
    end
endmodule
