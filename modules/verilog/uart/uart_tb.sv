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
    localparam BAUD_RATE_PERIOD = CLK_FREQUENCY/115200;

    // TESTING
    localparam N_TESTS = 16;
    localparam logic [7:0] TESTS_IN[15:0] = {
    8'h23, 8'h25, 8'hff, 8'h13,8'h00, 8'h11, 8'h99, 8'h11,
    8'h22, 8'hfa, 8'haf, 8'hba,8'hab, 8'h91, 8'h01, 8'h10
    };
    
    reg [DATA_BITS-1:0] tx_data_next;
    reg [DATA_BITS-1:0] tx_data_prev;
    
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
    .clk(clk),
    .nrst_in(nrst_in),
    // TX
    .data_rdy_in(data_rdy_in),
    .tx_data_in(tx_data_in),
    .tx_done_out(tx_done_out),
    .tx_serial_out(tx_serial_out), //! MUST BE A PIN
    // RX
    .rx_serial_in(rx_serial_in), //! MUST BE A PIN
    .rx_data_out(rx_data_out),
    .data_rdy_out(data_rdy_out)
    );

    always
        #5 clk = ~clk; // 10 ns clock


initial
    begin
        #(2*BAUD_RATE_PERIOD);
        nrst_in <= 1;
        #(2*BAUD_RATE_PERIOD);
        nrst_in <= 0;
        #(2*BAUD_RATE_PERIOD);
        nrst_in <= 1;

       for (integer test_idx=0; test_idx<=N_TESTS-1; test_idx = test_idx + 1)
        begin

            tx_data_in <= TESTS_IN[test_idx];
            // Write starting bit and trigger send
            data_rdy_in <= 1'b1; // Keep data ready high to see if it can just keep sending.
            @(negedge tx_serial_out);
            // data_rdy_in <= 1'b0;

            @(posedge data_rdy_out);
            if (rx_data_out == TESTS_IN[test_idx]) $display("Test %d success!", test_idx+1);
            else $display("Test %d FAIL", test_idx);
        end
        data_rdy_in <= 1'b0;
        $finish;
    end

endmodule
