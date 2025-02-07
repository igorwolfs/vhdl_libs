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

module uart_echo_app
(
    //! This is needed to make sure the module is in a defined state at start!
    // COMMON
    input nrst_in,
    input clk_in,

    // RX
    input rx_serial_in,

    // TX
    output tx_serial_out,

    // dv out
    input uart_tx_dv_o
);
    // *******************************
    // LOCAL PARAMETERS FOR TESTBENCH
    localparam DATA_BITS = 8;
    localparam BAUD_RATE = 115_200;
    localparam CLK_FREQUENCY = 100_000_000;

    // DEFINE FIFO DEPTH
    localparam DEPTH = 16;

    // *******************************
    wire full_out, empty_out;
    wire rw_clk;
    wire [DATA_BITS-1:0] data_in;
    wire [DATA_BITS-1:0] data_out;




    uart #(.CLOCK_FREQUENCY(CLK_FREQUENCY), .BAUD_RATE(BAUD_RATE), .DATA_BITS(DATA_BITS)) 
    uart_inst
    (.clk(clk), .nrst_in(nrst_in),
    // TX
    .data_rdy_in(data_rdy_in),
    .tx_data_in(tx_data_in), .tx_serial_out(tx_serial_out), //! MUST BE A PIN
    // RX
    .rx_serial_in(rx_serial_in), .rx_data_out(rx_data_out), .data_rdy_out(data_rdy_out)
    );

    fifo_async_circular(.DEPTH(DEPTH), .WIDTH(DATA_BITS)) fifo_async_circular_inst
            (.read_clk(), .write_clk()
            .write_in(rw_clk), .read_in(rw_clk),
            .w_nrst_in(nrst_in)), r_nrst_in(nrst_in),
            // ECHO so in-> rx, OUT -> tx
            .data_write_in(rx_data_out), .data_read_out(tx_data_in).
            .full_out(full_out), .empty_out(empty_out));


    // we need to create the read and write clock in sync with the baud rates.
    // Otherwise we might read / write twice were it was meant to be read / written only once.

    baud_generator #(.BAUD_RATE(BAUD_RATE),
    .CLOCK_IN(CLOCK_FREQUENCY),
    .OVERSAMPLING_RATE(OVERSAMPLING_RATE)) read_write_clk
    (
        .nrst_in(nrst_in),
        .clk_in(clk_in),
        .clk_out(rw_clk)
    );


endmodule
