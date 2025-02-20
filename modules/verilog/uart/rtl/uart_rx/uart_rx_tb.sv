`timescale 1ns/10ps


module uart_rx_tb(
    //? >>> APP
    input nrst_in,
    input sysclk,
    input uart_rx_serial_in,
    output reg [3:0] led_out
    //? <<< APP
);

    // *******************************
    // CLK INPUT TO UART RX
    localparam CLK_FREQ = 100_000_000; // Clock generated is 1 GHz
    localparam BAUD_RATE = 115_200;
    localparam OVERSAMPLING_DIV = 8;

    // *******************************
    // BUTTONS
    // UPPERCASE LETTERS
    localparam LED_1_CHAR_L = 8'h41;
    localparam LED_1_CHAR_U = 8'h5A;
    
    // LOWERCASE LETTERS
    localparam LED_2_CHAR_L = 8'h61;
    localparam LED_2_CHAR_U = 8'h7A;
    
    // NUMBERS
    localparam LED_3_CHAR_L = 8'h30;
    localparam LED_3_CHAR_U = 8'h39;
    
    // RANDOM SIGNS
    localparam LED_4_CHAR_L = 8'h20;
    localparam LED_4_CHAR_U = 8'h2F;


    // BITS
    localparam DATA_BITS = 8;

    // *** Wires
    wire divpulse_out;
    wire [DATA_BITS-1:0] uart_rx_data_out;
    wire uart_data_rdy_out;

    //! >>> SIMULATION
    /*
    // TESTS
    localparam N_TESTS = 16;
    reg [DATA_BITS-1:0] test_data;

    // Registers
    reg sysclk = 0;
    reg nrst_in = 1;
    reg uart_rx_serial_in = 1;

    always #5 sysclk = ~sysclk;
    */
    //! <<< SIMULATION

    baud_generator  #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLK_FREQ), .OVERSAMPLING_RATE(OVERSAMPLING_DIV)) baud_gen_inst (
        .baudpulse_out(baudpulse_out), .divpulse_out(divpulse_out), .clk_in(sysclk), .nrst_in(nrst_in));


    uart_rx #(.OVERSAMPLING(OVERSAMPLING_DIV), .DATA_BITS(DATA_BITS)) uart_rx_inst
                (.nrst_in(nrst_in), .sysclk_in(sysclk), .divpulse_in(divpulse_out),
                .rx_serial_in(uart_rx_serial_in), .data_rdy_out(uart_data_rdy_out),
                .rx_data_out(uart_rx_data_out));


    //! >>> SIMULATION
    /*
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
            uart_rx_serial_in <= 0;
            @(posedge baudpulse_out);
            // Send data bits
            for (integer i=0; i < DATA_BITS; i=i+1) begin
                uart_rx_serial_in <= test_data[i];
                @(posedge baudpulse_out);
            end
            // Send stop bit
            uart_rx_serial_in <= 1'b1;
            @(posedge uart_data_rdy_out)
            if (uart_rx_data_out == test_data) $display("Test %d success!", test_idx);
            else $display("Test %d FAIL", test_idx);
            $display("TEST: 0x%x - 0x%x", uart_rx_data_out, test_data);
        end
        $finish;
    end
       */
    //! >>> SIMULATION
    // ? >>> APP

    always @(posedge sysclk)
    begin
        if (~nrst_in)
            begin
                led_out <= 4'b1111;
            end
        else
            begin
                if (uart_data_rdy_out)
                begin
                    if ((uart_rx_data_out >= LED_1_CHAR_L) && (uart_rx_data_out <= LED_1_CHAR_U))
                            led_out <= 4'b1000;
                    else if ((uart_rx_data_out >= LED_2_CHAR_L) && (uart_rx_data_out <= LED_2_CHAR_U))
                            led_out <= 4'b0100;
                    else if ((uart_rx_data_out >= LED_3_CHAR_L) && (uart_rx_data_out <= LED_3_CHAR_U))
                            led_out <= 4'b0010;
                    else if ((uart_rx_data_out >= LED_4_CHAR_L) && (uart_rx_data_out <= LED_4_CHAR_U))
                            led_out <= 4'b0001;
                    else
                        led_out <= 4'b1010;
                end
                else;
            end
    end
        // ? <<< APP

endmodule
