// Copyright (C) 1953-2020 NUDT
// Verilog module name - global_time_sync 
// Version: GTS_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         global time synchronization 
//         generate report pulse base on global time
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module global_time_sync 
(

       i_clk,
       i_rst_n,
       
       iv_time_offset,
       i_time_offset_wr,
       iv_offset_period,
       
       pluse_s,
       
       iv_cfg_finish,
       iv_report_period,
       
       ov_syned_time,
       o_timer_reset_pluse
);

// clk & rst
input                  i_clk;
input                  i_rst_n;


input      [48:0]      iv_time_offset;    // time offset 
input                  i_time_offset_wr;  // time offset wr
input      [23:0]      iv_offset_period;  // time offset_period  

output reg             pluse_s;           // 1024 ms / 1.024ms pluse
 
input      [1:0]       iv_cfg_finish;
input      [11:0]      iv_report_period;
 
output reg [47:0]      ov_syned_time;               // have syned global time 


output reg             o_timer_reset_pluse;         // count reset pluse
reg        [18:0]      reset_counter;               //when value 0x7A120,reset

reg        [23:0]      offset_counter;               //when value 12500000,cfg offset

always @(posedge i_clk or negedge i_rst_n) begin// global time
    if(!i_rst_n)begin
        ov_syned_time        <= 48'b0;
    end
    else begin
        if(i_time_offset_wr == 1'b1 || (iv_offset_period != 0 && offset_counter == iv_offset_period))begin
            if(iv_time_offset[48] == 1'b0)begin//   +               
                if({1'b0,ov_syned_time[6:0]}  + {1'b0,iv_time_offset[6:0]}>= 8'd124)begin//if sum more than 7'd124999,high bit +1,low bit sum +1 -125000
                    ov_syned_time[47:7]  <= ov_syned_time[47:7] + iv_time_offset[47:7] + 1'b1;
                    ov_syned_time[6:0]  <= ov_syned_time[6:0]  + iv_time_offset[6:0] - 7'd124;
                end
                else begin
                    ov_syned_time[47:7]  <= ov_syned_time[47:7] + iv_time_offset[47:7];
                    ov_syned_time[6:0]   <= ov_syned_time[6:0]  + iv_time_offset[6:0] + 7'b1;
                end
            end         
            else begin// - 
                if(ov_syned_time[6:0] >= iv_time_offset[6:0])begin//ov_syned_time[6:0] >= iv_time_offset[6:0]
                    if(ov_syned_time[6:0] - iv_time_offset[6:0] ==7'd124)begin
                        ov_syned_time[47:7]  <= ov_syned_time[47:7] - iv_time_offset[47:7] + 1'b1;
                        ov_syned_time[6:0]   <= 7'd0;
                    end
                    else begin
                        ov_syned_time[47:7]  <= ov_syned_time[47:7] - iv_time_offset[47:7];
                        ov_syned_time[6:0]   <= ov_syned_time[6:0]  - iv_time_offset[6:0] + 1'b1; 
                    end
                end
                else begin//ov_syned_time[6:0] < iv_time_offset[6:0]
                    if({1'b0,ov_syned_time[6:0]} + 8'd125 - {1'b0,iv_time_offset[6:0]} == 8'd124)begin//ov_syned_time[6:0] - iv_time_offset[6:0] max  is -1
                        ov_syned_time[47:7]  <= ov_syned_time[47:7] - iv_time_offset[47:7];
                        ov_syned_time[6:0]   <= 7'd0;
                    end
                    else begin
                        ov_syned_time[47:7]  <= ov_syned_time[47:7] - iv_time_offset[47:7] - 1'b1;
                        ov_syned_time[6:0]   <= ov_syned_time[6:0] + 7'd125 - iv_time_offset[6:0] + 1'b1;
                    end
                end
            end         
        end
                
        
        else begin
            if(ov_syned_time[6:0]   == 7'd124)begin
                ov_syned_time[47:7] <= ov_syned_time[47:7] + 1'b1;
                ov_syned_time[6:0]  <= 7'd0;
            end
            else begin
                ov_syned_time[6:0] <= ov_syned_time[6:0] + 1'b1;
            end
        end
    end
end

always @(posedge i_clk or negedge i_rst_n) begin//local time rst 
    if(!i_rst_n)begin
        reset_counter        <= 19'b0;
        offset_counter       <= 24'b0;
        o_timer_reset_pluse  <= 1'b0;
    end
    else begin
        if(reset_counter == 19'h7A11e)begin
            reset_counter[18:0] <= reset_counter[18:0] + 1'b1;
            o_timer_reset_pluse <= 1'b1;
        end
        else if(reset_counter == 19'h7A11f)begin
            reset_counter <= 19'h0; 
            o_timer_reset_pluse <= 1'b0;
        end
        else begin
            reset_counter[18:0] <= reset_counter[18:0] + 1'b1;
            o_timer_reset_pluse <= 1'b0;
        end
        if(i_time_offset_wr == 1'b1 || offset_counter == iv_offset_period)begin
            offset_counter[23:0] <= 1'b0;
        end
        else if(iv_offset_period == 1'b0)begin
            offset_counter[23:0] <= 1'b0;
        end
        else begin
            offset_counter[23:0] <= offset_counter[23:0] + 1'b1;
        end
    end
end


reg        [31:0]      rv_local_cnt; 
reg        [30:0]      rv_last_time; 
always @(posedge i_clk or negedge i_rst_n) begin//report period
    if(!i_rst_n)begin
        pluse_s      <= 1'b0;
        rv_local_cnt <= 32'd0;
        rv_last_time <= 31'd0;
    end
    else begin
        if(iv_cfg_finish >= 2'd1)begin
            case(iv_report_period)
                12'd1:begin//1ms
                    if((ov_syned_time[16:0] == 17'd0) || (rv_local_cnt[16:0] == 17'd0) && (ov_syned_time[47:17] != rv_last_time))begin
                    //generate report pulse 
                    //when global time meet the conditions
                    //when global time havd miss the conditions because time synchronization,need generate report pulse base on "rv_local_cnt"
                    //when global time havd meet the last conditions because time synchronization,need generate report pulse base on "rv_last_time"
                        pluse_s      <= 1'b1;
                        rv_local_cnt <= 32'd0;
                        rv_last_time <= ov_syned_time[47:17];
                    end
                    else begin
                        pluse_s      <= 1'b0;
                        rv_last_time <= rv_last_time;
                        if(rv_local_cnt[6:0] == 7'd125)begin
                            rv_local_cnt[31:7] <= rv_local_cnt[31:7] + 25'd1;
                            rv_local_cnt[6:0]  <= 7'd0;
                        end
                        else begin
                            rv_local_cnt <= rv_local_cnt + 32'd1;
                        end
                    end
                end
                12'd1000:begin//1s
                    if((ov_syned_time[26:0] == 27'd0) || (rv_local_cnt[26:0] == 27'd0) && (ov_syned_time[47:27] != rv_last_time[20:0]))begin
                        pluse_s      <= 1'b1;
                        rv_local_cnt <= 32'd0;
                        rv_last_time[20:0] <= ov_syned_time[47:27];
                    end
                    else begin
                        pluse_s      <= 1'b0;
                        rv_last_time <= rv_last_time;
                        if(rv_local_cnt[6:0] == 7'd125)begin
                            rv_local_cnt[31:7] <= rv_local_cnt[31:7] + 25'd1;
                            rv_local_cnt[6:0]  <= 7'd0;
                        end
                        else begin
                            rv_local_cnt <= rv_local_cnt + 32'd1;
                        end
                    end
                end
                
                default:begin
                    pluse_s      <= 1'b0;
                    rv_local_cnt <= 32'd0;
                    rv_last_time <= 31'd0;
                end
            endcase
        end
        else begin
            pluse_s      <= 1'b0;
            rv_local_cnt <= 32'd0;
            rv_last_time <= 31'd0;
        end
    end
end
    
endmodule