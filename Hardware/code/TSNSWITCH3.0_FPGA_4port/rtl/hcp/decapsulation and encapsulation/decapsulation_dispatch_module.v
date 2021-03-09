// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_decapsulation_module
// Version: frame_decapsulation_module_V1.0
// Created:
//         by - Wu Shangming & peng jintao  Lian He Chu Pin
//         at - 01.2021
////////////////////////////////////////////////////////////////////////////
// Description:
//         - decapsulate TSMP frame to ARP ack frame、PTP frame、NMAC configuration frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module decapsulation_dispatch_module
(
        i_clk,
        i_rst_n,

        i_timer_rst,
        iv_syned_global_time,
       
        iv_data,
        iv_descriptor,
	    i_data_wr,
	    
	    ov_data2csm,
	    o_data2csm_wr,

        ov_data2mux,
        o_data2mux_wr,

        ov_dmac,
        ov_smac
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n; 

input                  i_timer_rst;
input      [47:0]      iv_syned_global_time; 
// pkt input
input	   [8:0]	   iv_data;
input      [34:0]      iv_descriptor;
input	         	   i_data_wr;
// pkt output to MUX or CSM
output reg [8:0]	   ov_data2csm;
output reg	           o_data2csm_wr;

output reg [8:0]	   ov_data2mux;
output reg	           o_data2mux_wr;
// dst_mac & src_mac 2 FEM
output reg [47:0]      ov_dmac;
output reg [47:0]      ov_smac;

reg    [18:0]          rv_timer;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
        rv_timer    <= 19'b0;
    end
    else begin
        if(i_timer_rst == 1'b1)begin
            rv_timer <= 19'b0;
        end
        else begin
            if(rv_timer == 19'd499999) begin //4ms
                rv_timer <= 19'b0;
            end
            else begin
                rv_timer <= rv_timer + 1'b1;
            end            
        end
    end
end
//***************************************************
//               decapsulating frame
//***************************************************
// internal reg&wire for state machine
reg  [3:0]  fdm_state;
reg  [6:0]  rv_cycle_cnt;
reg  [7:0]  rv_pkt_subtype;

reg  [18:0] rv_transmit_time;
reg  [47:0] rv_global_time;

reg [47:0]  rv_dmac;
reg [47:0]  rv_smac;
localparam  IDLE_S = 3'd0,
            TRANS_TO_CSM_S = 3'd1,
            TRANS_TO_MUX_S = 3'd2,
            TRANS_FIRST_CYCLE_TO_CSM_S = 3'd3,
            PROCESS_PTP_S = 3'd4,
            PROCESS_NOT_PTP_S = 3'd5,
            TRANS_FIRST_CYCLE_TO_MUX_S = 3'd6;

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data2csm <= 9'b0;
		o_data2csm_wr <= 1'b0;
        
        ov_data2mux <=9'b0;
        o_data2mux_wr <= 1'b0;

        ov_dmac <=48'b0;
        ov_smac <=48'b0;

        rv_dmac <=48'b0;
        rv_smac <=48'b0;
        
        rv_cycle_cnt <= 7'b0;
        rv_pkt_subtype <= 8'b0;
        
        rv_transmit_time <= 19'b0;
        rv_global_time <= 48'b0;

		fdm_state <= IDLE_S;
    end
    else begin
		case(fdm_state)
			IDLE_S:begin
                ov_data2csm <= 9'b0;
		        o_data2csm_wr <= 1'b0;              
                ov_data2mux <= 9'b0;
                o_data2mux_wr <= 1'b0;                               
				if(i_data_wr == 1'b1)begin//first cycle;discard the cycle and choose module                   
                    rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                end
                else begin
                    ov_dmac <= ov_dmac;
                    rv_cycle_cnt <= 7'b0;
                end

                if(rv_cycle_cnt <= 7'd5)begin
                    rv_dmac <= {rv_dmac[39:0],iv_data[7:0]};
                end
                else begin
                    rv_dmac <= rv_dmac;
                end
                
                if((rv_cycle_cnt > 7'd5)&&(rv_cycle_cnt <= 7'd11))begin
                    rv_smac <= {rv_smac[39:0],iv_data[7:0]};
                end
                else begin
                    rv_smac <= rv_smac;
                end    
                    
                if(rv_cycle_cnt == 7'd14)begin
                    rv_pkt_subtype <= iv_data[7:0];
                    fdm_state <= IDLE_S;
                end   
                else if(rv_cycle_cnt == 7'd15)begin
                    if(rv_pkt_subtype == 8'h2)begin
                        ov_dmac <= rv_dmac;
                        ov_smac <= rv_smac;                        
                        fdm_state <= TRANS_FIRST_CYCLE_TO_CSM_S;
                    end
                    else begin
                        fdm_state <= TRANS_FIRST_CYCLE_TO_MUX_S;
                    end
                end
                else begin 
                    fdm_state <= IDLE_S;    
                end
            end
            TRANS_FIRST_CYCLE_TO_CSM_S:begin
                ov_data2csm <= {1'b1,iv_data[7:0]};
                o_data2csm_wr <= i_data_wr;
                rv_cycle_cnt <= 7'd1;
                fdm_state <= TRANS_TO_CSM_S;
            end
            TRANS_TO_CSM_S:begin
                ov_data2csm <= iv_data;
                o_data2csm_wr <= i_data_wr;          
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin
                    fdm_state <= IDLE_S; 
                end
                else begin
                    fdm_state <= TRANS_TO_CSM_S; 
                end 
            end  
            TRANS_FIRST_CYCLE_TO_MUX_S:begin
                ov_data2mux <= {1'b1,iv_data[7:0]};
                o_data2mux_wr <= i_data_wr;
                if((iv_descriptor[15:0] == 16'hff01) && (rv_pkt_subtype == 8'h5))begin
                    rv_transmit_time <= rv_timer;
                    rv_global_time <= iv_syned_global_time;
                    rv_cycle_cnt <= 7'd1;
                    fdm_state <= PROCESS_PTP_S; 
                end
                else begin
                    fdm_state <= PROCESS_NOT_PTP_S; 
                end                  
            end            
            PROCESS_NOT_PTP_S:begin
                ov_data2mux <= iv_data;
                o_data2mux_wr <= i_data_wr;          
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin
                    fdm_state <= IDLE_S; 
                end
                else begin
                    fdm_state <= PROCESS_NOT_PTP_S; 
                end 
            end
            PROCESS_PTP_S:begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'd1;                
                if(rv_cycle_cnt <= 7'd57)begin
                    case(rv_cycle_cnt)
                        7'd3:begin
                            ov_data2mux <= {iv_data[8:3],rv_transmit_time[18:16]};
                            o_data2mux_wr <= i_data_wr;                        
                        end
                        7'd4:begin
                            ov_data2mux <= {1'b0,rv_transmit_time[15:8]};
                            o_data2mux_wr <= i_data_wr;                         
                        end 
                        7'd5:begin
                            ov_data2mux <= {1'b0,rv_transmit_time[7:0]};
                            o_data2mux_wr <= i_data_wr;                         
                        end
                        7'd52:begin
                            ov_data2mux <= {1'b0,rv_global_time[47:40]};
                            o_data2mux_wr <= i_data_wr;                         
                        end
                        7'd53:begin
                            ov_data2mux <= {1'b0,rv_global_time[39:32]};
                            o_data2mux_wr <= i_data_wr;                         
                        end
                        7'd54:begin
                            ov_data2mux <= {1'b0,rv_global_time[31:24]};
                            o_data2mux_wr <= i_data_wr;                         
                        end
                        7'd55:begin
                            ov_data2mux <= {1'b0,rv_global_time[23:16]};
                            o_data2mux_wr <= i_data_wr;                         
                        end 
                        7'd56:begin
                            ov_data2mux <= {1'b0,rv_global_time[15:8]};
                            o_data2mux_wr <= i_data_wr;                         
                        end
                        7'd57:begin
                            ov_data2mux <= {1'b0,rv_global_time[7:0]};
                            o_data2mux_wr <= i_data_wr;                         
                        end                           
                        default:begin                
                            ov_data2mux <= iv_data;
                            o_data2mux_wr <= i_data_wr;                        
                        end
                    endcase
                end
                else begin
                    ov_data2mux <= iv_data;
                    o_data2mux_wr <= i_data_wr;                   
                    if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin
                        fdm_state <= IDLE_S; 
                    end
                    else begin
                        fdm_state <= PROCESS_PTP_S; 
                    end
                end                    
            end           
			default:begin
                ov_data2csm <= 9'b0;
                o_data2csm_wr <= 1'b0;
                
                ov_data2mux <= 9'b0;
                o_data2mux_wr <= 1'b0;                
                fdm_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule