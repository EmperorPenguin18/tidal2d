#include "common.h"

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <assert.h>

typedef struct file_table {
	const char* name;
	size_t size;
} file_table;

typedef enum mode {
	C,
	ASM
} mode;

#define B_IN_SZ sizeof(size_t)/sizeof(unsigned char)

unsigned char* extension_handler(const char*, size_t*);

static bool validate_ext(const char* ext) {
	// there might be a more performant way to do this
	const char* s = valid_extensions[0];
	do
		if (strcmp(s, ext) == 0) return true;
	while ((s = strchr(s, '\0')+1));
	return false;
}

// needed to keep all images together
static int ext_cmp(const char* ext1, const char* ext2) {
	static const struct {
		const char* ext;
		int val;
	} map[] = {
		{"bmp", 0},
		{"jpg", 0},
		{"png", 0},
		{"svg", 0},
		{"ttf", 1},
		{"wav", 2},
		{"ogg", 2},
		{"lua", 3},
		{"ase", 0},
		{"aseprite", 0},
		{NULL, -1}
	};
	int val1 = 0, val2 = 0;
	for (int i = 0; map[i].ext; i++) {
		if (strcmp(ext1, map[i].ext) == 0) val1 = map[i].val;
		if (strcmp(ext2, map[i].ext) == 0) val2 = map[i].val;
	}
	return val1 - val2;
}

// doing this hopefully improves cache coherency during runtime
static file_table* sort(const int argc, char** const argv) {
	file_table* ft = calloc(argc+1, sizeof(file_table)); // one extra for NULL-termination
	int count = 0;
	for (int i = 0; i < argc; i++) {
		if (!validate_ext(extension(argv[i]))) continue;
		ft[count].name = argv[i];
		count++;
	}
	ft[count].name = NULL;
	file_table temp;
	for (int i = 0; ft[i+1].name; i++) {
		for (int j = 0; ft[j+i+1].name; j++) {
			if (ext_cmp(extension(ft[j].name), extension(ft[j+1].name)) > 0) {
				temp = ft[j];
				ft[j] = ft[j+1];
				ft[j+1] = temp;
			}
		}
	}
	return ft;
}

// look for what the desired output lang is
static int args(const int argc, char** argv, mode* m) {
	int i;
	for (i = 1; i < argc; i++) {
		if (argv[i][0] != '-') break;
		if (argv[i][1] != 'o') break;
		int j;
		for (j = 2; j < strlen(argv[i]); j++) if (argv[i][j] != ' ') break;
		if (argv[i][j] == 'c') {
			*m = C;
		} else if (argv[i][j] == 's') {
			*m = ASM;
		} else break;
	}
	return i;
}

#define SWITCH_MODE(m, c, s) \
	switch (m) { \
		case C: \
			c; \
			break; \
		case ASM: \
			s; \
			break; \
		default: \
			break; \
	}

#define WRITE_CHECK(text, out) \
{ \
	int err = fputs(text, out); \
	/*CHECK_ERROR(err > 0, "couldn't write to file");*/ \
}

#define PRINT_BYTE(file, byte, m, lc) \
{ \
	if (lc % 12 == 0) { \
		SWITCH_MODE(m, \
			fprintf(out, "\n\t0x%02x, ", byte), \
			fprintf(out, "\n\t.byte 0x%02x", byte) \
		); \
		lc = 0; \
	} else { \
		SWITCH_MODE(m, \
			fprintf(file, "0x%02x, ", byte), \
			fprintf(file, ", 0x%02x", byte) \
		); \
	} \
	lc++; \
}

#define OPEN_FILE(m, out) \
	SWITCH_MODE(m, \
		out = fopen("data.c", "w"), \
		out = fopen("data.S", "w") \
	); \
	CHECK_ERROR(out, "output failed to open");

int main(int argc, char** argv) {
	mode m = 0;
	const int n = args(argc, argv, &m);
	file_table* ft = sort(argc-n, argv+n);
	CHECK_ERROR(ft, "file table failed to initialize");
	FILE* out; OPEN_FILE(m, out);
	SWITCH_MODE(m,
		WRITE_CHECK("extern const unsigned char data_array[];\n\nconst unsigned char data_array[] = {",
			out),
		WRITE_CHECK("\t.globl\tdata_array\n#if defined(__clang__)\n\t.data\n#else\n\t.section\t.rodata\n#endif\n#if defined(EMSCRIPTEN)\n\t.size\tdata_array, 0\n#endif\ndata_array:",
			out)
	);
	int lc = 0;
	for (int i = 0; ft[i].name; i++) {
		size_t size = 0;
		unsigned char* buf = extension_handler(ft[i].name, &size);
		ft[i].size = size;
		if (!buf) {
			assert(size == 0);
			continue;
		}
		for (size_t j = 0; j < size; j++) PRINT_BYTE(out, buf[j], m, lc);
		if (size % 4 != 0) { // padding for alignment
			for (size_t j = 0; j < 4 - (size % 4); j++) PRINT_BYTE(out, 0, m, lc);
		}
		free(buf);
	}
	PRINT_BYTE(out, 0, m, lc); // not sure if this helps
	SWITCH_MODE(m,
		WRITE_CHECK("\n};\n\nextern const unsigned char data_info[];\n\nconst unsigned char data_info[] = {",
			out),
		WRITE_CHECK("\n\t.globl\tdata_info\n#if defined(EMSCRIPTEN)\n\t.size\tdata_info, 0\n#endif\ndata_info:",
			out)
	);
	lc = 0;
	for (int i = 0; ft[i].name; i++) {
		for (int j = 0; j < strlen(ft[i].name)+1; j++) { // +1 for null byte
			PRINT_BYTE(out, ft[i].name[j], m, lc);
		}
		for (int j = 0; j < B_IN_SZ; j++)
			PRINT_BYTE(out, (uint8_t)((ft[i].size >> (j*8)) & 0xff), m, lc);
	}
	SWITCH_MODE(m,
		WRITE_CHECK("0x0\n};", out),
		PRINT_BYTE(out, 0, m, lc)
	);
	WRITE_CHECK("\n", out);
	CHECK_ERROR(!fclose(out), "couldn't close file");
	free(ft);
	return EXIT_SUCCESS;
}
