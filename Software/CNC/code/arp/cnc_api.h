#ifndef CNC_API_H
#define CNC_API_H


#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>/*memcpy*/
#include <strings.h>/*bzero*/

#include <unistd.h>
#include <pcap.h>
#include <errno.h>

#include <arpa/inet.h>/*htons,ntohs*/

#include <endian.h>/*htobeXX,beXXtoh,htoleXX,leXXtoh*/
#include <sys/types.h>
#include <sys/socket.h>
#include <linux/in.h>/*struct sockaddr_in*/
#include <linux/if_ether.h>/*struct ethhdr*/
#include <linux/ip.h>/*struct iphdr*/
#include <sys/ioctl.h>
#include <net/if.h>
#include <netpacket/packet.h>



#include "tsmp_protocol.h"
#include "reg_cfg.h"
#include "beacon_report.h"


#define CNCAPI_DEBUG 1
//#undef CNCAPI_DEBUG

#if CNCAPI_DEBUG
	#define CNCAPI_DBG(args...) do{printf("CNCAPI-INFO: ");printf(args);}while(0)
	#define CNCAPI_ERR(args...) do{printf("CNCAPI-ERROR: ");printf(args);exit(0);}while(0)
#else
	#define CNCAPI_DBG(args...)
	#define CNCAPI_ERR(args...)
#endif



/**************数据接收相关API**************/
//数据报文接收初始化函数
int data_pkt_receive_init(u8* rule,u8* net_interface);

//数据报文接收处理函数（循环抓包）
int data_pkt_receive_loop(pcap_handler callback);

//数据报文接收处理函数（每次只抓一个包）
int data_pkt_receive_dispatch(pcap_handler callback);

//数据报文接收销毁函数
int data_pkt_receive_destroy();


/**************数据发送相关API**************/
//数据报文发送初始化函数
int data_pkt_send_init(u8* net_interface);

//数据报文发送处理函数
int data_pkt_send_handle(u8* pkt,u16 len);

//数据报文发送销毁函数
int data_pkt_send_destroy();


/**************tsmp协议相关API**************/

//构造tsmp报文，并填充tsmp头
u8* build_tsmp_pkt(tsmp_sub_type type,u16 dimac,u16 pkt_len);

//tsmp报文头源目的mac互换
u8* tsmp_header_switch_handle(u8* pkt,u16 len);


//从tsmp报文头中取出源mac的imac字段，返回的imac是网络序
u16 get_simac_from_tsmp_pkt(u8* pkt,u16 len);

//对报文进行内存释放，需要遵循谁申请谁释放的原则
void free_pkt(u8* pkt);


/**************调试工具相关API**************/
//报文打印
void cnc_pkt_print(u8 *pkt,int len);



#endif

