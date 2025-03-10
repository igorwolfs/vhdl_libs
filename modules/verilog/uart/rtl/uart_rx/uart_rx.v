`timescale 1ns/10ps

/**

# Inputs and outputs
PARAMETERS:
- OVERSAMPLING RATE (There should be an extra counter here that is used for oversamplign the start bit)
Inputs:
- RX_DSER
- Clock from baud generator
- NRST (reset)
Outputs:
- RX_DO (5-9 data-bist)
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
  #(parameter OVERSAMPLING = 8, parameter DATA_BITS = 8) // Oversampling
  (
   input            NRST,
   input            CLK,          // CURRENTLY UNUSED
   input            DIVPULSE,
   input            RX_DSER,
   output reg       RX_DRDY,        // reg: single-bit output
   output reg [DATA_BITS-1:0] RX_DO, // 8-bit output [MSB, LSB]
   output           RX_BUSY
   );

  // CONSTANTS
  localparam S_IDLE      = 2'b00;
  localparam S_START     = 2'b01;
  localparam S_DATA      = 2'b10;
  localparam S_STOP      = 2'b11;

  wire rx_serial_stable;
  // $clog2(N): minimum number of bits required to represent the parameter CLKS_PER_BIT
  reg [$clog2(DATA_BITS+2-1):0] data_bits_idx; // DATA_BITS + START STATE + STOP STATE
  reg [1:0] S_next;

  assign RX_BUSY = (S_next != S_IDLE);

  // double flipflop
  double_ff_sync #(.WIDTH(1), .NRST_VAL(1)) ff_sync
  (.NRST(NRST), .CLK(CLK),
    .D(RX_DSER), .Q(rx_serial_stable));

  always @(posedge CLK)
  begin
    if (~NRST)
      begin
      RX_DRDY <= 1'b0;
      S_next <= S_IDLE;
      end
    else
      case (S_next)
      S_IDLE:
          begin
          RX_DRDY <= 1'b0;
          if (rx_serial_stable == 1'b0) // If 1 is registered -> set state machine in start mode, start sampling at center
            S_next <= S_START;
          else
            S_next <= S_IDLE;
          end
        S_START:
          begin
          if (data_bits_idx == 1)
            S_next <= S_DATA;
          else
            S_next <= S_START;
          end
        S_DATA:
          begin
          if ((data_bits_idx == DATA_BITS+1) && (rx_serial_stable == 1'b1))
            S_next <= S_STOP;
          else
            S_next <= S_DATA;
          end
        S_STOP:
          begin
            // Wait for the stop bit to be registered in the shift register
            if (data_bits_idx == DATA_BITS+2)
              begin
              RX_DRDY <= 1'b1;
              S_next <= S_IDLE;
              end
            end
         default:
           S_next <= S_IDLE;
      endcase
  end


  reg [$clog2(OVERSAMPLING-1):0] divpulse_cnt;

  // Purpose: Control RX state machine
  always @(posedge CLK)
  begin
    if (~NRST)
    begin      
      RX_DO <= 0;
      data_bits_idx <= 0;      
      divpulse_cnt <= 0;
    end
    else
      begin
      if (DIVPULSE) // If the divpulse is asserted
        begin
        case (S_next)
          S_START :
            begin
              if (divpulse_cnt == (OVERSAMPLING-1)/2) // Sample halfway the start-bit
              begin
                divpulse_cnt <= 0;  // reset counter, found the middle
                data_bits_idx <= data_bits_idx + 1;
              end
              else
                divpulse_cnt <= divpulse_cnt + 1;
            end
          S_DATA :
            begin
            if (divpulse_cnt == OVERSAMPLING-1)
              begin
              RX_DO[data_bits_idx-1] <= rx_serial_stable;
              data_bits_idx <= data_bits_idx + 1;
              divpulse_cnt <= 0;
              end
            else
                divpulse_cnt <= divpulse_cnt + 1;
            end
          S_STOP :
            begin
            if (divpulse_cnt == OVERSAMPLING-1)
              begin
              divpulse_cnt <= 0;
              data_bits_idx <= data_bits_idx + 1;
              end
            else
              divpulse_cnt <= divpulse_cnt + 1;
            end
          default:
          ;
        endcase
      end
        else
          begin
            case (S_next)
              S_IDLE:
                begin
                data_bits_idx <= 0;          
                divpulse_cnt <= 0;
                end
              default:;
            endcase;
          end
      end
end

endmodule

/**
CENTRAL DESIGN IDEA
- The first always-loop controls the logic based on the index received at the shift register.
- The second always-loop is a shift register incrementing the receive index and the pulse counter from the baud_generator
*/