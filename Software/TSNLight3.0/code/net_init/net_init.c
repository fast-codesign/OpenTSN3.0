/** *************************************************************************
 *  @file       net_init.c
 *  @brief	    网络初始化函数
 *  @date		2021/04/23 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/
#include "net_init.h"


#define MAX_INIT_FORWARD_NUM   100  /*最大初始转发表的数量为100*/
//#define INIT_MAX_NODE_NUM   10  /*最大初始转发表的数量为100*/

#if 1
#include "../arp_proxy/arp_proxy.h"
#include "../state_monitor/state_monitor.h"
#include "../ptp/ptp_single_process.h"
#include "../basic_cfg/basic_cfg.h"
#include "../local_cfg/local_cfg.h"
#endif


#if 0
int restart_num = 0;
int work_run = 1;


struct timeval state_tv;//网络运行状态的时间戳
struct timeval basic_tv;//基础配置状态的时间戳
struct timeval local_tv;//本地配置状态的时间戳

#endif


void parse_register_xml( xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;

	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"IMAC")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].imac = atoi(value);
			printf("IMAC %d\n",init_cfg[cur_node_num].imac);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"port_type")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.port_type = atoi(value);
			printf("port_type %d\n",init_cfg[cur_node_num].reg_data.port_type);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"time_slot")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.slot_len = atoi(value);
			printf("time_slot %d\n",init_cfg[cur_node_num].reg_data.slot_len);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"qbv_or_qch")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.qbv_or_qch = atoi(value);
			printf("qbv_or_qch %d\n",init_cfg[cur_node_num].reg_data.qbv_or_qch);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"inject_slot_period")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.inj_slot_period = atoi(value);
			printf("inject_slot_period %d\n",init_cfg[cur_node_num].reg_data.inj_slot_period);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"submit_slot_period")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.sub_slot_period = atoi(value);
			printf("submit_slot_period %d\n",init_cfg[cur_node_num].reg_data.sub_slot_period);
		}
		/*
		
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"rc_regulation_value")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.rc_regulation_value = atoi(value);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"be_regulation_value")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.be_regulation_value = atoi(value);
		}
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"unmap_regulation_value")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.umap_regulation_value = atoi(value);
		}
		*/
		if(xmlStrcasecmp(entry->name,(const xmlChar *)"ST_buf_threshold")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].reg_data.rc_regulation_value = atoi(value)-100;
			init_cfg[cur_node_num].reg_data.be_regulation_value = atoi(value);//BE比RC小100个bufid
			init_cfg[cur_node_num].reg_data.umap_regulation_value = atoi(value);
			printf("ST_buf_threshold %d\n",init_cfg[cur_node_num].reg_data.umap_regulation_value);
		}
		

    }

}


//解析每一个转发表
void parse_forward_entry(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 tmp_forward_idx = 0;
	for(entry=cur->children;entry;entry=entry->next)
	{  
		tmp_forward_idx = init_cfg[cur_node_num].forward_table_num;
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"flowid")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].forward_table[tmp_forward_idx].flowid = atoi(value);
			printf("flowid %d\n",init_cfg[cur_node_num].forward_table[tmp_forward_idx].flowid);
		}
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"outport")==0)
		{
			value=xmlNodeGetContent(entry);
			init_cfg[cur_node_num].forward_table[tmp_forward_idx].outport = atoi(value);
			printf("outport %d\n",init_cfg[cur_node_num].forward_table[tmp_forward_idx].outport);
			init_cfg[cur_node_num].forward_table_num++;//转发表的数量

		}

	}
}


 void parse_forward_table(xmlNodePtr cur)
{
	xmlNodePtr entry;
	xmlChar* value;
	u16 flowid = 0;


	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
			printf("entry\n");
			parse_forward_entry(entry);
			
		}
		else
		{
			printf("no entry\n");
		}

    }

}



