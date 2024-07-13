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
	ASM,
	LLVM
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
		} else if (argv[i][j] == 'l') {
			*m = LLVM;
		} else break;
	}
	return i;
}

#define WRITE_CHECK(text, out, err) \
	err = fputs(text, out); \
	CHECK_ERROR(err > 0, "couldn't write to file");

#define LINE_BREAK(lc, out) \
	lc++; \
	if (lc % 12 == 0) { \
		fprintf(out, "\n  "); \
		lc = 0; \
	} \

#define PRINT_C_BYTE(file, byte) \
	fprintf(file, "0x%02x, ", byte);

static int mode_c(file_table* ft) {
	FILE* out = fopen("data.c", "w");
	CHECK_ERROR(out, "output failed to open");
	int err;
	WRITE_CHECK("extern const unsigned char data_array[];\n\nconst unsigned char data_array[] = {\n  ",
		out, err);
	int lc = 0;
	for (int i = 0; ft[i].name; i++) {
		size_t size = 0;
		unsigned char* buf = extension_handler(ft[i].name, &size);
		ft[i].size = size;
		if (!buf) {
			assert(size == 0);
			continue;
		}
		for (size_t j = 0; j < size; j++) {
			PRINT_C_BYTE(out, buf[j]);
			LINE_BREAK(lc, out);
		}
		if (size % 4 != 0) { // padding for alignment
			for (size_t j = 0; j < 4 - (size % 4); j++) {
				PRINT_C_BYTE(out, 0);
				LINE_BREAK(lc, out);
			}
		}
		free(buf);
	}
	WRITE_CHECK("0x0\n};\n\nextern const unsigned char data_info[];\n\nconst unsigned char data_info[] = {\n  ",
		out, err);
	lc = 0;
	for (int i = 0; ft[i].name; i++) {
		for (int j = 0; j < strlen(ft[i].name)+1; j++) { // +1 for null byte
			PRINT_C_BYTE(out, ft[i].name[j]);
			LINE_BREAK(lc, out);
		}
		for (int j = 0; j < B_IN_SZ; j++) {
			PRINT_C_BYTE(out, (uint8_t)((ft[i].size >> (j*8)) & 0xff) );
			LINE_BREAK(lc, out);
		}
	}
	WRITE_CHECK("0x0\n};\n", out, err);
	CHECK_ERROR(!fclose(out), "couldn't close file");
	return 0;
}

#define PRINT_S_BYTE(file, byte) \
	fprintf(file, "\t.byte\t%d\n", (char)byte);

static int mode_s(file_table* ft) {
	FILE* out = fopen("data.s", "w");
	CHECK_ERROR(out, "output failed to open");
	int err;
	WRITE_CHECK("\t.text\n\t.globl\tdata_array\n\t.section\t.rodata\n\t.align 32\n\t.type\tdata_array, @object\n",
	//WRITE_CHECK("\t.text\n\t.globl\tdata_array\n\t.section\t.rodata\n\t.align 32\n\t.type\tdata_array, @object\n\t.size\tdata_array, ",
		out, err);
	size_t total_size = 0;
	size_t info_size = 0;
	unsigned char** buffers = NULL;
	for (int i = 0; ft[i].name; i++) {
		size_t size = 0;
		REALLOC(buffers, (i+1)*sizeof(unsigned char*));
		buffers[i] = extension_handler(ft[i].name, &size);
		ft[i].size = size;
		if (!buffers[i]) {
			assert(size == 0);
			continue;
		}
		total_size += size + (ft[i].size % 4 != 0) ? 4 - (size % 4) : 0;
		info_size += strlen(ft[i].name)+1 + B_IN_SZ;
	}
	//fprintf(out, "%ld\ndata_array:\n", total_size);
	fprintf(out, "data_array:\n");
	for (int i = 0; ft[i].name; i++) {
		for (size_t j = 0; j < ft[i].size; j++) PRINT_S_BYTE(out, buffers[i][j]);
		if (ft[i].size % 4 != 0) { // padding for alignment
			for (size_t j = 0; j < 4 - (ft[i].size % 4); j++) PRINT_S_BYTE(out, 0);
		}
		free(buffers[i]);
	}
	free(buffers);
	WRITE_CHECK("\t.globl\tdata_info\n\t.align 32\n\t.type\tdata_info, @object\n",
	//WRITE_CHECK("\t.globl\tdata_info\n\t.align 32\n\t.type\tdata_info, @object\n\t.size\tdata_info, ",
		out, err);
	//fprintf(out, "%ld\ndata_info:\n", info_size);
	fprintf(out, "data_info:\n");
	for (int i = 0; ft[i].name; i++) {
		for (int j = 0; j < strlen(ft[i].name)+1; j++) { // +1 for null byte
			PRINT_S_BYTE(out, ft[i].name[j]);
		}
		for (int j = 0; j < B_IN_SZ; j++)
			PRINT_S_BYTE(out, (uint8_t)((ft[i].size >> (j*8)) & 0xff) );
	}
	PRINT_S_BYTE(out, 0);
	CHECK_ERROR(!fclose(out), "couldn't close file");
	return 0;
}

#define PRINT_L_BYTE(file, byte) \
	fprintf(file, "%d", byte);

static int mode_l(file_table* ft) {
	FILE* out = fopen("data.ll", "w");
	CHECK_ERROR(out, "output failed to open");
	int err = fputs("", out);
	CHECK_ERROR(err > 0, "couldn't write to file");
	//
	err = fputs("", out);
	CHECK_ERROR(err > 0, "couldn't write to file");
	//
	CHECK_ERROR(!fclose(out), "couldn't close file");
	return 0;
}

int main(int argc, char** argv) {
	mode m = 0;
	const int n = args(argc, argv, &m);
	file_table* ft = sort(argc-n, argv+n);
	CHECK_ERROR(ft, "file table failed to initialize");
	switch (m) {
		case C:
			if (mode_c(ft) != 0) return EXIT_FAILURE;
			break;
		case ASM:
			if (mode_s(ft) != 0) return EXIT_FAILURE;
			break;
		case LLVM:
			if (mode_l(ft) != 0) return EXIT_FAILURE;
			break;
		default:
			break;
	}
	free(ft);
	return EXIT_SUCCESS;
}
