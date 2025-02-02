`timescale 1ns/10ps



//! WARNING: LAST TEST ISN'T BEING RUN

module uart_tx_tb();

    // *** CONSTANTS
    // CLK INPUT TO UART RX
    localparam CLK_FREQ = 1_000_000_000; // Clock generated is 1 GHz
    localparam BAUD_RATE = 115200;
    localparam OVERSAMPLING_DIV = 8;
    localparam BAUD_OVERSAMPLED_TOGGLE_PERIOD = CLK_FREQ / (2 * BAUD_RATE * OVERSAMPLING_DIV) - 1;
    localparam BAUD_RATE_PERIOD = BAUD_OVERSAMPLED_TOGGLE_PERIOD * OVERSAMPLING_DIV * 2;

    // BITS
    localparam DATA_BITS = 8;
    // TESTS
    localparam N_TESTS = 16;
    localparam logic [7:0] TESTS_IN[15:0] = {
    8'h23, 8'h25, 8'hff, 8'h13,8'h00, 8'h11, 8'h99, 8'h11,
    8'h22, 8'hfa, 8'haf, 8'hba,8'hab, 8'h91, 8'h01, 8'h10
    };

    // *** REGISTERS
    reg clk = 1'b0;
    reg nrst_in = 1'b1;
    reg data_rdy_in = 1'b0;
    reg [DATA_BITS-1:0] tx_data_in;

    // For loop
    reg [DATA_BITS-1:0] tx_data_received = 0; // Holds received value

    // *** Wires
    wire tx_serial_out;
    wire tx_busy_out;
    wire tx_done_out;

    uart_tx #(.OVERSAMPLING(OVERSAMPLING_DIV),
    .DATA_BITS(DATA_BITS)) uart_tx_inst
    (
     .nrst_in(nrst_in),
     .clk_in(clk),
     .data_rdy_in(data_rdy_in),
     .tx_data_in(tx_data_in),
     .tx_serial_out(tx_serial_out),
     .tx_busy_out(tx_busy_out),
     .tx_done_out(tx_done_out)
    );

    always
        #(BAUD_OVERSAMPLED_TOGGLE_PERIOD) clk = ~clk;

    initial
        begin
            @(posedge clk);
            nrst_in <= 1;
            @(posedge clk);
            nrst_in <= 0;
            @(posedge clk);
            nrst_in <= 1;
            @(posedge clk);

            tx_data_in <= TESTS_IN[0];
            for (integer test_idx=0; test_idx<N_TESTS-1; test_idx = test_idx + 1)
            begin
                // Write starting bit and trigger send
                data_rdy_in <= 1'b1; // Keep data ready high to see if it can just keep sending.
                @(negedge tx_serial_out);
                tx_data_in <= TESTS_IN[test_idx+1]; // Put new data on start bit
                // Sample the data bits
                #(BAUD_RATE_PERIOD/2); // Wait for half a baud-rate period to sample in the center.
                for (int bit_idx = 0; bit_idx < DATA_BITS; bit_idx++) begin
                    #(BAUD_RATE_PERIOD);
                    tx_data_received[bit_idx] <= tx_serial_out;
                    end
                // Wait until the data ready is triggered
                @(posedge tx_done_out)
                if (tx_data_received != tx_data_in) $display("Test %d success!", test_idx+1);
                else $display("Test %d FAIL", test_idx);
                tx_data_received = 0;
            end
            $finish;
        end
endmodule
