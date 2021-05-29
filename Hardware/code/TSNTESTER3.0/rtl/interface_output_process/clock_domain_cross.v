// Copyright (C) 1953-2020 NUDT
// Verilog module name - clock_domain_cross
// Version: clock_domain_cross_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         clock domain cross(from core clock domain to gmii_tx clock domain)
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module clock_domain_cross
(
       i_clk,
       i_rst_n,
       
       i_gmii_clk,
       i_gmii_rst_n,
              
       iv_pkt_data,
       i_pkt_data_wr,
       
       o_fifo_overflow_pulse,
       o_fifo_underflow_pulse,
       
       ov_gmii_txd,
       o_gmii_tx_en,
       o_gmii_tx_er,
       o_gmii_tx_clk      
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input                  i_gmii_clk;
input                  i_gmii_rst_n;
// receive pkt data from pkt_centralize_bufm_memory
input      [7:0]       iv_pkt_data;
input                  i_pkt_data_wr;
// send pkt data from gmii     
output reg [7:0]       ov_gmii_txd;
output reg             o_gmii_tx_en;
output wire            o_gmii_tx_er;
output wire            o_gmii_tx_clk;

output reg             o_fifo_overflow_pulse;
output reg             o_fifo_underflow_pulse;

assign  o_gmii_tx_er  = 1'b0;
assign  o_gmii_tx_clk = i_gmii_clk;

//fifo
wire       [7:0]       wv_rd_data;
reg                    w_rd;
wire                   w_rdempty;
////////////////////////////////////////
//        fifo overflow               //
////////////////////////////////////////
wire      fifo_wrfull;
reg       [1:0]        fifo_wr_state;  
localparam             OVERFLOW_JUDGE_S  = 2'd0,
                       OVERFLOW_ERROR_S  = 2'd1;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        o_fifo_overflow_pulse <= 1'b0;
        fifo_wr_state <= OVERFLOW_JUDGE_S;
    end
    else begin
        case(fifo_wr_state)
            OVERFLOW_JUDGE_S:begin
                if((fifo_wrfull == 1'b1) && (i_pkt_data_wr == 1'b1))begin 
                    o_fifo_overflow_pulse <= 1'b1;            
                    fifo_wr_state <= OVERFLOW_ERROR_S;
                end
                else begin
                    o_fifo_overflow_pulse <= 1'b0;
                    fifo_wr_state <= OVERFLOW_JUDGE_S;
                end
            end
            OVERFLOW_ERROR_S:begin
                o_fifo_overflow_pulse <= 1'b0;    
                if(i_pkt_data_wr == 1'b0)begin   
                    fifo_wr_state <= OVERFLOW_JUDGE_S;            
                end
                else begin
                    fifo_wr_state <= OVERFLOW_ERROR_S;   
                end
            end
            default:begin
                o_fifo_overflow_pulse <= 1'b0;
                fifo_wr_state <= OVERFLOW_JUDGE_S;            
            end
        endcase
    end
end
////////////////////////////////////////
//        fifo underflow               //
////////////////////////////////////////
reg       [3:0]        rv_underflow_cycle_cnt;
reg       [1:0]        fifo_rd_state;  
localparam             UNDERFLOW_IDLE_S = 2'd0,
                       UNDERFLOW_READ_S = 2'd1,
                       UNDERFLOW_JUDGE_S = 2'd1;
always @(posedge i_gmii_clk or negedge i_gmii_rst_n) begin
    if(!i_gmii_rst_n)begin
        o_fifo_underflow_pulse <= 1'b0;
        rv_underflow_cycle_cnt <= 4'b0;
        fifo_rd_state <= UNDERFLOW_IDLE_S;
    end
    else begin
        case(fifo_rd_state)
            UNDERFLOW_IDLE_S:begin
                o_fifo_underflow_pulse <= 1'b0;             
                rv_underflow_cycle_cnt <= 4'b0;
                if(w_rd == 1'b1)begin 
                    fifo_rd_state <= UNDERFLOW_READ_S;
                end
                else begin
                    fifo_rd_state <= UNDERFLOW_IDLE_S;
                end
            end
            UNDERFLOW_READ_S:begin
                rv_underflow_cycle_cnt <= 4'b0;
                if(w_rd == 1'b0)begin 
                    fifo_rd_state <= UNDERFLOW_JUDGE_S;
                end 
                else begin
                    fifo_rd_state <= UNDERFLOW_READ_S;
                end                
            end
            UNDERFLOW_JUDGE_S:begin
                rv_underflow_cycle_cnt <= rv_underflow_cycle_cnt + 1'b1;
                if(rv_underflow_cycle_cnt <= 4'h8)begin
                    if(w_rdempty == 1'b0)begin
                        o_fifo_underflow_pulse <= 1'b1;
                        fifo_rd_state <= UNDERFLOW_IDLE_S;                        
                    end
                    else begin
                        o_fifo_underflow_pulse <= 1'b0; 
                        fifo_rd_state <= UNDERFLOW_JUDGE_S;         
                    end
                end
                else begin
                    o_fifo_underflow_pulse <= 1'b0; 
                    fifo_rd_state <= UNDERFLOW_IDLE_S;                  
                end
            end
            default:begin
                rv_underflow_cycle_cnt <= 4'h0;
                o_fifo_underflow_pulse <= 1'b0;
                fifo_rd_state <= UNDERFLOW_IDLE_S;            
            end
        endcase
    end
end
////////////////////////////////////////
//        read data from fifo         //
////////////////////////////////////////
reg        [2:0]       ccd_state;  
localparam             IDLE_S   = 3'd0,
                       DELAY_S  = 3'd1,
                       WAIT1_S  = 3'd2,
                       WAIT2_S  = 3'd3,
                       READ_S   = 3'd4;
always @(posedge i_gmii_clk or negedge i_gmii_rst_n) begin
    if(i_gmii_rst_n == 1'b0)begin
        ov_gmii_txd     <= 8'h0;
        o_gmii_tx_en    <= 1'b0;
        w_rd            <= 1'b0;
        ccd_state       <= IDLE_S;
    end
    else begin
        case(ccd_state)
            IDLE_S:begin
                w_rd         <= 1'b0;
                ov_gmii_txd  <= 8'd0;
                o_gmii_tx_en <= 1'b0;
                if(w_rdempty == 1'b0)begin
                    ccd_state       <= DELAY_S;
                end
                else begin
                    ccd_state       <= IDLE_S;
                end
            end
            DELAY_S:begin
                ccd_state       <= WAIT1_S;            
            end            
            WAIT1_S:begin
                w_rd         <= 1'b1;
                ov_gmii_txd  <= 8'd0;
                o_gmii_tx_en <= 1'b0;
                ccd_state       <= WAIT2_S;
            end
            
            WAIT2_S:begin
                w_rd         <= 1'b1;
                ov_gmii_txd  <= 8'd0;
                o_gmii_tx_en <= 1'b0;
                ccd_state       <= READ_S;
            end
            
            READ_S:begin
                w_rd         <= 1'b1;
                ov_gmii_txd  <= wv_rd_data;
                o_gmii_tx_en <= w_rd;
                if(w_rdempty == 1'b1)begin
                    ccd_state       <= IDLE_S;
                end
                else begin
                    ccd_state       <= READ_S;
                end
            end
        endcase
    end
end

ASFIFO_8_16  ASFIFO_8_16_inst
    (        
    .wr_aclr(~i_rst_n),                                         //Reset the all signal
    .rd_aclr(~i_gmii_rst_n),
    .data(iv_pkt_data),                                         //The Inport of data 
    .rdreq(w_rd),                                           //active-high
    .wrclk(i_clk),                                          //ASYNC WriteClk(), SYNC use wrclk
    .rdclk(i_gmii_clk),                                         //ASYNC WriteClk(), SYNC use wrclk  
    .wrreq(i_pkt_data_wr),                                          //active-high
    .q(wv_rd_data),                                             //The output of data
    .wrfull(fifo_wrfull),                                           //Write domain full 
    .wralfull(),                                        //Write domain almost-full
    .wrempty(),                                     //Write domain empty
    .wralempty(),                                       //Write domain almost-full  
    .rdfull(),                                          //Read domain full
    .rdalfull(),                                        //Read domain almost-full   
    .rdempty(w_rdempty),                                        //Read domain empty
    .rdalempty(),                                       //Read domain almost-empty
    .wrusedw(),                                     //Write-usedword
    .rdusedw()          
    );
endmodule