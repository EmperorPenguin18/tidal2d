#include "common.h"

#include <stdint.h>
#include <assert.h>

#include <stb_image.h>
#define STB_VORBIS_HEADER_ONLY
#include <stb_vorbis.c>
#include <nanosvgrast.h>
#include <dr_wav.h>
#include <cute_aseprite.h>

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

static unsigned char* wav_handler(const char* filename, size_t* size) {
	unsigned int channels, sampleRate;
	float* out = drwav_open_file_and_read_pcm_frames_f32(
		filename, &channels, &sampleRate, (drwav_uint64*)size, NULL);
	assert(channels == 2); assert(sampleRate == 48000);
	return (unsigned char*)out;
}

#define SHORT_TO_FLOAT(var, size) \
	void* temp = malloc(size*4); \
	drwav_s16_to_f32(temp, (drwav_int16*)var, size); \
	free(var); \
	var = temp; \
	size *= 4;

static unsigned char* ogg_handler(const char* filename, size_t* size) {
	unsigned char* out = NULL;
	int channels, freq;
	*size = stb_vorbis_decode_filename(filename, &channels, &freq, (short**)&out);
	assert(channels == 2); assert(freq == 48000);
	if (*size == -1) return NULL;
	*size = *size * channels; //samples
	SHORT_TO_FLOAT(out, *size);
	return out;
}

/*static unsigned char* txt_handler(const char* filename, size_t* size) {
	unsigned char* out = basic_handler(filename, size);
	REALLOC(out, (*size)+1);
	out[*size] = '\0';
	*size = (*size)+1;
	return out;
}*/

static unsigned char* ase_handler(const char* filename, size_t* size) {
	ase_t* ase = cute_aseprite_load_from_file(filename, NULL);
	const size_t frame_size = ase->w*ase->h*sizeof(ase_color_t);
	*size = frame_size*ase->frame_count;
	unsigned char* out = malloc(*size);
	for (int i = 0; i < ase->frame_count; ++i) {
		ase_frame_t* frame = ase->frames + i;
		memcpy(out+(i*frame_size), frame->pixels, frame_size);
	}
	cute_aseprite_free(ase);
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
	&ase_handler,
	&ase_handler  // aseprite
};

unsigned char* extension_handler(const char* filename, size_t* size) {
	for (int i = 0; valid_extensions[i]; i++)
		if (strcmp(extension(filename), valid_extensions[i]) == 0)
			return handlers[i](filename, size);
	fprintf(stderr, "Failure: tried to load unsupported file type\n");
	return NULL;
}
