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
   input       baudpulse_in,
   input       sysclk_in,
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

  reg [1:0] SM_tx_next_state;
  reg [1:0] SM_DBG_CURR;
  reg [$clog2(DATA_BITS-1):0] data_bits_idx; // 3 bits -> max 8 states
  reg [DATA_BITS-1:0] data_bits; // 3 bits -> max 8 states

  // Purpose: Control TX state machine
  //! WARNING: errors here might happen due to asynchronous reset, consider removing the nrst_in to make sure the reset happens synchronously.
  always @(posedge sysclk_in or negedge nrst_in)
  begin
    if (~nrst_in)
        begin      
        tx_serial_out <= 1'b1;  // tx is 1 by default
        tx_done_out <= 1'b0;
        tx_busy_out <= 1'b0;
        SM_tx_next_state <= SM_idle_s;  // Set to  SM_idle_s
        end
    else
      begin
      case (SM_tx_next_state)
        SM_idle_s:
          begin
          tx_done_out     <= 1'b0;
          if (data_rdy_in == 1'b1)
            begin
            tx_busy_out   <= 1'b1;
            data_bits     <= tx_data_in;   // Save data in internal register in case altering
            SM_tx_next_state <= SM_tx_start_s;
            end
          else
            tx_busy_out   <= 1'b0;
          end
        SM_tx_start_s:
          begin
          if (tx_serial_out == 1'b0)
            SM_tx_next_state <= SM_tx_data_s;
          else
            SM_tx_next_state <= SM_tx_start_s;
          end
        SM_tx_data_s:
          begin
          if (data_bits_idx == DATA_BITS)
              SM_tx_next_state = SM_tx_stop_s;
              //! ISSUE HERE IS PROBABLY WE'RE NOT GIVING THE SENDER THE TIME TO EXIT HERE
          else
            SM_tx_next_state <= SM_tx_data_s;
          end
        SM_tx_stop_s:
        begin
            // Set back to 0
            if (data_bits_idx == 0)
              begin
              SM_tx_next_state <= SM_idle_s;
              tx_done_out <= 1'b1; // Should assert after a full cycle of tx_stop
              end
              
            else
              SM_tx_next_state <= SM_tx_stop_s;
        end
        default:
         SM_tx_next_state <= SM_idle_s;
      endcase
    end
  end

  always @(posedge sysclk_in)
  begin
    if (baudpulse_in)
      begin
      case (SM_tx_next_state)
        SM_idle_s :
          begin
            SM_DBG_CURR <= SM_idle_s;
            tx_serial_out   <= 1'b1;         // Drive Line High for SM_idle_s
          end

        SM_tx_start_s :
          begin
            SM_DBG_CURR <= SM_tx_start_s;
            tx_serial_out <= 1'b0;
            data_bits_idx <= 0;
          end

        SM_tx_data_s :
          begin
            SM_DBG_CURR <= SM_tx_data_s;
            tx_serial_out <= data_bits[data_bits_idx];
            data_bits_idx <= data_bits_idx + 1;
          end

        SM_tx_stop_s :
            begin
            SM_DBG_CURR <= SM_tx_stop_s;
            data_bits_idx <= 0;
            tx_serial_out <= 1'b1;
            end

        default :
          tx_serial_out <= 1'b1;

      endcase
      end
    else;
  end
endmodule


/*
REWRITING

// *** IN CHARGE OF signals, state machine
@(posedge sysclk_in)
  if data_rdy_in
    - Copy data
    - set tx_busy_out
    - set state machine
  if (serial_out set to 0 and state machine is start)
    - change state machine to data
  if data_bits is the max number -> set to stop state
  if stop bit is high -> set back to idle
  default:
    - done_out
    - state machine is 0

// *** IN CHARGE OF serial_out
@(posedge baudclk_in, negedge nrst_in)
  if ~nrst_in
    - Set serial_out
  case
    IDLE
      - set serial_out
    START
      - set serial_out
    DATA
      - set tx_serial_out
      - increment index
    STOP
      - set stop bit
*/
/**
// TODO: Make sure to drive this clock signal using a pulse, instead of the clock generated in the baud-generator for the future.
          For now it seems ok since the actual baud_rate is muuuch higher than the clock pulse, and the amount of logic driven is not that high.
*/
