use_host_compiler()

set_source_files_properties(
	"pch.c"
	PROPERTIES
	COMPILE_OPTIONS "-w"
)

add_executable(${title} engine.c actions.c pch.c ${CMAKE_BINARY_DIR}/${data})
add_dependencies(${title} data)
list(LENGTH scripts NMOD)
target_compile_definitions(${title} PRIVATE NMOD=${NMOD})

foreach(script ${scripts})
	get_filename_component(scriptname ${script} NAME)
	add_library(${scriptname} OBJECT wrapper.c)
	target_link_libraries(${title} PRIVATE ${scriptname})
	target_compile_definitions(${scriptname} PRIVATE FILENAME="${script}")
	add_custom_target(force_rebuild ALL
		DEPENDS ${script}
	)
	add_dependencies(${scriptname} force_rebuild)
endforeach(script ${scripts})

fetch_header(${title} sokol sokol_gfx.h /usr/include https://github.com/floooh/sokol 55bc9cf3fa4051d485d10412c75c893c3135e885 "") # Commit May 6, 2024
fetch_header(${title} sokol sokol_gl.h /usr/include https://github.com/floooh/sokol 55bc9cf3fa4051d485d10412c75c893c3135e885 "util") # Commit May 6, 2024
fetch_header(${title} sokol_gp sokol_gp.h /usr/include https://github.com/edubart/sokol_gp a6ce39f93fb2da2c47b70cdd4d1c0a35c0e756ef "") # Commit Mar 22, 2024
fetch_header(${title} physac physac.h /usr/include https://github.com/victorfisac/Physac 999bc37eccdde91e8b1cc34b2fb00ce702a14928 "src") # Commit Aug 17, 2024
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
	file(WRITE "${CMAKE_BINARY_DIR}/shell.html" "${GENERATED_HTML}")
	set_target_properties(${title} PROPERTIES
		LINK_FLAGS "--shell-file ${CMAKE_BINARY_DIR}/shell.html"
	)
	target_link_options(${title} PRIVATE "-sFULL_ES3")
	target_link_options(${title} PRIVATE "-sTOTAL_MEMORY=67108864")
	#target_link_options(${title} PRIVATE "-sALLOW_MEMORY_GROWTH")
	install(FILES ${CMAKE_BINARY_DIR}/engine/index.wasm DESTINATION .)
	install(FILES ${CMAKE_BINARY_DIR}/engine/index.js DESTINATION .)
elseif(CMAKE_SYSTEM_NAME MATCHES Windows)
	set_target_properties(${title} PROPERTIES SUFFIX ".exe")
	target_link_options(${title} PRIVATE "-static")
	target_compile_options(${title} PRIVATE "-mwin32")
	target_link_options(${title} PRIVATE "-mwindows")
	target_link_libraries(${title} PRIVATE ole32)
elseif(CMAKE_SYSTEM_NAME MATCHES Darwin)
	enable_language(OBJC)
	set_source_files_properties(
		"pch.c"
		PROPERTIES
		LANGUAGE OBJC
	)
	target_link_libraries(${title} PRIVATE "-framework Foundation")
	target_link_libraries(${title} PRIVATE "-framework Cocoa")
	target_link_libraries(${title} PRIVATE "-framework QuartzCore")
	target_link_libraries(${title} PRIVATE "-framework OpenGL")
	target_link_libraries(${title} PRIVATE "-framework AudioToolbox")
elseif(CMAKE_SYSTEM_NAME MATCHES GBA)
	set_target_properties(${title} PROPERTIES SUFFIX ".gba")
	add_custom_command(TARGET ${title} POST_BUILD
		COMMAND arm-none-eabi-objcopy -O binary ${title}.gba ${title}.gba
	)
	#add_custom_command(TARGET ${title} POST_BUILD
	#COMMAND gbafix ${title}.gba
	#)
endif()

# Output a zipped archive
install(TARGETS ${title} RUNTIME DESTINATION .)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
set(CPACK_GENERATOR "ZIP")
set(CPACK_PACKAGE_NAME "${title}")
set(CPACK_PACKAGE_VERSION "")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CMAKE_SYSTEM_NAME}")
include(CPack)
