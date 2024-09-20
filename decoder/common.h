#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdlib.h>
#include <string.h>

#define CHECK_ERROR(var, msg) \
	if (!(var)) { \
		fprintf(stderr, "Failure: " #msg "\n"); \
		return EXIT_FAILURE; \
	}

static const char* valid_extensions[] = {
	"bmp",
	"jpg",
	"png",
	"svg",
	"ttf",
	"wav",
	"ogg",
	"ase",
	"aseprite",
	NULL,
};

static const char* extension(const char* filename) {
	return strrchr(filename, '.')+1;
}

/*static const char* basename(const char* filename) {
	return strrchr(filename, '/')+1;
}*/

#define REALLOC(var, size) \
	void* tmp = realloc(var, size); \
	if (!tmp) exit(EXIT_FAILURE); \
	var = tmp;

#endif
