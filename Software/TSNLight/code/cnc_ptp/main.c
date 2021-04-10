/** *************************************************************************
 *  @file       main.c
 *  @brief	    TSN控制器PTP主线程
 *  @date		2020/11/24  星期四
 *  @author		xxc
 *  @version	0.1.0
 ****************************************************************************/
#include "./libptp/ptp.h"
#include "./libptp/timer.h"
#include"../cnc_api/include/cnc_api.h"

int main(int argc,char* argv[])
{
    u16 ptp_period = 50;
    u16 ptp_mult_imac = 4096;
    u16 ptp_master_imac = 2;//读取配置信息，时间同步周期、主时钟imac、组播imac

    char test_rule[64] = {0};
	char temp_net_interface[16]={0};

	if(argc != 2)
	{
		printf("input format:./cnc_ptp net_interface\n");
		return 0;
	}

	printf("ok!\n");
	sprintf(test_rule,"%s","ether[3:1]=0x05 and ether[12:2]=0xff01");       //libpcap规则和网卡接口赋值
	sprintf(temp_net_interface,"%s",argv[1]);
	printf("ok!\n");
	data_pkt_receive_init(test_rule,temp_net_interface);           //初始化数据报文接收与发送
	printf("ok!\n");
	data_pkt_send_init(temp_net_interface);
	printf("ok!\n");
    timer_init(ptp_period,ptp_mult_imac,ptp_master_imac);     //启动定时线程

	printf("ok!\n");
    data_pkt_receive_loop(ptp_callback);                        //ptp主逻辑处理

    data_pkt_receive_destroy();
	data_pkt_send_destroy();
    //ptp_destroy();
}
