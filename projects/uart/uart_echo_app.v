`timescale 1ns / 10ps


/*
INPUTS:
- Button (8 wires)
- i_TX_DV (triggers the UART to start sending)
- i_Clock: clock signal for UART

OUTPUTS:
- TX_Serial: Tx-pin on output
- TX_Active: Active debug pin on output

NOTE:
- 1 bit should be sent every 1/115200 seconds
*/

module uart_echo_app();
// ? >>> PHYSICAL IMPL
/*
(
    //! This is needed to make sure the module is in a defined state at start!
    // COMMON
    input nrst_in,
    input sysclk,

    // RX
    input rx_serial_in,

    // TX
    output tx_serial_out,
);
*/
// ? <<< PHYSICAL IMPL

    // *******************************
    // LOCAL PARAMETERS FOR TESTBENCH
    localparam DATA_BITS = 8;
    localparam BAUD_RATE = 115_200;
    localparam CLK_FREQUENCY = 100_000_000;

    // DEFINE FIFO DEPTH
    localparam DEPTH = 16;

    // *******************************
    wire full_out, empty_out;
    wire [DATA_BITS-1:0] data_in;
    wire [DATA_BITS-1:0] data_out;


    //! >>> SIMULATION CASE
    // PARAMETERS
    localparam N_TESTS = 16;
    
    // CLOCK DEFINITION
    // PARAM
    parameter BAUD_RATE_TICKS = (CLK_FREQUENCY / BAUD_RATE) * 10; // We're dealing with a ns clock
    reg sysclk = 0;
    always #5 sysclk = ~sysclk;
    
    reg [DATA_BITS-1:0] rdata_q[$], rx_test_byte;

    // RX INPUT
    reg rx_serial_in = 1;
    reg nrst_in = 0;
    
    // Wire
    wire tx_done_out;
    wire [DATA_BITS-1:0] rx_data_out;
    wire [DATA_BITS-1:0] tx_data_in;
    
    //! <<< SIMULATION CASE

    // *** REGISTERS
    reg data_rdy_in = 0;
    reg write_in = 0, read_in = 0;

    uart #(.CLOCK_FREQUENCY(CLK_FREQUENCY), .BAUD_RATE(BAUD_RATE), .DATA_BITS(DATA_BITS))
    uart_inst (.clk(sysclk), .nrst_in(nrst_in),
    // TX
    .data_rdy_in(data_rdy_in), .tx_data_in(tx_data_in),
    .tx_serial_out(tx_serial_out), .tx_done_out(tx_done_out), //! MUST BE A PIN
    // RX
    .rx_serial_in(rx_serial_in), .rx_data_out(rx_data_out), .data_rdy_out(data_rdy_out));

    // Sync the buffer with the sysclk for now, assuming we don't really need the asynchronous features.
    //! ERROR: The signal that makes the uart out write to the buffer is asserted for too long of a time, shorten it.
    // data_rdy_out should only be high for a single clock cycle, otherwise it keeps saving stuff
    
    fifo_async_circular #(.DEPTH(DEPTH), .WIDTH(DATA_BITS))
    fifo_async_circular_inst
            (.read_clk(sysclk), .write_clk(sysclk),
            .write_in(data_rdy_out), // Attempt to write data into buffer directly from UART.
            .read_in(read_in),
            .w_nrst_in(nrst_in), .r_nrst_in(nrst_in),
            // ECHO so in-> rx, OUT -> tx
            .data_write_in(rx_data_out), .data_read_out(tx_data_in),
            .full_out(full_out), .empty_out(empty_out));


    //! >>> SIMULATION CASE
    initial begin
        rx_serial_in <= 1;
        nrst_in <= 1;
        #BAUD_RATE_TICKS
        nrst_in <= 0;
        #BAUD_RATE_TICKS
        nrst_in <= 1;
        #BAUD_RATE_TICKS
        for (integer test_idx = 0; test_idx < N_TESTS; test_idx = test_idx + 1)
        begin
            rx_test_byte = $urandom;
            rdata_q.push_back(rx_test_byte);
            rx_serial_in <= 0;
            #BAUD_RATE_TICKS;
            for (integer i=0; i < DATA_BITS; i=i+1)
            begin
                rx_serial_in <= rx_test_byte[i];
                #BAUD_RATE_TICKS;
            end
            rx_serial_in <= 1;
            #BAUD_RATE_TICKS;
        end
    end

    // Every time data is sent over tx, it should be measured
    reg [DATA_BITS-1:0] tx_data_received;
    initial 
    begin
        for (integer test_idx = 0; test_idx < N_TESTS; test_idx = test_idx + 1)
        begin
            @(negedge tx_serial_out);
            #(BAUD_RATE_TICKS/2);
            for (integer i=0; i < DATA_BITS; i=i+1)
                begin
                #BAUD_RATE_TICKS;
                tx_data_received[i] <= tx_serial_out;
                end
            @(negedge tx_done_out)
            if (tx_data_received == rdata_q[test_idx]) $display("Test %d success!", test_idx+1);
            else $display("Test %d FAIL", test_idx);
        end
        // WAIT HERE UNTIL TDATA ARRAY FILLS UP
        // COMPARE TDATA ARRAY WITH RDATA ARRAY
    end
    //! <<< SIMULATION CASE

    /**
    If the buffer is not empty
        - Take data from the buffer
        - Write it to the fifo
    */
    always @(posedge sysclk)
    begin
        if (!empty_out)
            data_rdy_in <= 1'b1;
        else
            data_rdy_in <= 1'b0;
    end

    // PART OF CODE THAT ALWAYS READS RX AND PUTS DATA IN ASYNC BUFFER
endmodule


/**
We need 2 loops
- the rx-loop that passes stuff to the async buffer byte by byte
- the tx-loop that reads stuff from the async buffer byte by byte and sends it away 

*/