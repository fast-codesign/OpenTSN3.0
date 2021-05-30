CC = gcc -g
AR = ar

LDHDPATH = -I ./cnc_api/include 
LDLIBS = -lm -lpcap
LDLIBS2  = -L ./cnc_api/ -lcnc_api -I /usr/local/include/libxml2/ -lxml2
LIBSRC=./cnc_api/src/



CNCAPI = ./cnc_api/
PTP  = ./ptp/

INIT_CFG = ./net_init/
BASIC_CFG = ./basic_cfg/
LOCAL_CFG = ./local_cfg/
REMOTE_CFG = ./remote_cfg/

STATEMON = ./state_monitor/
ARP = ./arp_proxy/


tsnlight: main.c libcnc_api.a net_init.o basic_cfg.o local_cfg.o remote_cfg.o ptp.o state_monitor.o arp_proxy.o 
	$(CC) -o tsnlight main.c $(CNCAPI)libcnc_api.a $(INIT_CFG)net_init.o $(BASIC_CFG)basic_cfg.o $(LOCAL_CFG)local_cfg.o $(REMOTE_CFG)remote_cfg.o $(PTP)ptp.o $(STATEMON)state_monitor.o $(ARP)arp_proxy.o $(LDLIBS) $(LDLIBS2)

libcnc_api.a:
	$(CC) -o $(LIBSRC)data_rec_engine.o -c $(LIBSRC)data_rec_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)data_send_engine.o -c $(LIBSRC)data_send_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)tsmp_protocol.o -c $(LIBSRC)tsmp_protocol.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)reg_cfg.o -c $(LIBSRC)reg_cfg.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)beacon_report.o -c $(LIBSRC)beacon_report.c $(LDLIBS) $(LDHDPATH)
	$(AR) -rc $(CNCAPI)libcnc_api.a $(LIBSRC)data_rec_engine.o $(LIBSRC)data_send_engine.o $(LIBSRC)tsmp_protocol.o $(LIBSRC)reg_cfg.o $(LIBSRC)beacon_report.o

ptp.o:
	$(CC) -o $(PTP)ptp.o -c $(PTP)ptp_single_process.c $(LDLIBS2)


net_init.o:
	$(CC) -o $(INIT_CFG)net_init.o -c $(INIT_CFG)net_init.c $(LDLIBS2)

basic_cfg.o:
	$(CC) -o $(BASIC_CFG)basic_cfg.o -c $(BASIC_CFG)basic_cfg.c $(LDLIBS2)

local_cfg.o:
	$(CC) -o $(LOCAL_CFG)local_cfg.o -c $(LOCAL_CFG)local_cfg.c $(LDLIBS2)

remote_cfg.o:
	$(CC) -o $(REMOTE_CFG)remote_cfg.o -c $(REMOTE_CFG)remote_cfg.c $(LDLIBS2)


state_monitor.o:
	$(CC) -o $(STATEMON)state_monitor.o -c $(STATEMON)state_monitor.c $(LDLIBS2)

arp_proxy.o:
	$(CC) -o $(ARP)arp_proxy.o -c $(ARP)arp_proxy.c $(LDLIBS2)

clean:
	rm -rf tsnlight $(PTP)*.o $(INIT_CFG)*.o $(BASIC_CFG)*.o $(LOCAL_CFG)*.o $(REMOTE_CFG)*.o $(STATEMON)*.o $(ARP)*.o $(LIBSRC)*.o $(CNCAPI)*.a 
