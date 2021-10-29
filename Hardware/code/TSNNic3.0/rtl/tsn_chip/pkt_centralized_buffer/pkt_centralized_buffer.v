// Copyright (C) 1953-2020 NUDT
// Verilog module name - pkt_centralized_buffer
// Version: PCB_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Pkt Centralized Buffer
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module pkt_centralized_buffer
(
        clk_sys,
        reset_n,
        iv_pkt_p0,
        i_pkt_wr_p0,
        iv_pkt_wr_bufadd_p0,
        o_pkt_wr_ack_p0,
        iv_pkt_p1,
        i_pkt_wr_p1,
        iv_pkt_wr_bufadd_p1,
        o_pkt_wr_ack_p1,
        iv_pkt_p2,
        i_pkt_wr_p2,
        iv_pkt_wr_bufadd_p2,
        o_pkt_wr_ack_p2,
        iv_pkt_p3,
        i_pkt_wr_p3,
        iv_pkt_wr_bufadd_p3,
        o_pkt_wr_ack_p3,
    
        iv_pkt_p8,
        i_pkt_wr_p8,
        iv_pkt_wr_bufadd_p8,
        o_pkt_wr_ack_p8,
        iv_pkt_rd_bufadd_p0,
        i_pkt_rd_p0,
        o_pkt_rd_ack_p0,
        ov_pkt_p0,
        o_pkt_wr_p0,
        iv_pkt_rd_bufadd_p1,
        i_pkt_rd_p1,
        o_pkt_rd_ack_p1,
        ov_pkt_p1,
        o_pkt_wr_p1,
        iv_pkt_rd_bufadd_p2,
        i_pkt_rd_p2,
        o_pkt_rd_ack_p2,
        ov_pkt_p2,
        o_pkt_wr_p2,
        iv_pkt_rd_bufadd_p3,
        i_pkt_rd_p3,
        o_pkt_rd_ack_p3,
        ov_pkt_p3,
        o_pkt_wr_p3,

        iv_pkt_rd_bufadd_p8,
        i_pkt_rd_p8,
        o_pkt_rd_ack_p8,
        ov_pkt_p8,
        o_pkt_wr_p8,
        ov_pkt_bufid_p0,
        o_pkt_bufid_wr_p0,
        i_pkt_bufid_ack_p0,
        ov_pkt_bufid_p1,
        o_pkt_bufid_wr_p1,
        i_pkt_bufid_ack_p1,     
        ov_pkt_bufid_p2,
        o_pkt_bufid_wr_p2,
        i_pkt_bufid_ack_p2,
        ov_pkt_bufid_p3,
        o_pkt_bufid_wr_p3,
        i_pkt_bufid_ack_p3,
        
        ov_pkt_bufid_p8,
        o_pkt_bufid_wr_p8,
        i_pkt_bufid_ack_p8,
        i_pkt_bufid_wr_flt,
        iv_pkt_bufid_flt,
        iv_pkt_bufid_cnt_flt,
        iv_pkt_bufid_p0,
        i_pkt_bufid_wr_p0,
        o_pkt_bufid_ack_p0,
        iv_pkt_bufid_p1,
        i_pkt_bufid_wr_p1,
        o_pkt_bufid_ack_p1,
        iv_pkt_bufid_p2,
        i_pkt_bufid_wr_p2,
        o_pkt_bufid_ack_p2,
        iv_pkt_bufid_p3,
        i_pkt_bufid_wr_p3,
        o_pkt_bufid_ack_p3,
      
        iv_pkt_bufid_p8,
        i_pkt_bufid_wr_p8,
        o_pkt_bufid_ack_p8,
        
        ov_pkt_write_state,      
        ov_pcb_pkt_read_state,   
        ov_address_write_state,  
        ov_address_read_state,   
        ov_free_buf_fifo_rdusedw,
		
        bufid_state,
        bufid_overflow_cnt,
        bufid_underflow_cnt		
);
// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
//receive port pkt
input       [133:0]     iv_pkt_p0;              //receive network interface port0 packet
input                   i_pkt_wr_p0;            //receive network interface port0 write signal
input       [15:0]      iv_pkt_wr_bufadd_p0;    //receive network interface port0 buffer address 
output                  o_pkt_wr_ack_p0;        //receive network interface port0 ack 
input       [133:0]     iv_pkt_p1;              
input                   i_pkt_wr_p1;            
input       [15:0]      iv_pkt_wr_bufadd_p1;    
output                  o_pkt_wr_ack_p1;        
input       [133:0]     iv_pkt_p2;              
input                   i_pkt_wr_p2;            
input       [15:0]      iv_pkt_wr_bufadd_p2;    
output                  o_pkt_wr_ack_p2;        
input       [133:0]     iv_pkt_p3;
input                   i_pkt_wr_p3;
input       [15:0]      iv_pkt_wr_bufadd_p3;
output                  o_pkt_wr_ack_p3;

