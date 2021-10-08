#include "arp_proxy.h"

struct arp_item arp_table[ARP_TABLE_SIZE]={0};

/* 解析arp_entry，把值取出来放到arp表中 */  
static void parse_arp_entry(xmlDocPtr doc, xmlNodePtr cur)
{  

	xmlNodePtr entry;
    xmlChar *IP,*MAC;

	int i = 0;

	for(entry=cur->children;entry;entry=entry->next)
	{  
    	if(xmlStrcasecmp(entry->name,(const xmlChar *)"entry")==0)
		{
            IP=xmlGetProp(entry,(const xmlChar *)"IP");
			MAC=xmlGetProp(entry,(const xmlChar *)"MAC");
            
            printf("IP=%s \n MAC=%s\n",(char*)IP,(char*)MAC);

			sscanf(MAC,"%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
			&arp_table[i].mac_addr[0],&arp_table[i].mac_addr[1],
			&arp_table[i].mac_addr[2],&arp_table[i].mac_addr[3],
			&arp_table[i].mac_addr[4],&arp_table[i].mac_addr[5]);
		
			sscanf(IP,"%hhd.%hhd.%hhd.%hhd.",&arp_table[i].ip_addr[0],&arp_table[i].ip_addr[1],&arp_table[i].ip_addr[2],&arp_table[i].ip_addr[3]);
			i++;
		}
            //xmlFree(IP);
            //xmlFree(MAC);
    }


#if 0
	u8 str[128] = {0};
	int j = i;

	for(i =0 ; i<j;i++)
	{
		sprintf(str,"%02x%02x%02x%02x%02x%02x",arp_table[i].mac_addr[0],arp_table[i].mac_addr[1],
			arp_table[i].mac_addr[2],arp_table[i].mac_addr[3],
			arp_table[i].mac_addr[4],arp_table[i].mac_addr[5]);
		printf("mac = %s \n",str);

		sprintf(str,"%02x%02x%02x%02x",arp_table[i].ip_addr[0],arp_table[i].ip_addr[1],arp_table[i].ip_addr[2],arp_table[i].ip_addr[3]);
		printf("ip = %s \n",str);
	}

#endif

    return;  
}

/* 解析文档 */  
static int parseDoc(char *docname){  
    /* 定义文档和节点指针 */  
    xmlDocPtr doc;  
    xmlNodePtr cur;  
    
    /* 进行解析，如果没成功，显示一个错误并停止 */  
    doc = xmlParseFile(docname);  
    if(doc == NULL){  
        fprintf(stderr, "Document not parse successfully. \n");  
        return -1;  
    }  
  
    /* 获取文档根节点，若无内容则释放文档树并返回 */  
    cur = xmlDocGetRootElement(doc);  
    if(cur == NULL){  
        fprintf(stderr, "empty document\n");  
        xmlFreeDoc(doc);  
        return -1;  
    }  
  
    /* 确定根节点名是否为nodes，不是则返回 */  
    if(xmlStrcmp(cur->name, (const xmlChar *)"nodes")){  
        fprintf(stderr, "document of the wrong type, root node != nodes");  
        xmlFreeDoc(doc);  
        return -1;  
    }  
  
    /* 遍历文档树 */  
    cur = cur->xmlChildrenNode;  
    while(cur != NULL){  
        /* 找到arp_table子节点 */  
        if(!xmlStrcmp(cur->name, (const xmlChar *)"arp_table")){  
            parse_arp_entry(doc, cur); /* 解析arp_table子节点 */  
        }
        
        cur = cur->next; /* 下一个子节点 */  
    }  
  
    xmlFreeDoc(doc); /* 释放文档树 */  
    return 0;  
}  

bool is_arp_req(u8* pkt, u16 len)
{
	//arp operation type, 14 bytes ethernet hearder + 6 bytes arp header
	//arp request 0x0001
	return pkt[20] == 0 & pkt[21] == 1;
}

int arp_table_lookup(u8* ip)
{
	int i = 0;
	int j = 0;
	u8 diffs = 0;
	
	//printf("%02x,%02x,%02x,%02x\n",ip[0],ip[1],ip[2],ip[3]);

	for(i =0 ; i<ARP_TABLE_SIZE;i++)
	{
		j = 0;
		diffs = 0;
		while(j<4 && diffs == 0)
		{
			diffs |= (arp_table[i].ip_addr[j] ^ ip[j]);
			//printf("i= %d ,j=%d \n",i,j);
			j++;
		}

		//printf("i= %d ,j=%d ,diff = %d \n",i,j,diffs);
		
		if(diffs == 0)
		{
			break;
			
		}
	}

	if( i == ARP_TABLE_SIZE)
	{
		i = -1;
	}

	//printf("i = %d \n",i);
	
	return i;
}

void buid_arp_resp(u8* pkt, u16 len,int index)
{
	u8* ptr = NULL;
	u8 tmp[32] = {0};
	u8 arp_type[2] = {0x00,0x02}; //arp response

	u8 inport;

	/****arp报文的处理***/
	//move to smac
	ptr = pkt + MAC_ADDR_LEN;

	//copy smac to dmac
	memcpy(pkt,ptr,MAC_ADDR_LEN);

	//copy matched mac address to smac
	memcpy(ptr,arp_table[index].mac_addr,MAC_ADDR_LEN);

	//set the arp type
	pkt[ETH_HEADER_LEN + ARP_HEADER_LEN-2] = 0x00;
	pkt[ETH_HEADER_LEN + ARP_HEADER_LEN-1] = 0x02;

	//store src mac and src ip
	ptr = pkt + ETH_HEADER_LEN + ARP_HEADER_LEN;
	memcpy(tmp,ptr,MAC_ADDR_LEN + IP_ADDR_LEN);
	
	//copy dest mac
	memcpy(ptr,arp_table[index].mac_addr,MAC_ADDR_LEN);

	//copy dest IP
	ptr = ptr + MAC_ADDR_LEN;
	memcpy(ptr,arp_table[index].ip_addr,IP_ADDR_LEN);

	//copy src mac and ip
	ptr = ptr + IP_ADDR_LEN;
	memcpy(ptr,tmp,MAC_ADDR_LEN + IP_ADDR_LEN);

	//np_pkt_print(pkt , len);	
	
	return;
}
//初始化状态下arp的初始化
int arp_table_init()
{
	char *docname = DEFAULT_XML_FILE;
	    
	if (parseDoc(docname) != 0) {
     fprintf(stderr, "Failed to parse xml.\n");
     return -1;
    }

	return 0;
}
//网络运行状态下arp响应函数
void arp_reply(u16 pkt_len,const unsigned char *packet_content)
{
	u16 imac=0;
	u8* pkt = NULL;
	
	cnc_pkt_print((u8*)packet_content,pkt_len);

	
	//exchange dmac and smac, pkt points to the ethernet header
	pkt = tsmp_header_switch_handle((u8*)packet_content,pkt_len);
	pkt_len = pkt_len - 16;//delete tsmp header

	//is arp?
	if(is_arp_req(pkt, pkt_len))
	{
		//arp table lookup, using destination ip address in arp packet
		int ret = arp_table_lookup(pkt + 38);

		if(-1 == ret)
		{
			printf("arp table dismatch!\n");
			return;
		}
		printf("arp match table %d!\n",ret);
		//generate an arp response
		buid_arp_resp(pkt, pkt_len, ret);
		cnc_pkt_print(pkt-16,pkt_len+16);
		//发送报文
		data_pkt_send_handle(pkt ,pkt_len);
	}
	
	return ;
}
