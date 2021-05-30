#ifndef _REMOTE_CFG_H__
#define _REMOTE_CFG_H__


#include "../net_init/net_init.h"



#define reg_type        0x00
#define forward_type    0x01
#define gate_port0_type 0x02
#define gate_port1_type 0x03
#define gate_port2_type 0x04
#define gate_port3_type 0x05
#define gate_port4_type 0x06
#define gate_port5_type 0x07
#define gate_port6_type 0x08
#define gate_port7_type 0x09
#define inject_type     0x0a
#define submit_type     0x0b
#define map_type        0x0c
#define remap_type      0x0d






typedef struct
{
	u8 report_type;
	u8 cfg_state;
	u16 imac;
}__attribute__((packed))report_confirm;


typedef struct
{
	u8 version;
	u8 type;
	u16 len;
	u8  tail_flag;
	u16 imac;
}__attribute__((packed))tsn_rcp_head;

typedef struct
{
	u8 dst_mac[6];
	u8 src_mac[6];	
	u16 pro_type; 
	u8  ip_head1[9];
	u8  udp_type;
	u8  ip_head2[10];
	
	u16 src_port;
	u16 dst_port;
	u16 len;//ip报文长度
	u16 sum_check;
	
	tsn_rcp_head tsn_rpc;
	
	u8 data[0];

}__attribute__((packed))tsn_rcp_pkt;



int remote_cfg(u8 *pkt,u16 pkt_len);


int send_remote_state();

int send_remote_confirm(u8 type,u16 len,u8 tail_flag,u16 imac,u8 *data);


#endif




