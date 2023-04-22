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
cp deps/sdl2/build/build/.libs/libSDL2.a lib/ || exit 1
cp deps/sdl2/build/build/.libs/libSDL2.so lib/ || \
cp deps/sdl2/build/build/.libs/SDL2.dll lib/ || \
exit 1
mkdir -p /usr/local/include/SDL2 && cp /$MSYSTEM/include/SDL2/* /usr/local/include/SDL2/ || exit 1

# Build PHYSFS
git clone --branch stable-3.0 https://github.com/icculus/physfs.git deps/physfs
cd deps/physfs
cmake -Bbuild \
  -DCMAKE_BUILD_TYPE=Release \
  -DPHYSFS_BUILD_TEST=FALSE -DPHYSFS_BUILD_STATIC=TRUE
cmake --build build --target all --target docs
make -C build install
cd ../../
cp deps/physfs/build/libphysfs.a lib/ || exit 1
cp deps/physfs/build/libphysfs.so lib/ || exit 1
cp deps/physfs/build/libphysfs.so /$MSYSTEM/bin/ || exit 1

# Build cJSON
git clone https://github.com/DaveGamble/cJSON.git deps/cjson
cd deps/cjson
cmake -B build -DENABLE_CJSON_UTILS=Off -DENABLE_CJSON_TEST=Off -DBUILD_SHARED_AND_STATIC_LIBS=On
make -C build
make -C build install
cd ../../
cp deps/cjson/build/libcjson.a lib/ || exit 1
cp deps/cjson/build/libcjson.so lib/ || exit 1
cp deps/cjson/build/libcjson.so /$MSYSTEM/bin/

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
cp deps/chipmunk/build/src/libchipmunk.a lib/ || exit 1
cp deps/chipmunk/build/src/libchipmunk.so lib/ || exit 1
cp deps/chipmunk/build/src/libchipmunk.so /$MSYSTEM/bin/

# Build SDL2 image
git clone --branch SDL2 https://github.com/libsdl-org/SDL_image deps/image
cd deps/image
cmake -B build -DBUILD_SHARED_LIBS=OFF -DSDL2IMAGE_SAMPLES=OFF
./configure --enable-static \
  --disable-jpg-shared \
  --disable-png-shared \
  --disable-stb-image \
  --disable-tif-shared \
  --disable-jxl-shared \
  --disable-webp-shared
make -C build
cd ../../
cp deps/image/build/libSDL2_image.a lib/ || exit 1
cd deps/image
git clean -fd
cmake -B build -DSDL2IMAGE_SAMPLES=OFF
./configure \
  --disable-jpg-shared \
  --disable-png-shared \
  --disable-stb-image \
  --disable-tif-shared \
  --disable-jxl-shared \
  --disable-webp-shared
make -C build
make -C build install
cd ../../
cp deps/image/build/libSDL2_image.so lib/ || exit 1
cp deps/image/build/libSDL2_image.so /$MSYSTEM/bin/

# Build asound
git clone https://github.com/alsa-project/alsa-lib deps/asound
cd deps/asound
autoreconf -fiv
CFLAGS+=" -flto-partition=none"
./configure --enable-shared=yes --enable-static=yes \
  --without-debug
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make
cd ../../

# Build genie
git config --global http.sslVerify false
git clone https://aur.archlinux.org/genie-git.git deps/genie
cd deps/genie
makepkg
cp src/GENie/bin/windows/genie.exe /usr/bin/ || exit 1
cd ../../

# Build SoLoud
git clone https://github.com/jarikomppa/soloud deps/soloud
cd deps/soloud
sed -i 's|#if defined(_MSC_VER)|#ifdef _WIN32|g' src/backend/sdl/soloud_sdl2_dll.c
#sed -i 's|WITH_WINMM = 1|WITH_WINMM = 0|g' genie.lua
cp ../sdl2/include/* include/
cd build
genie --with-sdl2-only gmake
cd gmake
sed -i 's|/DEF.*||g' SoloudDynamic.make
sed -i 's|libsoloud_static.a|libsoloud_static.a /ucrt64/lib/libdl.a|g' SoloudDynamic.make
make config=release SoloudDynamic
cd ../../
#ar r lib/libsoloud_static.a build/gmake/release/Release/SoloudDynamic/src/c_api/*.o
#cp ../asound/src/.libs/libasound.a ./
#ar -x libasound.a
#ar r lib/libsoloud_static.a *.o
cd ../../
cp deps/soloud/lib/libsoloud_static.a lib/libsoloud.a || exit 1
cp deps/soloud/lib/libsoloud.so lib/ || \
cp deps/soloud/lib/soloud.dll lib/ && cp deps/soloud/lib/soloud.dll /$MSYSTEM/bin/ || \
exit 1
mkdir -p /$MSYSTEM/include/soloud && cp deps/soloud/include/* /$MSYSTEM/include/ || exit 1

# Build SDL2 ttf
git clone --branch SDL2 https://github.com/libsdl-org/SDL_ttf deps/ttf
cd deps/ttf
sed -i 's|set(vendored_default FALSE)|set(vendored_default TRUE)|g' CMakeLists.txt
sed -i 's|SDL2TTF_ROOTPROJECT ON|SDL2TTF_ROOTPROJECT OFF|g' CMakeLists.txt
rm -rf external/*
git submodule update --init
cmake -B build
./configure --enable-static --enable-freetype-builtin --enable-harfbuzz-builtin
make -C build
make -C build install
cp /usr/local/lib/libSDL2_ttf.so /$MSYSTEM/bin/
cd ../../
cp deps/ttf/SDL_ttf.h /$MSYSTEM/include/SDL2/

# Build FontCache
git clone https://github.com/grimfang4/SDL_FontCache.git deps/font
cd deps/font
cp ../sdl2/include/*.h ./
cp ../ttf/*.h ./
cp ../ttf/build/*.a ./
cp ../ttf/build/external/freetype/*.a ./
cp ../ttf/build/libSDL2_ttf.* ./libSDL2_ttf.dll
cc -O3 -fPIC -shared SDL_FontCache.c -L./ -l SDL2 -l SDL2_ttf -o libSDL2_FontCache.so
cc -O3 -c -static SDL_FontCache.c
ar -x libfreetype.a
ar -x libSDL2_ttf.a
ar -crs libFontCache.a *.o
cd ../../
cp deps/font/libFontCache.a lib/ || exit 1
cp deps/font/libSDL2_FontCache.so lib/ || exit 1
cp deps/font/SDL_FontCache.h /$MSYSTEM/include/SDL2/ || exit 1

# Build openssl
git clone https://github.com/openssl/openssl deps/ssl
cd deps/ssl
./Configure
make
make install
cd ../../
cp deps/ssl/libcrypto.a lib/ || exit 1
cp deps/ssl/libcrypto.so lib/ || \
cp deps/ssl/libcrypto*.dll lib/ || \
exit 1
