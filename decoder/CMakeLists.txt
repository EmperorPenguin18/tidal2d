use_native_compiler()

file(GLOB_RECURSE decoder_sources *.c)

add_executable(decoder ${decoder_sources})

fetch_header(decoder stb stb_image.h /usr/include/stb https://github.com/nothings/stb ae721c50eaf761660b4f90cc590453cdb0c2acd0 "") # Commit Feb 13, 2024
fetch_header(decoder nanosvg nanosvgrast.h /usr/include/nanosvg https://github.com/memononen/nanosvg 93ce879dc4c04a3ef1758428ec80083c38610b1f "src") # Commit Dec 29, 2023
fetch_header(decoder dr_wav dr_wav.h /usr/include https://github.com/mackron/dr_libs da35f9d6c7374a95353fd1df1d394d44ab66cf01 "") # Commit Feb 26, 2024

# Platform linking
if (CMAKE_SYSTEM_NAME MATCHES Linux)
	target_link_libraries(decoder PRIVATE m)
endif()
