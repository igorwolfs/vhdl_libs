`timescale 1ns/10ps

// `define UART_APP
`define UART_SIM

module uart_rx_tb(
    //? >>> APP
`ifndef UART_SIM
    input NRST,
    input CLK,
    input RX_DSER,
    output reg [3:0] LED_O
`endif
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
    wire DIVPULSE;
    wire [DATA_BITS-1:0] uart_rx_data_out;
    wire uart_data_rdy_out;

    //! >>> SIMULATION
    `ifdef UART_SIM
    // TESTS
    localparam N_TESTS = 16;
    reg [DATA_BITS-1:0] test_data;

    // Registers
    reg CLK = 1'b0;
    reg NRST = 1'b1;
    reg RX_DSER = 1;

    always #5 CLK = ~CLK;
    `endif
    //! <<< SIMULATION

    baud_generator  #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLK_FREQ), .OVERSAMPLING_RATE(OVERSAMPLING_DIV)) baud_gen_inst (
        .BAUDPULSE(BAUDPULSE), .DIVPULSE(DIVPULSE), .CLK(CLK), .NRST(NRST));


    uart_rx #(.OVERSAMPLING(OVERSAMPLING_DIV), .DATA_BITS(DATA_BITS)) uart_rx_inst
                (.NRST(NRST), .CLK(CLK), .DIVPULSE(DIVPULSE),
                .RX_DSER(RX_DSER), .RX_DRDY(uart_data_rdy_out),
                .RX_DO(uart_rx_data_out));


    //! >>> SIMULATION
    `ifdef UART_SIM
    initial begin
        NRST <= 1;
        @(posedge CLK);
        NRST <= 0;
        @(posedge CLK);
        NRST <= 1;
        @(posedge CLK);
    end

    always @(posedge NRST) begin
        repeat(3) @(posedge CLK);
        // **** TEST 1 ****
        for (int test_idx=0; test_idx<N_TESTS; test_idx = test_idx + 1)
            begin
            @(posedge BAUDPULSE);
            test_data <= $urandom;
            // Send start bit
            RX_DSER <= 0;
            @(posedge BAUDPULSE);
            // Send data bits
            for (integer i=0; i < DATA_BITS; i=i+1) begin
                RX_DSER <= test_data[i];
                @(posedge BAUDPULSE);
            end
            // Send stop bit
            RX_DSER <= 1'b1;
            @(posedge uart_data_rdy_out)
            if (uart_rx_data_out == test_data) $display("Test %d success!", test_idx);
            else $display("Test %d FAIL", test_idx);
            $display("TEST: 0x%x - 0x%x", uart_rx_data_out, test_data);
        end
        $finish;
    end
    `else
    always @(posedge CLK)
    begin
        if (~NRST)
            begin
                LED_O <= 4'b1111;
            end
        else
            begin
                if (uart_data_rdy_out)
                begin
                    if ((uart_rx_data_out >= LED_1_CHAR_L) && (uart_rx_data_out <= LED_1_CHAR_U))
                            LED_O <= 4'b1000;
                    else if ((uart_rx_data_out >= LED_2_CHAR_L) && (uart_rx_data_out <= LED_2_CHAR_U))
                            LED_O <= 4'b0100;
                    else if ((uart_rx_data_out >= LED_3_CHAR_L) && (uart_rx_data_out <= LED_3_CHAR_U))
                            LED_O <= 4'b0010;
                    else if ((uart_rx_data_out >= LED_4_CHAR_L) && (uart_rx_data_out <= LED_4_CHAR_U))
                            LED_O <= 4'b0001;
                    else
                        LED_O <= 4'b1010;
                end
                else;
            end
    end
    `endif

endmodule
