#ifndef PTP_SINGLE_PROCESS_H_INCLUDED
#define PTP_SINGLE_PROCESS_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <malloc.h>
#include <unistd.h>
#include "../cnc_api/include/cnc_api.h"
#include "../state_monitor/state_monitor.h"



typedef char s8;				/**< �з��ŵ�8λ��1�ֽڣ����ݶ���*/
typedef unsigned char u8;		/**< �޷��ŵ�8λ��1�ֽڣ����ݶ���*/
typedef short s16;				/**< �з��ŵ�16λ��2�ֽڣ����ݶ���*/
typedef unsigned short u16;	/**< �޷��ŵ�16λ��2�ֽڣ����ݶ���*/
typedef int s32;				/**< �з��ŵ�32λ��4�ֽڣ����ݶ���*/
typedef unsigned int u32;		/**< �޷��ŵ�32λ��4�ֽڣ����ݶ���*/
typedef long long s64;				/**< �з��ŵ�64λ��8�ֽڣ����ݶ���*/
typedef unsigned long long u64;		/**< �޷��ŵ�64λ��8�ֽڣ����ݶ���*/
typedef struct {
    u64 t1;
    u64 t2;
    u64 corr_ms;
    u64 t3;
    u64 t4;
    u64 corr_sm;
    u64 sync_seq;
    u64 Latest_Offset;
    u64 Avg_Offset;
    u64 Corr_Fre;
    u16 guide_offset;
    u32 guide_offset_frequency;
    u8 guide_offset_flag;
    u64 preoffset;
    u8 offset_flag;
}sync_info;



typedef struct {
    sync_info table[101];
    int info_count;
}sync_info_table;



typedef struct{
    u8  ptp_des_mac[6];   // 48λptp����Ŀ��mac��ַ
    u8  ptp_src_mac[6];    // 48λptp����Դmac��ַ�ֶ�
    u16  eth_type:16;            // 16λ���������ֶ�
    u8   ptp_type:4,            //4λPTP�����ֶ�
         reserve1:4;
    u8  reserve2;
    u16 pkt_length;                 //16λ���ĳ���
    u16 reserve3;
    u16 reserve4;
    u8  corrField[8];             //�������ֶ�
    u16 reserve5;
    u32 reserve6[2];
    u64 sync_seq;
    u16 reserve8;
    u8 timestamp1[8];                       //ʱ���1�ֶ�
    u8 timestamp2[6];                    //ʱ���2�ֶ�
}__attribute__((packed))ptp_pkt;

int ptp_init(u16 set_time,u16 mul_imac,u16 master_imac,u8 set_precision);   //ʱ��ͬ����ʼ��

void ptp_handle(u16 pkt_len,const unsigned char *packet_content);           //���յ�����PTP�����߼�

u16 sync_period_timeout();                                                   //PTPͬ�����ڳ�ʱ�ж�

#endif // PTP_SINGLE_PROCESS_H_INCLUDED
