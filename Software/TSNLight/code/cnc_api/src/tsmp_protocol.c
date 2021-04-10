#include "cnc_api.h"


//BE流类型
#define FLOW_TYPE_BE 0x06

//控制器的imac
#define SIMAC 0x00

//TSNTag长度
#define TSNTAG_LEN 6

//TSMP头长度
#define TSMP_HEADER_LEN 16

void cnc_pkt_print(u8 *pkt,int len)
{
	int i=0;

	printf("-----------------------***CNC PACKET***-----------------------\n");
	printf("Packet Addr:%p\n",pkt);
	for(i=0;i<16;i++)
	{
		if(i % 16 == 0)
			printf("      ");
		printf(" %X ",i);
		if(i % 16 == 15)
			printf("\n");
	}
	
	for(i=0;i<len;i++)
	{
		if(i % 16 == 0)
			printf("%04X: ",i);
		printf("%02X ",*((u8 *)pkt+i));
		if(i % 16 == 15)
			printf("\n");
	}
	if(len % 16 !=0)
		printf("\n");
	printf("-----------------------***CNC PACKET***-----------------------\n\n");
}


static void copy_tsmp_header(tsmp_header *pkt,tsmp_sub_type type,u16 dimac)
{
	pkt->sub_type = type;

	pkt->dmac.flow_type = FLOW_TYPE_BE;
	pkt->dmac.flow_id = dimac;
	pkt->dmac.ctl[0] = htonl(pkt->dmac.ctl[0]);

	pkt->smac.flow_type = FLOW_TYPE_BE;
	pkt->smac.flow_id = SIMAC;
	pkt->smac.ctl[0] = htonl(pkt->smac.ctl[0]);
	
	pkt->type = htons(TSMP_PROTOCOL);

	return;
}

/*
	定义：u8* build_tsmp_pkt(tsmp_sub_type type,u16 dimac,u16 pkt_len)
	功能：完成tsmp报文内存空间的申请，TSMP头的赋值。	
	输入参数：tsmp子类型，目的imac，除TSMP头之外的报文长度
	返回结果：成功返回偏移TSMP头之后的数据报文指针地址，失败返回NULL
*/

u8* build_tsmp_pkt(tsmp_sub_type type,u16 dimac,u16 pkt_len)
{
	tsmp_header *pkt = (tsmp_header *)malloc(TSMP_HEADER_LEN+pkt_len+1);
	bzero(pkt,TSMP_HEADER_LEN+pkt_len+1);

	//tsmp头赋值
	copy_tsmp_header(pkt,type,dimac);

	//打印tsmp报文头
	//cnc_pkt_print((u8 *)pkt,TSMP_HEADER_LEN);

	//返回偏移TSMP头之后的数据报文指针地址
	return (u8 *)pkt + TSMP_HEADER_LEN;
}


/*
	定义：int tsmp_header_switch_handle(u8* pkt,u16 len);
	功能：完成tsmp报文头源目的mac的互换
	输入参数：tsmp报文头指针、tsmp报文长度
	返回结果：成功返回去掉tsmp头之后的报文指针地址，失败返回NULL
*/

u8* tsmp_header_switch_handle(u8* pkt,u16 len)
{
	u8 dtmp[8] ={0};
	u8* ptr = NULL;

	//指向smac
	ptr = pkt+TSNTAG_LEN ;

	//把dmac保存
	memcpy(dtmp,pkt,TSNTAG_LEN);

	//赋值dmac
	memcpy(pkt,ptr,TSNTAG_LEN);

	//赋值smac
	memcpy(ptr,dtmp,TSNTAG_LEN);

	pkt = (u8*)pkt+TSMP_HEADER_LEN;

	return pkt;	
}


/*
	定义：u16 get_simac_from_tsmp_pkt(u8* pkt,u16 len);
	功能：从tsmp报文头中取出源mac的imac字段，返回的imac是主机序
	输入参数：tsmp数据报文指针、tsmp数据报文长度
	返回结果：成功返回imac值（主机序），失败返回-1
*/

u16 get_simac_from_tsmp_pkt(u8* pkt,u16 len)
{
	u16 imac =0 ;
	u8 tmp[16] = {0};
	
	if(len < TSMP_HEADER_LEN)
	{
		CNCAPI_ERR("pkt len is error! \n");
		return -1;
	}

	//报文拷贝出来，避免改变原报文字段
	memcpy(tmp,pkt,TSMP_HEADER_LEN);
	
	tsmp_header *pkt_hdr = (tsmp_header *)tmp;

	pkt_hdr->smac.ctl[0] = ntohl(pkt_hdr->smac.ctl[0]);

	imac = pkt_hdr->smac.flow_id;

	return imac;	
}


void free_pkt(u8* pkt)
{
	//指针偏移到tsmp头
	pkt = pkt - TSMP_HEADER_LEN;
	
	if(pkt)
	{
		free(pkt);
		pkt = NULL;
	}

	return ;
}



