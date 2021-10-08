/** *************************************************************************
 *  @file       main.c
 *  @brief	    TSNLight主函数
 *  @date		2021/05/07 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/

#include "cnc_api/include/cnc_api.h"
#include "basic_cfg/basic_cfg.h"
#include "local_cfg/local_cfg.h"
#include "net_init/net_init.h"
#include "remote_cfg/remote_cfg.h"
#include "state_monitor/state_monitor.h"
#include "ptp/ptp_single_process.h" 
#include "arp_proxy/arp_proxy.h"




int restart_num = 0;
int work_run = 1;


struct timeval state_tv;//网络运行状态的时间戳
struct timeval basic_tv;//基础配置状态的时间戳
struct timeval local_tv;//本地配置状态的时间戳



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
	#if 0
		//判断是否超出最大基础配置时间
		if(tv.tv_sec - basic_tv.tv_sec > 10)
		{
			printf("error:basic cfg timeout\n");
			basic_tv.tv_sec = 0;//初始基础配置时间
			work_run = 0;//超时
		}
	#endif
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
		#if 0
		//判断是否超出最大基础配置时间
		if(tv.tv_sec - local_tv.tv_sec > 100)
		{
			printf("error:basic cfg timeout\n");
			local_tv.tv_sec = 0;//初始基础配置时间
			work_run = 0;//超时
		}
		#endif
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
			//printf("88888\n");
			sync_period_timeout();
			break;//时间同步初始化
		}
        case  NW_RUNNING_S:
		{
			//printf("NW RUNNING S timeout handle\n");
		    //时间同步，状态监测，动态配置
			sync_period_timeout();	
			state_monitor_timeout(tv);
/*
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
*/			
			break;
		}

    }
}

void net_run(u8 *pkt,u16 pkt_length)
{
	
	//dynamic_remote_cfg(pkt,pkt_length);	
#if 1	
    u8 pkt_type = get_pkt_type(pkt,pkt_length);
    if(pkt_type == 0x05)
    {
		//printf("***********************************ptp handle get pkt223\n");
        ptp_handle(pkt_length,pkt);
    }  
    else if(pkt_type == 0x01)
    {
		//printf("***********************************state monitor get pkt224\n");
        state_monitor(pkt_length,pkt);
    }  
    else if(pkt_type == 0x00)
    {
		//printf("************************************arp reply get pkt225\n");
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
	sprintf(temp_net_interface,"%s",argv[1]);

	data_pkt_receive_init(test_rule,temp_net_interface);//数据接收初始化
	data_pkt_send_init(temp_net_interface);//数据发送初始化

init:
    net_init(temp_net_interface);
	//init_cfg_fun(1);
	printf("enter while 1 G_STATE %d\n",G_STATE);
    while(1)
    {
		//每次获取一个报文
        pkt = data_pkt_receive_dispatch_1(&pkt_len);
       
        if(pkt != NULL)
        {
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




