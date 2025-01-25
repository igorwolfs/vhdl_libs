# Todo
## Create a serial IP-block that simply communicates whatever 8-bits you put into it.
- Create a UART TX module
- This module should have
    - input: 
        - byte (8-bit)
        - TX-divider (for the baud rate)
        - Clock
    - output:
        - Tx: single-bit output
        - Tx_done: TEST-signal(simply for checking) when the UART is done
        - Tx_active: TEST-signal: when uart is active

- Can you test the UART TX and RX separately even if they are in the same module?

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


## Get the xADC up and running
## Stream the data from the xADC to the serial device