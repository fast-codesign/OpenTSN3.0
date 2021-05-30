#ifndef _NET_INIT_H__
#define _NET_INIT_H__

#include"../cnc_api/include/cnc_api.h"

#if 1
#include <libxml/xmlmemory.h>  
#include <libxml/parser.h>  
#endif



typedef char s8;				/**< 有符号的8位（1字节）数据定义*/
typedef unsigned char u8;		/**< 无符号的8位（1字节）数据定义*/
typedef short s16;				/**< 有符号的16位（2字节）数据定义*/
typedef unsigned short u16;	/**< 无符号的16位（2字节）数据定义*/
typedef int s32;				/**< 有符号的32位（4字节）数据定义*/
typedef unsigned int u32;		/**< 无符号的32位（4字节）数据定义*/
typedef long long s64;				/**< 有符号的64位（8字节）数据定义*/
typedef unsigned long long u64;		/**< 无符号的64位（8字节）数据定义*/

#define DATA_OFFSET 16//芯片上报报文偏移该值获取上报数据域


#define MAX_INIT_FORWARD_NUM   100  /*最大初始转发表的数量为100*/
#define INIT_MAX_NODE_NUM   10  /*最大初始转发表的数量为100*/


#define INIT_XML_FILE "./net_init/init_cfg_xml.xml"

#define DEFAULT_PERCISION 100

#define BUF_SIZE 1024




//时间同步参数
u16 SYNC_PERIOD; //时间同步周期，单位为ms
u16 MASTER_IMAC; //主时钟的imac地址
u16 SYNC_FLOWID; //sync组播的flowid


//上报周期 
u16 REPORT_PERIOD;

//转发表
typedef struct 
{
	u16 flowid;//imac或者flowID	
	u16 outport;//输出端口
} forward_info;


//初始化配置结构体
typedef struct 
{
	u16 imac;	  //imac地址
	u8  forward_table_num;//初始转发表的数量
	chip_reg_info reg_data;//寄存器内容
	forward_info forward_table[MAX_INIT_FORWARD_NUM];//转发表
}init_cfg_info;

init_cfg_info init_cfg[INIT_MAX_NODE_NUM];

//当前节点的数量 
u16 cur_node_num;

//当前转发表的索引 
u16 cur_forward_idx;



void parse_register_xml( xmlNodePtr cur);
void parse_forward_entry(xmlNodePtr cur);


int net_init(u8 *network_inetrface);

#endif




