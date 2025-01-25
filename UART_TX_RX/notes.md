# Result
See image.
## Sending and receiving
- w_Rx_Byte-bits seem to be zero for some reason.
- r_RX_Serial is nonzero however.


Every-time 
- s_RX_Data_Bits is trigger
- r_Clk_Count has counted until C_CLKS_PER_BIT-1

r_RX_Byte(r_Bit_Index) is assigned r_RX_Data
And at the end 
- o_RX_Byte <= r_RX_Byte;