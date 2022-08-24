build: src/*.c
	gcc -g -Og -D DEBUG -l SDL2 -l physfs -l cjson -l SDL2_ttf -l chipmunk -l SDL2_mixer src/*.c -o tidalpp

release: src/*.c
	gcc -O3 -l SDL2 -l physfs -l cjson -l SDL2_ttf -l chipmunk -l SDL2_mixer src/*.c -o tidalpp

install: src/*.h tidalpp
	mkdir -p /usr/include/tidal
	mkdir -p /usr/bin
	cp src/*.h /usr/include/tidal/
	mv tidalpp /usr/bin/tidalpp

clean:
	rm -f tidalpp
