`timescale 1ns/10ps


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
        output  RX_DRDY,
        output  RX_BUSY
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
                .RX_DO(RX_DO),
                .RX_BUSY(RX_BUSY)
    );
endmodule
