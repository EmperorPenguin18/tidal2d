ifeq ($(STATIC),1)
	OPTS = -D STATIC -static -lSDL2 -lchipmunk
else
	OPTS = 
endif

COMMON = $(OPTS) -lm -I./ -I/usr/local/include -Llib

build: src/*.c
	gcc -g -Og -o tidalpp src/*.c src/*.S -D DEBUG -Wall $(COMMON)

release: src/*.c
	gcc -O3 -o tidalpp src/*.c src/*.S $(COMMON)

install: src/*.h tidalpp
	mkdir -p /usr/include/tidal
	mkdir -p /usr/bin
	cp src/*.h /usr/include/tidal/
	mv tidalpp /usr/bin/tidalpp

clean:
	rm -f tidalpp
	rm -rf deps
	rm -rf lib
