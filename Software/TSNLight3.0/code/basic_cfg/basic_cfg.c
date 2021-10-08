/** *************************************************************************
 *  @file       basic_cfg.c
 *  @brief	    基础配置函数
 *  @date		2021/04/24 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/
#include "basic_cfg.h"




//extern u8 G_STATE = 0;


chip_cfg_table_info chip_cfg_table;//芯片配置的表项信息




//初始配置
int init_cfg_fun(u8 node_idx)
{
	u16 flowid_idx = 0;	
	u32 cfg_data = 0;
	u8 ret = 0;
	
	
	//配置上报使能,开启上报
	cfg_data = 1;
	printf("cfg report enable %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);

	//端口类型，默认为全1
	cfg_data = 255;
	printf("cfg port_type %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);

	//端口类型，默认为全1
	cfg_data = 255;
	printf("cfg port_type %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);

	//配置上报类型默认值，上报单个寄存器	
	cfg_data = CHIP_REG_REPORT;
	printf("cfg port_type report %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&cfg_data);//配置上报类型为单个寄存器上报
	
	//配置qbv_qch默认值，默认选择qch
	cfg_data = 1;
	printf("cfg qch %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_QBV_QCH_ADDR,1,&cfg_data);	

	//配置上报使能,开启上报
	cfg_data = 1;
	printf("cfg report enable %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);


	//配置上报周期默认值，为1ms
	cfg_data = 1;
	printf("cfg report period %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_PERIOD_ADDR,1,(u32 *)&cfg_data);//配置端口类型

	//配置完成寄存器默认值2，可以传输非ST流
	cfg_data = 2;
	printf("cfg finish %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_CFG_FINISH_ADDR,1,(u32 *)&cfg_data);//配置端口类型

	//init_cfg[node_idx].reg_data.port_type = 255;
	init_cfg[node_idx].reg_data.cfg_finish = 2;
	init_cfg[node_idx].reg_data.report_enable = 1;
	init_cfg[node_idx].reg_data.report_period = 1;

	init_cfg[node_idx].reg_data.report_low  = 0;
	init_cfg[node_idx].reg_data.report_high = 0;
	
	//配置所有的单个寄存器
	ret = cfg_chip_single_register(init_cfg[node_idx].imac,init_cfg[node_idx].reg_data);
	

	//如果设置模式为qbv模式，则需要门控全开
	if(init_cfg[node_idx].reg_data.qbv_or_qch == 0)
	{
		//配置默认门控表，BE门控全开
		memset(&chip_cfg_table,255,sizeof(chip_cfg_table));
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC0_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC1_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC2_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC3_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC4_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC5_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC6_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC7_BASE_ADDR,chip_cfg_table);
		
	}


	//配置转发表，每次配置一个，配置多次
	for(flowid_idx=0;flowid_idx<init_cfg[node_idx].forward_table_num;flowid_idx++)
	{
		printf("node_idx %d,init_cfg[node_idx].forward_table_num %d\n",node_idx,init_cfg[node_idx].forward_table_num);
		printf("cfg forward flowID %d,outport %d\n", init_cfg[node_idx].forward_table[flowid_idx].flowid,init_cfg[node_idx].forward_table[flowid_idx].outport);
		cfg_data = init_cfg[node_idx].forward_table[flowid_idx].outport;
		//配置转发表，每次配置一个，配置多次
		build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
								CHIP_FLT_BASE_ADDR + init_cfg[node_idx].forward_table[flowid_idx].flowid,
								1,
								(u32 *)&cfg_data);

	}

	cfg_data = 2;
	printf("cfg hcp state %d\n",cfg_data);	
	//build_send_hcp_cfg_pkt(init_cfg[node_idx].imac,HCP_STATE_ADDR,(u32 *)&cfg_data,1);

	cfg_data = init_cfg[node_idx].reg_data.port_type;	
	printf("cfg hcp port_type %d\n",cfg_data);	
	//build_send_hcp_cfg_pkt(init_cfg[node_idx].imac,HCP_PORT_TYPE_ADDR,(u32 *)&cfg_data,1);
	//初始配置结束

	printf("1111111111111111111111111111111111111111111111111\n");

	return 0;
}


u16 get_imac_from_tsntag(u8 *tsntag)
{
	u16 temp_imac = 0;
	u8 temp_data = 0;
	temp_data = *(tsntag+2);
	temp_imac = temp_data >> 7;
	
	temp_data = *(tsntag+1);
	temp_imac += temp_data * 2;
	
	temp_data = *tsntag;
	temp_imac += (temp_data&0x1f)  * 512;

	return temp_imac;
}

u8 node_idx = 0;//节点的索引值
u8 local_cfg_flag = 1;

int basic_cfg(u8 *pkt,u16 pkt_len)
{
	int ret = 0;
	u16 imac = 0;//节点的imac地址
	chip_reg_info *temp_reg = NULL;//节点上报的单个寄存器	

	u8 *temp_pkt = NULL;//

	u16 flowid_idx = 0;

	u32 cfg_data = 0;

	//首先判断是否接收到与控制器直连节点的上报报文
	if(*(pkt+12)==0xff && *(pkt+13)==0x01) 
	{
		printf("get report pkt\n");
		imac = get_imac_from_tsntag(pkt+6);
		printf("*(pkt+8) %d\n",*(pkt+8));
		//判断上报的节点类型
		if(imac == init_cfg[node_idx].imac)
		{
			printf("get imac = %d report\n",imac);
			temp_pkt = pkt+16;//偏移到数据域，16字节TSMP头
			host_to_net_single_reg(temp_pkt);//网络序转主机序函数
			
			//强制转换
			temp_reg = (chip_reg_info *)temp_pkt;
			//打印上报单个寄存器的内容
			printf_single_reg(temp_reg);
		}
		else
		{
			printf("report pkt imac error imac=%d\n",imac);
			printf("cfg pkt imac =%d\n",init_cfg[node_idx].imac);

			return 0;
		}
		
		//判断上报内容是否正确
		if(init_cfg[node_idx].reg_data.slot_len == temp_reg->slot_len && init_cfg[node_idx].reg_data.cfg_finish == temp_reg->cfg_finish)
		{
			printf("slot_len cfg_finish cfg success\n");
			
			//最后配置关闭该节点的上报功能
			cfg_data = 0;
			printf("cfg  report enable %d\n",cfg_data);	
			build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
								CHIP_REPORT_EN_ADDR,
								1,
								(u32 *)&cfg_data);

			//最后配置端口类型，开始端口类型为全1，配置完该节点后，接收配置的报文的端口需要配置为0
			cfg_data = init_cfg[node_idx].reg_data.port_type;
			printf("cfg  port_type %d\n",cfg_data); 
			build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
								CHIP_PORT_TYPE_ADDR,
								1,
								(u32 *)&cfg_data);
			
			printf("888888888888888888888888888888888888888888888888888888888888888888888888888888cur_node_num %d\n",cur_node_num);
			//配置结束
			if(node_idx >= (cur_node_num-2))//last  is nic 
			{

								//配置上报使能,开启上报
				cfg_data = init_cfg[node_idx+1].reg_data.slot_len;
				printf("cfg slot len %d\n",init_cfg[node_idx+1].reg_data.slot_len);
				build_send_chip_cfg_pkt(init_cfg[node_idx+1].imac,CHIP_TIME_SLOT_ADDR,1,(u32 *)&cfg_data);

				//端口类型，默认为全1
				cfg_data = init_cfg[node_idx+1].reg_data.inj_slot_period;
				printf("cfg inj_slot_period %d\n",cfg_data);
				build_send_chip_cfg_pkt(init_cfg[node_idx+1].imac,CHIP_INJECT_SLOT_PERIOD_ADDR,1,(u32 *)&cfg_data);


				//配置结束，跳转状态
				printf("basic cfg end\n");
				if(local_cfg_flag == 1)
					G_STATE = LOCAL_PLAN_CFG_S;
				else
					G_STATE = REMOTE_PLAN_CFG_S;
				
			}
			else//配置未结束，配置下一个节点
			{
				printf("cfg next node\n");
				node_idx++;
				init_cfg_fun(node_idx);
			}

		}
		else
		{
			printf("report pkt data error\n");
			return 0;
		}
		
	}
	else
	{
		printf("report pkt type error\n");
		
	}
		
		
}
		
