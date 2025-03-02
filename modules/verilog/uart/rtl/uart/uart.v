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
- NRST (for resetting tx and rx)
- clk (clock)
TX
- TX_DI (8-bits tx bus)
- tx_rdy_in (gives a clk signal when data is ready and should be sent)
RX
- rx_serial_in (should be linked to RX pin)

## Outputs:
TX
- tx_busy (could be ignored for now)
- TX_DONE (shows that data is done sending)
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
        input   CLK,
        input   NRST,
        // TX
        input   [(DATA_BITS-1):0] TX_DI,
        input   TX_DRDY,
        output  TX_BUSY,
        output  TX_DONE,
        output  TX_DSER,      //! TX_PIN
        // RX
        input   RX_DSER, //! RX_PIN
        output  [(DATA_BITS-1):0] RX_DO,
        output  RX_DRDY
    );

    // CONSTANTS
    localparam OVERSAMPLING_RATE = 8;

    // REFERENCE CLOCK
    wire baud_pulse, div_pulse;

    baud_generator #(.BAUD_RATE(BAUD_RATE), .CLOCK_IN(CLOCK_FREQUENCY),
    .OVERSAMPLING_RATE(OVERSAMPLING_RATE)) baud_generator_inst
    (
        .NRST(NRST), .CLK(CLK),
        .DIVPULSE(div_pulse), .BAUDPULSE(baud_pulse)
    );

    uart_tx #(.OVERSAMPLING(OVERSAMPLING_RATE),
    .DATA_BITS(DATA_BITS)) uart_tx_inst
    (
        .NRST(NRST),
        .BAUDPULSE(baud_pulse),
        .CLK(CLK),
        .TX_DRDY(TX_DRDY),
        .TX_DI(TX_DI),
        .TX_DSER(TX_DSER),
        .TX_BUSY(TX_BUSY),
        .TX_DONE(TX_DONE)
    );

    uart_rx #(.OVERSAMPLING(OVERSAMPLING_RATE),
                .DATA_BITS(DATA_BITS)) uart_rx_inst
                (.NRST(NRST),
                .CLK(CLK),
                .DIVPULSE(div_pulse),
                .RX_DSER(RX_DSER),
                .RX_DRDY(RX_DRDY),
                .RX_DO(RX_DO)
    );
endmodule
