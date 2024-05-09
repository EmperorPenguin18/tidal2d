cmake_minimum_required(VERSION 3.28)
project(tidal2d)
include(FetchContent)

file(GLOB_RECURSE decoder_sources decoder/*.c)

#CMAKE_CROSSCOMPILING?
add_executable(decoder ${decoder_sources})

set(CMAKE_C_FLAGS_DEBUG_INIT "-Wall -pedantic")
set(CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE})

function(fetch_header target name example path url tag repo_path)
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
			target_include_directories(${target} PRIVATE "${${name}_SOURCE_DIR}/${repo_path}")
		endif()
	endif()
endfunction()

fetch_header(decoder stb stb_image.h /usr/include/stb https://github.com/nothings/stb ae721c50eaf761660b4f90cc590453cdb0c2acd0 "") # Commit Feb 13, 2024
fetch_header(decoder nanosvg nanosvgrast.h /usr/include/nanosvg https://github.com/memononen/nanosvg 93ce879dc4c04a3ef1758428ec80083c38610b1f "src") # Commit Dec 29, 2023

# Platform linking
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	target_link_libraries(decoder PRIVATE m)
endif()

file(GLOB_RECURSE engine_sources engine/*.c)

set(resource_path "" CACHE STRING "")

if (NOT "${resource_path}" STREQUAL "")
	file(REAL_PATH ${resource_path} real_path)
	if (NOT IS_DIRECTORY ${real_path})
		message(SEND_ERROR "Resource path not found")
	endif()
	file(GLOB_RECURSE resources "${real_path}/*")
endif()

add_custom_command(
	OUTPUT data.c
	COMMAND decoder ${resources}
	DEPENDS decoder ${resources}
	)

set(title "game" CACHE STRING "")

add_executable(${title} ${engine_sources} data.c)

fetch_header(${title} sokol sokol_gfx.h /usr/include https://github.com/floooh/sokol 55bc9cf3fa4051d485d10412c75c893c3135e885 "") # Commit May 6, 2024
fetch_header(${title} sokol_gp sokol_gp.h /usr/include https://github.com/edubart/sokol_gp a6ce39f93fb2da2c47b70cdd4d1c0a35c0e756ef "") # Commit Mar 22, 2024
fetch_header(${title} physac physac.h /usr/include https://github.com/victorfisac/physac 29d9fc06860b54571a02402fff6fa8572d19bd12 "src") # Commit Dec 10, 2023
fetch_header(${title} minilua minilua.h /usr/include https://github.com/edubart/minilua 79a00fab1639517de38a372db9e60fd6cc730d69 "") # v5.4.6
fetch_header(${title} fontstash fontstash.h /usr/include https://github.com/memononen/fontstash b5ddc9741061343740d85d636d782ed3e07cf7be "src") # Commit Apr 22, 2019

# Platform linking
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	target_link_libraries(${title} PRIVATE X11)
	target_link_libraries(${title} PRIVATE Xi)
	target_link_libraries(${title} PRIVATE Xcursor)
	target_link_libraries(${title} PRIVATE GL)
	target_link_libraries(${title} PRIVATE m)
	target_link_libraries(${title} PRIVATE asound)
#elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
	#target_link_libraries(decoder PRIVATE m)
endif()
