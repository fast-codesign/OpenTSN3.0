// Copyright (C) 1953-2020 NUDT
// Verilog module name - time_slot_calculation 
// Version: TSC_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         calculation of time slot 
//             - calculate time slot according to syned global time and time slot length.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module time_slot_calculation
(
       i_clk,
       i_rst_n,
       
       iv_syned_global_time,
       iv_time_slot_length,
       
       iv_table_period,
       
       ov_time_slot,
       o_time_slot_switch       
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;
// calculation of time slot
input      [47:0]      iv_syned_global_time;  //[47:7]:us_cnt ; [6:0]:cycle_cnt.      
input      [10:0]      iv_time_slot_length;    // measure:us; 10 means time slot length is 10us.
// period of injection slot table
input      [10:0]      iv_table_period;//measure:time slot; the number of time slot of injection slot table. 
// time slot
output reg [9:0]       ov_time_slot;//current time slot 
output reg             o_time_slot_switch;       
//***************************************************
//                time slot count
//***************************************************  
reg       [16:0]    rv_local_slot_time;
reg                 r_previous_slot_flag;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_local_slot_time <= 17'd0;
        r_previous_slot_flag <= 1'b0;
        ov_time_slot <= 10'd0;
        o_time_slot_switch <= 1'b0;
    end
    else begin
        if (|iv_table_period)begin
            case(iv_time_slot_length)  
                 11'd4:begin
                    if(iv_syned_global_time[8:0] == 9'b0 || rv_local_slot_time == 17'd499)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd499) && (&iv_syned_global_time[8:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[9] == ~r_previous_slot_flag))begin                        
                            o_time_slot_switch <= 1'b1;
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[9:9] };
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[10:9]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[11:9]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[12:9]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[13:9]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[14:9]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[15:9]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[16:9]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[17:9]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[18:9];
                                default:ov_time_slot <= iv_syned_global_time[18:9];
                            endcase
                        end
                        else begin                            
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;  
                            r_previous_slot_flag <= r_previous_slot_flag;
                        end
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end            
                 11'd8:begin
                    if(iv_syned_global_time[9:0] == 10'b0 || rv_local_slot_time == 17'd999)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd999) && (&iv_syned_global_time[9:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[10] == ~r_previous_slot_flag))begin
                            o_time_slot_switch <= 1'b1;                        
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[10:10]};
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[11:10]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[12:10]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[13:10]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[14:10]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[15:10]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[16:10]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[17:10]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[18:10]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[19:10];
                                default:ov_time_slot <= iv_syned_global_time[19:10];
                            endcase                            
                        end
                        else begin
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;                          
                            r_previous_slot_flag <= r_previous_slot_flag;                     
                        end                        
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end             
                 11'd16:begin
                    if(iv_syned_global_time[10:0] == 11'b0 || rv_local_slot_time == 17'd1999)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd1999) && (&iv_syned_global_time[10:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[11] == ~r_previous_slot_flag))begin                        
                            o_time_slot_switch <= 1'b1;                        
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[11:11]};
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[12:11]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[13:11]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[14:11]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[15:11]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[16:11]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[17:11]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[18:11]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[19:11]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[20:11];
                                default:ov_time_slot <= iv_syned_global_time[20:11];
                            endcase                              
                        end
                        else begin
                            r_previous_slot_flag <= r_previous_slot_flag;
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;                                               
                        end
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end            
                 11'd32:begin
                    if(iv_syned_global_time[11:0] == 12'b0 || rv_local_slot_time == 17'd3999)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd3999) && (&iv_syned_global_time[11:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[12] == ~r_previous_slot_flag))begin                                                
                            o_time_slot_switch <= 1'b1;                          
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[12:12]};
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[13:12]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[14:12]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[15:12]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[16:12]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[17:12]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[18:12]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[19:12]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[20:12]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[21:12];
                                default:ov_time_slot <= iv_syned_global_time[21:12];
                            endcase                              
                        end
                        else begin
                            r_previous_slot_flag <= r_previous_slot_flag;
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;                        
                        end
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end              
                 11'd64:begin
                    if(iv_syned_global_time[12:0] == 13'b0 || rv_local_slot_time == 17'd7999)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd7999) && (&iv_syned_global_time[12:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[13] == ~r_previous_slot_flag))begin                                                                        
                            o_time_slot_switch <= 1'b1;                           
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[13:13]};
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[14:13]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[15:13]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[16:13]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[17:13]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[18:13]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[19:13]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[20:13]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[21:13]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[22:13];
                                default:ov_time_slot <= iv_syned_global_time[22:13];
                            endcase                             
                        end
                        else begin
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;                           
                            r_previous_slot_flag <= r_previous_slot_flag;                       
                        end
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end             
                 11'd128:begin
                    if(iv_syned_global_time[13:0] == 14'b0 || rv_local_slot_time == 17'd15999)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd15999) && (&iv_syned_global_time[13:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[14] == ~r_previous_slot_flag))begin                                                                                                
                            o_time_slot_switch <= 1'b1;                          
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[14:14]};
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[15:14]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[16:14]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[17:14]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[18:14]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[19:14]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[20:14]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[21:14]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[22:14]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[23:14];
                                default:ov_time_slot <= iv_syned_global_time[23:14];
                            endcase                             
                        end
                        else begin
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;  
                            r_previous_slot_flag <= r_previous_slot_flag;                    
                        end
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end            
                 11'd256:begin
                    if(iv_syned_global_time[14:0] == 15'b0 || rv_local_slot_time == 17'd31999)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd31999) && (&iv_syned_global_time[14:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[15] == ~r_previous_slot_flag))begin                                                                                                                        
                            o_time_slot_switch <= 1'b1;                          
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[15:15]};
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[16:15]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[17:15]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[18:15]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[19:15]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[20:15]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[21:15]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[22:15]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[23:15]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[24:15];
                                default:ov_time_slot <= iv_syned_global_time[24:15];
                            endcase                             
                        end
                        else begin
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;                         
                            r_previous_slot_flag <= r_previous_slot_flag;                     
                        end
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end           
                 11'd512:begin
                    if(iv_syned_global_time[15:0] == 16'b0 || rv_local_slot_time == 17'd63999)begin
                        rv_local_slot_time <= 17'd0;
                        if(((rv_local_slot_time == 17'd63999) && (&iv_syned_global_time[15:7] == 1'b1) && (iv_syned_global_time[6:0] == 7'd124))||(iv_syned_global_time[16] == ~r_previous_slot_flag))begin                                                                                                                                                
                            o_time_slot_switch <= 1'b1;                          
                            r_previous_slot_flag <= ~r_previous_slot_flag;
                            case(iv_table_period)
                                11'd1:   ov_time_slot <= {10'b0};
                                11'd2:   ov_time_slot <= {9'b0,iv_syned_global_time[16:16]};
                                11'd4:   ov_time_slot <= {8'b0,iv_syned_global_time[17:16]};
                                11'd8:   ov_time_slot <= {7'b0,iv_syned_global_time[18:16]};
                                11'd16:  ov_time_slot <= {6'b0,iv_syned_global_time[19:16]};
                                11'd32:  ov_time_slot <= {5'b0,iv_syned_global_time[20:16]};
                                11'd64:  ov_time_slot <= {4'b0,iv_syned_global_time[21:16]};
                                11'd128: ov_time_slot <= {3'b0,iv_syned_global_time[22:16]};
                                11'd256: ov_time_slot <= {2'b0,iv_syned_global_time[23:16]};
                                11'd512: ov_time_slot <= {1'b0,iv_syned_global_time[24:16]};
                                11'd1024:ov_time_slot <= iv_syned_global_time[25:16];
                                default:ov_time_slot <= iv_syned_global_time[25:16];
                            endcase                             
                        end
                        else begin
                            ov_time_slot <= ov_time_slot;
                            o_time_slot_switch <= 1'b0;                          
                            r_previous_slot_flag <= r_previous_slot_flag;                    
                        end
                    end
                    else begin
                        rv_local_slot_time <= rv_local_slot_time + 1'b1;
                        ov_time_slot <= ov_time_slot;
                        o_time_slot_switch <= 1'b0; 
                        r_previous_slot_flag <= r_previous_slot_flag;
                    end
                end            
                default:begin
                    o_time_slot_switch <= 1'b0;
                end
            endcase
        end
        else begin
            o_time_slot_switch <= 1'b0;
        end
    end
end 
endmodule