// hello
`timescale 1ns/10ps

`include "top.v"
`include "UART_TX.v"
`include "UART_RX.v"

module BUTTON_UART_SIM();

    // Test buton input
    reg [3:0] r_btn = 4'b0000;
    reg [3:0] r_btn_active = 4'b0001;
    // reference clock (should simply be 1 ns)
    parameter c_DEFAULT_SEND_RATE = 750_000;
    reg r_ref_clk = 0;
    reg reset_in = 1'b0;
    wire r_tx_serial;
    wire r_tx_active;

    top #(.DEFAULT_SEND_RATE(c_DEFAULT_SEND_RATE)) top_inst
    (
     .i_Rst_L(reset_in),
     .p_btn(r_btn),
     .p_ref_clk(r_ref_clk),
     .p_tx_serial(r_tx_serial),
     .p_tx_active(r_tx_active)
    );

    task do_reset;
    begin
        reset_in <= 1'b1;
        #160;
        reset_in <= 1'b0;
        #160;
        reset_in <= 1'b1;
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
                r_btn <= r_btn_active;
                @(negedge r_tx_active);
                r_btn <= 4'b0;
                #160;
                r_btn_active = (r_btn_active << 1);
            end
            #1600;
            $finish;
        end
endmodule
