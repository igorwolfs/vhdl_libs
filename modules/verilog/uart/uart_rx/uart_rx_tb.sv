`timescale 1ns/10ps


module uart_rx_tb();

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
    reg clk = 0;
    reg nrst_in = 1;
    reg rx_serial_in = 1;
    // For loop
    reg [DATA_BITS-1:0] TEST_OUT_TEMP_reg;
    reg [7:0] test_out;

    // *** Wires
    wire data_rdy_out;
    wire [DATA_BITS-1:0] rx_data_out;

    uart_rx #(.OVERSAMPLING(OVERSAMPLING_DIV),
                .DATA_BITS(DATA_BITS)) uart_rx_inst
                (.nrst_in(nrst_in),
                .clk_in(clk),
                .rx_serial_in(rx_serial_in),
                .data_rdy_out(data_rdy_out),
                .rx_data_out(rx_data_out));

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
        // **** TEST 1 ****
        for (int test_idx=0; test_idx<N_TESTS; test_idx = test_idx + 1)
            begin
            TEST_OUT_TEMP_reg <= TESTS_IN[test_idx];
            // Send start bit
            rx_serial_in <= 0;
            #BAUD_RATE_PERIOD;
            // Send data bits
            for (integer i=0; i < DATA_BITS; i=i+1) begin
                rx_serial_in <= TEST_OUT_TEMP_reg[i];
                #BAUD_RATE_PERIOD;
                end
            // Send stop bit
            rx_serial_in <= 1'b1;
            @(posedge data_rdy_out)
            test_out <= rx_data_out;
            #(2*BAUD_RATE_PERIOD);
            if (test_out == TEST_OUT_TEMP_reg) $display("Test %d success!", test_idx);
            else $display("Test %d FAIL", test_idx);
        end

        $finish;
    end

endmodule
