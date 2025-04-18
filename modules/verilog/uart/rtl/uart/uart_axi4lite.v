`timescale 1ns/10ps

module uart_axi4lite
    #(
    // AXI PARAMETERS
    parameter AXI_AWIDTH = 4,
    parameter AXI_DWIDTH = 32,
    // UART PARAMETERS
    parameter CLOCK_FREQUENCY = 100_000_000,
    parameter BAUD_RATE = 115_200,
    parameter DATA_BITS = 8)
    (
        input                       AXI_ACLK,
        input                       AXI_ARESETN,
        input [AXI_AWIDTH-1:0]      AXI_AWADDR,
        input                       AXI_AWVALID,
        output reg                  AXI_AWREADY,
        input [AXI_DWIDTH-1:0]      AXI_WDATA,
        input [(AXI_DWIDTH/8)-1:0]  AXI_WSTRB,
        input AXI_WVALID,
        output reg                  AXI_WREADY,
        output reg  [1:0]           AXI_BRESP,
        output reg                  AXI_BVALID,
        input                       AXI_BREADY,
        input [AXI_AWIDTH-1:0]      AXI_ARADDR,
        input  wire                 AXI_ARVALID,
        output reg                  AXI_ARREADY,
        output reg [AXI_DWIDTH-1:0] AXI_RDATA,
        output reg [1:0]            AXI_RRESP,
        output reg                  AXI_RVALID,
        input                       AXI_RREADY,

        // UART PINS
        output  TX_DSER, //! TX_PIN
        input   RX_DSER //! RX_PIN
    );

    //======================================================
    // CONSTANTS
    //======================================================
    localparam ADDR_TX_DATA = 4'h0;
    localparam ADDR_TX_BUSY = 4'h4;
    localparam ADDR_RX_DATA = 4'h8;
    localparam ADDR_RX_STATE = 4'hC;

    //======================================================
    // SIGNALS
    //======================================================

    reg tx_drdy;
    reg [DATA_BITS-1:0] tx_di;
    wire tx_done, tx_busy, rx_drdy, rx_busy;
    wire [DATA_BITS-1:0] rx_do;

    //======================================================
    // UART ENTITY
    //======================================================

    uart #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY),
            .BAUD_RATE(BAUD_RATE),
            .DATA_BITS(DATA_BITS)) uart_inst
    (
        .CLK(AXI_ACLK), .NRST(AXI_ARESETN),
        // TX
        .TX_DRDY(tx_drdy), .TX_DI(tx_di),
        .TX_DONE(tx_done), .TX_BUSY(tx_busy),
        .TX_DSER(TX_DSER), //! MUST BE A PIN
        // RX
        .RX_DSER(RX_DSER), //! MUST BE A PIN
        .RX_DO(rx_do), .RX_DRDY(rx_drdy), .RX_BUSY(rx_busy)
    );

    //======================================================
    // Write DATA / ADDRES / RESPONSE + write logic into uart
    //======================================================

    wire [AXI_AWIDTH-1:0] write_addr = AXI_AWADDR;
    always @(posedge AXI_ACLK) begin
        if (!AXI_ARESETN)
        begin
            AXI_AWREADY <= 1'b0;
            AXI_WREADY <= 1'b0;
            AXI_BVALID <= 1'b0;

            tx_di  <= {DATA_BITS{1'b0}}; // reset user registers
            tx_drdy  <= 1'b0;
        end
        else if (AXI_WVALID & AXI_AWVALID)
        begin
            // If both the write and the address write channel are valid => Write to them
            //! WARN: the tx-busy needs to be checked by the peripheral before sending anything
            if (AXI_AWREADY & AXI_WREADY)
            begin
                AXI_AWREADY <= 1'b0;
                AXI_WREADY <= 1'b0;
                AXI_BVALID <= 1'b0;
                tx_drdy <= 1'b0;
            end
            else
            begin
                case (AXI_AWADDR[3:0])
                    ADDR_TX_DATA:
                    begin
                        if (!tx_busy)
                        begin
                        tx_di <= AXI_WDATA[DATA_BITS-1:0];
                        tx_drdy <= 1'b1; // DIRECTLY ENABLE SEND
                        end
                        else;
                    end
                    default:;
                endcase
                AXI_AWREADY <= 1'b1;
                AXI_WREADY <= 1'b1;
                AXI_BVALID <= 1'b1;
                AXI_BRESP <= 2'b00;
            end
        end
        else
            begin
                AXI_AWREADY <= 1'b0;
                AXI_WREADY <= 1'b0;
                AXI_BVALID <= 1'b0;
            end
    end

    //======================================================
    // READ DATA / ADDRESS + write logic into uart
    //======================================================
    reg rx_drdy_latch; // Indicates whether latched data has been read
    reg [DATA_BITS-1:0] rx_do_latch; // Used for data latching every time rx_drdy is triggered

    always @(posedge AXI_ACLK)
    begin
        if (!AXI_ARESETN)
        begin
            rx_drdy_latch <= 1'b0;
            rx_do_latch <= 8'hFF;
            AXI_RDATA <= 32'hDEADBEEF;
            AXI_RVALID <= 1'b0;
            AXI_ARREADY <= 1'b0;
            AXI_RRESP <= 2'b00;
        end
        else
        begin
            // LATCH DRDY
            if (rx_drdy)
            begin
                rx_drdy_latch <= 1'b1;
                rx_do_latch <= rx_do;
            end
            if (AXI_ARVALID & AXI_RREADY)
            begin
                if (AXI_RVALID & AXI_ARREADY)
                begin
                    AXI_RVALID <= 1'b0;
                    AXI_ARREADY <= 1'b0;
                end
                else
                begin
                    AXI_RVALID <= 1'b1;
                    AXI_ARREADY <= 1'b1;
                    AXI_RRESP <= 2'b00;

                    case (AXI_ARADDR[3:0])
                        ADDR_TX_DATA:
                            begin
                            AXI_RDATA <= { { (AXI_DWIDTH-DATA_BITS){1'b0} }, tx_di };
                            end
                        ADDR_TX_BUSY:
                            begin
                            AXI_RDATA <= { { (AXI_DWIDTH-1){1'b0} }, tx_busy};
                            end
                        ADDR_RX_DATA:
                            begin
                            AXI_RDATA <= { { (AXI_DWIDTH-DATA_BITS){1'b0} }, rx_do_latch };
                            rx_drdy_latch <= 1'b0;
                            end
                        ADDR_RX_STATE:
                            begin
                            AXI_RDATA <= { { (AXI_DWIDTH-2){1'b0} }, rx_busy, rx_drdy_latch};
                            end
                        default:
                            AXI_RDATA <= 32'hDEADBEEF;
                    endcase
                end
            end
            else
            begin
                AXI_RVALID <= 1'b0;
                AXI_ARREADY <= 1'b0;
                AXI_RDATA <= 32'hDEADBEEF;
            end
        end
    end

endmodule

/**
Read-data:
- Source: (here the peripheral) generates the valid-signal
- Destination: (here the master bus) generates the ready-signal
- Once the ready and valid signal are asserted for a cycle -> disable the valid signal
Write-data:
- Source: (here the master bus) generates the valid-signal
- Destination: (here the peripheral bus) generates the ready-signal on valid assertion
- Once the ready and valid signals are asserted -> disable the valid signal
Waiting for write-address bus to be valid
- This is done in case there are multiple masters on the bus, and one master already pulled the bus high


TODO:
- Data write to tx: check if data is directly written to the TX
        - Check the busy-signal as well for the TX -> Make sure its readable so data can be transmitted when the data is not busy.
*/