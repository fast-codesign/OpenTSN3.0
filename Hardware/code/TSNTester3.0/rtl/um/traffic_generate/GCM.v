/////////////////////////////////////////////////////////////////
// NUDT.  All rights reserved.
//*************************************************************
//                     Basic Information
//*************************************************************
//Vendor: NUDT
//FAST URL://www.fastswitch.org 
//Target Device: Xilinx
//Filename: GCM.v
//Version: 1.0
//date:  2019/08/08
//Author : Peng Jintao
//*************************************************************
//                     Module Description
//*************************************************************
// GCM(Gate Control Module):read data from GCL_RAM;
//     judge whether request of traffic generation is valid.
//*************************************************************
//                     Revision List
//*************************************************************
//	rn1: 
//      date: 
//      modifier: 
//      description: 
//////////////////////////////////////////////////////////////
module GCM(
//clk & rst
input			  clk,
input			  rst_n,
//receive from LCM
input	          in_gcm_test_start,             
input     [9:0]   iv_time_slot, 
input             i_time_slot_switch,
input     [10:0]  iv_time_slot_period,
//receive from TGM
input	          in_gcm_req_1,    
input	          in_gcm_req_2, 
input	          in_gcm_req_3, 
input	          in_gcm_req_4,
input	          in_gcm_req_5, 
input	          in_gcm_req_6, 
input	          in_gcm_req_7, 
input	          in_gcm_req_8,   
//receive from GCL_RAM
output reg        out_gcm_gcl_rd,   
output reg [4:0]  out_gcm_gcl_addr,    
input	   [127:0]in_gcm_gc,
//transmit to TSM
output	reg      [7:0]  out_gcm_valid
);
wire [7:0] req;
assign req = {in_gcm_req_8,in_gcm_req_7,in_gcm_req_6,in_gcm_req_5,in_gcm_req_4,in_gcm_req_3,in_gcm_req_2,in_gcm_req_1};
//************************************************************
//            read data from GCL_RAM
//************************************************************
reg [3:0] gcm_state; 
localparam INIT_S = 4'd0,
           IDLE_S = 4'd1,
           WAIT1_S = 4'd2,
		   WAIT2_S = 4'd3,
		   READ_S = 4'd4,
		   SLOT_FINISH_S = 4'd5;
always@(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        out_gcm_gcl_rd <= 1'b0;  
		out_gcm_gcl_addr <= 5'd0;
		gcm_state <= IDLE_S;
    end
    else begin
	    case(gcm_state)
            IDLE_S:begin
			    if(in_gcm_test_start == 1'b1)begin
			        if((iv_time_slot[3:0] == 4'h0) && i_time_slot_switch) begin
					    out_gcm_gcl_rd <= 1'b1;  
				        gcm_state <= WAIT1_S;    
				    end
				    else begin
					    out_gcm_gcl_rd <= 1'b0;
				        gcm_state <= IDLE_S; 
				    end
				end
				else begin
				    out_gcm_gcl_rd <= 1'b0;
				    out_gcm_gcl_addr <= 5'd0;
				    gcm_state <= IDLE_S; 
				end
			end
            WAIT1_S:begin
			    out_gcm_gcl_rd <= 1'b0;            
			    gcm_state <= WAIT2_S;    
		    end
            WAIT2_S:begin
			    gcm_state <= READ_S;    
		    end
			READ_S:begin
                if(iv_time_slot_period[10:4] <= ({2'b0,out_gcm_gcl_addr} + 1'b1))begin
                    out_gcm_gcl_addr <= 5'd0;                    
                end
                else begin
                    out_gcm_gcl_addr <= out_gcm_gcl_addr + 1'b1;  
                end
			    gcm_state <= IDLE_S;    
		    end
            default:begin
                out_gcm_gcl_rd <= 1'b0;
                gcm_state <= IDLE_S;  
            end
	    endcase
    end     
end 
//************************************************************
//    judge whether request of traffic generation is valid
//************************************************************
always@(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        out_gcm_valid <= 8'b0;  
    end
    else begin
	    if(in_gcm_test_start == 1'b0)begin
		    out_gcm_valid <= 8'b0;
		end
		else begin
	        case(iv_time_slot[3:0]) 
                4'b0000: out_gcm_valid <= in_gcm_gc[7:0]     & req;
                4'b0001: out_gcm_valid <= in_gcm_gc[15:8]    & req;	
                4'b0010: out_gcm_valid <= in_gcm_gc[23:16]   & req;	
                4'b0011: out_gcm_valid <= in_gcm_gc[31:24]   & req;	
                4'b0100: out_gcm_valid <= in_gcm_gc[39:32]   & req;	
                4'b0101: out_gcm_valid <= in_gcm_gc[47:40]   & req;	
                4'b0110: out_gcm_valid <= in_gcm_gc[55:48]   & req;	
                4'b0111: out_gcm_valid <= in_gcm_gc[63:56]   & req;	
                4'b1000: out_gcm_valid <= in_gcm_gc[71:64]   & req;	
                4'b1001: out_gcm_valid <= in_gcm_gc[79:72]   & req;	
                4'b1010: out_gcm_valid <= in_gcm_gc[87:80]   & req;	
                4'b1011: out_gcm_valid <= in_gcm_gc[95:88]   & req;	
                4'b1100: out_gcm_valid <= in_gcm_gc[103:96]  & req;	
                4'b1101: out_gcm_valid <= in_gcm_gc[111:104] & req;	
                4'b1110: out_gcm_valid <= in_gcm_gc[119:112] & req;	
                4'b1111: out_gcm_valid <= in_gcm_gc[127:120] & req;
                default: out_gcm_valid <= 8'b0;	
            endcase
        end		
    end     
end       
endmodule