input       [133:0]     iv_pkt_p8;              //receive host interface packet
input                   i_pkt_wr_p8;            //receive host interface write signal
input       [15:0]      iv_pkt_wr_bufadd_p8;    //receive host interface buffer address 
output                  o_pkt_wr_ack_p8;        //receive host interface ack
//send port pkt
input       [15:0]      iv_pkt_rd_bufadd_p0;    //send network interface port0 buffer address 
input                   i_pkt_rd_p0;            //send network interface port0 read signal
output                  o_pkt_rd_ack_p0;        //send network interface port0 ack
output      [133:0]     ov_pkt_p0;              //send network interface port0 packet
output                  o_pkt_wr_p0;            //send network interface port0 write signal
input       [15:0]      iv_pkt_rd_bufadd_p1;    
input                   i_pkt_rd_p1;            
output                  o_pkt_rd_ack_p1;        
output      [133:0]     ov_pkt_p1;              
output                  o_pkt_wr_p1;            
input       [15:0]      iv_pkt_rd_bufadd_p2;    
input                   i_pkt_rd_p2;            
output                  o_pkt_rd_ack_p2;        
output      [133:0]     ov_pkt_p2;              
output                  o_pkt_wr_p2;            
input       [15:0]      iv_pkt_rd_bufadd_p3;
input                   i_pkt_rd_p3;
output                  o_pkt_rd_ack_p3;
output      [133:0]     ov_pkt_p3;
output                  o_pkt_wr_p3;

input       [15:0]      iv_pkt_rd_bufadd_p8;    //send host interface buffer address
input                   i_pkt_rd_p8;            //send host interface read signal
output                  o_pkt_rd_ack_p8;        //send host interface ack
output      [133:0]     ov_pkt_p8;              //send host interface  packet
output                  o_pkt_wr_p8;            //send host interface write signal
//send port buffer id
output      [8:0]       ov_pkt_bufid_p0;
output                  o_pkt_bufid_wr_p0;
input                   i_pkt_bufid_ack_p0;
output      [8:0]       ov_pkt_bufid_p1;
output                  o_pkt_bufid_wr_p1;
input                   i_pkt_bufid_ack_p1;     
output      [8:0]       ov_pkt_bufid_p2;
output                  o_pkt_bufid_wr_p2;
input                   i_pkt_bufid_ack_p2;
output      [8:0]       ov_pkt_bufid_p3;
output                  o_pkt_bufid_wr_p3;
input                   i_pkt_bufid_ack_p3;

output      [8:0]       ov_pkt_bufid_p8;
output                  o_pkt_bufid_wr_p8;
input                   i_pkt_bufid_ack_p8;
//receive Forward Lookup Table Module's buf id and using cnt.
input                   i_pkt_bufid_wr_flt;
input       [8:0]       iv_pkt_bufid_flt;
input       [3:0]       iv_pkt_bufid_cnt_flt;
//receive port buffer id
input       [8:0]       iv_pkt_bufid_p0;
input                   i_pkt_bufid_wr_p0;
output                  o_pkt_bufid_ack_p0;
input       [8:0]       iv_pkt_bufid_p1;
input                   i_pkt_bufid_wr_p1;
output                  o_pkt_bufid_ack_p1;
input       [8:0]       iv_pkt_bufid_p2;
input                   i_pkt_bufid_wr_p2;
output                  o_pkt_bufid_ack_p2;
input       [8:0]       iv_pkt_bufid_p3;
input                   i_pkt_bufid_wr_p3;
output                  o_pkt_bufid_ack_p3;

input       [8:0]       iv_pkt_bufid_p8;
input                   i_pkt_bufid_wr_p8;
output                  o_pkt_bufid_ack_p8;
//state
output     [3:0]        ov_pkt_write_state;      
output     [3:0]        ov_pcb_pkt_read_state;   
output     [3:0]        ov_address_write_state;  
output     [3:0]        ov_address_read_state;   
output     [8:0]        ov_free_buf_fifo_rdusedw;

