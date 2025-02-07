# Todo
## UART
- Create a UART RX module
- Create tests for the module using systemverilog
- Create a UART TX module
- Test the UART TX module in systemverilog
- Combine the UART RX, TX module together with the baud generator
- Create systemverilog tests for this module
- Create a simple ECHO-application using the fifo buffer

## Fifo
- Make sure to understand the full fifo
- change it to verilog code.

### bin2gray
Make bin2gray hardawre conversion module

### Create a module that sends random signals with this UART module
- Takes input from buttons
- depending on 8-bit button combination, sends number

OR
- Simply make a module with just the clk-input.
- Call the UART-byte with a single number

### Creating the LED-testing module
- 8 register-bits in
- 8 LED's out
- if 2 registers on the bus are set at the same time -> break down.

### Create a module that performs DFT 
- Input: sinusoidal signal over UART / other protocol, using RX
- Output: fourier-transformed signal using TX

## Get the xADC up and running
## Stream the data from the xADC to the serial device
