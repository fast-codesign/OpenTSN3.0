#ifndef _NET_INIT_H__
#define _NET_INIT_H__

#include"../cnc_api/include/cnc_api.h"

#include <libxml/xmlmemory.h>  
#include <libxml/parser.h>  


#define MAX_INIT_FORWARD_NUM   0x100  /*最大初始转发表的数量为100*/


//#define CTL_IMAC   0x0  /*控制器的imac地址*/



//在通用函数中reg_cfg.h中定义
#if 0

//配置
#define CHIP_OFFSET_L_ADDR 		0x00000000  /*时钟偏移的低位*/
#define CHIP_OFFSET_H_ADDR 		0x00000001	/*时钟偏移的高位*/
#define CHIP_TIME_SLOT_ADDR 			0x00000002	/*时间槽长度*/
#define CHIP_CFG_FINISH_ADDR    		0x00000003  /*配置完成寄存器*/
#define CHIP_PORT_TYPE_ADDR 			0x00000004  /*端口类型*/
#define CHIP_QBV_QCH_ADDR 				0x00000005  /*qbv和qch寄存器*/
#define CHIP_REPORT_TYPE_ADDR 			0x00000006  /*上报类型*/
#define CHIP_REPORT_EN_ADDR 			0x00000007  /*上报使能*/
#define CHIP_INJECT_SLOT_PERIOD_ADDR 	0x00000008  /*注入周期*/
#define CHIP_SUBMIT_SLOT_PERIOD_ADDR	0x00000009  /*提交周期*/
#define CHIP_REPORT_PERIOD_ADDR 		0x0000000a  /*上报周期*/
#define CHIP_OFFSET_PERIOD_ADDR 		0x0000000b  /*offset周期*/
#define CHIP_RC_REGULATION_ADDR 		0x0000000c  /*RC流阈值*/
#define CHIP_BE_REGULATION_ADDR 		0x0000000d  /*BE流阈值*/
#define CHIP_UNMAP_REGULATION_ADDR 		0x0000000e  /*未经映射流的阈值*/
                                                    
#define CHIP_TIS_BASE_ADDR 			0x00100000  /*注入表基地址*/
#define CHIP_TSS_BASE_ADDR 			0x00200000  /*提交表基地址*/
#define CHIP_QGC0_BASE_ADDR 			0x00300000  /*端口0的门控基地址*/
#define CHIP_QGC1_BASE_ADDR 			0x00400000  /*端口1的门控基地址*/
#define CHIP_QGC2_BASE_ADDR 			0x00500000  /*端口2的门控基地址*/
#define CHIP_QGC3_BASE_ADDR 			0x00600000  /*端口3的门控基地址*/
#define CHIP_QGC4_BASE_ADDR 			0x00700000  /*端口4的门控基地址*/
#define CHIP_QGC5_BASE_ADDR 			0x00800000  /*端口5的门控基地址*/
#define CHIP_QGC6_BASE_ADDR 			0x00900000  /*端口6的门控基地址*/
#define CHIP_QGC7_BASE_ADDR 			0x00a00000  /*端口7的门控基地址*/
#define CHIP_GTS_BASE_ADDR 			0x00b00000  /*全局时钟基地址*/
#define CHIP_FLT_BASE_ADDR 			0x00c00000  /*查表转发基地址*/



//上报
#define CHIP_REGISTER_REPORT 	0x0  /*单个寄存器上报 16bit*/
#define CHIP_FORWARD_REPORT 	0x0400  /*转发表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_TIS_REPORT 		0x0800  /*注入表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_TSS_REPORT 		0x0C00  /*提交表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC0_REPORT 		0x1000  /*0号端口门控表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC1_REPORT 		0x1400  /*1号端口门控表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC2_REPORT 		0x1800  /*2号端口门控表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC3_REPORT 		0x1C00  /*3号端口门控表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC4_REPORT 		0x2000  /*4号端口门控表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC5_REPORT 		0x2400  /*5号端口门控表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC6_REPORT 		0x2800  /*6号端口门控表上报的基地址，每次上报32条转发表 16bit*/
#define CHIP_QGC7_REPORT 		0x2C00  /*7号端口门控表上报的基地址，每次上报32条转发表 16bit*/

#define STATE_REPORT 			0x3000  /*7号端口门控表上报的基地址，每次上报32条转发表 16bit*/




#define HCP_MAP_BASE_ADDR     0x82000000  /*HCP第一跳映射表基地址，最高位表示有效位，默认有效*/
#define HCP_REMAP_BASE_ADDR	  0x83000000  /*HCP最后一跳重映射表基地址，最高位表示有效位，默认有效，低14bit表示flowID，硬件根据低14bit进行索引*/

#define HCP_PORT_TYPE_ADDR    0x80000000  /*HCP的端口类型地址，最高位表示有效位，默认有效*/
#define HCP_REPORT_TYPE_ADDR  0x80000001  /*HCP的上报类型寄存器*/
#define HCP_STATE_ADDR  	  0x81000000  /*HCP的状态寄存器*/

#define HCP_REG_STATE_REPORT  0x0  /*单个寄存器上报和状态上报*/
#define HCP_MAP_REPORT		  0x1000  /*映射表上报*/
#define HCP_REMAP_REPORT	  0x2000  /*重映射表上报*/


