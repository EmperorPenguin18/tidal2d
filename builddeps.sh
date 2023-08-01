#!/bin/bash

rm -rf deps
mkdir deps
rm -f lib/*
mkdir -p lib

# Build SDL2
git clone --branch SDL2 https://github.com/libsdl-org/SDL deps/sdl2
cd deps/sdl2
mkdir build
cd build
../configure --enable-static --disable-hidapi
make
make install
cd ../../../
mkdir -p /usr/local/include/SDL2 && cp /$MSYSTEM/include/SDL2/* /usr/local/include/SDL2/
cp deps/sdl2/build/build/.libs/libSDL2.a lib/ || exit 1
cp deps/sdl2/build/build/.libs/libSDL2.so lib/ || \
cp deps/sdl2/build/build/.libs/SDL2.dll lib/ || \
exit 1

# Build Chipmunk2D
git clone https://github.com/slembcke/Chipmunk2D deps/chipmunk
cd deps/chipmunk
cmake -B build -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_DEMOS=OFF \
      -DCMAKE_C_FLAGS="-DCHIPMUNK_FFI" \
      -DBUILD_STATIC=ON
sed -i 's|C:|/c|g' build/src/CMakeFiles/chipmunk.dir/compiler_depend.make
sed -i 's|D:|/d|g' build/src/CMakeFiles/chipmunk.dir/compiler_depend.make
sed -i 's|C:|/c|g' build/src/CMakeFiles/chipmunk_static.dir/compiler_depend.make
sed -i 's|D:|/d|g' build/src/CMakeFiles/chipmunk_static.dir/compiler_depend.make
make -C build
make -C build install
cd ../../
cp deps/chipmunk/build/src/libchipmunk.so /$MSYSTEM/bin/
cp deps/chipmunk/build/src/libchipmunk.a lib/ || exit 1
cp deps/chipmunk/build/src/libchipmunk.so lib/ || exit 1

# Build Lua

