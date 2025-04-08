`timescale 1ns/10ps

/**
STARTING COMMUNICATION:
1. Check if the bus is open (high)
2. If it is:
		- Pull SDA low
		- Pull SCL low
3. Data transmission
	- SDA: serial data-bits (1->high, 0->low)
	- SCL: serial clock timing bit sequence
	NOTE: no changes of data line between rising and falling edge of clock line.
4. When done
	- Release SCL high
	- Release SDA high

## Communication frames
1. Address frame sent after start (>=1 frames consisting of 1 byte)
	- 7 bits address, 1 bit for read or nwrite
	- Reserved addresses exist
2. Acknowledge
	- SDA low -> address was received
	- If pulled high (NACK) -> controller indicates unsuccessfull communication
*/

module i2c_controller #(CLOCK_FREQUENCY=100_000_000, I2C_FREQ=100_000, DATA_BITS=8) (
	input CLK,
	input NRST,
	inout I2C_SDA,			//< SPI data line
	inout I2C_SCL,			//< SPI clock
	input [7:0] IDATA,		//< 8-bit data input
	input [6:0] IADDR,		//< 7-bit ADDR input
	input I_RW				//< 1-bit read/write input
	output reg [7:0] ODATA,	//< 8-bit data output read
	output reg BUSY, 		//< Indicates busy-state to output
	output ODRDY,			//< Data received ready
	input IDRDY				//< Data ready for transmission
);

// * STATE PARAMETERS AND VARIABLES
localparam S_IDLE = 0;
localparam S_TX_START = 1;
localparam S_TX_ADDR = 2; 
localparam S_TX_ACK = 3;
localparam S_TX_DATA = 4;
localparam S_TX_STOP = 5;
localparam S_RX_ADDR = 6;
localparam S_RX_ACK = 7;
localparam S_RX_DATA = 8;
localparam S_DONE = 9;

wire [7:0] state_next;
reg [3:0] state_internal;		//> State of internal state machine.

// * TX VARIABLES
parameter CYCLES_I2C_FULL = $clog2(CLOCK_FREQUENCY / I2C_FREQ);
parameter CYCLES_I2C_HALF = CYCLES_I2C_FULL / 2;
parameter CYCLES_I2C_QUART = CYCLES_I2C_HALF / 2; 				//> Start clock one quarter after I2C start
reg [7:0] addr_tx_internal; 									//> Address index at send
reg [$clog2(7):0] addr_i; 										//> Data index at send
reg [7:0] data_tx_internal;										//> Data to be sent
reg [$clog2(7):0] data_i; 										//> Data index at send
reg ack_internal;												//> Keeps track of internal ACK for STOP condition
reg [$clog2(CYCLES_I2C_HALF)-1:0] i2c_clk_count;				//> SPI half clock count

// * CLK 
wire i2c_clk_enable;


// * COMBINATORIAL
always @(*)
begin: SM_COMB
	state_next = S_IDLE;
	i2c_clk_enable = 1'b0;
	case (state_internal)
		S_IDLE:
		begin
			if (IDRDY) begin
				state_next = S_TX_START;
				i2c_clk_enable = 1;
			end
			else if ((!I2C_SDA) & I2C_SCL) begin
				state_next = S_RX_DATA;
			end
			else begin
				state_next = S_IDLE;
			end
		end
		S_TX_START:
		begin
			if (I2C_clk_count <= CYCLES_I2C_QUART)
			begin
				state_next = S_TX_START;
				i2c_clk_enable = 1;
			end
			else
			begin
				state_next = S_TX_ADDR;
				i2c_clk_enable = 0;
			end
		end
		S_TX_ADDR:
		begin
			// ÁLWAYS enable the clock
			i2c_clk_enable = 1;
			// IF the address index has reached max -> move onto the data tx-state
			// Initialization: wait n clock cycles -> set clock
			// Start clock -> set low (50 % low, 50 % high)
			if (data_i > 7)
			begin
				state_next = S_TX_ACK;
			end
			else;
		end
		S_TX_ACK:
		begin
			i2c_clk_enable = 1; //> If clock edge is high -> stop condition, if low -> continue to data
			if ((ack_internal) & (i2c_clk_count == CYCLES_I2C_HALF) & (I2C_SCL == 1))
			begin
				state_next = S_TX_STOP;
			end
			else if ((!ack_internal) & (i2c_clk_count == CYCLES_I2C_HALF) & (I2C_SCL == 1))
			begin
				if (data_i < 8)
				begin
					state_next = S_TX_DATA;  //> If the ACK was for the address-transfer
				end
				else
				begin
					state_next = S_TX_STOP;  //> If the ACK was for the data-transfer
				end
			end
			else
			begin
				state_next = S_TX_ACK;
			end
		end
		S_TX_DATA:
		begin
			// ÁLWAYS enable the clock
			i2c_clk_enable = 1;
			// IF the address index has reached max -> move onto the data tx-state
			// Initialization: wait n clock cycles -> set clock
			// Start clock -> set low (50 % low, 50 % high)
			if (data_i >= 7)
			begin
				state_next = S_TX_ACK;
			end
			else;
		end
		S_TX_STOP:
		begin
			i2c_clk_enable = 1;
			if ((I2C_SDA == 1) & (I2C_SCL == 1)) //> Stop condition
			begin
				state_next = S_IDLE;
			end
		end
	endcase
end

always @(posedge CLK)
begin
	if (~NRST)
	begin
		i2c_clk_count <= 0;
	end
	else if (i2c_clk_enable)
	begin
		if (i2c_clk_count < CYCLES_I2C_HALF)
		begin
			i2c_clk_count <= i2c_clk_count + 1;
		end
		else
		begin
			I2C_SCL <= ~I2C_SCL; 	//> SPI clock toggle
			i2c_clk_count <= 0;		//> 
		end
	end
	else
	begin
		i2c_clk_count <= 0;
	end
end

// ********************************************************************************
// ********************************** TX STATE ************************************
// ********************************************************************************

always @(posedge CLK)
begin: I2C_TX_SYNC
	if (~NRST)
	begin
		state_internal <= S_IDLE;
		data_tx_internal <= 8'b0;
		addr_tx_internal <= 8'b0;
		I2C_SDA <= 1;		//> Doesn't necessarily need to be driven
		I2C_SCL <= 1; 		//> Doesn't necessarily need to be driven
	end
	else
	begin
		state_internal <= state_next;
		case (state_next)
			S_TX_START:
			begin
				I2C_SDA <= 0; //> Keep low for n clock cycles
				if (state_internal == S_IDLE)
				begin
					data_tx_internal <= IDATA;
					addr_tx_internal <= {IADDR[6:0], I_RW}; //> Address to be sent
				end
			end
			S_TX_ADDR:
			begin
				if (state_internal == S_TX_START)
				begin
					ack_internal <= 0; 		//> Reset ACK
					I2C_SCL <= 0; 			//> Clock count start
				end
				else
					if ((i2c_clk_count == CYCLES_I2C_QUART) & (I2C_SCL == 0))  //> Change in the centre of the low-cycle
					begin
						I2C_SDA <= addr_tx_internal[addr_i]; 	//> Pull data line low
						addr_i <= addr_i + 1;
					end
					else;
			end
			S_TX_ACK:
			begin
				if ((I2C_SDA == 1) & (I2C_SCL == 1)) 	//> Sample the input line
				begin
					ack_internal <= 1;
				end
				else;
			end
			S_TX_DATA:
			begin
				if ((i2c_clk_count == CYCLES_I2C_QUART) & (I2C_SCL == 0)) 	//> Change in the centre of the low-cycle
				begin
					I2C_SDA <= data_tx_internal[data_i]; 	//> Pull data line low
					data_i <= data_i + 1;
				end
				else;
			end
			S_TX_STOP:
			begin
				if (i2c_clk_count == CYCLES_I2C_QUART)
				begin
					I2C_SCL <= 1; 		//> Pull clock line high
				end
				else if (i2c_clk_count == CYCLES_I2C_HALF)
				begin
					I2C_SDA <= 1;	 	//> Pull data line high
				end
				else;
			end
		endcase
	end
end

// ********************************************************************************
// ********************************** RX STATE ************************************
// ********************************************************************************



always @(posedge CLK)
begin: I2C_RX_SYNC

end

endmodule

/**
# IDLE MODE
## Starting RX
- Check if the SDA is pulled low
	- If it is we are working in receive mode, and we should go to S_RX_ADDR
## Starting in TX
- Check if an outside trigger is manifested (DRDY) for sending
	- If it is we are working in sending mode, and we need to go into S_TX_ADDR
- I2C data shouldn't change when CLK is high (should only change when CLK is low)
	- then keep the clock high for a few cycles
	- Then start the clock 50 % low, 50 % high -> during the high the data should be fixed
	- Do this 
*/


/**
* !!!!!!!!!!!!!!!!!!!!! TX MODE !!!!!!!!!!!!!!!!!!!!!!!!!
Default state: IDLE
- DRDY signal pulled high
TX_START
- pull the SDA low
- Wait for 25 % of I2C_clk_cycle
TX_ADDR
- pull the I2C_SCL low

*/

/**
TODO:
- Implement an SPI-clock.
- Make sure the TX_START goes into TX_ADDR once 25 % of the cycles have passed
- Make sure the I2C_clk_count resets to 0 when entering TX_ADDR and current state is still TX_START
	- I2C_clk_enable is held low for one cycle -> should reset the clock
< done
- In address mode
	- on low clock AND quarter cycles were reached: shift the data bit
	- on high clock: do nothing
- Once everything is sent -> move to ACK-state (when CLK cycle > 7 is sent)
- In ACK-state
	- Keep the clk active
	- Transition on next SCL-low here
	- Transitioning state needs to be decided by 

- STOP condition
	- SCL goes high after 25 % of the clock cycle
	- SDA goes high after 25 % of the clock cycle
*/