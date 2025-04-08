`timescale 1ns/1ps
module tb_i2c_controller;

  //--------------------------------------------------------------------------
  // Parameters
  //--------------------------------------------------------------------------  
  parameter CLOCK_FREQUENCY = 100_000_000;
  parameter I2C_FREQ        = 100_000;
  parameter DATA_BITS       = 8;

  //--------------------------------------------------------------------------
  // Signal Declaration
  //--------------------------------------------------------------------------  
  reg               CLK;
  reg               NRST;
  wire              I2C_SDA;
  wire              I2C_SCL;
  reg  [7:0]        IDATA;
  reg  [6:0]        IADDR;
  reg               I_RW;
  wire [7:0]        ODATA;
  wire              BUSY;
  wire              ODRDY;
  reg               IDRDY;

  //--------------------------------------------------------------------------
  // Pull-ups for I2C open-drain behavior (optional for simulation)
  //--------------------------------------------------------------------------  
  pullup (I2C_SDA);
  pullup (I2C_SCL);

  //--------------------------------------------------------------------------
  // DUT Instantiation
  //--------------------------------------------------------------------------  
  i2c_controller #(
    .CLOCK_FREQUENCY(CLOCK_FREQUENCY),
    .I2C_FREQ(I2C_FREQ),
    .DATA_BITS(DATA_BITS)
  ) dut (
    .CLK    (CLK),
    .NRST   (NRST),
    .I2C_SDA(I2C_SDA),
    .I2C_SCL(I2C_SCL),
    .IDATA  (IDATA),
    .IADDR  (IADDR),
    .I_RW   (I_RW),
    .ODATA  (ODATA),
    .BUSY   (BUSY),
    .ODRDY  (ODRDY),
    .IDRDY  (IDRDY)
  );

  //--------------------------------------------------------------------------
  // Clock Generation: 10 ns period = 100 MHz clock
  //--------------------------------------------------------------------------  
  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  //--------------------------------------------------------------------------
  // Reset Generation
  //--------------------------------------------------------------------------  
  initial begin
    NRST = 0;
    #20;
    NRST = 1;
  end

  //--------------------------------------------------------------------------
  // Optional Waveform Dump (for simulation viewing)
  //--------------------------------------------------------------------------  
  initial begin
    $dumpfile("tb_i2c_controller.vcd");
    $dumpvars(0, tb_i2c_controller);
  end

  //--------------------------------------------------------------------------
  // Test Sequence
  //--------------------------------------------------------------------------  
  initial begin
    // Initialize signals
    IDATA = 8'h00;
    IADDR = 7'h00;
    I_RW  = 1'b0;
    IDRDY = 1'b0;

    // Wait until reset is released
    @(posedge NRST);
    #50;

    //--- Write Transaction Example ------------------------------------------
    $display("Starting Write Transaction...");
    IADDR = 7'h50;   // Example I2C address (change as needed)
    IDATA = 8'hA5;   // Data to be written
    I_RW  = 1'b0;    // Write operation assumed when I_RW is 0
    IDRDY = 1'b1;    // Signal that data is ready for transmission
    #10;
    IDRDY = 1'b0;

    // Wait until the DUT indicates the transaction is complete
    wait (BUSY == 1'b0);
    $display("Write Transaction Completed. Output data: %h", ODATA);

    #100;

    //--- Read Transaction Example -------------------------------------------
    $display("Starting Read Transaction...");
    IADDR = 7'h50;   // Example I2C address for the read
    I_RW  = 1'b1;    // Read operation assumed when I_RW is 1
    IDRDY = 1'b1;    // Indicate data ready for transmission
    #10;
    IDRDY = 1'b0;

    // Wait until data reception is complete (ODRDY asserted)
    wait (ODRDY == 1'b1);
    $display("Read Transaction Completed. Data read: %h", ODATA);

    #100;

    $finish;
  end

endmodule