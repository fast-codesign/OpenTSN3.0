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
// ALTERA Confidential and Proprietary
// Copyright 2007 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

//Legal Notice: (C)2007 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

`timescale 1ns/1ns
module altera_tse_lvds_reverse_loopback
(
   input reset_wclk,
   input reset_rclk,
   input wclk,
   input rclk,
   input [9:0] tbi_rx_clk,
   output [9:0] tbi_tx_clk
);
localparam COMMAP = 7'b 1111100;  
localparam COMMAN = 7'b 0000011; 
localparam D16_2P = 10'b 1010110110;
localparam D16_2N = 10'b 1010001001;

wire [9:0] tbi_rx_clk_aligned;
reg  [9:0] tbi_rx_clk_aligned_reg_0;
reg  [9:0] tbi_rx_clk_aligned_reg_1;
wire [9:0] tbi_tx_clk_reg_in;
reg  [9:0] tbi_tx_clk_reg_0;
reg  [9:0] tbi_tx_clk_reg_1;

wire [9:0] tbi_rx_clk_flipped;
wire [9:0] tbi_din;
wire [9:0] tbi_dout;
wire ff_wren;
wire ff_rden;
wire ff_afull;
wire ff_aempty;

wire rm_insert;
reg rm_insert_d0;
reg rm_insert_d1;
wire rm_delete;
reg rm_delete_d;
wire tx_idle_detect;
wire rx_idle_detect;

// /I2/ detect for rate-match implementation
assign tx_idle_detect = 
(tbi_tx_clk_reg_1[6:0] == COMMAP && tbi_tx_clk_reg_0 == D16_2N) ||
(tbi_tx_clk_reg_1[6:0] == COMMAN && tbi_tx_clk_reg_0 == D16_2P);

assign rx_idle_detect = 
(tbi_rx_clk_aligned_reg_1[6:0] == COMMAP && tbi_rx_clk_aligned_reg_0 == D16_2N) ||
(tbi_rx_clk_aligned_reg_1[6:0] == COMMAN && tbi_rx_clk_aligned_reg_0 == D16_2P);

// Rate-match insert and delete equation
assign rm_delete = ff_afull & rx_idle_detect;
assign rm_insert = ff_aempty & tx_idle_detect;

always @(posedge reset_wclk or posedge wclk)
begin
   if (reset_wclk == 1'b 1)
      rm_delete_d <= 1'b0;
   else
      rm_delete_d <= rm_delete;
end

always @(posedge reset_rclk or posedge rclk)
begin
   if (reset_rclk == 1'b 1)
   begin
      rm_insert_d0 <= 1'b0;
      rm_insert_d1 <= 1'b0;
   end
   else
   begin
      rm_insert_d0 <= rm_insert;
      rm_insert_d1 <= rm_insert_d0;
   end
end

// Don't write to FIFO if rate-match delete happened (2 clock cycles for /I2/ order set)
assign ff_wren = ~ (rm_delete_d | rm_delete);

// Don't read from FIFO if rate-match insert happened (2 clock cycles for /I2/ order set)
assign ff_rden = ~ (rm_insert_d0 | rm_insert);

// If rate-match insert happended, duplicated the /I2/ order set by loopback tbi_tx_clk_reg_1 to tbi_tx_clk_reg_0
// for 2 clock cycles.
assign tbi_tx_clk_reg_in = (rm_insert_d0 | rm_insert_d1) ? tbi_tx_clk_reg_1: tbi_dout;

assign tbi_din = tbi_rx_clk_aligned_reg_1;

// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm
assign tbi_rx_clk_flipped = {
   tbi_rx_clk[0], 
   tbi_rx_clk[1], 
   tbi_rx_clk[2], 
   tbi_rx_clk[3],
   tbi_rx_clk[4],
   tbi_rx_clk[5],
   tbi_rx_clk[6],
   tbi_rx_clk[7],
   tbi_rx_clk[8],
   tbi_rx_clk[9]
};

assign tbi_tx_clk = {
   tbi_tx_clk_reg_1[0],
   tbi_tx_clk_reg_1[1],
   tbi_tx_clk_reg_1[2],
   tbi_tx_clk_reg_1[3],
   tbi_tx_clk_reg_1[4],
   tbi_tx_clk_reg_1[5],
   tbi_tx_clk_reg_1[6],
   tbi_tx_clk_reg_1[7],
   tbi_tx_clk_reg_1[8],
   tbi_tx_clk_reg_1[9]
};

// Align the 10 bit rx data to COMMA
altera_tse_align_sync
U_TBI_ALIGN (
   .rst_align (reset_wclk),
   .din (tbi_rx_clk_flipped),
   .dout (tbi_rx_clk_aligned),
   .sync (), // UNUSED
   .ce (1'b1),
   .clk (wclk),
   .sw_reset (1'b0),
   .rst (reset_wclk)
);

// Flop the aligned rx data
always @(posedge reset_wclk or posedge wclk)
begin
   if (reset_wclk == 1'b 1)
   begin
      tbi_rx_clk_aligned_reg_0 <= 10'b0;
      tbi_rx_clk_aligned_reg_1 <= 10'b0;
   end
   else
   begin
      tbi_rx_clk_aligned_reg_0 <= tbi_rx_clk_aligned;
      tbi_rx_clk_aligned_reg_1 <= tbi_rx_clk_aligned_reg_0;
   end
end

// Flop the tx data
always @(posedge reset_rclk or posedge rclk)
begin
   if (reset_rclk == 1'b 1)
   begin
      tbi_tx_clk_reg_0 <= 10'b0;
      tbi_tx_clk_reg_1 <= 10'b0;
   end
   else
   begin
      tbi_tx_clk_reg_0 <= tbi_tx_clk_reg_in;
      tbi_tx_clk_reg_1 <= tbi_tx_clk_reg_0;
   end
end

// DC FIFO for rate-match
altera_tse_a_fifo_24 
#( .FF_WIDTH(10),
   .ADDR_WIDTH(4),
   .DEPTH(16),
   .SAMPLE_SIZE(0)
)
U_REV_LOOPBACK_FIFO (

   .reset_wclk(reset_wclk),
   .reset_rclk(reset_rclk),
   .wclk(wclk),
   .wclk_ena(1'b1),
   .wren(ff_wren),
   .din(tbi_din),
   .rclk(rclk),
   .rclk_ena(1'b1),
   .rden(ff_rden),
   .dout(tbi_dout),
   .afull(ff_afull),
   .aempty(ff_aempty),
   .af_threshold(4'd4),
   .ae_threshold(4'd4),

   // These ports are not used
   .calc_clk(1'b0),
   .clk_125(1'b0),
   .latadj() // UNUSED
);


endmodule
