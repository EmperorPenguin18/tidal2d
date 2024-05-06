#ifndef __COMMON_H__

#include <stdlib.h>
#include <string.h>

#define CHECK_ERROR(var, msg) \
	if (!var) { \
		fprintf(stderr, "Failure: " #msg "\n"); \
		return EXIT_FAILURE; \
	}

#endif
