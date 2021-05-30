/** *************************************************************************
 *  @file       basic_cfg.c
 *  @brief	    基础配置函数
 *  @date		2021/04/24 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/
#include "local_cfg.h"



u8 port_id = 0;//交换机的端口

static chip_cfg_table_info chip_cfg_table;//芯片配置的表项信息






//解析每一个转发表
void parse_plan_forward_entry(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 flowid = 0;

	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"flowid")==0)
		{
			value=xmlNodeGetContent(entry);
			flowid = atoi(value);
			printf("flowid %d\n",flowid);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"outport")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_cfg_table.table[flowid] = atoi(value);
			printf("outport %d\n",chip_cfg_table.table[flowid]);
		}

	}
}

void parse_offline_plan_forward_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	//cur=cur->xmlChildrenNode;


	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
			printf("entry\n");
			parse_plan_forward_entry(entry);
		}
		else
		{
			printf("no entry\n");
		}

    }

}

//解析每一个注入时刻表
void parse_plan_inject_entry(xmlNodePtr cur,u16 entry_idx)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;

	//u16 entry_idx = 0;
	
	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"time_slot")==0)
		{
			value=xmlNodeGetContent(entry);
			time_slot = atoi(value);
			printf("time_slot %d\n",time_slot);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"inject_addr")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_cfg_table.table[entry_idx] = atoi(value);
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | time_slot<<5;
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | 0x8000;
			printf("inject_addr %d\n",chip_cfg_table.table[entry_idx]);	
			entry_idx++;			
		}

	}
}

//解析每一个提交时刻表
void parse_plan_submit_entry(xmlNodePtr cur,u16 entry_idx)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;

	//u16 entry_idx = 0;
	
	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"time_slot")==0)
		{
			value=xmlNodeGetContent(entry);
			time_slot = atoi(value);
			printf("time_slot %d\n",time_slot);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"inject_addr")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_cfg_table.table[entry_idx] = atoi(value);
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | time_slot<<5;
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | 0x8000;
			printf("inject_addr %d\n",chip_cfg_table.table[entry_idx]);	
			entry_idx++;			
		}

	}
}


//解析每一个门控时刻表
void parse_plan_gate_entry(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;

	u16 entry_idx = 0;
	
	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"time_slot")==0)
		{
			value=xmlNodeGetContent(entry);
			time_slot = atoi(value);
			printf("time_slot %d\n",time_slot);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"gate_state")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_cfg_table.table[time_slot] = atoi(value);
			printf("state %d\n",chip_cfg_table.table[time_slot]);			
		}

	}
}

//解析映射表
void parse_plan_map_entry(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;

	u16 entry_idx = 0;
	
	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"map_id")==0)
		{
			value=xmlNodeGetContent(entry);			
			entry_idx = atoi(value);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"src_ip")==0)
		{
			value=xmlNodeGetContent(entry);			
			sscanf(value,"%hhd.%hhd.%hhd.%hhd.",&map_table[entry_idx].src_ip[0],
												&map_table[entry_idx].src_ip[1],
												&map_table[entry_idx].src_ip[2],
												&map_table[entry_idx].src_ip[3]);
			printf("src_ip %d.%d.%d.%d\n",map_table[entry_idx].src_ip[0],
										  map_table[entry_idx].src_ip[1],
										  map_table[entry_idx].src_ip[2],
										  map_table[entry_idx].src_ip[3]);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"dst_ip")==0)
		{
			value=xmlNodeGetContent(entry);
			sscanf(value,"%hhd.%hhd.%hhd.%hhd.",&map_table[entry_idx].dst_ip[0],
												&map_table[entry_idx].dst_ip[1],
												&map_table[entry_idx].dst_ip[2],
												&map_table[entry_idx].dst_ip[3]);
			//time_slot = atoi(value);
			printf("dst_ip %d.%d.%d.%d\n",map_table[entry_idx].dst_ip[0],
										  map_table[entry_idx].dst_ip[1],
										  map_table[entry_idx].dst_ip[2],
										  map_table[entry_idx].dst_ip[3]);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"src_port")==0)
		{
			value=xmlNodeGetContent(entry);
			map_table[entry_idx].src_port = atoi(value);
			printf("src_port %d\n",map_table[entry_idx].src_port);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"dst_port")==0)
		{
			value=xmlNodeGetContent(entry);
			map_table[entry_idx].dst_port = atoi(value);
			printf("dst_port %d\n",map_table[entry_idx].dst_port);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"protocol_type")==0)
		{
			value=xmlNodeGetContent(entry);
			map_table[entry_idx].pro_type = atoi(value);
			printf("protocol_type %d\n",map_table[entry_idx].pro_type);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"flow_type")==0)
		{
			value=xmlNodeGetContent(entry);
			map_table[entry_idx].tsntag.flow_type = atoi(value);
			printf("flow_type %d\n",map_table[entry_idx].tsntag.flow_type);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"flow_id")==0)
		{
			value=xmlNodeGetContent(entry);
			map_table[entry_idx].tsntag.flow_id = atoi(value);
			printf("flow_type %d\n",map_table[entry_idx].tsntag.flow_id);

		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"inject_addr")==0)
		{
			value=xmlNodeGetContent(entry);
			map_table[entry_idx].tsntag.inject_addr = atoi(value);
			printf("inject_addr %d\n",map_table[entry_idx].tsntag.inject_addr);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"submit_addr")==0)
		{
			value=xmlNodeGetContent(entry);
			map_table[entry_idx].tsntag.submit_addr = atoi(value);
			printf("submit_addr %d\n",map_table[entry_idx].tsntag.submit_addr);

		}


	}
}


void parse_plan_remap_entry(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	u16 entry_idx = 0;
	
	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"remap_id")==0)
		{
			value=xmlNodeGetContent(entry);			
			entry_idx = atoi(value);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"flow_id")==0)
		{
			value=xmlNodeGetContent(entry);
			remap_table[entry_idx].flowID = atoi(value);
			printf("flow_id %d\n",remap_table[entry_idx].flowID);
		}
		else if(xmlStrcasecmp(entry->name,(const xmlChar *)"dmac")==0)
		{
			value=xmlNodeGetContent(entry);
			sscanf(value,"%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",&remap_table[entry_idx].dmac[0],
														 &remap_table[entry_idx].dmac[1],
														 &remap_table[entry_idx].dmac[2],
														 &remap_table[entry_idx].dmac[3],
														 &remap_table[entry_idx].dmac[4],
														 &remap_table[entry_idx].dmac[5]);			
			printf("dmac %2x:%2x:%2x:%2x:%2x:%2x\n",remap_table[entry_idx].dmac[0],
													remap_table[entry_idx].dmac[1],
													remap_table[entry_idx].dmac[2],
													remap_table[entry_idx].dmac[3],
													remap_table[entry_idx].dmac[4],
													remap_table[entry_idx].dmac[5]);
		}
		else if(xmlStrcasecmp(entry->name,(const xmlChar *)"outport")==0)
		{
			value=xmlNodeGetContent(entry);
			remap_table[entry_idx].outport = atoi(value);
			printf("outport %d\n",remap_table[entry_idx].outport);
		}
		else
		{
			printf("have no remap_table_entry\n");
		}

    }	
}

 void parse_offline_plan_table(u32 table_type,xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	//cur=cur->xmlChildrenNode;

	u16 entry_idx = 0;

	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
			printf("entry\n");
			switch(table_type)
			{
				case CHIP_TIS_BASE_ADDR :parse_plan_inject_entry(entry,entry_idx);break;
				case CHIP_TSS_BASE_ADDR :parse_plan_submit_entry(entry,entry_idx);break;
				case CHIP_FLT_BASE_ADDR :parse_plan_forward_entry(entry);break;
				case CHIP_QGC0_BASE_ADDR:parse_plan_gate_entry(entry);break;
				case HCP_MAP_BASE_ADDR  :parse_plan_map_entry(entry);break;
				case HCP_REMAP_BASE_ADDR:parse_plan_remap_entry(entry);break;


			}
			entry_idx++;
			
		}
		else if(xmlStrcasecmp(entry->name,(const xmlChar *)"port_id")==0)
		{
			printf("port_id\n");
			value=xmlNodeGetContent(entry);
			port_id = atoi(value);
		}
		else
		{
			printf("no entry\n");
		}

    }
}


/* 解析arp_entry，把值取出来放到arp表中 */  
 int parse_offline_plan_node(xmlDocPtr doc, xmlNodePtr cur)
{  
	 char test_rule[64] = {0};
	 char temp_net_interface[16]={0};

	int ret = 0;
	xmlChar* value;
	xmlNodePtr entry;
    xmlChar *IP,*MAC;

	u16 id = 0;
	u32 gate_cfg = 0;
	u32 cfg_data = 0;


	int i = 0;
	u16 flowid = 0;

	u16 entry_idx = 0;//对表项赋默认值	

	u16 imac = 0;
	u16 node_idx = 0;
	u16 forward_idx = 0;

	u16 temp_flowid = 0;

	cur=cur->xmlChildrenNode;
	while(cur != NULL)
	{  
        /* 找到arp_table子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"IMAC"))
		{  
			value=xmlNodeGetContent(cur);;
			imac = atoi(value);
			printf("imac %d\n",imac);

			//配置上报使能
			cfg_data = 1;
			printf("cfg report enable %d\n",cfg_data);
			build_send_chip_cfg_pkt(imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);//配置端口类型

        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"forwarding_table"))
		{  
			printf("forward_table\n");
			memset(&chip_cfg_table,0,sizeof(chip_cfg_table));
			
			//把初始配置的转发表拷贝到离线规划的xml文本中
			//循环查找所有初始配置节点
			for(node_idx=0;node_idx<cur_node_num;node_idx++)
			{
				printf("1111\n");
				//如果初始配置节点的imac与当前配置节点的imac相同
				if(init_cfg[node_idx].imac == imac)
				{
					//查找该节点的初始配置转发表，并赋值到本地配置
					for(forward_idx=0;forward_idx<init_cfg[node_idx].forward_table_num;forward_idx++)
					{
						printf("2222\n");
						temp_flowid = init_cfg[node_idx].forward_table[forward_idx].flowid;
						chip_cfg_table.table[temp_flowid] = init_cfg[node_idx].forward_table[forward_idx].outport;				
					}
				}
				
			}
						
            parse_offline_plan_forward_table(cur);  			
			printf("cfg_chip_table\n");
			cfg_chip_table(imac,CHIP_FLT_BASE_ADDR,chip_cfg_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"pkt_injection_table"))
		{  
			printf("inject_table\n");
			memset(&chip_cfg_table,0,sizeof(chip_cfg_table));
            parse_offline_plan_table(CHIP_TIS_BASE_ADDR,cur);
			
			cfg_chip_table(imac,CHIP_TIS_BASE_ADDR,chip_cfg_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"pkt_submission_table"))
		{  
			printf("submit_table\n");
			memset(&chip_cfg_table,0,sizeof(chip_cfg_table));
            parse_offline_plan_table(CHIP_TSS_BASE_ADDR,cur);  

			cfg_chip_table(imac,CHIP_TSS_BASE_ADDR,chip_cfg_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"gate_control_list_table"))
		{  
			//默认为1，全开
			printf("gate_table\n");
			memset(&chip_cfg_table,255,sizeof(chip_cfg_table));
            parse_offline_plan_table(CHIP_QGC0_BASE_ADDR,cur);  

			switch(port_id)
			{
				case 0: gate_cfg=CHIP_QGC0_BASE_ADDR;break;
				case 1: gate_cfg=CHIP_QGC1_BASE_ADDR;break;
				case 2: gate_cfg=CHIP_QGC2_BASE_ADDR;break;
				case 3: gate_cfg=CHIP_QGC3_BASE_ADDR;break;
				case 4: gate_cfg=CHIP_QGC4_BASE_ADDR;break;
				case 5: gate_cfg=CHIP_QGC5_BASE_ADDR;break;
				case 6: gate_cfg=CHIP_QGC6_BASE_ADDR;break;
				case 7: gate_cfg=CHIP_QGC7_BASE_ADDR;break;
			}
			cfg_chip_table(imac,gate_cfg,chip_cfg_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"TX_FL-tag_mapping_table"))
		{  
			printf("map_table\n");
			memset(&map_table,0,sizeof(map_table_info));
			
			//32条映射表,初始化每条映射表的地址
			for(entry_idx=0;entry_idx<32;entry_idx++)
			{
				map_table[entry_idx].addr = HCP_MAP_BASE_ADDR + entry_idx;
			}

			
           parse_offline_plan_table(HCP_MAP_BASE_ADDR,cur); 
		
			cfg_hcp_map_table(imac,map_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"RX_FL-tag_remapping_table"))
		{  
			printf("remap_table\n");
			memset(&remap_table,0,sizeof(remap_table_info));
			for(entry_idx=0;entry_idx<256;entry_idx++)
			{
				remap_table[entry_idx].addr = HCP_REMAP_BASE_ADDR + entry_idx;
			}
            parse_offline_plan_table(HCP_REMAP_BASE_ADDR,cur);
			cfg_hcp_remap_table(imac,remap_table);
        }
       
        cur = cur->next; /* 下一个子节点 */  		
	}
		
	//最后配置关闭上报功能
	cfg_data = 0;
	printf("close imac=%d report\n",imac);
	build_send_chip_cfg_pkt(imac,
						CHIP_REPORT_EN_ADDR,
						1,
						(u32 *)&cfg_data);

    return 0;  
}



