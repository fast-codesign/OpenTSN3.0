/** *************************************************************************
 *  @file       net_init.c
 *  @brief	    网络初始化进程主函数
 *  @date		2020/11/23 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/
#include "net_init.h"
#include "parse_offline_plan_file.h"

#include<sys/types.h>
#include<dirent.h>
#include<signal.h>
#include<time.h>



#define INIT_XML_FILE "init_cfg_xml.xml"

init_cfg_info init_cfg;
struct timeval tv;
struct timezone tz;


#define BUF_SIZE 1024


u8 port_type_info[100];


u16 cfg_order[500];
u16 cfg_order_idx;


#if 0
u8 *getPidByName(char* task_name)
{
    DIR *dir;
    struct dirent *ptr;
    FILE *fp;
    char filepath[50];//大小随意，能装下cmdline文件的路径即可
    char cur_task_name[50];//大小随意，能装下要识别的命令行文本即可
    char buf[BUF_SIZE];
    dir = opendir("/proc"); //打开路径
    if (NULL != dir)
    {
        while ((ptr = readdir(dir)) != NULL) //循环读取路径下的每一个文件/文件夹
        {
            //如果读取到的是"."或者".."则跳过，读取到的不是文件夹名字也跳过
            if ((strcmp(ptr->d_name, ".") == 0) || (strcmp(ptr->d_name, "..") == 0))
				continue;
            if (DT_DIR != ptr->d_type)
				continue;

            sprintf(filepath, "/proc/%s/status", ptr->d_name);//生成要读取的文件的路径
            fp = fopen(filepath, "r");//打开文件
            if (NULL != fp)
            {
                if( fgets(buf, BUF_SIZE-1, fp)== NULL)
				{
					fclose(fp);
					continue;
				}
				sscanf(buf, "%*s %s", cur_task_name);
				
                //如果文件内容满足要求则打印路径的名字（即进程的PID）
                if (!strcmp(task_name, cur_task_name))
					printf("PID:  %s\n", ptr->d_name);
                fclose(fp);
            }

        }
        closedir(dir);//关闭路径
    }

	return ptr->d_name;
}

#endif

u16 state_monitor_pid = 0;
u16 ptp_pid = 0;


int enable_application_service()
{
	u8 *ptp_pid_ptr = NULL;
	u8 *state_monitor_pid_ptr = NULL;
	
	system("./state_monitor &");
	system("./ptp master_imac=10 period=500 &");

	/*
	state_monitor_pid_ptr = getPidByName("state_monitor");
	state_monitor_pid = atoi(state_monitor_pid_ptr);

	printf("state_monitor start success\n");

	ptp_pid_ptr = getPidByName("ptp");
	ptp_pid = atoi(ptp_pid_ptr);

	printf("ptp start success\n");
	*/
	
}

void unable_application_service()
{
	system("killall ptp");
	system("killall state_monitor");
	/*
	kill(state_monitor_pid,9);
	printf("kill state_monitor\n");
	
	kill(ptp_pid,9);
	printf("kill ptp\n");
	*/
}


void sig_ctlc(int sig)		// 
{
	printf("sig = %d: sig_ctlc func\n", sig);
	unable_application_service();//杀死状态检测和时间同步进程
	printf("sig_ctlc return\n");
}


//程序进入休眠，执行程序的过程中按CTL + C不能是程序退出,而是唤醒程序，执行unable_application_service函数
void enter_sleep()
{
	if(SIG_ERR == signal(SIGINT, sig_ctlc))
		perror("SIGINT install err\n");
	pause();	
}


/*
void receive_callback(u8 *user,struct pcap_pkthdr *headr,u8 *pkt)
{
	cnc_pkt_print(pkt,headr->len);
}
*/


u8 get_port_type_from_init_cfg(u16 tmp_imac)
{
	return port_type_info[tmp_imac];
}

u16 *get_cfg_order_from_init_cfg()
{
	return cfg_order;
}

u16 get_cfg_num_from_init_cfg()
{
	return cfg_order_idx;
}


//配置第一个芯片时正常配置，配置第二个芯片时出现问题

