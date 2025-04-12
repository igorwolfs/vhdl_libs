

module i2c_slave (
	inout SCL, 							//> 
	inout SDA,							//> 
	output reg [6:0] 	ADDR,			//> Indicates the address that needs to be read / written
	output reg			ARDY,			//> Indicates address + R/W is received
	output reg 			RW,			//> Indicates whether read / write takes place
	output reg [7:0] 	ODATA,			//> Indicates the data that needs to be written to the system (W-CMD)
	input [7:0] 		IDATA,			//> Indicates the data that needs to be written to the bus (R-CMD)
	output reg			DRDY,			//> Indicates byte is processed by system (data-write-case)
	input 				NRST,
	input wire 			ACKA_RDY,		//> Indicates whether a stalling of the bus should happen on ACKA (because data fetching isn't done yet)
	input wire 			ACKD_RDY,		//> Indicates whether a stalling of bus should happen on ACKD (because data writing isn't done yet)
	output wire 		BUSY
)

localparam S_IDLE = 0,
localparam S_ADDR = 1,
localparam S_ACKA = 2;
localparam S_DATA = 3,
localparam S_ACKD = 4;
localparam S_STOP = 5;

localparam RW_WRITE = 1'b0;
localparam RW_READ = 1'b1;

reg [2:0] counter;
reg [7:0] data_internal;
reg r_w_internal;
reg [2:0] s_next;
reg [2:0] s_curr;
reg scl_slave, sda_slave, scl_drive, sda_drive;

assign SCL = (scl_drive) ? scl_slave : 1'bz;
assign SDA = (sda_drive) ? sda_slave : 1'bz;


// ****************************************************
// *************** SIGNAL DRIVING *********************
// ****************************************************

//> Drive SDA and SCL signals here when SCL is low

always @(negedge SCL, negedge NRST)
begin
	if (~NRST)
		s_curr <= S_IDLE;
	else
	begin
		s_curr <= s_next;
		case (s_next)
			S_ACKA:
			begin
				scl_slave <= 0;
				sda_slave <= 0;
			end
			S_DATA: //> Data write should happen on negedge
			begin
				if (RW == RW_READ)
				begin
					sda_slave <= IDATA[counter];
					counter <= counter + 1;
				end
				else;
			end
			S_ACKD:
			begin
				scl_slave <= 0;
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
	  counter <= 0;
	end
	else 
	begin
	  case (s_curr)
		S_ADDR:
		begin
			if (counter < 7)
				ADDR[counter] <= SDA;
			else if (counter == 7)
				RW <= SDA;
			else;
			counter <= counter + 1;
		end
		S_ACKA:
		begin
			counter <= 0;
		end
		S_DATA: //> Data read should happen on posedge
		begin
			if (RW == RW_WRITE)
			begin
				ODATA[counter] <= SDA;
				counter <= counter + 1;
			end
			else;
		end
		S_ACKD:
		begin
			counter <= 0;
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
	else if (curr_state == S_IDLE)
	begin
		if (SCL == 1'b1)
		begin
			start_condition <= 1;
		end
		else;
	end
	else
		start_condition <= 0; //> Set start condition to 0 when SCL goes low (since s_curr should then be set to s_next)
end

//> STOP CONDITION DETECTOR
always @(posedge SDA, negedge NRST, posedge SCL)
begin
	if (~NRST)
		stop_condition <= 0;
	else if (curr_state == S_STOP)
	begin
		if (SCL == 1'b0)
		begin
			stop_condition <= 1;
		end
		else;
	end
	else
		stop_condition <= 0; //> Set start condition to 0 when SCL goes high
end

always @(*) begin
	s_next = S_IDLE;  // default “no change”
	scl_drive = 1'b0;
	sda_drive = 1'b0;
	ARDY = 1'b0;
	DRDY = 1'b0;
	BUSY = 1'b1;

	case (s_curr)
		S_IDLE:
		begin
			if (start_condition)
				s_next = S_ADDR;
			else
			begin
				s_next = S_IDLE;
				BUSY = 1'b1;
			end
		end
		
		S_ADDR: //> Wait until address + R/W is received
		begin
			if (counter > 7)
				s_next = S_ACKA;
		end
		
		S_ACKA:	//> Address-ready out, waiting for data-in ready
		begin
			ARDY = 1'b1;
			if (ACKA_RDY) 			//> Should be enabled until the ARDY out turns low
			begin
				sda_drive = 1'b1; 	//> Drive SDA low
				s_next = S_DATA;
			end
			else
				scl_drive = 1'b1; //> Stall
		end
		
		S_DATA: 
		begin
			if (counter > 7)
			begin
				S_next = S_ACKD;
			end
			else
			begin
				if (RW == RW_READ)
					sda_drive = 1'b1; //> Slave drive SDA when data write
			end
		end
		
		S_ACKD: 
		begin
			DRDY = 1'b1;
			if (ACKD_RDY) 		  //> Should be enabled until DRDY out turns low
			begin
				sda_drive = 1'b1; //> Drive SDA low
				s_next = S_STOP;
			end
			else
				scl_drive = 1'b1; //> Stall
		end

		S_STOP: 
		begin
			if (stop_condition)
				s_next = S_IDLE;
			else;
		end
		
		default: s_next = IDLE;
	endcase
  end


endmodule
/**
Questions
- How does the controller on top of the i2c slave know when the address has received so it can start fetching from that address in case of a data read?
	- Answer: use clock stretching, pull the clock low until the data is fetched.
		- The master must normally detect this clock stretching (?how).
		- If the master has detected it it stalls.


- IDLE: 
	- @negedge SDA AND SCL high -> next_state = ADDR
		- @negedge SCL: IDLE -> ADDR
- ADDR:
	- @posedge SCL: 
		- if addr_index < 6, adddr_index ++
		- if addr_index == 7, set R_W
	- @negedge SCL: 
		- if addr_index > 7
			- ADDR -> STALLA
			- SCL low
- STALLA:
	- @posedge ACKA_RDY: STALLA -> ACKA
		- SCL loose
		- SDA low
- ACKA:
	- @negedge SCL: ACKA -> DATA
- DATA:
	- @posedge SCL:
		- if data index <= 7:
			- Store in data
	- @negedge SCL:
		- if data index <= 7:
			- next state is DATA
		- if data_index == 8:
			- next state is STALLD
			- SCL should be pulled low
- STALLD:
	- @posedge ACKD_RDY: STALLD -> ACKD
		- Pull SDA low
- ACKA:
	- @negedge SCL: ACKA -> STOP
- STOP:
	- @posedge SDA: STOP -> IDLE

NOTE:
- @negedge SCL: State transitions: S_curr <= S_next
- @posedge SCL: Sampling, data operations and next_state set based on curr_state
- in case of stalling -> just disable any state-related logic
	-> pull the SCL low UNTIL the correct drdy is triggered



We can drive the scl signals either
- In the negedge-loop and add 2 signals
- In the combinatorial loop

It seems like the best way to solve the issues here is to
- Have the ACK state and STALL together
- By default the STALL is always enabled
- It is ONLY unset once the relevant RDY-signal is asserted
	- Once that RDY signal is asserted the ACK should in fact 
		- Pull the SDA low
		- Release the SCL
	- HOWEVER: the SCL and SDA are then being set inside the comb-block
		- Solution: set only the scl_drive and sda_drive inside the comb-block
		- State transition then simply happens on the negedge
		
*/
