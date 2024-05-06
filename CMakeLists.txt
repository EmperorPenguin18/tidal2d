cmake_minimum_required(VERSION 3.5)
project(tidal2d)
include(FetchContent)

file(GLOB_RECURSE decoder_sources decoder/*.c)

add_executable(decoder ${decoder_sources})

set(CMAKE_C_FLAGS_DEBUG_INIT "-Wall -pedantic")
set(CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE})

function(fetch_header target name example path url tag)
	find_path(
		${name}_INCLUDE_DIR
		NAMES "${example}"
		PATHS "${path}"
	)
	if (${name}_INCLUDE_DIR)
		target_include_directories(${target} PRIVATE ${${name}_INCLUDE_DIR})
	else()
		FetchContent_Declare(
			${name}
			GIT_REPOSITORY ${url}
			GIT_TAG ${tag}
		)
		FetchContent_GetProperties(${name})
		if(NOT ${name}_POPULATED)
			FetchContent_Populate(${name})
			target_include_directories(${target} PRIVATE ${${name}_SOURCE_DIR})
		endif()
	endif()
endfunction()

fetch_header(decoder stb stb_image.h /usr/include/stb https://github.com/nothings/stb ae721c50eaf761660b4f90cc590453cdb0c2acd0) # Commit Feb 13, 2024
fetch_header(decoder nanosvg nanosvgrast.h /usr/include/nanosvg https://github.com/memononen/nanosvg 93ce879dc4c04a3ef1758428ec80083c38610b1f) # Commit Dec 29, 2023

target_link_libraries(decoder PRIVATE m)

file(GLOB_RECURSE engine_sources engine/*.c)

add_custom_command(
	OUTPUT data.c
	COMMAND decoder
	DEPENDS decoder
	)

add_executable(engine ${engine_sources} data.c)
