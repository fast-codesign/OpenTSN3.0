// Copyright (C) 1953-2020 NUDT
// Verilog module name - nmac_parse_module 
// Version: NPM_V1.0
// Created:
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         parse NMAC pkt 
//         configure the regist
//         configure the RAM
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module nmac_parse_module
(
       i_clk,
       i_rst_n,

       iv_data,
       i_data_wr,   
       
       i_reg_rst,
       ov_time_offset,
       o_time_offset_wr,
       ov_cfg_finish,
       ov_slot_len,
       ov_inject_slot_period,
       
       ov_offset_period,
       ov_report_period,
       
       ov_nmac_dmac,
       ov_nmac_smac
);


// I/O
// i_clk & rst
input                  i_clk;
input                  i_rst_n;
input                  i_reg_rst;     
//nmac data
input      [133:0]     iv_data;               // input nmac data
input                  i_data_wr;             // nmac writer signals
//configure regist
output reg [48:0]      ov_time_offset;
output reg             o_time_offset_wr;
output reg [1:0]       ov_cfg_finish;
output reg [10:0]      ov_slot_len;
output reg [10:0]      ov_inject_slot_period;
output reg [23:0]      ov_offset_period;
output reg [11:0]      ov_report_period;
// NMAC DMAC and SMAC
output reg [47:0]      ov_nmac_dmac;
output reg [47:0]      ov_nmac_smac;

