module async_fifo_circular_parallel_tb;

    // *** DEPTH / WIDTH
    localparam DEPTH = 16; // Try
    localparam WIDTH = 8;
    localparam READ_CLK_PERIOD = 10;
    localparam WRITE_CLK_PERIOD = 20;

    // *** TESTS
    // Queue to push data_in
    reg [WIDTH-1:0] wdata_q[$], wdata;

    // * clocks
    reg read_clk = 0;
    always #(READ_CLK_PERIOD/2) read_clk = ~read_clk;

    reg write_clk = 0;
    always #(WRITE_CLK_PERIOD/2) write_clk = ~write_clk;

    // *** DATA
    reg [WIDTH-1:0] data_write_in = 0;
    reg w_nrst_in = 0, r_nrst_in = 0;
    wire [WIDTH-1:0] data_read_out;
    wire full_out, empty_out;
    reg write_in = 0, read_in = 0;


    // *** FIFO Creation
    fifo_async_circular #(.DEPTH(DEPTH), .WIDTH(WIDTH)) async_fifo (
    .read_clk(read_clk), .write_clk(write_clk),
    .write_in(write_in), .read_in(read_in),
    .w_nrst_in(w_nrst_in), .r_nrst_in(r_nrst_in),
    .data_write_in(data_write_in), .data_read_out(data_read_out),
    .full_out(full_out), .empty_out(empty_out));


  initial begin
    write_clk = 1'b0; w_nrst_in = 1'b0;
    write_in = 1'b0;
    data_write_in = 0;

    repeat(10) @(posedge write_clk);
    w_nrst_in = 1'b1;

    repeat(2) begin
      for (int i=0; i<30; i++) begin
        @(posedge write_clk iff !full_out);
        write_in = (i%2 == 0)? 1'b1 : 1'b0;
        if (write_in) begin
            data_write_in = $urandom;
          wdata_q.push_back(data_write_in);
        end
      end
      #50;
    end
  end

  initial begin
    read_clk = 1'b0; r_nrst_in = 1'b0;
    read_in = 1'b0;

    repeat(20) @(posedge read_clk);
    r_nrst_in = 1'b1;

    repeat(2) begin 
      for (int i=0; i<30; i++) begin
        @(posedge read_clk iff !empty_out);
        read_in = (i%2 == 0)? 1'b1 : 1'b0;
        if (read_in) begin
          wdata = wdata_q.pop_front();
          if(data_read_out !== wdata) $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, data_read_out);
          else $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h",$time, wdata, data_read_out);
        end
      end
      #50;
    end

    $finish;
  end
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule