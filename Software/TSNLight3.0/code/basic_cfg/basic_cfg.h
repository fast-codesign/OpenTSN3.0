#ifndef _BASIC_CFG_H__
#define _BASIC_CFG_H__


#include "../net_init/net_init.h"



int basic_cfg(u8 *pkt,u16 pkt_len);

int init_cfg_fun(u8 node_idx);
u16 get_imac_from_tsntag(u8 *tsntag);

#endif



