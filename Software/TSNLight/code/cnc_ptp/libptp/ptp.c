#include <stdio.h>
#include <stdlib.h>
#include "ptp.h"


extern pthread_mutex_t pkt_send_lock;
extern u16 ptp_mult_imac ;//组播imac
extern u16 ptp_master_imac ;//主时钟imac
extern u16 ptp_period;
sync_info_table table;
extern u32 sync_seq ;


void file_write(u16 imac,u64 ptp_seq, u8 offset_flag, u64 offset){

    FILE * fp = NULL;
    fp = fopen("offset.txt","a");
    fprintf(fp,"imac =%d\t       ptp_seq=%lld\t     offset_flag%c\t      offset=%lld\t        \n",imac,ptp_seq,offset_flag,offset);
    fclose(fp);
    return ;

}
u16 mac_to_flow_id(u64 mac){            //完成从48位mac字段提取14位imac地址
    mac = mac>>31 ;
    return mac % 0x4000;
}

u64 corr_trans(u64 a){                    //修正域时间戳格式转换函数
    u64 corr_7 = a%125;
    u64 corr_41 = (a/125)*128 ;
	return corr_41+corr_7;
}

u64 ts_add(u64 u1,u64 u2){              //时间戳相加函数
    u64 u_sum;
    u64 u1_41 = (u1/128)*128;
    u64 u2_41 = (u2/128)*128;
    u8 u1_7 = u1%128;
    u8 u2_7 = u2%128;
    u1_41 = u1_41+u2_41;
    u1_7 = u1_7+u2_7;
    if(u1_7>124){
        u1_41 = u1_41+128;
        u1_7 = u1_7-125;
    }
    u_sum = u1_41+u1_7;
    return u_sum;
}

u64 ts_trans(u64 ts){
    u64 ts_7 = ts%128;
    u64 ts_41 = ts/128;
    u64 tran_ts = ts_41*125+ts_7;
    return tran_ts;
}

u64 ts_sub(u64 u1, u64 u2){               // 时间戳相减函数
    int flag;
    u64 u_sub;
    u64 u1_41 = (u1/128)*128;
    u64 u2_41 = (u2/128)*128;
    u64 u1_7 = u1%128;
    u64 u2_7 = u2%128;
    if(u1>=u2){
        flag = 0;
    }else {
        flag = 1;
    }
    if(flag == 0){
      if(u1_7>u2_7){
        u_sub = (u1_7-u2_7)+(u1_41-u2_41);
      }else if (u1_7<u2_7){
          u1_7 = u1_7 + 125 -u2_7;
          u1_41 = u1_41 - 128 -u2_41;
          u_sub = ts_add(u1_7,u1_41);
      }else if(u1_41>u2_41){
          u_sub = u1_41-u2_41;
      }else {
          u_sub = 0;
      }
    }else{
        if(u2_7>u1_7){
            u_sub = (u2_7-u1_7)+(u2_41-u1_41) +0X1000000000000;
        }else if (u2_7<u1_7){
            u1_7 = u2_7+125-u1_7;
            u1_41 = u2_41 -128 -u1_41;
            u_sub = ts_add(u1_7,u1_41)+0X1000000000000;
        }else if(u2_41>u1_41){
          u_sub = u2_41-u1_41+0X1000000000000;
      }
    }
    return u_sub;
}

u32 htonl(u32 a){                        //16位数据转网络序

    return ((a >> 24) & 0x000000ff) |         ((a >>  8) & 0x0000ff00) |         ((a <<  8) & 0x00ff0000) |         ((a << 24) & 0xff000000);

};

u16 htons(u16 a){                       //32位数据转网络序
  return ((a >> 8) & 0x00ff) | ((a << 8) & 0xff00);

};

u64 htonll_xxc(u64 a){                      //64位数据转网络序
    return ((a>>56)&0X00000000000000ff) | ((a>>40)&0X000000000000ff00) | ((a>>24)&0X0000000000ff0000) | ((a>>8)&0X00000000ff000000) | ((a<<8)&0X000000ff00000000)| ((a<<24)&0X0000ff0000000000)| ((a<<40)&0X00ff000000000000)| ((a<<56)&0Xff00000000000000);
};

