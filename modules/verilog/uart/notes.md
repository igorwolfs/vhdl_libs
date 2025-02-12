# Sequence
- Clock period: c_CLOCK_PERIOD_NS = 40 ns

## Wait 2 clock edges 
@posedge (r_Clock)

### Why is w_TX_Serial 1 at the beginning?
- Because it is set to 1 on a posedge i_Clock or negedge i_Rst_L


# Reset signals
- There is ALWAYS a hardware cost associated with setting initial registers. Registers are by default always floating.
- By adding a reset-input, one can perform this operation.


# ISSUE
- When sending in default mode
    - the rx-bytes are set to 2e
    - then the TX_DV is set to high
    - then the byte is set to 0 by default (maybe this shouldn't be done?)

# NEXT STEP
- Create a uart RX and TX and test it on hardware
- Retreive data through the RX module
- Send a hardware-stream of unprocessed signal-data
- Perform signal processing on the data
- Send it back through the TX module

# Clock variety in UART
Note that in UART, the system clock should be used to assert register signals like
 - data_rdy_in
 - tx_busy_out
 - tx_done_out
 - nrst_in

 So that modules external to the uart module can use the same module to write / read data to the uart-peripheral.

 Otherwise we'd have to export the baud-clock which would be pretty cumbersome.

 So we modified the uart peripheral to 
- rx: generate its own oversampling counter.
- rx, tx: take in the system clock and the baud clock for register triggering

## RX Issue
So we need to create a clock that can keep track of half the baud-clock, and then trigger.

So we need to treat the 2 as separate clock domains, and use them in separate always @(posedge) loops.

So how can we then change the flags in one clock domain and transfer the data in another clock domain?

## Issues with adding only a baud clock in the RX-case
CONTROLLED AS SYSCLOCK RATE:
- The data_rdy_out should assert only a single sysclk cycle.
- The nrst_in should assert only a single syclk cycle

1. When in idle -> sample in clk_cycles
2. Once downward detected, wait half the baud rate cycle
3. Then set the mode to data_read mode, here the wait should happen each baud_clk-cycle.
    - The issue however here is that the baud clock could have just asserted, so we'd miss out on another cycle for this bit
    - or the baud cycle will still assert in 2 sysclk cycles which means there will be a negative bit erroneously sampled
    - In that sense the previous solution seems better? Or having some kind-of divided baud rate instead of the actual one.

So let's use 
- the divided clock + the sysclk for this case
- the sysclk + divided clk for the other case

Otherwise you would need 2 baud generators to operate rx and tx.

### Setting the bit_idx to zero
Issue: we use the data_bits_idx to signal the state to the primary uart_rx-module.
However we need to set this value to 0.
data_bits_idx <= 0;
-> So perhaps the best way to actually do this is to move it into the "else"
- So we add an extra else if divpulse isn't enabled, and set the data_bits_idx to 0 there when the state is idle and the divpulse isn't enabled