# AXI4-Stream
Is a one-directional data protocol.

## Signals
### System signals
- ACLK (clock signal)
- ARESETn (active-low reset)

### Data Signals
- TVALID: Sender indicates whether the data is valid or not.
- TREADY: Receiver indicates whether it is ready to receive data, it can throttle the data-rate on enable.
- TDATA: data coming in.
- TSTRB: can indicate byte-level validity of data.
- TKEEP: Byte qualifier indicating which byte has been processed.
- TLAST: optional, indicates whether the last data-sample was transmitted.

### Meta-data signals
- TID: Data stream identifier
- TDEST: routing information
- TUSER: sideband info

## Receiving data
Receiving is done when both ready and valid are toggled high.
- Ready and valid should ALWAYS enabled both.

## Source
- AXI stream interface: https://www.youtube.com/watch?v=GyYmSZZor1s&ab_channel=FPGAsforBeginners
- AXI stream specifications: https://documentation-service.arm.com/static/642583d7314e245d086bc8c9?token=


# AXI-Lite
### AXI vs AXI stream
AXI-stream does not do addressing, AXI does, it indicates the address and it has a handshake-mechanism to check whether the data arrived at that particular position in memory.

-> AXI makes it easier

### AXI-Lite vs AXI
No last-signal in AXI-Lite, because EVERY TRANSACTION IS OF LENGTH 1.
Full AXI can send bursts of data-values for every address, but axi-lite can only send 1.


### Use
AXI lite is usually used to talk to registers, or applications with less throughput.

## Channels
### Read-architecture
- Read address channel
- Read data channel

### Write-architecture
- Write address channel
- Write data channel
- Write response channel

## Signals

Each channel has a
- VALID (indicating valid data from sender)
- READY (indicating the receiver is ready to receive the data)
- DATA (which is called ADDR for the addressing read/write channels)

### Other
- RRESP / WRESP: indicate the read / write went well
- AWPROT / ARPROT: indicates you're working with a secure memory space.
	- Set to 0 when not using / you can remove them

### Read data channel
- RRESP: indicates read went fine.
- WSTRB: Byte-specific valid-indicator (e.g.: 2 bytes are valid).

## Important rules
AXI-STREAM RULES
- DO NOT make the valid and ready dependent
- When the valid goes high, data must remain constant
- Valid must remain high constantly
- Transaction ends when ready AND valid are asserted
- Slave can't respond with BVALID until write and address write are done.
AXI-RULES
- RVALID can only be asserted after address-read transaction
- Only the ready and valid signal participate in the handshaking.

## Source:
- AXI Lite specifications: http://www.gstitt.ece.ufl.edu/courses/fall15/eel4720_5721/labs/refs/AXI4_specification.pdf
- AXI Lite: https://www.youtube.com/watch?v=y0z5Cg4gp6k&ab_channel=FPGAsforBeginners
- gh example: https://github.com/HDLForBeginners/Examples/blob/main/axi_lite/axi_lite_master.sv