void dmac_transf_tag(u8 *tmp_dmac,u8 flow_type,u16 flowid,u16 seqid,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr ){    //目的MAC转网络序
	tmp_dmac[0] = 0;
	tmp_dmac[0] = flow_type<<5;
	tmp_dmac[0] = tmp_dmac[0] | (flowid>>9);

	tmp_dmac[1] = 0;
	tmp_dmac[1] = flowid >> 1;

	tmp_dmac[2] = 0;
	tmp_dmac[2] = flowid << 7;
	tmp_dmac[2] = tmp_dmac[2] | (seqid >> 9);

	tmp_dmac[3] = 0;
	tmp_dmac[3] = seqid >> 1;
	tmp_dmac[3] = tmp_dmac[3] | (seqid >> 9);

	tmp_dmac[4] = 0;
	tmp_dmac[4] = seqid << 7;
	tmp_dmac[4] = tmp_dmac[4] | (frag_flag << 6);
	tmp_dmac[4] = tmp_dmac[4] | (frag_id << 2);
	tmp_dmac[4] = tmp_dmac[4] | (inject_addr >> 3);

	tmp_dmac[5] = 0;
	tmp_dmac[5] = inject_addr << 5;
	tmp_dmac[5] = tmp_dmac[5] | submit_addr;

};

void table_syncin(int value,u64 t1,u64 t2,u64 corr_ms){     //根据Sync报文的时间信息对表项进行填写
    table.table[value].t1 = t1;
    table.table[value].t2 = t2;
    table.table[value].corr_ms = corr_ms;
    return ;

}

void table_reqin(int value,u64 t3,u64 t4,u64 corr_sm){      //根据Req报文的时间信息对表项进行填写
    table.table[value].t3 = t3;
    table.table[value].t4 = t4;
    table.table[value].corr_sm = corr_sm;
    return ;

}

void offset_calu(int value){                            //根据imac索引信息表，对offset进行计算
   // u32 cfg_offset[2];
    u64 t_ms = ts_sub(table.table[value].t2,ts_add(table.table[value].t1,corr_trans(table.table[value].corr_ms)));
    u64 t_sm = ts_sub(table.table[value].t4,ts_add(table.table[value].t3,corr_trans(table.table[value].corr_sm)));
    if(t_ms<0x1000000000000&&t_sm<0x1000000000000){
        if(t_ms>=t_sm){
            table.table[value].Latest_Offset = ts_sub(t_ms,t_sm)/2;
            table.table[value].offset_flag = 0;
        }else if(t_ms<t_sm){
            table.table[value].Latest_Offset  = ts_sub(t_sm,t_ms)/2;
            table.table[value].offset_flag = 1;
        }
    }else if(t_ms<0x1000000000000&&t_sm>0x1000000000000){
        table.table[value].offset_flag = 0;
        table.table[value].Latest_Offset = ts_add(t_ms,t_sm-0x1000000000000)/2;
    }else if(t_ms>0x1000000000000&&t_sm<0x1000000000000){
        table.table[value].offset_flag = 1 ;
        table.table[value].Latest_Offset = ts_add(t_ms-0x1000000000000,t_sm)/2;
    }else{
        if((t_ms-0x1000000000000)>=(t_sm-0x1000000000000)){
            table.table[value].offset_flag = 1;
            table.table[value].Latest_Offset = ts_sub(t_ms,t_sm)/2;
        }else{
            table.table[value].offset_flag = 0;
            table.table[value].Latest_Offset = ts_sub(t_sm,t_ms)/2;
        }
    }


    if (table.table[value].sync_seq == 100 ){
            table.table[value].guide_offset = 1;
            if(table.table[value].Latest_Offset!=0){
                table.table[value].guide_offset_frequency = ptp_period*1000000/(8*table.table[value].Latest_Offset);
                table.table[value].guide_offset_flag = table.table[value].offset_flag ;
                table.table[value].preoffset = table.table[value].preoffset + table.table[value].Latest_Offset;
            }else{
                    table.table[value].guide_offset = 0;
                    table.table[value].guide_offset_frequency = ptp_period*1000000/8;
                    table.table[value].guide_offset_flag = table.table[value].offset_flag ;
                    table.table[value].preoffset = table.table[value].preoffset + table.table[value].Latest_Offset;
            }

	}else if(table.table[value].sync_seq>100 ){
	    if(table.table[value].guide_offset_flag!=table.table[value].offset_flag){
                if(table.table[value].Latest_Offset>table.table[value].preoffset){
                    table.table[value].guide_offset_flag = !table.table[value].guide_offset_flag;
                    table.table[value].preoffset = table.table[value].Latest_Offset - table.table[value].preoffset ;
                }else{
                table.table[value].preoffset = table.table[value].preoffset - table.table[value].Latest_Offset;
                }
                table.table[value].guide_offset = 1 ;
                if(table.table[value].preoffset == 0){
                      table.table[value].guide_offset = 0;
                      table.table[value].guide_offset_frequency = ptp_period*1000000/8;
                }else{
                table.table[value].guide_offset_frequency = ptp_period*1000000/(8*table.table[value].preoffset);
                 }

          //  Local_ts_info.guide_offset = Local_ts_info.guide_offset - Local_ts_info.offset/25;
	    }else {
	        table.table[value].preoffset = table.table[value].preoffset + table.table[value].Latest_Offset ;
	        table.table[value].guide_offset = 1 ;
                if(table.table[value].preoffset == 0){
                      table.table[value].guide_offset = 0;
                      table.table[value].guide_offset_frequency = ptp_period*1000000/8;
                }else{
                table.table[value].guide_offset_frequency = ptp_period*1000000/(8*table.table[value].preoffset);
                 }
	    }
	    //构造报文、并对报文进行发送
    }
    table.table[value].sync_seq = table.table[value].sync_seq +1 ;
}

