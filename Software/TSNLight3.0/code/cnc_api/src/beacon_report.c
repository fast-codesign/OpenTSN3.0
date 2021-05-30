#include "cnc_api.h"


/*
	定义：u16 get_chip_report_type(u8 *pkt,u16 len)
	功能：根据上报报文获取上报类型。	
	输入参数：pkt表示上报报文，
			  len表示上报报文长度，
	返回结果：上报报文类型
*/
u16 get_chip_report_type(u8 *pkt,u16 len)
{
	u16 report_type = 0;
	pkt = pkt + len - 2;//上报类型在最后两个字节
	report_type = *pkt<<8; 
	report_type = report_type + *(pkt+1);
	return report_type;
}


/*
	定义：
	功能：从上报报文中获取offset值	
	输入参数：
			  
	返回结果：
*/




