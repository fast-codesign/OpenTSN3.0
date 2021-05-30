#ifndef _STATE_MONITOR_H__
#define _STATE_MONITOR_H__


#include"../cnc_api/include/cnc_api.h"

#include <libxml/xmlmemory.h>  
#include <libxml/parser.h>  

#include<sys/types.h>
#include<dirent.h>
#include<signal.h>

#include"../remote_cfg/remote_cfg.h"



#define MAX_PERIOD   	  1024  /*最大调度周期1024*/
#define MAX_PORT_NUM 	  8  	/*最大端口数量为8*/
#define MAX_NODE_NUM 	  100   /*最大芯片数量为100*/
#define PRECISION 100 
#define REPORT_INTERVAL 1000000		/*1s上报一次*/


enum device_type
{
	CONTROL 	= 0,
	SWITCH 		= 1,
	ENDSTATION  = 2,
};

/*芯片上报网络口对应的内部状态机*/
#if 0
typedef struct
{
	u16 port_rx_cnt; //网络口接收报文数目
	u16 port_discard_cnt; //网络口丢弃报文数目
}__attribute__((packed))port_cnt;


/*芯片报文计数器上报*/
typedef struct
{
	u16 host_rx_cnt;  //主机口接收报文数目
	u16 host_discard_cnt; //主机口丢弃报文数目
	port_cnt rx_discard_cnt[8];//0-7号网络口接收丢弃报文数目
	u16 host_tx_cnt;  //主机口发送报文数目
	u16 port_tx_cnt[8];  //0-7号网络口发送报文数目
}__attribute__((packed))chip_pkt_static_report;


/*芯片上报网络口对应的内部状态机*/
typedef struct
{
	u8 osc_state:2, //OSC的状态机
		prc_state:2,//PRC的状态机
		gmii_write_state:2,//GMII WRITE状态机
		gmii_read_state:2;//GMII READ状态机
	u8 opc_state_p:3,//OPC的状态机
		gmii_fifo_full:1,//输入时钟域切换fifo满信号
		gmii_fifo_empty:1,//输入时钟域切换fifo空信号
		descriptor_extract_state:3;//DEM的状态机
	u8 frame_fragment_state:2,//FFM的状态机
		descriptor_send_state:2,//DSM的状态机
		data_splice_state:2,//DSP的状态机
		input_buf_interface_state:2;//IBI的状态机
}__attribute__((packed))port_state;


/*芯片模块状态上报*/
typedef struct
{
	u16 ts_inj_underflow_error_cnt;  //TS报文注入下溢错误计数器
	u16 ts_inj_overflow_error_cnt; //TS报文注入上溢错误计数器
	u16 ts_sub_underflow_error_cnt; //TS报文提交下溢错误计数器
	u16 ts_sub_overflow_error_cnt; //TS报文提交上溢错误计数器
	u16 host_gmii_write_state:2, //host GMII WRITE状态机
		pkt_state:3,//TRW状态机
		transmission_state:3,//TRR状态机
		prp_state:2,//PRP状态机
		descriptor_state:3,//PDG状态机
		tim_state:3;//TIM状态机
	u16 tom_state:2,//TOM状态机
		iv_ism_state:3,//ISM注入调度状态机
		hrc_state:3,//HRC状态机
		hos_state:2,//HOS状态机
		hoi_state:4,//HOI状态机
		reserve:2;//保留位	
	u16 tsm_state:3,//TSM状态机
		bufid_state:2,//BUFID状态机
		pdi_state:3,//PDI状态机
		smm_state:3,//SSM提交调度状态机
		tdm_state:4,//TDM的状态机
		reserve1:1;//保留位	
	port_state port[8];//0-7网络口状态机
	u16 pkt_write_state:4,//PW的状态机
		pkt_read_state:4,//PR的状态机
		address_write_state:4,//AW的状态机
		address_read_state:4;//AR的状态机
	u16 free_buf_fifo_rdusedw:9,//空闲地址管理fifo的个数
		reserve2:7;//保留位	
}__attribute__((packed))chip_module_status_report;
#endif


typedef struct
{
	chip_pkt_static_report chip_pkt_static;
	chip_module_status_report chip_module_status;
}__attribute__((packed))chip_static;


//从离线规划文本中获取
typedef struct 
{
	u16 time_slot;		//时间槽大小
	u16 slot_period;	//调度周期
	u8 qbv_or_qch;		//模式选择
	u8 gate_state[MAX_PERIOD][MAX_PORT_NUM];//门控状态
} chip_cfg_info;


//芯片状态信息
typedef struct 
{
	u64 offset;
	u8 online;		//是否在线，0表示在线，1表示离线
	u8 timeout;		//超时时间，超过10秒没有接收到，表明该设备离线或者链路出现故障
	chip_static chip_report;
	u64 max_offset;
} chip_state_info;


//每个端口信息数据结构
typedef struct 
{
	u8 valid;		//有效位，1表示端口连接，0表示该端口未连接
	u8 local_port;	//本地端口号
	u8 remote_port;	//远端设备端口号
	u8 remote_device;	//远端设备类型，0表示控制器，1表示交换机，2表示终端
	u16 imac;		//如果是控制器和交换机，则表示设备imac地址，如果是终端，则表示标签号
} port_info;


//节点信息数据结构，以结构体数组的形式存储，数组下标表示imac
typedef struct 
{
	u8 valid;		//该节点是否存在，存在为1，不存在为0
	u16 imac;		//imac地址
	u8 sync_type;	//时钟角色，0表示主，1表示从
	u8 port_type;	//端口类型，bitmap形式，0表示交换口，1表示终端口
	port_info port_state[MAX_PORT_NUM];	
	//结构体数组，表示每个端口的连接信息，下标表示端口号
	chip_state_info state;//节点的状态信息	
	chip_cfg_info 	cfg_info;//离线规划中的配置信息
	hcp_static hcp_info; //HCP状态信息
} hw_info;
//hw_info chip[MAX_NODE_NUM];
//以结构体数组的形式存储，数组下标表示imac，芯片的imac地址大小不能超过100


typedef struct
{
	u16 port_rx;
	u16 port_tx;
	u16 port_discard;
}__attribute__((packed))port_report;



typedef struct
{
	u16 imac;
	u16 node_state;	
	u32 offset; 
	port_report port_state[9];
	
	u16 inject_overflow;
	u16 inject_underflow;		
	
	u16 submit_overflow;
	u16 submit_underflow;	

}__attribute__((packed))state_report;


void state_monitor(u16 pkt_len,const unsigned char *packet_content);

u16 state_monitor_timeout(struct timeval tv);

int state_monitor_init();

u8 get_pkt_type(u8 *pkt,u16 len);

void update_offset(u8 imac,u64 offset);


#endif
