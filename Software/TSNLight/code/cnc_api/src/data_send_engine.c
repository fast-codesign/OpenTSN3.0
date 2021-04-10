
#include "../include/cnc_api.h"

//raw socket句柄变量定义
int sock_raw_fd;
struct sockaddr_ll sll;	


/*
	定义：int data_pkt_send_init();
	功能：完成数据报文发送资源的初始化。包括raw scoket句柄的初始化、指定网卡名称、原始套接字地址结构赋值等	
	输入参数：无
	返回结果：成功返回0，失败返回-1
*/

int data_pkt_send_init(u8* net_interface)
{
	//原始套接字初始化
	sock_raw_fd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
	
	//原始套接字地址结构
	struct ifreq req;

	//获取网络接口名字
	//char temp_net_interface[256] = {0};
	//char *net_interface ="enaftgm1i0";
	//strcpy(temp_net_interface,net_interface);

	CNCAPI_DBG("net_interface = %s \n",net_interface);
	if(NULL == net_interface)
	{
	    CNCAPI_ERR("net_interface is NULL!\n");
	    return -1;	
	}

	//指定网卡名称
	strncpy(req.ifr_name,net_interface, IFNAMSIZ);			
	
	if(-1 == ioctl(sock_raw_fd, SIOCGIFINDEX, &req))
	{
		CNCAPI_ERR("ioctl error!\n");
		close(sock_raw_fd);
		return -1;
	}
	
	/*将网络接口赋值给原始套接字地址结构*/
	bzero(&sll, sizeof(sll));
	sll.sll_ifindex = req.ifr_ifindex;
	

	return 0;
}

/*
	定义：int data_pkt_send_handle(u8* pkt,u16 len);
	功能：完成数据报文的发送处理
	输入参数：数据报文指针、数据报文长度
	返回结果：成功返回0，失败返回-1
*/
int data_pkt_send_handle(u8* pkt,u16 len)
{
	int strlen;
	//CNCAPI_DBG("send pkt\n");

	//指针往左偏移16字节，即tsmp头部，相应的报文长度需要增加tsmp头
	pkt = pkt - 16;
	len = len + 16;

	//cnc_pkt_print(pkt,len);
	
	strlen = sendto(sock_raw_fd, pkt, len, 0 , (struct sockaddr *)&sll, sizeof(sll));
	if(len == -1)
	{
	   CNCAPI_ERR("sendto fail\n");
	   return -1;
	}

	return 0;
}


/*
	定义：int data_pkt_send_destroy();
	功能：完成数据报文发送相关资源的销毁
	输入参数：无
	返回结果：成功返回0，失败返回-1
*/

int data_pkt_send_destroy()
{
	close(sock_raw_fd);
	return 0;
}



