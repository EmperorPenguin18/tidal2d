#include "common.h"

#include <stb_vorbis.c>
#include <stb_image.h>
#include <stb_truetype.h>
#include <nanosvgrast.h>

static const unsigned char* (*handlers[])(void*, const size_t) = {
};

#define FSIZE(fp, sz) \
	fseek(fp, 0L, SEEK_END); \
	sz = ftell(fp); \
	fseek(fp, 0L, SEEK_SET);

unsigned char* extension_handler(const char* filename, size_t* size) {
	for (int i = 0; valid_extensions[i]; i++) {
		if (strcmp(extension(filename), valid_extensions[i]) == 0) {
			unsigned char* out = NULL;
			FILE* fp = fopen(filename, "rb");
			if (fp) {
				FSIZE(fp, *size);
				out = malloc(*size);
				size_t err = fread(out, 1, *size, fp);
				if (err != *size) fprintf(stderr, "Failure: didn't read file correctly\n");
				fclose(fp);
			}
			return out;
		}
	}
	fprintf(stderr, "Failure: tried to load unsupported file type\n");
	return NULL;
}
