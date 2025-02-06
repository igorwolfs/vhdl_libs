## Issue 1
- For some reason the full_out becomes blank after a reset.
- This is probably because wfull is blank after one clock cycle
- This is probably because (one or more) are undefined after the first 2 clock-cycles
    - wrap_around (depends on the next 2 variables too)
    - rptr_b_sync -> comes from rptr_g_sync_in
        - we need at least 2 clock cycles to pass on the wptr signal through the flipflop from the reset
        - However the flip-flop should be reset with the read and write reset signal
    - wptr_b_out -> defined after reset

### Possible solution:
- Reset
- Wait for 20 clock cycles on read and write side
- Start transmission

=> I forgot to assign the register values before starting the simulation.

## Issue 2
- For some reason the full_out goes uncertain when the r_nrst_in is low.
- It also goes uncertain the read_clk edge after the first r_nrst_in

Again probably has something to do with the reset itself.
### Solution
I messed up the clock signals in the test-bench

## Issue 3

If we keep the write_in high, and simply switch the data we write in:
```verilog
begin
data_write_in <= TESTS_IN[i];
write_in <= 1;
@(posedge write_clk);
end
```
Eventually some data will be written to buffer position 0.
```verilog
begin
data_write_in <= TESTS_IN[i];
write_in <= 1;
@(posedge write_clk);
write_in <= 0;
@(posedge write_clk);
end
```
This solves the problem.

### Solution 1
We have to figure out why the buffer asserts being full 1 write-cycle late.
- It's probably because the wrap-around only works for powers of 2, since otherwise we just keep counting up the count-number and it doesn't reset. Also when choosing uneven buffer sizes it somehow doesn't write the last bit.

### Follow up issue 2
-> However it seems that choosing even buffer sizes also doesn't solve the issue.
- The buffer simply rewrites index 0 while it already contains data.

The full-flag does in fact assert right on the clock edge where the buffer gets written with data. So the issue is probably that it needs to assert this flag at the moment we wrote something into the last available buffer item.

Let's see what the bottleneck is here
- wrap_around: asserts early enough.
- wfull: asserts the clock cycle before
- However just one cycle early for the update.
Question:
- Why can't we just assign full as a combinatorial signal? It should become 0 anyways at the start since the signals driving it are 0.

Guess: it should be combinatorial, everything asserts correctly 1 cycle before, it's just the full-signal that asserts too late because of the clock delay.

### Solution 2
Make the full AND empty signal combinatorial.
It makes sense, since if there are sequential. Assume.
- The read signal stays the same
- The write signal keeps incrementing until it hits the buffer end
- At the moment the buffer reaches the last write position, the assigned wfull gets assigned full
- It takes an additional clock cycle from that to assign the full-flag to be full.


#### Follow up issue 2
We get stuck in an endless loop when we do this with the empty-signal. Probably due to some logic recursion.

### Solution 3
We need to make sure that IF there is a write going on and IF the next value is the same as the previous AND there is wrap-around, THEN there needs to be a FULL asserted in THE SAME CLOCK CYCLE.

Previously the current value would be changed to the next in the clock cycle, this would change the rempty.
Only the next clock cycle rempty would then be assigned to empty.
This should all happen at the same time if we want the full signal to assert the moment the buffer's current read signal is wrapped around.


## Issue 4
Now for some reason in testing the test passes 4 times, but only writes 3 times. 

The data is only written after it is certain that the next write pointer will be equal to the read pointer.
This is only known, the clock cycle after the nth data-point has been written. 
- SO it goes through the assertions
- But on the next write-cycle it asserts full, so it doesn't actually fill the buffer.

### NOTE
- The buffer will assert full AFTER the last data-point has been written, so after that clock cycle.
-> This might become an issue however, since we don't exactly know how much data we wrote to the buffer, since it will increment an extra clock cycle.
-> So the best thing would still be to try and make it combinatorial

## Issue 5
The read-signal asserts too late. The read-signal should assert if the read pointer will be equal to the right pointer for the next clock cycle.

We indeed have the issue now that the an additional read happens due to the is_empty not being asserted on time.

Changing the dynamic here to an in-loop change doesn't change the situation however, since it was already combinatorial
- (wptr_b_sync == rptr_b_next) was assigned combinatorially, and was assigned to empty_out every clock cycle.
We do need something combinatorial here.


### Answer 
The issue is probably that empty_out has a recursive definition with an undefined state. And it does indeed


```verilog
assign rptr_b_next = rptr_b_out + (read_in & !(wptr_b_sync == rptr_b_next));
assign empty_out = (wptr_b_sync == rptr_b_next);
```

It also seems that the verilog test-bench does take 1 out of every 2 clock cycles to write. 
So when it reads it
- Reads one clock cycle
- Waits one clock cycle
When it writes it
- writes one clock cycle
- waits one clock cycle

But when your clock signal is equal to the data-rate, this seems like a weird way to fill a FIFO? 
- Shouldn't the fifo be able to handle data at the clock speed of your peripheral?
- Maybe you assume that your peripherals will always be driven at a higher speed than the data-rate, because you have counters and dividers present at the peripheral?

So, it appears that the read / write works perfectly, but the check whether the read / write succeeded depends on whether the is_full or is_empty is asserted after reading / writing.
So just make sure to follow this structure when reading and writing:

Writing:
```verilog
begin
data_write_in <= TESTS_IN[i];
write_in <= 1;
@(posedge write_clk);
if (!full_out)
    begin
    $display("Data %d written to buffer, full: %d", i, full_out);
    $display("Data %d written to buffer, full: %d", i, full_out);
    // write_in <= 0;
    // @(posedge write_clk);
    end
else
    $display("BUFFER IS FULL %d", i);
end
```


Reading:
```verilog
begin
read_in <= 1;
@(posedge read_clk);
if (!empty_out)
    begin
    if (data_read_out == TESTS_IN[i]) $display("Read test OK %d", i);
    else  $display("read Test FAIL %d", i);
    end
else
    $display("Buffer EMTPY! %d", i);
end
```