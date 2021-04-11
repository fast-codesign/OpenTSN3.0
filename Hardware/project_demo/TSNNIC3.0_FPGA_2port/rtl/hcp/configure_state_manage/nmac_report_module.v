// Copyright (C) 1953-2020 NUDT
// Verilog module name - nmac_report_module 
// Version: nrm_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         report NMAC pkt 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module nmac_report_module 
(
       i_clk,
       i_rst_n,
       
       iv_nmac_dmac,
       iv_nmac_smac,
       
       ov_rd_command,
	   o_rd_command_wr, 
       iv_rd_command_ack,       
       
       iv_host_inpkt_cnt,
       iv_host_discard_pkt_cnt,
       iv_port0_inpkt_cnt,
       iv_port0_discard_pkt_cnt,
       iv_port1_inpkt_cnt,
       iv_port1_discard_pkt_cnt,
       iv_port2_inpkt_cnt,
       iv_port2_discard_pkt_cnt,
       iv_port3_inpkt_cnt,
       iv_port3_discard_pkt_cnt,
       iv_port4_inpkt_cnt,
       iv_port4_discard_pkt_cnt,
       iv_port5_inpkt_cnt,
       iv_port5_discard_pkt_cnt,
       iv_port6_inpkt_cnt,
       iv_port6_discard_pkt_cnt,
       iv_port7_inpkt_cnt,
       iv_port7_discard_pkt_cnt,
        
       iv_host_outpkt_cnt,
       iv_host_in_queue_discard_cnt,
       iv_port0_outpkt_cnt,
       iv_port1_outpkt_cnt,
       iv_port2_outpkt_cnt,
       iv_port3_outpkt_cnt,
       iv_port4_outpkt_cnt,
       iv_port5_outpkt_cnt,
       iv_port6_outpkt_cnt,
       iv_port7_outpkt_cnt,
       
       o_statistic_rst,
       
       ov_nmac_data,
       o_nmac_data_last,
       o_namc_report_req,
       i_nmac_report_ack,
       i_report_pulse,
       
       iv_nmac_receive_cnt,
       iv_nmac_report_cnt,
       iv_ts_inj_underflow_error_cnt,
       iv_ts_inj_overflow_error_cnt,
       iv_ts_sub_underflow_error_cnt,
       iv_ts_sub_overflow_error_cnt,

       iv_pkt_state,
       iv_transmission_state,
       iv_prp_state,
       iv_descriptor_state,
       iv_tim_state,
       iv_tom_state,
       iv_ism_state,
       iv_pkt_read_state,
       
       iv_hos_state,
       iv_hoi_state,
       iv_tsm_state,
       iv_bufid_state,
       iv_pdi_state,
       iv_smm_state,
       
       iv_tdm_state,

       iv_osc_state_p0,
       iv_prc_state_p0,
       iv_gmii_read_state_p0,
       iv_opc_state_p0,
       i_gmii_fifo_full_p0,
       i_gmii_fifo_empty_p0,
       iv_descriptor_extract_state_p0,
       iv_descriptor_send_state_p0,
       iv_data_splice_state_p0,
       iv_input_buf_interface_state_p0,
       
       iv_osc_state_p1,
       iv_prc_state_p1,
       iv_gmii_read_state_p1,
       iv_opc_state_p1,
       i_gmii_fifo_full_p1,
       i_gmii_fifo_empty_p1,
       iv_descriptor_extract_state_p1,
       iv_descriptor_send_state_p1,
       iv_data_splice_state_p1,
       iv_input_buf_interface_state_p1,
       
       iv_osc_state_p2,
       iv_prc_state_p2,
       iv_gmii_read_state_p2,
       iv_opc_state_p2,
       i_gmii_fifo_full_p2,
       i_gmii_fifo_empty_p2,
       iv_descriptor_extract_state_p2,
       iv_descriptor_send_state_p2,
       iv_data_splice_state_p2,
       iv_input_buf_interface_state_p2,
       
       iv_osc_state_p3,
       iv_prc_state_p3,
       iv_gmii_read_state_p3,
       iv_opc_state_p3,
       i_gmii_fifo_full_p3,
       i_gmii_fifo_empty_p3,
       iv_descriptor_extract_state_p3,
       iv_descriptor_send_state_p3,
       iv_data_splice_state_p3,
       iv_input_buf_interface_state_p3,
       
       iv_osc_state_p4,
       iv_prc_state_p4,
       iv_gmii_read_state_p4,
       iv_opc_state_p4,
       i_gmii_fifo_full_p4,
       i_gmii_fifo_empty_p4,
       iv_descriptor_extract_state_p4,
       iv_descriptor_send_state_p4,
       iv_data_splice_state_p4,
       iv_input_buf_interface_state_p4,
       
       iv_osc_state_p5,
       iv_prc_state_p5,
       iv_gmii_read_state_p5,
       iv_opc_state_p5,
       i_gmii_fifo_full_p5,
       i_gmii_fifo_empty_p5,
       iv_descriptor_extract_state_p5,
       iv_descriptor_send_state_p5,
       iv_data_splice_state_p5,
       iv_input_buf_interface_state_p5,
       
       iv_osc_state_p6,
       iv_prc_state_p6,
       iv_gmii_read_state_p6,
       iv_opc_state_p6,
       i_gmii_fifo_full_p6,
       i_gmii_fifo_empty_p6,
       iv_descriptor_extract_state_p6,
       iv_descriptor_send_state_p6,
       iv_data_splice_state_p6,
       iv_input_buf_interface_state_p6,
       
       iv_osc_state_p7,
       iv_prc_state_p7,
       iv_gmii_read_state_p7,
       iv_opc_state_p7,
       i_gmii_fifo_full_p7,
       i_gmii_fifo_empty_p7,
       iv_descriptor_extract_state_p7,
       iv_descriptor_send_state_p7,
       iv_data_splice_state_p7,
       iv_input_buf_interface_state_p7,
       
       iv_pkt_write_state,
       iv_pcb_pkt_read_state,
       iv_address_write_state,
       iv_address_read_state,
       iv_free_buf_fifo_rdusedw,
       
       iv_time_offset,
       iv_cfg_finish,
       iv_port_type,
       iv_slot_len,
       iv_inject_slot_period,
       iv_submit_slot_period,
       i_qbv_or_qch,
       iv_report_period,
       iv_report_type,
       i_report_en,
       iv_offset_period,         
       iv_rc_regulation_value,   
       iv_be_regulation_value,   
       iv_unmap_regulation_value,
          
       iv_rdata,
       ov_raddr,
       ov_rd,       
      
       o_nmac_report_pulse
);

// clk & rst
input                  i_clk;
input                  i_rst_n;

input     [47:0]       iv_nmac_dmac;
input     [47:0]       iv_nmac_smac;

