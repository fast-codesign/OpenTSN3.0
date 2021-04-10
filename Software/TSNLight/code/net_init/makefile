
CC=gcc -g
AR=ar

LDLIBS  = -I ../cnc_api/include/ -L ../cnc_api/ -lcnc_api -lpthread -lm -lpcap
LDLIBS  += -I /usr/local/include/libxml2/ -lxml2

init:net_init.c 
	gcc -o init net_init.c parse_offline_plan_file.c $(LDLIBS) 
	

clean:
	rm -f init libcnc_api.a