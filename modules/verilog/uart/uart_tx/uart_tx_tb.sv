`timescale 1ns/10ps



//! WARNING: LAST TEST ISN'T BEING RUN

module uart_tx_tb();

    // *** CONSTANTS
    // CLK INPUT TO UART RX
    localparam CLK_FREQ = 100_000_000; // Clock generated is 1 GHz
    localparam BAUD_RATE = 115_200;
    localparam OVERSAMPLING_DIV = 8;

    // BITS
    localparam DATA_BITS = 8;

    // TESTS
    localparam N_TESTS = 16;
    reg [DATA_BITS-1:0] wdata_q[$];

    // *** REGISTERS
    reg sysclk = 1'b0, nrst_in = 1'b1, data_rdy_in = 1'b0;
    reg [DATA_BITS-1:0] tx_data_next, tx_data_prev;

    // For loop
    reg [DATA_BITS-1:0] tx_data_received = 0; // Holds received value
    reg toggle = 0;
    // *** Wires
    wire tx_serial_out, tx_busy_out, tx_done_out, baud_clk, div_clk;

    always #5 sysclk = ~sysclk;
    baud_generator  #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLK_FREQ), .OVERSAMPLING_RATE(OVERSAMPLING_DIV)) baud_gen_inst (
        .baudclk_out(baud_clk), .divclk_out(div_clk), .clk_in(sysclk), .nrst_in(nrst_in));

    uart_tx #(.OVERSAMPLING(OVERSAMPLING_DIV),
    .DATA_BITS(DATA_BITS)) uart_tx_inst
    (
     .nrst_in(nrst_in), .baudclk_in(baud_clk), .sysclk_in(sysclk),
     .data_rdy_in(data_rdy_in),
     .tx_data_in(tx_data_next), .tx_serial_out(tx_serial_out),
     .tx_busy_out(tx_busy_out), .tx_done_out(tx_done_out)
    );
    initial
        begin
            @(posedge sysclk);
            nrst_in <= 1;
            @(posedge sysclk);
            nrst_in <= 0;
            @(posedge sysclk);
            nrst_in <= 1;
            @(posedge sysclk);
            @(posedge baud_clk);
            // Continuous transmit
            tx_data_next = $urandom;
            for (integer test_idx=0; test_idx<=N_TESTS-1; test_idx = test_idx + 1)
            begin
                data_rdy_in <= 1'b1;
                @(negedge tx_serial_out);
                data_rdy_in <= 1'b0;
                // Save this data for comparison.
                tx_data_prev <= tx_data_next;
                tx_data_next <= $urandom; // Put new data on start bit
                @(negedge baud_clk)
                // Sample the data bits
                for (integer bit_idx = 0; bit_idx <= DATA_BITS-1; bit_idx = bit_idx+1)
                    begin
                    @(negedge baud_clk);
                    tx_data_received[bit_idx] <= tx_serial_out;
                    toggle = ~toggle;
                    end
                // Wait until the data ready is triggered
                @(negedge tx_done_out);
                if (tx_data_received == tx_data_prev) $display("Test %d success!", test_idx+1);
                else $display("Test %d FAIL", test_idx);
            end

            data_rdy_in <= 1'b0;
            $finish;
        end
endmodule
