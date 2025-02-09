`timescale 1ns/10ps


module uart_rx_tb();

    // *** CONSTANTS
    // CLK INPUT TO UART RX
    localparam CLK_FREQ = 100_000_000; // Clock generated is 1 GHz
    localparam BAUD_RATE = 115_200;
    localparam OVERSAMPLING_DIV = 8;
    localparam BAUD_OVERSAMPLED_TOGGLE_PERIOD = CLK_FREQ / (2 * BAUD_RATE * OVERSAMPLING_DIV) - 1;
    localparam BAUD_RATE_PERIOD = BAUD_OVERSAMPLED_TOGGLE_PERIOD * OVERSAMPLING_DIV * 2;

    // BITS
    localparam DATA_BITS = 8;
    // TESTS
    localparam N_TESTS = 16;
    reg [DATA_BITS-1:0] test_data;

    // *** REGISTERS
    reg sysclk = 0;
    reg nrst_in = 1;
    reg rx_serial_in = 1;

    // *** Wires
    wire baud_clk, divpulse_out, data_rdy_out;
    wire [DATA_BITS-1:0] rx_data_out;

    always #5 sysclk = ~sysclk;
    baud_generator  #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLK_FREQ), .OVERSAMPLING_RATE(OVERSAMPLING_DIV)) baud_gen_inst (
        .baudpulse_out(baudpulse_out), .divpulse_out(divpulse_out), .clk_in(sysclk), .nrst_in(nrst_in));


    uart_rx #(.OVERSAMPLING(OVERSAMPLING_DIV), .DATA_BITS(DATA_BITS), .SYSCLK(CLK_FREQ)) uart_rx_inst
                (.nrst_in(nrst_in), .sysclk_in(sysclk), .divpulse_in(divpulse_out),
                .rx_serial_in(rx_serial_in), .data_rdy_out(data_rdy_out), .rx_data_out(rx_data_out), .SM_DBG_CURR(SM_DBG_CURR));




    initial
    begin
        @(posedge sysclk);
        nrst_in <= 1;
        @(posedge sysclk);
        nrst_in <= 0;
        @(posedge sysclk);
        nrst_in <= 1;
        @(posedge sysclk)
        // **** TEST 1 ****
        for (int test_idx=0; test_idx<N_TESTS; test_idx = test_idx + 1)
            begin
            @(posedge baudpulse_out);
            test_data <= $urandom;
            // Send start bit
            rx_serial_in <= 0;
            @(posedge baudpulse_out);
            // Send data bits
            for (integer i=0; i < DATA_BITS; i=i+1) begin
                rx_serial_in <= test_data[i];
                @(posedge baudpulse_out);
            end
            // Send stop bit
            rx_serial_in <= 1'b1;
            @(posedge data_rdy_out)
            if (rx_data_out == test_data) $display("Test %d success!", test_idx);
            else $display("Test %d FAIL", test_idx);
            $display("TEST: 0x%x - 0x%x", rx_data_out, test_data);
        end
        $finish;
    end
endmodule
