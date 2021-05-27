// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ns / 1ns

module altera_eth_tse_ptp_std_synchronizer #(
    parameter width = 1,
    parameter depth = 3
) (
    input   clk,
    input   reset_n,
    input   [width-1:0] din,
    output  [width-1:0] dout
);

genvar i;
generate
for (i = 0; i < width; i = i + 1) begin: nocut_sync    
    altera_std_synchronizer_nocut #(
        .depth(depth)
    ) std_sync_nocut (
        .clk        (clk),
        .reset_n    (reset_n),
        .din        (din[i]),
        .dout       (dout[i])
    );
end    
endgenerate
    
endmodule