// internal wire for pkt_RAM
wire        [133:0]     pkt_pwr2ram;
wire                    pkt_wr_pwr2ram;
wire        [15:0]      pkt_bufadd_pwr2ram;
wire        [15:0]      pkt_bufadd_prd2ram;
wire                    pkt_rd_prd2ram;
wire        [133:0]     pkt_ram2prd;
// internal wire for FIFO
wire                    pkt_bufid_rd_ard2fifo;
wire        [8:0]       pkt_bufid_fifo2ard;
wire                    pkt_bufid_empty_fifo2ard;
wire                    pkt_bufid_wr_awr2fifo;
wire        [8:0]       pkt_bufid_awr2fifo;
wire                    pkt_bufid_full_awr2fifo;
//internal wire for portnum_RAM
wire        [3:0]       rd_outport_num;
wire        [8:0]       bufid_addr;
wire                    rd_bufid_wr;
wire        [3:0]       wr_outport_num;
wire                    wr_bufid_wr;
        
//assign rd_outport_num = rd_outport_num_ram[3:0];

pkt_write pkt_write_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        .iv_pkt_p0(iv_pkt_p0),
        .i_pkt_wr_p0(i_pkt_wr_p0),
        .iv_pkt_wr_bufadd_p0(iv_pkt_wr_bufadd_p0),
        .o_pkt_wr_ack_p0(o_pkt_wr_ack_p0),
        .iv_pkt_p1(iv_pkt_p1),
        .i_pkt_wr_p1(i_pkt_wr_p1),
        .iv_pkt_wr_bufadd_p1(iv_pkt_wr_bufadd_p1),
        .o_pkt_wr_ack_p1(o_pkt_wr_ack_p1),
        .iv_pkt_p2(iv_pkt_p2),
        .i_pkt_wr_p2(i_pkt_wr_p2),
        .iv_pkt_wr_bufadd_p2(iv_pkt_wr_bufadd_p2),
        .o_pkt_wr_ack_p2(o_pkt_wr_ack_p2),
        .iv_pkt_p3(iv_pkt_p3),
        .i_pkt_wr_p3(i_pkt_wr_p3),
        .iv_pkt_wr_bufadd_p3(iv_pkt_wr_bufadd_p3),
        .o_pkt_wr_ack_p3(o_pkt_wr_ack_p3),
       
        .iv_pkt_p8(iv_pkt_p8),
        .i_pkt_wr_p8(i_pkt_wr_p8),
        .iv_pkt_wr_bufadd_p8(iv_pkt_wr_bufadd_p8),
        .o_pkt_wr_ack_p8(o_pkt_wr_ack_p8),
        .o_pkt(pkt_pwr2ram),
        .o_pkt_wr(pkt_wr_pwr2ram),
        .o_pkt_bufadd(pkt_bufadd_pwr2ram),
        .ov_pkt_write_state(ov_pkt_write_state)
    );

pkt_read pkt_read_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),  
        .iv_pkt_rd_bufadd_p0(iv_pkt_rd_bufadd_p0),
        .i_pkt_rd_p0(i_pkt_rd_p0),
        .o_pkt_rd_ack_p0(o_pkt_rd_ack_p0),
        .ov_pkt_p0(ov_pkt_p0),
        .o_pkt_wr_p0(o_pkt_wr_p0),
        .iv_pkt_rd_bufadd_p1(iv_pkt_rd_bufadd_p1),
        .i_pkt_rd_p1(i_pkt_rd_p1),
        .o_pkt_rd_ack_p1(o_pkt_rd_ack_p1),
        .ov_pkt_p1(ov_pkt_p1),
        .o_pkt_wr_p1(o_pkt_wr_p1),
        .iv_pkt_rd_bufadd_p2(iv_pkt_rd_bufadd_p2),
        .i_pkt_rd_p2(i_pkt_rd_p2),
        .o_pkt_rd_ack_p2(o_pkt_rd_ack_p2),
        .ov_pkt_p2(ov_pkt_p2),
        .o_pkt_wr_p2(o_pkt_wr_p2),
        .iv_pkt_rd_bufadd_p3(iv_pkt_rd_bufadd_p3),
        .i_pkt_rd_p3(i_pkt_rd_p3),
        .o_pkt_rd_ack_p3(o_pkt_rd_ack_p3),
        .ov_pkt_p3(ov_pkt_p3),
        .o_pkt_wr_p3(o_pkt_wr_p3),
   
        .iv_pkt_rd_bufadd_p8(iv_pkt_rd_bufadd_p8),
        .i_pkt_rd_p8(i_pkt_rd_p8),
        .o_pkt_rd_ack_p8(o_pkt_rd_ack_p8),
        .ov_pkt_p8(ov_pkt_p8),
        .o_pkt_wr_p8(o_pkt_wr_p8),
        .o_pkt_bufadd(pkt_bufadd_prd2ram),
        .o_pkt_rd(pkt_rd_prd2ram),
        .i_pkt(pkt_ram2prd),
        .ov_pcb_pkt_read_state(ov_pcb_pkt_read_state)
    );
    
