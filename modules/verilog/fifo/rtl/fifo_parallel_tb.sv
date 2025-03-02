`timescale 1ns/10ps

module fifo_parallel_tb();

    // *** DEPTH / WIDTH
    localparam DEPTH = 16; // Try
    localparam WIDTH = 8;
    localparam RCLK_PERIOD = 10;
    localparam WCLK_PERIOD = 20;
    // *** TESTS
    // Queue to push data_in
    reg [WIDTH-1:0] wdata_q[$], wdata;

    // * clocks
    reg RCLK = 0;
    always #(RCLK_PERIOD/2) RCLK = ~RCLK;

    reg WCLK = 0;
    always #(WCLK_PERIOD/2) WCLK = ~WCLK;

    // *** DATA
    reg [31:0] rand_in;
    reg [WIDTH-1:0] W_DI = 0;
    reg WNRST = 0, RNRST = 0;
    wire [WIDTH-1:0] R_DO;
    wire FULL, EMPTY;
    reg W_EN = 0, REN = 0;


    // *** FIFO Creation
    fifo_async_circular #(.DEPTH(DEPTH), .WIDTH(WIDTH)) async_fifo (
    .RCLK(RCLK), .WCLK(WCLK),
    .W_EN(W_EN), .REN(REN),
    .WNRST(WNRST), .RNRST(RNRST),
    .W_DI(W_DI), .R_DO(R_DO),
    .FULL(FULL), .EMPTY(EMPTY));

  initial begin
    WNRST = 1'b1;
    RNRST = 1'b1;
    repeat(2) @(posedge WCLK);
    repeat(2) @(posedge RCLK);
    WNRST = 1'b0;
    RNRST = 1'b0;
    repeat(2) @(posedge WCLK);
    repeat(2) @(posedge RCLK);
    WNRST = 1'b1;
    RNRST = 1'b1;
  end

  // *** WRITE ***
  always @(posedge WNRST) begin
    W_EN = 1'b0;
    W_DI = 0;
    repeat(10) @(posedge WCLK);
    repeat(2) begin
      for (int i=0; i<30; i++) begin
        @(posedge WCLK iff !FULL);
        W_EN = (i%2 == 0)? 1'b1 : 1'b0;
        if (W_EN) begin
            rand_in = $urandom;
            W_DI = rand_in[WIDTH-1:0];
          wdata_q.push_back(W_DI);
        end
      end
      #50;
    end
  end

  // *** READ ***
  always @(posedge RNRST) begin
    REN = 1'b0;
    repeat(20) @(posedge RCLK);
    repeat(2) begin
      for (int i=0; i<30; i++) begin
        @(posedge RCLK iff !EMPTY);
        REN = (i%2 == 0)? 1'b1 : 1'b0;
        if (REN) begin
          wdata = wdata_q.pop_front();
          if(R_DO !== wdata) $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, R_DO);
          else $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h",$time, wdata, R_DO);
        end
      end
    end
  #50;
  $finish;
  end
endmodule
