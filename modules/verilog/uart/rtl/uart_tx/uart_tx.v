`timescale 1ns/10ps


module uart_tx
  #(parameter OVERSAMPLING = 8,
    parameter DATA_BITS = 8)
  (
   input       NRST,
   input       BAUDPULSE,
   input       CLK,
   input       TX_DRDY,
   input [7:0] TX_DI,
   output reg  TX_DSER,
   output reg  TX_BUSY,
   output reg  TX_DONE
  );
  // *** PARAMETERS
  parameter DATA_BITS_WIDTH = $clog2(DATA_BITS-1); // 1 + DATA_BITS for state transition

  // *** STATE MACHINE
  localparam S_IDLE     = 2'b00;
  localparam S_START = 2'b01;
  localparam S_DATA  = 2'b10;
  localparam S_STOP  = 2'b11;

  reg [1:0] S_next;
  reg [DATA_BITS_WIDTH:0] data_bits_idx; // 3 bits -> max 8 states
  reg [DATA_BITS-1:0] data_bits; // 8 bits -> max 8 states

  // Purpose: Control TX state machine
  //! WARNING: errors here might happen due to asynchronous reset, consider removing the NRST to make sure the reset happens synchronously.
  always @(posedge CLK)
  begin
    if (~NRST)
        begin
        TX_DONE <= 1'b0;
        TX_BUSY <= 1'b0;
        S_next <= S_IDLE;  // Set to  S_IDLE
        end
    else
      begin
      case (S_next)
        S_IDLE:
          begin
          TX_DONE     <= 1'b0;
          if (TX_DRDY == 1'b1)
            begin
            TX_BUSY   <= 1'b1;
            data_bits     <= TX_DI;   // Save data in internal register in case altering
            S_next <= S_START;
            end
          else
            TX_BUSY   <= 1'b0;
          end
        S_START:
          begin
          if (TX_DSER == 1'b0)
            S_next <= S_DATA;
          else
            S_next <= S_START;
          end
        S_DATA:
          begin
          if (data_bits_idx == DATA_BITS)
              S_next <= S_STOP;
          else
            S_next <= S_DATA;
          end
        S_STOP:
        begin
            // Set back to 0
            if (data_bits_idx == 0)
              begin
              S_next <= S_IDLE;
              TX_DONE <= 1'b1; // Should assert after a full cycle of tx_stop
              end
            else
              S_next <= S_STOP;
        end
        default:
         S_next <= S_IDLE;
      endcase
    end
  end

  always @(posedge CLK)
  begin
    if (~NRST)
        TX_DSER <= 1'b1;  // tx is 1 by default
    else
    begin
    if (BAUDPULSE)
      begin
      case (S_next)
        S_IDLE :
          begin
            TX_DSER   <= 1'b1;         // Drive Line High for S_IDLE
          end

        S_START :
          begin
            TX_DSER <= 1'b0;
            data_bits_idx <= 0;
          end

        S_DATA :
          begin
            TX_DSER <= data_bits[data_bits_idx[2:0]];
            data_bits_idx <= data_bits_idx + 1;
          end

        S_STOP :
            begin
            data_bits_idx <= 0;
            TX_DSER <= 1'b1;
            end

        default :
          TX_DSER <= 1'b1;

      endcase
      end
    else;
  end
  end
endmodule
