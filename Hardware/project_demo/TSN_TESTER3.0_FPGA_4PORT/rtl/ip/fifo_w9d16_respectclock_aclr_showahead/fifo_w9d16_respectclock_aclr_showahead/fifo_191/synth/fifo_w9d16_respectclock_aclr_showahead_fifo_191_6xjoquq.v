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



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  fifo_w9d16_respectclock_aclr_showahead_fifo_191_6xjoquq  (
    aclr,
    data,
    rdclk,
    rdreq,
    wrclk,
    wrreq,
    q,
    rdempty,
    rdfull,
    rdusedw,
    wrempty,
    wrfull,
    wrusedw);

    input    aclr;
    input  [8:0]  data;
    input    rdclk;
    input    rdreq;
    input    wrclk;
    input    wrreq;
    output [8:0]  q;
    output   rdempty;
    output   rdfull;
    output [3:0]  rdusedw;
    output   wrempty;
    output   wrfull;
    output [3:0]  wrusedw;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
    tri0     aclr;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

    wire [8:0] sub_wire0;
    wire  sub_wire1;
    wire  sub_wire2;
    wire [3:0] sub_wire3;
    wire  sub_wire4;
    wire  sub_wire5;
    wire [3:0] sub_wire6;
    wire [8:0] q = sub_wire0[8:0];
    wire  rdempty = sub_wire1;
    wire  rdfull = sub_wire2;
    wire [3:0] rdusedw = sub_wire3[3:0];
    wire  wrempty = sub_wire4;
    wire  wrfull = sub_wire5;
    wire [3:0] wrusedw = sub_wire6[3:0];

    dcfifo  dcfifo_component (
                .aclr (aclr),
                .data (data),
                .rdclk (rdclk),
                .rdreq (rdreq),
                .wrclk (wrclk),
                .wrreq (wrreq),
                .q (sub_wire0),
                .rdempty (sub_wire1),
                .rdfull (sub_wire2),
                .rdusedw (sub_wire3),
                .wrempty (sub_wire4),
                .wrfull (sub_wire5),
                .wrusedw (sub_wire6),
                .eccstatus ());
    defparam
        dcfifo_component.enable_ecc  = "FALSE",
        dcfifo_component.intended_device_family  = "Arria 10",
        dcfifo_component.lpm_hint  = "DISABLE_DCFIFO_EMBEDDED_TIMING_CONSTRAINT=TRUE",
        dcfifo_component.lpm_numwords  = 16,
        dcfifo_component.lpm_showahead  = "ON",
        dcfifo_component.lpm_type  = "dcfifo",
        dcfifo_component.lpm_width  = 9,
        dcfifo_component.lpm_widthu  = 4,
        dcfifo_component.overflow_checking  = "ON",
        dcfifo_component.rdsync_delaypipe  = 4,
        dcfifo_component.read_aclr_synch  = "OFF",
        dcfifo_component.underflow_checking  = "ON",
        dcfifo_component.use_eab  = "ON",
        dcfifo_component.write_aclr_synch  = "OFF",
        dcfifo_component.wrsync_delaypipe  = 4;


endmodule