output reg[203:0]	   ov_rd_command;
output reg	           o_rd_command_wr;
input     [203:0]	   iv_rd_command_ack;
// pkt Statistic
input     [15:0]       iv_host_inpkt_cnt;
input     [15:0]       iv_host_discard_pkt_cnt;
input     [15:0]       iv_port0_inpkt_cnt;
input     [15:0]       iv_port0_discard_pkt_cnt;
input     [15:0]       iv_port1_inpkt_cnt;
input     [15:0]       iv_port1_discard_pkt_cnt;
input     [15:0]       iv_port2_inpkt_cnt;
input     [15:0]       iv_port2_discard_pkt_cnt;
input     [15:0]       iv_port3_inpkt_cnt;
input     [15:0]       iv_port3_discard_pkt_cnt;
input     [15:0]       iv_port4_inpkt_cnt;
input     [15:0]       iv_port4_discard_pkt_cnt;
input     [15:0]       iv_port5_inpkt_cnt;
input     [15:0]       iv_port5_discard_pkt_cnt;
input     [15:0]       iv_port6_inpkt_cnt;
input     [15:0]       iv_port6_discard_pkt_cnt;
input     [15:0]       iv_port7_inpkt_cnt;
input     [15:0]       iv_port7_discard_pkt_cnt;
                        
input     [15:0]       iv_host_outpkt_cnt;
input     [15:0]       iv_host_in_queue_discard_cnt;
input     [15:0]       iv_port0_outpkt_cnt;
input     [15:0]       iv_port1_outpkt_cnt;
input     [15:0]       iv_port2_outpkt_cnt;
input     [15:0]       iv_port3_outpkt_cnt;
input     [15:0]       iv_port4_outpkt_cnt;
input     [15:0]       iv_port5_outpkt_cnt;
input     [15:0]       iv_port6_outpkt_cnt;
input     [15:0]       iv_port7_outpkt_cnt;

output reg             o_statistic_rst;

// nmac report data to host_tx
output reg[7:0]        ov_nmac_data;
output reg             o_nmac_data_last;
output reg             o_namc_report_req;
input                  i_nmac_report_ack;
input                  i_report_pulse;

// others module state
input     [15:0]       iv_nmac_receive_cnt;
input     [15:0]       iv_nmac_report_cnt;
input     [15:0]       iv_ts_inj_underflow_error_cnt;
input     [15:0]       iv_ts_inj_overflow_error_cnt;
input     [15:0]       iv_ts_sub_underflow_error_cnt;
input     [15:0]       iv_ts_sub_overflow_error_cnt;

input     [2:0]        iv_pkt_state;
input     [2:0]        iv_transmission_state;
input     [1:0]        iv_prp_state;
input     [2:0]        iv_descriptor_state;
input     [2:0]        iv_tim_state;
input     [1:0]        iv_tom_state;
input     [2:0]        iv_ism_state;
input     [2:0]        iv_pkt_read_state;

input     [1:0]        iv_hos_state;
input     [3:0]        iv_hoi_state;
input     [2:0]        iv_tsm_state;
input     [1:0]        iv_bufid_state;
input     [2:0]        iv_pdi_state;
input     [2:0]        iv_smm_state;
input     [3:0]        iv_tdm_state;


input     [1:0]        iv_osc_state_p0;
input     [1:0]        iv_prc_state_p0;
input     [1:0]        iv_gmii_read_state_p0;
input     [2:0]        iv_opc_state_p0;
input                  i_gmii_fifo_full_p0;
input                  i_gmii_fifo_empty_p0;
input     [3:0]        iv_descriptor_extract_state_p0;
input     [1:0]        iv_descriptor_send_state_p0;
input     [1:0]        iv_data_splice_state_p0;
input     [1:0]        iv_input_buf_interface_state_p0;

input     [1:0]        iv_osc_state_p1;
input     [1:0]        iv_prc_state_p1;
input     [1:0]        iv_gmii_read_state_p1;
input     [2:0]        iv_opc_state_p1;
input                  i_gmii_fifo_full_p1;
input                  i_gmii_fifo_empty_p1;
input     [3:0]        iv_descriptor_extract_state_p1;
input     [1:0]        iv_descriptor_send_state_p1;
input     [1:0]        iv_data_splice_state_p1;
input     [1:0]        iv_input_buf_interface_state_p1;

input     [1:0]        iv_osc_state_p2;
input     [1:0]        iv_prc_state_p2;
input     [1:0]        iv_gmii_read_state_p2;
input     [2:0]        iv_opc_state_p2;
input                  i_gmii_fifo_full_p2;
input                  i_gmii_fifo_empty_p2;
input     [3:0]        iv_descriptor_extract_state_p2;
input     [1:0]        iv_descriptor_send_state_p2;
input     [1:0]        iv_data_splice_state_p2;
input     [1:0]        iv_input_buf_interface_state_p2;

input     [1:0]        iv_osc_state_p3;
input     [1:0]        iv_prc_state_p3;
input     [1:0]        iv_gmii_read_state_p3;
input     [2:0]        iv_opc_state_p3;
input                  i_gmii_fifo_full_p3;
input                  i_gmii_fifo_empty_p3;
input     [3:0]        iv_descriptor_extract_state_p3;
input     [1:0]        iv_descriptor_send_state_p3;
input     [1:0]        iv_data_splice_state_p3;
input     [1:0]        iv_input_buf_interface_state_p3;

input     [1:0]        iv_osc_state_p4;
input     [1:0]        iv_prc_state_p4;
input     [1:0]        iv_gmii_read_state_p4;
input     [2:0]        iv_opc_state_p4;
input                  i_gmii_fifo_full_p4;
input                  i_gmii_fifo_empty_p4;
input     [3:0]        iv_descriptor_extract_state_p4;
input     [1:0]        iv_descriptor_send_state_p4;
input     [1:0]        iv_data_splice_state_p4;
input     [1:0]        iv_input_buf_interface_state_p4;

input     [1:0]        iv_osc_state_p5;
input     [1:0]        iv_prc_state_p5;
input     [1:0]        iv_gmii_read_state_p5;
input     [2:0]        iv_opc_state_p5;
input                  i_gmii_fifo_full_p5;
input                  i_gmii_fifo_empty_p5;
input     [3:0]        iv_descriptor_extract_state_p5;
input     [1:0]        iv_descriptor_send_state_p5;
input     [1:0]        iv_data_splice_state_p5;
input     [1:0]        iv_input_buf_interface_state_p5;

input     [1:0]        iv_osc_state_p6;
input     [1:0]        iv_prc_state_p6;
input     [1:0]        iv_gmii_read_state_p6;
input     [2:0]        iv_opc_state_p6;
input                  i_gmii_fifo_full_p6;
input                  i_gmii_fifo_empty_p6;
input     [3:0]        iv_descriptor_extract_state_p6;
input     [1:0]        iv_descriptor_send_state_p6;
input     [1:0]        iv_data_splice_state_p6;
input     [1:0]        iv_input_buf_interface_state_p6;