u32 get_l_offset(u64 offset){
    return (u32)offset;

}

u32 get_h_offset(u64 offset,u8 offset_flag){
    if(offset_flag == 0 ){
        offset = offset + 0x1000000000000;
    }
    return (u32)(offset>>32);
}
void offset_cfg_send(u16 value){
    u32 offset_cfg_arr[2];
    u32 frequency = 0;
    printf("----------------------ptp_info---------------------------------------------------------\n");
    printf("imac = %d \n",value);
    printf("offset = %lld, offset_flag = %d\n",table.table[value].Latest_Offset,table.table[value].offset_flag);

   // printf("preoffset = %lld, guide_offset_flag = %d\n",table.table[value].preoffset,table.table[value].guide_offset_flag);
 //   printf("offset_frequency = %d\n",table.table[value].guide_offset_frequency);
            offset_cfg_arr[0] = get_l_offset(table.table[value].Latest_Offset);
        offset_cfg_arr[1] = get_h_offset(table.table[value].Latest_Offset,table.table[value].offset_flag);
        build_send_chip_cfg_pkt(value,CHIP_OFFSET_L_ADDR,2,offset_cfg_arr);
        build_send_chip_cfg_pkt(value,CHIP_OFFSET_PERIOD_ADDR,1,&(frequency));

  /*  if(table.table[value].sync_seq > 100){
        offset_cfg_arr[0] = get_l_offset(table.table[value].guide_offset);
        offset_cfg_arr[1] = get_h_offset(table.table[value].guide_offset,table.table[value].guide_offset_flag);
        build_send_chip_cfg_pkt(value,CHIP_OFFSET_L_ADDR,2,offset_cfg_arr);
        build_send_chip_cfg_pkt(value,CHIP_OFFSET_PERIOD_ADDR,1,&(table.table[value].guide_offset_frequency));
    }*/
}

void   pkt_init(ptp_pkt* pkt){             //PTP报文构造的初始化函数
    memset(pkt,0,sizeof(ptp_pkt));
    return ;
};

char*  get_ptp_src_mac_addr(ptp_pkt* pkt){                  //从接收到的ptp_pkt中取出源Mac的地址
    char src_mac[6];
    char* ptr = NULL;
    int i;
    for(i=0;i<6;i++){
        src_mac[i]=pkt->ptp_src_mac[i];
    }
    ptr = src_mac;
    return ptr;

};

u64 get_ptp_src_mac(ptp_pkt* pkt){                         //从接收到的ptp_pkt中取出源Mac（48位）
    u64* a ;
    a = (u64*)get_ptp_src_mac_addr(pkt);
    return htonll_xxc(*a)>>16;

}

char*  get_ptp_des_mac(ptp_pkt* pkt){                      //从接收到的ptp_pkt中取出目的Mac的地址
    char des_mac[6];
    char* ptr = NULL;
    int i;
    for(i=0;i<6;i++){
        des_mac[i]=pkt->ptp_des_mac[i];
    }
    ptr = des_mac;
    return ptr;

};

long long get_corr(ptp_pkt* pkt){                          //从接收到的ptp_pkt中取出修正域字段值
    long long * ptr;
    ptr = (long long *)(pkt->corrField);
    return htonll_xxc(*ptr);
};

long long get_pkt_ts1(ptp_pkt* pkt){                       //从接收的ptp_pkt中取出报文携带的时间戳
    long long * ptr;
    ptr = (long long *)(pkt->timestamp1);
    return htonll_xxc(*ptr);
};

long long get_pkt_ts2(ptp_pkt* pkt){                     //从接收的ptp_pkt中取出报文携带的时间戳
    long long * ptr;
    ptr = (long long *)(pkt->timestamp2);
    return (htonll_xxc(*ptr))>>16;
};

