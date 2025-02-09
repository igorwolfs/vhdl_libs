`timescale 1ns/10ps

/**
# TEST BENCH FOR COMBINED UART MODULE
Simple echo app which saves what is received by UART and sends it back after a few clock-ticks.



*/

module uart_tb();
    // LOCAL PARAMETERS FOR TESTBENCH
    localparam DATA_BITS = 8;
    localparam BAUD_RATE = 115_200;
    localparam CLK_FREQUENCY = 100_000_000;
    //! WARNING, OFFSET HERE MIGHT BE TOO BIG, WAITING MIGHT NEED TO BE SYNCED TO BAUD CLOCK (but shouldn't be an issue normally)
    localparam BAUD_RATE_PERIOD_TICKS = (CLK_FREQUENCY/BAUD_RATE)*10; // x 10 due to ns reference

    // TESTING
    localparam N_TESTS = 16;
    reg [DATA_BITS-1:0] wdata_q[$];

    // RX AND TX
    reg nrst_in = 1;
    reg   clk = 0;

    // Used to control peripheral
    // TX
    reg   data_rdy_in = 0;
    reg   [(DATA_BITS-1):0] tx_data_in;
    wire  tx_done_out;
    wire  tx_serial_out;

    // RX
    wire rx_serial_in; //! Must be a pin
    wire [(DATA_BITS-1):0] rx_data_out;
    wire data_rdy_out;

    assign rx_serial_in = tx_serial_out;

    uart #(.CLOCK_FREQUENCY(CLK_FREQUENCY),
            .BAUD_RATE(BAUD_RATE),
            .DATA_BITS(DATA_BITS)) uart_inst
    (
    .clk(clk), .nrst_in(nrst_in),
    // TX
    .data_rdy_in(data_rdy_in), .tx_data_in(tx_data_in),
    .tx_done_out(tx_done_out), .tx_serial_out(tx_serial_out), //! MUST BE A PIN
    // RX
    .rx_serial_in(rx_serial_in), //! MUST BE A PIN
    .rx_data_out(rx_data_out), .data_rdy_out(data_rdy_out)
    );

    always
        #5 clk = ~clk; // 10 ns clock


initial
    begin
        #BAUD_RATE_PERIOD_TICKS;
        nrst_in <= 1;
        #BAUD_RATE_PERIOD_TICKS;
        nrst_in <= 0;
        #BAUD_RATE_PERIOD_TICKS;
        nrst_in <= 1;
        #BAUD_RATE_PERIOD_TICKS;

        tx_data_in = $urandom;
        wdata_q.push_back(tx_data_in);

        data_rdy_in <= 1'b1; // Keep data ready high to see if it can just keep sending.
        for (integer test_idx=0; test_idx<=N_TESTS-1; test_idx = test_idx + 1)
        begin
            // Write starting bit and trigger send
            @(negedge tx_serial_out); // Start bit occurred
            tx_data_in = $urandom; // Load new data already -> for continuous sending
            wdata_q.push_back(tx_data_in);

            @(posedge data_rdy_out);
            if (rx_data_out == wdata_q[test_idx]) $display("Test %d success!", test_idx);
            else $display("Test %d FAIL 0x%x != 0x%x", test_idx, rx_data_out, wdata_q[test_idx]);
        end
        data_rdy_in <= 1'b0;
        $finish;
    end

endmodule


/**
MAJOR WARNING: make sure when appending tests to an array, your logic is combinatorial. 
You should EITHER
- have a blocking assignment "=" assigning your test to the tx_input of your uart
- OR have a non-blocking assignment "<=" with a clk-edge between your assignment and your appending it to the array.
*/