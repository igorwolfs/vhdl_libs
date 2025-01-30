// hello
`timescale 1ns/10ps

`include "top_uart_tx_app.v"
`include "uart_tx.v"
`include "uart_rx.v"

module uart_tx_tb();

    // Test buton input
    reg [3:0] button_i = 4'b0000;
    reg [3:0] r_btn_active = 4'b0001;

    // reference clock (should simply be 1 ns)
    parameter c_DEFAULT_SEND_RATE = 750;//_000;
    parameter c_DEFAULT_CLOCK_IN = 10;//_000;

    reg r_ref_clk = 0, rst_n_i = 1'b0;

    wire uart_tx_data_o, uart_tx_active_o;

    top_uart_tx_app #(.DEFAULT_SEND_RATE(c_DEFAULT_SEND_RATE),
    .DEFAULT_CLOCK_IN(c_DEFAULT_CLOCK_IN)
    ) top_uart_tx_app_inst
    (
     .rst_n_i(rst_n_i),
     .button_i(button_i),
     .clk_i(r_ref_clk),
     .uart_tx_data_o(uart_tx_data_o),
     .uart_tx_active_o(uart_tx_active_o)
    );

    task do_reset;
    begin
        rst_n_i <= 1'b1;
        #160;
        rst_n_i <= 1'b0;
        #160;
        rst_n_i <= 1'b1;
        #160;
    end
    endtask

    always
        #5 r_ref_clk = ~r_ref_clk; // Clock period of 10 ns (100 MHz)

    initial
        begin
            do_reset;
            #1600
            for (integer i=0; i<4; i = i + 1)
            begin
                $display("BUTTON %d", i);
                button_i <= r_btn_active;
                @(negedge uart_tx_active_o);
                button_i <= 4'b0;
                #160;
                r_btn_active = (r_btn_active << 1);
            end
            #35_000;
            r_btn_active = 4'b0001;
            for (integer i=0; i<4; i = i + 1)
            begin
                $display("BUTTON %d", i);
                button_i <= r_btn_active;
                @(negedge uart_tx_active_o);
                button_i <= 4'b0;
                #160;
                r_btn_active = (r_btn_active << 1);
            end
            $finish;
        end
endmodule