
#include "parse_offline_plan_file.h"
#include <libxml/xmlmemory.h>  
#include <libxml/parser.h>  


#define OFFLINE_PLAN_XML_FILE "offline_plan_xml.xml"


void parse_offline_plan_register( xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	//cur=cur->xmlChildrenNode;


	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"time_slot")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_reg.slot_len = atoi(value);
			printf("time_slot %d\n",chip_reg.slot_len);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"qbv_or_qch")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_reg.qbv_or_qch = atoi(value);
			printf("qbv_or_qch %d\n",chip_reg.qbv_or_qch);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"inject_slot_period")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_reg.inj_slot_period = atoi(value);
			printf("inject_slot_period %d\n",chip_reg.inj_slot_period);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"submit_slot_period")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_reg.sub_slot_period = atoi(value);
			printf("submit_slot_period %d\n",chip_reg.sub_slot_period);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"rc_regulation_value")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_reg.rc_regulation_value = atoi(value);
			printf("rc_regulation_value %d\n",time_slot);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"be_regulation_value")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_reg.be_regulation_value = atoi(value);
			printf("be_regulation_value %d\n",time_slot);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"unmap_regulation_value")==0)
		{
			value=xmlNodeGetContent(entry);
			chip_reg.umap_regulation_value = atoi(value);
			printf("unmap_regulation_value %d\n",time_slot);
		}




            //xmlFree(IP);
            //xmlFree(MAC);
    }


	
}

 void parse_offline_plan_forward_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 flowid = 0;
	//cur=cur->xmlChildrenNode;


	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
			printf("entry\n");
			value=xmlGetProp(entry,(const xmlChar *)"flowid");
			flowid = atoi(value);
			//printf("flowid %d\n",flowid);

			value=xmlGetProp(entry,(const xmlChar *)"outport");
			chip_cfg_table.table[flowid] = atoi(value);
			printf("flowid %d, outport %d\n",flowid,chip_cfg_table.table[flowid]);			
		}
		else
		{
			printf("no entry\n");
		}
         //xmlFree(IP);
            //xmlFree(MAC);
    }

}

 void parse_offline_plan_inject_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	//cur=cur->xmlChildrenNode;
	u16 entry_idx = 0;

	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
			printf("entry\n");
			value=xmlGetProp(entry,(const xmlChar *)"time_slot");
			time_slot = atoi(value);
			printf("time_slot %d\n",time_slot);

			value=xmlGetProp(entry,(const xmlChar *)"inject_addr");
			chip_cfg_table.table[entry_idx] = atoi(value);
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | time_slot<<5;
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | 0x8000;
			
			printf("inject_addr %d\n",chip_cfg_table.table[entry_idx]);	
			entry_idx++;
		}
		else
		{
			printf("no entry\n");
		}
         //xmlFree(IP);
            //xmlFree(MAC);
    }	
}

 void parse_offline_plan_submit_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	//cur=cur->xmlChildrenNode;
	u16 entry_idx = 0;


	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
			printf("entry\n");
			value=xmlGetProp(entry,(const xmlChar *)"time_slot");
			time_slot = atoi(value);
			printf("time_slot %d\n",time_slot);

			value=xmlGetProp(entry,(const xmlChar *)"submit_addr");
			chip_cfg_table.table[entry_idx] = atoi(value);
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | time_slot<<5;
			chip_cfg_table.table[entry_idx] = chip_cfg_table.table[entry_idx] | 0x8000;

			printf("submit_addr %d\n",chip_cfg_table.table[entry_idx]);		
			entry_idx++;
		}
		else
		{
			printf("no entry\n");
		}
         //xmlFree(IP);
            //xmlFree(MAC);
    }	
}

 void parse_offline_plan_gate_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;


	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
			printf("gate entry\n");
			value=xmlGetProp(entry,(const xmlChar *)"time_slot");
			time_slot = atoi(value);
			printf("time_slot %d\n",time_slot);

			value=xmlGetProp(entry,(const xmlChar *)"state");
			chip_cfg_table.table[time_slot] = atoi(value);
			printf("state %d\n",chip_cfg_table.table[time_slot]);			
		}
		else
		{
			printf("no gate entry\n");
		}
         //xmlFree(IP);
            //xmlFree(MAC);
    }	
}





 void parse_offline_plan_map_table_entry(xmlNodePtr cur,u8 entry_idx)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	//cur=cur->xmlChildrenNode;
	//u16 entry_idx = 0;

	for(entry=cur->children;entry;entry=entry->next)
	{  
		
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"src_ip")==0)
		{
			value=xmlNodeGetContent(entry);			
			sscanf(value,"%hhd.%hhd.%hhd.%hhd.",&map_table[entry_idx].src_ip[0],
												&map_table[entry_idx].src_ip[1],
												&map_table[entry_idx].src_ip[2],
												&map_table[entry_idx].src_ip[3]);
			//time_slot = atoi(value);
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

		//map_table[entry_idx].addr = map_table[entry_idx].addr + 1;


            //xmlFree(IP);
            //xmlFree(MAC);
    }	
}




 void parse_offline_plan_map_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	cur=cur->xmlChildrenNode;

	u8 entry_idx = 0;
	//cur=cur->xmlChildrenNode;
	while(cur != NULL)
	{  
        /* 找到arp_table子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"entry"))
		{  
			printf("map_table entry\n");
			
			value=xmlGetProp(cur,(const xmlChar *)"id");
			time_slot = atoi(value);
			printf("id %d\n",time_slot);
			
            parse_offline_plan_map_table_entry( cur,entry_idx); /* 解析arp_table子节点 */  
			entry_idx++;
        }
		else
		{
			printf("have no map_table entry\n");
		}
        
        cur = cur->next; /* 下一个子节点 */  
    }  


}

 void parse_offline_plan_remap_table_entry(xmlNodePtr cur,u8 entry_idx)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	//cur=cur->xmlChildrenNode;
	//u16 entry_idx = 0;

	for(entry=cur->children;entry;entry=entry->next)
	{  
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


            //xmlFree(IP);
            //xmlFree(MAC);
    }	
}


 void parse_offline_plan_remap_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 time_slot = 0;
	cur=cur->xmlChildrenNode;
	
	u8 entry_idx = 0;


	//cur=cur->xmlChildrenNode;
	while(cur != NULL)
	{  
        /* 找到arp_table子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"entry"))
		{  
			printf("map_table entry\n");
			
			value=xmlGetProp(cur,(const xmlChar *)"id");
			time_slot = atoi(value);
			printf("id %d\n",time_slot);
			
			
            parse_offline_plan_remap_table_entry( cur,entry_idx); /* 解析arp_table子节点 */  
			entry_idx++;
        }
		else
		{
			printf("have no map_table entry\n");
		}
        
        cur = cur->next; /* 下一个子节点 */  
    }  

}


