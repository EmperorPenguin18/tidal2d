#include "common.h"

#include <stdio.h>
#include <stdbool.h>

typedef struct file_table {
	const char* name;
	size_t size;
} file_table;

#define B_IN_SZ sizeof(size_t)/sizeof(unsigned char)

unsigned char* extension_handler(const char*, size_t*);

static bool validate_ext(const char* ext) {
	// there might be a more performant way to do this
	const char* s = valid_extensions[0];
	do
		if (strcmp(s, ext) == 0) return true;
	while (s = strchr(s, '\0')+1);
	return false;
}

// doing this hopefully improves cache coherency during runtime
static file_table* sort(const int argc, char** const argv) {
	file_table* ft = malloc(sizeof(file_table)*argc); // one extra for NULL-termination
	int count = 0;
	for (int i = 1; i < argc; i++) {
		if (!validate_ext(extension(argv[i]))) continue;
		ft[i-1].name = argv[i];
		count++;
	}
	ft[count].name = NULL;
	file_table temp;
	for (int i = 0; ft[i+1].name; i++) {
		for (int j = 0; ft[j+i+1].name; j++) {
			if (strcmp(extension(ft[j].name), extension(ft[j+1].name)) > 0) {
				temp = ft[j];
				ft[j] = ft[j+1];
				ft[j+1] = temp;
			}
		}
	}
	return ft;
}

#define LINE_BREAK(lc, out) \
	lc++; \
	if (lc % 12 == 0) { \
		fprintf(out, "\n  "); \
		lc = 0; \
	}

#define PRINT_BYTE(file, byte) \
	fprintf(file, "0x%02x, ", byte);

int main(int argc, char** argv) {
	FILE* out = fopen("data.c", "w");
	CHECK_ERROR(out, "data.c failed to open");
	file_table* ft = sort(argc, argv);
	CHECK_ERROR(ft, "file table failed to initialize");
	int err = fputs("extern const unsigned char data_array[];\n\nconst unsigned char data_array[] = {\n  ", out);
	CHECK_ERROR(err > 0, "couldn't write to file");
	int lc = 0;
	for (int i = 0; ft[i].name; i++) {
		size_t size = 0;
		unsigned char* buf = extension_handler(ft[i].name, &size);
		ft[i].size = size;
		if (!buf) continue;
		for (size_t j = 0; j < size; j++) {
			PRINT_BYTE(out, buf[j]);
			LINE_BREAK(lc, out);
		}
		if (size % 4 != 0) { // padding for alignment
			for (size_t j = 0; j < 4 - (size % 4); j++) {
				PRINT_BYTE(out, 0);
				LINE_BREAK(lc, out);
			}
		}
		free(buf);
	}
	err = fputs("\n};\n\nextern const unsigned char data_info[];\n\nconst unsigned char data_info[] = {\n  ", out);
	CHECK_ERROR(err > 0, "couldn't write to file");
	lc = 0;
	for (int i = 0; ft[i].name; i++) {
		for (int j = 0; j < strlen(ft[i].name)+1; j++) { // +1 for null byte
			PRINT_BYTE(out, ft[i].name[j]);
			LINE_BREAK(lc, out);
		}
		for (int j = 0; j < B_IN_SZ; j++) {
			PRINT_BYTE(out, (unsigned char)((ft[i].size >> (j*8)) & 0xff) );
			LINE_BREAK(lc, out);
		}
	}
	err = fputs("0x0\n};\n", out);
	CHECK_ERROR(err > 0, "couldn't write to file");
	free(ft);
	CHECK_ERROR(!fclose(out), "couldn't close file");
	return EXIT_SUCCESS;
}
