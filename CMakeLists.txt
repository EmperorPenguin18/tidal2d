cmake_minimum_required(VERSION 3.28)
project(tidal2d C ASM)
include(FetchContent)

# More warnings
add_compile_options(-Wall -pedantic)
# For multi-configs like MSVC
set(CMAKE_CONFIGURATION_TYPES ${CMAKE_BUILD_TYPE})

# Helper function for header-only libs
function(fetch_header target name example path url tag repo_path)
	try_compile(
		result
		SOURCE_FROM_CONTENT test.c "#include <${example}>"
		CMAKE_FLAGS -DINCLUDE_DIRECTORIES=${path}
	)
	if (result)
		target_include_directories(${target} PRIVATE ${path})
	else()
		FetchContent_Declare(
			${name}
			GIT_REPOSITORY ${url}
			GIT_TAG ${tag}
			EXCLUDE_FROM_ALL
		)
		FetchContent_GetProperties(${name})
		if(NOT ${name}_POPULATED)
			FetchContent_MakeAvailable(${name})
		endif()
		target_include_directories(${target} PRIVATE "${${name}_SOURCE_DIR}/${repo_path}")
	endif()
endfunction()

# Cross compilation settings
set(HOST_SYSTEM_NAME ${CMAKE_SYSTEM_NAME} CACHE STRING "")
set(CURRENT_COMPILER "NATIVE")
set(NATIVE_C_COMPILER CMAKE_C_COMPILER)
set(HOST_C_COMPILER "")
set(CROSSCOMPILING ${CMAKE_CROSSCOMPILING})
if (NOT HOST_SYSTEM_NAME MATCHES ${CMAKE_SYSTEM_NAME})
	set(CROSSCOMPILING true)
	if (HOST_SYSTEM_NAME MATCHES Linux)
		# Nothing for now
	elseif (HOST_SYSTEM_NAME MATCHES Emscripten)
		set(HOST_C_COMPILER "emcc")
	elseif (HOST_SYSTEM_NAME MATCHES Windows)
		set(HOST_C_COMPILER "x86_64-w64-mingw32-gcc")
	elseif (HOST_SYSTEM_NAME MATCHES GBA)
		set(HOST_C_COMPILER "arm-none-eabi-gcc")
		set(HOST_C_FLAGS "-mthumb -DGBA")
	endif()
endif()

# Cross compilation macros
macro(use_host_compiler)
	if (CROSSCOMPILING AND ${CURRENT_COMPILER} STREQUAL "NATIVE")
		# Save current native flags
		set(NATIVE_C_FLAGS ${CMAKE_C_FLAGS} CACHE STRING "GCC flags for the native compiler." FORCE)

		# Change compiler
		set(CMAKE_SYSTEM_NAME ${HOST_SYSTEM_NAME})
		#set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
		set(CMAKE_C_COMPILER ${HOST_C_COMPILER})
		set(CMAKE_ASM_COMPILER ${HOST_C_COMPILER})
		set(CMAKE_C_FLAGS ${HOST_C_FLAGS})
		set(CURRENT_COMPILER "HOST" CACHE STRING "Which compiler we are using." FORCE)
	endif()
endmacro()
macro(use_native_compiler)
	if (${CURRENT_COMPILER} STREQUAL "HOST")
		# Save current host flags
		set(HOST_C_FLAGS ${CMAKE_C_FLAGS} CACHE STRING "GCC flags for the host compiler." FORCE)

		# Change compiler
		set(CMAKE_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
		#set(CMAKE_SYSTEM_PROCESSOR ${NATIVE_SYSTEM_PROCESSOR})
		set(CMAKE_C_COMPILER ${NATIVE_C_COMPILER})
		set(CMAKE_ASM_COMPILER ${NATIVE_C_COMPILER})
		set(CMAKE_C_FLAGS ${NATIVE_C_FLAGS})
		set(CURRENT_COMPILER "NATIVE" CACHE STRING "Which compiler we are using." FORCE)
	endif()
endmacro()

# Build decoder
add_subdirectory(decoder)

# List resource folder
set(resource_path "" CACHE STRING "")
if (NOT "${resource_path}" STREQUAL "")
	file(REAL_PATH ${resource_path} real_path)
	if (NOT IS_DIRECTORY ${real_path})
		message(SEND_ERROR "Resource path not found")
	endif()
	file(GLOB_RECURSE resource_files "${real_path}/*")
	foreach(resource IN LISTS resource_files)
		get_filename_component(FILE_EXTENSION ${resource} EXT)
		if(FILE_EXTENSION STREQUAL ".c")
			list(APPEND scripts ${resource})
		else()
			list(APPEND resources ${resource})
		endif()
	endforeach()
endif()

# Generate data array
set(data "data.S")
set(flag "s")
add_custom_command(
	OUTPUT ${data}
	COMMAND decoder
	ARGS -o${flag} -p${real_path}/ ${resources}
	DEPENDS decoder ${resources}
	)
add_custom_target(
	data
	DEPENDS ${data}
	)
set_source_files_properties(
	${data}
	PROPERTIES GENERATED TRUE
	)

# Allow for custom game titles
set(title "game" CACHE STRING "")

# Minimal html file
set(GENERATED_HTML "<!DOCTYPE html>
<html>
<head>
    <meta charset=\"utf-8\">
    <title>${title}</title>
    <style>
        body { margin: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: black; }
        canvas { width: 100%; height: auto; max-height: 100vh; }
    </style>
</head>
<body>
    <canvas id=\"canvas\"></canvas>
    <script>
        function resizeCanvas() {
            var canvas = document.getElementById('canvas');
            var aspectRatio = canvas.width / canvas.height;
            if (window.innerWidth / window.innerHeight > aspectRatio) {
                // window is wider than canvas aspect ratio
                canvas.style.height = '100vh';
                canvas.style.width = 'auto';
            } else {
                // window is taller than canvas aspect ratio
                canvas.style.width = '100vw';
                canvas.style.height = 'auto';
            }
        }
        window.addEventListener('resize', resizeCanvas);
        window.addEventListener('load', resizeCanvas);
    </script>
    {{{ SCRIPT }}}
</body>
</html>")

# Build game
add_subdirectory(engine)
