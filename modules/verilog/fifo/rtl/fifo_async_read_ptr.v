`timescale 1ns/10ps

/**
Read pointer
- IN:Takes a clock input from the read-side
- IN: Takes a write-pointer from the write side that went through the sync
- IN: takes a nrst signal
- IN: Takes a REN signal to signify when someone wants to read on the next clock-cycle
- OUT: Outputs the read pointer to the syncer -> which then goes to the write-side
- OUT: Outputs an empty-signal when reading is impossible due to the buffer being empty


*/

module fifo_async_read_ptr #(parameter WIDTH=8, parameter PTR_WIDTH=3)
    (
        input RCLK, NRST, REN,
        input [PTR_WIDTH-1:0] WPTR_G_SYNC,
        output reg [PTR_WIDTH-1:0] RPTR_B, RPTR_G,
        output reg EMPTY
    );

    // *** COMBINATORIAL LOGIC - NEXT STATE DETERMINATION
    // reg [PTR_WIDTH-1:0] rptr_g_next;
    wire [PTR_WIDTH-1:0] rptr_b_next; // WARNING: in Verilog you can't drive registers, you can only drive wires. You can do that in systemverilog.
    wire [PTR_WIDTH-1:0] rptr_g_next;
    wire [PTR_WIDTH-1:0] wptr_b_sync;
    wire rempty;

    gray2bin #(.N(PTR_WIDTH)) gray2BIst (.GI(WPTR_G_SYNC), .BO(wptr_b_sync));
    assign rptr_b_next = RPTR_B + {{{PTR_WIDTH-1}{1'b0}}, (REN & !EMPTY)};
    assign rptr_g_next = (rptr_b_next >> 1) ^ rptr_b_next;
    assign rempty = (wptr_b_sync == rptr_b_next);

    always @(posedge RCLK) begin
        if (~NRST)
            begin
            RPTR_B <= 0;
            RPTR_G <= 0;
            end
        else
            begin
            RPTR_B <= rptr_b_next;
            RPTR_G <= rptr_g_next;
            end
    end

    always @(posedge RCLK) begin
        if (~NRST)
            EMPTY <= 1;
        else
            EMPTY <= rempty;
    end
endmodule
