#include "cnc_api.h"



void printf_single_reg(chip_reg_info *chip_reg)
{
	printf("offset1 		 %d\n",chip_reg->offset1);
	printf("offset2 		 %d\n",chip_reg->offset2);
	printf("cfg_finish		 %d\n",chip_reg->cfg_finish);
	printf("port_type 		 %d\n",chip_reg->port_type);

	printf("slot_len 		 %d\n",chip_reg->slot_len);
	printf("inj_slot_period  %d\n",chip_reg->inj_slot_period);
	printf("sub_slot_period  %d\n",chip_reg->sub_slot_period);

	printf("qbv_or_qch 		 %d\n",chip_reg->qbv_or_qch);
	printf("report_period	 %d\n",chip_reg->report_period);



	printf("report_high		 %d\n",chip_reg->report_high);
	printf("report_low 		 %d\n",chip_reg->report_low);
	printf("report_enable	 %d\n",chip_reg->report_enable);
	printf("reserve6	     %d\n",chip_reg->reserve6);

	//printf("rc_regulation_value	     %d\n",chip_reg->rc_regulation_value);

	
}

void print_chip_report_table(chip_report_table_info *report_entry)
{
	u8 entry_idx = 0;
	for(entry_idx=0;entry_idx<32;entry_idx++)
	{
		printf("entry_idx %d,table %d\n",entry_idx,report_entry->table[entry_idx]);
	}
}


u64 htonll(u64 value)
{
	return (((u64)htonl(value)) << 32) + htonl(value >> 32);
}
/*
void host_to_net_single_reg(u8 *host)
{
	u16 idx = 0;
	u64 *tmp_host_64 = NULL;
	u16 *tmp_host_16 = NULL;
	tmp_host_64 = (u64 *)host;
	tmp_host_16 = (u16 *)host;

	for(idx = 0;idx<2;idx++)
	{
		*(tmp_host_64+idx) = htonll(*(tmp_host_64+idx));
	}
	//在当前条件下，16bit的数据不需要转换，64bit的数据需要转换，目前还不知道原因
	*(tmp_host_16+8) = htons(*(tmp_host_16+8));

}
*/
void host_to_net_single_reg(u8 *host)
{

/*
	chip_reg_info *tmp_chip_reg = NULL;

	tmp_chip_reg = (chip_reg_info *)host;

	tmp_chip_reg->data[0] = htonll(tmp_chip_reg->data[0]);
	tmp_chip_reg->data1[0] = htonll(tmp_chip_reg->data1[0]);
	tmp_chip_reg->data2[0] = htonll(tmp_chip_reg->data2[0]);
	tmp_chip_reg->data3[0] = htons(tmp_chip_reg->data3[0]);


	printf("11121212121212\n");
	printf("offset1 		 %d\n",tmp_chip_reg->offset1);
	printf("offset2 		 %d\n",tmp_chip_reg->offset2);
	printf("cfg_finish		 %d\n",tmp_chip_reg->cfg_finish);
	printf("port_type 		 %d\n",tmp_chip_reg->port_type);

	printf("slot_len 		 %d\n",tmp_chip_reg->slot_len);
	printf("inj_slot_period  %d\n",tmp_chip_reg->inj_slot_period);
	printf("sub_slot_period  %d\n",tmp_chip_reg->sub_slot_period);

	printf("qbv_or_qch 		 %d\n",tmp_chip_reg->qbv_or_qch);
	printf("report_period	 %d\n",tmp_chip_reg->report_period);



	printf("report_high		 %d\n",tmp_chip_reg->report_high);
	printf("report_low 		 %d\n",tmp_chip_reg->report_low);
	printf("report_enable	 %d\n",tmp_chip_reg->report_enable);
	printf("reserve6	     %d\n",tmp_chip_reg->reserve6);
	printf("11121212121212\n");
*/

	u16 idx = 0;
	u64 *tmp_host_64 = NULL;
	u16 *tmp_host_16 = NULL;
	tmp_host_64 = (u64 *)host;
	tmp_host_16 = (u16 *)host;

	for(idx = 0;idx<3;idx++)
	{
		*(tmp_host_64+idx) = htonll(*(tmp_host_64+idx));
	}
	printf("host_to_net_single_reg\n");
	*(tmp_host_16+12) = htons(*(tmp_host_16+12));

}