input     [1:0]        iv_osc_state_p7;
input     [1:0]        iv_prc_state_p7;
input     [1:0]        iv_gmii_read_state_p7;
input     [2:0]        iv_opc_state_p7;
input                  i_gmii_fifo_full_p7;
input                  i_gmii_fifo_empty_p7;
input     [3:0]        iv_descriptor_extract_state_p7;
input     [1:0]        iv_descriptor_send_state_p7;
input     [1:0]        iv_data_splice_state_p7;
input     [1:0]        iv_input_buf_interface_state_p7;

input     [3:0]        iv_pkt_write_state;
input     [3:0]        iv_pcb_pkt_read_state;
input     [3:0]        iv_address_write_state;
input     [3:0]        iv_address_read_state;
input     [8:0]        iv_free_buf_fifo_rdusedw;

input     [48:0]       iv_time_offset;
input     [1:0]        iv_cfg_finish;
input     [7:0]        iv_port_type;
input     [10:0]       iv_slot_len;
input     [10:0]       iv_inject_slot_period;
input     [10:0]       iv_submit_slot_period;
input                  i_qbv_or_qch;
input     [11:0]       iv_report_period;
input     [15:0]       iv_report_type;
input                  i_report_en;
input     [23:0]       iv_offset_period;         
input     [8:0]        iv_rc_regulation_value;   
input     [8:0]        iv_be_regulation_value;  
input     [8:0]        iv_unmap_regulation_value;

output reg             o_nmac_report_pulse;//for report cnt
//report RAM
output reg [15:0]      ov_raddr;
input      [15:0]      iv_rdata;
output reg [10:0]      ov_rd;

