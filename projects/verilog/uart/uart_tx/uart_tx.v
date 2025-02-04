`timescale 1ns/10ps

/**

# Inputs and outputs
PARAMETERS
- OVERSAMPLING RATE
- DATA_BITS
Inputs:
- tx_data_in
- tx nreset in
- tx_rdy_in (toggle sending of data set in tx_data_in)
- clk_in (clock, requested baud rate / OVERSAMPLING RATE)
Outputs:
- tx_serial_out (serial data line out)
- tx_rdy_out (data is sent)

# UART TX WORKING
1. tx_data_in is set
2. tx_rdy_in is toggled
3. start bit is sent (bit_duration = clk_in * OVERSAMPLING_RATE)
4. data-bits are sent
5. parity bits are sent
6. stop-bit is sent
7. tx_rdy_out is set

# States
- Idle state:
  - wait for tx rdy_in -> transition to start bit
- Start state:
  - toggle tx_serial, wait bit_duration -> transition to data state
- Data state:
  - toggle tx serial for DATA_BITS
  - when done, go to stop-state
- Stop state:
  - toggle for DATA_BITS
  - When done -> assert, tx_rdy_out, assert idle_state
*/

module uart_tx
  #(parameter OVERSAMPLING = 8,
    parameter DATA_BITS = 8)
  (
   input       nrst_in,
   input       clk_in,
   input       data_rdy_in,
   input [7:0] tx_data_in,
   output reg  tx_serial_out,
   output reg  tx_busy_out,
   output reg  tx_done_out
  );

  localparam SM_idle_s     = 2'b00;
  localparam SM_tx_start_s = 2'b01;
  localparam SM_tx_data_s  = 2'b10;
  localparam SM_tx_stop_s  = 2'b11;

  reg [$clog2(OVERSAMPLING)-1:0] cnt_baud_clk;

  reg [2:0] SM_next_state;
  reg [$clog2(DATA_BITS-1):0] data_bits_idx; // 3 bits -> max 8 states
  reg [DATA_BITS-1:0] data_bits; // 3 bits -> max 8 states

  // Purpose: Control TX state machine
  //! WARNING: errors here might happen due to asynchronous reset, consider removing the nrst_in to make sure the reset happens synchronously.
  //always @(posedge clk_in or negedge nrst_in)
  always @(posedge clk_in, negedge nrst_in)
  begin
    if (~nrst_in)
    begin
      SM_next_state <= SM_idle_s;  // Set to  SM_idle_s
      tx_busy_out <= 1'b0;
      tx_serial_out <= 1'b1;  // tx is 1 by default
      tx_done_out   <= 1'b0;
      cnt_baud_clk <= 0;
    end
    else
    begin
      case (SM_next_state)
      SM_idle_s :
        begin // >>> SM_idle_s
          tx_serial_out   <= 1'b1;         // Drive Line High for SM_idle_s
          tx_done_out     <= 1'b0;
          cnt_baud_clk    <= 0;
          if (data_rdy_in == 1'b1)
          begin
            tx_busy_out   <= 1'b1;
            data_bits    <= tx_data_in;   // Save data in internal register in case altering
            SM_next_state <= SM_tx_start_s;
          end
          else
            tx_busy_out   <= 1'b0;
          end // <<< SM_idle_s


      SM_tx_start_s :
        begin // >>> SM_tx_start_s
          tx_done_out <= 1'b0; // default assignment
          tx_serial_out <= 1'b0;
          if (cnt_baud_clk < OVERSAMPLING-1)
          begin
            cnt_baud_clk <= cnt_baud_clk + 1;
          end
          else
          begin
            cnt_baud_clk  <= 0;
            data_bits_idx <= 0;
            SM_next_state <= SM_tx_data_s;
          end
        end // <<< SM_tx_start_s


      SM_tx_data_s :
        begin // >>> SM_tx_data_s
          tx_serial_out <= data_bits[data_bits_idx];

          if (cnt_baud_clk == OVERSAMPLING-1)
            begin
            cnt_baud_clk <= 0;
            if (data_bits_idx == (DATA_BITS - 1))
              SM_next_state   <= SM_tx_stop_s;
            else
              data_bits_idx <= data_bits_idx + 1;
            end
          else
            cnt_baud_clk <= cnt_baud_clk + 1;
        end // <<< SM_tx_data_s


      SM_tx_stop_s :
        begin // >>> SM_tx_stop_s
          tx_serial_out <= 1'b1;

          // Wait OVERSAMPLING-1 clock cycles for Stop bit to finish
          if (cnt_baud_clk == OVERSAMPLING-1)
          begin
            SM_next_state = SM_idle_s;
            tx_done_out = 1'b1;
            cnt_baud_clk <= 0;
          end
          else
            cnt_baud_clk <= cnt_baud_clk + 1;
        end // <<< SM_tx_stop_s

      default :
        SM_next_state <= SM_idle_s;
    endcase
    end
  end
endmodule
