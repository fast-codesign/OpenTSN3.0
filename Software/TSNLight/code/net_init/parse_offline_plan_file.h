#ifndef _PARSE_OFFLINE_PLAN_H__
#define _PARSE_OFFLINE_PLAN_H__

#include"../cnc_api/include/cnc_api.h"
#include <libxml/xmlmemory.h>  
#include <libxml/parser.h>  

#include "net_init.h"




chip_reg_info chip_reg;//芯片配置的单个寄存器
chip_cfg_table_info chip_cfg_table;//芯片配置的表项信息


map_table_info map_table[32];//hcp映射表
remap_table_info remap_table[256];//hcp重映射表

u16 imac;

void parse_offline_plan_register( xmlNodePtr cur);
void parse_offline_plan_forward_table(xmlNodePtr cur);
void parse_offline_plan_inject_table(xmlNodePtr cur);
void parse_offline_plan_submit_table(xmlNodePtr cur);
void parse_offline_plan_gate_table(xmlNodePtr cur);
void parse_offline_plan_map_table_entry(xmlNodePtr cur,u8 entry_idx);
void parse_offline_plan_map_table(xmlNodePtr cur);
void parse_offline_plan_remap_table_entry(xmlNodePtr cur,u8 entry_idx);
void parse_offline_plan_remap_table(xmlNodePtr cur);
int parse_offline_plan_node(xmlDocPtr doc, xmlNodePtr cur);
int parse_offline_plan_doc(char *docname);
int parse_offline_plan_cfg_file();
int offline_plan_cfg();


#endif