reg        [7:0]       rv_report_cnt;
reg                    r_ram_byte;
reg        [10:0]      rv_rd_regist;
//////////////////////////////////////////////////
//                  state                       //
//////////////////////////////////////////////////
reg     [3:0]         nrm_state;
localparam            IDLE_S           = 4'd0,
                      WITE_S           = 4'd1,
                      DMAC_S           = 4'd2,
                      SMAC_S           = 4'd3,
                      ETH_S            = 4'd4,
                      REGIST_S         = 4'd5,
                      STATE_S          = 4'd6,
                      REPORT_S         = 4'd7,
                      REPORT_MAPPING_TABLE_S = 4'd8,
                      REPORT_INVERSE_MAPPING_TABLE_S = 4'd9,
                      WAIT_S           = 4'd10;
                              
                      
 always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin 
        o_statistic_rst <= 1'b0;
        ov_raddr        <= 16'h0;
        ov_rd           <= 11'h0;
        rv_rd_regist    <= 11'h0;
        rv_report_cnt   <= 8'h0;
        r_ram_byte      <= 1'b0;
        
        o_rd_command_wr <= 1'b0;
        ov_rd_command   <= 204'b0;
        
        ov_nmac_data    <= 8'h0;
        o_nmac_data_last  <= 1'h0;
        o_namc_report_req <= 1'h0;
        o_nmac_report_pulse <= 1'h0;
        
        nrm_state       <= IDLE_S;
    end
    else begin
        case(nrm_state)
            IDLE_S:begin//state report nmac pkt
                o_statistic_rst <= 1'b0;

                rv_report_cnt   <= 8'h0;
                r_ram_byte      <= 1'b0;

                o_rd_command_wr <= 1'b0;
                ov_rd_command   <= 204'b0; 
                
                ov_nmac_data    <= 8'h0;
                o_nmac_data_last  <= 1'h0;
                o_nmac_report_pulse <= 1'h0;
                if((i_report_pulse == 1'b1) && (i_report_en == 1'b1))begin//report enbale regist is high & receive report pulse single from GTS
                    o_namc_report_req <= 1'h1; //request report nmac pkt to HTP
                    nrm_state         <= WITE_S;
                end
                else begin
                    o_namc_report_req <= 1'h0;
                    nrm_state         <= IDLE_S;
                end
            end
            
            WITE_S:begin// wait report ack single from HTP
                o_nmac_data_last  <= 1'h0;
                if(i_nmac_report_ack == 1'b1)begin
                    o_nmac_report_pulse <= 1'h1;
                    o_namc_report_req <= 1'h0;
                    ov_nmac_data    <= iv_nmac_smac[47:40];
                    rv_report_cnt   <= 8'h1;
                    nrm_state       <= DMAC_S;
                end
                else begin
                    o_nmac_report_pulse <= 1'h0;
                    ov_nmac_data    <= 8'h0;
                    rv_report_cnt   <= 8'h0;
                    nrm_state       <= WITE_S;
                end
            end
            
            DMAC_S:begin//generate nmac pkt DMAC
                o_nmac_report_pulse <= 1'h0;
                if(rv_report_cnt < 8'd6)begin
                    rv_report_cnt   <= rv_report_cnt + 8'h1;
                    case(rv_report_cnt)
                        8'd1:ov_nmac_data    <= iv_nmac_smac[39:32];
                        8'd2:ov_nmac_data    <= iv_nmac_smac[31:24];
                        8'd3:ov_nmac_data    <= iv_nmac_smac[23:16];
                        8'd4:ov_nmac_data    <= iv_nmac_smac[15:8];
                        8'd5:ov_nmac_data    <= iv_nmac_smac[7:0];
                        default:ov_nmac_data    <= ov_nmac_data;
                    endcase
                    nrm_state       <= DMAC_S;
                end
                else begin
                    rv_report_cnt   <= 8'h1;
                    ov_nmac_data    <= iv_nmac_dmac[47:40];
                    nrm_state       <= SMAC_S;
                end
            end
            
            SMAC_S:begin//generate nmac pkt SMAC
                if(rv_report_cnt < 8'd5)begin
                    rv_report_cnt   <= rv_report_cnt + 8'h1;
                    case(rv_report_cnt)
                        8'd1:ov_nmac_data    <= iv_nmac_dmac[39:32];
                        8'd2:ov_nmac_data    <= iv_nmac_dmac[31:24];
                        8'd3:ov_nmac_data    <= iv_nmac_dmac[23:16];
                        8'd4:ov_nmac_data    <= iv_nmac_dmac[15:8];
                        default:ov_nmac_data    <= ov_nmac_data;
                    endcase
                    nrm_state       <= SMAC_S;
                end
                else begin//generate namc pkt data base on "iv_report_type"
                    rv_report_cnt   <= 8'h0;
                    ov_nmac_data    <= iv_nmac_dmac[7:0];
                    
                    nrm_state       <= ETH_S;
                end
            end
            
            ETH_S:begin
                if(rv_report_cnt == 8'd0)begin//generate nmac pkt Ethernet first byte
                    rv_report_cnt   <= rv_report_cnt + 8'h1;
                    ov_nmac_data    <= 8'h16;
                    nrm_state       <= ETH_S;
                    
                    if(iv_report_type[15:10] == 6'h0)begin//report regist
                        o_rd_command_wr <= 1'b0;
                        ov_rd_command[203:0] <= 204'b0;
                    end
                    else if(iv_report_type[15:10] == 6'h1)begin//report forward table                                        
                        o_rd_command_wr <= 1'b1;
                        ov_rd_command[203:196] <= 8'b0;
                        ov_rd_command[195:188] <= 8'd12;//report forward table
                        ov_rd_command[187:184] <= 4'b0010;//type:read 
                        ov_rd_command[151:0] <= 152'b0;                        
                        if((iv_report_type[9:0] == 10'd0))begin//report first block              
                            ov_rd_command[183:152] <= 32'h0;//addr
                        end
                        else begin//report others block
                            ov_rd_command[183:152] <= ({22'b0,iv_report_type[9:0]} << 5);//addr
                        end
                    end
                    else if(iv_report_type[15:10] == 6'h2)begin//report inject table
                        o_rd_command_wr <= 1'b1;
                        ov_rd_command[203:196] <= 8'b0;
                        ov_rd_command[195:188] <= 8'd1;//report inject table
                        ov_rd_command[187:184] <= 4'b0010;//type:read 
                        ov_rd_command[151:0] <= 152'b0;                           
                        if((iv_report_type[9:0] == 10'd0))begin//report first block
                            ov_rd_command[183:152] <= 32'h0;//addr
                        end
                        else begin//report others block
                            ov_rd_command[183:152] <= ({22'b0,iv_report_type[9:0]} << 5);//addr
                        end
                    end
                    else if(iv_report_type[15:10] == 6'h3)begin//report submit table
                        o_rd_command_wr <= 1'b1;
                        ov_rd_command[203:196] <= 8'b0;
                        ov_rd_command[195:188] <= 8'd2;//report submit table
                        ov_rd_command[187:184] <= 4'b0010;//type:read 
                        ov_rd_command[151:0] <= 152'b0;                         
                        if((iv_report_type[9:0] == 10'd0))begin//report first block
                            ov_rd_command[183:152] <= 32'h0;//addr
                        end
                        else begin//report others block
                            ov_rd_command[183:152] <= ({22'b0,iv_report_type[9:0]} << 5);//addr
                        end
                    end
                    else if((iv_report_type[15:10] >= 6'd4) && (iv_report_type[15:10] <= 6'd11))begin//report gate table
                        ov_rd_command[203:196] <= 8'b0;
                        ov_rd_command[187:184] <= 4'b0010;//type:read 
                        ov_rd_command[151:0] <= 152'b0;  
                        if((iv_report_type[9:0] == 10'd0))begin//report first block
                            ov_rd_command[183:152] <= 32'h0;//addr
                        end
                        else begin//report others block
                            ov_rd_command[183:152] <= ({22'b0,iv_report_type[9:0]} << 5);//addr
                        end
                        case(iv_report_type[15:10])
                            6'd4:begin//gate table of port 0 
                                ov_rd_command[195:188] <= 8'd3;
                                o_rd_command_wr <= 1'b1;
                            end
                            6'd5:begin//gate table of port 1 
                                ov_rd_command[195:188] <= 8'd4;
                                o_rd_command_wr <= 1'b1;
                            end
                            6'd6:begin//gate table of port 2 
                                ov_rd_command[195:188] <= 8'd5;
                                o_rd_command_wr <= 1'b1;
                            end
                            6'd7:begin//gate table of port 3 
                                ov_rd_command[195:188] <= 8'd6;
                                o_rd_command_wr <= 1'b1;
                            end
                            6'd8:begin//gate table of port 4 
                                ov_rd_command[195:188] <= 8'd7;
                                o_rd_command_wr <= 1'b1;
                            end
                            6'd9:begin//gate table of port 5 
                                ov_rd_command[195:188] <= 8'd8;
                                o_rd_command_wr <= 1'b1;
                            end
                            6'd10:begin//gate table of port 6 
                                ov_rd_command[195:188] <= 8'd9;
                                o_rd_command_wr <= 1'b1;
                            end
                            6'd11:begin//gate table of port 7 
                                ov_rd_command[195:188] <= 8'd10;
                                o_rd_command_wr <= 1'b1;
                            end
                            default:begin
                                ov_rd_command[195:188] <= 8'd0;
                                o_rd_command_wr <= 1'b0;
                            end
                        endcase
                    end
                    else if(iv_report_type[15:10] == 6'd12)begin//report state
                        ov_rd_command[195:188] <= 8'd0;
                        o_rd_command_wr <= 1'b0;
                    end
                    else if(iv_report_type[15:10] == 6'd13)begin//report mapping table
                        o_rd_command_wr <= 1'b0;
                        ov_rd_command[203:0] <= 204'b0; 
                    end
                    else if(iv_report_type[15:10] == 6'd14)begin//report inverse mapping table
                        o_rd_command_wr <= 1'b0;
                        ov_rd_command[203:0] <= 204'b0;
                    end                     
                    else begin//error
                        nrm_state       <= IDLE_S;
                    end                    
                end
                else if(rv_report_cnt == 8'd1)begin//generate nmac pkt Ethernet last byte
                    rv_report_cnt   <= rv_report_cnt + 8'h1;
                    ov_nmac_data    <= 8'h62;                
                    nrm_state       <= ETH_S;
                    o_rd_command_wr <= 1'b0;                       
                end
                else if(rv_report_cnt == 8'd2)begin//generate nmac pkt report type first byte
                    ov_nmac_data    <= iv_report_type[15:8];
                    rv_report_cnt   <= rv_report_cnt + 8'h1;              
                    nrm_state       <= ETH_S;
                    
                    //start read table,because read ram have two cycle delay
                    if(iv_report_type[15:10] == 6'h0)begin//report regist
                        o_rd_command_wr <= 1'b0;  
                    end
                    else if(iv_report_type[15:10] == 6'h1)begin//report lookup table
                        ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'h1;//addr
                        o_rd_command_wr <= 1'b1;  
                    end
                    else if(iv_report_type[15:10] == 6'h2)begin//report inject table
                        ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'h1;//addr
                        o_rd_command_wr <= 1'b1;  
                    end
                    else if(iv_report_type[15:10] == 6'h3)begin//report submit table
                        ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'h1;//addr
                        o_rd_command_wr <= 1'b1;  
                    end
                    else if((iv_report_type[15:10] >= 6'd4) && (iv_report_type[15:10] <= 6'd11))begin//report gate table
                        ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'h1;//addr
                        case(iv_report_type[15:10])
                            6'd4:begin//gate table of port 0 
                                o_rd_command_wr <= 1'b1;  
                            end
                            6'd5:begin//gate table of port 1 
                                o_rd_command_wr <= 1'b1; 
                            end
                            6'd6:begin//gate table of port 2 
                                o_rd_command_wr <= 1'b1; 
                            end
                            6'd7:begin//gate table of port 3 
                                o_rd_command_wr <= 1'b1; 
                            end
                            6'd8:begin//gate table of port 4 
                                o_rd_command_wr <= 1'b1; 
                            end
                            6'd9:begin//gate table of port 5 
                                o_rd_command_wr <= 1'b1; 
                            end
                            6'd10:begin//gate table of port 6 
                                o_rd_command_wr <= 1'b1; 
                            end
                            6'd11:begin//gate table of port 7 
                                o_rd_command_wr <= 1'b1;                               
                            end
                            default:begin
                                o_rd_command_wr <= 1'b0; 
                            end
                        endcase
                    end
                    else if(iv_report_type[15:10] == 6'd12)begin//report state
                        o_rd_command_wr <= 1'b0; 
                    end
                    else if(iv_report_type[15:10] == 6'd13)begin//report mapping table
                        o_rd_command_wr <= 1'b0; 
                    end 
                    else if(iv_report_type[15:10] == 6'd14)begin//report inverse mapping table
                        o_rd_command_wr <= 1'b0; 
                    end                     
                    else begin//error
                        o_rd_command_wr <= 1'b0; 
                        nrm_state       <= IDLE_S;
                    end                    
                end
                else begin//generate nmac pkt report type last byte
                    ov_nmac_data    <= iv_report_type[7:0];
                    rv_report_cnt   <= 8'h0;
                    o_rd_command_wr <= 1'b0; 
                    if(iv_report_type[15:10] == 6'h0)begin//report regist
                        nrm_state       <= REGIST_S;
                    end
                    else if(iv_report_type[15:10] == 6'h1)begin//report lookup table
                        nrm_state   <= REPORT_S;
                    end
                    else if(iv_report_type[15:10] == 6'h2)begin//report inject table
                        nrm_state   <= REPORT_S;
                    end
                    else if(iv_report_type[15:10] == 6'h3)begin//report submit table
                        nrm_state   <= REPORT_S;
                    end
                    else if((iv_report_type[15:10] >= 6'd4) && (iv_report_type[15:10] <= 6'd11))begin//report gate table
                        nrm_state   <= REPORT_S;
                    end
                    else if(iv_report_type[15:10] == 6'd12)begin//report state regist
                        nrm_state       <= STATE_S;
                        o_statistic_rst <= 1'b1;
                    end
                    else if(iv_report_type[15:10] == 6'd13)begin//report mapping table
                        nrm_state   <= REPORT_MAPPING_TABLE_S;
                    end                     
                    else if(iv_report_type[15:10] == 6'd14)begin//report inverse mapping table
                        nrm_state   <= REPORT_INVERSE_MAPPING_TABLE_S;
                    end 
                    else begin//error
                        nrm_state       <= IDLE_S;
                    end
                end
            end
            
            REGIST_S:begin//generate nmac pkt data base on regist
                o_statistic_rst   <= 1'b0;
                if(rv_report_cnt < 8'd47)begin
                    rv_report_cnt   <= rv_report_cnt + 8'h1;
                    case(rv_report_cnt)
                        8'd0:ov_nmac_data <= iv_time_offset[48:41];
                        8'd1:ov_nmac_data <= iv_time_offset[40:33];
                        8'd2:ov_nmac_data <= iv_time_offset[32:25];
                        8'd3:ov_nmac_data <= iv_time_offset[24:17];
                        8'd4:ov_nmac_data <= iv_time_offset[16:9];
                        8'd5:ov_nmac_data <= iv_time_offset[8:1];
                        8'd6:ov_nmac_data <= {iv_time_offset[0],5'd0,iv_cfg_finish};
                        
                        8'd7:ov_nmac_data <= iv_port_type;
                        8'd8:ov_nmac_data <= iv_slot_len[10:3];
                        8'd9:ov_nmac_data <= {iv_slot_len[2:0],2'd0,iv_inject_slot_period[10:8]};
                        8'd10:ov_nmac_data <= iv_inject_slot_period[7:0];
                        
                        8'd11:ov_nmac_data <= {5'd0,iv_submit_slot_period[10:8]};
                        8'd12:ov_nmac_data <= iv_submit_slot_period[7:0];
 
                        8'd13:ov_nmac_data <= {i_qbv_or_qch,3'd0,iv_report_period[11:8]};
                        8'd14:ov_nmac_data <= iv_report_period[7:0];
                        
                        8'd15:ov_nmac_data <= iv_report_type[15:8];
                        8'd16:ov_nmac_data <= iv_report_type[7:0];
                        
                        8'd17:ov_nmac_data <= iv_offset_period[23:16];
                        8'd18:ov_nmac_data <= iv_offset_period[15:8];
                        8'd19:ov_nmac_data <= iv_offset_period[7:0];
                        
                        8'd20:ov_nmac_data <= {7'h0,iv_rc_regulation_value[8]};
                        8'd21:ov_nmac_data <= iv_rc_regulation_value[7:0];
                        
                        8'd22:ov_nmac_data <= {7'h0,iv_be_regulation_value[8]};
                        8'd23:ov_nmac_data <= iv_be_regulation_value[7:0];
                        
                        8'd24:ov_nmac_data <= {7'h0,iv_unmap_regulation_value[8]};
                        8'd25:ov_nmac_data <= iv_unmap_regulation_value[7:0];
                        8'd26:ov_nmac_data <= {i_report_en,7'd0};
                        default:ov_nmac_data <= 8'd0;
                    endcase
                end
                else begin
                    ov_nmac_data      <= 8'd0;
                    o_nmac_data_last  <= 1'h1;
                    rv_report_cnt     <= 8'd0;
                    nrm_state         <= IDLE_S;
                end
            end
            
            STATE_S:begin//generate nmac pkt data base on state
                o_statistic_rst <= 1'b0;
                if(rv_report_cnt < 8'd101)begin
                    rv_report_cnt   <= rv_report_cnt + 8'h1;
                    case(rv_report_cnt)
                        8'd0:ov_nmac_data <= {iv_host_inpkt_cnt[15:8]};
                        8'd1:ov_nmac_data <= {iv_host_inpkt_cnt[7:0]};
                        8'd2:ov_nmac_data <= {iv_host_discard_pkt_cnt[15:8]};
                        8'd3:ov_nmac_data <= {iv_host_discard_pkt_cnt[7:0]};
                        8'd4:ov_nmac_data <= {iv_port0_inpkt_cnt[15:8]};
                        8'd5:ov_nmac_data <= {iv_port0_inpkt_cnt[7:0]};
                        8'd6:ov_nmac_data <= {iv_port0_discard_pkt_cnt[15:8]};
                        8'd7:ov_nmac_data <= {iv_port0_discard_pkt_cnt[7:0]};
                        8'd8:ov_nmac_data <= {iv_port1_inpkt_cnt[15:8]};
                        8'd9:ov_nmac_data <= {iv_port1_inpkt_cnt[7:0]};
                        8'd10:ov_nmac_data <= {iv_port1_discard_pkt_cnt[15:8]};
                        8'd11:ov_nmac_data <= {iv_port1_discard_pkt_cnt[7:0]};
                        8'd12:ov_nmac_data <= {iv_port2_inpkt_cnt[15:8]};
                        8'd13:ov_nmac_data <= {iv_port2_inpkt_cnt[7:0]};
                        8'd14:ov_nmac_data <= {iv_port2_discard_pkt_cnt[15:8]};
                        8'd15:ov_nmac_data <= {iv_port2_discard_pkt_cnt[7:0]};
                        8'd16:ov_nmac_data <= {iv_port3_inpkt_cnt[15:8]};
                        8'd17:ov_nmac_data <= {iv_port3_inpkt_cnt[7:0]};
                        8'd18:ov_nmac_data <= {iv_port3_discard_pkt_cnt[15:8]};
                        8'd19:ov_nmac_data <= {iv_port3_discard_pkt_cnt[7:0]};
                        8'd20:ov_nmac_data <= {iv_port4_inpkt_cnt[15:8]};
                        8'd21:ov_nmac_data <= {iv_port4_inpkt_cnt[7:0]};
                        8'd22:ov_nmac_data <= {iv_port4_discard_pkt_cnt[15:8]};
                        8'd23:ov_nmac_data <= {iv_port4_discard_pkt_cnt[7:0]};
                        8'd24:ov_nmac_data <= {iv_port5_inpkt_cnt[15:8]};
                        8'd25:ov_nmac_data <= {iv_port5_inpkt_cnt[7:0]};
                        8'd26:ov_nmac_data <= {iv_port5_discard_pkt_cnt[15:8]};
                        8'd27:ov_nmac_data <= {iv_port5_discard_pkt_cnt[7:0]};
                        8'd28:ov_nmac_data <= {iv_port6_inpkt_cnt[15:8]};
                        8'd29:ov_nmac_data <= {iv_port6_inpkt_cnt[7:0]};
                        8'd30:ov_nmac_data <= {iv_port6_discard_pkt_cnt[15:8]};
                        8'd31:ov_nmac_data <= {iv_port6_discard_pkt_cnt[7:0]};
                        8'd32:ov_nmac_data <= {iv_port7_inpkt_cnt[15:8]};
                        8'd33:ov_nmac_data <= {iv_port7_inpkt_cnt[7:0]};
                        8'd34:ov_nmac_data <= {iv_port7_discard_pkt_cnt[15:8]};
                        8'd35:ov_nmac_data <= {iv_port7_discard_pkt_cnt[7:0]};
                                                   
                        8'd36:ov_nmac_data <= {iv_host_outpkt_cnt[15:8]};
                        8'd37:ov_nmac_data <= {iv_host_outpkt_cnt[7:0]};
                        8'd38:ov_nmac_data <= {iv_host_in_queue_discard_cnt[15:8]};
                        8'd39:ov_nmac_data <= {iv_host_in_queue_discard_cnt[7:0]};
                        
                        8'd40:ov_nmac_data <= {iv_port0_outpkt_cnt[15:8]};
                        8'd41:ov_nmac_data <= {iv_port0_outpkt_cnt[7:0]};
                        8'd42:ov_nmac_data <= {iv_port1_outpkt_cnt[15:8]};
                        8'd43:ov_nmac_data <= {iv_port1_outpkt_cnt[7:0]};
                        8'd44:ov_nmac_data <= {iv_port2_outpkt_cnt[15:8]};
                        8'd45:ov_nmac_data <= {iv_port2_outpkt_cnt[7:0]};
                        8'd46:ov_nmac_data <= {iv_port3_outpkt_cnt[15:8]};
                        8'd47:ov_nmac_data <= {iv_port3_outpkt_cnt[7:0]};
                        8'd48:ov_nmac_data <= {iv_port4_outpkt_cnt[15:8]};
                        8'd49:ov_nmac_data <= {iv_port4_outpkt_cnt[7:0]};
                        8'd50:ov_nmac_data <= {iv_port5_outpkt_cnt[15:8]};
                        8'd51:ov_nmac_data <= {iv_port5_outpkt_cnt[7:0]};
                        8'd52:ov_nmac_data <= {iv_port6_outpkt_cnt[15:8]};
                        8'd53:ov_nmac_data <= {iv_port6_outpkt_cnt[7:0]};
                        8'd54:ov_nmac_data <= {iv_port7_outpkt_cnt[15:8]};
                        8'd55:ov_nmac_data <= {iv_port7_outpkt_cnt[7:0]};
                        
                        8'd56:ov_nmac_data <= {iv_nmac_receive_cnt[15:8]};
                        8'd57:ov_nmac_data <= {iv_nmac_receive_cnt[7:0]};                       
                        8'd58:ov_nmac_data <= {iv_nmac_report_cnt[15:8]};
                        8'd59:ov_nmac_data <= {iv_nmac_report_cnt[7:0]};    
                        
                        8'd60:ov_nmac_data<=  {iv_ts_inj_underflow_error_cnt[15:8]};
                        8'd61:ov_nmac_data <= {iv_ts_inj_underflow_error_cnt[7:0]};
                        8'd62:ov_nmac_data <= {iv_ts_inj_overflow_error_cnt[15:8]};
                        8'd63:ov_nmac_data <= {iv_ts_inj_overflow_error_cnt[7:0]};
                        8'd64:ov_nmac_data <= {iv_ts_sub_underflow_error_cnt[15:8]};
                        8'd65:ov_nmac_data <= {iv_ts_sub_underflow_error_cnt[7:0]};
                        8'd66:ov_nmac_data <= {iv_ts_sub_overflow_error_cnt[15:8]};
                        8'd67:ov_nmac_data <= {iv_ts_sub_overflow_error_cnt[7:0]};  
                        
                        8'd68:ov_nmac_data <= {2'd0,iv_pkt_state,iv_transmission_state};
                        8'd69:ov_nmac_data <= {iv_prp_state,iv_descriptor_state,iv_tim_state};
                        8'd70:ov_nmac_data <= {iv_tom_state,iv_ism_state,iv_pkt_read_state};
                        8'd71:ov_nmac_data <= {iv_hos_state,iv_hoi_state,2'd0};
                        8'd72:ov_nmac_data <= {iv_tsm_state,iv_bufid_state,iv_pdi_state};
                        8'd73:ov_nmac_data <= {iv_smm_state,iv_tdm_state,1'b0};     
                        
                        8'd74:ov_nmac_data <= {iv_osc_state_p0,iv_prc_state_p0,iv_gmii_read_state_p0,iv_descriptor_send_state_p0};
                        8'd75:ov_nmac_data <= {i_gmii_fifo_full_p0,i_gmii_fifo_empty_p0,iv_opc_state_p0,3'd0};
                        8'd76:ov_nmac_data <= {iv_descriptor_extract_state_p0,iv_data_splice_state_p0,iv_input_buf_interface_state_p0}; 
                        
                        8'd77:ov_nmac_data <= {iv_osc_state_p1,iv_prc_state_p1,iv_gmii_read_state_p1,iv_descriptor_send_state_p1};
                        8'd78:ov_nmac_data <= {i_gmii_fifo_full_p1,i_gmii_fifo_empty_p1,iv_opc_state_p1,3'd0};
                        8'd79:ov_nmac_data <= {iv_descriptor_extract_state_p1,iv_data_splice_state_p1,iv_input_buf_interface_state_p1};  
                        
                        8'd80:ov_nmac_data <= {iv_osc_state_p2,iv_prc_state_p2,iv_gmii_read_state_p2,iv_descriptor_send_state_p2};
                        8'd81:ov_nmac_data <= {i_gmii_fifo_full_p2,i_gmii_fifo_empty_p2,iv_opc_state_p2,3'd0};
                        8'd82:ov_nmac_data <= {iv_descriptor_extract_state_p2,iv_data_splice_state_p2,iv_input_buf_interface_state_p2};   
                        
                        8'd83:ov_nmac_data <= {iv_osc_state_p3,iv_prc_state_p3,iv_gmii_read_state_p3,iv_descriptor_send_state_p3};
                        8'd84:ov_nmac_data <= {i_gmii_fifo_full_p3,i_gmii_fifo_empty_p3,iv_opc_state_p3,3'd0};
                        8'd85:ov_nmac_data <= {iv_descriptor_extract_state_p3,iv_data_splice_state_p3,iv_input_buf_interface_state_p3}; 
                        
                        8'd86:ov_nmac_data <= {iv_osc_state_p4,iv_prc_state_p4,iv_gmii_read_state_p4,iv_descriptor_send_state_p4};
                        8'd87:ov_nmac_data <= {i_gmii_fifo_full_p4,i_gmii_fifo_empty_p4,iv_opc_state_p4,3'd0};
                        8'd88:ov_nmac_data <= {iv_descriptor_extract_state_p4,iv_data_splice_state_p4,iv_input_buf_interface_state_p4}; 
                        
                        8'd89:ov_nmac_data <= {iv_osc_state_p5,iv_prc_state_p5,iv_gmii_read_state_p5,iv_descriptor_send_state_p5};
                        8'd90:ov_nmac_data <= {i_gmii_fifo_full_p5,i_gmii_fifo_empty_p5,iv_opc_state_p5,3'd0};
                        8'd91:ov_nmac_data <= {iv_descriptor_extract_state_p5,iv_data_splice_state_p5,iv_input_buf_interface_state_p5}; 
                        
                        8'd92:ov_nmac_data <= {iv_osc_state_p6,iv_prc_state_p6,iv_gmii_read_state_p6,iv_descriptor_send_state_p6};
                        8'd93:ov_nmac_data <= {i_gmii_fifo_full_p6,i_gmii_fifo_empty_p6,iv_opc_state_p6,3'd0};
                        8'd94:ov_nmac_data <= {iv_descriptor_extract_state_p6,iv_data_splice_state_p6,iv_input_buf_interface_state_p6};  
                        
                        8'd95:ov_nmac_data <= {iv_osc_state_p7,iv_prc_state_p7,iv_gmii_read_state_p7,iv_descriptor_send_state_p7};
                        8'd96:ov_nmac_data <= {i_gmii_fifo_full_p7,i_gmii_fifo_empty_p7,iv_opc_state_p7,3'd0};
                        8'd97:ov_nmac_data <= {iv_descriptor_extract_state_p7,iv_data_splice_state_p7,iv_input_buf_interface_state_p7};  
                        
                        8'd98:ov_nmac_data <= {iv_pkt_write_state,iv_pcb_pkt_read_state};
                        8'd99:ov_nmac_data <= {iv_address_write_state,iv_address_read_state};                   
                        8'd100:ov_nmac_data <= {iv_free_buf_fifo_rdusedw[8:1]};
                        default:ov_nmac_data <= 8'd0;
                    endcase
                end
                else begin                        
                    ov_nmac_data      <= {iv_free_buf_fifo_rdusedw[0],7'h0};  
                    o_nmac_data_last  <= 1'h1;                    
                    rv_report_cnt     <= 8'd0;
                    nrm_state         <= IDLE_S;
                end
            end
                                  
            REPORT_S:begin//generate nmac pkt data base on table
                o_nmac_data_last  <= 1'h0;
                r_ram_byte        <= r_ram_byte + 1'b1;
                if(rv_report_cnt < 8'd30)begin   
                    nrm_state    <= REPORT_S;
                    case(r_ram_byte)
                        1'd1:begin
                            ov_nmac_data <= iv_rd_command_ack[15:8];
                            ov_rd_command[183:152] <= ov_rd_command[183:152];//addr
                            o_rd_command_wr <= 1'b0;
                            rv_report_cnt   <= rv_report_cnt;
                        end
                        1'd0:begin
                            ov_nmac_data <= iv_rd_command_ack[7:0];
                            ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'b1;//addr
                            o_rd_command_wr <= 1'b1;
                            rv_report_cnt   <= rv_report_cnt + 8'h1;
                        end 
                    endcase
                end
                else begin
                    ov_nmac_data <= iv_rd_command_ack[15:8];
                    ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'b1;//addr
                    o_rd_command_wr <= 1'b1;
                    nrm_state    <= WAIT_S;
                end
            end
            
            WAIT_S:begin//generate nmac pkt data on table
                o_rd_command_wr <= 1'b0;
                if(rv_report_cnt < 8'd32)begin
                    nrm_state    <= WAIT_S;
                    r_ram_byte      <= r_ram_byte + 1'b1;
                    case(r_ram_byte)
                        1'd1:begin
                            ov_nmac_data <= iv_rd_command_ack[15:8];
                            rv_report_cnt   <= rv_report_cnt;
                        end
                        1'd0:begin
                            ov_nmac_data <= iv_rd_command_ack[7:0];
                            rv_report_cnt   <= rv_report_cnt + 8'h1;
                        end 
                    endcase
                end
                else begin
                    ov_nmac_data <= iv_rd_command_ack[15:8];
                    o_nmac_data_last  <= 1'h1;
                    nrm_state    <= IDLE_S;
                end
            end
            REPORT_MAPPING_TABLE_S:begin
                rv_report_cnt   <= rv_report_cnt + 8'h1;
                if(rv_report_cnt == 8'd8)begin   
                    o_rd_command_wr <= 1'b1;
                    ov_rd_command[203:196] <= 8'b0;
                    ov_rd_command[195:188] <= 8'd13;
                    ov_rd_command[187:184] <= 4'b0010;//type:read 
                    ov_rd_command[183:152] <= ({22'b0,iv_report_type[9:0]} << 1);//addr
                    ov_rd_command[151:0] <= 152'b0;  
                end
                else if(rv_report_cnt == 8'd40)begin
                    o_rd_command_wr <= 1'b1;
                    ov_rd_command[203:196] <= 8'b0;
                    ov_rd_command[195:188] <= 8'd13;
                    ov_rd_command[187:184] <= 4'b0010;//type:read 
                    ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'b1;//addr
                    ov_rd_command[151:0] <= 152'b0;                  
                end
                else begin
                    o_rd_command_wr <= 1'b0;
                    ov_rd_command <= 204'b0;                 
                end
                
                if(rv_report_cnt[4:0] < 5'd13)begin
                    ov_nmac_data <= 8'b0;
                end
                else if((rv_report_cnt[4:0] > 5'd12) && (rv_report_cnt[4:0] <= 5'd31))begin
                    case(rv_report_cnt[4:0])
                        5'd13:begin
                            ov_nmac_data <= iv_rd_command_ack[151:144];
                        end
                        5'd14:begin
                            ov_nmac_data <= iv_rd_command_ack[143:136];
                        end
                        5'd15:begin
                            ov_nmac_data <= iv_rd_command_ack[135:128];
                        end
                        5'd16:begin
                            ov_nmac_data <= iv_rd_command_ack[127:120];
                        end
                        5'd17:begin
                            ov_nmac_data <= iv_rd_command_ack[119:112];
                        end
                        5'd18:begin
                            ov_nmac_data <= iv_rd_command_ack[111:104];
                        end
                        5'd19:begin
                            ov_nmac_data <= iv_rd_command_ack[103:96];
                        end
                        5'd20:begin
                            ov_nmac_data <= iv_rd_command_ack[95:88];
                        end
                        5'd21:begin
                            ov_nmac_data <= iv_rd_command_ack[87:80];
                        end
                        5'd22:begin
                            ov_nmac_data <= iv_rd_command_ack[79:72];
                        end
                        5'd23:begin
                            ov_nmac_data <= iv_rd_command_ack[71:64];
                        end
                        5'd24:begin
                            ov_nmac_data <= iv_rd_command_ack[63:56];
                        end
                        5'd25:begin
                            ov_nmac_data <= iv_rd_command_ack[55:48];
                        end
                        5'd26:begin
                            ov_nmac_data <= iv_rd_command_ack[47:40];
                        end
                        5'd27:begin
                            ov_nmac_data <= iv_rd_command_ack[39:32];
                        end
                        5'd28:begin
                            ov_nmac_data <= iv_rd_command_ack[31:24];
                        end
                        5'd29:begin
                            ov_nmac_data <= iv_rd_command_ack[23:16];
                        end
                        5'd30:begin
                            ov_nmac_data <= iv_rd_command_ack[15:8];
                        end
                        5'd31:begin
                            ov_nmac_data <= iv_rd_command_ack[7:0];
                        end
                    endcase
                end
                
                if(rv_report_cnt == 8'd63)begin
                    o_nmac_data_last  <= 1'h1;
                    nrm_state    <= IDLE_S;
                end
                else begin
                    o_nmac_data_last  <= 1'h0;
                end                
            end
            REPORT_INVERSE_MAPPING_TABLE_S:begin
                rv_report_cnt   <= rv_report_cnt + 8'h1;
                if(rv_report_cnt == 8'd2)begin   
                    o_rd_command_wr <= 1'b1;
                    ov_rd_command[203:196] <= 8'b0;
                    ov_rd_command[195:188] <= 8'd14;
                    ov_rd_command[187:184] <= 4'b0010;//type:read 
                    ov_rd_command[183:152] <= ({22'b0,iv_report_type[9:0]} << 2);//addr
                    ov_rd_command[151:0] <= 152'b0;  
                end
                else if(rv_report_cnt == 8'd18)begin
                    o_rd_command_wr <= 1'b1;
                    ov_rd_command[203:196] <= 8'b0;
                    ov_rd_command[195:188] <= 8'd14;
                    ov_rd_command[187:184] <= 4'b0010;//type:read 
                    ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'b1;//addr
                    ov_rd_command[151:0] <= 152'b0;                  
                end
                else if(rv_report_cnt == 8'd34)begin
                    o_rd_command_wr <= 1'b1;
                    ov_rd_command[203:196] <= 8'b0;
                    ov_rd_command[195:188] <= 8'd14;
                    ov_rd_command[187:184] <= 4'b0010;//type:read 
                    ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'b1;//addr
                    ov_rd_command[151:0] <= 152'b0;                  
                end
                else if(rv_report_cnt == 8'd50)begin
                    o_rd_command_wr <= 1'b1;
                    ov_rd_command[203:196] <= 8'b0;
                    ov_rd_command[195:188] <= 8'd14;
                    ov_rd_command[187:184] <= 4'b0010;//type:read 
                    ov_rd_command[183:152] <= ov_rd_command[183:152] + 1'b1;//addr
                    ov_rd_command[151:0] <= 152'b0;                  
                end                  
                else begin
                    o_rd_command_wr <= 1'b0;
                    ov_rd_command <= 204'b0;                 
                end
                
                if(rv_report_cnt[3:0] < 4'd6)begin
                    ov_nmac_data <= 8'b0;
                    o_nmac_data_last  <= 1'h0;
                end
                else if((rv_report_cnt[3:0] > 4'd5) && (rv_report_cnt[3:0] <= 4'd15))begin
                    o_nmac_data_last  <= 1'h0;
                    case(rv_report_cnt)
                        8'd6:begin
                            ov_nmac_data <= {2'b0,iv_rd_command_ack[77:72]};
                        end
                        8'd7:begin
                            ov_nmac_data <= iv_rd_command_ack[71:64];
                        end
                        8'd8:begin
                            ov_nmac_data <= iv_rd_command_ack[63:56];
                        end
                        8'd9:begin
                            ov_nmac_data <= iv_rd_command_ack[55:48];
                        end
                        8'd10:begin
                            ov_nmac_data <= iv_rd_command_ack[47:40];
                        end
                        8'd11:begin
                            ov_nmac_data <= iv_rd_command_ack[39:32];
                        end
                        8'd12:begin
                            ov_nmac_data <= iv_rd_command_ack[31:24];
                        end
                        8'd13:begin
                            ov_nmac_data <= iv_rd_command_ack[23:16];
                        end
                        8'd14:begin
                            ov_nmac_data <= iv_rd_command_ack[15:8];
                        end
                        8'd15:begin
                            ov_nmac_data <= iv_rd_command_ack[7:0];
                        end
                    endcase
                end
                if(rv_report_cnt == 8'd63)begin
                    o_nmac_data_last  <= 1'h1;
                    nrm_state       <= IDLE_S;
                end
                else begin
                    o_nmac_data_last  <= 1'h0;   
                end                
            end            
            default:begin
                o_statistic_rst <= 1'b0;
                rv_report_cnt   <= 8'h0;
                r_ram_byte      <= 1'b0;
                
                ov_nmac_data    <= 8'h0;
                o_nmac_data_last  <= 1'h0;
                o_namc_report_req <= 1'h0;
                
                nrm_state       <= IDLE_S;
            end
        endcase
    end
end
endmodule