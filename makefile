ifeq ($(STATIC),1)
OPTS = -D STATIC -static lib/*.o
else
OPTS = 
endif

build: src/*.c
	gcc -g -Og -D DEBUG -Wall -I./ $(OPTS) src/*.c -o tidalpp

release: src/*.c
	gcc -O3 -I./ $(OPTS) src/*.c -o tidalpp

install: src/*.h tidalpp
	mkdir -p /usr/include/tidal
	mkdir -p /usr/bin
	cp src/*.h /usr/include/tidal/
	mv tidalpp /usr/bin/tidalpp

clean:
	rm -f tidalpp
