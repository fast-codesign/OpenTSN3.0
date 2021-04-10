
CC=gcc -g
AR=ar

LDHDPATH = -I ./include 
LDLIBS =-lm -lpcap

LIBSRC=./src/


all: clean libcnc_api.a

libcnc_api.a:
	$(CC) -o $(LIBSRC)data_rec_engine.o -c $(LIBSRC)data_rec_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)data_send_engine.o -c $(LIBSRC)data_send_engine.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)tsmp_protocol.o -c $(LIBSRC)tsmp_protocol.c $(LDLIBS) $(LDHDPATH)

	$(CC) -o $(LIBSRC)reg_cfg.o -c $(LIBSRC)reg_cfg.c $(LDLIBS) $(LDHDPATH)
	$(CC) -o $(LIBSRC)beacon_report.o -c $(LIBSRC)beacon_report.c $(LDLIBS) $(LDHDPATH)

	ar -rc libcnc_api.a $(LIBSRC)data_rec_engine.o $(LIBSRC)data_send_engine.o $(LIBSRC)tsmp_protocol.o $(LIBSRC)reg_cfg.o $(LIBSRC)beacon_report.o

clean:
	rm -rf $(LIBSRC)*.o *.a 
	
