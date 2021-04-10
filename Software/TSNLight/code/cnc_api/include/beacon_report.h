
#ifndef BEACON_REPORT_H
#define BEACON_REPORT_H


typedef char s8;				/**< 有符号的8位（1字节）数据定义*/
typedef unsigned char u8;		/**< 无符号的8位（1字节）数据定义*/
typedef short s16;				/**< 有符号的16位（2字节）数据定义*/
typedef unsigned short u16;	/**< 无符号的16位（2字节）数据定义*/
typedef int s32;				/**< 有符号的32位（4字节）数据定义*/
typedef unsigned int u32;		/**< 无符号的32位（4字节）数据定义*/
typedef long long s64;				/**< 有符号的64位（8字节）数据定义*/
typedef unsigned long long u64;		/**< 无符号的64位（8字节）数据定义*/


//芯片转发表最大数目
#define MAX_CHIP_FLT_REPORT_NUM 256 
//芯片时刻表最大数目
#define CHIP_TS_REPORT_NUM 16
//芯片输出门控表最大数目
#define CHIP_QGC_REPORT_NUM 16


/*芯片上报类型*/
#define CHIP_REG_REPORT 0x0000 //芯片单个寄存器上报
#define CHIP_FLT_REPORT_BASE 0x0400 //第0-63条转发表，后面的转发表依次加1，如第64-127，则为0x0400+1，最大为0x0800+255
#define CHIP_TIS_REPORT_BASE 0x0800 //第0-63条注入时刻表,后面的注入时刻表依次加1，如第64-127，则为0x0800+1，最大为0x0800+15
#define CHIP_TSS_REPORT_BASE 0x0C00 //第0-63条提交时刻表,后面的提交时刻表依次加1，如第64-127，则为0x0C00+1，最大为0x0C00+15
#define CHIP_QGC0_REPORT_BASE 0x1000 //p0端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x1000+1，最大为0x1000+15
#define CHIP_QGC1_REPORT_BASE 0x1400 //p1端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x1400+1，最大为0x1400+15
#define CHIP_QGC2_REPORT_BASE 0x1800 //p2端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x1800+1，最大为0x1800+15
#define CHIP_QGC3_REPORT_BASE 0x1C00 //p3端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x1C00+1，最大为0x1C00+15
#define CHIP_QGC4_REPORT_BASE 0x2000 //p4端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x2000+1，最大为0x2000+15
#define CHIP_QGC5_REPORT_BASE 0x2400 //p5端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x2400+1，最大为0x2400+15
#define CHIP_QGC6_REPORT_BASE 0x2800 //p6端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x2800+1，最大为0x2800+15
#define CHIP_QGC7_REPORT_BASE 0x2C00 //p7端口第0-63条输出门控表,后面的输出门控表依次加1，如第64-127，则为0x2C00+1，最大为0x2C00+15
#define CHIP_STATE_REPORT 0x3000 //芯片状态上报


//HCP上报
#define HCP_REG_STATE_REPORT  0x0  /*单个寄存器上报和状态上报*/
#define HCP_MAP_REPORT		  0x1000  /*映射表上报*/
#define HCP_REMAP_REPORT	  0x2000  /*重映射表上报*/



/*芯片表上报/配置*/
typedef struct
{
	u16 table[64];
}__attribute__((packed))chip_table_info;


/*芯片寄存器上报/配置*/
typedef struct
{
	u64 offset1:17,//ptp时钟偏移值1
		offset2:32,//ptp时钟偏移值2
		reserve:5,//保留位
		cfg_finish:2,//配置完成寄存器
		port_type:8;//端口类型
	u64 slot_len:11, //时间槽长度
		reserve1:2,//保留位
		inj_slot_period:11,//注入时间槽周期
		reserve2:5,//保留位
		sub_slot_period:11,//提交时间槽周期
		qbv_or_qch:1,//调度模式
		reserve3:3,//保留位
		report_period:12,//上报周期
		report_high:8;//上报类型高位

	 	
	u64	report_low:8,//上报类型高位
		offset_period:24,
		reserve7:7,
		rc_regulation_value:9,
		reserve8:7,
		be_regulation_value:9;

		
	u16	reserve9:7,
		umap_regulation_value:9;

	u8	report_enable:1,//上报使能
		reserve6:7;//保留位				
	
/*
	u16 report_low:8,//上报类型低位
		report_enable:1,//上报使能
		reserve6:7;//保留位		
*/

		
}__attribute__((packed))chip_reg_info_standard;