reg        [7:0]       rv_configure_cnt;
reg        [19:0]      rv_configure_addr;
//////////////////////////////////////////////////
//                  state                       //
//////////////////////////////////////////////////
reg     [3:0]         npm_state;
localparam            RESET_S = 4'd0,
                      IDLE_S = 4'd1,
                      DISC_MD1_S = 4'd2,
                      EXACT_MAC_S = 4'd3,
                      EXACT_COUNT_S = 4'd4,
                      EXACT_REG1_S = 4'd5,
                      EXACT_REG2_S = 4'd6;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin        
        ov_offset_period <= 24'h0;
        ov_time_offset   <= 49'h0;
        o_time_offset_wr <= 1'h0;
        ov_cfg_finish <= 2'h1;
        ov_slot_len <= 11'h4;
        ov_inject_slot_period <= 11'h4;
        ov_report_period <= 12'h1;
        ov_nmac_smac <= 48'hffffffffffff;
        ov_nmac_dmac <= 48'hffffffffffff;

        rv_configure_cnt <= 8'h0;
        rv_configure_addr <= 20'd0;
        npm_state <= IDLE_S;
    end
    else begin
        case(npm_state) 
            /*RESET_S:begin
                //ov_offset_period <= 24'h0;
                ov_time_offset   <= 49'h0;
                o_time_offset_wr <= 1'h0;
                //ov_cfg_finish <= 2'h1;
                //ov_slot_len <= 11'h4;
                //ov_inject_slot_period <= 11'h4;
                //ov_report_period <= 12'h1;
                //ov_nmac_smac <= 48'hffffffffffff;
                //ov_nmac_dmac <= 48'hffffffffffff;
                
                rv_configure_cnt <= 8'h0;
                rv_configure_addr <= 20'd0;            
                if(i_reg_rst)begin
                    npm_state <= RESET_S;
                end
                else begin
                    npm_state <= IDLE_S;                
                end
            end*/            
            IDLE_S:begin // receive the nmac pkt                    
                o_time_offset_wr <= 1'h0;
                
                rv_configure_addr<= 20'd0;
                rv_configure_cnt <= 8'h0;                 
                /*if(i_reg_rst)begin
                    npm_state <= RESET_S;
                end
                else begin
                    if((i_data_wr == 1'b1)&&(iv_data[133:132] == 2'b01))begin
                        npm_state <= DISC_MD1_S;
                    end
                    else begin
                        npm_state <= IDLE_S;
                    end
                end*/
				if((i_data_wr == 1'b1)&&(iv_data[133:132] == 2'b01))begin
					npm_state <= DISC_MD1_S;
				end
				else begin
					npm_state <= IDLE_S;
				end
            end
            DISC_MD1_S:begin //                                                      npm_state <= DISC_MD1_S;
                npm_state     <= EXACT_MAC_S;
            end            
            EXACT_MAC_S:begin//TSMP HEADER                             
                ov_nmac_dmac <= iv_data[127:80];
                ov_nmac_smac <= iv_data[79:32];
                npm_state     <= EXACT_COUNT_S;
            end             
            EXACT_COUNT_S:begin  // record the namc pkt configure count
                rv_configure_cnt <= iv_data[15:8];
                npm_state <= EXACT_REG1_S;
            end
            EXACT_REG1_S:begin // record the nmac pkt configure regist addr
                if(iv_data[122:116] == 7'd0)begin
                    if(iv_data[115:96] == 20'd0)begin
                        if(rv_configure_cnt == 8'd1)begin
                            ov_time_offset[31:0] <= iv_data[95:64];
                            o_time_offset_wr <= 1'b0;                             
                        end                        
                        else if(rv_configure_cnt == 8'd2)begin
                            ov_time_offset[31:0] <= iv_data[95:64];
                            ov_time_offset[48:32] <= iv_data[48:32];
                            o_time_offset_wr <= 1'b1;                             
                        end
                        else if(rv_configure_cnt >= 8'd3)begin
                            ov_time_offset[31:0] <= iv_data[95:64];
                            ov_time_offset[48:32] <= iv_data[48:32];
                            o_time_offset_wr <= 1'b1; 
                            ov_slot_len <= iv_data[10:0];                            
                        end
                        else begin
                            o_time_offset_wr <= 1'b0;  
                        end
                    end
                    else if(iv_data[115:96] == 20'd1)begin
                        if(rv_configure_cnt == 8'd1)begin                         
                            ov_time_offset[48:32] <= iv_data[80:64];
                            o_time_offset_wr <= 1'b1;
                        end
                        else if(rv_configure_cnt == 8'd2)begin                         
                            ov_time_offset[48:32] <= iv_data[80:64];
                            o_time_offset_wr <= 1'b1;
                            ov_slot_len <= iv_data[42:32];
                        end
                        else if(rv_configure_cnt >= 8'd3)begin 
                            ov_time_offset[48:32] <= iv_data[80:64];
                            o_time_offset_wr <= 1'b1;                        
                            ov_slot_len <= iv_data[42:32];
                            ov_cfg_finish <= iv_data[1:0];  
                        end                           
                        else begin                         
                            o_time_offset_wr <= 1'b0; 
                        end                            
                    end
                    else if(iv_data[115:96] == 20'd2)begin
                        if(rv_configure_cnt == 8'd1)begin
                            ov_slot_len <= iv_data[74:64];
                        end
                        else if(rv_configure_cnt >= 8'd2)begin
                            ov_slot_len <= iv_data[74:64];
                            ov_cfg_finish <= iv_data[33:32];
                        end
                        else begin
                            ov_cfg_finish <= ov_cfg_finish;
                        end                         
                    end
                    else if(iv_data[115:96] == 20'd3)begin//configure cfg_finish regist
                        if(rv_configure_cnt >= 8'd1)begin
                            ov_cfg_finish <= iv_data[65:64];   
                        end
                        else begin
                            ov_cfg_finish <= ov_cfg_finish;
                        end                        
                    end
                    else if(iv_data[115:96] == 20'd8)begin
                        if(rv_configure_cnt == 8'd1)begin
                            ov_inject_slot_period <= iv_data[74:64];
                        end
                        else if(rv_configure_cnt >= 8'd3)begin
                            ov_inject_slot_period <= iv_data[74:64];
                            ov_report_period <= iv_data[11:0];                         
                        end
                        else begin
                            ov_report_period <= ov_report_period;   
                        end                        
                    end
                    else if(iv_data[115:96] == 20'd10)begin
                        if(rv_configure_cnt == 8'd1)begin
                            ov_report_period <= iv_data[75:64];
                        end
                        else if(rv_configure_cnt >= 8'd2)begin
                            ov_report_period <= iv_data[75:64];
                            ov_offset_period <= iv_data[55:32];                    
                        end
                        else begin
                            ov_offset_period <= ov_offset_period;   
                        end                                                   
                    end                    
                    else if(iv_data[115:96] == 20'd11)begin
                        if(rv_configure_cnt >= 8'd1)begin
                            ov_offset_period <= iv_data[87:64];
                        end
                        else begin
                            ov_offset_period <= ov_offset_period;
                        end                        
                    end
                    else begin
                        ov_offset_period <= ov_offset_period;  
                    end
                    
                    if(rv_configure_cnt <= 8'd3)begin
                        rv_configure_cnt <= 8'h0;
                        rv_configure_addr <= 20'd0;  
                        npm_state <= IDLE_S;
                    end
                    else begin
                        rv_configure_cnt <= rv_configure_cnt - 8'd3;
                        rv_configure_addr <= rv_configure_addr + 20'd3;  
                        npm_state <= EXACT_REG2_S;  
                    end                    
                end
                else begin
                    npm_state <= IDLE_S;  
                end
            end
            EXACT_REG2_S:begin  
                o_time_offset_wr <= 1'b0;
                if(rv_configure_addr == 20'd3)begin 
                    ov_cfg_finish <= iv_data[97:96];                       
                end
                else if(rv_configure_addr == 20'd5)begin
                    if(rv_configure_cnt >= 8'd4)begin
                        ov_inject_slot_period <= iv_data[10:0]; 
                    end
                    else begin
                        ov_inject_slot_period <= ov_inject_slot_period; 
                    end                    
                end
                else if(rv_configure_addr == 20'd6)begin
                    if(rv_configure_cnt >= 8'd3)begin
                        ov_inject_slot_period <= iv_data[42:32];
                    end
                    else begin
                        ov_inject_slot_period <= ov_inject_slot_period; 
                    end                    
                end
                else if(rv_configure_addr == 20'd7)begin
                    if(rv_configure_cnt >= 8'd4)begin
                        ov_inject_slot_period <= iv_data[74:64];
                        ov_report_period <= iv_data[11:0];                       
                    end
                    else if(rv_configure_cnt >= 8'd2)begin
                        ov_inject_slot_period <= iv_data[74:64];                     
                    end                    
                    else begin
                        ov_report_period <= ov_report_period; 
                        ov_inject_slot_period <= ov_inject_slot_period;                        
                    end                    
                end                
                else if(rv_configure_addr == 20'd8)begin
                    ov_inject_slot_period <= iv_data[104:94];
                    if(rv_configure_cnt >= 8'd4)begin
                        ov_report_period <= iv_data[43:32];  
                        ov_offset_period <= iv_data[23:0];                          
                    end
                    else if(rv_configure_cnt >= 8'd3)begin
                        ov_report_period <= iv_data[43:32];                         
                    end
                    else begin
                        ov_report_period <= ov_report_period; 
                        ov_offset_period <= ov_offset_period;                         
                    end                        
                end
                else if(rv_configure_addr == 20'd9)begin
                    if(rv_configure_cnt >= 8'd3)begin
                        ov_report_period <= iv_data[75:64]; 
                        ov_offset_period <= iv_data[55:32];                          
                    end
                    else if(rv_configure_cnt >= 8'd2)begin
                        ov_report_period <= iv_data[75:64];                     
                    end
                    else begin
                        ov_report_period <= ov_report_period; 
                        ov_offset_period <= ov_offset_period;                         
                    end                        
                end
                else if(rv_configure_addr == 20'd10)begin
                    ov_report_period <= iv_data[107:96];
                    if(rv_configure_cnt >= 8'd2)begin
                        ov_offset_period <= iv_data[87:64];                    
                    end
                    else begin
                        ov_offset_period <= ov_offset_period;   
                    end                                                   
                end                    
                else if(rv_configure_addr == 20'd11)begin
                    ov_offset_period <= iv_data[87:64];                                               
                end
                else begin
                    ov_offset_period <= ov_offset_period;  
                end
                
                if(rv_configure_cnt <= 8'd4)begin
                    rv_configure_cnt <= 8'h0;
                    rv_configure_addr <= 20'd0;  
                    npm_state <= IDLE_S;
                end
                else begin
                    rv_configure_cnt <= rv_configure_cnt - 8'd4;
                    rv_configure_addr <= rv_configure_addr + 20'd4;  
                    npm_state <= EXACT_REG2_S;  
                end                    
            end            
            default:begin
                npm_state <= IDLE_S;
            end
        endcase
    end
end    

endmodule
    