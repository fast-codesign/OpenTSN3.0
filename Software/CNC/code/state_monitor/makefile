
CC=gcc -g
AR=ar

LDLIBS  = -I ../cnc_api/include/ -L ../cnc_api/ -lcnc_api -lpthread -lm -lpcap
LDLIBS  += -I /usr/local/include/libxml2/ -lxml2

monitor:state_monitor.c 
	gcc -o monitor state_monitor.c  $(LDLIBS) 
	

clean:
	rm -f monitor libcnc_api.a