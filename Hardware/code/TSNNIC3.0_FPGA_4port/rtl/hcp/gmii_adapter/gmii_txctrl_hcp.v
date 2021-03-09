// Copyright (C) 1953-2020 NUDT
// Verilog module name - gmii_txctrl_host 
// Version: GTH_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         1.message first byte detection；
//         2.calcultion of CRC checkout code；
//         3.controlled of message output；
////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module gmii_txctrl_hcp(
    input                 rst_n,
    input                 clk,
    input  wire           ppt2gtc_gmii_dv,
    input  wire           ppt2gtc_gmii_er,
    input  wire  [   7:0] ppt2gtc_gmii_data,
    
    output reg            gmii_tx_en,
    output reg            gmii_tx_er,
    output reg   [  7:0]  gmii_txd
    );

////////////////////////////////////////////////////////////////////////////
//        Intermediate variable Declaration
////////////////////////////////////////////////////////////////////////////
    reg            ppt2gtc_gmii_dv_r0;
    wire           pos_edge;
    wire           neg_edge;
    wire   [7:0]   data_in;
    wire   [31:0]  crc_f;
    reg    [31:0]  next_crc;
    wire   [31:0]  lastcrc;
    reg    [1:0]   crc_cnt;
   
    reg    [2:0]   ctrl_state;
    localparam IDLE_S = 3'd1,
               RCV_S  = 3'd2,
               CRC_S  = 3'd3,
               OUT_S  = 3'd4;

////////////////////////////////////////////////////////////////////////////
assign pos_edge =~ppt2gtc_gmii_dv_r0 & ppt2gtc_gmii_dv;
assign neg_edge =ppt2gtc_gmii_dv_r0 & ~ppt2gtc_gmii_dv;                 

