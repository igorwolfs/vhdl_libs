`timescale 1ns/10ps

/**
Read pointer
- IN:Takes a clock input from the write-side
- IN: Takes a read-pointer from the read side that went through the sync
- IN: takes a nrst signal
- IN: Takes a write_in signal to signify when someone wants to read on the next clock-cycle
- OUT: Outputs write read pointer to the syncer -> which then goes to the read-side
- OUT: Outputs an full-signal when writing is impossible due to the buffer being full
*/

module fifo_async_write_ptr #(parameter WIDTH=8, parameter PTR_WIDTH=3)
    (
        input clk_in,
        input nrst_in,
        input write_in,
        input [PTR_WIDTH-1:0] rptr_g_sync_in,
        output reg [PTR_WIDTH-1:0] wptr_b_out, wptr_g_out,
        output full_out
    );

    /*
    reg [PTR_WIDTH-1:0] wptr_b_next;
    reg [PTR_WIDTH-1:0] wptr_g_next;
    reg wrap_around;
    */
    // *** COMBINATORIAL LOGIC - NEXT STATE DETERMINATION
    wire [PTR_WIDTH-1:0] wptr_b_next;
    wire [PTR_WIDTH-1:0] wptr_g_next;
    wire wrap_around;
    wire wfull;
    wire [PTR_WIDTH-1:0] rptr_b_sync;

    gray2bin #(.N(PTR_WIDTH)) gray2bin_inst (.gray_in(rptr_g_sync_in), .gray_out(rptr_b_sync));

    // Increment if not full and write enabled
    assign wptr_b_next = wptr_b_out + (write_in & !full_out);
    // bin2gray
    assign wptr_g_next = (wptr_b_next >> 1) ^ wptr_b_next;

    // wrap_around == 1 if the MSB is positive (write is ahead of read -> buffer is full)
    // assign wrap_around = rptr_b_sync[PTR_WIDTH-1] ^ wptr_b_out[PTR_WIDTH-1];
    // Full if wrap around and read and write pointers are equal
    // assign wfull = wrap_around & (rptr_b_sync[PTR_WIDTH-2:0] == wptr_b_out[PTR_WIDTH-2:0]);

    always @(posedge clk_in or negedge nrst_in)
    begin
        if (~nrst_in)
            begin
            wptr_b_out <= 0;
            wptr_g_out <= 0;
            full_out <= 0;
            end
        else
            begin
            wptr_b_out <= wptr_b_next;
            wptr_g_out <= wptr_g_next;
            // Assigned to wptr_b_out in the next cycle
            if ((wptr_b_next [PTR_WIDTH-2:0] == rptr_b_sync[PTR_WIDTH-2:0]) & ((rptr_b_sync[PTR_WIDTH-1] ^ wptr_b_next[PTR_WIDTH-1])))
                full_out <= 1;
            else
                full_out <= 0;
    end
    // always @(posedge clk_in or negedge nrst_in)
    // begin
    //     if (~nrst_in)
    //         full_out <= 0;
    //     else
    //         full_out <= wfull;
    // end

endmodule


/**
Source: https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/
*/