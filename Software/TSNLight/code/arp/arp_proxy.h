#ifndef _ARP_PROXY_H__
#define _ARP_PROXY_H__

//#include <libnet.h>
#include "cnc_api.h"
#include <stdbool.h>
#include <libxml/xmlmemory.h>  
#include <libxml/parser.h>  

#define DEFAULT_XML_FILE "arp_table.xml"

//arp item number
#define ARP_TABLE_SIZE 256 
//ehternet header length
#define ETH_HEADER_LEN 14
//arp header length
#define ARP_HEADER_LEN 8
//mac address length
#define MAC_ADDR_LEN 6
//ip address length
#define IP_ADDR_LEN 4

//ip-tsntag mapping 
struct arp_item
{
	u8 mac_addr[6];
	u8 ip_addr[4];
};

//arp packet 
//struct arp_header
//{
//    u16 hardware_type;      /* type of the hardware port, ethernet is 1 */
//    u16 protocol_type;      /* type of the protocol, ip is 0x0800  */
//    u8  hwaddr_len;         /* length of the hardware address, ethernet is 6*/
//    u8  ptaddr_len;         /* length of protocol address, ip is 4 */
//    u16 op_type;            /* operation type, arp req 1, arp resp 2, rarp req 3, rarp resp 4 */
//};


int arp_table_init();
bool is_arp_req(u8* pkt, u16 len);
int arp_table_lookup(u8* ip);
void buid_arp_resp (u8* pkt, u16 len, int index);


#endif