void host_to_net_chip_table(u8 *host,u16 len)
{
	u16 idx = 0;
	u16 *tmp_host_16 = NULL;
	len = len/2;//转换为16bit
	tmp_host_16 = (u16 *)host;

	for(idx = 0;idx<len;idx++)
	{
		*(tmp_host_16+idx) = htons(*(tmp_host_16+idx));
	}	
}


void host_to_net_chip_map(map_table_info *tmp_map_table)
{
	u8 *pkt = NULL;
	map_table_info *next_map_table = NULL;
	
	tmp_map_table->src_port = htons(tmp_map_table->src_port);
	tmp_map_table->dst_port = htons(tmp_map_table->dst_port);
	tmp_map_table->tsntag.ctl[0] = htonl(tmp_map_table->tsntag.ctl[0]);
	tmp_map_table->tsntag.ctl1[0] = htons(tmp_map_table->tsntag.ctl1[0]);

	//偏移到下一个比较
	pkt = (u8 *)tmp_map_table + sizeof(map_table_info);
	next_map_table = (map_table_info *)pkt;
	
	next_map_table->src_port = htons(next_map_table->src_port);
	next_map_table->dst_port = htons(next_map_table->dst_port);
	next_map_table->tsntag.ctl[0] = htonl(next_map_table->tsntag.ctl[0]);
	next_map_table->tsntag.ctl1[0] = htons(next_map_table->tsntag.ctl1[0]);

}

void host_to_net_chip_remap(remap_table_info *tmp_remap_table)
{
	u8 *pkt = NULL;
	u8 idx = 0;
	remap_table_info *next_remap_table = NULL;
	
	tmp_remap_table->ctl[0] = htons(tmp_remap_table->ctl[0]);
	tmp_remap_table->ctl1[0] = htons(tmp_remap_table->ctl1[0]);

	for(idx=1;idx<4;idx++)
	{
		//偏移到下一个比较
		pkt = (u8 *)tmp_remap_table + sizeof(remap_table_info) * idx;
		next_remap_table = (remap_table_info *)pkt;
		
		next_remap_table->ctl[0] = htons(next_remap_table->ctl[0]);
		next_remap_table->ctl1[0] = htons(next_remap_table->ctl1[0]);
	}



}





//把配置寄存器转换成每个寄存器为32bit的数据
void single_reg_trans_fun(chip_reg_info tmp_chip_reg,u32 *data)
{
	data[0] = tmp_chip_reg.offset1;
	data[1] = tmp_chip_reg.offset2;
	data[2] = tmp_chip_reg.slot_len;
	data[3] = tmp_chip_reg.cfg_finish;
	data[4] = tmp_chip_reg.port_type;
	data[5] = tmp_chip_reg.qbv_or_qch;
	data[6] = tmp_chip_reg.report_high<<8 + tmp_chip_reg.report_low;
	data[7] = tmp_chip_reg.report_enable;
	data[8] = tmp_chip_reg.inj_slot_period;
	data[9] = tmp_chip_reg.sub_slot_period;
	data[10] = tmp_chip_reg.report_period;

	
	data[11] = tmp_chip_reg.offset_period;
	data[12] = tmp_chip_reg.rc_regulation_value;
	data[13] = tmp_chip_reg.be_regulation_value;
	data[14] = tmp_chip_reg.umap_regulation_value;
}

/*
把16位的芯片表项上报转换为32位，与配置的数据结构保持一致
tmp_table为转换后存储的数据结构，chip_report_table为需要转换的内容

*/
void report_table_trans_fun(u32 *tmp_table,chip_report_table_info *chip_report_table)
{
	u8 idx = 0;
	for(idx = 0;idx<32;idx++)
		tmp_table[idx] = (u32)(chip_report_table->table[idx]);
}



