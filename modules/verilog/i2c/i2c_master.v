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
	input NRST,					//> NRST
	inout I2C_SDA,				//> SPI data line
	inout I2C_SCL,				//> SPI clock
	input [7:0] IDATA,		   	//> 8-bit data input
	input [6:0] IADDR,		   	//> 7-bit ADDR input
	input I_RW,				    //> 1-bit read/write input
	output reg [6:0] OADDR,     //> Data received, to be read
	output reg O_RW,
	output reg [7:0] ODATA,	   	//> 8-bit data output read
	output reg BUSY, 		    //> Indicates busy-state to output
	output ODRDY,			   	//> Data received ready
	input IDRDY				    //> Data ready for transmission
);

// * STATE PARAMETERS AND VARIABLES
localparam S_IDLE = 0;
localparam S_TX_START = 1;
localparam S_TX_ADDR = 2; 
localparam S_TX_ACK = 3;
localparam S_TX_DATA = 4;
localparam S_TX_STOP = 5;
localparam S_RX_START = 6;
localparam S_RX_ADDR = 7;
localparam S_RX_ACK = 8;
localparam S_RX_DATA = 9;
localparam S_RX_STOP = 10;

reg [3:0] state_next;
reg [3:0] state_internal;	//> State of internal state machine.


reg I2C_SDA_SYNC, I2C_SCL_SYNC;	//> Synchronization of the I2C lines

double_ff_sync #(.WIDTH(1), .NRST_VAL(1)) ff_sync_sda (
	.CLK(CLK),
	.NRST(NRST),
	.D(I2C_SDA),
	.Q(I2C_SDA_SYNC));

double_ff_sync #(.WIDTH(1), .NRST_VAL(1)) ff_sync_scl (
	.CLK(CLK),
	.NRST(NRST),
	.D(I2C_SCL),
	.Q(I2C_SCL_SYNC));

// * RX VARIABLES
reg RX_I2C_SDA;

// * TX VARIABLES
reg TX_I2C_SDA, TX_I2C_SCL;

parameter CYCLES_I2C_FULL = CLOCK_FREQUENCY / I2C_FREQ;
parameter CYCLES_I2C_HALF = CYCLES_I2C_FULL / 2;
parameter CYCLES_I2C_QUART = CYCLES_I2C_HALF / 2; 				//> Start clock one quarter after I2C start

reg [7:0] addr_internal; 									//> Address index at send
reg [$clog2(7):0] addr_i; 										//> Data index at send
reg [7:0] data_internal;										//> Data to be sent
reg [$clog2(7):0] data_i; 										//> Data index at send
reg ack_internal;												//> Keeps track of internal ACK for STOP condition
reg [$clog2(CYCLES_I2C_HALF)-1:0] i2c_clk_count;				//> SPI half clock count

// * CLK 
reg i2c_clk_enable;

// ******** DETERMINING SCL AND SDA **********
assign I2C_SDA = ((state_internal != S_IDLE) & (state_internal != S_TX_ACK)) ? TX_I2C_SDA :
				(state_internal == S_RX_ACK) ? RX_I2C_SDA :
                    1'bz;
assign I2C_SCL = (state_internal != S_IDLE) ? TX_I2C_SCL :
                    1'bz;


// *******************************************************************************
// ***************** COMBINATORIAL STATE MACHINE DETERMINATION *******************
// *******************************************************************************

