`timescale 1ns/10ps

/**
# Inputs and ouptus
Check draw-io diagram

ALWAYS EXTERNALLY

// **** READ MODULE
INPUTS:
    - clk_in
    - NRST
    - REN
    - WPTR_G_SYNC (comes from the synchronizer to check if fifo is full)
OUTPUTS:
    - rptr_b, EMPTY (to memory)
    - rptr_g (to synchronizer)

// **** WRITE MODULE
INPUTS:
    - clk_in
    - NRST
    - W_EN
    - RPTR_G_SYNC (comes from synchronizer to check if fifo is full)
OUTPUTS:
    - wptr_b, FULL (to memory)
    - wptr_g (fo synchronizer -> for read module)

// **** Synchronizers
// * Read synchronizer
INPUTS
    - NRST
    - clk_read (we have to stabilise with respect to this clock)
    - wptr_g
OUTPUTS
    - wptr_g_sync

// * Write synchronizer
INPUTS
    - NRST
    - clk_write (we have to stabilise with respect to this clock)
    - rptr_g
OUTPUTS
    - rptr_g_sync

// **** Memory module
INPUTS:
    - REN, W_EN (read / write signals)
    - read_NRST, write_NRST (separate read/write reset signals synced with their clock)
    - RCLK, WCLK (read / write clock signals)
    - W_DI (data to be written)
OUTPUTS:
    - R_DO (data to be read)
    - FULL, EMPTY (full / empty signals)
*/

module fifo_async_circular
    #(parameter DEPTH = 16,
    parameter WIDTH = 8)
(
    input RCLK, WCLK,
    input W_EN, REN,
    input WNRST, RNRST, //! NOTE: 2 reset signals present here.
    input [WIDTH-1:0] W_DI,
    output [WIDTH-1:0] R_DO,
    output FULL, EMPTY
);
    parameter PTR_WIDTH = $clog2(DEPTH-1)+1; // Necessary bits + 1
    wire [PTR_WIDTH-1:0] rptr_g, wptr_g;
    wire [PTR_WIDTH-1:0] rptr_b, wptr_b;
    wire [PTR_WIDTH-1:0] wptr_g_sync, rptr_g_sync;

    // READ PTR
    fifo_async_read_ptr #(.WIDTH(WIDTH), .PTR_WIDTH(PTR_WIDTH)) read_ptr
    (.RCLK(RCLK), .NRST(RNRST), .REN(REN),
    .WPTR_G_SYNC(wptr_g_sync),
    .RPTR_B(rptr_b), .RPTR_G(rptr_g),
    .EMPTY(EMPTY));

    // WRITE PTR
    fifo_async_write_ptr #(.WIDTH(WIDTH), .PTR_WIDTH(PTR_WIDTH)) write_ptr
    (.WCLK(WCLK), .NRST(WNRST), .W_EN(W_EN),
    .RPTR_G_SYNC(rptr_g_sync),
    .WPTR_B(wptr_b), .WPTR_G(wptr_g), .FULL(FULL));

    // READ PTR SYNC
    double_ff_sync #(.WIDTH(PTR_WIDTH)) read_sync
    (.CLK(WCLK), .NRST(WNRST), .D(rptr_g), .Q(rptr_g_sync));

    // WRITE PTR SYNC
    double_ff_sync #(.WIDTH(PTR_WIDTH)) write_sync
    (.CLK(RCLK), .NRST(RNRST), .D(wptr_g), .Q(wptr_g_sync));

    // MEMORY DECLARE
    fifo_memory #(.WIDTH(WIDTH), .DEPTH(DEPTH), .PTR_WIDTH(PTR_WIDTH)) fifo_memory_inst
    (.WCLK(WCLK), .W_EN(W_EN),
    .FULL(FULL), .EMPTY(EMPTY),
    .R_PTR(rptr_b), .W_PTR(wptr_b),
    .W_DI(W_DI), .R_DO(R_DO));
endmodule