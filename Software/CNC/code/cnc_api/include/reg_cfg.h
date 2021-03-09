
#ifndef REG_CFG_H
#define REG_CFG_H


#include "tsmp_protocol.h"


#define CTL_IMAC   0x0  /*控制器的imac地址*/


//芯片配置
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






//HCP配置
//#define HCP_MAP_BASE_ADDR     0x82000000  /*HCP第一跳映射表基地址，最高位表示有效位，默认有效*/
//#define HCP_REMAP_BASE_ADDR	  0x83000000  /*HCP最后一跳重映射表基地址，最高位表示有效位，默认有效，低14bit表示flowID，硬件根据低14bit进行索引*/

#define HCP_MAP_BASE_ADDR     0x00d00000  /*HCP第一跳映射表基地址，最高位表示有效位，默认有效*/
#define HCP_REMAP_BASE_ADDR	  0x00e00000  /*HCP最后一跳重映射表基地址，最高位表示有效位，默认有效，低14bit表示flowID，硬件根据低14bit进行索引*/


#define HCP_PORT_TYPE_ADDR    0x80000000  /*HCP的端口类型地址，最高位表示有效位，默认有效*/
#define HCP_REPORT_TYPE_ADDR  0x81000001  /*HCP的上报类型寄存器*/
#define HCP_STATE_ADDR  	  0x81000000  /*HCP的状态寄存器*/


#define DATA_OFFSET 16//芯片上报报文偏移该值获取上报数据域




//芯片上报和配置单个寄存器在beacon_report中定义


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


//TSNtag定义在tsmp_protocol.h中定义
//tsn_tag_standard    tsn_tag


/*NMAC配置报文*/
typedef struct
{
	tsn_tag dst_tsn_tag;
	tsn_tag src_tsn_tag;
	u16 type;
	u8 count;
	u8 cfg_type;
	u32 addr;
	u32 data[0];
}__attribute__((packed))nmac_pkt;




//hcp映射表
typedef struct
{
	u32 addr;	//配置的地址 
	u8  reserve[9];	//最高位保留
	
	u8  pro_type;	//协议类型
	
	u8  src_ip[4];	//源IP
	u8  dst_ip[4];	//目的IP
	u16 src_port;	//源端口号
	u16 dst_port;	//目的端口号
	
	tsn_tag tsntag;	//查表的结果
} __attribute__((packed))map_table_info;


//重映射表标准 
typedef struct 
{
	u32 addr;	//配置的地址 
	u16 reserve1;	//保留位
	u16 ctl[0];
	u16 reserve2:2,	//保留位
		flowID:14;	//flowID，使用flowID进行查表，
	u8  dmac[6];	//目的mac
	u16 ctl1[0];
	u16 reserve3:7,	//保留位
		outport:9; 	//输出端口号
} __attribute__((packed))remap_table_info_standard;

//重映射表 dmac和outport为查表结果
typedef struct 
{
	u32 addr;	//配置的地址 
	u16 reserve1;	//保留位
	u16 ctl[0];
	u16 flowID:14,	//flowID，使用flowID进行查表，
		reserve2:2;	//保留位		
	u8  dmac[6];	//目的mac
	u16 ctl1[0];
	u16 outport:9, 	//输出端口号
		reserve3:7;	//保留位
		
} __attribute__((packed))remap_table_info;


#endif


