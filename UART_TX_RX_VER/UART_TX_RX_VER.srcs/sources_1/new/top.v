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
    #(parameter DEFAULT_SEND_RATE = 750_000) // (750e3 / 100e6) * 40 = 3
(
    //! This is needed to make sure the module is in a defined state at start!
    input i_Rst_L,
    // Buttons
    input [3:0] p_btn,
    // External clock
    input p_ref_clk,
    // tx_serial
    output p_tx_serial,
    // tx_active (debug)
    output p_tx_active
);

// *******************************
// BUTTONS
localparam BUTTON_1      = 3'b1000;
localparam BUTTON_2      = 3'b0100;
localparam BUTTON_3      = 3'b0010;
localparam BUTTON_4      = 3'b0001;

// STATE MACHINE
localparam STATE_BUTTON = 1'b0;
localparam STATE_SEND   = 1'b1;
// *******************************

localparam c_CLOCK_PERIOD_NS = 20;
localparam c_CLKS_PER_BIT    = 217;
localparam c_BIT_PERIOD      = 8600;

reg r_TX_DV = 0;
reg [7:0] r_TX_Byte;

// Clock divider, should divide by c_CLOCK_PERIOD_NS
reg [$clog2(c_CLOCK_PERIOD_NS):0] count = 0;
reg r_Clock = 0;

UART_TX #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_Inst
(
 .i_Rst_L(i_Rst_L),
 .i_Clock(r_Clock),
 .i_TX_DV(r_TX_DV),
 .i_TX_Byte(r_TX_Byte),
 .o_TX_Active(p_tx_active),
 .o_TX_Serial(p_tx_serial),
 .o_TX_Done()
 );


// Checker for every how-many times there should be a default send if nothing is pressed
reg [$clog2(c_CLOCK_PERIOD_NS):0] count_default_send = 0;

initial begin
    count = 0;
    r_Clock = 0;
end
 // Should divide the clock by c_CLOCK_PERIOD_NS
 always @(posedge p_ref_clk) begin
    if (count == c_CLOCK_PERIOD_NS-1) begin
        count <= 0;
        r_Clock <= ~r_Clock;
    end
    else begin
        count <= count + 1;
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

always @(posedge r_Clock or negedge i_Rst_L) begin
    if (~i_Rst_L)
    begin
        count <= 0;
        r_Clock <= 1'b0;
        r_TX_DV <= 1'b0;
        count_default_send <= 0;
    end

    else if (p_tx_active == 0) begin
        case (p_btn)
            BUTTON_1: begin
                    count_default_send <= 0;
                    r_TX_Byte <= 8'h0A;
                    r_TX_DV   <= 1'b1; // Indicate start send
                end
            BUTTON_2: begin
                    count_default_send <= 0;
                    r_TX_Byte <= 8'hA0;
                    r_TX_DV   <= 1'b1; // Indicate start send
                end
            BUTTON_3: begin
                    count_default_send <= 0;
                    r_TX_Byte <= 8'h0B;
                    r_TX_DV   <= 1'b1; // Indicate start send
                end
            BUTTON_4: 
                    begin
                    count_default_send <= 0;
                    r_TX_Byte <= 8'hB0;
                    r_TX_DV   <= 1'b1; // Indicate start send
                    end
            // COUNT for 3 seconds and send a random message if nothing was sent in the meantime
            default:
                    begin
                    if (count_default_send < DEFAULT_SEND_RATE)
                        begin
                        count_default_send <= count_default_send + 1;
                        end
                    else
                        begin
                        count_default_send <= 0;
                        r_TX_Byte <= 8'h22;
                        end
                end
        endcase
    end
    // Future: make sure to end this only when the TX-done signal was raised
    else begin
        if (r_TX_DV == 1'b1) 
        begin
            r_TX_DV <= 1'b0;
        end
    end
end

endmodule
