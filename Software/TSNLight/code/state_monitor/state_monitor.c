/** *************************************************************************
 *  @file       net_init.c
 *  @brief	    状态检测进程
 *  @date		2020/11/25 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/
#include "state_monitor.h"

#define BASE_TIMER_S 10  //s
#define BASE_TIMER_US 0  //us


#define TIME_OUT 10  //s


//定时器锁，修改超时的值
pthread_mutex_t timer_lock;

#define TOPOLOGY_INFO_XML_FILE "topolopy_info_xml.xml"


//增加统计信息的累加的数据结构
chip_static node_cnt[500];



//硬件结构数组
hw_info chip[MAX_NODE_NUM];

//上报默认配置
int report_default_cfg(u16 dimac)
{
	u32 default_report_type   = 0;//单个寄存器
	u32 default_report_period = 1000;//每秒上报一次
	u32 default_report_en 	 = 1;//默认开启上报

	
	build_send_chip_cfg_pkt(dimac,CHIP_REPORT_PERIOD_ADDR,1,(u32 *)&default_report_period);	//上报周期
	build_send_chip_cfg_pkt(dimac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&default_report_type);//上报类型
	build_send_chip_cfg_pkt(dimac,CHIP_REPORT_EN_ADDR,1,(u32 *)&default_report_en);//上报使能
	





	return 0;
}


//网络上报配置
int net_report_cfg()
{
	u16 node_idx = 0;
	//test:MAX_NODE_NUM - 10
	for(node_idx=0;node_idx<10;node_idx++)
	{
		if(chip[node_idx].valid == 1)//说明该节点有效
		{
			printf("node imac %d\n",node_idx);
			report_default_cfg(chip[node_idx].imac);//进行默认上报配置
		}
		else
		{
			printf("node %d not exist\n",node_idx);
		}
	}
}


/* 解析arp_entry，把值取出来放到arp表中 */  
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
            parse_topology_node(doc, cur); /* 解析arp_table子节点 */  
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


//解析文本中的拓扑信息，存储在拓扑的数据结构中
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

//定时器回调函数，判断各个节点是否超时
void timer_callback()
{
	u16 node_idx = 0;
	//test:MAX_NODE_NUM - 1
	for(node_idx=0;node_idx<10;node_idx++)
	{
		if(chip[node_idx].valid == 1)//说明该节点有效
		{
			if(chip[node_idx].state.timeout==0)
			{
				chip[node_idx].state.online = 1;//离线
				printf("imac=%d node offline\n",chip[node_idx].imac);
			}
			else
			{
				pthread_mutex_lock(&timer_lock);
				chip[node_idx].state.timeout--;//自减，需要加锁修改
				pthread_mutex_unlock(&timer_lock);				
				printf("imac=%d node online\n",chip[node_idx].imac);
			}
		}
		else
		{
			
			printf("node %d not exist\n",node_idx);
		}
	}
	printf("************************************\n");

	return;
}



/*定时器处理线程*/
void state_monitor_timer(void *argv)
{
	
	struct itimerval tick;
	
	pthread_detach(pthread_self());
		
	printf("state_monitor start!\n");
	signal(SIGALRM, timer_callback);
	memset(&tick, 0, sizeof(tick));
	
	//Timeout to run first time
	tick.it_value.tv_sec = BASE_TIMER_S;
	tick.it_value.tv_usec = BASE_TIMER_US;
	
	//After first, the Interval time for clock
	tick.it_interval.tv_sec = BASE_TIMER_S;
	tick.it_interval.tv_usec = BASE_TIMER_US;
	
	if(setitimer(ITIMER_REAL, &tick, NULL) < 0)
	{
		printf("Set timer failed!\n");
	}
	
	while(1)
	{
		pause();
	}

	printf("exit state_monitor_timer\n");
	
}