//进行网络初始配置,每次只配置一个节点的内容
int init_cfg_fun()
{
	u16 len = 0;
	u16 flowid_idx = 0;
	u8 *pkt = NULL;
	u16 *test_pkt = NULL;	
	u32 cfg_data = 0;
	//上报确认
	chip_reg_info *chip_reg = NULL;//芯片上报的单个寄存器
	chip_report_table_info *report_entry = NULL;//芯片上报的表项

	//配置port_type
	u16 count = 0;

#if 1	
		//配置上报使能
		cfg_data = 1;
		printf("cfg report enable %d\n",cfg_data);
		build_send_chip_cfg_pkt(init_cfg.imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);//配置端口类型
#endif	


	
	cfg_data = 255;
	printf("cfg port_type %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);//配置端口类型

	cfg_data = 255;
	printf("cfg port_type %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);//配置端口类型


	//sleep(1);
	cfg_data = CHIP_REG_REPORT;
	printf("cfg port_type report %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&cfg_data);//配置上报类型为单个寄存器上报


	
/*
	cfg_data = CHIP_REG_REPORT;
	printf("cfg port_type report %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&cfg_data);//配置上报类型为单个寄存器上报
*/	


//配置芯片qch

	cfg_data = 1;
	printf("cfg qch %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_QBV_QCH_ADDR,1,&cfg_data);	

	//配置芯片转发表,默认控制器的转发表，为了进行上报
	cfg_data = init_cfg.forward_table[0].outport;
	printf("cfg flt %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_FLT_BASE_ADDR,1,&cfg_data);	

#if 1	
	//配置上报使能
	cfg_data = 1;
	printf("cfg report enable %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);//配置端口类型
#endif	
#if 1
	//配置上报周期
	cfg_data = 1;
	printf("cfg report period %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_REPORT_PERIOD_ADDR,1,(u32 *)&cfg_data);//配置端口类型
#endif	
	
	//配置完成寄存器
	cfg_data = 3;
	printf("cfg finish %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_CFG_FINISH_ADDR,1,(u32 *)&cfg_data);//配置端口类型
	gettimeofday(&tv,&tz);
	printf("tv_sec %ld,tv_usec%ld\n",tv.tv_sec,tv.tv_usec);
	

	//配置HCP状态
	cfg_data = 2;	
	printf("cfg hcp state %d\n",cfg_data);
	//build_send_hcp_cfg_pkt(init_cfg.imac,HCP_STATE_ADDR,&cfg_data,1);
	
	//配置HCP端口类型，在测ping时测出该问题
	cfg_data = init_cfg.port_type;	
	printf("cfg hcp state %d\n",cfg_data);
	//build_send_hcp_cfg_pkt(init_cfg.imac,HCP_PORT_TYPE_ADDR,&cfg_data,1);
	

#if 0
	while(1)
	{
		//接收单个寄存器上报的报文
		printf("wait report pkt\n");
		pkt = data_pkt_receive_dispatch_1(&len);
		pkt = pkt+16;//偏移到数据域，16字节TSMP头
		host_to_net_single_reg(pkt);//网络序转主机序函数
		//强制转换
		chip_reg = (chip_reg_info *)pkt;
		//打印上报单个寄存器的内容
		printf_single_reg(chip_reg);
		
		//比较上报内容与配置内容是否相同
		if(255 == chip_reg->port_type)
		{
			printf("port_type cfg success,count=%d\n",count);
			break;
		}
		else
		{
			count++;
			printf("port_type cfg fail\n");
			//return -1;
		}


	}

	count = 0;

	while(1)
	{
		//接收单个寄存器上报的报文
		pkt = data_pkt_receive_dispatch_1(&len);
		pkt = pkt+16;//偏移到数据域，16字节TSMP头
		host_to_net_single_reg(pkt);//网络序转主机序函数
		//强制转换
		chip_reg = (chip_reg_info *)pkt;
		//打印上报单个寄存器的内容
		printf_single_reg(chip_reg);
		
		//比较上报内容与配置内容是否相同
		if(3 == chip_reg->cfg_finish)
		{
			printf("cfg_finish cfg ,count=%d\n",count);
			break;
		}
		else
		{
			count++;
			printf("cfg_finish cfg fail\n");
			//return -1;
		}


	}
#endif	
	//init_cfg_info init_cfg;默认端口类型为全1
	/*
	cfg_data = init_cfg.port_type;
	printf("cfg port_type %d\n",init_cfg.port_type);
	build_send_chip_cfg_pkt(init_cfg.imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);//配置端口类型
	*/


#if 0

	//接收单个寄存器上报的报文
	pkt = data_pkt_receive_dispatch_1();
	pkt = pkt+16;//偏移到数据域，16字节TSMP头
	host_to_net_single_reg(pkt);//网络序转主机序函数
	//强制转换
	chip_reg = (chip_reg_info *)pkt;
	//打印上报单个寄存器的内容
	printf_single_reg(chip_reg);

	//比较上报内容与配置内容是否相同
	if(init_cfg.port_type == chip_reg->port_type)
		printf("port_type cfg success\n");
	else
	{
		printf("port_type cfg fail\n");
		return -1;
	}
#endif	
	printf("init_cfg.max_flowid %d\n",init_cfg.max_flowid);
	for(flowid_idx=0;flowid_idx<init_cfg.max_flowid;flowid_idx++)
	{
		printf("cfg forward flowID %d,outport %d\n",flowid_idx,init_cfg.forward_table[flowid_idx].outport);
		cfg_data = init_cfg.forward_table[flowid_idx].outport;
		//配置转发表，每次配置一个，配置多次
		build_send_chip_cfg_pkt(init_cfg.imac,
								CHIP_FLT_BASE_ADDR + init_cfg.forward_table[flowid_idx].imac_flowid,
								1,
								(u32 *)&cfg_data);
		//配置上报类型为转发表,上报转发表的第几块对flowid求除
		cfg_data = CHIP_FLT_REPORT_BASE + init_cfg.forward_table[flowid_idx].imac_flowid/32;
		printf("cfg  CHIP_FLT_REPORT_BASE report %d\n",cfg_data);

		build_send_chip_cfg_pkt(init_cfg.imac,
								CHIP_REPORT_TYPE_ADDR,
								1,
								(u32 *)&cfg_data);
		
		gettimeofday(&tv,&tz);
		printf("11111 tv_sec %ld,tv_usec%ld\n",tv.tv_sec,tv.tv_usec);
#if 0
		//sleep(20);
		count = 0;
		while(1)
		{
			//接收单个寄存器上报的报文
			pkt = data_pkt_receive_dispatch_1(&len);
				
			pkt = pkt+16;//偏移到数据域，16字节TSMP头
	
			//对接收的表项上报报文进行主机序转网络序
			host_to_net_chip_table(pkt,sizeof(chip_report_table_info));
			//强制转换为上报的数据结构
			report_entry = (chip_report_table_info *)pkt;
			//打印上报表项内容
			print_chip_report_table(report_entry);
	
			//比较配置的内容与上报的内容是否一致,对上报某块中的第几个，对flowid求余
			if(init_cfg.forward_table[flowid_idx].outport == report_entry->table[init_cfg.forward_table[flowid_idx].imac_flowid%32])
			{
				printf("flowid = %d forward cfg success,count=%d\n",init_cfg.forward_table[flowid_idx].imac_flowid,count);
				break;
	
			}
			else
			{
				printf("flowid = %d forward cfg fail\n",init_cfg.forward_table[flowid_idx].imac_flowid);
				count++;
				//return -1;
			}
	

		
		
		}
		gettimeofday(&tv,&tz);
		printf("22222 tv_sec %ld,tv_usec%ld\n",tv.tv_sec,tv.tv_usec);

		
		//芯片上报表项
		//data_pkt_receive_dispatch(receive_callback);
		
		//pkt = data_pkt_receive_dispatch(receive_callback);
/*		
		pkt = pkt+16;//偏移到数据域，16字节TSMP头

		//对接收的表项上报报文进行主机序转网络序
		host_to_net_chip_table(pkt,sizeof(chip_report_table_info));
		//强制转换为上报的数据结构
		report_entry = (chip_report_table_info *)pkt;
		//打印上报表项内容
		print_chip_report_table(report_entry);

		//比较配置的内容与上报的内容是否一致,对上报某块中的第几个，对flowid求余
		if(init_cfg.forward_table[flowid_idx].outport == report_entry->table[init_cfg.forward_table[flowid_idx].imac_flowid%32])
		{
			printf("flowid = %d forward cfg success\n",init_cfg.forward_table[flowid_idx].imac_flowid);

		}
		else
		{
			printf("flowid = %d forward cfg fail\n",init_cfg.forward_table[flowid_idx].imac_flowid);
			return -1;
		}
*/
#endif
	}


#if 0
	//接收单个寄存器上报的报文
	pkt = data_pkt_receive_dispatch_1();
	pkt = pkt+16;//偏移到数据域，16字节TSMP头
	host_to_net_single_reg(pkt);//网络序转主机序函数
	//强制转换
	chip_reg = (chip_reg_info *)pkt;
	//打印上报单个寄存器的内容
	printf_single_reg(chip_reg);

	//比较上报内容与配置内容是否相同
	if(init_cfg.port_type == chip_reg->port_type)
		printf("port_type cfg success\n");
	else
	{
		printf("port_type cfg fail\n");
		return -1;
	}
#endif	

	//最后配置关闭上报功能
	cfg_data = 0;
	printf("cfg  report enable %d\n",cfg_data);	
	build_send_chip_cfg_pkt(init_cfg.imac,
						CHIP_REPORT_EN_ADDR,
						1,
						(u32 *)&cfg_data);

	//最后配置端口类型，开始端口类型为全1，配置完该节点后，接收配置的报文的端口需要配置为0
	cfg_data = init_cfg.port_type;
	printf("cfg  port_type %d\n",cfg_data); 
	build_send_chip_cfg_pkt(init_cfg.imac,
						CHIP_PORT_TYPE_ADDR,
						1,
						(u32 *)&cfg_data);
						
	return 0;
}


/* 解析arp_entry，把值取出来放到arp表中 */  
static void parse_init_node(xmlDocPtr doc, xmlNodePtr cur)
{  
	xmlChar* value;
	xmlNodePtr entry;
    xmlChar *IP,*MAC;

	int i = 0;
	u16 flowid = 0;

	//memset(&init_cfg,0,sizeof(init_cfg_info));

	value = xmlGetProp(cur, (const xmlChar *)"imac");
	init_cfg.imac = atoi(value);
	printf("imac %d\n",init_cfg.imac);

	value = xmlGetProp(cur, (const xmlChar *)"port_mode");
	init_cfg.port_type = atoi(value);
	printf("port_type %d\n",init_cfg.port_type);
	
	port_type_info[init_cfg.imac] = init_cfg.port_type;

	//对交换机配置顺序进行存储，
	cfg_order[cfg_order_idx] = init_cfg.imac;
	cfg_order_idx++;
	
	for(entry=cur->children;entry;entry=entry->next)
	{  
		printf("888888888888888888\n");
		//xmlStrcmp  xmlStrcasecmp
    	if(xmlStrcmp(entry->name,(const xmlChar *)"entry")==0)
		{
			init_cfg.max_flowid = init_cfg.max_flowid + 1;

            value=xmlGetProp(entry,(const xmlChar *)"flowid");
			flowid = atoi(value);
			init_cfg.forward_table[init_cfg.max_flowid - 1].imac_flowid = flowid;
			printf("imac_flowid %d\n",init_cfg.forward_table[init_cfg.max_flowid - 1].imac_flowid);

            value=xmlGetProp(entry,(const xmlChar *)"outport");
			init_cfg.forward_table[flowid].outport = atoi(value);
			printf("outport %d\n",init_cfg.forward_table[flowid].outport);

			//init_cfg.max_flowid = flowid;
		}
            //xmlFree(IP);
            //xmlFree(MAC);
    }



    return;  
}


/* 解析文档 */  
static int parse_init_doc(char *docname)
{  
    /* 定义文档和节点指针 */  
    xmlDocPtr doc;  
    xmlNodePtr cur;  

	xmlChar* value;

	int ret = 0;
	
    /* 进行解析，如果没成功，显示一个错误并停止 */  
    doc = xmlParseFile(docname); 
	//xmlFreeDoc(doc);
	//xmlFree(doc);
	//doc = NULL;
    printf("7777777777\n");
	//doc = xmlParseFile(docname); 
    //doc = xmlReadFile(docname,NULL,XML_PARSE_NOBLANKS); 
	
    printf("8888888888\n");
    if(doc == NULL){  
        fprintf(stderr, "Document not parse successfully. \n");  
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
  
    /* 确定根节点名是否为nodes，不是则返回 */  
    if(xmlStrcmp(cur->name, (const xmlChar *)"nodes"))
	{  
        fprintf(stderr, "document of the wrong type, root node != nodes");  
        xmlFreeDoc(doc);  
        return -1;  
    }  

	value = xmlGetProp(cur, (const xmlChar *)"sync_period");
	SYNC_PERIOD = atoi(value);
	printf("SYNC_PERIOD %d\n",SYNC_PERIOD);

	value = xmlGetProp(cur, (const xmlChar *)"master_imac");
	MASTER_IMAC = atoi(value);
	printf("MASTER_IMAC %d\n",MASTER_IMAC);
	
	value = xmlGetProp(cur, (const xmlChar *)"sync_flowid");
	SYNC_FLOWID = atoi(value);
	printf("SYNC_FLOWID %d\n",SYNC_FLOWID);
	
    /* 遍历文档树 */  
    cur = cur->xmlChildrenNode;  
    while(cur != NULL)
	{  
        /* 找到node子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"node"))
		{  
			printf("node\n");
			memset(&init_cfg,0,sizeof(init_cfg_info));
            parse_init_node(doc, cur); /* 解析node子节点 */ 
			ret = init_cfg_fun();
			if(ret == -1)//解析完毕，进行初始化配置
			{
				printf("init_cfg_fun fail\n");
				return ret;
			}
		}
		else
		{
			printf("have no node\n");
		}
        
        cur = cur->next; /* 下一个子节点 */  
    }  

  	//xmlFree(doc);
    xmlFreeDoc(doc); /* 释放文档树 */ 
	//xmlCleanupParser();
	//xmlMemoryDump();
	if(doc == NULL)
		printf("doc NULL\n");
	//doc = NULL;
	printf("free success\n");
    return 0;  
}  
  



int parse_init_cfg_file()
{

	char *docname = INIT_XML_FILE;
	if (parse_init_doc(docname) != 0) 
	{
		fprintf(stderr, "Failed to parse xml.\n");
		return -1;
	}

	return 0;

}





//解析完后存储在数据结构中，按照节点进行解析
int net_init_cfg()
{
	int ret = 0;
	ret = parse_init_cfg_file();
	if(ret == -1)
	{
		printf("net_init_cfg fail\n");
		return -1;
	}
}



int main(int argc,char* argv[])
{
	int ret = 0;
	//初始化进程
	char test_rule[64] = {0};
	char temp_net_interface[16]={0};

	if(argc != 2)
	{
		printf("input format:./init net_interface\n");
		return 0;
	}

	//libpcap initialization
	//sprintf(test_rule,"%s","ether[3:1]=0x1 and ether[12:2]=0xff01");
	sprintf(test_rule,"%s","ether[12:2]=0xff01");
	sprintf(temp_net_interface,"%s",argv[1]);

	
	data_pkt_receive_init(test_rule,temp_net_interface);//数据接收初始化
	data_pkt_send_init(temp_net_interface);//数据发送初始化
	
	//从初始配置文件中读取初始配置内容，进行配置并确认
	ret = net_init_cfg();
	if(ret == -1)
	{
		printf("net_init_cfg fail\n");
		return 0;
	}

	printf("net_init_cfg success!\n");
	//从离线规划结果文本读取配置内容，
	offline_plan_cfg();

	printf("config finish\n");
	//开启服务，时间同步服务，ARP代理服务
	//enable_application_service();
	
	
	//进入休眠状态
	//判断是否接收到ctrl_c信号SIGINT，如果接收到，则关闭服务，退出程序
	//enter_sleep();
	
	
	return 0;
	
	
}
