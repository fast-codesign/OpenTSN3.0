// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_decapsulation_module
// Version: frame_decapsulation_module_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - decapsulate TSMP frame to ARP ack frame、PTP frame、NMAC configuration frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module mux
(
        i_clk,
        i_rst_n,
       
        i_data_lcm_req,
	    o_data_lcm_ack,
        iv_data_lcm,
        
        iv_data_fem,
	    i_data_fem_wr,
        
        iv_data_fdm,
	    i_data_fdm_wr,
	    
        ov_data,
        o_data_wr
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;  
// pkt input from fem
input	         	    i_data_lcm_req;
output reg              o_data_lcm_ack;
input	   [133:0]	    iv_data_lcm;
// pkt input from ddm
input	   [133:0]	    iv_data_fem;
input	         	    i_data_fem_wr;
// pkt input from ddm
input	   [133:0]	    iv_data_fdm;
input	         	    i_data_fdm_wr;
// pkt output to mux
output reg [133:0]	    ov_data;
output reg	            o_data_wr;
//***************************************************
//               mux 2to1
//***************************************************
// internal reg&wire for state machine
reg     [133:0]  rv_data;
reg              r_data_wr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data <= 134'b0;
		r_data_wr <= 1'b0;
    end
    else begin
        if(i_data_fem_wr == 1'b1)begin                   
            rv_data   <= iv_data_fem;
	        r_data_wr <= i_data_fem_wr;
        end
        else if(i_data_fdm_wr == 1'b1)begin                   
            rv_data <= iv_data_fdm;
	        r_data_wr <= i_data_fdm_wr;
        end
        else begin
            rv_data <= 9'b0;
            r_data_wr <= 1'b0; 
        end
    end
end
//***************************************************
//               mux 2to1
//***************************************************
reg              r_fifo_rd;
wire  [133:0]    wv_fifo_q;
wire             w_fifo_empty;

reg   [2:0]      mux_state;
localparam  IDLE_S = 3'd0,
            WAIT_1CYCLE_S = 3'd1,
            TRANS_REPORT_S = 3'd2,
            TRANS_PTP_S = 3'd3;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
        o_data_wr <= 1'b0;
        o_data_lcm_ack <= 1'b0;  
		r_fifo_rd <= 1'b0;
        mux_state <= IDLE_S;
    end
    else begin
        case(mux_state)
            IDLE_S:begin
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
                if(i_data_lcm_req)begin 
                    o_data_lcm_ack <= 1'b1; 
                    r_fifo_rd <= 1'b0;                    
                    mux_state <= WAIT_1CYCLE_S;
                end
                else if(!w_fifo_empty)begin 
                    o_data_lcm_ack <= 1'b0;  
                    r_fifo_rd <= 1'b1;
                    mux_state <= TRANS_PTP_S;                    
                end
                else begin
                    o_data_lcm_ack <= 1'b0;  
                    r_fifo_rd <= 1'b0;
                    mux_state <= IDLE_S;                     
                end
            end
            WAIT_1CYCLE_S:begin
                o_data_lcm_ack <= 1'b0;  
                r_fifo_rd <= 1'b0;
                mux_state <= TRANS_REPORT_S;                
            end
            TRANS_REPORT_S:begin
                ov_data <= iv_data_lcm;
                o_data_wr <= 1'b1;
                if(iv_data_lcm[133:132]==2'b10)begin
                    mux_state <= IDLE_S;                      
                end
                else begin
                    mux_state <= TRANS_REPORT_S;      
                end                
            end
            TRANS_PTP_S:begin
                ov_data <= wv_fifo_q;
                o_data_wr <= 1'b1;
                if(wv_fifo_q[133:132]==2'b10)begin
                    r_fifo_rd <= 1'b0;
                    mux_state <= IDLE_S;                      
                end
                else begin
                    r_fifo_rd <= 1'b1;
                    mux_state <= TRANS_PTP_S;      
                end              
            end
            default:begin
                mux_state <= IDLE_S;
            end
        endcase
    end
end
fifo_w134d128_commonclock_sclr_showahead pkt_fifo_inst(
.data(rv_data),  //  fifo_input.datain
.wrreq(r_data_wr), //            .wrreq
.rdreq(r_fifo_rd), //            .rdreq
.sclr(!i_rst_n),
.clock(i_clk), //            .clk
.q(wv_fifo_q),     // fifo_output.dataout
.usedw(), //            .usedw
.full(),  //            .full
.empty(w_fifo_empty)  //            .empty
);
endmodule