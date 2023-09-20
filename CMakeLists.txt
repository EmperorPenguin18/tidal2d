cmake_minimum_required(VERSION 3.15)
project(tidalpp)

option(STATIC "Build the game to work as a single binary" OFF)
message(STATUS "Static build: ${STATIC}")

if (STATIC)
	set(BUILD_SHARED_LIBS OFF)
	set(BUILD_STATIC_LIBS ON)
else()
	set(BUILD_SHARED_LIBS ON)
	set(BUILD_STATIC_LIBS OFF)
endif()

add_executable(tidalpp)

target_sources(tidalpp PRIVATE src/actions.c src/assets.c src/common.c src/engine.c src/filesystem.c src/fonts.c src/instance.c src/main.c src/physics.c src/zpl.c)

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

# Physac dependency
find_path(
	PHYSAC_INCLUDE_DIR
	NAMES "physac.h"
	PATHS "/usr/include"
)
message(STATUS "${PHYSAC_INCLUDE_DIR}")
if (PHYSAC_INCLUDE_DIR)
	target_include_directories(tidalpp PRIVATE ${PHYSAC_INCLUDE_DIR})
else()
	FetchContent_Declare(
		physac
		GIT_REPOSITORY https://github.com/victorfisac/Physac
		GIT_TAG 9f7d175437c053dbf380716bb8dfd878acb81d4a # Commit Jul 23 2022
	)
	FetchContent_GetProperties(physac)
	if(NOT physac_POPULATED)
		FetchContent_Populate(physac)
		target_include_directories(tidalpp PRIVATE "${physac_SOURCE_DIR}/src")
	endif()
endif()

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