/* 解析switch */  
static void parse_init_node(xmlDocPtr doc, xmlNodePtr cur)
{  
	xmlChar* value;
	xmlNodePtr entry;


	cur=cur->xmlChildrenNode;

	while(cur != NULL)
	{  
		printf("n11111\n");
        /* 找到register子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"register"))
		{  
			printf("register\n");
			//赋默认值
			init_cfg[cur_node_num].reg_data.cfg_finish = 2;
			init_cfg[cur_node_num].reg_data.report_enable = 1;
			init_cfg[cur_node_num].reg_data.report_period = 1;
			init_cfg[cur_node_num].reg_data.slot_len = 4;
			init_cfg[cur_node_num].reg_data.inj_slot_period = 4;
			init_cfg[cur_node_num].reg_data.sub_slot_period = 4;
			init_cfg[cur_node_num].reg_data.port_type = 0;			
			init_cfg[cur_node_num].reg_data.qbv_or_qch = 0;
			
			//解析寄存器标签
            parse_register_xml(cur);
        }
		if(!xmlStrcmp(cur->name, (const xmlChar *)"forward_table"))
		{  
			printf("forward_table\n");

            parse_forward_table(cur);  			
        }
		cur = cur->next; /* 下一个子节点 */  
	}
    return;  
}


/* 解析文档 */  
static int parse_init_doc(char *docname)
{  
    /* 定义文档和节点指针 */  
    xmlDocPtr doc;  
    xmlNodePtr cur;  

	xmlNodePtr entry;

	xmlChar* value;

	int ret = 0;
	
    /* 进行解析，如果没成功，显示一个错误并停止 */  
    doc = xmlParseFile(docname); 

    if(doc == NULL){  
        fprintf(stderr, "init_doc not parse successfully. \n");  
        return -1;  
    }  
  
    /* 获取文档根节点，若无内容则释放文档树并返回 */  
    cur = xmlDocGetRootElement(doc);  
    if(cur == NULL)
	{  
        fprintf(stderr, "empty document\n");  
        xmlFreeDoc(doc);  
        return -1;  
    }  
  
    /* 确定根节点名是否为network_init_cfg，不是则返回 */  
    if(xmlStrcmp(cur->name, (const xmlChar *)"network_init_cfg"))
	{  
        fprintf(stderr, "document of the wrong type, root node != network_init_cfg");  
        xmlFreeDoc(doc);  
        return -1;  
    }  
	
    /* 遍历文档树 */  
    cur = cur->xmlChildrenNode;  
    while(cur != NULL)
	{  
        /* 找到node子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"switch"))
		{  
			printf("switch\n");
            parse_init_node(doc, cur); /* 解析node子节点 */ 
			cur_node_num++;			
		}
		else if(!xmlStrcmp(cur->name, (const xmlChar *)"tsnlight_info"))
		{  
			printf("tsnlight_info\n");
			
			for(entry=cur->children;entry;entry=entry->next)
			{  
				if(xmlStrcasecmp(entry->name,(const xmlChar *)"master_imac")==0)
				{
					value=xmlNodeGetContent(entry);
					MASTER_IMAC = atoi(value);
					printf("MASTER_IMAC %d\n",MASTER_IMAC);
				}
				if(xmlStrcasecmp(entry->name,(const xmlChar *)"sync_period")==0)
				{
					value=xmlNodeGetContent(entry);
					SYNC_PERIOD = atoi(value);
					printf("SYNC_PERIOD %d\n",SYNC_PERIOD);
				}
				if(xmlStrcasecmp(entry->name,(const xmlChar *)"sync_flowID")==0)
				{
					value=xmlNodeGetContent(entry);
					SYNC_FLOWID = atoi(value);
					printf("SYNC_FLOWID %d\n",SYNC_FLOWID);
				}
				if(xmlStrcasecmp(entry->name,(const xmlChar *)"report_period")==0)
				{
					value=xmlNodeGetContent(entry);
					REPORT_PERIOD = atoi(value);
					printf("REPORT_PERIOD %d\n",REPORT_PERIOD);
				}
			}				
		}
		else
		{
			printf("have no switch\n");
		}
        
        cur = cur->next; /* 下一个子节点 */  
    }  

    xmlFreeDoc(doc); /* 释放文档树 */ 
	if(doc == NULL)
		printf("doc NULL\n");
	//doc = NULL;
	printf("free success\n");
    return 0;  
}  
  



int parse_init_cfg_xml(u8 *init_cfg_file_name)
{

	char *docname = INIT_XML_FILE;
	if (parse_init_doc(init_cfg_file_name) != 0) 
	{
		fprintf(stderr, "Failed to parse init_cfg_file_name.\n");
		return -1;
	}

	return 0;

}





