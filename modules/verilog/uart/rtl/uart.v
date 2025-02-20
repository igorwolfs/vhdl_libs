`timescale 1ns/10ps


/**
# Purpose
Simple UART module.

# Inputs and outputs
Parameters:
- CLOCK_FREQUENCY (actual frequency)
- BAUD_RATE (desired baud rate)
- DATA_BITS (desired number of data bits)
## Inputs:
TX and RX
- nrst_in (for resetting tx and rx)
- clk (clock)
TX
- tx_data_in (8-bits tx bus)
- tx_rdy_in (gives a clk signal when data is ready and should be sent)
RX
- rx_serial_in (should be linked to RX pin)

## Outputs:
TX
- tx_busy (could be ignored for now)
- tx_done_out (shows that data is done sending)
- tx_data_out (should be linked to output pin)
RX
- rx_data_out (data_bits-length)
- data_rdy_out (signals that data can be read)

**/

module uart
    #(parameter CLOCK_FREQUENCY = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter DATA_BITS = 8)
    (
        input   sysclk,
        input   nrst_in,
        // TX
        input   [(DATA_BITS-1):0] tx_data_in,
        input   data_rdy_in,
        output  tx_busy_out,
        output  tx_done_out,
        output  tx_serial_out, //! TX_PIN
        // RX
        input   rx_serial_in,   //! RX_PIN
        output  [(DATA_BITS-1):0] rx_data_out,
        output  data_rdy_out
    );

    // CONSTANTS
    localparam OVERSAMPLING_RATE = 8;

    // REFERENCE CLOCK
    wire baud_pulse, div_pulse;

    baud_generator #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLOCK_FREQUENCY),
    .OVERSAMPLING_RATE(OVERSAMPLING_RATE)) baud_generator_inst
    (
        .nrst_in(nrst_in), .clk_in(sysclk),
        .divpulse_out(div_pulse), .baudpulse_out(baud_pulse)
    );

    uart_tx #(.OVERSAMPLING(OVERSAMPLING_RATE),
    .DATA_BITS(DATA_BITS)) uart_tx_inst
    (
        .nrst_in(nrst_in),
        .baudpulse_in(baud_pulse),
        .sysclk_in(sysclk),
        .data_rdy_in(data_rdy_in),
        .tx_data_in(tx_data_in),
        .tx_serial_out(tx_serial_out),
        .tx_busy_out(tx_busy_out),
        .tx_done_out(tx_done_out)
    );

    uart_rx #(.OVERSAMPLING(OVERSAMPLING_RATE),
                .DATA_BITS(DATA_BITS)) uart_rx_inst
                (.nrst_in(nrst_in),
                .sysclk_in(sysclk),
                .divpulse_in(div_pulse),
                .rx_serial_in(rx_serial_in),
                .data_rdy_out(data_rdy_out),
                .rx_data_out(rx_data_out)
    );
endmodule
