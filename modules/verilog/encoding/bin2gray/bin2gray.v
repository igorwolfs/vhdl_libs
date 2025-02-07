`timescale 1ns/10ps

module gray2bin
    #(parameter N=8) (
    input [N-1:0] gray_in,
    output [N-1:0] bin_out
    );
    
    genvar i;
    assign bin_out[N-1] = gray_in[N-1];
    generate
        for (i=N-2; i>=0; i=i-1)
            begin
            assign bin_out[i] = bin_out[i+1] ^ gray_in[i];
            end
    endgenerate
endmodule

module bin2gray
    #(parameter N=8) (
    input [N-1:0] bin_in,
    output [N-1:0] gray_out
    );

    genvar i;
    generate
        // Can also be written as (bin_in >> 1) ^ bin_in
        for (i=0; i<N-1; i=i+1)
            begin
            assign gray_out[i] = bin_in[i] ^ bin_in[i+1];
            end
    endgenerate
    assign gray_out[N-1] = bin_in[N-1];

endmodule
