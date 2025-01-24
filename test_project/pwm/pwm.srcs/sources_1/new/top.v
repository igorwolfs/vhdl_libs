`timescale 1ns / 10ps

module pwm(
    input clk,
    output [3:0] led // Change LED to bus of 4
    );

// Create a counter that gets triggered on the positive edge of the clock
reg [7:0] counter =0; // Counter 8-bits wide, reg: memory (e.g.: fliflop)
always @(posedge clk) begin // Do at positive clock-edge
    if (counter == 16'hFFFF) // Overflow detected
        counter <= 0;
    if (counter < 100) counter <= counter+1; // count until we get to 200
    else 
        counter <= 0; // reset counter to 0
end

// Create a 25 % duty cycle
assign led[0] = (counter < 10) ? 1:0; // Assign led to 1 if counter value is less than 10

// Create a 30 % duty cycle
assign led[1] = (counter < 20) ? 1:0; // Assign led to 1 if counter value is less than 50

// Create a 50 % duty cycle
assign led[2] = (counter < 30) ? 1:0; // Assign led to 1 if counter value is less than 50

// Create a 70 % duty cycle
assign led[3] = (counter < 40) ? 1:0; // Assign led to 1 if counter value is less than 50


// Led should be on for 50 x 5 ns
// Led should be off for 150 x 5 ns
endmodule // NOTE: all procedural code must ALWAYS be inside a module.

/*
# Blocking vs non-blocking assignment
- <= non-blocking assignment (model sequential logic, flip-flops, registers, ..
    - In procedural block: updates at LHS occur at end of current simulation t-step.
    - Prevents race conditions when multiple variables updated at the same time
    - Use in e.g.: sequential logic (flip-flops, registers).
    
- = blocking assignemnts
    - e.g.: a=b; b=a; -> a and b will have the same , next assignment (b=a) is only executed when previous assignment (a=b) is complete.
    - Use in e.g.: combinatorial logic / procedural 

# "Bus of 4"
4-bit wide bus, [4:0] defines the order of the bus
- 3: MSB
- 0: LSB
-> standard convention in digital design.


*/