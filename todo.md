# Todo
# Testbench setup
Setup a verilator testbench for 
## FIFO TESTBENCH SETUP

- The regular testbench is running
    - HOWEVER: it doesn't seem to function 100 % correctly, there seem to be issues with the test itself
- There seem to be lots of writes happening, the reads are not able to keep up with the writes because they happen too late.
- Try to increase the buffer size.


### Create a module that performs DFT 
- Input: sinusoidal signal over UART / other protocol, using RX
- Output: fourier-transformed signal using TX

## Get the xADC up and running
## Stream the data from the xADC to the serial device
