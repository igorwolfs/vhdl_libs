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

module i2c_controller #(CLOCK_FREQUENCY=100_000_000, SPI_FREQ=100_000) (
	input CLK,
	input NRST,
	inout SPI_SDA,			//< SPI data line
	inout SPI_SCL,			//< SPI clock
	input [7:0] IDATA,		//< 8-bit data input
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
localparam S_RX_ADDR = 5;
localparam S_RX_ACK = 6;
localparam S_RX_DATA = 7;
localparam S_DONE = 8;

wire [7:0] state_next;
reg [3:0] state_internal;		//> State of internal state machine.

// * TX VARIABLES
parameter CYCLES_SPI_FULL = $clog2(CLOCK_FREQUENCY / SPI_FREQ);
parameter CYCLES_SPI_HALF = CYCLES_SPI_FULL / 2;
parameter CYCLES_SPI_QUART = CYCLES_SPI_HALF / 2; 	//> Start clock one quarter after I2C start
reg [7:0] data_tx_internal;								//> Data to be sent
reg [$clog2(7):0] data_i; 								//> Data index at send
reg [CYCLES_PER_SPI_CLK-1:0] spi_clk_count;				//> SPI half clock count

// * CLK 
wire spi_clk_enable;


// * COMBINATORIAL
always @(*)
begin: SM_COMB
	state_next = S_IDLE;
	spi_clk_enable = 1'b0;
	case (state_internal)
		S_IDLE: 
		begin
			if (IDRDY) begin
				state_next = S_TX_START;
				spi_clk_enable = 1;
			end
			else if ((!SPI_SDA) & SPI_SCL) begin
				state_next = S_RX_DATA;
			end
			else begin
				state_next = S_IDLE;
			end
		end
		S_TX_START: 
		begin
			if (spi_clk_count <= CYCLES_QUART)
			begin
				state_next = S_TX_START;
				spi_clk_enable = 1;
			end
			else
			begin
				state_next = S_TX_ADDR;
				spi_clk_enable = 0;
			end
			// Initialization: wait n clock cycles -> set clock
			// Start clock -> set low (50 % low, 50 % high)
			// Transition SPI data signal on half the low signal (25 % low signal)
		end
		S_TX_ADDR:
		begin
			
		end
	endcase
end

always @(posedge CLK)
begin
	if (~NRST)
	begin
		spi_clk_count <= 0;
	end
	else if (spi_clk_enable)
	begin
		if 	(spi_clk_count < (CYCLES_SPI_FULL))
			spi_clk_count <= spi_clk_count + 1;
		else
		begin
			spi_clk_count <= 0;
		end
	end
	else
	begin
		spi_clk_count <= 0;
	end
end

//! TX STATE
always @(posedge CLK)
begin: I2C_ACTIONS
	if (~NRST)
	begin
		state_internal <= S_IDLE;
		data_internal <= 8'b0;
		SPI_SDA <= 1;		//> Doesn't necessarily need to be driven
		SPI_SCL <= 1; 		//> Doesn't necessarily need to be driven
	end
	else
		state_internal <= state_next;
		case (state_next)
			S_TX_START:
			begin
				SPI_SDA <= 0; //< Keep low for n clock cycles
			end
			S_TX_ADDR:
			begin
				if (state_internal == S_TX_START)
				begin
					SPI_SCL <= 0; //< Clock count start
				end
				else
					if (spi_clk_count >= )
					// Wait 25 % after the start of a clock cycle to pull data high
					// Wait 50 % after clock count to pull clock high
					begin
						
					end
			end
			S_TX_DATA:
			begin
				
			end
		endcase
	begin
		data_internal <= IDATA;
	end
end

always @(posedge CLK)
begin: sm_sync

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
# RX_START


# TX_START_ADDR
- Load addr into local data
- Enable i2c clock generation

NOTE:
- I2C_CLK clock duty cycle should be about 50 %
- I2C frequency can be 100 kHz (Sm) and 400 kHz (Fm)
*/