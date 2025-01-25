//////////////////////////////////////////////////////////////////////
// File Downloaded from http://www.nandland.com
//////////////////////////////////////////////////////////////////////
 
// This testbench will exercise both the UART Tx and Rx.
// It sends out byte 0xAB over the transmitter
// It then exercises the receive by receiving byte 0x3F
`timescale 1ns/10ps

module uart_tb ();
 
  // Testbench uses a 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 87;
  parameter c_BIT_PERIOD      = 8600; // ns it takes to transmit a single bit
   
  // Driven procedurally
  reg r_Clock = 0;
  reg r_Tx_DV = 0;
  
  // Driven continuously -> can't store a value, they're simple points in a design
  wire r_TX_Active;
  wire w_Tx_Done;
  reg [7:0] r_Tx_Byte = 0;
  wire r_TX_serial;
  reg r_RX_Serial = 1;
  wire [7:0] w_Rx_Byte;
   
  
  /*
  *** TASK ***
  Code inside a task is ALWAYS executed sequentially. (like in "initial" or "always"-block)
  It has
  - input / output arguments
  - Timing control
  - Proc  Code inside a task is ALWAYS executed sequentially. (like in "initial" or "always"-block)
edural statements
  NOTE: the equivalent in VHDL is a function.
  */
    task UART_WRITE_BYTE;
    input [7:0] i_Data;  // Input byte to be transmitted
    integer ii;          // Loop counter
    begin
      // Send Start Bit (UART protocol requires a low start bit)
      r_RX_Serial <= 1'b0;  // Set r_RX_Serial to 0
      #(c_BIT_PERIOD);      // Delay C_BIT_PERIOD (8.6 us)
      #1000;                // Delay 1 us

      // Send Data Byte (8 bits)
      for (ii = 0; ii < 8; ii = ii + 1) begin
        r_RX_Serial <= i_Data[ii];  // Send the current bit
        #(c_BIT_PERIOD);            // Delay C_BIT_PERIOD (8.6 us)
      end

      // Send Stop Bit (UART protocol requires a high stop bit)
      r_RX_Serial <= 1'b1;  // Set r_RX_Serial to 1
      #(c_BIT_PERIOD);      // Delay C_BIT_PERIOD (8.6 us)
    end
  endtask
   
   
  uart_rx #(.g_CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST
    (.i_Clk(r_Clock),
     .i_RX_Serial(r_Rx_Serial),
     .o_RX_DV(),
     .o_RX_Byte(w_Rx_Byte)
     );
   
  uart_tx #(.g_CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_INST
    (.i_Clk(r_Clock),
     .i_TX_DV(r_Tx_DV),
     .i_TX_Byte(r_Tx_Byte),
     .o_TX_Active(r_TX_Active),
     .o_TX_Serial(r_TX_serial),
     .o_TX_Done(w_Tx_Done)
     );
 
  
  // Procedural block: statements inside it are executed sequentially
  // Here: creates a clock signal of c_CLOCK_PERIOD_NS (100 NS)
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
 
   
  // Main Testing:
  initial
    begin
       

      // Make the UART TX peripheral wait for 2 clock edges
      @(posedge r_Clock);
      @(posedge r_Clock);
      // Indicate to the UART that it can start sending
      // >>> Happens in parallel (since they have non-blocking assignment <=)
      r_Tx_DV <= 1'b1; // <1>: width 1, <'b>: binary, <1>: set to 1 (NOTE: we could also use '1' bu that would change when using multi-bus registers)
      r_Tx_Byte <= 8'hAB;
      // <<< Happens in parallel
      @(posedge r_Clock);
      r_Tx_DV <= 1'b0;

      /*
      Wait until w_Tx_Done rising edge (Transmission completed)
      EXPECTED WAITING TIME:
        - State-machine switching happens on a rising clock edge 
          - (r_clock = 100 ns)
          - C_CLKS_PER_BI (86 ns)
        1. (s_TX_IDLE) i_TX_DV <= 1, r_SM_Main <= start_bit
        2. (s_TX_START_Bit) o_TX_Active <='1', o_TX_Serial <='0'
            - Wait C_CLKS_PER_BIT-1  (86 ns)
            - when done: r_SM_Main <= s_TX_DATA_BITS
        3. (s_TX_DATA_Bits) o_TX_Serial <= r_TX_Data 
          - wait 86 ns (g_CLKS_PER_BIT-1)
          - then switch to the next bit
      */
      @(posedge w_Tx_Done);
       
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'h3F); // Send 0x3F using the task
      @(posedge r_Clock);
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h3F)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
       
    end
   
endmodule