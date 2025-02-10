`timescale 1ns/10ps



//! WARNING: LAST TEST ISN'T BEING RUN

module uart_tx_tb(
    //? >>> APP
    input nrst_in, // Reset input
    input [3:0] button_in, // Button input
    input sysclk, // Clock
    output uart_tx_serial_out, // uart data tx output
    output uart_tx_busy_out, // uart tx active output
    output uart_tx_done_out // uart tx done out
    //? <<< APP
);


    // *** CONSTANTS
    // CLK INPUT TO UART RX
    localparam CLK_FREQ = 100_000_000; // Clock generated is 1 GHz
    localparam BAUD_RATE = 115_200;
    localparam OVERSAMPLING_DIV = 8;

    // BITS
    localparam DATA_BITS = 8;


    // REGISTERS
    reg [DATA_BITS-1:0] tx_data_next;
    reg data_rdy_in = 1'b0;

    // WIRES
    wire div_pulse, baud_pulse;

    //! >>> TEST
    /*
    // CONSTANTS + ARRAYS
    localparam N_TESTS = 16;
    reg [DATA_BITS-1:0] wdata_q[$];
    localparam BAUD_RATE_TICKS = (1_000_000_000 / BAUD_RATE);

    // REGISTERS
    reg nrst_in = 1'b1;
    reg [DATA_BITS-1:0] tx_data_prev = 0;
    reg [DATA_BITS-1:0] tx_data_received = 0; // Holds received value
    reg toggle = 0;

    // WIRES
    wire uart_tx_serial_out, uart_tx_busy_out;
    wire uart_tx_done_out;

    // CLOCK
    reg sysclk = 1'b0;
    always #5 sysclk = ~sysclk;
    */
    //! <<< TEST

    baud_generator  #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLK_FREQ), .OVERSAMPLING_RATE(OVERSAMPLING_DIV)) baud_gen_inst (
        .baudpulse_out(baud_pulse), .divpulse_out(div_pulse), .clk_in(sysclk), .nrst_in(nrst_in));

    uart_tx #(.OVERSAMPLING(OVERSAMPLING_DIV),
    .DATA_BITS(DATA_BITS)) uart_tx_inst
    (
     .nrst_in(nrst_in), .baudpulse_in(baud_pulse), .sysclk_in(sysclk),
     .data_rdy_in(data_rdy_in),
     .tx_data_in(tx_data_next), 
     .tx_serial_out(uart_tx_serial_out),
     .tx_done_out(uart_tx_done_out),
     .tx_busy_out(uart_tx_busy_out)
    );

    //! >>> TEST SEQUENCE
    /*
    initial
        begin
            @(posedge sysclk);
            nrst_in <= 1;
            @(posedge sysclk);
            nrst_in <= 0;
            @(posedge sysclk);
            nrst_in <= 1;
            @(posedge sysclk);
            @(posedge baud_pulse);
            // Continuous transmit
            tx_data_next = $urandom;
            for (integer test_idx=0; test_idx<=N_TESTS-1; test_idx = test_idx + 1)
            begin
                data_rdy_in <= 1'b1;
                @(negedge uart_tx_serial_out);
                // data_rdy_in <= 1'b0;
                // Save this data for comparison.
                tx_data_prev <= tx_data_next;
                tx_data_next <= $urandom; // Put new data on start bit
                #(BAUD_RATE_TICKS/2)
                // Sample the data bits
                for (integer bit_idx = 0; bit_idx <= DATA_BITS-1; bit_idx = bit_idx+1)
                    begin
                    #BAUD_RATE_TICKS;
                    tx_data_received[bit_idx] <= tx_serial_out;
                    toggle = ~toggle;
                    end
                // Wait until the data ready is triggered
                @(negedge uart_tx_done_out);
                if (tx_data_received == tx_data_prev) $display("Test %d success!", test_idx+1);
                else $display("Test %d FAIL", test_idx);
            end

            data_rdy_in <= 1'b0;
            $finish;
        end
    */
    //! <<< TEST SEQUENCE

    //? >>> APP SEQUENCE
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
    // Should divide the clock by CLOCK_PERIOD_NS
    NOTE: Inputs should be driven only by a single signal.
    Which is why we wrote the reset signal in both always-blocks.
    **/

    /*
    1. A button press happens
    2. A message needs to be written to the tx buffer according to the button press
    3. The message needs to be sent
    There are just 2 states:
        - The buffer is full -> we continue sending
        - The buffer is not full -> we check the button switch-case
                - If button: fill, wait clock cycle, continue to sending
    */

    always @(posedge sysclk) begin
        if (~nrst_in)
            begin
            data_rdy_in <= 1'b0;
            count_default_send_reg <= 0;
            end

        else if (uart_tx_busy_out == 0) begin
            case (button_in)
                BUTTON_1:
                        begin
                        count_default_send_reg <= 0;
                        tx_data_next <= BUTTON_1_CHAR; //8'h97;
                        data_rdy_in   <= 1'b1; // Indicate start send
                        end
                BUTTON_2:
                        begin
                        count_default_send_reg <= 0;
                        tx_data_next <= BUTTON_2_CHAR;
                        data_rdy_in   <= 1'b1; // Indicate start send
                        end
                BUTTON_3:
                        begin
                        count_default_send_reg <= 0;
                        tx_data_next <= BUTTON_3_CHAR;
                        data_rdy_in   <= 1'b1; // Indicate start send
                        end
                BUTTON_4:
                        begin
                        count_default_send_reg <= 0;
                        tx_data_next <= BUTTON_4_CHAR;
                        data_rdy_in   <= 1'b1; // Indicate start send
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
                            tx_data_next <= BUTTON_DEFAULT_CHAR; // Send dot
                            data_rdy_in   <= 1'b1; // Indicate start send
                            end
                        end
            endcase
        end
        // Future: make sure to end this only when the TX-done signal was raised
        else begin
            if (data_rdy_in == 1'b1)
            begin
                data_rdy_in <= 1'b0;
            end
        end
    end

    //? <<< APP SEQUENCE

endmodule
