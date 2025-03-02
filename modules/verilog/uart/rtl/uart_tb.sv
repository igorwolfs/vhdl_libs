`timescale 1ns/10ps

/**
# TEST BENCH FOR COMBINED UART MODULE
Simple echo app which saves what is received by UART and sends it back after a few clock-ticks.

*/

`define UART_SIM


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
    reg nrst = 1'b1;
    reg clk = 1'b0;

    // Used to control peripheral
    // TX
    reg   tx_drdy = 0;
    reg   [(DATA_BITS-1):0] tx_di;
    wire  tx_done;
    wire  tx_dser;

    // RX
    wire rx_dser; //! Must be a pin
    wire [(DATA_BITS-1):0] rx_do;
    wire rx_drdy;

    assign rx_dser = tx_dser;

    uart #(.CLOCK_FREQUENCY(CLK_FREQUENCY),
            .BAUD_RATE(BAUD_RATE),
            .DATA_BITS(DATA_BITS)) uart_inst
    (
    .CLK(clk), .NRST(nrst),
    // TX
    .TX_DRDY(tx_drdy), .TX_DI(tx_di),
    .TX_DONE(tx_done), .TX_DSER(tx_dser), //! MUST BE A PIN
    // RX
    .RX_DSER(rx_dser), //! MUST BE A PIN
    .RX_DO(rx_do), .RX_DRDY(rx_drdy)
    );

    always
        #5 clk = ~clk; // 10 ns clock

initial
    begin
        #BAUD_RATE_PERIOD_TICKS;
        nrst = 1;
        #BAUD_RATE_PERIOD_TICKS;
        nrst = 0;
        #BAUD_RATE_PERIOD_TICKS;
        nrst = 1;
    end


reg [31:0] tx_di32;

always @(posedge nrst) begin
        #BAUD_RATE_PERIOD_TICKS;
        #BAUD_RATE_PERIOD_TICKS;

        tx_di32 = $urandom;
        tx_di = tx_di32[7:0];
        wdata_q.push_back(tx_di);

        tx_drdy <= 1'b1; // Keep data ready high to see if it can just keep sending.
        for (integer test_idx=0; test_idx<=N_TESTS-1; test_idx = test_idx + 1)
        begin
            // Write starting bit and trigger send
            @(negedge tx_dser); // Start bit occurred
            tx_di32 = $urandom;
            tx_di = tx_di32[7:0];
            wdata_q.push_back(tx_di);

            @(posedge rx_drdy);
            if (rx_do == wdata_q[test_idx]) $display("Test %d success!", test_idx);
            else $display("Test %d FAIL 0x%x != 0x%x", test_idx, rx_do, wdata_q[test_idx]);
        end
        tx_drdy <= 1'b0;
        $finish;
    end

endmodule


/**
MAJOR WARNING: make sure when appending tests to an array, your logic is combinatorial. 
You should EITHER
- have a blocking assignment "=" assigning your test to the tx_input of your uart
- OR have a non-blocking assignment "<=" with a clk-edge between your assignment and your appending it to the array.
*/