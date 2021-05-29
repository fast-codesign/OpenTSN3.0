/////////////////////////////////////////////////////////////////
// NUDT.  All rights reserved.
//*************************************************************
//                     Basic Information
//*************************************************************
//Vendor: NUDT
//FAST URL://www.fastswitch.org 
//Target Device: Xilinx
//Filename: TGR.v
//Version: 1.0
//date: 2019/08/08
//Author : Peng Jintao
//*************************************************************
//                     Module Description
//*************************************************************
// TGR(Traffic Generation Request):achieve rate limiting based on Token-Bucket algorithm;
//
//*************************************************************
//                     Revision List
//*************************************************************
//	rn1: 
//      date: 
//      modifier: 
//      description: 
//////////////////////////////////////////////////////////////
module TGR(
//clk & rst
input			clk,
input			rst_n,
input           i_test_start,
input     [1:0] iv_cfg_finish,
input           i_time_slot_switch,
input     [9:0] iv_time_slot, 
//receive from LCM
input   [11:0] in_tgr_pkt_len,
input   [15:0] in_tgr_tb_size,       //committed burst size is 4095 Byte.
input   [15:0] in_tgr_tb_rate,       //add number of token per slot.  
//receive from TSM
input	        in_tgr_selected,    
         
//transmit to GCM
output	reg     out_tgr_req
);

wire [15:0] pkt_len;
assign pkt_len = {4'b0,in_tgr_pkt_len+12'd4};
//token bucket parameter
reg  [15:0] RT;        //remaining tokens
reg  [15:0] CT;        //consume tokens,1Byte consumes 1 token.
//************************************************************
//                   consume tokens
//************************************************************
always@(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        CT <= 16'd0;	
    end
    else begin
		if(in_tgr_selected == 1'b1)begin
		    CT <= pkt_len;
		end
		else begin
		    CT <= 16'd0;
		end
    end
end 

//************************************************************
//                    count token
//************************************************************
reg [3:0] tb_state;
localparam INIT_S = 4'd0,
           WAIT_SYNC_FINISH_S = 4'd1,
           WAIT_PERIOD_START_S = 4'd2,
           TB_UPDATA_S = 4'd3;
always@(negedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        RT <= 16'd0;
        tb_state <= INIT_S;
    end
	else begin
	    case(tb_state)
	        INIT_S:begin
            	RT <= 16'd0;
	            if(i_test_start == 1'b1)begin
	                tb_state <= WAIT_SYNC_FINISH_S;
	            end
	            else begin
	                tb_state <= INIT_S;
	            end   
	        end
            WAIT_SYNC_FINISH_S:begin
	            if(iv_cfg_finish == 2'h3)begin
	                tb_state <= WAIT_PERIOD_START_S;
	            end
	            else begin
	                tb_state <= WAIT_SYNC_FINISH_S;
	            end               
            end            
            WAIT_PERIOD_START_S:begin
	            if((i_time_slot_switch)&&(iv_time_slot == 10'h0))begin
	                RT <= in_tgr_tb_rate;
	                tb_state <= TB_UPDATA_S;
	            end
	            else begin
	                RT <= 16'd0;
	                tb_state <= WAIT_PERIOD_START_S;
	            end              
            end
	        TB_UPDATA_S:begin
	           if(i_test_start == 1'b1)begin
	               tb_state <= TB_UPDATA_S;
	               if(i_time_slot_switch) begin
	                   if(RT + in_tgr_tb_rate - CT <= in_tgr_tb_size)begin
	                       RT <= RT + in_tgr_tb_rate - CT;
	                   end
	                   else begin
	                       RT <= in_tgr_tb_size;
	                   end
	                end
	                else begin
	                    RT <= RT - CT;
	                end
                end
                else begin
                    RT <= 16'd0;
                    tb_state <= INIT_S;
                end
            end
            default:begin
                tb_state <= INIT_S;
            end
        endcase
    end
end
//************************************************************
//  judge whether the queue has request of traffic generation
//************************************************************
always@(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        out_tgr_req <= 1'b0;
    end
    else begin
	    if(RT >= pkt_len)begin
		    out_tgr_req <= 1'b1;
		end
		else begin
		    out_tgr_req <= 1'b0;
		end
    end     
end        
endmodule



