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

module top
    #(parameter DEFAULT_SEND_RATE = 750_000, // (750e3 / 100e6) * 40 = 3
    parameter DEFAULT_CLOCK_IN = 10) // Input clock signal period in ns
(
    //! This is needed to make sure the module is in a defined state at start!
    input rst_n_i,
    // Buttons
    input [3:0] button_i,
    // External clock
    input clk_i,
    // tx_serial
    output uart_tx_data_o,
    // tx_active (debug)
    output uart_tx_active_o,
    // tx_done (debug)
    output uart_tx_done_o
);

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


// STATE MACHINE
localparam STATE_BUTTON = 1'b0;
localparam STATE_SEND   = 1'b1;
// *******************************

localparam c_CLOCK_PERIOD_NS = 20;
localparam c_CLKS_PER_BIT    = 217;
localparam c_BIT_PERIOD      = 8600;

// calculate actual clock period
// Make sure to set the clock-period of UART as absolute.
parameter c_CLOCK_PERIOD = (c_CLOCK_PERIOD_NS % DEFAULT_CLOCK_IN == 0) ? (c_CLOCK_PERIOD_NS / DEFAULT_CLOCK_IN) : c_CLOCK_PERIOD_NS;


reg [7:0] uart_tx_byte_reg;

// Clock divider, should divide by c_CLOCK_PERIOD_NS
reg [$clog2(c_CLOCK_PERIOD):0] clk_count_reg = 0;
reg clk_reg = 0;

// Checker for every how-many times there should be a default send if nothing is pressed
reg [$clog2(DEFAULT_SEND_RATE):0] count_default_send_reg = 0;
reg uart_tx_dv_reg;
UART_TX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_Inst
(
 .i_Rst_L(rst_n_i),
 .i_Clock(clk_reg),
 .i_TX_DV(uart_tx_dv_reg),
 .i_TX_Byte(uart_tx_byte_reg),
 .o_TX_Active(uart_tx_active_o),
 .o_TX_Serial(uart_tx_data_o),
 .o_TX_Done(uart_tx_done_o)
 );


initial begin
    clk_count_reg = 0;
    clk_reg = 0;
end
 // Should divide the clock by c_CLOCK_PERIOD_NS
 always @(posedge clk_i) begin
    if (clk_count_reg == c_CLOCK_PERIOD-1) begin
        clk_count_reg <= 0;
        clk_reg <= ~clk_reg;
    end
    else begin
        clk_count_reg <= clk_count_reg + 1;
    end
 end

 /*
 1. A button press happens
 2. A message needs to be written to the tx buffer according to the button press
 3. The message needs to be sent
 There are just 2 states:
    - The buffer is full -> we continue sending
    - The buffer is not full -> we check the button switch-case
            - If button: fill, wait clock cycle, continue to sending
 */

always @(posedge clk_reg or negedge rst_n_i) begin
    if (~rst_n_i)
    begin
        clk_count_reg <= 0;
        clk_reg <= 1'b0;
        uart_tx_dv_reg <= 1'b0;
        count_default_send_reg <= 0;
    end

    else if (uart_tx_active_o == 0) begin
        case (button_i)
            BUTTON_1:
                    begin
                    count_default_send_reg <= 0;
                    uart_tx_byte_reg <= BUTTON_1_CHAR; //8'h97;
                    uart_tx_dv_reg   <= 1'b1; // Indicate start send
                    end
            BUTTON_2:
                    begin
                    count_default_send_reg <= 0;
                    uart_tx_byte_reg <= BUTTON_2_CHAR;
                    uart_tx_dv_reg   <= 1'b1; // Indicate start send
                    end
            BUTTON_3:
                    begin
                    count_default_send_reg <= 0;
                    uart_tx_byte_reg <= BUTTON_3_CHAR;
                    uart_tx_dv_reg   <= 1'b1; // Indicate start send
                    end
            BUTTON_4:
                    begin
                    count_default_send_reg <= 0;
                    uart_tx_byte_reg <= BUTTON_4_CHAR;
                    uart_tx_dv_reg   <= 1'b1; // Indicate start send
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
                            uart_tx_byte_reg <= BUTTON_DEFAULT_CHAR; // Send dot
                            uart_tx_dv_reg   <= 1'b1; // Indicate start send
                        end
                    end
        endcase
    end
    // Future: make sure to end this only when the TX-done signal was raised
    else begin
        if (uart_tx_dv_reg == 1'b1)
        begin
            uart_tx_dv_reg <= 1'b0;
        end
    end
end

endmodule
