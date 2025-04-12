`timescale 1ns/1ps
module tb_dual_i2c;

  //-------------------------------------------------------------------------
  // Parameters
  //-------------------------------------------------------------------------
  parameter CLOCK_FREQUENCY = 100_000_000;
  parameter I2C_FREQ        = 100_000;
  parameter DATA_BITS       = 8;

  //-------------------------------------------------------------------------
  // Clock and Reset Signals
  //-------------------------------------------------------------------------
  reg CLK;
  reg NRST;

  //-------------------------------------------------------------------------
  // I2C Bus Wires (shared open-drain bus)
  //-------------------------------------------------------------------------
  wire I2C_SDA_bus;
  wire I2C_SCL_bus;

  // Instantiate pull-ups for simulation (open-drain bus behavior)
  pullup (I2C_SDA_bus);
  pullup (I2C_SCL_bus);

  //-------------------------------------------------------------------------
  // Master (Transmitter) Signals
  //-------------------------------------------------------------------------
  reg [7:0] master_IDATA;
  reg [6:0] master_IADDR;
  reg       master_I_RW;    // 0 = write, 1 = read
  reg       master_IDRDY;
  wire [7:0] master_ODATA;
  wire       master_BUSY;
  wire       master_ODRDY;

  //-------------------------------------------------------------------------
  // Slave (Receiver) Signals
  //-------------------------------------------------------------------------
  reg [7:0] slave_IDATA;
  reg [6:0] slave_IADDR;
  reg       slave_I_RW;     // For a slave, this could determine data direction.
  reg       slave_IDRDY;
  wire [7:0] slave_ODATA;
  wire       slave_BUSY;
  wire       slave_ODRDY;

  //-------------------------------------------------------------------------
  // Instantiate the Master I2C Controller
  //-------------------------------------------------------------------------
  i2c_controller #(
    .CLOCK_FREQUENCY(CLOCK_FREQUENCY),
    .I2C_FREQ(I2C_FREQ),
    .DATA_BITS(DATA_BITS)
  ) master_i2c (
    .CLK    (CLK),
    .NRST   (NRST),
    .I2C_SDA(I2C_SDA_bus),
    .I2C_SCL(I2C_SCL_bus),
    .IDATA  (master_IDATA),
    .IADDR  (master_IADDR),
    .I_RW   (master_I_RW),
    .ODATA  (master_ODATA),
    .BUSY   (master_BUSY),
    .ODRDY  (master_ODRDY),
    .IDRDY  (master_IDRDY)
  );

  //-------------------------------------------------------------------------
  // Instantiate the Slave I2C Controller
  //-------------------------------------------------------------------------
  i2c_controller #(
    .CLOCK_FREQUENCY(CLOCK_FREQUENCY),
    .I2C_FREQ(I2C_FREQ),
    .DATA_BITS(DATA_BITS)
  ) slave_i2c (
    .CLK    (CLK),
    .NRST   (NRST),
    .I2C_SDA(I2C_SDA_bus),
    .I2C_SCL(I2C_SCL_bus),
    .IDATA  (slave_IDATA),
    .IADDR  (slave_IADDR),
    .I_RW   (slave_I_RW),
    .ODATA  (slave_ODATA),
    .BUSY   (slave_BUSY),
    .ODRDY  (slave_ODRDY),
    .IDRDY  (slave_IDRDY)
  );

  //-------------------------------------------------------------------------
  // Clock Generation: 100 MHz (10 ns period)
  //-------------------------------------------------------------------------
  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;  // toggle every 5 ns
  end

  //-------------------------------------------------------------------------
  // Reset Generation
  //-------------------------------------------------------------------------
  initial begin
    NRST = 0;
    #20;
    NRST = 1;
  end

  //-------------------------------------------------------------------------
  // Test Sequence
  //-------------------------------------------------------------------------
  initial begin
    // Initialize both master and slave signals
    master_IDATA = 8'h00;
    master_IADDR = 7'h00;
    master_I_RW  = 1'b0;  // Start with write operation
    master_IDRDY = 1'b0;

    // Configure slave with its address and preload data to be sent on a read transaction
    slave_IDATA = 8'h55;  // Arbitrary data value to send back on read
    slave_IADDR = 7'h50;  // Slave address
    slave_I_RW  = 1'b0;   // Slave idle setting; in a real scenario, this might be auto-detected
    slave_IDRDY = 1'b0;

    // Wait for reset deassertion
    @(posedge NRST);
    #50;

    //===============================
    // Write Transaction (Master TX)
    //===============================
    $display("Time %t: Master Write Transaction Starting...", $time);
    
    master_IADDR = 7'h50;    // Set target slave address
    master_IDATA = 8'hA5;    // Data to write to the slave
    master_I_RW  = 1'b0;     // Write operation
    master_IDRDY = 1'b1;     // Indicate data ready for transmission
    #10;
    master_IDRDY = 1'b0;

    // Wait until the master controller indicates completion (BUSY goes low)
    wait (master_BUSY == 1'b0);
    $display("Time %t: Master Write Completed. Master ODATA: %h", $time, master_ODATA);
    #100;

    //===============================
    // Read Transaction (Master RX)
    //===============================
    $display("Time %t: Master Read Transaction Starting...", $time);
    
    master_IADDR = 7'h50;    // Set target slave address
    master_I_RW  = 1'b1;     // Read operation
    master_IDRDY = 1'b1;     // Signal transaction start for read
    #10;
    master_IDRDY = 1'b0;

    // The slave should be prepared to send data. In this simple testbench,
    // we signal the slave that data is ready with slave_IDRDY.
    slave_IDRDY = 1'b1;
    #10;
    slave_IDRDY = 1'b0;

    // Wait until the master controller receives the data (ODRDY asserted)
    wait (master_ODRDY == 1'b1);
    $display("Time %t: Master Read Completed. Data received: %h", $time, master_ODATA);
    #100;

    $finish;
  end

  //-------------------------------------------------------------------------
  // Optional: Dump waveforms for viewing in a waveform viewer
  //-------------------------------------------------------------------------
  initial begin
    $dumpfile("tb_dual_i2c.vcd");
    $dumpvars(0, tb_dual_i2c);
  end

endmodule
