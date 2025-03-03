

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
    localparam ADDR_RX_DRDY = 4'hC;

    //======================================================
    // SIGNALS
    //======================================================

    reg tx_drdy;
    reg [DATA_BITS-1:0] tx_di;
    wire tx_done, rx_drdy;
    wire [DATA_BITS-1:0] rx_do;

    //======================================================
    // UART ENTITY
    //======================================================

    uart #(.CLOCK_FREQUENCY(CLK_FREQUENCY),
            .BAUD_RATE(BAUD_RATE),
            .DATA_BITS(DATA_BITS)) uart_inst
    (
        .CLK(AXI_ACLK), .NRST(NRST),
        // TX
        .TX_DRDY(tx_drdy), .TX_DI(tx_di),
        .TX_DONE(tx_done), .TX_DSER(TX_DSER), //! MUST BE A PIN
        // RX
        .RX_DSER(RX_DSER), //! MUST BE A PIN
        .RX_DO(rx_do), .RX_DRDY(rx_drdy)
    );

    //======================================================
    // AXI Write Address Channel
    //======================================================

    always @(posedge AXI_ACLK) begin
        if (!AXI_ARESETN)
            AXI_AWREADY <= 1'b0;
        else
        begin
            if (!AXI_AWREADY & AXI_AWVALID & AXI_WVALID)
                // Accept address
                AXI_AWREADY <= 1'b1;
            else
                AXI_AWREADY <= 1'b0;
        end
    end

    //======================================================
    // AXI Write Data Channel
    //======================================================
    always @(posedge AXI_ACLK)
    begin
        if (!AXI_ARESETN)
            AXI_WREADY <= 1'b0;
        else
        begin
            if (!AXI_WREADY & AXI_WVALID & AXI_AWVALID)
                // Accept write data
                AXI_WREADY <= 1'b1;
            else
                AXI_WREADY <= 1'b0;
        end
    end

    //======================================================
    // Write logic to your internal registers / UART signals
    //======================================================

    wire [AXI_AWIDTH-1:0] write_addr = AXI_AWADDR;
    always @(posedge AXI_ACLK) begin
        if (!AXI_ARESETN)
        begin
            // reset user registers
            tx_di  <= {DATA_BITS{1'b0}};
            TX_DRDY  <= 1'b0;
        end 
        else
        begin
            if (AXI_WREADY && AXI_WVALID && AXI_AWREADY && AXI_AWVALID) 
                tx_di <= AXI_WDATA[DATA_BITS-1:0];
                // ADD OTHER REGISTER WRITES HERE IF RELEVANT
            else
                tx_drdy <= 1'b0;
        end
    end

    // Provide TX_DI to the UART
    assign uart_TX_DI = tx_data_reg;  // or 8 bits from that register

    //======================================================
    // Write Response Channel
    //======================================================
    always @(posedge AXI_ACLK) begin
        if (!AXI_ARESETN) begin
            AXI_BVALID <= 1'b0;
            AXI_BRESP  <= 2'b0;
        end 
        else 
        begin
            if (AXI_AWREADY & AXI_AWVALID & ~AXI_BVALID &
                AXI_WREADY & AXI_WVALID) 
            begin
                // Both address and data accepted
                AXI_BVALID <= 1'b1;
                AXI_BRESP  <= 2'b00; // 'OKAY' response
            end 
            else if (AXI_BREADY && AXI_BVALID)
                AXI_BVALID <= 1'b0; // Master accepted the response
        end
    end

    //======================================================
    // AXI Read Address Channel
    //======================================================

    always @(posedge AXI_ACLK) begin
        if (!AXI_ARESETN)
        begin
            AXI_ARREADY <= 1'b0;
        end
        else 
        begin
            if (!AXI_ARREADY && AXI_ARVALID)
                // Accept read address
                AXI_ARREADY <= 1'b1;
            else
                AXI_ARREADY <= 1'b0;
        end
    end

    //======================================================
    // AXI Read Data Channel
    //======================================================
    // Reading from UART
    //! TODO: Latch the data-ready signal, should be cleared once data is read.
    reg uart_reg_rx_drdy;

    always @(posedge AXI_ACLK)
        begin
        if (!AXI_ARESETN)
        begin
            uart_reg_rx_drdy <= 1'b0;
            AXI_RVALID <= 1'b0;
            AXI_RRESP  <= 2'b0;
        end
        else
        begin
            // LATCH DRDY
            if (rx_drdy)
                uart_reg_rx_drdy <= 1'b1;
            if (AXI_ARREADY & AXI_ARVALID & ~AXI_RVALID)
            begin
                // Valid address; latch data for RDATA
                AXI_RVALID <= 1'b1;
                AXI_RRESP  <= 2'b00; // 'OKAY'
                case (AXI_ARADDR)
                    ADDR_TX_DATA:
                        AXI_RDATA <= { { (AXI_DWIDTH-DATA_BITS){1'b0} }, tx_di };
                    ADDR_RX_DATA:
                        AXI_RDATA <= { { (AXI_DWIDTH-DATA_BITS){1'b0} }, rx_do };
                    ADDR_RX_DRDY:
                        begin
                            AXI_RDATA <= { { (AXI_DWIDTH-DATA_BITS){1'b0} }, uart_reg_rx_drdy};
                            uart_reg_rx_drdy <= 1'b0;
                        end
                    default:         AXI_RDATA <= 32'hDEADBEEF;
                endcase
            end 
            else if (AXI_RVALID & AXI_RREADY)
                AXI_RVALID <= 1'b0;
            end
        end

endmodule
