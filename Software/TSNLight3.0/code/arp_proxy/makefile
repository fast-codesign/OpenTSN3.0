
LDLIBS  = -I../cnc_api/include -I /usr/local/include/libxml2/ -lxml2 -L../cnc_api/ -lcnc_api -lpthread -lm -lpcap
arp_proxy:arp_proxy.c
	gcc -o arp_proxy arp_proxy.c $(LDLIBS) 
clean:
	rm -f arp_proxy