always @(*)
begin: SM_COMB
	state_next = S_IDLE;
	i2c_clk_enable = 1'b0;
	BUSY = 1'b1;
	case (state_internal)
		S_IDLE:
		begin
			if ((!I2C_SDA_SYNC) & (I2C_SCL_SYNC))
			begin
				state_next = S_RX_START;
			end
			else if (IDRDY)
			begin
				state_next = S_TX_START;
				i2c_clk_enable = 1;
			end
			else if ((!I2C_SDA_SYNC) & I2C_SCL_SYNC) begin
				state_next = S_RX_START;
			end
			else begin
				state_next = S_IDLE;
			end
			BUSY = 1'b0;
		end
		S_TX_START:
		begin
			if (i2c_clk_count < CYCLES_I2C_QUART)
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
			if (addr_i > 8)
			begin
				state_next = S_TX_ACK;
			end
			else
			begin
				state_next = S_TX_ADDR;
			end
		end
		S_TX_ACK:
		begin
			i2c_clk_enable = 1; //> If clock edge is high -> stop condition, if low -> continue to data
			if ((ack_internal) & (i2c_clk_count == CYCLES_I2C_HALF) & (TX_I2C_SCL == 1))
			begin
				state_next = S_TX_STOP;
			end
			else if ((!ack_internal) & (i2c_clk_count == CYCLES_I2C_HALF) & (TX_I2C_SCL == 1))
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
			else
			begin
				state_next = S_TX_DATA;
			end
		end
		S_TX_STOP:
		begin
			i2c_clk_enable = 1;
			if ((TX_I2C_SDA == 1) & (TX_I2C_SCL == 1) & (i2c_clk_count >= CYCLES_I2C_HALF)) //> Stop condition
			begin
				state_next = S_IDLE;
			end
			else
			begin
				state_next = S_TX_STOP;
			end
		end
		S_RX_START:
		begin
			if ((I2C_SCL_SYNC == 0) & (I2C_SDA_SYNC == 0))
			begin
				state_next = S_RX_ADDR;
			end
			else if ((I2C_SCL_SYNC == 1) & (I2C_SDA_SYNC == 0))
			begin
				state_next = S_RX_START;
			end
			else
			begin
				state_next = S_IDLE;
			end
		end
		S_RX_ADDR:
		begin
			if (addr_i < 8)
			begin
				state_next = S_RX_ADDR;
				i2c_clk_enable = 1;
			end
			else
			begin
				state_next = S_RX_ACK;
				i2c_clk_enable = 0; 	//> Disable the clock for a single cycle
			end
		end
		S_RX_ACK:
		begin
			if ((i2c_clk_count == CYCLES_I2C_HALF) & (I2C_SCL == 1))
			begin
				if (addr_i > 8)
					state_next = S_RX_DATA;
				else
					state_next = S_RX_STOP;
			end
			else
			begin	//> Wait until the end of the clock cycle
				state_next = S_RX_ACK;
			end
		end
		S_RX_DATA:
		begin
			if (data_i < 8)
			begin
				state_next = S_RX_DATA;
				i2c_clk_enable = 1;
			end
			else
			begin
				state_next = S_RX_ACK;
				i2c_clk_enable = 0; 	//> Disable the clock for a single cycle
			end
		end
		S_RX_STOP:
		begin
			//> Wait for when DRDY is pulled high, transition to IDLE
			if (ODRDY)
			begin
				state_next = S_IDLE;
			end
			else
			begin
				state_next = S_RX_STOP;
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
			TX_I2C_SCL <= ~TX_I2C_SCL; 	//> SPI clock toggle
			i2c_clk_count <= 0;			//> 
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
		data_internal <= 8'b0;
		addr_internal <= 8'b0;
		TX_I2C_SDA <= 1;		//> Doesn't necessarily need to be driven
		TX_I2C_SCL <= 1; 		//> Doesn't necessarily need to be driven
	end
	else
	begin
		state_internal <= state_next;
		case (state_next)
			S_IDLE:; // NOTHING in TX_SYNC when IDLE
			S_TX_START:
			begin
				TX_I2C_SDA <= 0; //> Keep low for n clock cycles
				if (state_internal == S_IDLE)
				begin
					data_internal <= IDATA;
					addr_internal <= {IADDR[6:0], I_RW}; //> Address to be sent
					data_i <= 0;
					addr_i <= 0;
				end
			end
			S_TX_ADDR:
			begin
				if (state_internal == S_TX_START)
				begin
					ack_internal <= 0; 		//> Reset ACK
					TX_I2C_SCL <= 0; 			//> Clock count start
				end
				else
					if ((i2c_clk_count == CYCLES_I2C_QUART) & (TX_I2C_SCL == 0))  //> Change in the centre of the low-cycle
					begin
						if (addr_i < DATA_BITS)
							TX_I2C_SDA <= addr_internal[addr_i]; 	//> Pull data line low
						addr_i <= addr_i + 1;							//> 
					end
					else;
			end
			S_TX_ACK:
			begin
				if ((TX_I2C_SDA == 1) & (TX_I2C_SCL == 1)) 	//> Sample the input line
				begin
					ack_internal <= 1;
				end
				else;
			end
			S_TX_DATA:
			begin
				if ((i2c_clk_count == CYCLES_I2C_QUART) & (TX_I2C_SCL == 0)) 	//> Change in the centre of the low-cycle
				begin
					TX_I2C_SDA <= data_internal[data_i]; 	//> Pull data line low
					data_i <= data_i + 1;
				end
				else;
			end
			S_TX_STOP:
			begin
				if (TX_I2C_SCL == 0)
				begin
					TX_I2C_SDA <= 0;		//> Pull data line low to pull high at 75 %
					TX_I2C_SCL <= 1;
				end
				else if (i2c_clk_count == CYCLES_I2C_HALF)
				begin
					TX_I2C_SDA <= 1;	 	//> pull SDA high 75 %
				end
				else;
			end
			default:;
		endcase
	end
