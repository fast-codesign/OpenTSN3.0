/** *************************************************************************
 *  @file       basic_cfg.c
 *  @brief	    基础配置函数
 *  @date		2021/04/24 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/
#include "remote_cfg.h"

u8 cfg_varify_flag = 0;



//chip_cfg_table_info chip_cfg_table;//芯片配置的表项信息



chip_reg_info remote_reg_info;//寄存器信息
chip_cfg_table_info remote_forward_info;//远程配置的转发表项信息
chip_cfg_table_info remote_gate_info[8];//远程配置的门控表项信息
chip_cfg_table_info remote_inject_info;//远程配置的注入表项信息
chip_cfg_table_info remote_submit_info;//远程配置的提交表项信息

map_table_info    remote_map_table[32];//hcp映射表
remap_table_info  remote_remap_table[256];//hcp重映射表


u16 g_inject_idx = 0;
u16 g_submit_idx = 0;
u16 g_map_idx = 0;
u16 g_remap_idx = 0;



//判断报文类型
int get_remote_pkt_type(u8 *pkt)
{
	
	if(*(pkt+6)  == 0x60 && 
	   *(pkt+7)  == 0x00 && 
	   *(pkt+34) == 0x1f && 
	   *(pkt+35) == 0x90 &&
	   *(pkt+36) == 0x1f && 
	   *(pkt+37) == 0x90)
		return 0;
	else
		return -1;
	
}

int parse_remap_info(u8 *pkt,u16 len)
{
	u16 remap_idx = 0;
	u16 remap_num = 0;
	
	u8 *remap_info = NULL;
	u8 remap_id = 0;
		
	remap_info = pkt + 7;//偏移到数据字段
	remap_num = len/11;//11个字节一个映射表
	


	for(remap_idx=0;remap_idx<remap_num;remap_idx++)
	{
		remap_id = *remap_info;
		remote_remap_table[remap_id].flowID = (*(remap_info+1)) * 256 + (*(remap_info+2));
		
		remote_remap_table[remap_id].dmac[0] = *(remap_info+3);
		remote_remap_table[remap_id].dmac[1] = *(remap_info+4);
		remote_remap_table[remap_id].dmac[2] = *(remap_info+5);
		remote_remap_table[remap_id].dmac[3] = *(remap_info+6);	
		remote_remap_table[remap_id].dmac[4] = *(remap_info+7);
		remote_remap_table[remap_id].dmac[5] = *(remap_info+8);
			
		remote_remap_table[remap_id].outport = (*(remap_info+9)) * 256 + (*(remap_info+10));

		printf("flowid %d\n",remote_remap_table[remap_id].flowID);
		printf("dmac %d:%d:%d:%d:%d:%d\n",
							 remote_remap_table[remap_id].dmac[0],
							 remote_remap_table[remap_id].dmac[1],
							 remote_remap_table[remap_id].dmac[2],
							 remote_remap_table[remap_id].dmac[3],
                             remote_remap_table[remap_id].dmac[4],
                             remote_remap_table[remap_id].dmac[5]);
		printf("outport %d\n",remote_remap_table[remap_id].outport);



		//g_remap_idx++;
		remap_info = remap_info+11;	//11个字节一个重映射表	
	}
	return 0;
		
}


int dynamic_parse_remap_info(u8 *pkt,u16 len,u16 imac)
{
	printf("dynamic_parse_remap_info\n");

	u16 remap_idx = 0;
	u16 remap_num = 0;
	
	u8 *remap_info = NULL;
	u8 remap_id = 0;
		
	remap_info = pkt + 7;//偏移到数据字段
	remap_num = len/11;//11个字节一个映射表
	
	remap_table_info temp_remote_remap_table;


	for(remap_idx=0;remap_idx<remap_num;remap_idx++)
	{
		remap_id = *remap_info;
		temp_remote_remap_table.flowID = (*(remap_info+1)) * 256 + (*(remap_info+2));
		
		temp_remote_remap_table.dmac[0] = *(remap_info+3);
		temp_remote_remap_table.dmac[1] = *(remap_info+4);
		temp_remote_remap_table.dmac[2] = *(remap_info+5);
		temp_remote_remap_table.dmac[3] = *(remap_info+6);	
		temp_remote_remap_table.dmac[4] = *(remap_info+7);
		temp_remote_remap_table.dmac[5] = *(remap_info+8);
			
		temp_remote_remap_table.outport = (*(remap_info+9)) * 256 + (*(remap_info+10));

		printf("flowid %d\n",temp_remote_remap_table.flowID);
		printf("dmac %d:%d:%d:%d:%d:%d\n",
							 temp_remote_remap_table.dmac[0],
							 temp_remote_remap_table.dmac[1],
							 temp_remote_remap_table.dmac[2],
							 temp_remote_remap_table.dmac[3],
                             temp_remote_remap_table.dmac[4],
                             temp_remote_remap_table.dmac[5]);
		printf("outport %d\n",temp_remote_remap_table.outport);

		build_send_hcp_cfg_pkt(imac,HCP_REMAP_BASE_ADDR+remap_id,(u32 *)&temp_remote_remap_table,1);


		//g_remap_idx++;
		remap_info = remap_info+11;	//11个字节一个重映射表	
	}



	return 0;
		
}

int parse_map_info(u8 *pkt,u16 len)
{
	u16 map_idx = 0;
	u16 map_num = 0;

	u8 map_id = 0;
	
	u8 *map_info = NULL;

		
	map_info = pkt + 7;//偏移到数据字段
	map_num = len/21;//21个字节一个映射表
	


	for(map_idx=0;map_idx<map_num;map_idx++)
	{
		map_id = *map_info;
		remote_map_table[map_id].src_ip[0] = *(map_info+1);
		remote_map_table[map_id].src_ip[1] = *(map_info+2);
		remote_map_table[map_id].src_ip[2] = *(map_info+3);
		remote_map_table[map_id].src_ip[3] = *(map_info+4);
		
		remote_map_table[map_id].dst_ip[0] = *(map_info+5);
		remote_map_table[map_id].dst_ip[1] = *(map_info+6);
		remote_map_table[map_id].dst_ip[2] = *(map_info+7);
		remote_map_table[map_id].dst_ip[3] = *(map_info+8);	

		remote_map_table[map_id].src_port = (*(map_info+9)) * 256 + (*(map_info+10));
		remote_map_table[map_id].dst_port = (*(map_info+11)) * 256 + (*(map_info+12));
		remote_map_table[map_id].pro_type = *(map_info+13);
		
		remote_map_table[map_id].tsntag.flow_type   = *(map_info+14);
		remote_map_table[map_id].tsntag.flow_id     = (*(map_info+15)) * 256 + (*(map_info+16));
		remote_map_table[map_id].tsntag.inject_addr = (*(map_info+17)) * 256 + (*(map_info+18));
		remote_map_table[map_id].tsntag.submit_addr = (*(map_info+19)) * 256 + (*(map_info+20));
		
		printf("src_ip %d:%d:%d:%d\n",remote_map_table[map_id].src_ip[0],
							 remote_map_table[map_id].src_ip[1],
							 remote_map_table[map_id].src_ip[2],
							 remote_map_table[map_id].src_ip[3]);
		printf("src_port=%d,dst_port=%d,pro_type=%d\n",remote_map_table[map_id].src_port,
					remote_map_table[map_id].dst_port,
					remote_map_table[map_id].pro_type);
		printf("flow_type=%d,flow_id=%d,inject_addr=%d,inject_addr=%d\n",
					remote_map_table[map_id].tsntag.flow_type,
					remote_map_table[map_id].tsntag.flow_id,
					remote_map_table[map_id].tsntag.inject_addr,
					remote_map_table[map_id].tsntag.submit_addr);					
					
		//g_map_idx++;
		map_info = map_info+21;	//20个字节一个映射表	
	}
	return 0;
		
}



int dynamic_parse_map_info(u8 *pkt,u16 len,u16 imac)
{
	printf("dynamic_parse_map_info\n");
	
	u16 map_idx = 0;
	u16 map_num = 0;

	u8 map_id = 0;
	
	u8 *map_info = NULL;

		
	map_info = pkt + 7;//偏移到数据字段
	map_num = len/21;//21个字节一个映射表
	
	map_table_info temp_remote_map_table;


	for(map_idx=0;map_idx<map_num;map_idx++)
	{
		map_id = *map_info;
		temp_remote_map_table.src_ip[0] = *(map_info+1);
		temp_remote_map_table.src_ip[1] = *(map_info+2);
		temp_remote_map_table.src_ip[2] = *(map_info+3);
		temp_remote_map_table.src_ip[3] = *(map_info+4);
		
		temp_remote_map_table.dst_ip[0] = *(map_info+5);
		temp_remote_map_table.dst_ip[1] = *(map_info+6);
		temp_remote_map_table.dst_ip[2] = *(map_info+7);
		temp_remote_map_table.dst_ip[3] = *(map_info+8);	

		temp_remote_map_table.src_port = (*(map_info+9)) * 256 + (*(map_info+10));
		temp_remote_map_table.dst_port = (*(map_info+11)) * 256 + (*(map_info+12));
		temp_remote_map_table.pro_type = *(map_info+13);
		
		temp_remote_map_table.tsntag.flow_type   = *(map_info+14);
		temp_remote_map_table.tsntag.flow_id     = (*(map_info+15)) * 256 + (*(map_info+16));
		temp_remote_map_table.tsntag.inject_addr = (*(map_info+17)) * 256 + (*(map_info+18));
		temp_remote_map_table.tsntag.submit_addr = (*(map_info+19)) * 256 + (*(map_info+20));
		
		printf("src_ip %d:%d:%d:%d\n",temp_remote_map_table.src_ip[0],
							 temp_remote_map_table.src_ip[1],
							 temp_remote_map_table.src_ip[2],
							 temp_remote_map_table.src_ip[3]);
		printf("src_port=%d,dst_port=%d,pro_type=%d\n",temp_remote_map_table.src_port,
					temp_remote_map_table.dst_port,
					temp_remote_map_table.pro_type);
		printf("flow_type=%d,flow_id=%d,inject_addr=%d,inject_addr=%d\n",
					temp_remote_map_table.tsntag.flow_type,
					temp_remote_map_table.tsntag.flow_id,
					temp_remote_map_table.tsntag.inject_addr,
					temp_remote_map_table.tsntag.submit_addr);					
		build_send_hcp_cfg_pkt(imac,HCP_MAP_BASE_ADDR+map_id,(u32 *)&temp_remote_map_table,1);			
		//g_map_idx++;
		map_info = map_info+21;	//20个字节一个映射表	
	}	
	

	return 0;
}

int parse_submit_info(u8 *pkt,u16 len)
{
	u16 submit_idx = 0;
	u16 submit_num = 0;
	
	u16 *submit_info = NULL;


	submit_info = (u16 *)(pkt + 7);//偏移到数据字段
	submit_num = len/6;
	


	for(submit_idx=0;submit_idx<submit_num;submit_idx++)
	{
		remote_submit_info.table[htons(*submit_info)] = htons(*(submit_info+1)) | (htons(*(submit_info+2)))<<5;
		remote_submit_info.table[htons(*submit_info)] = remote_submit_info.table[htons(*submit_info)] | 0x8000;
		
		printf("time_slot %d,addr %d\n",htons(*(submit_info+1)),htons(*(submit_info+2)));
		printf("table_data %d\n",remote_submit_info.table[htons(*submit_info)]);

		submit_info = submit_info+3;	
		//g_submit_idx++;
	}
	return 0;
	
}

int dynamic_parse_submit_info(u8 *pkt,u16 len,u16 imac)
{
	u16 submit_idx = 0;
	u16 submit_num = 0;
	
	u16 *submit_info = NULL;

	u32 tmp_submit_data = 0;

	submit_info = (u16 *)(pkt + 7);//偏移到数据字段
	submit_num = len/6;
	


	for(submit_idx=0;submit_idx<submit_num;submit_idx++)
	{
		printf("dynamic_parse_submit_info \n");
		
		//每次解析一个时刻表，配置一个时刻表
		tmp_submit_data = htons(*(submit_info+1)) | (htons(*(submit_info+2)))<<5;
		tmp_submit_data = tmp_submit_data | 0x8000;
		
		build_send_chip_cfg_pkt(imac,CHIP_TSS_BASE_ADDR + htons(*submit_info),1,(u32 *)&tmp_submit_data);
		printf("time_slot %d,addr %d\n",htons(*(submit_info+1)),htons(*(submit_info+2)));
		submit_info = submit_info+3;

	}
	return 0;
	
}



int parse_inject_info(u8 *pkt,u16 len)
{
	u16 inject_idx = 0;
	u16 inject_num = 0;
	
	u16 *inject_info = NULL;


	inject_info = (u16 *)(pkt + 7);//偏移到数据字段
	inject_num = len/6;
	


	for(inject_idx=0;inject_idx<inject_num;inject_idx++)
	{
		//修改g_inject_idx为元层配置下来的序列号
		remote_inject_info.table[htons(*inject_info)] = htons(*(inject_info+1)) | (htons(*(inject_info+2)))<<5;
		remote_inject_info.table[htons(*inject_info)] = remote_inject_info.table[htons(*inject_info)] | 0x8000;
		printf("time_slot %d,addr %d\n",htons(*(inject_info+1)),htons(*(inject_info+2)));
		printf("table_data %d\n",remote_inject_info.table[htons(*inject_info)]);

		inject_info = inject_info+3;	
		//g_inject_idx++;
	}
	return 0;
	
}



int dynamic_parse_inject_info(u8 *pkt,u16 len,u16 imac)
{
	u16 inject_idx = 0;
	u16 inject_num = 0;
	
	u16 *inject_info = NULL;


	inject_info = (u16 *)(pkt + 7);//偏移到数据字段
	inject_num = len/6;
	
	u32 tmp_inject_data = 0;

	for(inject_idx=0;inject_idx<inject_num;inject_idx++)
	{
		printf("dynamic_parse_inject_info\n");
		//每次解析一个时刻表，配置一个时刻表
		tmp_inject_data = htons(*(inject_info+1)) | (htons(*(inject_info+2)))<<5;
		tmp_inject_data = tmp_inject_data | 0x8000;
		
		build_send_chip_cfg_pkt(imac,CHIP_TIS_BASE_ADDR + htons(*inject_info),1,(u32 *)&tmp_inject_data);
		printf("time_slot %d,addr %d\n",htons(*(inject_info+1)),htons(*(inject_info+2)));
		inject_info = inject_info+3;

	}
	return 0;
	
}



int parse_gate_info(u8 *pkt,u8 port_id,u16 len)
{
	u16 gate_idx = 0;
	u16 gate_num = 0;
	
	u16 *gate_info = NULL;

		
	gate_info = (u16 *)(pkt + 7);//偏移到数据字段
	gate_num = len/4;
	


	for(gate_idx=0;gate_idx<gate_num;gate_idx++)
	{
		remote_gate_info[port_id].table[htons(*gate_info)] = htons(*(gate_info+1));
		printf("time_slot %d,gate_state %d\n",htons(*gate_info),htons(*(gate_info+1)));
		gate_info = gate_info+2;	
	}
	return 0;
	
}

int dynamic_parse_gate_info(u8 *pkt,u32 addr,u16 len,u16 imac)
{
	u16 gate_idx = 0;
	u16 gate_num = 0;
	
	u16 *gate_info = NULL;

		
	gate_info = (u16 *)(pkt + 7);//偏移到数据字段
	gate_num = len/4;
	


	for(gate_idx=0;gate_idx<gate_num;gate_idx++)
	{
		//每次解析一个门控，配置一个门控
		build_send_chip_cfg_pkt(imac,addr + htons(*gate_info),1,(u32 *)(gate_info+1));
		printf("time_slot %d,gate_state %d\n",htons(*gate_info),htons(*(gate_info+1)));
		gate_info = gate_info+2;	
	}
	return 0;
	
}



u8 remote_first_cfg_flag = 1;

int parse_forward_info(u8 *pkt,u16 len,u16 imac)
{
	u16 forward_idx = 0;
	u16 forward_num = 0;
	
	u16 *forward_info = NULL;
	
	
	u16 temp_flowid = 0;
	u16 node_idx = 0;
		
	forward_info = (u16 *)(pkt + 7);//偏移到数据字段
	forward_num = len/4;
	
	
	
	if(remote_first_cfg_flag == 1)
	{
		//初始转发表，即需要把基础配置时配置的转发表也初始到这远程配置
		for(node_idx=0;node_idx<cur_node_num;node_idx++)
		{
			printf("init_cfg[node_idx].imac %d,imac %d\n",init_cfg[node_idx].imac,imac);
			//如果初始配置节点的imac与当前配置节点的imac相同
			if(init_cfg[node_idx].imac == imac)
			{
				//查找该节点的初始配置转发表，并赋值到本地配置
				for(forward_idx=0;forward_idx<init_cfg[node_idx].forward_table_num;forward_idx++)
				{
					printf("2222\n");
					temp_flowid = init_cfg[node_idx].forward_table[forward_idx].flowid;
					remote_forward_info.table[temp_flowid] = init_cfg[node_idx].forward_table[forward_idx].outport;				
					printf("temp_flowid = %d,outport = %d\n",temp_flowid,remote_forward_info.table[temp_flowid]);

				}
			}
			
		}	
		remote_first_cfg_flag = 0;
	}
	for(forward_idx=0;forward_idx<forward_num;forward_idx++)
	{
		remote_forward_info.table[htons(*forward_info)] = htons(*(forward_info+1));		
		printf("flowID %d,outport %d\n",htons(*forward_info),htons(*(forward_info+1)));
		forward_info = forward_info+2;		
	}
	
	return 0;
	
}

int dynamic_parse_forward_info(u8 *pkt,u16 len,u16 imac)
{
	u16 forward_idx = 0;
	u16 forward_num = 0;
	
	u16 *forward_info = NULL;
	
	
	u16 temp_flowid = 0;
	u16 node_idx = 0;
		
	forward_info = (u16 *)(pkt + 7);//偏移到数据字段
	forward_num = len/4;
	
	
	for(forward_idx=0;forward_idx<forward_num;forward_idx++)
	{

		build_send_chip_cfg_pkt(imac,CHIP_FLT_BASE_ADDR + htons(*forward_info),1,(u32 *)(forward_info+1));
		printf("flowID %d,outport %d\n",htons(*forward_info),htons(*(forward_info+1)));
		forward_info = forward_info+2;		
	}
	
	return 0;
	
}

int parse_reg_info(u16 imac,u8 *pkt,u16 len)
{
	printf("start parse_reg_info\n");
	u16 reg_idx = 0;
	u16 reg_num = 0;
	
	u16 *reg_info = NULL;
	
		
	reg_info = (u16 *)(pkt + 7);//偏移到数据字段
	reg_num = len/4;
	
	u32 cfg_data = 0;


	for(reg_idx=0;reg_idx<reg_num;reg_idx++)
	{
		printf("htons(*reg_info) %d\n",htons(*reg_info));
		//每次接收到的单个寄存器的配置信息后，每接收一个配置一个
		switch(htons(*reg_info))
		{
			case CHIP_TIME_SLOT_ADDR         :remote_reg_info.slot_len        = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.slot_len;
											  build_send_chip_cfg_pkt(imac,CHIP_TIME_SLOT_ADDR,1,(u32 *)&cfg_data);			
											  break;
			case CHIP_PORT_TYPE_ADDR         :remote_reg_info.port_type       = htons(*(reg_info+1));
										 	  cfg_data = remote_reg_info.port_type;
											  build_send_chip_cfg_pkt(imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);		  
											  break;
			case CHIP_QBV_QCH_ADDR           :remote_reg_info.qbv_or_qch      = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.qbv_or_qch;
											  build_send_chip_cfg_pkt(imac,CHIP_QBV_QCH_ADDR,1,(u32 *)&cfg_data);		
											  break;
			case CHIP_REPORT_TYPE_ADDR       :remote_reg_info.report_low      = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.report_low;
											  build_send_chip_cfg_pkt(imac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_INJECT_SLOT_PERIOD_ADDR:remote_reg_info.inj_slot_period = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.inj_slot_period;
											  build_send_chip_cfg_pkt(imac,CHIP_INJECT_SLOT_PERIOD_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_SUBMIT_SLOT_PERIOD_ADDR:remote_reg_info.sub_slot_period = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.sub_slot_period;
											  build_send_chip_cfg_pkt(imac,CHIP_SUBMIT_SLOT_PERIOD_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_REPORT_PERIOD_ADDR     :remote_reg_info.report_period   = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.report_period;
											  build_send_chip_cfg_pkt(imac,CHIP_REPORT_PERIOD_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_OFFSET_PERIOD_ADDR     :{remote_reg_info.rc_regulation_value   = htons(*(reg_info+1));
  											   cfg_data = remote_reg_info.rc_regulation_value;
  											   build_send_chip_cfg_pkt(imac,CHIP_RC_REGULATION_ADDR,1,(u32 *)&cfg_data);
			
											   remote_reg_info.be_regulation_value   = htons(*(reg_info+1))+100;
											   cfg_data = remote_reg_info.be_regulation_value;
											   build_send_chip_cfg_pkt(imac,CHIP_BE_REGULATION_ADDR,1,(u32 *)&cfg_data);
											   
											   remote_reg_info.umap_regulation_value = htons(*(reg_info+1));
											   cfg_data = remote_reg_info.umap_regulation_value;
											   build_send_chip_cfg_pkt(imac,CHIP_UNMAP_REGULATION_ADDR,1,(u32 *)&cfg_data);	  
											   break;
											  }
		}
		printf("reg_type %d,reg_data %d\n",htons(*reg_info),htons(*(reg_info+1)));
		reg_info = reg_info+2;
		
	}
	return 0;
}

int dynamic_parse_reg_info(u8 *pkt,u16 len,u16 imac)
{
	printf("start parse_reg_info\n");
	u16 reg_idx = 0;
	u16 reg_num = 0;
	
	u16 *reg_info = NULL;
	
	u32 cfg_data = 0;
		
	reg_info = (u16 *)(pkt + 7);//偏移到数据字段
	reg_num = len/4;
	

	for(reg_idx=0;reg_idx<reg_num;reg_idx++)
	{
		printf("htons(*reg_info) %d\n",htons(*reg_info));
		
		//每次接收到的单个寄存器的配置信息后，每接收一个配置一个
		switch(htons(*reg_info))
		{
			case CHIP_TIME_SLOT_ADDR         :remote_reg_info.slot_len        = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.slot_len;
											  build_send_chip_cfg_pkt(imac,CHIP_TIME_SLOT_ADDR,1,(u32 *)&cfg_data);			
											  break;
			case CHIP_PORT_TYPE_ADDR         :remote_reg_info.port_type       = htons(*(reg_info+1));
										 	  cfg_data = remote_reg_info.port_type;
											  build_send_chip_cfg_pkt(imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);		  
											  break;
			case CHIP_QBV_QCH_ADDR           :remote_reg_info.qbv_or_qch      = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.qbv_or_qch;
											  build_send_chip_cfg_pkt(imac,CHIP_QBV_QCH_ADDR,1,(u32 *)&cfg_data);		
											  break;
			case CHIP_REPORT_TYPE_ADDR       :remote_reg_info.report_low      = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.report_low;
											  build_send_chip_cfg_pkt(imac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_INJECT_SLOT_PERIOD_ADDR:remote_reg_info.inj_slot_period = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.inj_slot_period;
											  build_send_chip_cfg_pkt(imac,CHIP_INJECT_SLOT_PERIOD_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_SUBMIT_SLOT_PERIOD_ADDR:remote_reg_info.sub_slot_period = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.sub_slot_period;
											  build_send_chip_cfg_pkt(imac,CHIP_SUBMIT_SLOT_PERIOD_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_REPORT_PERIOD_ADDR     :remote_reg_info.report_period   = htons(*(reg_info+1));
											  cfg_data = remote_reg_info.report_period;
											  build_send_chip_cfg_pkt(imac,CHIP_REPORT_PERIOD_ADDR,1,(u32 *)&cfg_data);	  
											  break;
			case CHIP_OFFSET_PERIOD_ADDR     :{remote_reg_info.rc_regulation_value   = htons(*(reg_info+1));
  											   cfg_data = remote_reg_info.rc_regulation_value;
  											   build_send_chip_cfg_pkt(imac,CHIP_RC_REGULATION_ADDR,1,(u32 *)&cfg_data);
			
											   remote_reg_info.be_regulation_value   = htons(*(reg_info+1))+100;
											   cfg_data = remote_reg_info.be_regulation_value;
											   build_send_chip_cfg_pkt(imac,CHIP_BE_REGULATION_ADDR,1,(u32 *)&cfg_data);
											   
											   remote_reg_info.umap_regulation_value = htons(*(reg_info+1));
											   cfg_data = remote_reg_info.umap_regulation_value;
											   build_send_chip_cfg_pkt(imac,CHIP_UNMAP_REGULATION_ADDR,1,(u32 *)&cfg_data);	  
											   break;
											  }
		}

		printf("reg_type %d,reg_data %d\n",htons(*reg_info),htons(*(reg_info+1)));
		reg_info = reg_info+2;
		
	}
	return 0;
}

u8 *build_rcp_pkt(u16 len)
{
	tsn_rcp_pkt *pkt = NULL;
	pkt = (tsn_rcp_pkt *)malloc(len+1);
	bzero(pkt,len+1);
	return (u8 *)pkt;
}


int send_remote_confirm(u8 type,u16 len,u8 tail_flag,u16 imac,u8 *data)
{
	int num_idx = 0;
	tsn_rcp_pkt *tsn_rcp = NULL;
	//nmac_pkt *nmac_tsn_tag = NULL;
	
	tsn_rcp = (tsn_rcp_pkt *)build_rcp_pkt(len+42+7);

	if(tsn_rcp == NULL)
		return -1;
	
	
	tsn_rcp->dst_mac[0] = 0x60;
	tsn_rcp->dst_mac[1] = 0x00;
	tsn_rcp->dst_mac[2] = 0x80;
	tsn_rcp->dst_mac[3] = 0x00;
	tsn_rcp->dst_mac[4] = 0x00;
	tsn_rcp->dst_mac[5] = 0x00;

	tsn_rcp->src_mac[0] = 0x60;
	tsn_rcp->src_mac[1] = 0x00;
	tsn_rcp->src_mac[2] = 0x00;
	tsn_rcp->src_mac[3] = 0x00;
	tsn_rcp->src_mac[4] = 0x00;
	tsn_rcp->src_mac[5] = 0x00;
	
	tsn_rcp->pro_type = 0x0800;
	
	tsn_rcp->udp_type = 0x11;
	
	tsn_rcp->src_port = 0x8080;
	tsn_rcp->dst_port = 0x8080;
	tsn_rcp->len 	  = 40;

	tsn_rcp->tsn_rpc.version = 0x00;
	tsn_rcp->tsn_rpc.type = type;	
	tsn_rcp->tsn_rpc.len = ntohs(len);
	tsn_rcp->tsn_rpc.tail_flag = tail_flag;
	tsn_rcp->tsn_rpc.imac = ntohs(imac);
	
	memcpy(tsn_rcp->data,data,len);
	//tsn_rcp->data = data;
	printf("send confirm pkt\n");
	remote_data_pkt_send_handle((u8 *)tsn_rcp,len+42+7);
	free((u8 *)tsn_rcp);
	return 0;
	
}

u8 send_init_cfg_flag = 1;

int remote_cfg(u8 *pkt,u16 pkt_len)
{
	if(pkt[0] == 0x60)
{
	cnc_pkt_print(pkt,pkt_len);

	report_confirm  report_confirm_data;

	if(send_init_cfg_flag == 1)
	{
		printf("send init cfg report\n");
		report_confirm_data.report_type = 0;//初始配置上报
		report_confirm_data.cfg_state   = 1;//离线规划配置成功
		report_confirm_data.imac        = 0;
		
		//e:配置上报  4：数据内容的长度 7:子报文头的长度  1：尾标识
		send_remote_confirm(0xe,4+7,1,0,(u8 *)&report_confirm_data);	
		send_init_cfg_flag = 0;
		

		memset(&remote_gate_info[0],255,sizeof(remote_gate_info[0]));
		memset(&remote_gate_info[1],255,sizeof(remote_gate_info[1]));
		memset(&remote_gate_info[2],255,sizeof(remote_gate_info[2]));
		memset(&remote_gate_info[3],255,sizeof(remote_gate_info[3]));
		memset(&remote_gate_info[4],255,sizeof(remote_gate_info[4]));
		memset(&remote_gate_info[5],255,sizeof(remote_gate_info[5]));
		memset(&remote_gate_info[6],255,sizeof(remote_gate_info[6]));
		memset(&remote_gate_info[7],255,sizeof(remote_gate_info[7]));

		return 0;
	}

	int ret = 0;
	ret = get_remote_pkt_type(pkt);
	if(ret == 0)
		printf("get remote cfg pkt\n");
	else
	{
		printf(" pkt error \n");
		return 0;
	}
		
	tsn_rcp_head tsn_rcp_pkt;
	
	
	pkt = pkt+42;//偏移到子报文头
	
	memcpy(&tsn_rcp_pkt,pkt,sizeof(tsn_rcp_head));
	tsn_rcp_pkt.len = htons(tsn_rcp_pkt.len);
	tsn_rcp_pkt.imac = htons(tsn_rcp_pkt.imac);
	printf("tsn_rcp_pkt.type  %d\n",tsn_rcp_pkt.type);
	printf("tsn_rcp_pkt.len  %d\n",tsn_rcp_pkt.len);
	printf("tsn_rcp_pkt.imac  %d\n",tsn_rcp_pkt.imac);
	switch(tsn_rcp_pkt.type)
	{
		case reg_type       :parse_reg_info(tsn_rcp_pkt.imac,pkt,   tsn_rcp_pkt.len -7);break;
		case forward_type   :parse_forward_info(pkt,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port0_type:parse_gate_info(pkt,0,tsn_rcp_pkt.len -7);break;	
		case gate_port1_type:parse_gate_info(pkt,1,tsn_rcp_pkt.len -7);break;
		case gate_port2_type:parse_gate_info(pkt,2,tsn_rcp_pkt.len -7);break;
		case gate_port3_type:parse_gate_info(pkt,3,tsn_rcp_pkt.len -7);break;
		case gate_port4_type:parse_gate_info(pkt,4,tsn_rcp_pkt.len -7);break;
		case gate_port5_type:parse_gate_info(pkt,5,tsn_rcp_pkt.len -7);break;
		case gate_port6_type:parse_gate_info(pkt,6,tsn_rcp_pkt.len -7);break;
		case gate_port7_type:parse_gate_info(pkt,7,tsn_rcp_pkt.len -7);break;
		case inject_type    :parse_inject_info(pkt,tsn_rcp_pkt.len -7);break;
		case submit_type    :parse_submit_info(pkt,tsn_rcp_pkt.len -7);break;
		case map_type       :parse_map_info(pkt,tsn_rcp_pkt.len -7);break;
		case remap_type     :parse_remap_info(pkt,tsn_rcp_pkt.len -7);break;
		default:printf("tsn_rcp_pkt.type is error %d\n",tsn_rcp_pkt.type);break;	

	}
	if(tsn_rcp_pkt.tail_flag == 1 || tsn_rcp_pkt.tail_flag == 3)//当前节点配置结束
	{
		printf("send flt\n");
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_FLT_BASE_ADDR,remote_forward_info);
		printf("send inject table\n");
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_TIS_BASE_ADDR,remote_inject_info);
		printf("send submit table\n");
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_TSS_BASE_ADDR,remote_submit_info);
		printf("send gate table\n");
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC0_BASE_ADDR,remote_gate_info[0]);
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC1_BASE_ADDR,remote_gate_info[1]);
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC2_BASE_ADDR,remote_gate_info[2]);
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC3_BASE_ADDR,remote_gate_info[3]);
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC4_BASE_ADDR,remote_gate_info[4]);
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC5_BASE_ADDR,remote_gate_info[5]);
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC6_BASE_ADDR,remote_gate_info[6]);
		cfg_chip_table(tsn_rcp_pkt.imac,CHIP_QGC7_BASE_ADDR,remote_gate_info[7]);
		printf("send map table\n");
		cfg_hcp_map_table(tsn_rcp_pkt.imac,remote_map_table);
		printf("send remap table\n");
		cfg_hcp_remap_table(tsn_rcp_pkt.imac,remote_remap_table);
		
		
		report_confirm_data.report_type = 1;//离线规划配置上报
		report_confirm_data.cfg_state   = 1;//离线规划配置成功
		report_confirm_data.imac        = ntohs(tsn_rcp_pkt.imac);
		
		//e:配置上报  4：数据内容的长度   1：尾标识
		send_remote_confirm(0xe,4+7,1,tsn_rcp_pkt.imac,(u8 *)&report_confirm_data);
		
		//出示下一个节点
		g_inject_idx = 0;
		g_submit_idx = 0;
		g_map_idx    = 0;
		g_remap_idx  = 0;
		remote_first_cfg_flag = 1;//第一次远程配置标志位设置为1
		//1标识上报类型为离线规划配置上报，
		//4标识上报数据有效内容的长度为4字节，
		//1标识尾报文，
		
		
		if(tsn_rcp_pkt.tail_flag == 3)//如果网络配置结束，则跳转状态
		{
			if(cfg_varify_flag == 1)
				G_STATE = 4;//跳转到配置验证
			else
			{
				G_STATE = 5;//跳转到时间同步初始化状态
				//G_STATE = 6;//测试使用，跳转到动态配置状态
			}
				
		}
	}
	
}	
	
}
		
int dynamic_remote_cfg(u8 *pkt,u16 pkt_len)
{
	if(pkt[0] == 0x60)
{
	cnc_pkt_print(pkt,pkt_len);
	
	int ret = 0;
	ret = get_remote_pkt_type(pkt);
	if(ret == 0)
		printf("get remote cfg pkt\n");
	else
	{
		printf(" pkt error \n");
		return 0;
	}
	
	tsn_rcp_head tsn_rcp_pkt;

	pkt = pkt+42;//偏移到子报文头
	
	memcpy(&tsn_rcp_pkt,pkt,sizeof(tsn_rcp_head));
	tsn_rcp_pkt.len = htons(tsn_rcp_pkt.len);
	tsn_rcp_pkt.imac = htons(tsn_rcp_pkt.imac);
	printf("tsn_rcp_pkt.type  %d\n",tsn_rcp_pkt.type);
	printf("tsn_rcp_pkt.len  %d\n",tsn_rcp_pkt.len);
	printf("tsn_rcp_pkt.imac  %d\n",tsn_rcp_pkt.imac);
	switch(tsn_rcp_pkt.type)
	{
		case reg_type       :dynamic_parse_reg_info(pkt,   tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case forward_type   :dynamic_parse_forward_info(pkt,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port0_type:dynamic_parse_gate_info(pkt,CHIP_QGC0_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;	
		case gate_port1_type:dynamic_parse_gate_info(pkt,CHIP_QGC1_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port2_type:dynamic_parse_gate_info(pkt,CHIP_QGC2_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port3_type:dynamic_parse_gate_info(pkt,CHIP_QGC3_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port4_type:dynamic_parse_gate_info(pkt,CHIP_QGC4_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port5_type:dynamic_parse_gate_info(pkt,CHIP_QGC5_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port6_type:dynamic_parse_gate_info(pkt,CHIP_QGC6_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case gate_port7_type:dynamic_parse_gate_info(pkt,CHIP_QGC7_BASE_ADDR,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case inject_type    :dynamic_parse_inject_info(pkt,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case submit_type    :dynamic_parse_submit_info(pkt,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case map_type       :dynamic_parse_map_info(pkt,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		case remap_type     :dynamic_parse_remap_info(pkt,tsn_rcp_pkt.len -7,tsn_rcp_pkt.imac);break;
		default:printf("tsn_rcp_pkt.type is error %d\n",tsn_rcp_pkt.type);break;

	}	
	return 0;
}
}	

