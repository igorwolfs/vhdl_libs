`timescale 1ns/10ps

/*
// *** TESTING PROCEDURE ***
// ** VARS
- reset signal
// READ
- Read data
- Read data clock
- Read data enabled
- EMPTY
// WRITE
- Write data
- Write data clock
- Write data enabled
- FULL
// **** PROCESS
1. Create 2 clocks, a read and write clock (make sure their period can be varied)
2. Create a write array of data to write
3. Reset read and write
4. Create 2 always blocks, one for reading and one for writing, each with their own clock.
5. Check if the read-data corresponds to the written data
*/


module fifo_simple_tb ();
    // *** DEPTH / WIDTH
    localparam DEPTH = 16; // Try
    localparam WIDTH = 8;
    localparam RCLK_PERIOD = 10;
    localparam WCLK_PERIOD = 20;

    // *** TESTS
    localparam N_TESTS = 16;
    localparam logic [WIDTH-1:0] TESTS_IN[15:0] = {
        8'h23, 8'h25, 8'hff, 8'h13, 8'h00, 8'h11, 8'h99, 8'h11,
        8'h22, 8'hfa, 8'haf, 8'hba, 8'hab, 8'h91, 8'h01, 8'h10
    };

    // *** REGISTERS
    //! WARNING: MAKE SURE TO ALWAYS PREDEFINE ALL YOUR REGISTERS NAMES
    // * clocks
    reg RCLK = 0;
    always #(RCLK_PERIOD/2) RCLK <= ~RCLK;

    reg WCLK = 0;
    always #(WCLK_PERIOD/2) WCLK <= ~WCLK;

    // *** DATA
    reg [WIDTH-1:0] W_DI = 0;
    reg [WIDTH-1:0] R_DO=0;
    reg WNRST = 0, RNRST = 0;
    wire FULL, EMPTY;
    reg W_EN = 0, REN = 0;


    // *** FIFO Creation
    fifo_async_circular #(.DEPTH(DEPTH), .WIDTH(WIDTH)) async_fifo (
    .RCLK(RCLK), .WCLK(WCLK),
    .W_EN(W_EN), .REN(REN),
    .WNRST(WNRST), .RNRST(RNRST),
    .W_DI(W_DI), .R_DO(R_DO),
    .FULL(FULL), .EMPTY(EMPTY));

    // *** TEST BLOCKS
    // * WRITE BLOCK
    always @(posedge RNRST)
    begin
        repeat(10) @(posedge WCLK);
        for (int i=0; i<N_TESTS; i++)
            begin
            W_DI = TESTS_IN[i];
            W_EN = 1;
            @(posedge WCLK);
            if (!FULL)
                begin
                $display("Data %d written to buffer, full: %d", i, FULL);
                $display("Data %d written to buffer, full: %d", i, FULL);
                // W_EN <= 0;
                // @(posedge WCLK);
                end
            else
                $display("BUFFER IS FULL %d", i);
            end
        W_EN = 0;

        @(posedge RCLK);
        for (int i=0; i<N_TESTS; i++)
            begin
            @(posedge RCLK);
            if (!EMPTY)
                begin
                REN = 1;
                if (R_DO == TESTS_IN[i]) $display("Read test OK %d", i);
                else  $display("read Test FAIL %d", i);
                end
            else
                begin
                REN = 0;
                $display("Buffer EMTPY! %d", i);
                end
            end
        $finish;
    end

    // * READ BLOCK
    initial
    begin
        @(posedge RCLK);
        @(posedge WCLK);
        WNRST = 1;
        RNRST = 1;
        @(posedge RCLK);
        @(posedge WCLK);
        WNRST = 1;
        RNRST = 0;
        @(posedge RCLK);
        @(posedge WCLK);
        WNRST = 1;
        RNRST = 1;
        @(posedge RCLK);
        @(posedge WCLK);
    end

endmodule