int parse_offline_plan_cfg_file(u8 *docname)
{

	
	printf("docname %s\n",docname);
    /* 定义文档和节点指针 */  
    xmlDocPtr doc;  
    xmlNodePtr cur;  
	xmlNodePtr tmp_cur; 

	xmlChar* value;


	u16 imac = 0;
	u16 imac_idx = 0;
	u16 *tmp_cfg_order = (u16 *)malloc(sizeof(u16));
	u16 cfg_num = 0;
	

	printf("parse_offline_plan_doc\n");
	printf("docname %s\n",docname);

	
    /* 进行解析，如果没成功，显示一个错误并停止 */  
    doc = xmlParseFile(docname);  
    //doc = xmlReadFile(docname,"GB2312",XML_PARSE_RECOVER); 
	printf("999999999999\n");
    if(doc == NULL){  
        fprintf(stderr, "Document not parse successfully. \n");  
        return -1;  
    }  
	printf("parse_offline_plan_doc13\n");
    /* 获取文档根节点，若无内容则释放文档树并返回 */  
    cur = xmlDocGetRootElement(doc);  
    if(cur == NULL){  
        fprintf(stderr, "empty document\n");  
        xmlFreeDoc(doc);  
        return -1;  
    }  
  
    /* 确定根节点名是否为nodes，不是则返回 */  
    if(xmlStrcmp(cur->name, (const xmlChar *)"network_plan_cfg")){  
        fprintf(stderr, "document of the wrong type, root node != network_plan_cfg");  
        xmlFreeDoc(doc);  
        return -1;  
    }  
	printf("parse_offline_plan_doc12\n");
	
	cur = cur->xmlChildrenNode;
    /* 遍历文档树 */  

	while(cur != NULL)
	{  
	
		if(!xmlStrcmp(cur->name, (const xmlChar *)"switch"))
		{  
			printf("switch\n");
			
			parse_offline_plan_node(doc, cur); /* 解析arp_table子节点 */  


		}
		else
		{
			printf("have no node\n");
		}
		
		cur = cur->next; /* 下一个子节点 */  
	}  



  
    xmlFreeDoc(doc); /* 释放文档树 */  
    return 0; 

	return 0;
}
	


int local_cfg(u8 *pkt,u16 pkt_len)
{
	int ret = 0;
	u16 imac = 0;//节点的imac地址
	chip_reg_info *temp_reg = NULL;//节点上报的单个寄存器	

	u8 *temp_pkt = NULL;//

	u16 flowid_idx = 0;

	u32 cfg_data = 0;

	//在该状态下在，只解析配置文本，进行配置，不需要判断报文的内容
	
	
	
	parse_offline_plan_cfg_file(OFFLINE_PLAN_XML_FILE);

	G_STATE = SYNC_INIT_S;
	//G_STATE = NW_RUNNING_S;
		
}
		
		
	
#if 0

int main(int argc,char* argv[])
{
	
	local_cfg("sdksidh");
	return 0;
}
#endif
