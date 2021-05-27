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



// START_FILE_HEADER ----------------------------------------------------------
//
// Filename    : altera_eth_tse_std_synchronizer.v
//
// Description : Contains the simulation model for the altera_eth_tse_std_synchronizer
//
// Owner       : Paul Scheidt
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//
// END_FILE_HEADER ------------------------------------------------------------

// START_MODULE_NAME-----------------------------------------------------------
//
// Module Name : altera_eth_tse_std_synchronizer
//
// Description : Single bit clock domain crossing synchronizer. 
//               Composed of two or more flip flops connected in series.
//               Random metastable condition is simulated when the 
//               __ALTERA_STD__METASTABLE_SIM macro is defined.
//               Use +define+__ALTERA_STD__METASTABLE_SIM argument 
//               on the Verilog simulator compiler command line to 
//               enable this mode. In addition, dfine the macro
//               __ALTERA_STD__METASTABLE_SIM_VERBOSE to get console output 
//               with every metastable event generated in the synchronizer.
//
// Copyright (C) Altera Corporation 2009, All Rights Reserved
// END_MODULE_NAME-------------------------------------------------------------

`timescale 1ns / 1ns

module altera_eth_tse_std_synchronizer  #(
    parameter depth = 3
) (
    input   clk,
    input   reset_n,
    input   din,
    output  dout
);
    
    altera_std_synchronizer_nocut #(
        .depth(depth)
    ) std_sync_no_cut (
        .clk        (clk),
        .reset_n    (reset_n),
        .din        (din),
        .dout       (dout)
    );
    
endmodule
      
