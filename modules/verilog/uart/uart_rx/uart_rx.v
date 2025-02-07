`timescale 1ns/10ps

/**

# Inputs and outputs
PARAMETERS:
- OVERSAMPLING RATE (There should be an extra counter here that is used for oversamplign the start bit)
Inputs:
- rx_serial_in
- Clock from baud generator
- nrst_in (reset)
Outputs:
- rx_data_out (5-9 data-bist)
- data_ready (1 bit) -> signalling that data is ready to be read

# UART RX Working
1. RX must be pulled high - default state
2. Start bit
    - High to low for 1 clock cycle -> UART Should sample this until it detects a low bit
3. Data frame
    - 5 .. 9 bits
4. Parity bit
    - 0 .. 1 bit
5. Stop bit
    - 1-2 bits (high voltage)
6. Pass received bytes to data-bus
*/


module uart_rx
  #(parameter OVERSAMPLING = 8,
    parameter DATA_BITS = 8, parameter CLOCK_IN = 100_000_000) // Oversampling
  (
   input            nrst_in,
   input            sysclk_in,
   input            clk_in,
   input            rx_serial_in,
   output reg       data_rdy_out,         // reg: single-bit output
   output reg [DATA_BITS-1:0] rx_data_out // 8-bit output [MSB, LSB]
   );

   // CONSTANTS
  localparam SM_idle_s         = 2'b00;
  localparam SM_rx_start_s     = 2'b01;
  localparam SM_rx_data_s      = 2'b10;
  localparam SM_rx_stop_s      = 2'b11;

  // $clog2(N): minimum number of bits required to represent the parameter CLKS_PER_BIT
  reg [$clog2(OVERSAMPLING-1):0] cnt_baud_clk; //! WARNING: modified line here without testing

  reg [$clog2(DATA_BITS-1):0] data_bits_idx; // 3 bits -> max 8 states
  reg [1:0] SM_next_state;
  reg rx_data_unstable;
  reg rx_data_stable;

  // double flipflop
  always @(posedge clk_in)
  begin
     begin
     rx_data_unstable <= rx_serial_in;
     rx_data_stable <= rx_data_unstable;
     end
  end

  // Purpose: Control RX state machine
  always @(posedge clk_in, negedge nrst_in)
  begin
    // If ~i_Rst_L: reset is triggered
    if (~nrst_in)
    begin
      SM_next_state = SM_idle_s;
      data_rdy_out = 1'b0;
      rx_data_out = 0;
      data_bits_idx <= 0;
    end
    else
    begin
      case (SM_next_state)

      SM_idle_s :
      begin       // >>> SM_idle_s
          data_rdy_out    <= 1'b0;
          cnt_baud_clk    <= 0;

          if (rx_serial_in == 1'b0)
            SM_next_state <= SM_rx_start_s;
          else
            SM_next_state <= SM_idle_s;
        end      // <<< SM_idle_s

      SM_rx_start_s :
      begin       // >>> SM_start_s
        if (cnt_baud_clk == (OVERSAMPLING-1)/2) // Sample halfway the start-bit
        begin
          if (rx_serial_in == 1'b0)
            begin
              cnt_baud_clk <= 0;  // reset counter, found the middle
              SM_next_state <= SM_rx_data_s;
            end
          else
            SM_next_state <= SM_idle_s;
        end
        else
        begin
          cnt_baud_clk <= cnt_baud_clk + 1;
        end
      end   // <<< SM_start_s
      SM_rx_data_s  :
      begin // <<< SM_rx_data_s
        if (cnt_baud_clk == OVERSAMPLING-1)
          begin
          rx_data_out[data_bits_idx] <= rx_data_stable;
          data_bits_idx <= data_bits_idx + 1;
          cnt_baud_clk <= 0;
          if (data_bits_idx == (DATA_BITS - 1))
            SM_next_state <= SM_rx_stop_s;
          end
        else
          begin
          cnt_baud_clk <= cnt_baud_clk + 1;
          end
      end // <<< SM_rx_data_s
      SM_rx_stop_s :
        begin // >>> SM_rx_stop_s
        if (cnt_baud_clk == OVERSAMPLING-1)
          begin
          data_rdy_out <= 1'b1;
          cnt_baud_clk <= 0;
          data_bits_idx <= 0;
          SM_next_state <= SM_idle_s;
          end
        else
          cnt_baud_clk <= cnt_baud_clk + 1;
        end // <<< SM_rx_stop_s
      default:
        SM_next_state <= SM_idle_s;
    endcase
    end
  end

endmodule // UART_RX