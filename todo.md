# Todo
# Testbench setup
Setup a verilator testbench for 
## FIFO TESTBENCH SETUP
- Setup verilator testbench for fifo using makefile and verilator
- Eliminate combinatorial loops by 
    - Introducing a single-cycle delay in the full empty synchronization

- The regular testbench is running
    - HOWEVER: it doesn't seem to function 100 % correctly, there seem to be issues with the test itself
- The parallel testbench for now doesn't want to be found
    - Check sources

### Create a module that performs DFT 
- Input: sinusoidal signal over UART / other protocol, using RX
- Output: fourier-transformed signal using TX

## Get the xADC up and running
## Stream the data from the xADC to the serial device