/*
	定义：int build_send_chip_cfg_pkt(u16 dimac,u32 addr,u8 num,u8 *data)
	功能：构建和发送芯片配置报文。	
	输入参数：dimac配置设备的imac地址，
			  addr表示配置寄存器首地址，
			  num表示配置的数量,不超过16个，
			  data表示配置内容指针
	返回结果：配置和发送成功返回0，失败返回-1
*/
int build_send_chip_cfg_pkt(u16 dimac,u32 addr,u8 num,u32 *data)
{

	int num_idx = 0;
	nmac_pkt *nmac = NULL;
	//nmac_pkt *nmac_tsn_tag = NULL;
	
	nmac = (nmac_pkt *)build_tsmp_pkt(TSMP_CHIP_CFG,dimac,128);

	if(nmac == NULL)
		return -1;
	
	nmac->dst_tsn_tag.flow_type = 5;//NMAC报文 二进制101
	nmac->dst_tsn_tag.flow_id = dimac;
	nmac->dst_tsn_tag.ctl[0] = ntohl(nmac->dst_tsn_tag.ctl[0]);
	nmac->dst_tsn_tag.ctl1[0] = ntohs(nmac->dst_tsn_tag.ctl1[0]);


	nmac->src_tsn_tag.flow_type = 5;//NMAC报文 二进制101
	nmac->src_tsn_tag.flow_id = CTL_IMAC;
	nmac->src_tsn_tag.ctl[0] = ntohl(nmac->src_tsn_tag.ctl[0]);
	nmac->src_tsn_tag.ctl1[0] = ntohs(nmac->src_tsn_tag.ctl1[0]);

	nmac->type = ntohs(0x1662);
	//nmac->count = ntohs(num);
	nmac->count = num;

	nmac->addr = ntohl(addr);

	for(num_idx = 0;num_idx<num;num_idx++)
	{
		nmac->data[num_idx] = ntohl(data[num_idx]);
	}
	//memcpy(nmac->data,data,num*sizeof(u32));
	//nmac->data = data;

	data_pkt_send_handle((u8 *)nmac,128);

	return 0;
}