void set_ptp_src_mac(ptp_pkt* pkt,char* ptr){       //对构造的ptp_pkt设置目的Mac
    int i;
    for(i=0;i<6;i++){
        pkt->ptp_src_mac[i]=*(ptr+i);}

};

void set_ptp_des_mac(ptp_pkt* pkt,char* ptr){            //对构造的ptp_pkt设置目的Mac
        int i;
    for(i=0;i<6;i++){
        pkt->ptp_des_mac[i]=*(ptr+i);}

};



int delay_req_pkt_build(ptp_pkt * pkt,u16 ptp_slave_imac){            //对Delay_req报文进行构造

    //set_tsmp_des_mac(pkt,get_tsmp_src_mac_addr(pkt));//填充TSMP目的MAC字段
    dmac_transf_tag(pkt->ptp_src_mac,0X4,ptp_slave_imac,0X0000,0X00,0X00,0X00,0X00);     //填充PTP源MAC字段
   // dmac_transf_tag(pkt->tsmp_src_mac,0x6,ptp_cnc_imac,0x0000,0x00,0x00,0x00,0x00);     //填充TSMP源MAC字段
    //pkt->type=htons(0xff01);
    //pkt->sub_type = 0X6;
    dmac_transf_tag(pkt->ptp_des_mac,0X4,ptp_master_imac,0X0000,0X00,0X00,0X00,0X00);      //填充PTP目的MAC字段
   // pkt->eth_type=htons(0X98F7);                         //以太网报文字段填充
    pkt->ptp_type=0X3;       ////ptp类型字段填充
    memset(pkt->timestamp1,0,8);
    memset(pkt->timestamp2,0,6);
    memset(pkt->corrField,0,8);                             //时间戳、透明时钟字段填充0

    //pkt->pkt_length = htons(72);                         //报文长度字段填充
    return sizeof(ptp_pkt);

}

void print_pkt(ptp_pkt* pkt){                                        //对ptp_ptk进行打印（供测试使用）
    char* ptr;
    ptr = (char*)pkt;
    int i;

    for(i=0;i<80;i++){
        if(i%16==0){
            printf("\n");
        };
        printf("%.2x ",(u8)*(ptr+i));
    }
}

void set_corr(ptp_pkt* pkt,long long  corr){                            // 对发送的ptp_pkt设置修正域字段（供测试使用）
    long long * ptr;
    ptr = (long long *)(pkt->corrField) ;
    *ptr = htonll_xxc(corr);

};

void set_ts1(ptp_pkt* pkt,long long  ts1){                              // 对发送的ptp_pkt设置时间戳1字段（供测试使用）
    long long * ptr;
    ptr = (long long *)(pkt->timestamp1) ;
    *ptr = htonll_xxc(ts1);

};

void set_ts2(ptp_pkt* pkt,long long  ts2){                              // 对发送的ptp_pkt设置时间戳2字段（供测试使用）
    u16 * ptr1;
    u32 * ptr2;
    u16 ts_h;
    u32 ts_l;
    ts_h = ts2/ 0x100000000;
    ts_l = ts2 % 0x100000000;
    ptr1 = (u16 *)(pkt->timestamp2) ;
    *ptr1 = htons(ts_h);
    ptr2 = (u32*)(ptr1 + 1);
    *ptr2 = htonl(ts_l);
};

void sync_handler(ptp_pkt * pkt,u16 imac){                                    //将收到的Sync报文信息载入到同步信息表中

    table_syncin(imac,get_pkt_ts1(pkt),get_pkt_ts2(pkt),get_corr(pkt));
   // printf("the ts1 = %lld,the ts2 = %lld,the corr_ms = %lld \n",get_pkt_ts1(pkt),get_pkt_ts2(pkt),get_corr(pkt));   
 printf("  imac = %d , the ts1 = %lld,the ts2 = %lld,the corr_ms = %lld \n",imac,ts_trans(get_pkt_ts1(pkt)),ts_trans(get_pkt_ts2(pkt)),get_corr(pkt));

}

u16 delay_req_handler(ptp_pkt * pkt){                               //将收到的Delay_req报文信息载入到同步信息表中
    u64 tmp_addr;
    tmp_addr = get_ptp_src_mac(pkt);
    table_reqin(mac_to_flow_id(tmp_addr),get_pkt_ts1(pkt),get_pkt_ts2(pkt),get_corr(pkt));
    printf("  the ts3 = %lld,the ts4 = %lld,the corr_sm = %lld \n",ts_trans(get_pkt_ts1(pkt)),ts_trans(get_pkt_ts2(pkt)),get_corr(pkt));
    return mac_to_flow_id(tmp_addr);
}
/*
int ptp_callback(){                                                   //
    ptp_pkt* tmp_addr;
    if(tmp_addr->ptp_type == 0x01)
    {
        //得到从时钟imac
        sync_handler();     //将sync报文信息写入
        delay_req_pkt_build();     // 根据相关信息构造Delay_req报文


        //数据报文的发送

    }else if(tmp_addr->ptp_type == 0x03){
        //得到从时钟imac
        delay_req_handler();//delay_req报文信息写入
        offset_calu();  //进行offset的计算
        //nmac报文的构造
        //TSMP报文头的封装
        //数据报文的发送
    }
}
*/