int net_init(u8 *network_inetrface)
{
	int ret = 0;

	u8 *init_cfg_file_name = INIT_XML_FILE;//初始配置文本

	//初始化libnet和libpcap
	char test_rule[64] = {0};
	char temp_net_interface[16]={0};
	sprintf(test_rule,"%s","ether[12:2]=0xff01");
	sprintf(temp_net_interface,"%s",network_inetrface);


	//解析初始配置xml文本
	ret = parse_init_cfg_xml(init_cfg_file_name);
	if(ret == -1)
	{
		printf("parse_init_cfg_xml fail\n");
		return -1;
	}


	//初始化时间同步
	ret = ptp_init(50,SYNC_FLOWID,MASTER_IMAC,DEFAULT_PERCISION);
	if(ret == -1)
	{
		printf("init_ptp fail\n");
		return -1;
	}
	
	//初始化ARP代理
	ret = arp_table_init();
	if(ret == -1)
	{
		printf("arp_table_init fail\n");
		return -1;
	}
	
	//初始化状态检测
	ret = state_monitor_init();
	if(ret == -1)
	{
		printf("state_monitor_init fail\n");
		return -1;
	}
	
	//配置与控制器直连的交换机
	ret = init_cfg_fun(0);
	if(ret == -1)
	{
		printf("init_cfg_fun fail\n");
		return -1;
	}


	//初始化完成，跳转到基础配置状态
	G_STATE = BASIC_CFG_S;
	return 0;

}


#if 0

void basic_cfg_timeout_handle(struct timeval tv)
{


	//printf("basic_cfg_timeout_handle111\n");
	if(basic_tv.tv_sec == 0)
	{
		//第一次开始定时
		basic_tv.tv_sec = tv.tv_sec;
	}
	else
	{
		//判断是否超出最大基础配置时间
		if(tv.tv_sec - basic_tv.tv_sec > 10)
		{
			printf("error:basic cfg timeout\n");
			basic_tv.tv_sec = 0;//初始基础配置时间
			work_run = 0;//超时
		}

	}

}

void local_cfg_timeout_handle(struct timeval tv)
{

	printf("local_cfg_timeout_handle\n");
	if(local_tv.tv_sec == 0)
	{
		//第一次开始定时
		local_tv.tv_sec = tv.tv_sec;
	}
	else
	{
		//判断是否超出最大基础配置时间
		if(tv.tv_sec - local_tv.tv_sec > 100)
		{
			printf("error:basic cfg timeout\n");
			local_tv.tv_sec = 0;//初始基础配置时间
			work_run = 0;//超时
		}

	}
	
}

void remote_cfg_timeout_handle(struct timeval tv)
{
#if 0
	u8 pkt[128];
	memset(pkt,0,128);
	pkt[6] = 0x60;
	pkt[7] = 0x00;
	pkt[34] = 0x1f;
	pkt[35] = 0x90;
	pkt[36] = 0x1f;
	pkt[37] = 0x90;	
	
	//类型
	pkt[43] = 0x0c;
	//长度
	pkt[44] = 0x00;
	pkt[45] = 0x28;		
	//tail
	pkt[46] = 0x01;
	
	//imac
	pkt[47] = 0x00;
	pkt[48] = 0x01;
	
	//reg
	pkt[49] = 0x00;
	pkt[50] = 0x02;	
	pkt[51] = 0x00;
	pkt[52] = 0x01;	
	
	//映射表
	pkt[49] = 0xc0;
	pkt[50] = 0xa8;	
	pkt[51] = 0x01;
	pkt[52] = 0x02;	

	pkt[53] = 0xc0;
	pkt[54] = 0xa8;	
	pkt[55] = 0x01;
	pkt[56] = 0x03;		

	pkt[57] = 0x80;
	pkt[58] = 0x80;	

	pkt[59] = 0x70;
	pkt[60] = 0x70;

	pkt[61] = 0x11;	
	
	//流类型
	pkt[62] = 0x03;
	pkt[63] = 0x01;
	pkt[64] = 0x01;
	
	pkt[65] = 0x00;
	pkt[66] = 0x01;
	
	pkt[67] = 0x00;
	pkt[68] = 0x01;
	
	printf("start remote cfg\n");
	remote_cfg(pkt);
	G_STATE = SYNC_INIT_S;
#endif	
}

void cfg_verify_timeout_handle(struct timeval tv)
{
	G_STATE = SYNC_INIT_S;
}