/*
	定义：int build_send_hcp_cfg_pkt(u16 dimac,u32 type,u8 *data,u16 num)
	功能：构建和发送HCP配置报文。	
	输入参数：dimac配置设备的imac地址，
			  addr表示配置寄存器地址，
			  data表示配置内容指针
			  num表示配置的数量，
	返回结果：配置和发送成功返回0，失败返回-1
*/
int build_send_hcp_cfg_pkt(u16 dimac,u32 addr,u32 *data,u16 num)
{
	u8 num_idx = 0;
	nmac_pkt *hcp_cfg_pkt = NULL;

	map_table_info *tmp_map_table = NULL;
	map_table_info *tmp_map_table_data = NULL;

	
	remap_table_info *tmp_remap_table = NULL;
	remap_table_info *tmp_remap_table_data = NULL;

	//修改配置类型为TSMP_CHIP_CFG
	hcp_cfg_pkt = (nmac_pkt *)build_tsmp_pkt(TSMP_HCP_CFG,dimac,128);
	//hcp_cfg_pkt = (nmac_pkt *)build_tsmp_pkt(TSMP_CHIP_CFG,dimac,128);
	if(hcp_cfg_pkt == NULL)
		return -1;
#if 0
//nmac 配置报文赋值
	hcp_cfg_pkt->dst_tsn_tag.flow_type = 5;//NMAC报文 二进制101
	hcp_cfg_pkt->dst_tsn_tag.flow_id = dimac;
	hcp_cfg_pkt->dst_tsn_tag.ctl[0] = ntohl(hcp_cfg_pkt->dst_tsn_tag.ctl[0]);
	hcp_cfg_pkt->dst_tsn_tag.ctl1[0] = ntohs(hcp_cfg_pkt->dst_tsn_tag.ctl1[0]);


	hcp_cfg_pkt->src_tsn_tag.flow_type = 5;//NMAC报文 二进制101
	hcp_cfg_pkt->src_tsn_tag.flow_id = CTL_IMAC;
	hcp_cfg_pkt->src_tsn_tag.ctl[0] = ntohl(hcp_cfg_pkt->src_tsn_tag.ctl[0]);
	hcp_cfg_pkt->src_tsn_tag.ctl1[0] = ntohs(hcp_cfg_pkt->src_tsn_tag.ctl1[0]);

	hcp_cfg_pkt->type = ntohs(0x1662);
	//nmac->count = ntohs(num);
	hcp_cfg_pkt->count = num;

	hcp_cfg_pkt->addr = ntohl(addr);
#endif

	//配置映射表
	if(addr == HCP_MAP_BASE_ADDR)
	{
		tmp_map_table 	   = (map_table_info *)(hcp_cfg_pkt);//
		tmp_map_table_data = (map_table_info *)data;
		for(num_idx=0;num_idx<num;num_idx++)
		{
			tmp_map_table[num_idx].addr 		   = ntohl(tmp_map_table_data[num_idx].addr);
			tmp_map_table[num_idx].src_port 	   = ntohs(tmp_map_table_data[num_idx].src_port);
			tmp_map_table[num_idx].dst_port 	   = ntohs(tmp_map_table_data[num_idx].dst_port);
			tmp_map_table[num_idx].pro_type 	   = tmp_map_table_data[num_idx].pro_type;
			memcpy(tmp_map_table[num_idx].src_ip,tmp_map_table_data[num_idx].src_ip,4);
			memcpy(tmp_map_table[num_idx].dst_ip,tmp_map_table_data[num_idx].dst_ip,4);
			tmp_map_table[num_idx].tsntag.ctl[0]   = ntohl(tmp_map_table_data[num_idx].tsntag.ctl[0]);
			tmp_map_table[num_idx].tsntag.ctl1[0]  = ntohs(tmp_map_table_data[num_idx].tsntag.ctl1[0]);
		}
	}
	else if(addr == HCP_REMAP_BASE_ADDR)//配置重映射表
	{
		tmp_remap_table 	   = (remap_table_info *)(hcp_cfg_pkt);//
		tmp_remap_table_data   = (remap_table_info *)data;

		for(num_idx=0;num_idx<num;num_idx++)
		{
			tmp_remap_table[num_idx].addr 		   = ntohl(tmp_remap_table_data[num_idx].addr);
			tmp_remap_table[num_idx].reserve1 	   = ntohs(tmp_remap_table_data[num_idx].reserve1);
			tmp_remap_table[num_idx].ctl[0] 	   = ntohs(tmp_remap_table_data[num_idx].ctl[0]);
			tmp_remap_table[num_idx].ctl1[0] 	   = ntohs(tmp_remap_table_data[num_idx].ctl1[0]);
			memcpy(tmp_remap_table[num_idx].dmac,tmp_remap_table_data[num_idx].dmac,6);
		}

	}
		//memcpy(hcp_cfg_pkt,data,sizeof(remap_table_info)*num);
	else//配置单个寄存器，每次只能配置一个单个寄存器
	{
		//printf("hcp addr error\n");
		*(u32 *)hcp_cfg_pkt = ntohl(addr);
		*((u32 *)hcp_cfg_pkt + 1) = ntohl(*data);
	}

	data_pkt_send_handle((u8 *)hcp_cfg_pkt,128);
}




