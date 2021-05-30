#include "state_monitor.h"

#define NO_PKT_TIMEOUT 10000000 // us
#define TOPOLOGY_INFO_XML_FILE "./state_monitor/topolopy_info_xml.xml"


/*增加统计信息的累加的数据结构*/
chip_static node_cnt[500];

/*硬件结构数组*/
hw_info chip[MAX_NODE_NUM];

/*上一次接收到某节点的上报报文时间*/
struct timeval tv_node[MAX_NODE_NUM]; 

struct timeval report_tv;

/*first packet process flag*/
u8 is_first_pkt = 0;
u16 valid_node_num = 0;

u16 offline_node_cnt = 0;

/*默认的网络上报配置*/
int report_default_cfg(u16 dimac)
{
	u32 default_report_type   = CHIP_STATE_REPORT;//状态上报报文
	u32 default_report_period = 1000;//每秒上报一次
	u32 default_report_en 	 = 1;//默认开启上报

	
	build_send_chip_cfg_pkt(dimac,CHIP_REPORT_PERIOD_ADDR,1,(u32 *)&default_report_period);	//上报周期
	build_send_chip_cfg_pkt(dimac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&default_report_type);//上报类型
	build_send_chip_cfg_pkt(dimac,CHIP_REPORT_EN_ADDR,1,(u32 *)&default_report_en);//上报使能
	
	return 0;
}

/*网络上报配置*/
int net_report_cfg()
{
	u16 node_idx = 0;
	//test:MAX_NODE_NUM - 10
	for(node_idx=0;node_idx<10;node_idx++)
	{
		if(chip[node_idx].valid == 1)//说明该节点有效
		{
			printf("node imac %d\n",node_idx);
			valid_node_num ++;
			report_default_cfg(chip[node_idx].imac);//进行默认上报配置
		}
		else
		{
			printf("node %d not exist\n",node_idx);
		}
	}
}

/* 解析xml文件，构造文档树，把值取出来放到节点信息表中 */  
static void parse_topology_node(xmlDocPtr doc, xmlNodePtr cur)
{	
	xmlChar* value;
	xmlNodePtr entry;
	xmlChar *IP,*MAC;

	u8 port_id = 0;
	
	int i = 0;
	u16 flowid = 0;

	value = xmlGetProp(cur, (const xmlChar *)"imac");
	flowid = atoi(value);
	chip[flowid].imac = flowid;
	printf("imac %d\n",flowid);
	
	chip[flowid].valid = 1;//有效位置1
	chip[flowid].state.online = 0;//初始在线
	chip[flowid].state.timeout = 10;//设置初始超时时间为10
	
	value = xmlGetProp(cur, (const xmlChar *)"sync_type");
	if(strcmp(value,"master")==0)
	{
	chip[flowid].sync_type = 0;
	printf("master %d\n",chip[flowid].sync_type);
	}
	else if(strcmp(value,"slave")==0)
	{
	chip[flowid].sync_type = 1;
	printf("slave %d\n",chip[flowid].sync_type);
	}
	else
	printf("sync_type error\n");

	value = xmlGetProp(cur, (const xmlChar *)"port_type");
	chip[flowid].port_type = atoi(value);
	printf("port_type %d\n",chip[flowid].port_type);

	for(entry=cur->children;entry;entry=entry->next)
	{	
		if(xmlStrcmp(entry->name,(const xmlChar *)"link")==0)
		{
			value=xmlGetProp(entry,(const xmlChar *)"local_port");
			port_id = atoi(value);
			printf("local_port %d\n",port_id);
			chip[flowid].port_state[port_id].valid = 1;
			chip[flowid].port_state[port_id].local_port = port_id;

			value=xmlGetProp(entry,(const xmlChar *)"remote_port");
			chip[flowid].port_state[port_id].remote_port = atoi(value);
			printf("remote_port %d\n",chip[flowid].port_state[port_id].remote_port);

			value=xmlGetProp(entry,(const xmlChar *)"remote_device");
			if(strcmp(value,"switch")==0)
			{
				chip[flowid].port_state[port_id].remote_device = 1;
				printf("switch %d\n",chip[flowid].port_state[port_id].remote_device);
			}
			else if(strcmp(value,"controler")==0)
			{
				chip[flowid].port_state[port_id].remote_device = 0;
				printf("controler %d\n",chip[flowid].port_state[port_id].remote_device);
			}
			else
			{
				chip[flowid].port_state[port_id].remote_device = 2;
				printf("endstation %d\n",chip[flowid].port_state[port_id].remote_device);
			}
			value=xmlGetProp(entry,(const xmlChar *)"addr");
			chip[flowid].port_state[port_id].imac = atoi(value);
			printf("addr %d\n",chip[flowid].port_state[port_id].imac);
		}
			//xmlFree(IP);
			//xmlFree(MAC);
	} 
	return;  
}

