#ifndef __COMMON_H__

#include <stdlib.h>
#include <string.h>

#include <minilua.h>

#define CHECK_ERROR(var, msg) \
	if (!var) { \
		fprintf(stderr, "Failure: " #msg "\n"); \
		return EXIT_FAILURE; \
	}

static const char* extension(const char* filename) {
	return strrchr(filename, '.')+1;
}

static const char* basename(const char* filename) {
	return strrchr(filename, '/')+1;
}

typedef struct engine {
	lua_State* L;
} engine;

#endif
