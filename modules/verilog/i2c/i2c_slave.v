`timescale 1ns / 1ps


module i2c_slave (
	inout SCL, 							//> SCL
	inout SDA,							//> SDA
	output reg [6:0] 	ADDR,			//> Indicates the address that needs to be read / written
	output reg			ARDY,			//> Indicates address + R/W is received
	output reg 			RW,			//> Indicates whether read / write takes place
	output reg [7:0] 	ODATA,			//> Indicates the data that needs to be written to the system (W-CMD)
	input [7:0] 		IDATA,			//> Indicates the data that needs to be written to the bus (R-CMD)
	output reg			DRDY,			//> Indicates byte is processed by system (data-write-case)
	input 				NRST,
	input wire 			ACKA_RDY,		//> Indicates whether a stalling of the bus should happen on ACKA (because data fetching isn't done yet)
	input wire 			ACKD_RDY,		//> Indicates whether a stalling of bus should happen on ACKD (because data writing isn't done yet)
	output reg  		BUSY
);

localparam S_IDLE = 0;
localparam S_ADDR = 1;
localparam S_ACKA = 2;
localparam S_DATA = 3;
localparam S_ACKD = 4;

localparam RW_WRITE = 1'b0;
localparam RW_READ = 1'b1;

reg [3:0] counter;
reg [7:0] data_internal;
reg r_w_internal;
reg [2:0] next_state;
reg [2:0] curr_state;
reg sda_slave, scl_drive, sda_drive;

assign SCL = (scl_drive) ? 1'b0 : 1'bz;
assign SDA = (sda_drive) ? sda_slave : 1'bz;


// ****************************************************
// *************** SIGNAL DRIVING *********************
// ****************************************************

//> Drive SDA and SCL signals here when SCL is low

always @(negedge SCL, negedge NRST)
begin
	if (~NRST)
	begin
		curr_state <= S_IDLE;
		sda_slave <= 0;
	end
	else
	begin
		curr_state <= next_state;
		case (next_state)
			S_IDLE:
			begin
				counter <= 8;
			end
			S_ACKA:
			begin
				sda_slave <= 0;
			end
			S_DATA: //> Data write should happen on negedge
			begin
				if (RW == RW_READ)
				begin
					counter <= counter - 1;
					sda_slave <= IDATA[(counter-1)];
				end
				else;
			end
			S_ACKD:
			begin
				sda_slave <= 0;
			end
		endcase
	end
end

// ****************************************************
// ************* DATA SAMPLING****** ******************
// ****************************************************


always @(posedge SCL or negedge NRST) begin
	if (~NRST)
	begin
	  counter <= 8;
	end
	else 
	begin
	  case (curr_state)
		S_ADDR:
		begin
			if (counter > 1)
				ADDR[(counter-2)] <= SDA;
			else if (counter == 1)
				RW <= SDA;
			else;
			counter <= counter - 1;
		end
		S_ACKA:
		begin
			counter <= 8;
		end
		S_DATA: //> Data read should happen on posedge
		begin
			if (RW == RW_WRITE)
			begin
				ODATA[counter-1] <= SDA;
				counter <= counter - 1;
			end
			else;
		end
		S_ACKD:
		begin
			counter <= 8;
		end
	  endcase
	end
  end

// ****************************************************
// ************* COMBINATORIAL BLOCK ******************
// ****************************************************


reg start_condition;
reg stop_condition;

//> START CONDITION DETECTOR
always @(negedge SDA, negedge NRST, negedge SCL)
begin
	if (~NRST)
		start_condition <= 0;
	else if (next_state == S_IDLE)
	begin
		if (SCL == 1'b1)
		begin
			start_condition <= 1;
		end
		else;
	end
	else
		start_condition <= 0; //> Set start condition to 0 when SCL goes low (since curr_state should then be set to next_state)
end

//> STOP CONDITION DETECTOR
always @(posedge SDA, negedge NRST, negedge SCL)
begin
	if (~NRST)
		stop_condition <= 0;
	else
	begin
		if (SCL == 1'b1)
		begin
			stop_condition <= 1;
			// curr_state <= S_IDLE;
		end
		else
			stop_condition <= 0; //> Set start condition to 0 when SCL goes high
	end
end

always @(*) begin
	next_state = S_IDLE;  // default “no change”
	scl_drive = 1'b0;
	sda_drive = 1'b0;
	ARDY = 1'b0;
	DRDY = 1'b0;
	BUSY = 1'b1;

	if (stop_condition)
	begin
		next_state = S_IDLE;
	end
	else
	begin
		case (curr_state)
			S_IDLE:
			begin
				if (start_condition)
					next_state = S_ADDR;
				else
				begin
					next_state = S_IDLE;
					BUSY = 1'b1;
				end
			end
			
			S_ADDR: //> Wait until address + R/W is received
			begin
				if (counter == 0)
					next_state = S_ACKA;
				else 
					next_state = S_ADDR;
			end
			
			S_ACKA:	//> Address-ready out, waiting for data-in ready
			begin
				ARDY = 1'b1;
				if (ACKA_RDY) 				//> Should be enabled until the ARDY out turns low
				begin
					sda_drive = 1'b1; 		//> Drive SDA low
					next_state = S_DATA;
				end
				else
				begin
					scl_drive = 1'b1; 		//> Stall
					next_state = S_ACKA;
				end
			end
			
			S_DATA:
			begin
				if (counter == 0)
				begin
					next_state = S_ACKD;
				end
				else
				begin
					next_state = S_DATA;
					if (RW == RW_READ)
					begin
						sda_drive = 1'b1; 	//> Slave drive SDA when data write
					end
				end
			end
			
			S_ACKD:
			begin
				DRDY = 1'b1;
				if (ACKD_RDY) 		  		//> Should be enabled until DRDY out turns low
				begin
					if (RW == RW_WRITE) 	//> Drive SDA low (master write)
						sda_drive = 1'b1;
					else;					//> Master read, slave should wait for ACK
					next_state = S_DATA; 	//> Continue back to data-state
				end
				else
				begin
					scl_drive = 1'b1; 		//> Stall
					next_state = S_ACKD;
				end
			end

			default: next_state = S_IDLE;
		endcase
	end
  end


endmodule


/**

TODO:
- The I2C is probably pulled lowed here by both the testbench and the i2c-slave.
- Make sure to release the I2C in the testbench when not using it.
- The curr state doesn't become IDLE due to the lack of the last negedge in the state transition
	- Find a solution for that (e.g.: inside the stop-condition perhaps?)

ACK
- If the operation is read, make sure the slave awaits the master ACK after the data transmission
- It seems like the stop condition isn't triggered appropriately, why not?

S_ACKD
- The slave needs to keep reading / writing until the master is done.
*/