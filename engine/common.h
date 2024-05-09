#ifndef __COMMON_H__

#include <stdlib.h>
#include <string.h>

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

#define DATA_LOOP(offset, ...) \
	offset = 0; \
	for (int i = 0; data_info[i];) { \
		size_t len = strlen(data_info+i)+1; \
		size_t size = \
			((size_t)data_info[i+len+0] << 0*8) | \
			((size_t)data_info[i+len+1] << 1*8) | \
			((size_t)data_info[i+len+2] << 2*8) | \
			((size_t)data_info[i+len+3] << 3*8) | \
			((size_t)data_info[i+len+4] << 4*8) | \
			((size_t)data_info[i+len+5] << 5*8) | \
			((size_t)data_info[i+len+6] << 6*8) | \
			((size_t)data_info[i+len+7] << 7*8); \
		unsigned char padding = (size % 4 == 0) ? 0 : 4 - (size % 4); \
		__VA_ARGS__ \
		offset += size + padding; \
		i += len + 8; \
	}

#define MIN(one, two) \
	(one < two) ? one : two

#endif