#endif




#define DATA_OFFSET 16//芯片上报报文偏移该值获取上报数据域
//#define HCP_DATA_OFFSET 16//HCP上报报文偏移该值获取上报数据域




//时间同步参数
u16 SYNC_PERIOD; //时间同步周期，单位为ms
u16 MASTER_IMAC; //主时钟的imac地址
u16 SYNC_FLOWID; //sync组播的flowid
//转发表
typedef struct 
{
	u16 imac_flowid;//imac或者flowID	
	u16 outport;//输出端口
} forward_info;

//初始化配置结构体
typedef struct 
{
	u16 imac;	  //imac地址
	u8  port_type;//端口类型
	u8  max_flowid;//最大的flowID
	forward_info forward_table[MAX_INIT_FORWARD_NUM];//转发表
} init_cfg_info;

//init_cfg_info init_cfg; //初始配置结构体变量,每次读取一个节点的所有配置内容，存储在该数据结构中



#if 0

//芯片寄存器的数据结构
typedef struct
{
	u64 offset:49,//ptp时钟偏移值
		reserve:5,//保留位
		cfg_finish:2,//配置完成寄存器
		port_type:8;//端口类型
	u64 slot_len:11, //时间槽长度
		reserve1:2,//保留位
		inj_slot_period:11,//注入时间槽周期
		reserve2:5,//保留位
		sub_slot_period:11,//提交时间槽周期
		qbv_or_qch:1,//调度模式
		reserve3:4,//保留位
		report_period:12,//上报周期
		report_high:8;//上报类型的高8it
	u16 report_low:8,//上报类型的低8bit
		report_enable:1,//上报使能
		reserve6:7;//保留位		
}__attribute__((packed))chip_reg_info;



/*芯片表项上报*/
typedef struct
{
	u16 table[32];//每个上报表项16bit，每次上报32个表项
}__attribute__((packed))chip_report_table_info;





/*芯片表配置*/
typedef struct
{
	u32 table[16384];
	/*每个配置表项32bit，每次读取完一类表项再去配置，
	在芯片配置时，每个报文只配置16条表项，配置32条表项后进行上报确认，因为每次上报32条表项
	*/
}__attribute__((packed))chip_cfg_table_info;




/*TSNtag*/
typedef struct
{
	u32 flow_type:3,//流类型
		flow_id:14,//静态流量使用flowID,每条静态流分配一个唯一flowID
		seq_h:15;//用于标识每条流中报文的序列号，高15位
	u16 seq_l:1,//用于标识每条流中报文的序列号，低1位
		frag_flag:1,//用于标识分片后的尾。0:分片后的中间报文	,1:尾拍
		frag_id:4,//用于表示当前分片报文在原报文中的分片序列号
		inject_addr:5,//TS流在源端等待发送调度时缓存地址
		submit_addr:5;//TS流在终端等待接收调度时缓存地址
}__attribute__((packed))tsn_tag; 


/*tsmp报文头部*/
typedef struct
{
	tsn_tag dmac;//dmac
	tsn_tag smac;//源mac
	u16 type; 		/* 协议类型   */
	u8 sub_type;/* TSMP协议子类型   */
	u8 inport;/* TSMP协议子类型   */
}__attribute__((packed))tsmp_header;


/*TSMP子类型*/
typedef enum
{
	/*握手报文*/
	TSMP_ARP = 0x00,/*arp帧*/
	TSMP_BEACON = 0x01,/*beacon帧*/
	TSMP_CHIP_CFG = 0x02,/*芯片配置帧*/
	TSMP_HCP_CFG = 0x03,/*HCP配置帧*/
	TSMP_HCP_REPORT = 0x04,/*HCP状态上报帧*/
	TSMP_PTP = 0x05,/*PTP帧*/
}tsmp_sub_type;




/*NMAC配置报文*/
typedef struct
{
	tsn_tag dst_tsn_tag;
	tsn_tag src_tsn_tag;
	u16 type;
	u16 count;
	u32 addr;
	u8 data[0];
}__attribute__((packed))nmac_pkt;



//hcp映射表
typedef struct
{
	u32 addr;	//配置的地址 
	u8  reserve[9];	//最高位保留
	u8  src_ip[4];	//源IP
	u8  dst_ip[4];	//目的IP
	u16 src_port;	//源端口号
	u16 dst_port;	//目的端口号
	u8  pro_type;	//协议类型
	tsn_tag tsntag;	//查表的结果
} map_table_info;

//重映射表 dmac和outport为查表结果
typedef struct 
{
	u32 addr;	//配置的地址 
	u16 reserve1;	//保留位 
	u16 reserve2:2,	//保留位
		flowID:14;	//flowID，使用flowID进行查表，
	u8  dmac[6];	//目的mac
	u16 reserve3:7,	//保留位
		outport:9; 	//输出端口号
} remap_table_info;


#endif

u8 get_port_type_from_init_cfg(u16 tmp_imac);
u16 *get_cfg_order_from_init_cfg();
u16 get_cfg_num_from_init_cfg();


#endif



