//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "assets.h"
#include "common.h"
#include "sfx.h"

#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>
#define STB_TRUETYPE_IMPLEMENTATION
#include <stb/stb_truetype.h>
#define STB_VORBIS_IMPLEMENTATION
#include <stb/stb_vorbis.h>

#include <stdio.h>
#include <string.h>
#include <math.h>
#define NANOSVG_IMPLEMENTATION
#include <nanosvg/nanosvgrast.h>

#define ZPL_ENABLE_PARSER
#include <zpl.h>

static int bmp_create(void** out, void* in, const size_t len) {
	SDL_Surface* surface = SDL_LoadBMP_RW(S_RWFromMem(in, len), 1);
	if (!surface) return -1;
	*out = surface;
	return 0;
}

static void bmp_destroy(void* in) {
	SDL_FreeSurface(in);
}

static int stb_create(void** out, void* in, const size_t len) {
	int w, h, n;
	unsigned char* data = stbi_load_from_memory(in, &w, &h, &n, 0);
	if (!data) return -1;
	SDL_Surface* surface = SDL_CreateRGBSurface(0, w, h, n*8, 0, 0, 0, 0);
	if (!surface) return -1;
	memcpy(surface->pixels, data);
	stbi_image_free(data);
	SDL_free(in);
	*out = surface;
	return 0;
}

static void stb_destroy(void* in) {
	SDL_FreeSurface(in);
}

static int svg_create(void** out, void* in, const size_t len) {
	NSVGimage* image = nsvgParse(in, "px", 96);
	struct NSVGrasterizer* rast = nsvgCreateRasterizer();
	SDL_Surface* surface = SDL_CreateRGBSurfaceWithFormat(0, image->width, image->height, 32, SDL_PIXELFORMAT_RGBA32);
	nsvgRasterize(rast, image, 0, 0, 1, surface->pixels, surface->w, surface->h, surface->pitch);
	nsvgDeleteRasterizer(rast);
	nsvgDelete(image);
	SDL_free(in);
	*out = surface;
	return 0;
}

static void svg_destroy(void* in) {
	SDL_FreeSurface(in);
}

static int json_create(void** out, void* in, const size_t len) {
	zpl_json_object root = malloc(sizeof(zpl_json_object));
	zpl_json_parse(root, in, NULL);
	if (!root) return -1;
	SDL_free(in);
	*out = root;
	return 0;
}

static void json_destroy(void* in) {
	free(in);
}

static int ttf_create(void** out, void* in, const size_t len) {
	stbtt_fontinfo* info = malloc(sizeof(stbtt_fontinfo));
	if (stbtt_InitFont(&info, in, 0) == 0) return -1;
	*out = info;
	return 0;
}

static void ttf_destroy(void* in) {
	SDL_free(in->data);
	free(in);
}

static int wav_create(void** out, void* in, const size_t len) {
	SDL_AudioSpec* spec = malloc(sizeof(SDL_AudioSpec));
	Uint8* buffer;
	Uint32 size;
	spec = SDL_LoadWAV_RW(SDL_RWFromMem(in, len), 1, spec, &buffer, &size);
	if (!spec) return -1;
	spec->userdata = buffer;
	SDL_free(in);
	*out = spec;
	return 0;
}

static void wav_destroy(void* in) {
	SDL_FreeWAV(in->userdata);
	free(in);
}

static int vorb_create(void** out, void* in, const size_t len) {
	int error = 0;
	stb_vorbis* vorbis = stb_vorbis_open_memory(in, len, &error, NULL);
	if (error != 0) return -1;
	stb_vorbis_info info = stb_vorbis_get_info(vorbis);
	SDL_AudioSpec* spec = malloc(sizeof(SDL_AudioSpec));
	spec->freq = info.sample_rate;
	spec->format = AUDIO_S16;
	spec->channels = 2;
	spec->samples = 1024;
	spec->userdata = vorbis;
	SDL_free(in);
	*out = spec;
	return 0;
}

static void vorb_destroy(void* in) {
	stb_vorbis_close(in->userdata);
	free(in);
}

static int sfx_create(void** out, void* in, const size_t len) {
	Sfx sfx;
	if (load_sfx(&sfx, in) < 0) return -1;
	SDL_free(in);
	void* wav;
	size_t wav_len = 0;
	if (sfx2wav(&wav, &wav_len, &sfx) < 0) return -1;
	SDL_AudioSpec* spec = malloc(sizeof(SDL_AudioSpec));
	Uint8* buffer;
	Uint32 size;
	spec = SDL_LoadWAV_RW(SDL_RWFromMem(wav, wav_len), 1, spec, &buffer, &size);
	if (!spec) return -1;
	spec->userdata = buffer;
	free(wav);
	*out = spec;
	return 0;
}

static void sfx_destroy(void* in) {
	free(in); //temp
}

/* Based on extension given, sets the function pointers for an asset.
*/
static int type_handler(Asset* asset, const char* ext) {
	if (strcmp(ext, "bmp") == 0) {
		asset->create = &bmp_create;
		asset->destroy = &bmp_destroy;
	} else if (strcmp(ext, "jpg") == 0 || strcmp(ext, "png") == 0) {
		asset->create = &stb_create;
		asset->destroy = &stb_destroy;
	} else if (strcmp(ext, "svg") == 0) {
		asset->create = &svg_create;
		asset->destroy = &svg_destroy;
	} else if (strcmp(ext, "json") == 0) {
		asset->create = &json_create;
		asset->destroy = &json_destroy;
	} else if (strcmp(ext, "ttf") == 0) {
		asset->create = &ttf_create;
		asset->destroy = &ttf_destroy;
	} else if (strcmp(ext, "wav") == 0) {
		asset->create = &wav_create;
		asset->destroy = &wav_destroy;
	} else if (strcmp(ext, "ogg") == 0) {
		asset->create = &vorb_create;
		asset->destroy = &vorb_destroy;
	/*} else if (strcmp(ext, "sfx") == 0) {
		asset->create = &sfx_create;
		asset->destroy = &sfx_destroy;*/
	} else {
		fprintf(stderr, "Unsupported file type");
		return -1;
	}
	return 0;
}

int asset_init(Asset* asset, const char* path, void* raw, const size_t len) {
	asset->name = (char*)malloc(strlen(path)+1);
	strcpy(asset->name, path);
	if (type_handler(asset, getextension(path)) < 0) return -1;
	if (asset->create(&asset->data, raw, len) < 0) return -1;
	return 0;
}

void asset_cleanup(Asset* asset) {
	asset->destroy(&asset->data);
}
