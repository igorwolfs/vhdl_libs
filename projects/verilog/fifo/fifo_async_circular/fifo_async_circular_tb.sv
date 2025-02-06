`timescale 1ns/10ps

/*
// *** TESTING PROCEDURE ***
// ** VARS
- reset signal
// READ
- Read data
- Read data clock
- Read data enabled
- Empty_out
// WRITE
- Write data
- Write data clock
- Write data enabled
- Full_out
// **** PROCESS
1. Create 2 clocks, a read and write clock (make sure their period can be varied)
2. Create a write array of data to write
3. Reset read and write
4. Create 2 always blocks, one for reading and one for writing, each with their own clock.
5. Check if the read-data corresponds to the written data
*/


module fifo_async_circular_tb ();
    // *** DEPTH / WIDTH
    localparam DEPTH = 16; // Try
    localparam WIDTH = 8;
    localparam READ_CLK_PERIOD = 10;
    localparam WRITE_CLK_PERIOD = 20;

    // *** TESTS
    localparam N_TESTS = 16;
    localparam logic [WIDTH-1:0] TESTS_IN[15:0] = {
        8'h23, 8'h25, 8'hff, 8'h13, 8'h00, 8'h11, 8'h99, 8'h11,
        8'h22, 8'hfa, 8'haf, 8'hba, 8'hab, 8'h91, 8'h01, 8'h10
    };

    // *** REGISTERS
    //! WARNING: MAKE SURE TO ALWAYS PREDEFINE ALL YOUR REGISTERS NAMES
    // * clocks
    reg read_clk = 0;
    always #(READ_CLK_PERIOD/2) read_clk = ~read_clk;

    reg write_clk = 0;
    always #(WRITE_CLK_PERIOD/2) write_clk = ~write_clk;

    // *** DATA
    reg [WIDTH-1:0] data_write_in = 0;
    reg w_nrst_in = 0, r_nrst_in = 0;
    wire [WIDTH-1:0] data_read_out;
    wire full_out, empty_out;
    reg write_in = 0, read_in = 0;


    // *** FIFO Creation
    fifo_async_circular #(.DEPTH(DEPTH), .WIDTH(WIDTH)) async_fifo (
    .read_clk(read_clk), .write_clk(write_clk),
    .write_in(write_in), .read_in(read_in),
    .w_nrst_in(w_nrst_in), .r_nrst_in(r_nrst_in),
    .data_write_in(data_write_in), .data_read_out(data_read_out),
    .full_out(full_out), .empty_out(empty_out));

    // *** TEST BLOCKS
    // * WRITE BLOCK
    initial
    begin
        @(posedge write_clk);
        w_nrst_in <= 1;
        @(posedge write_clk);
        w_nrst_in <= 0;
        @(posedge write_clk);
        w_nrst_in <= 1;
        repeat(10) @(posedge write_clk);
        for (int i=0; i<N_TESTS*2; i++)
            begin
            data_write_in <= TESTS_IN[i];
            write_in <= 1;
            @(posedge write_clk);
            if (!full_out)
                begin
                $display("Data %d written to buffer, full: %d", i, full_out);
                $display("Data %d written to buffer, full: %d", i, full_out);
                // write_in <= 0;
                // @(posedge write_clk);
                end
            else
                $display("BUFFER IS FULL %d", i);
            end
        write_in <= 0;

        @(posedge read_clk);
        for (int i=0; i<N_TESTS*2; i++)
            begin
            read_in <= 1;
            @(posedge read_clk);
            if (!empty_out)
                begin
                if (data_read_out == TESTS_IN[i]) $display("Read test OK %d", i);
                else  $display("read Test FAIL %d", i);
                end
            else
                $display("Buffer EMTPY! %d", i);
            end
    end

    // * READ BLOCK
    initial
    begin
        @(posedge read_clk);
        r_nrst_in <= 1;
        @(posedge read_clk);
        r_nrst_in <= 0;
        @(posedge read_clk);
        r_nrst_in <= 1;
        @(posedge read_clk);
    end

endmodule
