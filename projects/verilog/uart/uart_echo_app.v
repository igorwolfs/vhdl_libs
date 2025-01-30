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
    input rst_n_i,
    input clk_i,

    // RX
    input uart_rx_data_i,

    // TX
    output uart_tx_data_o,
    // dv out
    input uart_tx_dv_o,
    // Done out
    output uart_tx_done
);


// *******************************
localparam DEFAULT_CLOCK_IN = 10; // DEFAULT INPUT CLOCK PERIOD
localparam CLOCK_PERIOD_NS = 20;
localparam c_CLKS_PER_BIT = 217;
localparam c_BIT_PERIOD = 8600;
// Actual period used
localparam CLK_PERIOD = (CLOCK_PERIOD_NS % DEFAULT_CLOCK_IN == 0) ? (CLOCK_PERIOD_NS / DEFAULT_CLOCK_IN) : CLOCK_PERIOD_NS;

// Clock divider, should divide by CLOCK_PERIOD_NS
reg [$clog2(CLK_PERIOD):0] clk_count_reg;
reg clk_reg;

// STATE MACHINE
wire uart_rx_dv_o;
wire [7:0] uart_rx_byte_reg;

UART_RX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_Inst
(
 .i_Rst_L(rst_n_i),
 .i_Clock(clk_reg),
 .i_RX_Serial(uart_rx_data_i),
 .o_RX_DV(uart_rx_dv_o),
 .o_RX_Byte(uart_rx_byte_reg)
 );


 always @(posedge clk_i or negedge rst_n_i) begin
    if (~rst_n_i)
    begin
        clk_count_reg <= 0;
        clk_reg <= 1'b0;
    end
    else if (clk_count_reg >= CLK_PERIOD-1)
    begin
        clk_count_reg <= 0;
        clk_reg <= ~clk_reg;
    end
    else begin
        clk_count_reg <= clk_count_reg + 1;
    end
 end

/**
 After receiving a message, wait 100 clock cycles, and send it back
 - So you need a buffer which can handle the same amount of chars (100 x 8 bytes)
 */
always @(posedge uart_rx_dv_o)
begin
    
end