void ptp_callback(unsigned char *argument,const struct pcap_pkthdr *packet_heaher,const unsigned char *packet_content)
{
	//printf("OK!\n");
	u16 imac=0;
	//u8* pkt = NULL;
	u16 pkt_len = 0;
	ptp_pkt* pkt = NULL;
	//ptp_pkt* alt_addr =NULL;

	pkt_len = packet_heaher->len;

	//cnc_pkt_print((u8*)packet_content,packet_heaher->len);


	//获取simac
	imac = get_simac_from_tsmp_pkt((u8*)packet_content,packet_heaher->len);       //字节序转换
	//printf("tsmp src imac = %0x \n",imac);

	//源目的mac对换
	pkt = (ptp_pkt*)tsmp_header_switch_handle((u8*)packet_content,packet_heaher->len);

	pkt_len = pkt_len - 16;//去掉tsmp报文头部的长度
	//printf("OK!\n");

	//alt_addr = malloc(pkt_len);

//	memccpy(alt_addr,pkt,pkt_len);

	//源目的mac对换后的报文，做相应的处理
	/*此时pkt和pkt_len已经不包含tsmp头,为PTP报文*/
	if(pkt->ptp_type == 0x1){
	//printf("get tsmp Sync pkt ! \n");
        sync_handler(pkt,imac);                                      //对报文信息进行读取
	//printf("handler tsmp Sync pkt ! \n");
        delay_req_pkt_build(pkt,imac);                          //构造Delay_req_pkt
	//printf("build tsmp delay_req pkt ! \n");

        pthread_mutex_lock(&pkt_send_lock);

        data_pkt_send_handle((u8*)pkt,pkt_len);	                    //发送报文
	//printf("build tsmp delay_req pkt ! \n");

        pthread_mutex_unlock(&pkt_send_lock);

        //free_pkt(pkt);        	                                //释放tsmp报文

	}else if(pkt->ptp_type == 0x3 && pkt->sync_seq == sync_seq-1){



	    imac = delay_req_handler(pkt);              // 对delay_req报文进行解析

	    offset_calu(imac);                         //对offset值进行计算
     //   file_write(imac,table.table[imac].sync_seq,table.table[imac].offset_flag,table.table[imac].Latest_Offset);

        pthread_mutex_lock(&pkt_send_lock);           //加锁

	    offset_cfg_send(imac);                     //发送offset配置报文

        pthread_mutex_unlock(&pkt_send_lock);            //解锁


      //  free_pkt(pkt);        	                               //释放tsmp报文
/*
    build_send_chip_cfg_pkt(value,CHIP_OFFSET_PERIOD_ADDR,1,&(frequency));
    nmac_pkt = build_tsmp_pkt(sub_type,imac,len);	           //构造tsmp（nmac)报文,所返回的指针为偏移tsmp头之后的数据报文指针地址

        data_pkt_send_handle(pkt,len);                         //发送报文


        free_pkt(pkt);	                                       //释放tsmp报文
*/



	}else if(pkt->ptp_type == 0x3 && pkt->sync_seq != sync_seq-1){

        printf("sync seq erro! \n");
        printf("sync seq = %d  , pkt seq = %d  \n",sync_seq,pkt->sync_seq);
	}


	/*********************************end***************/
	return ;
}



/*void ptp_init(){
    char test_rule[64] = {0};
	char temp_net_interface[16]={0};

	sprintf(test_rule,"%s","ether[3:1]=0x05 and ether[12:2]=0xff01");       //libpcap规则和网卡接口赋值
	sprintf(temp_net_interface,"%s","enp0s3");


	data_pkt_receive_init(test_rule,temp_net_interface);           //初始化数据报文接收与发送
	data_pkt_send_init(temp_net_interface);

    memset(&table,0,sizeof(sync_info_table));     // 对信息记录表进行初始化
}


void start_ptp(){


    data_pkt_receive_loop(ptp_callback);

}



void ptp_destroy(){
	data_pkt_receive_destroy();
	data_pkt_send_destroy();
}
*/