/*
u16 get_chip_report_type(u8 *pkt,u16 len)
{
	u16 report_type = 0;
	pkt = pkt + len - 2;//上报类型在最后两个字节
	report_type = (*pkt)<<8 + *(pkt+1);
	return report_type;
}
*/


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

	node_cnt[imac].chip_module_status.ts_inj_overflow_error_cnt  += tmp_chip_static->chip_module_status.ts_inj_overflow_error_cnt;
	node_cnt[imac].chip_module_status.ts_inj_underflow_error_cnt += tmp_chip_static->chip_module_status.ts_inj_underflow_error_cnt;
	node_cnt[imac].chip_module_status.ts_sub_overflow_error_cnt  += tmp_chip_static->chip_module_status.ts_sub_overflow_error_cnt;
	node_cnt[imac].chip_module_status.ts_sub_underflow_error_cnt += tmp_chip_static->chip_module_status.ts_sub_underflow_error_cnt;

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

void state_monitor_callback(u_char *user, const struct pcap_pkthdr *pkthdr, const u_char *packet)
{
	printf("receive pkt\n");
	cnc_pkt_print((u8*)packet,pkthdr->len);
	//解析上报报文
	u16 imac=0;
	u8* pkt = NULL;
	u16 pkt_len = 0;

	u16 report_type = 0;

	pkt_len = pkthdr->len;//获取报文长度

	u32 cfg_data = 0;
	//获取simac，
	imac = get_simac_from_tsmp_pkt((u8*)packet,pkthdr->len);
	printf("imac = %0x \n",imac);
	if(imac > MAX_NODE_NUM)
	{
		printf("imac error \n");
		return;
	}
	chip[imac].state.timeout = TIME_OUT;
	report_type = get_chip_report_type((u8*)packet,pkthdr->len);

	printf("report_type %d\n",report_type);
	if(report_type == CHIP_REG_REPORT)
	{
		printf("CHIP_REG_REPORT\n");
		//获取offset值
		chip[imac].state.offset = get_offset_from_pkt((u8*)packet,pkthdr->len);
		printf("imac = %d, offset = %lld\n",imac,chip[imac].state.offset);
		if(chip[imac].state.offset > 50)
		{
			printf("net have no sync\n");
		}

		//配置上报类型为状态上报
		cfg_data = CHIP_STATE_REPORT;
		build_send_chip_cfg_pkt(imac,CHIP_REPORT_TYPE_ADDR,1,&cfg_data);
		
	}
	else if(report_type == CHIP_STATE_REPORT)
	{
		printf("CHIP_STATE_REPORT\n");
		//获取各个节点的状态
		parse_chip_state_report(imac,&chip[imac].state,(u8*)packet,pkthdr->len);
		//配置上报类型为寄存器上报
		cfg_data = CHIP_REG_REPORT;
		build_send_chip_cfg_pkt(imac,CHIP_REPORT_TYPE_ADDR,1,&cfg_data);
		
	}
	else
	{
		printf("REPORT ERROR\n");
	}

	
}



int main(int argc,char* argv[])
{
	//状态检测进程
	
	int ret = -1;
	pthread_t timerid;



	//初始化进程
	char test_rule[64] = {0};
	char temp_net_interface[16]={0};
	if(argc != 2)
	{
		printf("input format:./monitor net_interface\n");
		return 0;
	}


	//libpcap initialization
	sprintf(test_rule,"%s","ether[3:1]=0x1 and ether[12:2]=0xff01");
	//报文类型为1表示beacon上报，为4表示HCP上报
	sprintf(temp_net_interface,"%s","enp0s17");

	//sprintf(test_rule,"%s","ether[12:2]=0xff01");
	//sprintf(temp_net_interface,"%s",argv[1]);

	
	data_pkt_receive_init(test_rule,temp_net_interface);//数据接收初始化
	data_pkt_send_init(temp_net_interface);//数据发送初始化
	sprintf(temp_net_interface,"%s",argv[1]);

	


	//解析文本拓扑拓扑信息
	parse_topology_info();
	
	//根据拓扑信息，对各个节点进行默认上报配置
	net_report_cfg();

	//创建定时器线程，用于周期性判断设备是否离线
	ret=pthread_create(&timerid,NULL,(void *)state_monitor_timer,NULL); 

	data_pkt_receive_loop(state_monitor_callback);
	

	
	return 0;
	
	
}