/* 解析文档 */  
int parse_topology_doc(char *docname)
{  
    /* 定义文档和节点指针 */  
    xmlDocPtr doc;  
    xmlNodePtr cur;  

	xmlChar* value;

	
    /* 进行解析，如果没成功，显示一个错误并停止 */  
    doc = xmlParseFile(docname);  
    if(doc == NULL){  
        fprintf(stderr, "Document not parse successfully. \n");  
        return -1;  
    }  
  
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

	
    /* 遍历文档树 */  
    cur = cur->xmlChildrenNode;  
    while(cur != NULL)
	{   
        if(!xmlStrcmp(cur->name, (const xmlChar *)"node"))
		{  
			printf("node\n");
            parse_topology_node(doc, cur); /* 解析系欸但信息表子节点 */  
        }
		else
		{
			printf("have no node\n");
		}
        
        cur = cur->next; /* 下一个子节点 */  
    }  

  
    xmlFreeDoc(doc); /* 释放文档树 */  
    return 0;  
}  

/*解析文本中的拓扑信息，存储在拓扑的数据结构中*/
int parse_topology_info()
{
	char *docname = TOPOLOGY_INFO_XML_FILE;
	if (parse_topology_doc(docname) != 0) 
	{
		fprintf(stderr, "Failed to parse xml.\n");
		return -1;
	}
	return 0;
}

/*获取报文的上报类型*/
u16 get_chip_report_type(u8 *pkt,u16 len)
{
	u16 report_type = 0;
	pkt = pkt + len - 2;//上报类型在最后两个字节
	report_type = (*pkt)<<8 + *(pkt+1);
	return report_type;
}

/*获取报文的上报类型*/
u8 get_pkt_type(u8 *pkt,u16 len)
{
	u8 report_type = 0;
	pkt = pkt + 3;//上报类型在最后两个字节
	report_type = (*pkt);
	return report_type;
}