/*
	定义：int cfg_chip_single_register(u16 dimac,chip_reg_info chip_reg)
	功能：配置芯片的所有单个寄存器,并进行确认。	
	输入参数：dimac配置设备的imac地址，
			  chip_reg 表示单个寄存器的值
	返回结果：配置和发送成功返回0，失败返回-1
*/
int cfg_chip_single_register(u16 dimac,chip_reg_info chip_reg)
{
	u16 len = 0;
	u16 get_report_type = 0;
	u8 *pkt = NULL;
	u32 cur_cfg_info = 0;
	u32 single_ref_cfg[15];//需要配置15个寄存器，每个寄存器32bit
	//chip_reg_info chip_reg;//芯片配置的单个寄存器
	chip_reg_info *chip_report_reg;//芯片上报的单个寄存器


	single_reg_trans_fun(chip_reg,single_ref_cfg);
	build_send_chip_cfg_pkt(dimac,CHIP_OFFSET_L_ADDR,15,single_ref_cfg);//单个寄存器,CHIP_OFFSET_L_ADDR为基地址
	cur_cfg_info = CHIP_REG_REPORT;
	build_send_chip_cfg_pkt(dimac,CHIP_REPORT_TYPE_ADDR,1,&cur_cfg_info);//配置上报类型为单个寄存器上报
		
#if 0
	while(1)
	{
		
		printf("wait report pkt\n");
		pkt = data_pkt_receive_dispatch_1(&len) + DATA_OFFSET;
		get_report_type = *(pkt + len -2);
		get_report_type = get_report_type<<8 + *(pkt + len -1);

		//判断是否为芯片状态上报报文和上报类型为刚配置的类型
		if(*(pkt+14) == TSMP_BEACON && get_report_type == CHIP_REG_REPORT)
		{
			host_to_net_single_reg(pkt);
			
			chip_report_reg = (chip_reg_info *)pkt;
			printf("111111111111\n");
			printf_single_reg(&chip_reg);	
			printf("2222222222222\n");
			printf_single_reg(chip_report_reg);
			
			if(memcmp(&chip_reg,chip_report_reg,sizeof(chip_reg_info))==0)
			{
				printf("single_reg cfg success\n");
				break;
			}
			else
			{
				printf("single_reg cfg fail\n");
			}

		}
		else
		{
			
			printf("report single_reg pkt error\n");
		}
			

	}
#endif	

	return 0;
}


/*
	定义：int cfg_chip_table(u16 dimac,u8 type,chip_cfg_table_info chip_cfg_table)
	功能：配置芯片的表项，并进行确认函数。	
	输入参数：dimac配置设备的imac地址，
			  chip_cfg_table 表示表项
	返回结果：配置和发送成功返回0，失败返回-1
*/
int cfg_chip_table(u16 dimac,u32 type,chip_cfg_table_info chip_cfg_table)
{
	u16 len = 0;
	u16 get_report_type = 0;


	u8 *pkt = NULL;
	u16 table_idx = 0;
	u32 table[32];

	u32 report = 0;
	
	//chip_cfg_table_info chip_cfg_table;//芯片配置表项
	chip_report_table_info *chip_report_table;//芯片上报表项
	//memset(&chip_cfg_table,0,sizeof(chip_cfg_table_info));//清零,初值为0


	u16 cfg_num 	= 0;
	u16 report_type = 0;

	switch(type)
	{
		case CHIP_FLT_BASE_ADDR:  cfg_num = 512;report_type = CHIP_FLT_REPORT_BASE;break;
		case CHIP_TIS_BASE_ADDR:  cfg_num = 32;report_type = CHIP_TIS_REPORT_BASE;break;
		case CHIP_TSS_BASE_ADDR:  cfg_num = 32;report_type = CHIP_TSS_REPORT_BASE;break;
		case CHIP_QGC0_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC0_REPORT_BASE;break;
		case CHIP_QGC1_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC1_REPORT_BASE;break;
		case CHIP_QGC2_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC2_REPORT_BASE;break;
		case CHIP_QGC3_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC3_REPORT_BASE;break;
		case CHIP_QGC4_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC4_REPORT_BASE;break;
		case CHIP_QGC5_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC5_REPORT_BASE;break;
		case CHIP_QGC6_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC6_REPORT_BASE;break;
		case CHIP_QGC7_BASE_ADDR: cfg_num = 32;report_type = CHIP_QGC7_REPORT_BASE;break;
	}
	


	//512=16384/32 ,每次配置32个表项，一共需要配置512次
	for(table_idx = 0;table_idx<cfg_num;table_idx++)
	{
		//每次配置16个表项，配置两次确认一次
		printf("chip_cfg_table.table[0] %u\n",chip_cfg_table.table[0]);
		build_send_chip_cfg_pkt(dimac,type + table_idx*32,16,(u32 *)&(chip_cfg_table.table[table_idx*32]));
		build_send_chip_cfg_pkt(dimac,type + table_idx*32 + 16,16,&(chip_cfg_table.table[table_idx*32 + 16]));//

#if 0
		//配置上报类型，用于配置验证
		report = report_type + table_idx;
		build_send_chip_cfg_pkt(dimac,CHIP_REPORT_TYPE_ADDR,1,&report);//配置上报类型为转发表的上报类型

		while(1)
		{
		
			printf("wait report pkt\n");
			pkt = data_pkt_receive_dispatch_1(&len);
			
			printf("len %d\n",len);
			get_report_type = *(pkt + len -2);
			printf("get_report_type %d\n",get_report_type);
			get_report_type = get_report_type<<8;
			
			printf("get_report_type %d\n",get_report_type);
			get_report_type = get_report_type + *(pkt + len -1);			
			printf("get_report_type %d\n",get_report_type);
			
			if(*(pkt+14) == TSMP_BEACON && get_report_type == report)
			{
				pkt = pkt + DATA_OFFSET;

				host_to_net_chip_table(pkt,sizeof(chip_report_table_info));
		
				chip_report_table = (chip_report_table_info *)pkt;
				
				printf("print cfg\n");
				for(int i=0;i<32;i++)
				{
					printf("table %d\n",chip_cfg_table.table[table_idx*32 + i]);
				}
				printf("print report\n");
				print_chip_report_table(chip_report_table);
		
				//把表项上报信息转换为与配置信息相同的位宽，方便进行比较
				report_table_trans_fun(table,chip_report_table);

				if(memcmp((u8 *)table,(u8 *)&(chip_cfg_table.table[table_idx*32]),10)==0)
				{
					printf("%d 111forward cfg success\n",table_idx);
					break;
				}
				else
				{
					printf("%d 111forward cfg fail\n",table_idx);
					//return -1;
				}
			}
			else
			{
				
				printf("%d %d report chip table pkt error\n",report,get_report_type);
			}

		}

#endif
	}	
	return 0;
}