void time_handle(int global_state,struct timeval tv)
{
    switch(global_state)//根据状态判断需要进行的超时处理逻辑
    {
        case  BASIC_CFG_S:basic_cfg_timeout_handle(tv);break;
        //网络基础配置
        
        case  LOCAL_PLAN_CFG_S:local_cfg_timeout_handle(tv);break;
			
        //本地规划配置

        case  REMOTE_PLAN_CFG_S:remote_cfg_timeout_handle(tv);break;
        //远程规划配置

        case  CONF_VERIFY_S:cfg_verify_timeout_handle(tv);break;
        //配置验证

        case  SYNC_INIT_S:
		{	
			printf("88888\n");
			sync_period_timeout();
			break;//时间同步初始化
		}
        case  NW_RUNNING_S:
		{
			printf("1111111\n");
		        //时间同步，状态监测，动态配置
			//state_monitor_timeout();
			//sync_period_timeout();	
			
			
			if(state_tv.tv_sec == 0)
			{
				//第一次开始定时
				state_tv.tv_sec = tv.tv_sec;
			}
			else
			{
				if(tv.tv_sec - state_tv.tv_sec > 10)
				{
					//send_remote_state();//发送上报状态
					state_tv.tv_sec = tv.tv_sec;//更新当前时间
				}
			}
			
			break;
		}

    }
}

void net_run(u8 *pkt,u16 pkt_length)
{
	
	dynamic_remote_cfg(pkt,pkt_length);
	
#if 1	
    u8 pkt_type = get_pkt_type(pkt,pkt_length);
    if(pkt_type == 0x01)
    {
    
		printf("get pkt223\n");
        ptp_handle(pkt_length,pkt);
    }  
    else if(pkt_type == 0x02)
    {
    
		printf("get pkt224\n");
        state_monitor(pkt_length,pkt);
    }  
    else if(pkt_type == 0x03)
    {
    
		printf("get pkt225\n");
        arp_reply(pkt_length,pkt);
    }
	
#endif
}

int cfg_varify(u8 *pkt)
{
	
	return 0;
}

int main(int argc,char* argv[])
{
	int ret = 0;
	//初始化进程
	char test_rule[64] = {0};
	char temp_net_interface[16]={0};

	
	struct timeval cur_time;//用于获取当前时间
	u16 pkt_len  = 0;//报文长度
	u8 *pkt      = NULL;//报文的指针


	if(argc != 2)
	{
		printf("input format:./tsnlight net_interface\n");
		return 0;
	}

	//libpcap initialization
	//sprintf(test_rule,"%s","ether[12:2]=0xff01");
	sprintf(temp_net_interface,"%s",argv[1]);

	data_pkt_receive_init(test_rule,temp_net_interface);//数据接收初始化
	data_pkt_send_init(temp_net_interface);//数据发送初始化

init:
    net_init(temp_net_interface);
    init_cfg_fun(init_cfg[0].imac);

	printf("enter while 1 G_STATE %d\n",G_STATE);
    while(1)
    {
		//每次获取一个报文
        pkt = data_pkt_receive_dispatch_1(&pkt_len);
       
        if(pkt != NULL)
        {
        	printf("get pkt111\n");
            switch(G_STATE)//根据状态判断需要进行的处理逻辑
            {
	            case  BASIC_CFG_S:		basic_cfg(pkt,pkt_len);break;		
	            case  LOCAL_PLAN_CFG_S: local_cfg(pkt,pkt_len);break;
	            case  REMOTE_PLAN_CFG_S:remote_cfg(pkt,pkt_len);break;
	            case  CONF_VERIFY_S:	cfg_varify(pkt);break;
	            case  SYNC_INIT_S:		ptp_handle(pkt_len,pkt);break;
	            case  NW_RUNNING_S:		net_run(pkt,pkt_len);break;
            } 
        }		
		printf("get pkt222\n");
		printf("G_STATE %d\n",G_STATE);
        gettimeofday(&cur_time,NULL);//获取当前时间，用于判断是否超时
        time_handle(G_STATE,cur_time);//根据本地时间判断是否超时

        if(work_run==1) //判断网络是否正常工作，该标志位在时间处理函数更改
            continue;
        else
        {
        	work_run = 1;
			goto init;//跳转到初始状态

		}
            
        if(restart_num>3)//判断重启是否超过三次
            break;
        else
            continue;
    }
	return 0;
}


#endif

