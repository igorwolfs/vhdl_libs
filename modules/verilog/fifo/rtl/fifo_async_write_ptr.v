`timescale 1ns/10ps

/**
Read pointer
- IN:Takes a clock input from the write-side
- IN: Takes a read-pointer from the read side that went through the sync
- IN: takes a nrst signal
- IN: Takes a W_EN signal to signify when someone wants to read on the next clock-cycle
- OUT: Outputs write read pointer to the syncer -> which then goes to the read-side
- OUT: Outputs an full-signal when writing is impossible due to the buffer being full
*/

module fifo_async_write_ptr #(parameter WIDTH=8, parameter PTR_WIDTH=3)
    (
        input WCLK,
        input NRST,
        input W_EN,
        input [PTR_WIDTH-1:0] RPTR_G_SYNC,
        output reg [PTR_WIDTH-1:0] WPTR_B, WPTR_G,
        output reg FULL
    );

    // *** COMBINATORIAL LOGIC - NEXT STATE DETERMINATION
    wire [PTR_WIDTH-1:0] wptr_b_next;
    wire [PTR_WIDTH-1:0] wptr_g_next;
    wire [PTR_WIDTH-1:0] rptr_b_sync;

    gray2bin #(.N(PTR_WIDTH)) gray2BIst (.GI(RPTR_G_SYNC), .BO(rptr_b_sync));

    // Increment if not full and write enabled
    assign wptr_b_next = WPTR_B + {{{PTR_WIDTH-1}{1'b0}}, (W_EN & !FULL)};
    // bin2gray
    assign wptr_g_next = (wptr_b_next >> 1) ^ wptr_b_next;

    // wrap_around == 1 if the MSB is positive (write is ahead of read -> buffer is full)
    // assign wrap_around = rptr_b_sync[PTR_WIDTH-1] ^ WPTR_B[PTR_WIDTH-1];
    // Full if wrap around and read and write pointers are equal
    // assign wfull = wrap_around & (rptr_b_sync[PTR_WIDTH-2:0] == WPTR_B[PTR_WIDTH-2:0]);

    always @(posedge WCLK)
    begin
        if (~NRST)
            begin
            WPTR_B <= 0;
            WPTR_G <= 0;
            FULL <= 0;
            end
        else
            begin
            WPTR_B <= wptr_b_next;
            WPTR_G <= wptr_g_next;
            // Assigned to WPTR_B in the next cycle
            if ((wptr_b_next [PTR_WIDTH-2:0] == rptr_b_sync[PTR_WIDTH-2:0]) & ((rptr_b_sync[PTR_WIDTH-1] ^ wptr_b_next[PTR_WIDTH-1])))
                FULL <= 1;
            else
                FULL <= 0;
            end
    end
endmodule


/**
Source: https://vlsiverify.com/verilog/verilog-codes/asynchronous-fifo/
*/