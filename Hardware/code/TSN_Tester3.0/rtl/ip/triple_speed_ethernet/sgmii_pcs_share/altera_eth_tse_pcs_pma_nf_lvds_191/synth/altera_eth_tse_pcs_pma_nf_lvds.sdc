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
set IS_SGMII 0
set CONNECT_TO_MAC 1
set IS_INT_FIFO 0
set IS_HD_LOGIC 0
set ENABLE_REV_LOOPBACK 0
set ENABLE_TIMESTAMPING 0

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
    
    set_net_delay -from [get_pins -compatibility_mode *${module_name}:*|${from_reg1}|q]    -to [get_registers *${module_name}:*|${to_reg1}] -max $max_delay1
    set_net_delay -from [get_pins -compatibility_mode *${module_name}:*|${from_reg2}[*]|q] -to [get_registers *${module_name}:*|${to_reg2}[*]] -max $max_delay2
    set_net_delay -from [get_pins -compatibility_mode *${module_name}:*|${from_reg3}|q]    -to [get_registers *${module_name}:*|${to_reg3}] -max $max_delay3
    
    if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
        # Check for instances
        set inst [get_registers -nowarn *${module_name}:*|${from_reg1}]
        
        # Check number of instances
        set inst_num [llength [query_collection -report -all $inst]]
        if {$inst_num > 0} {
            # Uncomment line below for debug purpose
            #puts "${inst_num} ${module_name} instance(s) found"
        } else {
            # Uncomment line below for debug purpose
            #puts "No ${module_name} instance found"
        }
        
        # Constraint one instance at a time to avoid set_max_skew apply to all instances
        foreach_in_collection each_inst_tmp $inst {
        set each_inst [get_node_info -name $each_inst_tmp] 
            # Get the path to instance
            regexp "(.*${module_name})(:.*|)(${from_reg1})" $each_inst reg_path inst_path inst_name reg_name
            
            # Check if unused data buffer get synthesized away
            set reg2_collection [get_registers -nowarn ${inst_path}${inst_name}${to_reg2}[*]]
            set reg2_num [llength [query_collection -report -all $reg2_collection]]
            
            if {$reg2_num > 0} {
                set_max_skew -from [get_registers "${inst_path}${inst_name}${from_reg1} ${inst_path}${inst_name}${from_reg2}[*]"] -to [get_registers "${inst_path}${inst_name}${to_reg1} ${inst_path}${inst_name}${to_reg2}[*]"] $max_skew
                
                set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg2}[*]] -to [get_registers ${inst_path}${inst_name}${to_reg2}[*]] 100ns
                set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg2}[*]] -to [get_registers ${inst_path}${inst_name}${to_reg2}[*]] -100ns
            }
            
            set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg1}] -to [get_registers ${inst_path}${inst_name}${to_reg1}] 100ns
            set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg1}] -to [get_registers ${inst_path}${inst_name}${to_reg1}] -100ns
            
            set_max_delay -from [get_registers ${inst_path}${inst_name}${from_reg3}] -to [get_registers ${inst_path}${inst_name}${to_reg3}] 100ns
            set_min_delay -from [get_registers ${inst_path}${inst_name}${from_reg3}] -to [get_registers ${inst_path}${inst_name}${to_reg3}] -100ns
        }
        
    } else {
        # Relax the fitter effort
        set_max_delay -from [get_registers *${module_name}:*|${from_reg1}]    -to [get_registers *${module_name}:*|${to_reg1}] 8ns
        set_min_delay -from [get_registers *${module_name}:*|${from_reg1}]    -to [get_registers *${module_name}:*|${to_reg1}] -100ns
        
        set_max_delay -from [get_registers *${module_name}:*|${from_reg2}[*]] -to [get_registers *${module_name}:*|${to_reg2}[*]] 8ns
        set_min_delay -from [get_registers *${module_name}:*|${from_reg2}[*]] -to [get_registers *${module_name}:*|${to_reg2}[*]] -100ns
        
        set_max_delay -from [get_registers *${module_name}:*|${from_reg3}]    -to [get_registers *${module_name}:*|${to_reg3}] 8ns
        set_min_delay -from [get_registers *${module_name}:*|${from_reg3}]    -to [get_registers *${module_name}:*|${to_reg3}] -100ns
    }
    
}

# Constraint Standard Synchronizer
altera_eth_tse_constraint_std_sync

if { [ expr ($IS_SGMII == 1)] } {

    altera_eth_tse_constraint_ptr  altera_tse_a_fifo_24:*|altera_tse_gray_cnt:U_RD  g_out  altera_tse_a_fifo_24:*altera_std_synchronizer_nocut:*  din_s1  7.5ns  6ns
    altera_eth_tse_constraint_ptr  altera_tse_a_fifo_24:*|altera_tse_gray_cnt:U_WRT  g_out  altera_tse_a_fifo_24:*altera_std_synchronizer_nocut:*  din_s1  7.5ns  6ns

	if {[expr ($CONNECT_TO_MAC == 1)]} {
	  if {[expr ($IS_INT_FIFO == 0)]} {
		  if {[expr ($IS_HD_LOGIC == 1)]} {
			 altera_eth_tse_constraint_net_delay  *altera_tse_top_sgmii*:U_SGMII|altera_tse_colision_detect:U_COL|state*  *altera_tse_fifoless_mac_tx:U_TX|gm_rx_col_reg*  6ns
		  }
	  }
	}	
} else {
   if {[expr ($ENABLE_REV_LOOPBACK == 1)]} {
      altera_eth_tse_constraint_ptr  altera_tse_a_fifo_24:*|altera_tse_gray_cnt:U_RD  g_out  altera_tse_a_fifo_24:*altera_std_synchronizer_nocut:*  din_s1  7.5ns  6ns
      altera_eth_tse_constraint_ptr  altera_tse_a_fifo_24:*|altera_tse_gray_cnt:U_WRT  g_out  altera_tse_a_fifo_24:*altera_std_synchronizer_nocut:*  din_s1  7.5ns  6ns
   }
}

if {[expr ($ENABLE_TIMESTAMPING == 1)]} {
   set regs [get_registers -nowarn *altera_tse_ph_calculator:*|altera_eth_tse_ptp_std_synchronizer:U_SYNC_WR_PTR|altera_std_synchronizer_nocut:*|din_s1]
   if {[llength [query_collection -report -all $regs]] > 0} {
      altera_eth_tse_constraint_ptr  altera_tse_ph_calculator:phase_calculator.ph_cal_inst  wr_ptr_sample  altera_tse_ph_calculator:*|altera_eth_tse_ptp_std_synchronizer:U_SYNC_WR_PTR|altera_std_synchronizer_nocut:*  din_s1  4.5ns  3ns
   }

   set regs [get_registers -nowarn *altera_tse_ph_calculator:*|altera_eth_tse_ptp_std_synchronizer:U_SYNC_RD_PTR|altera_std_synchronizer_nocut:*|din_s1]
   if {[llength [query_collection -report -all $regs]] > 0} {
      altera_eth_tse_constraint_ptr  altera_tse_ph_calculator:phase_calculator.ph_cal_inst  rd_ptr_sample  altera_tse_ph_calculator:*|altera_eth_tse_ptp_std_synchronizer:U_SYNC_RD_PTR|altera_std_synchronizer_nocut:*  din_s1  4.5ns  3ns
   }
}

# Clock Crosser
altera_eth_tse_constraint_clock_crosser

# False path marker used in auto negotiation module
altera_eth_tse_constraint_net_delay  *  *altera_tse_false_path_marker:*|data_out_reg*  6ns

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
