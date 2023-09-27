//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
#define STB_VORBIS_IMPLEMENTATION
#include <stb_vorbis.c>

#define NANOSVG_IMPLEMENTATION
#define NANOSVGRAST_IMPLEMENTATION
#include <nanosvgrast.h>

//#include "sfx.h"
#include "fonts.h"

#include "assets.h"

/* .bmp handler */
static int bmp_create(void** out, void* in, const size_t len) {
	SDL_Surface* surface = SDL_LoadBMP_RW(SDL_RWFromMem(in, len), 1);
	if (!surface) return ERROR("Load bmp failed: %s", SDL_GetError());
	*out = surface;
	return 0;
}

static void bmp_destroy(void* in) {
	SDL_FreeSurface(in);
}

/* .jpg and .png handler */
static int stb_create(void** out, void* in, const size_t len) {
	int w, h, format;
	unsigned char* pixels = stbi_load_from_memory(in, len, &w, &h, &format, STBI_default);
	if (!pixels) return ERROR("Load image failed");
	SDL_free(in);
	SDL_PixelFormatEnum sdlformat;
	switch (format) {
		case STBI_grey:
			sdlformat = SDL_PIXELFORMAT_INDEX8;
			break;
		case STBI_rgb:
			sdlformat = SDL_PIXELFORMAT_RGB24;
			break;
		case STBI_rgb_alpha:
			sdlformat = SDL_PIXELFORMAT_RGBA32;
			break;
		default:
			return ERROR("Invalid pixel format");
	}
	SDL_Surface* surface = SDL_CreateRGBSurfaceWithFormatFrom(pixels, w, h, 8*format, w*format, sdlformat);
	if (!surface) return ERROR("Create surface failed: %s", SDL_GetError());
	*out = surface;
	return 0;
}

static void stb_destroy(void* in) {
	unsigned char* pixels = ((SDL_Surface*)in)->pixels;
	SDL_FreeSurface(in);
	stbi_image_free(pixels);
}

/* .svg handler. Probably needs more error handling. */
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

/* .json handler */
static int json_create(void** out, void* in, const size_t len) {
	json* json = malloc(sizeof(json));
	json->root = malloc(sizeof(zpl_json_object));
	zpl_json_error err = zpl_json_parse(json->root, in, zpl_heap());
	if (err != ZPL_JSON_ERROR_NONE && err != ZPL_JSON_ERROR_OBJECT_END_PAIR_MISMATCHED) return ERROR("Json parse failed with: %d", err);
	json->raw = in;
	*out = json;
	return 0;
}

static void json_destroy(void* in) {
	json* json = in;
	zpl_json_free(json->root);
	free(json->root);
	SDL_free(json->raw);
	free(json);
}

/* .ttf handler. Needs to be completely redone. */
static int ttf_create(void** out, void* in, const size_t len) {
	*out = load_font(in, len);
	if (*out == NULL) return ERROR("Load font failed");
	return 0;
}

static void ttf_destroy(void* in) {
	SDL_free(((stbtt_fontinfo*)in)->data);
	free(in);
}

/* .wav handler */
static int wav_create(void** out, void* in, const size_t len) {
	SDL_AudioSpec* spec = malloc(sizeof(SDL_AudioSpec));
	Uint8* buffer;
	Uint32 size;
	spec = SDL_LoadWAV_RW(SDL_RWFromMem(in, len), 1, spec, &buffer, &size);
	if (!spec) return ERROR("Load wav failed: %s", SDL_GetError());
	spec->userdata = buffer;
	spec->size = size;
	SDL_free(in);
	*out = spec;
	return 0;
}

static void wav_destroy(void* in) {
	SDL_FreeWAV(((SDL_AudioSpec*)in)->userdata);
	free(in);
}

/* .ogg handler. Slow */
static int vorb_create(void** out, void* in, const size_t len) {
	SDL_AudioSpec* spec = malloc(sizeof(SDL_AudioSpec));
	spec->format = AUDIO_S16SYS;
	spec->samples = 1024;
	spec->size = stb_vorbis_decode_memory(in, len, (int*)&spec->channels, (int*)&spec->freq, (short**)&spec->userdata);
	if (spec->size == -1) return ERROR("Load ogg failed");
	SDL_free(in);
	*out = spec;
	return 0;
}

static void vorb_destroy(void* in) {
	free(((SDL_AudioSpec*)in)->userdata);
	free(in);
}

/*static int sfx_create(void** out, void* in, const size_t len) {
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
}*/

/* .lua handler. No work is really done */
static int lua_create(void** out, void* in, const size_t len) {
	char* str = malloc(strlen(in)+1);
	strcpy(str, in);
	SDL_free(in);
	*out = str;
	return 0;
}

static void lua_destroy(void* in) {
	free(in);
}

/* Based on extension given, sets the function pointers for an asset. */
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
	} else if (strcmp(ext, "lua") == 0) {
		asset->create = &lua_create;
		asset->destroy = &lua_destroy;
	} else return ERROR("Unsupported file type: %s", ext);
	/* In the future maybe just skip the file instead of erroring? */
	return 0;
}

/* Initialize Asset struct */
int asset_init(Asset* asset, const char* name, void* raw, const size_t len) {
	asset->name = (char*)malloc(strlen(name)+1);
	strcpy(asset->name, name);
	if (type_handler(asset, getextension(name)) < 0) return ERROR("Type handler failed");
	if (asset->create(&asset->data, raw, len) < 0) return ERROR("Asset create failed");
	return 0;
}

/* Cleanup Asset struct */
void asset_cleanup(Asset* asset) {
	asset->destroy(asset->data);
}