/*芯片寄存器上报/配置*/
typedef struct
{



	u64 data[0];
	u64 port_type:8,//端口类型
		cfg_finish:2,//配置完成寄存器
		reserve:5,//保留位
		offset2:32,//ptp时钟偏移值2
		offset1:17;//ptp时钟偏移值1

	u64 data1[0];
	u64 report_high:8,//上报类型高位
		report_period:12,//上报周期
		reserve3:3,//保留位
		qbv_or_qch:1,//调度模式
		sub_slot_period:11,//提交时间槽周期
		reserve2:5,//保留位
		inj_slot_period:11,//注入时间槽周期
		reserve1:2,//保留位
		slot_len:11;//时间槽长度


	u64 data2[0];
	u64 be_regulation_value:9,//调度模式
		reserve8:7,//提交时间槽周期
		rc_regulation_value:9,//保留位
		reserve7:7,//注入时间槽周期
		offset_period:24,//保留位
		report_low:8;//时间槽长度

	u16 data3[0];
	u16 umap_regulation_value:9,//保留位
		reserve9:7;

	u8	reserve6:7,//上报使能
		report_enable:1;//保留位	


/*
	u8	report_enable:1,//上报使能
		reserve6:7;//保留位	


	u16 data2[0];
	u16 reserve6:7,//保留位
		report_enable:1,//上报使能
		report_low:8;//上报类型低位

*/		
}__attribute__((packed))chip_reg_info;



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
	
	u16 host_in_queue_discard_cnt;  //主机口输入队列丢弃报文数目       

	
	u16 port_tx_cnt[8];  //0-7号网络口发送报文数目

	
	u16 nmac_receive_cnt;  //nmac报文接收数目       
	u16 nmac_report_cnt;  //nmac报文上报数目       
	
}__attribute__((packed))chip_pkt_static_report;


/*芯片上报网络口对应的内部状态机*/
typedef struct
{
	u8 osc_state:2, //OSC的状态机
		prc_state:2,//PRC的状态机
		gmii_read_state:2,//GMII WRITE状态机
		descriptor_send_state:2;//GMII READ状态机
		
	u8 	gmii_fifo_full:1,//输入时钟域切换fifo满信号
		gmii_fifo_empty:1,//输入时钟域切换fifo空信号
		opc_state_p:3,//OPC的状态机
		reserve:3;
	
	u8 	descriptor_extract_state:4,//DSM的状态机
		data_splice_state:2,//DSP的状态机
		input_buf_interface_state:2;//IBI的状态机
}__attribute__((packed))port_state_standard;


/*芯片上报网络口对应的内部状态机*/
typedef struct
{
	u8  descriptor_send_state:2,//GMII READ状态机
		gmii_write_state:2,//GMII WRITE状态机
		prc_state:2,//PRC的状态机
		osc_state:2; //OSC的状态机

	u8  reserve:3,//DEM的状态机
		opc_state_p:3,//输入时钟域切换fifo空信号
		gmii_fifo_empty:1,//输入时钟域切换fifo满信号
		gmii_fifo_full:1;//OPC的状态机

	u8  input_buf_interface_state:2,//IBI的状态机
		data_splice_state:2,//DSP的状态机
		descriptor_extract_state:4;//DSM的状态机
}__attribute__((packed))port_state;



/*芯片模块状态上报*/
typedef struct
{
	u16 ts_inj_underflow_error_cnt;  //TS报文注入下溢错误计数器
	u16 ts_inj_overflow_error_cnt; //TS报文注入上溢错误计数器
	u16 ts_sub_underflow_error_cnt; //TS报文提交下溢错误计数器
	u16 ts_sub_overflow_error_cnt; //TS报文提交上溢错误计数器
	u16 reserve:2, //
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
		reserve1:2;//保留位	
		
	u16 tsm_state:3,//TSM状态机
		bufid_state:2,//BUFID状态机
		pdi_state:3,//PDI状态机
		smm_state:3,//SSM提交调度状态机
		tdm_state:4,//TDM的状态机
		reserve2:1;//保留位	
		
	port_state port[8];//0-7网络口状态机
	
	u16 pkt_write_state:4,//PW的状态机
		pcb_pkt_read_state:4,//PR的状态机
		address_write_state:4,//AW的状态机
		address_read_state:4;//AR的状态机
		
	u16 free_buf_fifo_rdusedw:9,//空闲地址管理fifo的个数
		reserve3:7;//保留位	
}__attribute__((packed))chip_module_status_report_standard;