/*
	定义：int cfg_hcp_map_table(u16 imac,map_table_info *map_table)
	功能：配置hcp映射表，并进行确认函数。	
	输入参数：imac配置设备的imac地址，
			  map_table 表示映射表的数据结构
	返回结果：配置和发送成功返回0，失败返回-1
*/
int cfg_hcp_map_table(u16 imac,map_table_info *map_table)
{
	u16 get_report_type = 0;
	u16 len = 0;
	u8 *pkt = NULL;

	map_table_info *map_table_report = NULL;

	u32 cur_cfg_info = 0;

	u8 table_idx = 0;//共32条表项，每个报文配置2个映射表，一共配置16个报文
	for(table_idx = 0;table_idx<16;table_idx++)
	{
		printf("table_idx %d\n",table_idx);
		printf("map_table[table_idx*2].addr %x\n",map_table[table_idx*2].addr);

		printf("src_ip %d.%d.%d.%d\n",map_table[table_idx*2].src_ip[0],
									  map_table[table_idx*2].src_ip[1],
									  map_table[table_idx*2].src_ip[2],
									  map_table[table_idx*2].src_ip[3]);
		build_send_hcp_cfg_pkt(imac,HCP_MAP_BASE_ADDR,(u32 *)&(map_table[table_idx*2]),2);
		cur_cfg_info = HCP_MAP_REPORT+table_idx;
		//build_send_hcp_cfg_pkt(imac,HCP_REPORT_TYPE_ADDR,(u32 *)&cur_cfg_info,1);


		printf("77777777777777777777777\n");
		//build_send_hcp_cfg_pkt(imac,HCP_REPORT_TYPE_ADDR,(u32 *)&cur_cfg_info,1);
		//build_send_hcp_cfg_pkt(imac,HCP_MAP_BASE_ADDR,(u32 *)&(map_table[table_idx*2]),2);
		
		printf("888888888888888888888888\n");
#if 0
		while(1)
		{

			//大小端转换
			
			printf("wait report pkt\n");
			pkt = data_pkt_receive_dispatch_1(&len);
			
			get_report_type = *(pkt + 16);
			
			printf("get_report_type %d\n",get_report_type);
			get_report_type = get_report_type<<8; 
			
			printf("get_report_type %d\n",get_report_type);
			get_report_type = get_report_type + *(pkt + 17);
			printf("get_report_type %d\n",get_report_type);
			printf("cur_cfg_info %d\n",cur_cfg_info);

			
			if(*(pkt+14) == TSMP_HCP_REPORT && get_report_type == cur_cfg_info)
			{


			
				map_table_report = (map_table_info *)(pkt + 32);
				host_to_net_chip_map(map_table_report);
	/*			
				printf("cfg data\n");
				cnc_pkt_print((u8 *)map_table,64);
				printf("report data\n");
				cnc_pkt_print((u8 *)map_table_report,64);
	*/			
				//比较配置与上报是否一致，只比较数据内容，不比较地址，因此每次比较地址需要后移4个字节
				if(memcmp((u8 *)&map_table[table_idx*2]+4,(u8 *)map_table_report + 4,sizeof(map_table_info)-4)==0 
					&& memcmp((u8 *)&map_table[table_idx*2 + 1]+4,(u8 *)(map_table_report+1) + 4,sizeof(map_table_info)-4) == 0)
				{
					printf("%d map cfg success\n",table_idx);
					break;
				}
				else
				{
					printf("%d map cfg fail\n",table_idx);
					//return -1;
				}
			}
			else
			{
				
				printf("%d map report error\n",table_idx);
			}

		}

#endif
	}
	
	return 0;

}

