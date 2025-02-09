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
  #(parameter OVERSAMPLING = 8, parameter DATA_BITS = 8, parameter SYSCLK = 100_000_000) // Oversampling
  (
   input            nrst_in,
   input            sysclk_in,          // CURRENTLY UNUSED
   input            divpulse_in,
   input            rx_serial_in,
   output reg       data_rdy_out,         // reg: single-bit output
   output reg [DATA_BITS-1:0] rx_data_out, // 8-bit output [MSB, LSB]
   output reg [1:0] SM_DBG_CURR
   );

   // CONSTANTS
  localparam SM_rx_idle_s         = 2'b00;
  localparam SM_rx_start_s     = 2'b01;
  localparam SM_rx_data_s      = 2'b10;
  localparam SM_rx_stop_s      = 2'b11;


  // $clog2(N): minimum number of bits required to represent the parameter CLKS_PER_BIT
  reg [$clog2(OVERSAMPLING-1):0] divpulse_cnt; //! WARNING: modified line here without testing
  reg [$clog2(DATA_BITS+2-1):0] data_bits_idx; // DATA_BITS + START STATE + STOP STATE
  reg [1:0] SM_rx_next_state;

  // double flipflop
  double_ff_sync #(.WIDTH(1), .NRST_VAL(1)) ff_sync
  (.nrst_in(nrst_in), .clkin(sysclk_in),
    .data_in(rx_serial_in), .data_out(rx_serial_stable));

  always @(posedge sysclk_in)
  begin
    if (~nrst_in)
      begin
      SM_DBG_CURR <= 0;
      data_rdy_out <= 1'b0;
      rx_data_out <= 0;
      SM_rx_next_state <= SM_rx_idle_s;
      //! RESETTING THE BITSHIFT REGISTER
      divpulse_cnt <= 0;
      data_bits_idx <= 0;
      end
    else
      case (SM_rx_next_state)
        SM_rx_idle_s:
          begin
          //! RESETTING THE BITSHIFT REGISTER
          divpulse_cnt <= 0;
          data_bits_idx <= 0;

          //! DATA READY OUT
          data_rdy_out <= 1'b0;
          if (rx_serial_stable == 1'b0) // If 1 is registered -> set state machine in start mode, start sampling at center
              SM_rx_next_state <= SM_rx_start_s;
          else
            SM_rx_next_state <= SM_rx_idle_s;
          end
        SM_rx_start_s:
          begin
          if (data_bits_idx == 1)
            SM_rx_next_state <= SM_rx_data_s;
          else
            SM_rx_next_state <= SM_rx_start_s;
          end
        SM_rx_data_s:
          begin
          if ((data_bits_idx == DATA_BITS+1) && (rx_serial_stable == 1'b1))
            SM_rx_next_state <= SM_rx_stop_s;
          else
            SM_rx_next_state <= SM_rx_data_s;
          end
        SM_rx_stop_s:
          begin
            // Wait for the stop bit to be registered in the shift register
            if (data_bits_idx == DATA_BITS+2)
              begin
              data_rdy_out <= 1'b1;
              SM_rx_next_state <= SM_rx_idle_s;
              end
            end
      endcase
  end

  // Purpose: Control RX state machine
  always @(posedge sysclk_in)
  begin
    if (divpulse_in) // If the divpulse is asserted
      begin
      case (SM_rx_next_state)
        SM_rx_start_s :
          begin
            if (divpulse_cnt == (OVERSAMPLING-1)/2) // Sample halfway the start-bit
            begin
              SM_DBG_CURR <= SM_rx_start_s;
              divpulse_cnt <= 0;  // reset counter, found the middle
              data_bits_idx <= data_bits_idx + 1;
            end
            else
              divpulse_cnt <= divpulse_cnt + 1;
          end
        SM_rx_data_s :
          begin
          if (divpulse_cnt == OVERSAMPLING-1)
            begin
            SM_DBG_CURR <= SM_rx_data_s;
            rx_data_out[data_bits_idx-1] <= rx_serial_stable;
            data_bits_idx <= data_bits_idx + 1;
            divpulse_cnt <= 0;
            end
          else
              divpulse_cnt <= divpulse_cnt + 1;
          end
        SM_rx_stop_s :
          begin
          if (divpulse_cnt == OVERSAMPLING-1)
            begin
            SM_DBG_CURR <= SM_rx_stop_s;
            divpulse_cnt <= 0;
            data_bits_idx <= data_bits_idx + 1;
            end
          else
            divpulse_cnt <= divpulse_cnt + 1;
          end
        default:
          begin
            SM_DBG_CURR <= SM_rx_idle_s;
            SM_rx_next_state <= SM_rx_idle_s;
          end
    endcase
  end
  else;
end

endmodule;

/**
CENTRAL DESIGN IDEA
- The first always-loop controls the logic based on the index received at the shift register.
- The second always-loop is a shift register incrementing the receive index and the pulse counter from the baud_generator
*/