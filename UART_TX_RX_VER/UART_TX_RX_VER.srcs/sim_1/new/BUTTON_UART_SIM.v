// hello
`timescale 1ns/10ps

`include "top.v"
`include "UART_TX.v"
`include "UART_RX.v"

module BUTTON_UART_SIM();

    // Test buton input 
    reg [3:0] r_btn = 4'b0000;
    // reference clock (should simply be 1 ns)
    parameter c_DEFAULT_SEND_RATE = 750_000;
    reg r_ref_clk = 0;
    wire r_tx_serial;
    wire r_tx_active;

    top #(.DEFAULT_SEND_RATE(c_DEFAULT_SEND_RATE)) top_inst
    (.p_btn(r_btn),
     .p_ref_clk(r_ref_clk),
     .p_tx_serial(r_tx_serial),
     .p_tx_active(r_tx_active)
    );

    always 
    begin
        #5;
        r_ref_clk = ~r_ref_clk;
    end // Clock period of 10 ns (100 MHz)

    initial
        begin
            #100;
            r_btn <= 4'b0001;
            // Wait until tx is done
            @(negedge r_tx_active);
            #100;
            r_btn <= 4'b0010;
            @(negedge r_tx_active);
            #100;
            r_btn <= 4'b0100;
            @(negedge r_tx_active);
            #100;
            r_btn <= 4'b1000;
            #100;
            @(negedge r_tx_active);
            r_btn <= 4'b0000;
            #100;
            @(negedge r_tx_active);
            #100;
            $finish;
        end
endmodule