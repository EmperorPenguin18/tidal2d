#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdlib.h>
#include <string.h>
#ifdef _WIN32
#include <windows.h>
#endif

#define CHECK_ERROR(var, msg) \
	if (!var) { \
		fprintf(stderr, "Failure: " #msg "\n"); \
		return EXIT_FAILURE; \
	}

static const char* basename(const char* filename) {
	return strrchr(filename, '/')+1;
}

#define DATA_LOOP(offset, ...) \
	offset = 0; \
	for (int i = 0; data_info[i];) { \
		const size_t len = strlen(data_info+i)+1; \
		const uint64_t size = *(uint64_t*)(data_info+i+len); \
		const uint8_t padding = (size % 4 == 0) ? 0 : 4 - (size % 4); \
		__VA_ARGS__ \
		offset += size + padding; \
		i += len + 8; \
	}

#define MIN(one, two) \
	(one < two) ? one : two

#endif
