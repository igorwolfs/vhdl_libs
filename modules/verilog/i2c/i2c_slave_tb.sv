`timescale 1ns / 1ps

module tb_i2c_slave;

  // ----------------------------------------
  // Testbench signals for the bus
  // ----------------------------------------
  reg  SCL_drive_tb;
  reg  SDA_drive_tb;
  
  wire SCL_pin;
  wire SDA_pin;
  
  assign SCL_pin = SCL_drive_tb;
  assign SDA_pin = SDA_drive_tb;

  reg NRST;


  // I2C slave I/O
  wire [6:0] ADDR_out;
  wire       ARDY_out;
  wire       RW_out;
  wire [7:0] ODATA_out;
  reg  [7:0] IDATA_in;
  wire       DRDY_out;
  wire       BUSY_out;
  
  // Stall signals
  reg  ACKA_RDY_tb;
  reg  ACKD_RDY_tb;

  // ----------------------------------------
  // Instantiate the i2c_slave
  // ----------------------------------------
  i2c_slave uut (
    .SCL      (SCL_pin),
    .SDA      (SDA_pin),
    .ADDR     (ADDR_out),
    .ARDY     (ARDY_out),
    .RW       (RW_out),
    .ODATA    (ODATA_out),
    .IDATA    (IDATA_in),
    .DRDY     (DRDY_out),
    .NRST     (NRST),
    .ACKA_RDY (ACKA_RDY_tb),
    .ACKD_RDY (ACKD_RDY_tb),
    .BUSY     (BUSY_out)
  );

  // ----------------------------------------
  // Initialization
  // ----------------------------------------
  initial begin
    // Initially, bus is idle: SDA=1, SCL=1
    SDA_drive_tb       = 1'b1;
    SCL_drive_tb       = 1'b1;
    NRST         = 1'b0;
    ACKA_RDY_tb  = 1'b1;  // By default, do not stall on ACKA
    ACKD_RDY_tb  = 1'b1;  // By default, do not stall on ACKD
    IDATA_in     = 8'hA5; // For read commands, slave will put this on the bus

    // Wait a bit, then release reset
    #1000;
    NRST = 1'b1;

    // Wait for reset to be propagated
    #1000;

    // -----------------------------------------------------
    // 1) Perform a dummy WRITE sequence (master writes data)
    // -----------------------------------------------------
    $display("==== Starting Dummy WRITE sequence ====");

    i2c_start();                    // start condition
    i2c_write_byte({7'h55, 1'b0});  // 7-bit address = 0x55, R/W=0 (WRITE)
    i2c_write_byte(8'hDE);          // data byte #1
    i2c_write_byte(8'hAD);          // data byte #2
    i2c_stop();

    #1000;

    // -----------------------------------------------------
    // 2) Perform a dummy READ sequence (master reads data)
    // -----------------------------------------------------
    $display("==== Starting Dummy READ sequence ====");

    i2c_start();
    i2c_write_byte({7'h55, 1'b1});  // 7-bit address = 0x55, R/W=1 (READ)
    i2c_read_byte(1'b1);            // read byte, then send ACK=1 (ACK)
    i2c_read_byte(1'b0);            // read another byte, then send NACK=0
    i2c_stop();

    #2000;
    $stop;  // End simulation
  end

  // ----------------------------------------
  // Basic I2C Timing Parameters
  // ----------------------------------------
  parameter BIT_PERIOD = 200;  // adjust for readability in simulation

  // ----------------------------------------
  // I2C Master Tasks (bit-banged)
  // ----------------------------------------

  // Pull SDA low while SCL high => START condition
  task i2c_start;
  begin
    SDA_drive_tb = 1'b1;
    SCL_drive_tb = 1'b1;
    #(BIT_PERIOD/2);
    SDA_drive_tb = 1'b0;   // SDA goes low while SCL is high
    #(BIT_PERIOD/2);
    SCL_drive_tb = 1'b0;   // Now drive clock low
    #(BIT_PERIOD);
  end
  endtask

  // Pull SDA high while SCL high => STOP condition
  task i2c_stop;
  begin
    // Assume SCL is already low
    SDA_drive_tb = 1'b0;
    #(BIT_PERIOD/2);
    SCL_drive_tb = 1'b1;
    #(BIT_PERIOD/2);
    SDA_drive_tb = 1'b1;
    #(BIT_PERIOD);
  end
  endtask

  // Master writes a byte: sends 8 bits, reads 1 bit ACK
  task i2c_write_byte(input [7:0] data_in);
    integer i;
    begin
      for (i=7; i>=0; i=i-1) begin
        // Put data on SDA
        SDA_drive_tb = data_in[i];
        #(BIT_PERIOD/2);
        // Rising edge => slave samples bit
        SCL_drive_tb = 1'b1;
        #(BIT_PERIOD/2);
        // Falling edge
        SCL_drive_tb = 1'b0;
        #(BIT_PERIOD/2);
      end
      // Now read ACK bit
      // Master releases SDA (goes high) so slave can drive it
      SDA_drive_tb = 1'b1;
      #(BIT_PERIOD/2);
      SCL_drive_tb = 1'b1;
      #(BIT_PERIOD/2);
      // Here you could sample SDA_drive_tb to check for actual ACK
      // For now, we just wait
      SCL_drive_tb = 1'b0;
      #(BIT_PERIOD/2);
    end
  endtask

  // Master reads a byte from slave: it releases SDA each bit, then
  // drives ACK=1 or NACK=0 after the byte
  task i2c_read_byte(input bit ack);
    integer i;
    reg [7:0] data_in;
    begin
      data_in = 8'h00;
      for (i=7; i>=0; i=i-1) begin
        // Release SDA
        SDA_drive_tb = 1'b1;
        #(BIT_PERIOD/2);
        // Rising edge => sample bit
        SCL_drive_tb = 1'b1;
        #(BIT_PERIOD/4);
        data_in[i] = SDA_drive_tb;  // sample
        #(BIT_PERIOD/4);
        // Falling edge
        SCL_drive_tb = 1'b0;
        #(BIT_PERIOD/2);
      end
      // Now master sends ACK or NACK
      SDA_drive_tb = ~ack;  // ack=1 => SDA=0 (ACK), ack=0 => SDA=1 (NACK)
      #(BIT_PERIOD/2);
      SCL_drive_tb = 1'b1;
      #(BIT_PERIOD/2);
      SCL_drive_tb = 1'b0;
      #(BIT_PERIOD/2);
      
      $display("Master read byte = 0x%02h (sent ack=%b) at time %t", data_in, ack, $time);
    end
  endtask

endmodule