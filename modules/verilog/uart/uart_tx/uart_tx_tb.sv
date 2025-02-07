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
    reg [DATA_BITS-1:0] wdata_q[$], test_data;

    // *** REGISTERS
    reg sysclk = 1'b0;
    reg nrst_in = 1'b1;
    reg data_rdy_in = 1'b0;
    reg [DATA_BITS-1:0] tx_data_next;
    reg [DATA_BITS-1:0] tx_data_prev;

    // For loop
    reg [DATA_BITS-1:0] tx_data_received = 0; // Holds received value

    // *** Wires
    wire tx_serial_out, tx_busy_out, tx_done_out;

    always #5 sysclk = ~sysclk;
    baud_generator  #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLK_FREQ), .OVERSAMPLING_RATE(OVERSAMPLING_DIV)) baud_gen_inst (
        .baudclk_out(baud_clk), .divclk_out(div_clk), .clk_in(sysclk), .nrst_in(nrst_in));

    uart_tx #(.OVERSAMPLING(OVERSAMPLING_DIV),
    .DATA_BITS(DATA_BITS)) uart_tx_inst
    (
     .nrst_in(nrst_in),
     .clk_in(clk),
     .data_rdy_in(data_rdy_in),
     .tx_data_in(tx_data_next),
     .tx_serial_out(tx_serial_out),
     .tx_busy_out(tx_busy_out),
     .tx_done_out(tx_done_out)
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

            tx_data_next = $urandom;
            for (integer test_idx=0; test_idx<=N_TESTS-1; test_idx = test_idx + 1)
            begin
                // Write starting bit and trigger send
                data_rdy_in <= 1'b1; // Keep data ready high to see if it can just keep sending.
                @(negedge tx_serial_out);
                // Save this data for comparison.
                tx_data_prev <= tx_data_next;
                tx_data_next <= $urandom; // Put new data on start bit

                // Sample the data bits
                #(BAUD_RATE_PERIOD/2); // Wait for half a baud-rate period to sample in the center.
                for (int bit_idx = 0; bit_idx < DATA_BITS; bit_idx++) begin
                    #(BAUD_RATE_PERIOD);
                    tx_data_received[bit_idx] <= tx_serial_out;
                    end
                // Wait until the data ready is triggered
                @(posedge tx_done_out)
                if (tx_data_received == tx_data_prev) $display("Test %d success!", test_idx+1);
                else $display("Test %d FAIL", test_idx);
                tx_data_received = 0;
            end

            $finish;
        end
endmodule
