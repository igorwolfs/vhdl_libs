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