# (C) 2001-2019 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# CORE_PARAMETERS
set ENABLE_SUP_ADDR 0
set ENABLE_MAC_FLOW_CTRL 0
set ENABLE_MAGIC_DETECT 1
set ENABLE_HD_LOGIC 0
set ENABLE_GMII_LOOPBACK 0
set STAT_CNT_ENA 0

set old_mode [set_project_mode -get_mode_value always_show_entity_name] 
set_project_mode -always_show_entity_name on

# Function to constraint non-std_synchronizer path
proc altera_eth_tse_constraint_net_delay {from_reg to_reg max_net_delay} {
   
   set_net_delay -from [get_pins -compatibility_mode ${from_reg}|q] -to [get_registers ${to_reg}] -max $max_net_delay
   
   if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
      set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 100ns
      set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -100ns
   } else {
      # Relax the fitter effort
      set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 8ns
      set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -100ns
   }
   
}

# Function to constraint std_synchronizer
proc altera_eth_tse_constraint_std_sync {} {
   
   altera_eth_tse_constraint_net_delay  *  *altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*|din_s1  6ns
   
}

# Function to constraint pointers
proc altera_eth_tse_constraint_ptr {from_path from_reg to_path to_reg max_skew max_net_delay} {
   
   set_net_delay -from [get_pins -compatibility_mode *${from_path}|${from_reg}[*]|q] -to [get_registers *${to_path}|${to_reg}*] -max $max_net_delay
   
   if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
      # Check for instances
      set inst [get_registers -nowarn *${from_path}|${from_reg}\[0\]]
      
      # Check number of instances
      set inst_num [llength [query_collection -report -all $inst]]
      if {$inst_num > 0} {
         # Uncomment line below for debug purpose
         #puts "${inst_num} ${from_path}|${from_reg} instance(s) found"
      } else {
         # Uncomment line below for debug purpose
         #puts "No ${from_path}|${from_reg} instance found"
      }
      
      # Constraint one instance at a time to avoid set_max_skew apply to all instances
      foreach_in_collection each_inst_tmp $inst {
      set each_inst [get_node_info -name $each_inst_tmp] 
         # Get the path to instance
         regexp "(.*${from_path})(.*|)(${from_reg})" $each_inst reg_path inst_path inst_name reg_name
         
         set_max_skew -from [get_registers ${inst_path}${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] $max_skew
         
         set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] 100ns
         set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] -100ns
      }
      
   } else {
      # Relax the fitter effort
      set_max_delay -from [get_registers *${from_path}|${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] 8ns
      set_min_delay -from [get_registers *${from_path}|${from_reg}[*]] -to [get_registers *${to_path}|${to_reg}*] -100ns
   }
   
}

# Function to constraint clock crosser
proc altera_eth_tse_constraint_clock_crosser {} {
    set module_name altera_tse_clock_crosser
    
    set from_reg1 in_data_toggle
    set to_reg1 altera_eth_tse_std_synchronizer:in_to_out_synchronizer|altera_std_synchronizer_nocut:*|din_s1
    
    set from_reg2 in_data_buffer
    set to_reg2 out_data_buffer
    
    set from_reg3 out_data_toggle_flopped
    set to_reg3 altera_eth_tse_std_synchronizer:out_to_in_synchronizer|altera_std_synchronizer_nocut:*|din_s1
    
    set max_skew 7.5ns
    
    set max_delay1 6ns
    set max_delay2 4ns
    set max_delay3 6ns

    # Check for clock crosser instances
    set inst [get_registers -nowarn *${module_name}:*|${from_reg1}]
    
    # Check number of instances
    set inst_num [llength [query_collection -report -all $inst]]
    
    # Apply constraint if clock crosser exist
    if {$inst_num > 0} {
    
        # Constraint one instance at a time to avoid set_max_skew apply to all instances
        foreach_in_collection each_inst_tmp $inst {
        set each_inst [get_node_info -name $each_inst_tmp] 
        
            # Get the path to instance
            regexp "(.*${module_name})(:.*|)(${from_reg1})" $each_inst reg_path inst_path inst_name reg_name
            # Check if data buffer of the clock crosser instance exists or get synthesized away
            set reg2_collection [get_registers -nowarn ${inst_path}${inst_name}${to_reg2}[*]]
            set reg2_num [llength [query_collection -report -all $reg2_collection]]
             
            # Apply constraints common in both STA and FIT
            set_net_delay -from [get_pins -compatibility_mode *${module_name}:*|${from_reg1}|q]    -to [get_registers *${module_name}:*|${to_reg1}] -max $max_delay1
            set_net_delay -from [get_pins -compatibility_mode *${module_name}:*|${from_reg3}|q]    -to [get_registers *${module_name}:*|${to_reg3}] -max $max_delay3
            if {$reg2_num > 0} {
                set_net_delay -from [get_pins -compatibility_mode *${module_name}:*|${from_reg2}[*]|q] -to [get_registers *${module_name}:*|${to_reg2}[*]] -max $max_delay2
            }
            
            # Apply constraints specific to STA
            if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
                if {$reg2_num > 0} {
                    set_max_skew -from [get_registers "${inst_path}${inst_name}${from_reg1} ${inst_path}${inst_name}${from_reg2}[*]"] -to [get_registers "${inst_path}${inst_name}${to_reg1} ${inst_path}${inst_name}${to_reg2}[*]"] $max_skew
                    
                    set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg2}[*]] -to [get_registers ${inst_path}${inst_name}${to_reg2}[*]] 100ns
                    set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg2}[*]] -to [get_registers ${inst_path}${inst_name}${to_reg2}[*]] -100ns
                }
                
                set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg1}] -to [get_registers ${inst_path}${inst_name}${to_reg1}] 100ns
                set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg1}] -to [get_registers ${inst_path}${inst_name}${to_reg1}] -100ns
                
                set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg3}] -to [get_registers ${inst_path}${inst_name}${to_reg3}] 100ns
                set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg3}] -to [get_registers ${inst_path}${inst_name}${to_reg3}] -100ns
            
            # Apply constraints specific to FIT
            } else {
                # Relax the fitter effort
                set_max_delay -from [get_registers *${module_name}:*|${from_reg1}]    -to [get_registers *${module_name}:*|${to_reg1}] 8ns
                set_min_delay -from [get_registers *${module_name}:*|${from_reg1}]    -to [get_registers *${module_name}:*|${to_reg1}] -100ns
                if {$reg2_num > 0} {
                    set_max_delay -from [get_registers *${module_name}:*|${from_reg2}[*]] -to [get_registers *${module_name}:*|${to_reg2}[*]] 8ns
                    set_min_delay -from [get_registers *${module_name}:*|${from_reg2}[*]] -to [get_registers *${module_name}:*|${to_reg2}[*]] -100ns
                }
                set_max_delay -from [get_registers *${module_name}:*|${from_reg3}]    -to [get_registers *${module_name}:*|${to_reg3}] 8ns
                set_min_delay -from [get_registers *${module_name}:*|${from_reg3}]    -to [get_registers *${module_name}:*|${to_reg3}] -100ns
            }
        }
    }
}

