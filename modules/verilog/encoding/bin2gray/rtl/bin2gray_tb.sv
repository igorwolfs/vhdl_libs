
module bin2gray_tb();

    // * TEST DATA
    // BITS
    localparam DATA_BITS = 8;
    // TESTS
    localparam N_TESTS = 16;
    localparam logic [7:0] TESTS_IN[15:0] = {
    8'h23, 8'h25, 8'hff, 8'h13,8'h00, 8'h11, 8'h99, 8'h11,
    8'h22, 8'hfa, 8'haf, 8'hba,8'hab, 8'h91, 8'h01, 8'h10
    };

    reg [DATA_BITS-1:0] b_data_in;
    reg [DATA_BITS-1:0] g_data_in;
    wire [DATA_BITS-1:0] g_data_out;
    wire [DATA_BITS-1:0] b_data_out;

    // * TEST
    bin2gray #(.N(DATA_BITS)) bin2gray_inst (.bin_in(b_data_in), .gray_out(g_data_out));
    gray2bin #(.N(DATA_BITS)) gray2bin_inst (.gray_in(g_data_in), .bin_out(b_data_out));

    reg clk = 0;

    always #5 clk <= ~clk; // 10 ns clock
    assign g_data_in = g_data_out;
    
    initial
    begin
        $dumpfile("vars.vcd");                // default "dump.vcd"
        for (integer test_idx=0; test_idx < N_TESTS; test_idx=test_idx+1)
        begin            
            @(negedge clk)
            b_data_in = TESTS_IN[test_idx];
            // Convert them to gray with the module (done through assign)
            // Convert the gray back to binary with the module (into var b_data_out)
            // Check if the converted-back is consistent with the test module
            @(posedge clk)
            if (b_data_out == TESTS_IN[test_idx]) $display("Test %d success!", test_idx);
            else $display("Test %d FAIL", test_idx);
        end
        $dumpfile("vars.vcd");
    end

endmodule

// * NOTE: The modules are combinatorial, so a clock is only necessary for test-bench timing.