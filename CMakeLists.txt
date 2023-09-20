cmake_minimum_required(VERSION 3.15)
project(tidalpp)

option(STATIC "Build the game to work as a single binary" OFF)
message(STATUS "Static build: ${STATIC}")

if (STATIC)
	set(BUILD_SHARED_LIBS OFF)
	set(BUILD_STATIC_LIBS ON)
	set(BUILD_SHARED OFF CACHE BOOL "Don't build shared")
	set(BUILD_STATIC ON CACHE BOOL "Build static")
else()
	set(BUILD_SHARED_LIBS ON)
	set(BUILD_STATIC_LIBS OFF)
	set(BUILD_SHARED ON CACHE BOOL "Don't build shared")
	set(BUILD_STATIC OFF CACHE BOOL "Build static")
endif()

add_executable(tidalpp)

target_sources(tidalpp PRIVATE src/actions.c src/assets.c src/common.c src/engine.c src/filesystem.c src/fonts.c src/instance.c src/main.c src/zpl.c)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-Wall")

include(FetchContent)

# Math dependency
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	target_link_libraries(tidalpp PRIVATE m)
endif()

# SDL2 dependency
find_path(
	SDL_INCLUDE_DIR
	NAMES "SDL.h"
	PATHS "/usr/include/SDL2"
)
message(STATUS "${SDL_INCLUDE_DIR}")
find_library(SDL_LIB "SDL2" "/usr/lib")
message(STATUS "${SDL_LIB}")
if (SDL_INCLUDE_DIR AND SDL_LIB AND (NOT STATIC))
	message(STATUS "Using system SDL2 lib")
	target_link_libraries(tidalpp PRIVATE SDL2 SDL2main)
else()
	FetchContent_Declare(
		SDL
		GIT_REPOSITORY https://github.com/libsdl-org/SDL
		GIT_TAG 8a5ba43d00252c6c8b33c9aa4f1048222955ab4d # 2.28.3
	)
	FetchContent_GetProperties(SDL)
	if(NOT SDL_POPULATED)
		FetchContent_Populate(SDL)
		file(READ "${sdl_SOURCE_DIR}/src/video/x11/SDL_x11xinput2.h" TEXT)
		string(REPLACE "typedef struct XGenericEventCookie XGenericEventCookie;" "" TEXT "${TEXT}")
		file(WRITE "${sdl_SOURCE_DIR}/src/video/x11/SDL_x11xinput2.h" "${TEXT}")
		set(SDL_TEST OFF CACHE BOOL "Don't build test")
		add_subdirectory(${sdl_SOURCE_DIR} ${sdl_BINARY_DIR} EXCLUDE_FROM_ALL)
		if (NOT STATIC)
			set_target_properties(SDL2 PROPERTIES OUTPUT_NAME "SDL2")
		endif()
		add_dependencies(tidalpp SDL2::SDL2)
		add_dependencies(tidalpp SDL2::SDL2main)
		target_include_directories(tidalpp PRIVATE "${sdl_BINARY_DIR}/include")
		target_include_directories(tidalpp PRIVATE "${sdl_BINARY_DIR}/include-config-release/SDL2")
		target_include_directories(tidalpp PRIVATE "${sdl_BINARY_DIR}/include-config-debug/SDL2")
		target_include_directories(tidalpp PRIVATE "${sdl_SOURCE_DIR}/include")
		target_link_directories(tidalpp PRIVATE ${sdl_BINARY_DIR})
	endif()
	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		target_link_libraries(tidalpp PRIVATE SDL2d SDL2maind)
	else()
		target_link_libraries(tidalpp PRIVATE SDL2 SDL2main)
	endif()
endif()

# Chipmunk2D dependency
find_path(
	CHIPMUNK_INCLUDE_DIR
	NAMES "chipmunk.h"
	PATHS "/usr/include/chipmunk"
)
message(STATUS "${CHIPMUNK_INCLUDE_DIR}")
find_library(CHIPMUNK_LIB "chipmunk" "/usr/lib")
message(STATUS "${CHIPMUNK_LIB}")
if (CHIPMUNK_INCLUDE_DIR AND CHIPMUNK_LIB AND (NOT STATIC))
	message(STATUS "Using system chipmunk lib")
else()
	FetchContent_Declare(
		chipmunk
		GIT_REPOSITORY https://github.com/slembcke/Chipmunk2D
		GIT_TAG 87340c216bf97554dc552371bbdecf283f7c540e # 7.0.3
	)
	FetchContent_GetProperties(chipmunk)
	if(NOT chipmunk_POPULATED)
		FetchContent_Populate(chipmunk)
		file(READ "${chipmunk_SOURCE_DIR}/src/cpHastySpace.c" TEXT)
		string(REPLACE "#include <sys/sysctl.h>" "" TEXT "${TEXT}")
		file(WRITE "${chipmunk_SOURCE_DIR}/src/cpHastySpace.c" "${TEXT}")
		set(BUILD_DEMOS OFF CACHE BOOL "Don't build demos")
		add_subdirectory(${chipmunk_SOURCE_DIR} ${chipmunk_BINARY_DIR} EXCLUDE_FROM_ALL)
		if (STATIC)
			add_dependencies(tidalpp chipmunk_static)
		else()
			add_dependencies(tidalpp chipmunk)
		endif()
		target_include_directories(tidalpp PRIVATE "${chipmunk_SOURCE_DIR}/include")
		target_link_directories(tidalpp PRIVATE "${chipmunk_BINARY_DIR}/src")
	endif()
endif()
target_link_libraries(tidalpp PRIVATE chipmunk)

# Stb dependency
find_path(
	STB_INCLUDE_DIR
	NAMES "stb_image.h"
	PATHS "/usr/include/stb"
)
message(STATUS "${STB_INCLUDE_DIR}")
if (STB_INCLUDE_DIR)
	target_include_directories(tidalpp PRIVATE ${STB_INCLUDE_DIR})
else()
	FetchContent_Declare(
		stb
		GIT_REPOSITORY https://github.com/nothings/stb
		GIT_TAG 5736b15f7ea0ffb08dd38af21067c314d6a3aae9 # Commit Jan 29 2023
	)
	FetchContent_GetProperties(stb)
	if(NOT stb_POPULATED)
		FetchContent_Populate(stb)
		target_include_directories(tidalpp PRIVATE ${stb_SOURCE_DIR})
	endif()
endif()

# nanoSVG dependency
find_path(
	NANOSVG_INCLUDE_DIR
	NAMES "nanosvgrast.h"
	PATHS "/usr/include/nanosvg"
)
message(STATUS "${NANOSVG_INCLUDE_DIR}")
if (NANOSVG_INCLUDE_DIR)
	target_include_directories(tidalpp PRIVATE ${NANOSVG_INCLUDE_DIR})
else()
	FetchContent_Declare(
		nanosvg
		GIT_REPOSITORY https://github.com/memononen/nanosvg
		GIT_TAG 9da543e8329fdd81b64eb48742d8ccb09377aed1 # Commit Dec 4 2022
	)
	FetchContent_GetProperties(nanosvg)
	if(NOT nanosvg_POPULATED)
		FetchContent_Populate(nanosvg)
		target_include_directories(tidalpp PRIVATE ${nanosvg_SOURCE_DIR})
	endif()
endif()

#find_package(Lua REQUIRED)
#find_package(Emscripten REQUIRED)

install(TARGETS tidalpp DESTINATION bin)