# Constraint Standard Synchronizer
altera_eth_tse_constraint_std_sync

# MAC without FIFO
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[9]}] -to [get_registers {*altera_tse_fifoless_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|frm_length[*]}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]

if {[expr ($ENABLE_SUP_ADDR == 1)]} {
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[16]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[17]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|command_config[18]}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_fifoless_mac_rx:U_RX|*}]
}

if {[expr ($ENABLE_MAC_FLOW_CTRL == 1)]} {
   set_false_path -from [get_registers *|altera_tse_fifoless_mac_rx:*|pause_quant_val*] -to [get_registers *|altera_tse_fifoless_mac_tx:*|pause_latch*]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|pause_quant_reg*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|pause_quant_reg*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|holdoff_quant*}] -to [get_registers {*|altera_tse_fifoless_mac_tx:U_TX|*}]

}

# Magic packet detection 
if {[expr ($ENABLE_MAGIC_DETECT == 1)]} {
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_0[*]}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
   set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|mac_1[*]}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]

   if {[expr ($ENABLE_SUP_ADDR == 1)]} {
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_0*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_1*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_2*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
      set_false_path -from [get_registers {*|altera_tse_shared_register_map:U_REG|smac_3*}] -to [get_registers {*|altera_tse_magic_detection:U_MAGIC|*}]
   }
}

altera_eth_tse_constraint_clock_crosser

# GMII loopback
if {[expr ($ENABLE_GMII_LOOPBACK == 1)]} {
   altera_eth_tse_constraint_ptr  altera_tse_a_fifo_24:U_LBFF|altera_tse_gray_cnt:U_RD  g_out  altera_tse_a_fifo_24:U_LBFF|altera_eth_tse_std_synchronizer_bundle:U_SYNC_RD_G_PTR|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*  din_s1  7.5ns  6ns
   altera_eth_tse_constraint_ptr  altera_tse_a_fifo_24:U_LBFF|altera_tse_gray_cnt:U_WRT  g_out  altera_tse_a_fifo_24:U_LBFF|altera_eth_tse_std_synchronizer_bundle:U_SYNC_WR_G_PTR|altera_eth_tse_std_synchronizer:*|altera_std_synchronizer_nocut:*  din_s1  7.5ns  6ns
}

# Half duplex logic
if {[expr ($ENABLE_HD_LOGIC == 1)]} {
   set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
   set_multicycle_path -setup 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*] -to [ get_registers *]
   set_multicycle_path -setup 5 -from [ get_registers *] -to [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*]
     
   set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_altsyncram_dpm_fifo:U_RTSM|altsyncram*] -to [ get_registers *]
   set_multicycle_path -hold 5 -from [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*] -to [ get_registers *]
   set_multicycle_path -hold 5 -from [ get_registers *] -to [ get_registers *|altera_tse_fifoless_mac_tx:U_TX|altera_tse_fifoless_retransmit_cntl:U_RETR|*]
}

#**************************************************************
# Set False Path for altera_tse_reset_synchronizer
#**************************************************************
set tse_aclr_counter 0
set tse_clrn_counter 0
set tse_aclr_collection [get_pins -compatibility_mode -nocase -nowarn *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|aclr]
set tse_clrn_collection [get_pins -compatibility_mode -nocase -nowarn *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|clrn]
foreach_in_collection tse_aclr_pin $tse_aclr_collection {
    set tse_aclr_counter [expr $tse_aclr_counter + 1]
}
foreach_in_collection tse_clrn_pin $tse_clrn_collection {
    set tse_clrn_counter [expr $tse_clrn_counter + 1]
}
if {$tse_aclr_counter > 0} {
    set_false_path -to [get_pins -compatibility_mode -nocase *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|aclr]
}

if {$tse_clrn_counter > 0} {
    set_false_path -to [get_pins -compatibility_mode -nocase *|altera_tse_reset_synchronizer:*|altera_tse_reset_synchronizer_chain*|clrn]
}

set_project_mode -always_show_entity_name $old_mode