end

// ********************************************************************************
// ********************************** RX STATE ************************************
// ********************************************************************************



always @(posedge CLK)
begin: I2C_RX_SYNC
	if (~NRST);
	else
	begin
		// state_internal <= state_next; //> Done in TX_SYNC
		case (state_next)
			S_IDLE:;			//> Wait double flip-flop sampling, check in combinatorial logic for start condition
			S_RX_START:;		//> Combinatorially wait for the clock-line to go low
			S_RX_ADDR:
			begin
				if (state_internal == S_RX_START)
				begin
					ack_internal <= 0; 			//> Reset ACK
					TX_I2C_SCL <= 0; 			//> Clock count start
				end
				else
				begin
					if (((i2c_clk_count == CYCLES_I2C_QUART) | (i2c_clk_count == CYCLES_I2C_HALF)) & (TX_I2C_SCL == 1))  //> Change in the centre of the low-cycle
					begin
						if (addr_i < DATA_BITS)
							addr_internal[addr_i] <= I2C_SDA_SYNC; 	//> Pull data line low
						addr_i <= addr_i + 1; //> Should keep going until addr_i is equal to 8 -> then we should enter RX_ACK stage
					end
					else;
				end
			end
			S_RX_ACK:
			begin
				//> Pull the SDA line low for one clock-cycle to show an ACK
				if (i2c_clk_count >= CYCLES_I2C_QUART)
				begin
					RX_I2C_SDA <= 0;
				end
			end
			S_RX_DATA:
			begin
				if (state_internal == S_RX_START)
				begin
					ack_internal <= 0; 			//> Reset ACK
					TX_I2C_SCL <= 0; 			//> Clock count start
				end
				else
				begin
					if (((i2c_clk_count == CYCLES_I2C_QUART) | (i2c_clk_count == CYCLES_I2C_HALF)) & (TX_I2C_SCL == 1))  //> Change in the centre of the low-cycle
					begin
						if (data_i < DATA_BITS)
						begin
							data_internal[data_i] <= I2C_SDA_SYNC; 	//> Pull data line low
						end
						data_i <= data_i + 1; //> Should keep going until addr_i is equal to 8 -> then we should enter RX_ACK stage
					end
					else;
				end
			end
			S_RX_STOP:
			begin
				//! Warning: detects scl and sda high, should detect poedge sda when scl high
				//> Set data out to data when stop condition asserted
				if ((I2C_SDA_SYNC == 1) & (I2C_SCL_SYNC == 1))
				begin
					//> Set data out
					ODRDY <= data_internal;
				end
			end
		endcase
	end
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
*/


/**
* !!!!!!!!!!!!!!!!!!!!! TX MODE !!!!!!!!!!!!!!!!!!!!!!!!!
- SDA should go low while SCL is high

* !!!!!!!!!!!!!!!!!!!!! RX MODE !!!!!!!!!!!!!!!!!!!!!!!!!
- RX_ADDR mode should be entered when SCL is low (so after the start condition is finished)
- In the start state, wait for the SCL to go low -> move to RX_ADDR
- Run the double rx-signal through a double flip-flop sync.


ACK:
- Pull the SDA low after a quarter cycle of CLK-low
- transition should happen when CLK is high and i2c_clk_count is halfway
*/