/*
	定义：int cfg_chip_table(u16 dimac,u8 type,chip_cfg_table_info chip_cfg_table)
	功能：配置芯片的表项，并进行确认函数。	
	输入参数：dimac配置设备的imac地址，
			  remap_table 表示重映射
	返回结果：配置和发送成功返回0，失败返回-1
*/
int cfg_hcp_remap_table(u16 imac,remap_table_info *remap_table)
{

	u16 get_report_type = 0;
	u16 len = 0;
	u8 *pkt = NULL;


	u32 cur_cfg_info = 0;

	remap_table_info *remap_table_report = NULL;

	u8 table_idx = 0;//共256条表项，每个报文配置4个重映射表，每次上报4个，一共配置64个报文
	for(table_idx = 0;table_idx<64;table_idx++)
	{
		build_send_hcp_cfg_pkt(imac,HCP_REMAP_BASE_ADDR,(u32 *)&remap_table[table_idx*4],4);
		cur_cfg_info = HCP_REMAP_REPORT+table_idx;
		//build_send_hcp_cfg_pkt(imac,HCP_REPORT_TYPE_ADDR,&cur_cfg_info,1);
#if 0
		while(1)
		{
		
			printf("wait report pkt\n");
			pkt = data_pkt_receive_dispatch_1(&len);
			
			get_report_type = *(pkt + 16);
			
			printf("get_report_type %d\n",get_report_type);
			get_report_type = get_report_type<<8 ;
			
			printf("get_report_type %d\n",get_report_type);
			get_report_type = get_report_type + *(pkt + 17);
			
			printf("get_report_type %d\n",get_report_type);
			
			printf("cur_cfg_info %d\n",cur_cfg_info);
			if(*(pkt+14) == TSMP_HCP_REPORT && get_report_type == cur_cfg_info)
			{
				remap_table_report = (remap_table_info *)(pkt + 32);
				
				host_to_net_chip_remap(remap_table_report);
				
				printf("cfg data\n");
				cnc_pkt_print((u8 *)&remap_table[table_idx*4],64);
				printf("report data\n");
				cnc_pkt_print((u8 *)remap_table_report,64);
			
				
				//比较配置与上报是否一致，只比较数据内容，不比较地址，因此每次比较地址需要后移4个字节
				if(memcmp((u8 *)&remap_table[table_idx*4]+4,(u8 *)remap_table_report + 4,sizeof(remap_table_info)-4)==0 &&
				   memcmp((u8 *)&remap_table[table_idx*4 + 1]+4,(u8 *)(remap_table_report+1) + 4,sizeof(remap_table_info)-4)==0)
				{
					printf("%d remap cfg success\n",table_idx);
					break;
				}
				else
				{
					printf("%d remap cfg fail\n",table_idx);
					//return -1;
				}
			}
			else
			{
				
				printf("%d remap report error\n",table_idx);
			}
		}

#endif
	}
	
	return 0;

}




