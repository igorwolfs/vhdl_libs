`timescale 1ns/10ps

module gray2bin #(parameter N=8) (
    input [N-1:0] GI,
    output [N-1:0] BO
    );

    genvar i;
    assign BO[N-1] = GI[N-1];
    generate
        for (i=N-2; i>=0; i=i-1)
            begin
            assign BO[i] = BO[i+1] ^ GI[i];
            end
    endgenerate
endmodule

module bin2gray #(parameter N=8) (
    input [N-1:0] BI,
    output [N-1:0] GO
    );

    genvar i;
    generate
        // Can also be written as (BI >> 1) ^ BI
        for (i=0; i<N-1; i=i+1)
            begin
            assign GO[i] = BI[i] ^ BI[i+1];
            end
    endgenerate
    assign GO[N-1] = BI[N-1];

endmodule
