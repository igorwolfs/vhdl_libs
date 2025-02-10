`timescale 1ns/10ps

/**
# Inputs and ouptus
Check draw-io diagram

ALWAYS EXTERNALLY

// **** READ MODULE
INPUTS:
    - clk_in
    - nrst_in
    - read_in
    - wptr_g_sync_in (comes from the synchronizer to check if fifo is full)
OUTPUTS:
    - rptr_b, empty_out (to memory)
    - rptr_g (to synchronizer)

// **** WRITE MODULE
INPUTS:
    - clk_in
    - nrst_in
    - write_in
    - rptr_g_sync_in (comes from synchronizer to check if fifo is full)
OUTPUTS:
    - wptr_b, full_out (to memory)
    - wptr_g (fo synchronizer -> for read module)

// **** Synchronizers
// * Read synchronizer
INPUTS
    - nrst_in
    - clk_read (we have to stabilise with respect to this clock)
    - wptr_g
OUTPUTS
    - wptr_g_sync

// * Write synchronizer
INPUTS
    - nrst_in
    - clk_write (we have to stabilise with respect to this clock)
    - rptr_g
OUTPUTS
    - rptr_g_sync

// **** Memory module
INPUTS:
    - read_in, write_in (read / write signals)
    - read_nrst_in, write_nrst_in (separate read/write reset signals synced with their clock)
    - read_clk, write_clk (read / write clock signals)
    - data_write_in (data to be written)
OUTPUTS:
    - data_read_out (data to be read)
    - full_out, empty_out (full / empty signals)
*/

module fifo_async_circular
    #(parameter DEPTH = 16,
    parameter WIDTH = 8)
(
    input read_clk, write_clk,
    input write_in, read_in,
    input w_nrst_in, r_nrst_in, //! NOTE: 2 reset signals present here.
    input [WIDTH-1:0] data_write_in,
    output [WIDTH-1:0] data_read_out,
    output full_out, empty_out
);
    parameter PTR_WIDTH = $clog2(DEPTH-1)+1; // Necessary bits + 1
    wire [PTR_WIDTH-1:0] rptr_g, wptr_g;
    wire [PTR_WIDTH-1:0] rptr_b, wptr_b;
    wire [PTR_WIDTH-1:0] wptr_g_sync, rptr_g_sync;
    // READ PTR
    fifo_async_read_ptr #(.WIDTH(WIDTH), .PTR_WIDTH(PTR_WIDTH)) read_ptr
    (.read_clk(read_clk), .nrst_in(r_nrst_in), .read_in(read_in),
    .wptr_g_sync_in(wptr_g_sync),
    .rptr_b_out(rptr_b), .rptr_g_out(rptr_g),
    .empty_out(empty_out));

    // WRITE PTR
    fifo_async_write_ptr #(.WIDTH(WIDTH), .PTR_WIDTH(PTR_WIDTH)) write_ptr
    (.write_clk(write_clk), .nrst_in(w_nrst_in), .write_in(write_in),
    .rptr_g_sync_in(rptr_g_sync),
    .wptr_b_out(wptr_b), .wptr_g_out(wptr_g), .full_out(full_out));

    // READ PTR SYNC
    double_ff_sync #(.WIDTH(PTR_WIDTH)) read_sync
    (.clkin(write_clk), .nrst_in(w_nrst_in), .data_in(rptr_g), .data_out(rptr_g_sync));

    // WRITE PTR SYNC
    double_ff_sync #(.WIDTH(PTR_WIDTH)) write_sync
    (.clkin(read_clk), .nrst_in(r_nrst_in), .data_in(wptr_g), .data_out(wptr_g_sync));

    // MEMORY DECLARE
    fifo_memory #(.WIDTH(WIDTH), .DEPTH(DEPTH), .PTR_WIDTH(PTR_WIDTH)) fifo_memory_inst
    (.write_clk(write_clk), .write_in(write_in),
    .full_in(full_out), .empty_in(empty_out),
    .read_ptr_in(rptr_b), .write_ptr_in(wptr_b),
    .data_write_in(data_write_in), .data_read_out(data_read_out));
endmodule