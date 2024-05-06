#include "common.h"

#include <stb_vorbis.c>
#include <stb_image.h>
#include <stb_truetype.h>
#include <nanosvgrast.h>

static const char* extension(const char* filename) {
	return strrchr(filename, '.')+1;
}

void* extension_handler(const char* filename) {
	//TODO
	return NULL;
}
