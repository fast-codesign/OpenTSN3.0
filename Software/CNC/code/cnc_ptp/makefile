


CC=gcc -g
AR=ar


LDLIBS  = -I../cnc_api/include -L../cnc_api/ -lcnc_api -lpthread -lm -lpcap

LIBSRC  = ./libptp/


all: clean cnc_ptp

cnc_ptp: main.c libptpl.a
	$(CC) -o cnc_ptp main.c -L ./ -lptpl $(LDLIBS) 

libptpl.a:
	$(CC) -o $(LIBSRC)ptp.o -c $(LIBSRC)ptp.c $(LDLIBS)
	$(CC) -o $(LIBSRC)timer.o -c $(LIBSRC)timer.c $(LDLIBS)
	$(AR) -rc libptpl.a $(LIBSRC)ptp.o $(LIBSRC)timer.o
	
clean:
	rm -rf cnc_ptp libptpl.a $(LIBSRC)*.o