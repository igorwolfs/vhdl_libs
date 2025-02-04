`timescale 1ns/10ps

/**
# Inputs and ouptus
PARAMETERS
- DATA_WIDTH (bitwidth for a single fifo)
- DATA_DEPTH (depth for a single fifo)
Inputs:
- data_in (input data)
- push_in (save input data)
- fetch_in (get output data)
Outputs:
- data_out (output data)
- full_out (signals if fifo is full)
*/

module fifo
    #(parameter DATA_WIDTH = 8)
(
    
)