void time_table_order( )
{
	u32 table_idx = 0;
	
	u16 time_slot1 = 0;
	u16 time_slot2 = 0;

	
	u32 tmp_table = 0;
	u16 table_num = 0;
	
	u16 j=0;
	
	for(table_idx=0;table_idx<65535;table_idx++)
	{
		if((chip_cfg_table.table[table_idx] >> 15) == 1 )//表示该表项有效
		{
			continue;
		}
		else
		{
			table_num = table_idx;//获取表项的数量
			break;
		}		
	}
	
	for(table_idx=0;table_idx<table_num-1;table_idx++)//冒泡排序，从小到大依次排列
	{
		for(j=0;j<table_num-table_idx-1;j++)
		{
		
			time_slot1 = (chip_cfg_table.table[j] >> 5) & 0x3ff;
			time_slot2 = (chip_cfg_table.table[j+1] >> 5) & 0x3ff;
			if(time_slot1>time_slot2)
			{
				tmp_table = chip_cfg_table.table[j+1];
				chip_cfg_table.table[j+1] = chip_cfg_table.table[j];
				chip_cfg_table.table[j]   = tmp_table;
			}
		}
	}

	
	for(table_idx=0;table_idx<table_num;table_idx++)//冒泡排序，从小到大依次排列
	{
		printf("time_slot111 %d\n",(chip_cfg_table.table[table_idx] >> 5) & 0x3ff);
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

	value = xmlGetProp(cur, (const xmlChar *)"imac");
	imac = atoi(value);
	printf("imac %d\n",imac);

	//配置上报使能
	cfg_data = 1;
	printf("cfg report enable %d\n",cfg_data);
	build_send_chip_cfg_pkt(imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);//配置端口类型


	cur=cur->xmlChildrenNode;
	while(cur != NULL)
	{  
        /* 找到arp_table子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"register"))
		{  
			printf("register\n");
			memset(&chip_reg,0,sizeof(chip_reg));
			//赋默认值
			chip_reg.cfg_finish = 3;
			chip_reg.report_enable = 1;
			chip_reg.report_period = 1;
			chip_reg.slot_len = 4;
			chip_reg.inj_slot_period = 4;
			chip_reg.sub_slot_period = 4;
			chip_reg.port_type = get_port_type_from_init_cfg(imac);			
			chip_reg.qbv_or_qch = 1;

			
            parse_offline_plan_register(cur);
			printf("start cfg single reg\n");
			ret = cfg_chip_single_register(imac,chip_reg);//配置所有的单个寄存器
			if(ret == -1)
			{
				printf("cfg_chip_single_register fail\n");
				return -1;
			}
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"forward_table"))
		{  
			printf("forward_table\n");
			memset(&chip_cfg_table,0,sizeof(chip_cfg_table));
            parse_offline_plan_forward_table(cur);  			
			printf("cfg_chip_table\n");
			cfg_chip_table(imac,CHIP_FLT_BASE_ADDR,chip_cfg_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"inject_table"))
		{  
			printf("inject_table\n");
			memset(&chip_cfg_table,0,sizeof(chip_cfg_table));
            parse_offline_plan_inject_table(cur);
			//对注入时刻表按照时间槽从小到大进行排序，
			time_table_order();
			
			cfg_chip_table(imac,CHIP_TIS_BASE_ADDR,chip_cfg_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"submit_table"))
		{  
			printf("submit_table\n");
			memset(&chip_cfg_table,0,sizeof(chip_cfg_table));
            parse_offline_plan_submit_table(cur);  
			
			//对注入时刻表按照时间槽从小到大进行排序，
			time_table_order();
			
			cfg_chip_table(imac,CHIP_TSS_BASE_ADDR,chip_cfg_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"gate_table"))
		{  
			//默认为1，全开
			printf("gate_table\n");
			memset(&chip_cfg_table,0,sizeof(chip_cfg_table));
            parse_offline_plan_gate_table(cur);  

			value=xmlGetProp(cur,(const xmlChar *)"id");
			id = atoi(value);
			printf("id %d\n",id);
			switch(id)
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
        if(!xmlStrcmp(cur->name, (const xmlChar *)"map_table"))
		{  
			printf("map_table\n");
			memset(&map_table,0,sizeof(map_table_info));
			for(entry_idx=0;entry_idx<32;entry_idx++)
			{
				map_table[entry_idx].addr = HCP_MAP_BASE_ADDR + entry_idx;
			}

			
            parse_offline_plan_map_table(cur); 
/*
			sprintf(test_rule,"%s","ether[3:1]=0x4 and ether[12:2]=0xff01");
			sprintf(temp_net_interface,"%s","enp0s17");
			
			
			data_pkt_receive_init(test_rule,temp_net_interface);//数据接收初始化
			data_pkt_send_init(temp_net_interface);//数据发送初始化

*/
			
			cfg_hcp_map_table(imac,map_table);
        }
        if(!xmlStrcmp(cur->name, (const xmlChar *)"remap_table"))
		{  
			printf("remap_table\n");
			memset(&remap_table,0,sizeof(remap_table_info));
			for(entry_idx=0;entry_idx<256;entry_idx++)
			{
				remap_table[entry_idx].addr = HCP_REMAP_BASE_ADDR + entry_idx;
			}
            parse_offline_plan_remap_table(cur);
			cfg_hcp_remap_table(imac,remap_table);
        }
		else
		{
			printf("have no node\n");
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




/* 解析文档 */  
int parse_offline_plan_doc(char *docname)
{  
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
    doc = xmlParseFile("offline_plan_xml.xml");  
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
    if(xmlStrcmp(cur->name, (const xmlChar *)"nodes")){  
        fprintf(stderr, "document of the wrong type, root node != nodes");  
        xmlFreeDoc(doc);  
        return -1;  
    }  
	printf("parse_offline_plan_doc12\n");
	
    /* 遍历文档树 */  

	cfg_num = get_cfg_num_from_init_cfg();//获取配置交换机的数量
	tmp_cfg_order = get_cfg_order_from_init_cfg();//获取配置顺序
	tmp_cur = cur->xmlChildrenNode; 
    //cur = cur->xmlChildrenNode; 
    //根据初始配置的顺序，来进行离线规划配置
	for(imac_idx=0;imac_idx<cfg_num;imac_idx++)
	{
		cur = tmp_cur;
		while(cur != NULL)
		{  
		
			if(!xmlStrcmp(cur->name, (const xmlChar *)"node"))
			{  
				printf("node\n");
				
				value = xmlGetProp(cur, (const xmlChar *)"imac");
				imac = atoi(value);
				printf("imac %d\n",imac);
				/*
				printf("tmp_cfg_order %d\n",tmp_cfg_order[imac_idx]);
				printf("tmp_cfg_order %d,%d,%d,%d\n",tmp_cfg_order[0],tmp_cfg_order[1],tmp_cfg_order[2],tmp_cfg_order[3]);
				printf("cfg_num %d\n",cfg_num);
				*/
				if(imac == tmp_cfg_order[imac_idx])
				{
					parse_offline_plan_node(doc, cur); /* 解析arp_table子节点 */  
					break;
				}

			}
			else
			{
				printf("have no node\n");
			}
			
			cur = cur->next; /* 下一个子节点 */  
		}  

	}


  
    xmlFreeDoc(doc); /* 释放文档树 */  
    return 0;  
}  

  


int parse_offline_plan_cfg_file()
{

	char *docname = OFFLINE_PLAN_XML_FILE;
	printf("docname %s\n",docname);
	if (parse_offline_plan_doc(docname) != 0) 
	{
		fprintf(stderr, "Failed to parse xml.\n");
		return -1;
	}

	return 0;
}


int offline_plan_cfg()
{

	parse_offline_plan_cfg_file();

	return 0;
}
