`timescale 1ns/10ps

// `define UART_APP
`define UART_SIM

//! WARNING: LAST TEST ISN'T BEING RUN

module uart_tx_tb(
    `ifndef UART_SIM
    //? >>> APP
    input NRST, // Reset input
    input [3:0] BUTTON_I, // Button input
    input CLK, // Clock
    output TX_DSER, // uart data tx output
    output TX_BUSY, // uart tx active output
    output NRST_LED_O
    //output uart_TX_DONE // uart tx done out
    //? <<< APP
    `endif /* UART_APP */
);


    // *** CONSTANTS
    // CLK INPUT TO UART RX
    localparam CLK_FREQ = 100_000_000; // Clock generated is 1 GHz
    localparam BAUD_RATE = 115_200;
    localparam OVERSAMPLING_DIV = 8;

    // BITS
    localparam DATA_BITS = 8;


    // REGISTERS
    reg [DATA_BITS-1:0] tx_dnext;
    reg TX_DRDY = 1'b0;

    // WIRES
    wire div_pulse, baud_pulse;

    //! >>> TEST
    `ifdef UART_SIM
    // CONSTANTS + ARRAYS
    localparam N_TESTS = 16;
    reg [DATA_BITS-1:0] wdata_q[$];
    localparam BAUD_RATE_TICKS = (1_000_000_000 / BAUD_RATE);

    // REGISTERS
    reg NRST = 1'b1;
    reg [DATA_BITS-1:0] tx_data_prev = 0;
    reg [DATA_BITS-1:0] tx_data_received = 0; // Holds received value
    reg toggle = 0;
    reg [31:0] tx32_dnext;
    // WIRES
    wire TX_DSER, TX_BUSY;
    wire uart_TX_DONE;

    // CLOCK
    reg CLK = 1'b0;
    always #5 CLK = ~CLK;

    `endif
    //! <<< TEST
    baud_generator  #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLK_FREQ), .OVERSAMPLING_RATE(OVERSAMPLING_DIV)) baud_gen_inst (
        .BAUDPULSE(baud_pulse), .DIVPULSE(div_pulse), .CLK(CLK), .NRST(NRST));

    uart_tx #(.OVERSAMPLING(OVERSAMPLING_DIV),
    .DATA_BITS(DATA_BITS)) uart_tx_inst
    (
     .NRST(NRST), .BAUDPULSE(baud_pulse), .CLK(CLK),
     .TX_DRDY(TX_DRDY),
     .TX_DI(tx_dnext),
     .TX_DSER(TX_DSER),
     .TX_DONE(uart_TX_DONE),
     .TX_BUSY(TX_BUSY)
    );
    initial begin
        NRST = 1;
        @(posedge CLK);
        NRST = 0;
        @(posedge CLK);
        NRST = 1;
        @(posedge CLK);
    end

    //! >>> TEST SEQUENCE
    `ifdef UART_SIM
    always @(negedge NRST)
        begin
            repeat(3) @(posedge CLK);
            @(posedge baud_pulse);
            // Continuous transmit
            tx32_dnext = $urandom;
            tx_dnext = tx32_dnext[7:0]; // Put new data on start bit
            for (integer test_idx=0; test_idx<=N_TESTS-1; test_idx = test_idx + 1)
            begin
                TX_DRDY <= 1'b1;
                @(negedge TX_DSER);
                // TX_DRDY <= 1'b0;
                // Save this data for comparison.
                tx_data_prev <= tx_dnext;
                tx32_dnext = $urandom;
                tx_dnext = tx32_dnext[7:0]; // Put new data on start bit
                #(BAUD_RATE_TICKS/2)
                // Sample the data bits
                for (integer bit_idx = 0; bit_idx <= DATA_BITS-1; bit_idx = bit_idx+1)
                    begin
                    #BAUD_RATE_TICKS;
                    tx_data_received[bit_idx] <= TX_DSER;
                    toggle = ~toggle;
                    end
                // Wait until the data ready is triggered
                @(negedge uart_TX_DONE);
                if (tx_data_received == tx_data_prev) $display("Test %d success!", test_idx+1);
                else $display("Test %d FAIL", test_idx);
            end

            TX_DRDY = 1'b0;
            $finish;
        end
    `endif
    //! <<< TEST SEQUENCE

    //? >>> APP SEQUENCE
    `ifndef UART_SIM

    assign NRST_LED_O = NRST;
    localparam DEFAULT_SEND_RATE        = 750_000;

    // *** Registers
    reg [$clog2(DEFAULT_SEND_RATE):0] count_default_send_reg = 0;

    // *******************************
    // BUTTONS
    localparam BUTTON_1      = 4'b0001;
    localparam BUTTON_1_CHAR = 8'h61;

    localparam BUTTON_2      = 4'b0010;
    localparam BUTTON_2_CHAR = 8'h62;

    localparam BUTTON_3      = 4'b0100;
    localparam BUTTON_3_CHAR = 8'h63;

    localparam BUTTON_4      = 4'b1000;
    localparam BUTTON_4_CHAR = 8'h64;

    localparam BUTTON_DEFAULT_CHAR = 8'h2E;

    /*
    Should divide the clock by CLOCK_PERIOD_NS
    NOTE: Inputs should be driven only by a single signal.
    Which is why we wrote the reset signal in both always-blocks.


    1. A button press happens
    2. A message needs to be written to the tx buffer according to the button press
    3. The message needs to be sent
    There are just 2 states:
        - The buffer is full -> we continue sending
        - The buffer is not full -> we check the button switch-case
                - If button: fill, wait clock cycle, continue to sending
    */

    always @(posedge CLK) begin
        if (~NRST)
            begin
            TX_DRDY <= 1'b0;
            count_default_send_reg <= 0;
            end

        else if (TX_BUSY == 0) begin
            case (BUTTON_I)
                BUTTON_1:
                        begin
                        count_default_send_reg <= 0;
                        tx_dnext <= BUTTON_1_CHAR; //8'h97;
                        TX_DRDY   <= 1'b1; // Indicate start send
                        end
                BUTTON_2:
                        begin
                        count_default_send_reg <= 0;
                        tx_dnext <= BUTTON_2_CHAR;
                        TX_DRDY   <= 1'b1; // Indicate start send
                        end
                BUTTON_3:
                        begin
                        count_default_send_reg <= 0;
                        tx_dnext <= BUTTON_3_CHAR;
                        TX_DRDY   <= 1'b1; // Indicate start send
                        end
                BUTTON_4:
                        begin
                        count_default_send_reg <= 0;
                        tx_dnext <= BUTTON_4_CHAR;
                        TX_DRDY   <= 1'b1; // Indicate start send
                        end
                // COUNT for 3 seconds and send a random message if nothing was sent in the meantime
                default:
                        begin
                        if (count_default_send_reg < DEFAULT_SEND_RATE-1)
                            begin
                            count_default_send_reg <= count_default_send_reg + 1;
                            end
                        else
                            begin
                            count_default_send_reg <= 0;
                            tx_dnext <= BUTTON_DEFAULT_CHAR; // Send dot
                            TX_DRDY   <= 1'b1; // Indicate start send
                            end
                        end
            endcase
        end
        // Future: make sure to end this only when the TX-done signal was raised
        else begin
            if (TX_DRDY == 1'b1)
            begin
                TX_DRDY <= 1'b0;
            end
        end
    end
    `endif
    //? <<< APP SEQUENCE

endmodule
