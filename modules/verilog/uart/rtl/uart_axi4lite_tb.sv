
module uart_axi4lite_tb();
    // Constants
    localparam AXI_AWIDTH = 4;
    localparam AXI_DWIDTH = 32;

    // Signals / Registers
    reg s_axi_aclk;
    reg s_axi_aresetn;
    reg [AXI_AWIDTH-1:0] s_axi_awaddr;
    reg s_axi_awvalid;
    wire s_axi_awready;
    reg [AXI_DWIDTH-1:0] s_axi_wdata;
    reg [$clog2(AXI_DWIDTH-1)-1: 0] s_axi_wstrb;
    reg s_axi_wvalid;
    wire s_axi_wready;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    reg s_axi_bready;
    reg [AXI_AWIDTH-1:0] s_axi_araddr;
    reg s_axi_arvalid;
    wire s_axi_arready;
    wire [AXI_DWIDTH-1:0] s_axi_rdata;
    wire [1:0]  s_axi_rresp;
    wire s_axi_rvalid;
    reg s_axi_rready, tx_dser, rx_dser;

    uart_axi4lite#(
        // AXI PARAMETERS
        .AXI_AWIDTH(AXI_AWIDTH), .AXI_DWIDTH(AXI_DWIDTH),
        // UART PARAMETERS
        .CLOCK_FREQUENCY(100_000_000),
        .BAUD_RATE(115_200),
        .DATA_BITS(8))
        (.AXI_ACLK(s_axi_aclk),
        .AXI_ARESETN(s_axi_aresetn),
        .AXI_AWADDR(s_axi_awaddr),
        .AXI_AWVALID(s_axi_awvalid),
        .AXI_AWREADY(s_axi_awready),
        .AXI_WDATA(s_axi_wdata),
        .AXI_WSTRB(s_axi_wstrb),
        .AXI_WVALID(s_axi_wvalid),
        .AXI_WREADY(s_axi_wready),
        .AXI_BRESP(s_axi_bresp),
        .AXI_BVALID(s_axi_bvalid),
        .AXI_BREADY(s_axi_bready),
        .AXI_ARADDR(s_axi_araddr),
        .AXI_ARVALID(s_axi_arvalid),
        .AXI_ARREADY(s_axi_arready),
        .AXI_RDATA(s_axi_rdata),
        .AXI_RRESP(s_axi_rresp),
        .AXI_RVALID(s_axi_rvalid),
        .AXI_RREADY(s_axi_rready),
        .TX_DSER(tx_dser), //! TX_PIN
        .RX_DSER(rx_dser) //! RX_PIN
        );

endmodule
