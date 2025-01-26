# Sequence
- Clock period: c_CLOCK_PERIOD_NS = 40 ns

## Wait 2 clock edges 
@posedge (r_Clock)

### Why is w_TX_Serial 1 at the beginning?
- Because it is set to 1 on a posedge i_Clock or negedge i_Rst_L