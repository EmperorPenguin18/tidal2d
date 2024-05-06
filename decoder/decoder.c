#include "common.h"

#include <stdio.h>

void* extension_handler(const char* filename);

static const char* basename(const char* filename) {
	return strrchr(filename, '/')+1;
}

int main(int argc, char** argv) {
	FILE* out = fopen("data.c", "w");
	CHECK_ERROR(out, "data.c failed to open");
	//TODO extension sorting
	fputs("extern const unsigned char data_array[];\nconst unsigned char data_array[] = {\n", out);
	for (size_t i = 1; i < argc; i++) {
		void* buf = extension_handler(argv[i]);
		if (!buf) continue;
		//TODO output xxd-style
		free(buf);
	}
	fputs("};\n", out);
	//TODO file table
	return EXIT_SUCCESS;
}