always @ (posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        ppt2gtc_gmii_dv_r0 <= 1'b0;
    end
    else begin
        ppt2gtc_gmii_dv_r0 <= ppt2gtc_gmii_dv;
    end
end      

////////////////////////////////////////////////////////////////////////////
//gmii data 
assign data_in ={ppt2gtc_gmii_data[0],ppt2gtc_gmii_data[1],ppt2gtc_gmii_data[2],ppt2gtc_gmii_data[3],ppt2gtc_gmii_data[4],ppt2gtc_gmii_data[5],ppt2gtc_gmii_data[6],ppt2gtc_gmii_data[7]};

assign crc_f ={next_crc[0],next_crc[1],next_crc[2],next_crc[3],next_crc[4],next_crc[5],next_crc[6],next_crc[7],next_crc[8],next_crc[9],
next_crc[10],next_crc[11],next_crc[12],next_crc[13],next_crc[14],next_crc[15],next_crc[16],next_crc[17],next_crc[18],next_crc[19],
next_crc[20],next_crc[21],next_crc[22],next_crc[23],next_crc[24],next_crc[25],next_crc[26],next_crc[27],next_crc[28],next_crc[29],
next_crc[30],next_crc[31]};
assign lastcrc =~crc_f;
always @ (posedge clk or negedge rst_n) begin
    if(rst_n==1'b0)begin
        gmii_tx_en <= 1'b0;
        gmii_tx_er <= 1'b0;
        gmii_txd <= 8'b0;
        crc_cnt<= 2'b0;
        next_crc <= 32'hffffffff;
        ctrl_state <= IDLE_S;         
    end
    else begin
        case(ctrl_state)
        IDLE_S:begin        
            if (pos_edge == 1'b1)begin //posedge of “ppt2gtc_gmii_dv” signal
                gmii_txd <= ppt2gtc_gmii_data;
                gmii_tx_en <= ppt2gtc_gmii_dv;
                gmii_tx_er <= ppt2gtc_gmii_er;
                ctrl_state <= RCV_S;
            end
            else begin
                ctrl_state <= IDLE_S;      
            end
        end
        RCV_S:begin          
            if((ppt2gtc_gmii_dv == 1'b1)&&(ppt2gtc_gmii_data == 8'hd5))begin//first byte
                gmii_txd <= ppt2gtc_gmii_data;
                gmii_tx_en <= ppt2gtc_gmii_dv;
                gmii_tx_er <= ppt2gtc_gmii_er;  
                ctrl_state <= CRC_S;
            end
            else begin
                gmii_txd <= ppt2gtc_gmii_data;
                gmii_tx_en <= ppt2gtc_gmii_dv;
                gmii_tx_er <= ppt2gtc_gmii_er;                  
                ctrl_state <= RCV_S; 
            end 
        end            
        CRC_S:begin
            if(neg_edge == 1'b1)begin
                
                gmii_txd <= lastcrc[7:0];
                gmii_tx_en <= 1'b1;
                ctrl_state <= OUT_S;
            end
            else  begin   

                next_crc[0]<=  data_in[6] ^ data_in[0] ^ next_crc[24] ^ next_crc[30];
                next_crc[1]<=  data_in[7] ^ data_in[6] ^ data_in[1] ^ data_in[0] ^ next_crc[24] ^ next_crc[25] ^ next_crc[30] ^ next_crc[31];
                next_crc[2]<=  data_in[7] ^ data_in[6] ^ data_in[2] ^ data_in[1] ^ data_in[0] ^ next_crc[24] ^ next_crc[25] ^ next_crc[26] ^ next_crc[30] ^ next_crc[31];
                next_crc[3]<=  data_in[7] ^ data_in[3] ^ data_in[2] ^ data_in[1] ^ next_crc[25] ^ next_crc[26] ^ next_crc[27] ^ next_crc[31];
                next_crc[4]<=  data_in[6] ^ data_in[4] ^ data_in[3] ^ data_in[2] ^ data_in[0] ^ next_crc[24] ^ next_crc[26] ^ next_crc[27] ^ next_crc[28] ^ next_crc[30];
                next_crc[5]<=  data_in[7] ^ data_in[6] ^ data_in[5] ^ data_in[4] ^ data_in[3] ^ data_in[1] ^ data_in[0] ^ next_crc[24] ^ next_crc[25] ^ next_crc[27] ^ next_crc[28] ^ next_crc[29] ^ next_crc[30] ^ next_crc[31];
                next_crc[6]<=  data_in[7] ^ data_in[6] ^ data_in[5] ^ data_in[4] ^ data_in[2] ^ data_in[1] ^ next_crc[25] ^ next_crc[26] ^ next_crc[28] ^ next_crc[29] ^ next_crc[30] ^ next_crc[31];
                next_crc[7]<=  data_in[7] ^ data_in[5] ^ data_in[3] ^ data_in[2] ^ data_in[0] ^ next_crc[24] ^ next_crc[26] ^ next_crc[27] ^ next_crc[29] ^ next_crc[31];
                next_crc[8]<=  data_in[4] ^ data_in[3] ^ data_in[1] ^ data_in[0] ^ next_crc[0] ^ next_crc[24] ^ next_crc[25] ^ next_crc[27] ^ next_crc[28];
                next_crc[9]<=  data_in[5] ^ data_in[4] ^ data_in[2] ^ data_in[1] ^ next_crc[1] ^ next_crc[25] ^ next_crc[26] ^ next_crc[28] ^ next_crc[29];
                next_crc[10] <= data_in[5] ^ data_in[3] ^ data_in[2] ^ data_in[0] ^ next_crc[2] ^ next_crc[24] ^ next_crc[26] ^ next_crc[27] ^ next_crc[29];
                next_crc[11] <= data_in[4] ^ data_in[3] ^ data_in[1] ^ data_in[0] ^ next_crc[3] ^ next_crc[24] ^ next_crc[25] ^ next_crc[27] ^ next_crc[28];
                next_crc[12] <= data_in[6] ^ data_in[5] ^ data_in[4] ^ data_in[2] ^ data_in[1] ^ data_in[0] ^ next_crc[4] ^ next_crc[24] ^ next_crc[25] ^ next_crc[26] ^ next_crc[28] ^ next_crc[29] ^ next_crc[30];
                next_crc[13] <= data_in[7] ^ data_in[6] ^ data_in[5] ^ data_in[3] ^ data_in[2] ^ data_in[1] ^ next_crc[5] ^ next_crc[25] ^ next_crc[26] ^ next_crc[27] ^ next_crc[29] ^ next_crc[30] ^ next_crc[31];
                next_crc[14] <= data_in[7] ^ data_in[6] ^ data_in[4] ^ data_in[3] ^ data_in[2] ^ next_crc[6] ^ next_crc[26] ^ next_crc[27] ^ next_crc[28] ^ next_crc[30] ^ next_crc[31];
                next_crc[15] <= data_in[7] ^ data_in[5] ^ data_in[4] ^ data_in[3] ^ next_crc[7] ^ next_crc[27] ^ next_crc[28] ^ next_crc[29] ^ next_crc[31];
                next_crc[16] <= data_in[5] ^ data_in[4] ^ data_in[0] ^ next_crc[8] ^ next_crc[24] ^ next_crc[28] ^ next_crc[29];
                next_crc[17] <= data_in[6] ^ data_in[5] ^ data_in[1] ^ next_crc[9] ^ next_crc[25] ^ next_crc[29] ^ next_crc[30];
                next_crc[18] <= data_in[7] ^ data_in[6] ^ data_in[2] ^ next_crc[10] ^ next_crc[26] ^ next_crc[30] ^ next_crc[31];
                next_crc[19] <= data_in[7] ^ data_in[3] ^ next_crc[11] ^ next_crc[27] ^ next_crc[31];
                next_crc[20] <= data_in[4] ^ next_crc[12] ^ next_crc[28];
                next_crc[21] <= data_in[5] ^ next_crc[13] ^ next_crc[29];
                next_crc[22] <= data_in[0] ^ next_crc[14] ^ next_crc[24];
                next_crc[23] <= data_in[6] ^ data_in[1] ^ data_in[0] ^ next_crc[15] ^ next_crc[24] ^ next_crc[25] ^ next_crc[30];
                next_crc[24] <= data_in[7] ^ data_in[2] ^ data_in[1] ^ next_crc[16] ^ next_crc[25] ^ next_crc[26] ^ next_crc[31];
                next_crc[25] <= data_in[3] ^ data_in[2] ^ next_crc[17] ^ next_crc[26] ^ next_crc[27];
                next_crc[26] <= data_in[6] ^ data_in[4] ^ data_in[3] ^ data_in[0] ^ next_crc[18] ^ next_crc[24] ^ next_crc[27] ^ next_crc[28] ^ next_crc[30];
                next_crc[27] <= data_in[7] ^ data_in[5] ^ data_in[4] ^ data_in[1] ^ next_crc[19] ^ next_crc[25] ^ next_crc[28] ^ next_crc[29] ^ next_crc[31];
                next_crc[28] <= data_in[6] ^ data_in[5] ^ data_in[2] ^ next_crc[20] ^ next_crc[26] ^ next_crc[29] ^ next_crc[30];
                next_crc[29] <= data_in[7] ^ data_in[6] ^ data_in[3] ^ next_crc[21] ^ next_crc[27] ^ next_crc[30] ^ next_crc[31];
                next_crc[30] <= data_in[7] ^ data_in[4] ^ next_crc[22] ^ next_crc[28] ^ next_crc[31];
                next_crc[31] <= data_in[5] ^ next_crc[23] ^ next_crc[29];
                
                
                   
                gmii_txd <= ppt2gtc_gmii_data;//message normal transmission
                gmii_tx_en <= ppt2gtc_gmii_dv;
                gmii_tx_er <= ppt2gtc_gmii_er; 
                ctrl_state <= CRC_S; 
            end
        end
        OUT_S:begin           
            if(crc_cnt==2'b00) begin
                gmii_tx_en <= 1'b1;
                gmii_txd   <= lastcrc[15:8];
                ctrl_state <= OUT_S;  
                crc_cnt<=crc_cnt+1'b1;
            end
            else if(crc_cnt==2'b01)begin
                gmii_tx_en <= 1'b1;
                gmii_txd   <= lastcrc[23:16];
                crc_cnt<=crc_cnt+1'b1;
                ctrl_state <= OUT_S; 
            end
            else if(crc_cnt==2'b10)begin
                gmii_tx_en <= 1'b1;
                gmii_txd   <= lastcrc[31:24];
                crc_cnt<=crc_cnt+1'b1;
                ctrl_state <= OUT_S; 
            end
            else begin
                gmii_tx_en <= 1'b0;
                gmii_tx_er <= 1'b0;
                gmii_txd <= 8'b0;
                crc_cnt<= 2'b0;
                next_crc <= 32'hffffffff;
                ctrl_state <= IDLE_S; 
            end
        end
        default:ctrl_state <= IDLE_S;
       
        endcase 
    end
end


endmodule

