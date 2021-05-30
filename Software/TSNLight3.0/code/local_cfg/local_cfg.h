#ifndef _LOCAL_CFG_H__
#define _LOCAL_CFG_H__


#include "../net_init/net_init.h"


map_table_info map_table[32];//hcp映射表
remap_table_info remap_table[256];//hcp重映射表

#define OFFLINE_PLAN_XML_FILE "./local_cfg/local_cfg_xml.xml"


int local_cfg(u8 *pkt,u16 pkt_len);

#endif




