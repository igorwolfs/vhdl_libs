`timescale 1ns/10ps

/**
Read pointer
- IN:Takes a clock input from the read-side
- IN: Takes a write-pointer from the write side that went through the sync
- IN: takes a nrst signal
- IN: Takes a read_in signal to signify when someone wants to read on the next clock-cycle
- OUT: Outputs the read pointer to the syncer -> which then goes to the write-side
- OUT: Outputs an empty-signal when reading is impossible due to the buffer being empty


*/

module fifo_async_read_ptr #(parameter WIDTH=8, parameter PTR_WIDTH=3)
    (
        input read_clk, nrst_in, read_in,
        input [PTR_WIDTH-1:0] wptr_g_sync_in,
        output reg [PTR_WIDTH-1:0] rptr_b_out, rptr_g_out,
        output reg empty_out
    );

    // *** COMBINATORIAL LOGIC - NEXT STATE DETERMINATION
    // reg [PTR_WIDTH-1:0] rptr_g_next;
    wire [PTR_WIDTH-1:0] rptr_b_next; // WARNING: in Verilog you can't drive registers, you can only drive wires. You can do that in systemverilog.
    wire [PTR_WIDTH-1:0] rptr_g_next;
    wire [PTR_WIDTH-1:0] wptr_b_sync;
    wire rempty;

    gray2bin #(.N(PTR_WIDTH)) gray2bin_inst (.gray_in(wptr_g_sync_in), .bin_out(wptr_b_sync));
    assign rptr_b_next = rptr_b_out + {{{PTR_WIDTH-1}{1'b0}}, (read_in & !empty_out)};
    assign rptr_g_next = (rptr_b_next >> 1) ^ rptr_b_next;
    assign rempty = (wptr_b_sync == rptr_b_next);

    always @(posedge read_clk) begin
        if (~nrst_in)
            begin
            rptr_b_out <= 0;
            rptr_g_out <= 0;
            end
        else
            begin
            rptr_b_out <= rptr_b_next;
            rptr_g_out <= rptr_g_next;
            end
    end

    always @(posedge read_clk) begin
        if (~nrst_in)
            empty_out <= 1;
        else
            empty_out <= rempty;
    end
endmodule