/*芯片模块状态上报*/
typedef struct
{
	u16 ts_inj_underflow_error_cnt;  //TS报文注入下溢错误计数器
	u16 ts_inj_overflow_error_cnt; //TS报文注入上溢错误计数器
	u16 ts_sub_underflow_error_cnt; //TS报文提交下溢错误计数器
	u16 ts_sub_overflow_error_cnt; //TS报文提交上溢错误计数器

	/*
	u16 state[0];
	u16 tim_state:3,//TIM状态机
		descriptor_state:3,//PDG状态机
		prp_state:2,//PRP状态机
		transmission_state:3,//TRR状态机
		pkt_state:3,//TRW状态机
		reserve:2;//host GMII WRITE状态机

	u16 state1[0];
	u16 reserve1:2,//保留位	
		hoi_state:4,//HOI状态机
		hos_state:2,//HOS状态机
		hrc_state:3,//HRC状态机
		iv_ism_state:3,//ISM注入调度状态机
		tom_state:2;//TOM状态机	
		
	u16 state2[0];		
	u16 reserve2:1,//保留位	
		tdm_state:4,//TDM的状态机
		smm_state:3,//SSM提交调度状态机
		pdi_state:3,//PDI状态机
		bufid_state:2,//BUFID状态机
		tsm_state:3;//TSM状态机	
	*/
	//u16 state[0];
	u8	transmission_state:3,//TRR状态机
		pkt_state:3,//TRW状态机
		reserve:2;//host GMII WRITE状态机

		
	u8 tim_state:3,//TIM状态机
		descriptor_state:3,//PDG状态机
		prp_state:2;//PRP状态机

	
	//u16 state1[0];
	u8	hrc_state:3,//HRC状态机
		iv_ism_state:3,//ISM注入调度状态机
		tom_state:2;//TOM状态机	

	
	u8  reserve1:2,//保留位	
		hoi_state:4,//HOI状态机
		hos_state:2;//HOS状态机

		
	//u16 state2[0];	
	u8	pdi_state:3,//PDI状态机
		bufid_state:2,//BUFID状态机
		tsm_state:3;//TSM状态机

	
	u8 reserve2:1,//保留位	
		tdm_state:4,//TDM的状态机
		smm_state:3;//SSM提交调度状态机





	
	port_state port[8];//0-7网络口状态机
	
	u16 state3[0];
	u16 address_read_state:4,//AR的状态机
		address_write_state:4,//AW的状态机
		pkt_read_state:4,//PR的状态机
		pkt_write_state:4;//PW的状态机
	
	u16 state4[0];
	u16 reserve3:7,//保留位	
		free_buf_fifo_rdusedw:9;//空闲地址管理fifo的个数		
}__attribute__((packed))chip_module_status_report;



//hcp状态结构体
typedef struct
{
	u16 report_type;//上报类型
	u8 port_type;	//端口类型
	u8 hcp_state;	//hcp状态
	u8 reserve1[8];	//保留位
	u16 port_inpkt_cnt;//接口接收报文个数计数器
	u16 port_outpkt_cnt;//接口发送报文个数计数器
	u16 port_rx_asynfifo_overflow_cnt;//端口接收端异步fifo上溢计数器
	u16 port_rx_asynfifo_underflow_cnt;//端口接收端异步fifo下溢计数器
	u16 port_tx_asynfifo_overflow_cnt;//端口发送端到异步fifo上溢计数器
	u16 port_tx_asynfifo_underflow_cnt;//端口发送端异步fifo下溢计数器
	u16 frc_discard_pkt_cnt;//全网处于配置状态时，FRC模块丢弃的非TSMP帧的个数计数器
	u16 pdm_first_node_notip_discard_pkt_cnt;//第一个节点HCP接收到主机发来的非IP报文（被丢弃）个数计数器
	u16 cim_inpkt_cnt;//控制器交互模块接收报文个数计数器
	u16 cim_outpkt_cnt;//控制器交互模块发送报文个数计数器
	u16 lcm_inpkt_cnt;//本地配置管理模块接收报文个数计数器
	u16 srm_outpkt_cnt;//状态上报模块发送报文个数计数器
	u16 cim_extfifo_overflow_cnt;//存储封装/解封装后的帧的fifo上溢计数器
	u16 cim_intfifo_overflow_cnt;//存储HCP状态上报帧的fifo上溢计数器
	u16 fnp_inpkt_cnt;//第一跳处理模块接收报文个数计数器
	u16 fnp_outpkt_cnt;//第一跳处理模块发送报文个数计数器
	u16 fnp_fifo_overflow_cnt;//第一跳处理模块中fifo上溢计数器
	u16 fnp_no_1st_frag_cnt;//第一跳处理模块接收到的被分片帧的第一个分片被丢弃的计数器
	u16 fnp_no_not1st_frag_cnt;//第一跳处理模块接收到的被分片帧的非第一个分片（中间分片或最后一个分片）被丢弃的计数器
	u16 lnp_inpkt_cnt;//最后一跳处理模块接收报文个数计数器
	u16 lnp_outpkt_cnt;//最后一跳处理模块发送报文个数计数器
	u16 lnp_no_notlast_frag_flag_cnt;//最后一跳处理模块接收到的被分片帧的非最后一个分片（第一个分片或中间分片）被丢弃的计数器
	u16 lnp_no_last_frag_flag_cnt;//最后一跳处理模块接收到的被分片帧的最后一个分片被丢弃的计数器
	u16 lnp_fifo_overflow_cnt;//最后一跳处理模块中fifo上溢计数器
	u16 lnp_flow_table_overflow_cnt;//最后一跳处理模块中流表溢出的计数器
}hcp_static;






#endif