/*打印节点的状态信息*/
void printf_chip_state_info(chip_static *tmp_chip_static)
{
	int port_idx = 0;

	//printf("host_rx_cnt 	 %d\n",htons(tmp_chip_static->chip_pkt_static.host_rx_cnt));
	printf("host_rx_cnt 	 %d\n",tmp_chip_static->chip_pkt_static.host_rx_cnt);
	printf("host_tx_cnt %d\n",tmp_chip_static->chip_pkt_static.host_tx_cnt);
	printf("host_discard_cnt %d\n",tmp_chip_static->chip_pkt_static.host_discard_cnt);
	for(port_idx=0;port_idx<8;port_idx++)
	{
		printf("port[%d] port_rx_cnt %d\n",port_idx,tmp_chip_static->chip_pkt_static.rx_discard_cnt[port_idx].port_rx_cnt);
		printf("port[%d] port_tx_cnt %d\n",port_idx,tmp_chip_static->chip_pkt_static.port_tx_cnt[port_idx]);
		printf("port[%d] port_discard_cnt %d\n",port_idx,tmp_chip_static->chip_pkt_static.rx_discard_cnt[port_idx].port_discard_cnt);
	}	
	


	printf("nmac_receive_cnt 	 %d\n",tmp_chip_static->chip_pkt_static.nmac_receive_cnt);
	printf("nmac_report_cnt 	 %d\n",tmp_chip_static->chip_pkt_static.nmac_report_cnt);


	printf("ts_inj_underflow_error_cnt 	 %d\n",tmp_chip_static->chip_module_status.ts_inj_underflow_error_cnt);
	printf("ts_inj_overflow_error_cnt 	 %d\n",tmp_chip_static->chip_module_status.ts_inj_overflow_error_cnt);
	printf("ts_sub_underflow_error_cnt 	 %d\n",tmp_chip_static->chip_module_status.ts_sub_underflow_error_cnt);
	printf("ts_sub_overflow_error_cnt 	 %d\n",tmp_chip_static->chip_module_status.ts_sub_overflow_error_cnt);

//20210113修改，屏蔽掉打印状态信息的功能，只打印报文统计计数器，和free_buf_fifo_rdusedw
#if 0
	//printf("host_gmii_write_state 	 %d\n",tmp_chip_static->chip_module_status.host_gmii_write_state);
	printf("pkt_state 	 %d\n",tmp_chip_static->chip_module_status.pkt_state);
	printf("transmission_state 	 %d\n",tmp_chip_static->chip_module_status.transmission_state);
	printf("prp_state 	 %d\n",tmp_chip_static->chip_module_status.prp_state);
	printf("descriptor_state 	 %d\n",tmp_chip_static->chip_module_status.descriptor_state);
	printf("tim_state 	 %d\n",tmp_chip_static->chip_module_status.tim_state);
	printf("tom_state 	 %d\n",tmp_chip_static->chip_module_status.tom_state);
	printf("iv_ism_state 	 %d\n",tmp_chip_static->chip_module_status.iv_ism_state);
	printf("hrc_state 	 %d\n",tmp_chip_static->chip_module_status.hrc_state);
	printf("hos_state 	 %d\n",tmp_chip_static->chip_module_status.hos_state);
	printf("hoi_state 	 %d\n",tmp_chip_static->chip_module_status.hoi_state);
	printf("tsm_state 	 %d\n",tmp_chip_static->chip_module_status.tsm_state);
	printf("bufid_state 	 %d\n",tmp_chip_static->chip_module_status.bufid_state);
	printf("pdi_state 	 %d\n",tmp_chip_static->chip_module_status.pdi_state);
	printf("smm_state 	 %d\n",tmp_chip_static->chip_module_status.smm_state);
	printf("tdm_state 	 %d\n",tmp_chip_static->chip_module_status.tdm_state);

	//端口状态
	for(port_idx=0;port_idx<8;port_idx++)
	{
		printf("port[%d] osc_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].osc_state);
		printf("port[%d] prc_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].prc_state);
		printf("port[%d] gmii_write_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].gmii_write_state);
		printf("port[%d] gmii_read_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].descriptor_send_state);
		printf("port[%d] opc_state_p %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].opc_state_p);
		printf("port[%d] gmii_fifo_full %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].gmii_fifo_full);
		printf("port[%d] gmii_fifo_empty %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].gmii_fifo_empty);
		printf("port[%d] descriptor_extract_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].descriptor_extract_state);
		//printf("port[%d] frame_fragment_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].frame_fragment_state);
		printf("port[%d] descriptor_send_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].descriptor_send_state);
		printf("port[%d] data_splice_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].data_splice_state);
		printf("port[%d] input_buf_interface_state %d\n",port_idx,tmp_chip_static->chip_module_status.port[port_idx].input_buf_interface_state);

	}	

	printf("pkt_write_state 	 %d\n",tmp_chip_static->chip_module_status.pkt_write_state);
	printf("pkt_read_state 	 %d\n",tmp_chip_static->chip_module_status.pkt_read_state);
	printf("address_write_state 	 %d\n",tmp_chip_static->chip_module_status.address_write_state);
	printf("address_read_state 	 %d\n",tmp_chip_static->chip_module_status.address_read_state);

#endif
	printf("free_buf_fifo_rdusedw 	 %d\n",tmp_chip_static->chip_module_status.free_buf_fifo_rdusedw);


}

void host_to_net_short(u16 *host,u16 len)
{
	u16 idx = 0;
	for(idx = 0;idx<len;idx++)
	{
	
		if(idx>=(34) && idx<(34+12+3))
		{
			continue;

		}
	
		*(host+idx) = htons(*(host+idx));
		//printf("22222222 %d\n",*(host+idx));
	}
}

void get_cnt_info(u16 imac,chip_static *tmp_chip_static)
{
	int port_idx = 0;
	node_cnt[imac].chip_pkt_static.host_rx_cnt                += tmp_chip_static->chip_pkt_static.host_rx_cnt;
	node_cnt[imac].chip_pkt_static.host_tx_cnt                += tmp_chip_static->chip_pkt_static.host_tx_cnt;
	node_cnt[imac].chip_pkt_static.host_discard_cnt           += tmp_chip_static->chip_pkt_static.host_discard_cnt;

	node_cnt[imac].chip_pkt_static.host_in_queue_discard_cnt  += tmp_chip_static->chip_pkt_static.host_in_queue_discard_cnt;

	node_cnt[imac].chip_pkt_static.nmac_receive_cnt           += tmp_chip_static->chip_pkt_static.nmac_receive_cnt;
	node_cnt[imac].chip_pkt_static.nmac_report_cnt            += tmp_chip_static->chip_pkt_static.nmac_report_cnt;

	for(port_idx=0;port_idx<8;port_idx++)
	{
		node_cnt[imac].chip_pkt_static.port_tx_cnt[port_idx]                     += tmp_chip_static->chip_pkt_static.port_tx_cnt[port_idx];
		
		node_cnt[imac].chip_pkt_static.rx_discard_cnt[port_idx].port_discard_cnt += tmp_chip_static->chip_pkt_static.rx_discard_cnt[port_idx].port_discard_cnt;
		node_cnt[imac].chip_pkt_static.rx_discard_cnt[port_idx].port_rx_cnt      += tmp_chip_static->chip_pkt_static.rx_discard_cnt[port_idx].port_rx_cnt;

	}

	node_cnt[imac].chip_module_status.ts_inj_overflow_error_cnt      += tmp_chip_static->chip_module_status.ts_inj_overflow_error_cnt;
	node_cnt[imac].chip_module_status.ts_inj_underflow_error_cnt   += tmp_chip_static->chip_module_status.ts_inj_underflow_error_cnt;
	node_cnt[imac].chip_module_status.ts_sub_overflow_error_cnt    += tmp_chip_static->chip_module_status.ts_sub_overflow_error_cnt;
	node_cnt[imac].chip_module_status.ts_sub_underflow_error_cnt += tmp_chip_static->chip_module_status.ts_sub_underflow_error_cnt;

	//剩余bufID，不需要累加，表示瞬时剩余bufID
	node_cnt[imac].chip_module_status.free_buf_fifo_rdusedw              = tmp_chip_static->chip_module_status.free_buf_fifo_rdusedw;
}

void print_cnt_info(u16 imac)
{
	int port_idx = 0;

	//printf("host_rx_cnt 	 %d\n",htons(tmp_chip_static->chip_pkt_static.host_rx_cnt));
	printf("host_rx_cnt 	 %d\n",node_cnt[imac].chip_pkt_static.host_rx_cnt);
	printf("host_tx_cnt %d\n",     node_cnt[imac].chip_pkt_static.host_tx_cnt);
	printf("host_discard_cnt %d\n",node_cnt[imac].chip_pkt_static.host_discard_cnt);
	for(port_idx=0;port_idx<8;port_idx++)
	{
		printf("port[%d] port_rx_cnt %d\n",port_idx,node_cnt[imac].chip_pkt_static.rx_discard_cnt[port_idx].port_rx_cnt);
		printf("port[%d] port_tx_cnt %d\n",port_idx,node_cnt[imac].chip_pkt_static.port_tx_cnt[port_idx]);
		printf("port[%d] port_discard_cnt %d\n",port_idx,node_cnt[imac].chip_pkt_static.rx_discard_cnt[port_idx].port_discard_cnt);
		
	}	

	printf("nmac_receive_cnt 	 %d\n",node_cnt[imac].chip_pkt_static.nmac_receive_cnt);
	printf("nmac_report_cnt 	 %d\n",node_cnt[imac].chip_pkt_static.nmac_report_cnt);


	printf("ts_inj_underflow_error_cnt 	 %d\n",node_cnt[imac].chip_module_status.ts_inj_underflow_error_cnt);
	printf("ts_inj_overflow_error_cnt 	 %d\n",node_cnt[imac].chip_module_status.ts_inj_overflow_error_cnt);
	printf("ts_sub_underflow_error_cnt 	 %d\n",node_cnt[imac].chip_module_status.ts_sub_underflow_error_cnt);
	printf("ts_sub_overflow_error_cnt 	 %d\n",node_cnt[imac].chip_module_status.ts_sub_overflow_error_cnt);

	
	printf("free_buf_fifo_rdusedw	 %d\n",node_cnt[imac].chip_module_status.free_buf_fifo_rdusedw);
}

int parse_chip_state_report(u16 imac,chip_state_info *state_info,u8 *pkt,u16 len)
{
	int port_idx = 0;

	chip_static *tmp_chip_report = NULL;

	pkt = pkt + 16;//偏移16字节的TSMP头，获取数据域

	//获取各个节点的状态
	tmp_chip_report = (chip_static *)pkt;	
	//&(state_info->chip_report) = tmp_chip_report;
	memcpy(&(state_info->chip_report),tmp_chip_report,sizeof(chip_static));
	
	//printf("chip_pkt_static_report    sizeof %d\n",sizeof(chip_pkt_static_report));	
	//printf("chip_module_status_report sizeof %d\n",sizeof(chip_module_status_report));	
	//printf("chip_static               sizeof %d\n",sizeof(chip_static));
	//由于是16bit，因此需要字节除2
	host_to_net_short((u16 *)&(state_info->chip_report),sizeof(chip_static)/2);
		
	//(chip_static *)&(state_info->chip_report) = (chip_static *)pkt;

	get_cnt_info(imac,&(state_info->chip_report));//统计累计计数信息
	printf("*************print sum cnt***************\n");
	print_cnt_info(imac);//打印累计计数信息


	
	printf("*************print per cnt***************\n");
	printf_chip_state_info(&(state_info->chip_report));

	if(state_info->chip_report.chip_pkt_static.host_discard_cnt>0)
		printf("host_discard_cnt %d\n",state_info->chip_report.chip_pkt_static.host_discard_cnt);

	for(port_idx=0;port_idx<8;port_idx++)
	{
		if(state_info->chip_report.chip_pkt_static.rx_discard_cnt[port_idx].port_discard_cnt >0)
			printf("port[%d]_discard_cnt %d\n",port_idx,state_info->chip_report.chip_pkt_static.rx_discard_cnt[port_idx].port_discard_cnt);
	}

	return 0;
}

u64 get_offset_from_pkt(u8 *pkt,u16 len)
{
	return 0;
}

int state_monitor_init()
{
	return 0;
}

void state_monitor(u16 pkt_len, const unsigned char *packet_content)
{
	printf("*******************state_monitor************receive pkt\n");
	//cnc_pkt_print((u8*)packet_content,pkt_len);
	//解析上报报文
	u16 imac=0;
	u8* pkt = NULL;
	u16 report_type = 0;
	u32 cfg_data = 0;
	struct  timeval tv_current;

	//获取simac，
	imac = get_simac_from_tsmp_pkt((u8*)packet_content,pkt_len);
	printf("imac = %0x \n",imac);
	if(imac > MAX_NODE_NUM)
	{
		printf("imac error \n");
		return;
	}

	report_type = get_chip_report_type((u8*)packet_content,pkt_len);
	printf("report_type %d\n",report_type);
	if(report_type == CHIP_STATE_REPORT)
	{
		printf("CHIP_STATE_REPORT\n");
		//获取各个节点的状态
		parse_chip_state_report(imac,&chip[imac].state,(u8*)packet_content,pkt_len);
		//配置上报类型为状态上报
		cfg_data = CHIP_STATE_REPORT;
		//cfg_data = CHIP_REG_REPORT;
		//build_send_chip_cfg_pkt(imac,CHIP_REPORT_TYPE_ADDR,1,&cfg_data);	
	}
	else
	{
		printf("REPORT ERROR\n");
	}

	//chip[imac].state.timeout = TIME_OUT;
	gettimeofday(&tv_current,NULL);
	tv_node[imac] = tv_current;
}


#if 1
int send_remote_state()
{
	u16 port_idx = 0;
	state_report node_state[5];
	u16 imac;
	u16 node_idx = 0;

	for(int i = 0; i < MAX_NODE_NUM; i++)
	{
		if (chip[i].valid == 1)
		{
			node_state[node_idx].imac = ntohs(chip[i].imac);
			imac = chip[i].imac;
			node_state[node_idx].node_state = ntohs(chip[i].state.online);
			node_state[node_idx].inject_overflow = ntohs(node_cnt[imac].chip_module_status.ts_inj_overflow_error_cnt);
			node_state[node_idx].inject_underflow = ntohs(node_cnt[imac].chip_module_status.ts_inj_underflow_error_cnt);
			node_state[node_idx].submit_overflow = ntohs(node_cnt[imac].chip_module_status.ts_sub_overflow_error_cnt);
			node_state[node_idx].submit_underflow = ntohs(node_cnt[imac].chip_module_status.ts_sub_underflow_error_cnt);
			node_state[node_idx].offset = ntohl(chip[i].state.offset);
			for(port_idx = 0;port_idx < 9;port_idx++)
			{
				node_state[node_idx].port_state[port_idx].port_rx = ntohs(node_cnt[imac].chip_pkt_static.rx_discard_cnt[port_idx].port_rx_cnt);
				node_state[node_idx].port_state[port_idx].port_tx = ntohs(node_cnt[imac].chip_pkt_static.port_tx_cnt[port_idx]);
				node_state[node_idx].port_state[port_idx].port_discard = ntohs(node_cnt[imac].chip_pkt_static.rx_discard_cnt[port_idx].port_discard_cnt);
			}

			memset(&node_cnt[imac],0,sizeof(chip_static));
			node_idx ++;
		}
		else
		{
			continue;
		}
	}

	for(int i = 0;i < node_idx-1 ;i ++)
	{
		send_remote_confirm(0xf,sizeof(state_report),0,0, (u8 *)(node_state + i));
	}

	send_remote_confirm(0xf,sizeof(state_report),1,0, (u8 *)(node_state + node_idx -1));

	
	return 0;
	
}
#endif	


u16 state_monitor_timeout(struct timeval tv)
{
	if (is_first_pkt == 0)
	{
		parse_topology_info();
		net_report_cfg();
		for (int i = 0; i < valid_node_num+1; i++)
		{
			tv_node[i] = tv;
		}
		report_tv = tv;
		is_first_pkt = 1;
		return 0;
	}
	u16 node_idx = 0;
	struct  timeval tv_current,temp;
    u64 time_interval;
	//gettimeofday(&tv_current,NULL);
	tv_current = tv;

	for(node_idx=0;node_idx < 5;node_idx++)
	{
		if(chip[node_idx].valid == 1)//说明该节点有效
		{
			/*long time no pkt*/
			temp = tv_node[node_idx];
			time_interval = (tv_current.tv_sec - temp.tv_sec)*1000000 + (tv_current.tv_usec - temp.tv_usec);
			if(time_interval > NO_PKT_TIMEOUT)
			{
				chip[node_idx].state.online = 1;//离线
				offline_node_cnt ++;
				printf("******************************time intervel  %lld\n",time_interval);
				printf("imac=%d node offline\n",chip[node_idx].imac);
			}
			if(chip[node_idx].state.offset > PRECISION)
			{
				printf("imac=%d node out of precision    offset = %lld \n",chip[node_idx].imac,chip[node_idx].state.offset);
			}
			else
			{
				continue;
			}
		}
		else
		{
			//printf("node %d not exist\n",node_idx);
		}
	}

	//report 
	time_interval = (tv_current.tv_sec - report_tv.tv_sec)*1000000 + (tv_current.tv_usec - report_tv.tv_usec);
	if(time_interval > REPORT_INTERVAL)
	{
		send_remote_state();
		report_tv = tv;
	}
	
	// if (offline_node_cnt == valid_node_num)
	// {
	// 	G_STATE = INIT_S;
	// }
	return 0;
}

void update_offset(u8 imac,u64 offset)
{
	u64 old_v = chip[imac].state.max_offset;

	if (old_v < offset)
	{
		chip[imac].state.max_offset = offset;
	}

	chip[imac].state.offset = offset;
}
