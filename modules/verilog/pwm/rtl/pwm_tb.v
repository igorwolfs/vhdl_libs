`timescale 1ns / 10ps

module testbench;

// INPUT
reg clk = 0;
// OUTPUT
wire [3:0] led;

// the "pwm"module is the design we want to test (unit under test)
// clk -> connected to clock input, led ->connected to the output of the module (as defined in the module)
pwm UUT (
    .clk(clk),
    .led(led)
);
    
// Generate a clock signal of 10 ns (timescale 1 ns / 1 ps) (5 ns high, 5 ns low)
always #5 clk = ~clk;


endmodule;

/*
Make sure to drag the counter period into the simulation as well, so you can see the register bits changing.
*/