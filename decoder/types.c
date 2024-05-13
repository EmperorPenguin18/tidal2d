#include "common.h"

#include <stdint.h>

#include <stb_image.h>
#define STB_VORBIS_HEADER_ONLY
#include <stb_vorbis.c>
#include <nanosvgrast.h>

#define FSIZE(fp, sz) \
	fseek(fp, 0L, SEEK_END); \
	sz = ftell(fp); \
	fseek(fp, 0L, SEEK_SET);

static unsigned char* stb_handler(const char* filename, size_t* size) {
	int w, h, format;
	unsigned char* pixels = stbi_load(filename, &w, &h, &format, 4);
	*size = w*h*format;
	return pixels;
}

static unsigned char* svg_handler(const char* filename, size_t* size) {
	struct NSVGimage* image = nsvgParseFromFile(filename, "px", 96);
	if (!image) return NULL;
	struct NSVGrasterizer* rast = nsvgCreateRasterizer();
	*size = image->width*image->height*4;
	unsigned char* pixels = malloc(*size);
	nsvgRasterize(rast, image, 0, 0, 1, pixels, image->width, image->height, image->width*4);
	nsvgDeleteRasterizer(rast);
	nsvgDelete(image);
	return pixels;
}

static unsigned char* basic_handler(const char* filename, size_t* size) {
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

static void short_to_float(unsigned char* buffer, const size_t len) {
	for (size_t i = (len/2)-2; i != SIZE_MAX; i -= 1) {
		union {
			uint32_t u32;
			float f32;
		} x;
		x.u32 = (uint16_t)*(int16_t*)(buffer+(i*2)) ^ 0x43808000u;
		x.f32 = x.f32 - 257.0f;
		memcpy(buffer+(i*4), &x.f32, sizeof(float));
	}
}

#define SHORT_TO_FLOAT(var, size) \
	REALLOC(var, size*2); \
	short_to_float(var, size); \
	size *= 2;

static unsigned char* wav_handler(const char* filename, size_t* size) {
	//TODO
	return NULL;
}

static unsigned char* ogg_handler(const char* filename, size_t* size) {
	unsigned char* out = NULL;
	int channels, freq;
	*size = stb_vorbis_decode_filename(filename, &channels, &freq, (short**)&out);
	if (*size == -1) return NULL;
	*size = *size * sizeof(short) * channels;
	SHORT_TO_FLOAT(out, *size);
	return out;
}

static unsigned char* txt_handler(const char* filename, size_t* size) {
	unsigned char* out = basic_handler(filename, size);
	REALLOC(out, (*size)+1);
	out[*size] = '\0';
	*size = (*size)+1;
	return out;
}

static unsigned char* (*const handlers[])(const char*, size_t*) = {
	&stb_handler, // bmp
	&stb_handler, // jpg
	&stb_handler, // png
	&svg_handler,
	&basic_handler, // ttf
	&wav_handler,
	&ogg_handler,
	&txt_handler // lua
};

unsigned char* extension_handler(const char* filename, size_t* size) {
	for (int i = 0; valid_extensions[i]; i++)
		if (strcmp(extension(filename), valid_extensions[i]) == 0)
			return handlers[i](filename, size);
	fprintf(stderr, "Failure: tried to load unsupported file type\n");
	return NULL;
}
