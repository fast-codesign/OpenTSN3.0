#include "timer.h"





//#include <arpa/inet.h>

pthread_mutex_t pkt_send_lock;

u16 ptp_period ;             //
u16 ptp_mult_imac ;
u16 ptp_master_imac ;
u32 sync_seq = 1 ;
int sync_pkt_build(ptp_pkt* pkt){                      //对sync报文的构造，供定时器线程使用
    pkt_init(pkt);                                    //报文初始化

    dmac_transf_tag(pkt->ptp_des_mac,0X4,ptp_mult_imac,0X0000,0X00,0X00,0X00,0X00);      //填充PTP目的MAC字段
    dmac_transf_tag(pkt->ptp_src_mac,0x4,ptp_master_imac,0x0000,0x00,0x00,0x00,0x00);     //填充PTP源MAC字段
    pkt->eth_type=htons(0X98F7);                         //以太网报文字段填充
    pkt->ptp_type=0X1;                                   //ptp类型字段填充
    pkt->pkt_length = htons(72);                         //报文长度字段填充
    pkt->sync_seq = sync_seq;
    sync_seq = sync_seq + 1;
    return sizeof(ptp_pkt);
};


void timer_callback(){
    ptp_pkt* pkt;

    pkt = (ptp_pkt*)build_tsmp_pkt(TSMP_PTP,ptp_master_imac,64);

    sync_pkt_build(pkt);                                                       //对PTP报文内容进行填充

    pthread_mutex_lock(&pkt_send_lock);

    data_pkt_send_handle((u8*)pkt,64);                                             //对报文进行发送

    free_pkt((u8*)pkt);
    pthread_mutex_unlock(&pkt_send_lock);

}

void start_timer(void *argv){



    struct itimerval tick;
    pthread_detach(pthread_self());
    signal(SIGALRM, timer_callback);

    memset(&tick, 0, sizeof(tick));
	tick.it_value.tv_sec = 0;
	tick.it_value.tv_usec = BASE_TIMER*ptp_period;
    tick.it_interval.tv_sec = 0;
	tick.it_interval.tv_usec = BASE_TIMER*ptp_period;
	if(setitimer(ITIMER_REAL, &tick, NULL) < 0)
	{
		TIMER_ERR("Set timer failed!\n");
	}
		while(1)
	{
		pause();
	}


}

int timer_init(u16 set_time,u16 mul_imac,u16 master_imac)
{
	int ret = -1;
	pthread_t timerid;

	ptp_period = set_time ;
	ptp_master_imac = master_imac;
	ptp_mult_imac = mul_imac ;


	ret=pthread_create(&timerid,NULL,(void *)start_timer,NULL);

	if(0 != ret)
	{
		TIMER_ERR("create hx_timer_handler fail!ret=%d err=%s\n",ret, strerror(ret));
	}

	return ret;
}


