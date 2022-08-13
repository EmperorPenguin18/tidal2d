build: src/*.cc
	g++ -g -Og -D DEBUG src/*.cc -o tidalpp

release: src/*.cc
	g++ -O3 src/*.cc -o tidalpp

install: src/*.h tidalpp
	mkdir -p /usr/include/tidal
	mkdir -p /usr/bin
	cp src/*.h /usr/include/tidal/
	mv tidalpp /usr/bin/tidalpp

clean:
	rm -f tidalpp