suhddpsram65536x134_s suhddpsram65536x134_s_inst(
        .aclr       (!reset_n               ),  //asynchronous reset(high active)
        .address_a  (pkt_bufadd_prd2ram     ),  //RAM read address
        .address_b  (pkt_bufadd_pwr2ram     ),  //RAM write address
        .clock      (clk_sys                ),  //ASYNC WriteClk, SYNC use wrclk,
        .data_a     ({134{1'b0}}            ),  //
        .data_b     (pkt_pwr2ram            ),  //RAM input data
        .rden_a     (pkt_rd_prd2ram         ),  //RAM read request(high active)
        .rden_b     (1'b0                   ),  //
        .wren_a     (1'b0                   ),  //
        .wren_b     (pkt_wr_pwr2ram         ),  //RAM write request(high active)
        .q_a        (pkt_ram2prd            ),  //RAM output data
        .q_b        (                       )   //
);                  

suhddpsram512x4_rq suhddpsram512x4_rq_inst( 
        .aclr(!reset_n),                        //asynchronous reset(high active)
        
        .address_a(iv_pkt_bufid_flt),           //port A: address
        .address_b(bufid_addr),                 //port B: address
        
        .clock(clk_sys),                        //port A & B: clock
        
        .data_a(iv_pkt_bufid_cnt_flt),          //port A: data input
        .data_b(wr_outport_num),                //port B: data input
        
        .rden_a(1'b0),                          //port A: read enable(high active)
        .rden_b(rd_bufid_wr),                   //port B: read enable(high active)
        
        .wren_a(i_pkt_bufid_wr_flt),            //port A: write enable(high active)
        .wren_b(wr_bufid_wr),                   //port B: write enable(high active)
        
        .q_a(),                                 //port A: data output
        .q_b(rd_outport_num)                    //port B: data output
);          

address_read address_read_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),  
        .ov_pkt_bufid_p0(ov_pkt_bufid_p0),
        .o_pkt_bufid_wr_p0(o_pkt_bufid_wr_p0),
        .i_pkt_bufid_ack_p0(i_pkt_bufid_ack_p0),
        .ov_pkt_bufid_p1(ov_pkt_bufid_p1),
        .o_pkt_bufid_wr_p1(o_pkt_bufid_wr_p1),
        .i_pkt_bufid_ack_p1(i_pkt_bufid_ack_p1),        
        .ov_pkt_bufid_p2(ov_pkt_bufid_p2),
        .o_pkt_bufid_wr_p2(o_pkt_bufid_wr_p2),
        .i_pkt_bufid_ack_p2(i_pkt_bufid_ack_p2),
        .ov_pkt_bufid_p3(ov_pkt_bufid_p3),
        .o_pkt_bufid_wr_p3(o_pkt_bufid_wr_p3),
        .i_pkt_bufid_ack_p3(i_pkt_bufid_ack_p3),
     
        .ov_pkt_bufid_p8(ov_pkt_bufid_p8),
        .o_pkt_bufid_wr_p8(o_pkt_bufid_wr_p8),
        .i_pkt_bufid_ack_p8(i_pkt_bufid_ack_p8),
        .o_pkt_bufid_rd(pkt_bufid_rd_ard2fifo),
        .iv_pkt_bufid(pkt_bufid_fifo2ard),
        .i_pkt_bufid_empty(pkt_bufid_empty_fifo2ard),
        .ov_address_read_state(ov_address_read_state)
    );

address_write add_write_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        .iv_pkt_bufid_p0(iv_pkt_bufid_p0),
        .i_pkt_bufid_wr_p0(i_pkt_bufid_wr_p0),
        .o_pkt_bufid_ack_p0(o_pkt_bufid_ack_p0),
        .iv_pkt_bufid_p1(iv_pkt_bufid_p1),
        .i_pkt_bufid_wr_p1(i_pkt_bufid_wr_p1),
        .o_pkt_bufid_ack_p1(o_pkt_bufid_ack_p1),
        .iv_pkt_bufid_p2(iv_pkt_bufid_p2),
        .i_pkt_bufid_wr_p2(i_pkt_bufid_wr_p2),
        .o_pkt_bufid_ack_p2(o_pkt_bufid_ack_p2),
        .iv_pkt_bufid_p3(iv_pkt_bufid_p3),
        .i_pkt_bufid_wr_p3(i_pkt_bufid_wr_p3),
        .o_pkt_bufid_ack_p3(o_pkt_bufid_ack_p3),
    
        .iv_pkt_bufid_p8(iv_pkt_bufid_p8),
        .i_pkt_bufid_wr_p8(i_pkt_bufid_wr_p8),
        .o_pkt_bufid_ack_p8(o_pkt_bufid_ack_p8),
        .o_pkt_bufid_wr(pkt_bufid_wr_awr2fifo),
        .o_pkt_bufid(pkt_bufid_awr2fifo),
        .i_pkt_bufid_full(pkt_bufid_full_awr2fifo),
        .ov_address_write_state(ov_address_write_state),
        .rd_outport_num(rd_outport_num),
        .bufid_addr(bufid_addr),
        .rd_bufid_wr(rd_bufid_wr),
        .wr_outport_num(wr_outport_num),
        .wr_bufid_wr(wr_bufid_wr)   
    );

SFIFO_9_512  SFIFO_9_512_inst
    (
        .aclr(!reset_n),                    //Reset the all signal(active high)
        .data(pkt_bufid_awr2fifo),          //The Inport of data 
        .rdreq(pkt_bufid_rd_ard2fifo),      //active-high
        .clk(clk_sys),                      //ASYNC WriteClk, SYNC use wrclk
        .wrreq(pkt_bufid_wr_awr2fifo),      //active-high
        .q(pkt_bufid_fifo2ard),             //The output of data
        .wrfull(pkt_bufid_full_awr2fifo),   //Write domain full 
        .rdempty(pkt_bufid_empty_fifo2ard), //Read domain empty
        
        .wralfull(),    
        .wrempty(), 
        .wralempty(),   
        .rdfull(),      
        .rdalfull(),    
        .rdalempty(),   
        .wrusedw(), 
        .rdusedw(ov_free_buf_fifo_rdusedw)  
    );
output reg  [511:0] bufid_state;
output reg  [31:0] bufid_overflow_cnt;
output reg  [31:0] bufid_underflow_cnt;
always@(posedge clk_sys or negedge reset_n)
    if(!reset_n) begin
        bufid_state <= 512'b0;
		bufid_overflow_cnt <= 32'b0;
		bufid_underflow_cnt <= 32'b0;
    end
    else begin
	    if((pkt_bufid_wr_awr2fifo == 1'b1) && (pkt_bufid_rd_ard2fifo == 1'b0))begin
			bufid_state[pkt_bufid_awr2fifo] <= 1'b1;
			if(|((512'h1 << pkt_bufid_awr2fifo) & bufid_state)==1'b1)begin
			    bufid_overflow_cnt <= bufid_overflow_cnt + 1'b1;
			end
			else begin
			    bufid_overflow_cnt <= bufid_overflow_cnt;
			end
		end
		else if((pkt_bufid_wr_awr2fifo == 1'b0) && (pkt_bufid_rd_ard2fifo == 1'b1))begin
			bufid_state[pkt_bufid_fifo2ard] <= 1'b0;
			if(|((512'h1 << pkt_bufid_fifo2ard) & bufid_state)==1'b1)begin
			    bufid_underflow_cnt <= bufid_underflow_cnt;
			end
			else begin
			    bufid_underflow_cnt <= bufid_underflow_cnt +1'b1;
			end			
		end
		else if((pkt_bufid_wr_awr2fifo == 1'b1) && (pkt_bufid_rd_ard2fifo == 1'b1))begin
			if(pkt_bufid_awr2fifo == pkt_bufid_fifo2ard)begin
                bufid_state <= bufid_state; 
            end
            else begin
                bufid_state[pkt_bufid_awr2fifo] <= 1'b1;
			    bufid_state[pkt_bufid_fifo2ard] <= 1'b0;            
            end
			if(|((512'h1 << pkt_bufid_awr2fifo) & bufid_state)==1'b1)begin
			    bufid_overflow_cnt <= bufid_overflow_cnt + 1'b1;
			end
			else begin
			    bufid_overflow_cnt <= bufid_overflow_cnt;
			end	
			if(|((512'h1 << pkt_bufid_fifo2ard) & bufid_state)==1'b1)begin
			    bufid_underflow_cnt <= bufid_underflow_cnt;
			end
			else begin
			    bufid_underflow_cnt <= bufid_underflow_cnt +1'b1;
			end				
		end
	    else begin
		    bufid_state <= bufid_state;
		end
	end
endmodule   