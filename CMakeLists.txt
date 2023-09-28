cmake_minimum_required(VERSION 3.15)
project(tidal2d)

option(STATIC "Build the game to work as a single binary" OFF)

if (CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
	set(STATIC ON)
endif()

message(STATUS "Static build: ${STATIC}")
message(STATUS "Platform: ${CMAKE_SYSTEM_NAME}")

if (STATIC)
	set(BUILD_SHARED_LIBS OFF)
	set(BUILD_STATIC_LIBS ON)
	set(BUILD_SHARED OFF CACHE BOOL "Don't build chipmunk shared")
	set(BUILD_STATIC ON CACHE BOOL "Build chipmunk static")
	set(LUA_ENABLE_SHARED OFF CACHE BOOL "Don't build Lua shared")
	if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
		set(CMAKE_EXE_LINKER_FLAGS "-static")
	endif()
else()
	set(BUILD_SHARED_LIBS ON)
	set(BUILD_STATIC_LIBS OFF)
	set(BUILD_SHARED ON CACHE BOOL "Build chipmunk shared")
	set(BUILD_STATIC OFF CACHE BOOL "Don't build chipmunk static")
	set(LUA_ENABLE_SHARED ON CACHE BOOL "Build Lua shared")
endif()

add_executable(tidal2d)

target_sources(tidal2d PRIVATE src/actions.c src/assets.c src/common.c src/engine.c src/events.c src/filesystem.c src/fonts.c src/instance.c src/main.c src/zpl.c)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-Wall")

include(FetchContent)

# Math dependency
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	target_link_libraries(tidal2d PRIVATE m)
endif()

# SDL2 dependency
if (CMAKE_SYSTEM_NAME STREQUAL "Emscripten")
	target_compile_options(tidal2d PRIVATE "-sUSE_SDL=2")
	target_link_options(tidal2d PRIVATE "-sUSE_SDL=2")
	target_link_options(tidal2d PRIVATE "-sALLOW_MEMORY_GROWTH")
	set_target_properties(tidal2d PROPERTIES SUFFIX ".html") # remove later
else()
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
		target_include_directories(tidal2d PRIVATE "${SDL_INCLUDE_DIR}")
		target_link_libraries(tidal2d PRIVATE SDL2 SDL2main)
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
			if (STATIC)
				set_target_properties(SDL2-static PROPERTIES OUTPUT_NAME "SDL2")
			else()
				set_target_properties(SDL2 PROPERTIES OUTPUT_NAME "SDL2")
			endif()
			add_dependencies(tidal2d SDL2::SDL2)
			add_dependencies(tidal2d SDL2::SDL2main)
			target_include_directories(tidal2d PRIVATE "${sdl_BINARY_DIR}/include/SDL2")
			target_include_directories(tidal2d PRIVATE "${sdl_BINARY_DIR}/include-config-release/SDL2")
			target_include_directories(tidal2d PRIVATE "${sdl_BINARY_DIR}/include-config-debug/SDL2")
			target_include_directories(tidal2d PRIVATE "${sdl_SOURCE_DIR}/include/SDL2")
			target_link_directories(tidal2d PRIVATE ${sdl_BINARY_DIR})
		endif()
		if (CMAKE_BUILD_TYPE STREQUAL "Debug")
			target_link_libraries(tidal2d PRIVATE SDL2d SDL2maind)
		else()
			target_link_libraries(tidal2d PRIVATE SDL2 SDL2main)
		endif()
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
		if (NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")
			file(READ "${chipmunk_SOURCE_DIR}/src/cpHastySpace.c" TEXT)
			string(REPLACE "#include <sys/sysctl.h>" "" TEXT "${TEXT}")
			file(WRITE "${chipmunk_SOURCE_DIR}/src/cpHastySpace.c" "${TEXT}")
		endif()
		set(BUILD_DEMOS OFF CACHE BOOL "Don't build demos")
		add_subdirectory(${chipmunk_SOURCE_DIR} ${chipmunk_BINARY_DIR} EXCLUDE_FROM_ALL)
		if (STATIC)
			add_dependencies(tidal2d chipmunk_static)
		else()
			add_dependencies(tidal2d chipmunk)
		endif()
		target_include_directories(tidal2d PRIVATE "${chipmunk_SOURCE_DIR}/include")
		target_link_directories(tidal2d PRIVATE "${chipmunk_BINARY_DIR}/src")
	endif()
endif()
target_link_libraries(tidal2d PRIVATE chipmunk)

# Stb dependency
find_path(
	STB_INCLUDE_DIR
	NAMES "stb_image.h"
	PATHS "/usr/include/stb"
)
message(STATUS "${STB_INCLUDE_DIR}")
if (STB_INCLUDE_DIR)
	target_include_directories(tidal2d PRIVATE ${STB_INCLUDE_DIR})
else()
	FetchContent_Declare(
		stb
		GIT_REPOSITORY https://github.com/nothings/stb
		GIT_TAG 5736b15f7ea0ffb08dd38af21067c314d6a3aae9 # Commit Jan 29 2023
	)
	FetchContent_GetProperties(stb)
	if(NOT stb_POPULATED)
		FetchContent_Populate(stb)
		target_include_directories(tidal2d PRIVATE ${stb_SOURCE_DIR})
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
	target_include_directories(tidal2d PRIVATE ${NANOSVG_INCLUDE_DIR})
else()
	FetchContent_Declare(
		nanosvg
		GIT_REPOSITORY https://github.com/memononen/nanosvg
		GIT_TAG 9da543e8329fdd81b64eb48742d8ccb09377aed1 # Commit Dec 4 2022
	)
	FetchContent_GetProperties(nanosvg)
	if(NOT nanosvg_POPULATED)
		FetchContent_Populate(nanosvg)
		target_include_directories(tidal2d PRIVATE "${nanosvg_SOURCE_DIR}/src")
	endif()
endif()

# Lua dependency
find_path(
	LUA_INCLUDE_DIR
	NAMES "lua.h"
	PATHS "/usr/include"
)
message(STATUS "${LUA_INCLUDE_DIR}")
find_library(LUA_LIB "lua" "/usr/lib")
message(STATUS "${LUA_LIB}")
if (LUA_INCLUDE_DIR AND LUA_LIB AND (NOT STATIC))
	message(STATUS "Using system Lua lib")
else()
	FetchContent_Declare(
		lua
		GIT_REPOSITORY https://github.com/walterschell/Lua
		GIT_TAG 88246d621abf7b6fba9332f49229d507f020e450 # Commit Aug 8 2023
	)
	FetchContent_GetProperties(lua)
	if(NOT lua_POPULATED)
		FetchContent_Populate(lua)
		add_subdirectory(${lua_SOURCE_DIR} ${lua_BINARY_DIR} EXCLUDE_FROM_ALL)
		if (STATIC)
			set_target_properties(lua_static PROPERTIES OUTPUT_NAME "lua")
		else()
			set_target_properties(lua_shared PROPERTIES OUTPUT_NAME "lua")
		endif()
		add_dependencies(tidal2d Lua::Library)
		target_include_directories(tidal2d PRIVATE "${lua_SOURCE_DIR}/lua-5.4.6/include")
		target_link_directories(tidal2d PRIVATE "${lua_BINARY_DIR}/lua-5.4.6")
	endif()
endif()
target_link_libraries(tidal2d PRIVATE lua)

install(TARGETS tidal2d DESTINATION bin)
