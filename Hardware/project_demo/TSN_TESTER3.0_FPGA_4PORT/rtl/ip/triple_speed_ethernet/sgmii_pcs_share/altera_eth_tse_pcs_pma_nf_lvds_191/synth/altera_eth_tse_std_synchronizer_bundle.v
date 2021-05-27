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


//
// Module Name : altera_eth_tse_std_synchronizer_bundle
//
// Description : Bundle of bit synchronizers. 
//               WARNING: only use this to synchronize a bundle of 
//               *independent* single bit signals or a Gray encoded 
//               bus of signals. Also remember that pulses entering 
//               the synchronizer will be swallowed upon a metastable
//               condition if the pulse width is shorter than twice
//               the synchronizing clock period.
//

`timescale 1 ps / 1 ps
module altera_eth_tse_std_synchronizer_bundle  (
                                        clk,
                                        reset_n,
                                        din,
                                        dout
                                        );
    // GLOBAL PARAMETER DECLARATION
    parameter width = 1;
    parameter depth = 3;   
   
    // INPUT PORT DECLARATION
    input clk;
    input reset_n;
    input [width-1:0] din;

    // OUTPUT PORT DECLARATION
    output [width-1:0] dout;
   
    generate
        genvar i;
        for (i=0; i<width; i=i+1)
        begin : sync
            altera_eth_tse_std_synchronizer #(.depth(depth))
                                    u  (
                                        .clk(clk), 
                                        .reset_n(reset_n), 
                                        .din(din[i]), 
                                        .dout(dout[i])
                                        );
        end
    endgenerate
   
endmodule // altera_eth_tse_std_synchronizer_bundle
// END OF MODULE
