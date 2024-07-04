use_host_compiler()

file(GLOB_RECURSE engine_sources *.c)

set_source_files_properties(
	"pch.c"
	PROPERTIES
	COMPILE_OPTIONS "-w"
)

add_executable(${title} ${engine_sources} ${CMAKE_BINARY_DIR}/data.c)
add_dependencies(${title} data)

fetch_header(${title} sokol sokol_gfx.h /usr/include https://github.com/floooh/sokol 55bc9cf3fa4051d485d10412c75c893c3135e885 "") # Commit May 6, 2024
fetch_header(${title} sokol sokol_gl.h /usr/include https://github.com/floooh/sokol 55bc9cf3fa4051d485d10412c75c893c3135e885 "util") # Commit May 6, 2024
fetch_header(${title} sokol_gp sokol_gp.h /usr/include https://github.com/edubart/sokol_gp a6ce39f93fb2da2c47b70cdd4d1c0a35c0e756ef "") # Commit Mar 22, 2024
fetch_header(${title} physac physac.h /usr/include https://github.com/EmperorPenguin18/physac c8f2816199cbd8559bc6529cac829e5cb02136ef "src") # My fork
fetch_header(${title} minilua minilua.h /usr/include https://github.com/edubart/minilua 79a00fab1639517de38a372db9e60fd6cc730d69 "") # v5.4.6
fetch_header(${title} fontstash fontstash.h /usr/include https://github.com/memononen/fontstash b5ddc9741061343740d85d636d782ed3e07cf7be "src") # Commit Apr 22, 2019
fetch_header(${title} glibc force_link_glibc_2.23.h /usr/include https://github.com/wheybags/glibc_version_header 60d54829f34f21dc440126ad5630e6a9789a48b2 "version_headers/x64") # Commit May 3, 2019

# Platform linking
if (CMAKE_SYSTEM_NAME MATCHES Linux)
	target_compile_options(${title} PRIVATE "-includeforce_link_glibc_2.23.h")
	target_link_libraries(${title} PRIVATE X11)
	target_link_libraries(${title} PRIVATE Xi)
	target_link_libraries(${title} PRIVATE Xcursor)
	target_link_libraries(${title} PRIVATE GL)
	target_link_libraries(${title} PRIVATE m)
	target_link_libraries(${title} PRIVATE asound)
elseif(CMAKE_SYSTEM_NAME MATCHES Emscripten)
	set_target_properties(${title} PROPERTIES OUTPUT_NAME "index")
	set_target_properties(${title} PROPERTIES SUFFIX ".html")
	#target_link_options(${title} PRIVATE "--shell-file ${CMAKE_SOURCE_DIR}/index.html")
	target_link_options(${title} PRIVATE "-sFULL_ES3")
	target_link_options(${title} PRIVATE "-sTOTAL_MEMORY=67108864")
	#target_link_options(${title} PRIVATE "-sALLOW_MEMORY_GROWTH")
elseif(CMAKE_SYSTEM_NAME MATCHES Windows)
	set_target_properties(${title} PROPERTIES SUFFIX ".exe")
	target_link_options(${title} PRIVATE "-static")
	target_compile_options(${title} PRIVATE "-mwin32")
	target_link_options(${title} PRIVATE "-mwindows")
	target_link_libraries(${title} PRIVATE ole32)
elseif(CMAKE_SYSTEM_NAME MATCHES Darwin)
	#target_link_libraries(${title} PRIVATE "-framework Foundation")
	target_link_libraries(${title} PRIVATE Cocoa)
	target_link_libraries(${title} PRIVATE QuartzCore)
	target_link_libraries(${title} PRIVATE OpenGL)
endif()

# Output a zipped archive
set(ZIP_FILE ${CMAKE_BINARY_DIR}/${title}_${HOST_SYSTEM_NAME}.tar.gz)
add_custom_command(
	TARGET ${title}
	POST_BUILD
	COMMAND ${CMAKE_COMMAND}
	ARGS -E tar "cfz" "${ZIP_FILE}" "$<TARGET_FILE:${title}>"
	)
