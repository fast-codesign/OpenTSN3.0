#include "ptp_single_process.h"

u16 ptp_mult_imac ;                                    //�鲥imac
u16 ptp_master_imac ;                               //��ʱ��imac
u32 ptp_period;                                      // ��΢��Ϊ��λ
sync_info_table table;
u64 sync_seq ;                                      //��ʼͬ������Ϊ1
u8 precision;                                       //ͬ��������ֵ
u16 SYNC_TO_INIT_SHRESHOLD = 100;                    //��¼��ǰͬ����ʼ״̬���ʼ״̬ת������ֵ
u16 consequent_sync =0;                                //��¼��ǰͬ������С����ֵ������ͬ������
struct  timeval  tv_sync;                          //��¼�ϴ�ͬ����ϵͳʱ��




/**************ʱ�������API**************/

u64 ts_add(u64 u1,u64 u2){              //ʱ�����Ӻ���
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

u64 ts_sub(u64 u1, u64 u2){               // ʱ����������
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

u64 corr_trans(u64 a){                    //������ʱ�����ʽת������
    u64 corr_7 = a%125;
    u64 corr_41 = (a/125)*128 ;
	return corr_41+corr_7;
}

/**************�ֽ���ת��API**************/
/*
u32 htonl(u32 a){                        //16λ����ת������

    return ((a >> 24) & 0x000000ff) |         ((a >>  8) & 0x0000ff00) |         ((a <<  8) & 0x00ff0000) |         ((a << 24) & 0xff000000);

};

u16 htons(u16 a){                       //32λ����ת������
  return ((a >> 8) & 0x00ff) | ((a << 8) & 0xff00);

};

u64 htonll(u64 a){                      //64λ����ת������
    return ((a>>56)&0X00000000000000ff) | ((a>>40)&0X000000000000ff00) | ((a>>24)&0X0000000000ff0000) | ((a>>8)&0X00000000ff000000) | ((a<<8)&0X000000ff00000000)| ((a<<24)&0X0000ff0000000000)| ((a<<40)&0X00ff000000000000)| ((a<<56)&0Xff00000000000000);
};
*/


/**************�ֶδ���API**************/

void dmac_transf_tag(u8 *tmp_dmac,u8 flow_type,u16 flowid,u16 seqid,u8 frag_flag,u8 frag_id,u8 inject_addr,u8 submit_addr ){    //Ŀ��MACת������
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

u32 get_l_offset(u64 offset){                                //ȡƫ��ֵ��32λ
    return htonl((u32)offset);

}

u32 get_h_offset(u64 offset,u8 offset_flag){                 //ȡƫ��ֵ��16λ������λ
    if(offset_flag == 0 ){
        offset = offset + 0x1000000000000;
    }
    return htonl((u32)(offset>>32));
}

u16 mac_to_flow_id(u64 mac){            //��ɴ�48λmac�ֶ���ȡ14λimac��ַ
    mac = mac>>31 ;
    return mac % 0x4000;
}

char*  get_ptp_src_mac_addr(ptp_pkt* pkt){                  //�ӽ��յ���ptp_pkt��ȡ��ԴMac�ĵ�ַ
    char src_mac[6];
    char* ptr = NULL;
    int i;
    for(i=0;i<6;i++){
        src_mac[i]=pkt->ptp_src_mac[i];
    }
    ptr = src_mac;
    return ptr;

};

u64 get_ptp_src_mac(ptp_pkt* pkt){                         //�ӽ��յ���ptp_pkt��ȡ��ԴMac
    u64* a ;
    a = (u64*)get_ptp_src_mac_addr(pkt);
    return htonll(*a)>>16;

}

char*  get_ptp_des_mac(ptp_pkt* pkt){                      //�ӽ��յ���ptp_pkt��ȡ��Ŀ��Mac�ĵ�ַ
    char des_mac[6];
    char* ptr = NULL;
    int i;
    for(i=0;i<6;i++){
        des_mac[i]=pkt->ptp_des_mac[i];
    }
    ptr = des_mac;
    return ptr;

};

long long get_corr(ptp_pkt* pkt){                          //�ӽ��յ���ptp_pkt��ȡ���������ֶ�ֵ
    long long * ptr;
    ptr = (long long *)(pkt->corrField);
    return htonll(*ptr);
};

long long get_pkt_ts1(ptp_pkt* pkt){                       //�ӽ��յ�ptp_pkt��ȡ������Я����ʱ���1
    long long * ptr;
    ptr = (long long *)(pkt->timestamp1);
    return htonll(*ptr);
};

long long get_pkt_ts2(ptp_pkt* pkt){                      //�ӽ��յ�ptp_pkt��ȡ������Я����ʱ���2
    long long * ptr;
    ptr = (long long *)(pkt->timestamp2);
    return (htonll(*ptr))>>16;
};

void set_ptp_src_mac(ptp_pkt* pkt,char* ptr){             //�Թ����ptp_pkt����Ŀ��Mac
    int i;
    for(i=0;i<6;i++){
        pkt->ptp_src_mac[i]=*(ptr+i);}

};

void set_ptp_des_mac(ptp_pkt* pkt,char* ptr){            //�Թ����ptp_pkt����Ŀ��Mac
    int i;
    for(i=0;i<6;i++){
        pkt->ptp_des_mac[i]=*(ptr+i);}

};

/**************���Ĺ���/����API**************/

int ptp_init(u16 set_time,u16 mul_imac,u16 master_imac,u8 set_precsion){
        ptp_period = set_time*1000 ;
	ptp_master_imac = master_imac;
	ptp_mult_imac = mul_imac ;
	precision = set_precsion;
	//printf("set period = %d  ptp_period =%lld ********************************************************************** \n",set_time,ptp_period);
	sync_seq = 0;                       // ��ʼ��ͬ������
	tv_sync.tv_sec = 0;                 // ��ͬ��ʱ������Ϊ0
	tv_sync.tv_usec = 0;
	memset(&table,0,sizeof(sync_info_table));   //��ʼ��ͬ����Ϣ��

    return 0;
}

void table_sync_in(int value,u64 t1,u64 t2,u64 corr_ms){     //����Sync_stamped���ĵ�ʱ����Ϣ�Ա��������д
    table.table[value].t1 = t1;
    table.table[value].t2 = t2;
    table.table[value].corr_ms = corr_ms;
    return ;

}

void table_sync_reply_in(int value,u64 t3,u64 t4,u64 corr_sm){      //����Sync_reply_stamped���ĵ�ʱ����Ϣ�Ա��������д
    table.table[value].t3 = t3;
    table.table[value].t4 = t4;
    table.table[value].corr_sm = corr_sm;
    return ;

}

u16 sync_cnt = 0;

void offset_calu(int value){                            //����imac������Ϣ������offset���м���
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
    update_offset(value,table.table[value].Latest_Offset);
    //printf("imac = %d, t1 = %lld\n",value,table.table[value].t1);
    //printf("imac = %d, t2 = %lld\n",value,table.table[value].t2);
    //printf("imac = %d, corr_ms = %lld\n",value,table.table[value].corr_ms);
    //printf("imac = %d, t3 = %lld\n",value,table.table[value].t3);
    //printf("imac = %d, t4 = %lld\n",value,table.table[value].t4);	
    //printf("imac = %d, corr_ms = %lld\n",value,table.table[value].corr_sm);	
    printf("imac = %d, offset = %lld\n",value,table.table[value].Latest_Offset);
    //printf("imac = %d, guide_offset_frequency = %d\n",value,table.table[value].guide_offset_frequency);


/*
    u32 cfg_data = 0;
    if(table.table[value].Latest_Offset < 50)
    {
        sync_cnt++;
        if(200>sync_cnt && sync_cnt>100)
        {
            	//配置完成寄存器默认值2，可以传输非ST流
            cfg_data = 3;
            printf("cfg finish %d\n",cfg_data);
            build_send_chip_cfg_pkt(value,CHIP_CFG_FINISH_ADDR,1,(u32 *)&cfg_data);//配置端口类型

        }

    }
*/

    if (table.table[value].sync_seq == 10 ){
            table.table[value].guide_offset = 1;
		if(table.table[value].Latest_Offset != 0){
            table.table[value].guide_offset_frequency = ptp_period*1000/(8*table.table[value].Latest_Offset);
		}else {
                                    table.table[value].guide_offset_frequency = ptp_period*1000/8;
}
            table.table[value].guide_offset_flag = table.table[value].offset_flag ;
            table.table[value].preoffset = table.table[value].preoffset + table.table[value].Latest_Offset;
            //���챨�ġ����Ա��Ľ��з���

	}else if(table.table[value].sync_seq>10 ){
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
                      table.table[value].guide_offset_frequency = ptp_period*1000/8;
                }else{
                table.table[value].guide_offset_frequency = ptp_period*1000/(8*table.table[value].preoffset);
                 }

          //  Local_ts_info.guide_offset = Local_ts_info.guide_offset - Local_ts_info.offset/25;
	    }else {
	        table.table[value].preoffset = table.table[value].preoffset + table.table[value].Latest_Offset ;
	        table.table[value].guide_offset = 1 ;
                if(table.table[value].preoffset == 0){
                      table.table[value].guide_offset_frequency = ptp_period*1000/8;
                }else{
                table.table[value].guide_offset_frequency = ptp_period*1000/(8*table.table[value].preoffset);
                 }
	    }
	    //���챨�ġ����Ա��Ľ��з���
    }
    table.table[value].sync_seq = table.table[value].sync_seq +1 ;        //ÿ�μ���ƫ��ֵ��ʱ��ͬ�����м�1
}

void pkt_init(ptp_pkt* pkt){                  //PTP���Ĺ���ĳ�ʼ������
    memset(pkt,0,sizeof(ptp_pkt));
    return ;
};

int sync_pkt_build(ptp_pkt* pkt){                      //��sync���ĵĹ���
    pkt_init(pkt);                                    //���ĳ�ʼ��
    dmac_transf_tag(pkt->ptp_des_mac,0X4,ptp_mult_imac,0X0000,0X00,0X00,0X00,0X00);      //���PTPĿ��MAC�ֶ�
    dmac_transf_tag(pkt->ptp_src_mac,0x4,ptp_master_imac,0x0000,0x00,0x00,0x00,0x00);     //���PTPԴMAC�ֶ�
    pkt->eth_type=htons(0X98F7);                         //��̫�������ֶ����
    pkt->ptp_type=0X1;                                   //ptp�����ֶ����
    pkt->pkt_length = htons(72);                         //���ĳ����ֶ����
    pkt->sync_seq = sync_seq;
    sync_seq = sync_seq + 1;
    return sizeof(ptp_pkt);
};

int sync_reply_pkt_build(ptp_pkt * pkt,u16 ptp_slave_imac){            //��Delay_req���Ľ��й���
    dmac_transf_tag(pkt->ptp_src_mac,0X4,ptp_slave_imac,0X0000,0X00,0X00,0X00,0X00);     //���PTPԴMAC�ֶ�
    dmac_transf_tag(pkt->ptp_des_mac,0X4,ptp_master_imac,0X0000,0X00,0X00,0X00,0X00);      //���PTPĿ��MAC�ֶ�
    pkt->ptp_type=0X3;       ////ptp�����ֶ����
    memset(pkt->timestamp1,0,8);
    memset(pkt->timestamp2,0,6);
    memset(pkt->corrField,0,8);                             //ʱ�����͸��ʱ���ֶ����0
    return sizeof(ptp_pkt);

}

void offset_cfg_send(u16 value){
    u32 offset_cfg_arr[2];
    u32 frequency = 0;
    offset_cfg_arr[0] = htonl(get_l_offset(table.table[value].Latest_Offset));
    offset_cfg_arr[1] = htonl(get_h_offset(table.table[value].Latest_Offset,table.table[value].offset_flag));
    build_send_chip_cfg_pkt(value,CHIP_OFFSET_L_ADDR,2,offset_cfg_arr);
    build_send_chip_cfg_pkt(value,CHIP_OFFSET_PERIOD_ADDR,1,&(frequency));   //��������Ϊ0�����ñ��ġ�ֻ����һ��
    if(table.table[value].sync_seq >= 10){
        offset_cfg_arr[0] = htonl(get_l_offset(table.table[value].guide_offset));
        offset_cfg_arr[1] = htonl(get_h_offset((table.table[value].guide_offset),table.table[value].guide_offset_flag));
        build_send_chip_cfg_pkt(value,CHIP_OFFSET_L_ADDR,2,offset_cfg_arr);
        build_send_chip_cfg_pkt(value,CHIP_OFFSET_PERIOD_ADDR,1,&(table.table[value].guide_offset_frequency));
    }
}

void sync_raw_pkt_send(){                                     //sync_raw ���ķ���
    ptp_pkt* pkt;

    pkt = (ptp_pkt*)build_tsmp_pkt(TSMP_PTP,ptp_master_imac,64);                    // ����tsmp����ͷ

    sync_pkt_build(pkt);                                                       //��sync�������ݽ������

    data_pkt_send_handle((u8*)pkt,64);                                             //��sync_raw���Ľ��з���

    free_pkt((u8*)pkt);

}

void sync_stamped_handler(ptp_pkt * pkt,u16 imac){                                    //���յ���Sync_stamped������Ϣ���뵽ͬ����Ϣ����

    table_sync_in(imac,get_pkt_ts1(pkt),get_pkt_ts2(pkt),get_corr(pkt));
}

u16 sync_reply_stamped_handler(ptp_pkt * pkt){                               //���յ���Sync_reply_stamped������Ϣ���뵽ͬ����Ϣ����
    u64 tmp_addr;
    tmp_addr = get_ptp_src_mac(pkt);
   // printf("imac = %d \n",mac_to_flow_id(tmp_addr));
    table_sync_reply_in(mac_to_flow_id(tmp_addr),get_pkt_ts1(pkt),get_pkt_ts2(pkt),get_corr(pkt));
    return mac_to_flow_id(tmp_addr);                                                              //���ش�ʱ�ӵ�ַ
}

u16 sync_period_timeout(){                                                       //�ж��Ƿ�ͬ����ʱ
    //return 0;
    struct  timeval tv_current;
    u64 time_interval;
    gettimeofday(&tv_current,NULL);
    time_interval = (tv_current.tv_sec - tv_sync.tv_sec)*1000000+(tv_current.tv_usec - tv_sync.tv_usec);     //��ȡ��ǰʱ�����ϴ�ͬ��ʱ��ļ��
    if(time_interval > ptp_period){
        sync_raw_pkt_send();
        printf("tv_sync.tv_sec = %ld , tv_sync.tv_usec =%ld , time_interval = %lld , ptp_period = %d\n" ,tv_sync.tv_sec,tv_sync.tv_usec,time_interval,ptp_period);
        tv_sync.tv_sec = tv_current.tv_sec;
        tv_sync.tv_usec = tv_current.tv_usec;
        return 1;      
	}		//
    else{
        return 0;
	}

}


int is_precision_in_shreshold(){
    if(sync_seq > 0 ){
        for(int i = 0;i<10;i++){
            if(table.table[i].Latest_Offset > precision)
                return 0;
		}
    }else{
            return 0;                        //sync_seq = 0 :��ǰ��һ��ͬ����δ���  �޷��ж�ϵͳ�����Ƿ�С����ֵ
    }
    return 1;
}



void ptp_handle(u16 pkt_len,const unsigned char *packet_content)
{
   // return;
	 tsmp_header * tmp = (tsmp_header*)packet_content;
	if((htons(tmp->type)==0xff01)&&(tmp->sub_type==0x05)){	
        u16 imac=0;
	u16 ptp_pkt_len = 0;
	ptp_pkt* pkt = NULL;     //������ʼ��
	ptp_pkt_len = pkt_len - 16;
	imac = get_simac_from_tsmp_pkt((u8*)packet_content,pkt_len);       //�ֽ���ת��
	//printf("imac = %d\n",imac);
	pkt = (ptp_pkt*)tsmp_header_switch_handle((u8*)packet_content,pkt_len);           //������ֵ

	/*��ʱpkt��pkt_len�Ѿ�������tsmpͷ,ΪPTP����*/
	if(pkt->ptp_type == 0x1 && pkt->sync_seq == sync_seq-1){
        sync_stamped_handler(pkt,imac);                                      //�Ա�����Ϣ���ж�ȡ

        sync_reply_pkt_build(pkt,imac);                          //����sync_reply_raw����

        data_pkt_send_handle((u8*)pkt,ptp_pkt_len);	                    //���ͱ���

	}else if(pkt->ptp_type == 0x3 && pkt->sync_seq == sync_seq-1){

	    imac = sync_reply_stamped_handler(pkt);              // ��delay_req���Ľ��н���

	    offset_calu(imac);                         //��offsetֵ���м���

	    offset_cfg_send(imac);                     //����offset���ñ���
	    printf("state = %d  \n",G_STATE);

	    if(G_STATE == SYNC_INIT_S){

            if(is_precision_in_shreshold()){                  //�ж�ϵͳͬ�������Ƿ�С����ֵ
            G_STATE = NW_RUNNING_S;                       //��ת����������״̬
            u32 cfg_data = 3;
            printf("11cfg finish %d\n",cfg_data);
            build_send_chip_cfg_pkt(1,CHIP_CFG_FINISH_ADDR,1,(u32 *)&cfg_data);//配置端口类型
            for(int i =0;i<101;i++){
                if(table.table[i].sync_seq!=0){
                     build_send_chip_cfg_pkt(i,CHIP_CFG_FINISH_ADDR,1,(u32 *)&cfg_data);//配置端口类型
                }
            }
            consequent_sync = 0;
        }else{
            consequent_sync++;
            if(consequent_sync>SYNC_TO_INIT_SHRESHOLD){
                G_STATE = INIT_S;                             //��ת����ʼ״̬
            }
        }
	    printf("state = %d  \n",G_STATE);

	    }


	}else if(pkt->ptp_type == 0x3 && pkt->sync_seq != sync_seq-1){

        printf("sync seq erro! \n");
        printf("sync seq = %lld  , pkt seq = %lld  \n",sync_seq,pkt->sync_seq);
	}


	/*********************************end***************/
	return ;
    }else {
                //printf("ptp handle accept ");
            return;
        }

}

