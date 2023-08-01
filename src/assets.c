//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "assets.h"
#include "common.h"

int asset_init(Asset* asset, const char* path, const unsigned char* raw) {
	asset->name = (char*)malloc(strlen(path)+1);
	strcpy(asset->name, path);
	if (type_handler(asset, getextension(path)) < 0) return -1;
	if (asset->create(&asset->data, raw) < 0) return -1;
	return 0;
}

void asset_cleanup(Asset* asset) {
	asset->destroy(&asset->data);
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
	} else if (strcmp(ext, "sfx") == 0) {
		asset->create = &sfx_create;
		asset->destroy = &sfx_destroy;
	} else {
		fprintf(stderr, "Unsupported file type");
		return -1;
	}
	return 0;
}

/* Read in JSON data */
/*static int obj_handler(Engine* engine, unsigned char* data, size_t len, const char* path) {
	engine->objects[engine->objects_num].data = J_ParseWithLength((char*)data, len);
	if (!engine->objects[engine->objects_num].data) {
		S_Log("cJSON error: %s", J_GetErrorPtr());
		return -1;
	}
	const cJSON* layer = J_GetObjectItemCaseSensitive(engine->objects[engine->objects_num].data, "layer");
	if (J_IsNumber(layer)) {
		if (layer->valueint < engine->first_layer) {
			engine->first_object = engine->objects + engine->objects_num;
			engine->first_layer = layer->valueint;
		}
	}
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Object successfully created");
	return 0;
}*/

/* Read in image data */
/*static int init_texture(Engine* engine, unsigned char* data, size_t len, const char* path) {
	Texture* tmp = (Texture*)realloc(engine->textures, (engine->textures_num+1)*sizeof(Texture));
	if (tmp == NULL) return -1;
	engine->textures = tmp;
	SDL_Surface* surface = I_Load_RW(S_RWFromMem(data, len), 1);
	engine->textures[engine->textures_num].data = S_CreateTextureFromSurface(engine->renderer, surface);
	S_FreeSurface(surface);
	engine->textures[engine->textures_num].name = (char*)malloc(strlen(path+1)+1);
	strcpy(engine->textures[engine->textures_num].name, path+1);
	if (!engine->textures[engine->textures_num].data) return -1;
	engine->textures_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Texture successfully created");
	return 0;
}*/

/* Read in font data */
/*static int init_font(Engine* engine, unsigned char* data, size_t len, const char* path) {
	Font* tmp = (Font*)realloc(engine->fonts, (engine->fonts_num+1)*sizeof(Font));
	if (tmp == NULL) return -1;
	engine->fonts = tmp;
	engine->fonts[engine->fonts_num].normal = F_CreateFont();
	engine->fonts[engine->fonts_num].bold = F_CreateFont();
	if (F_LoadFontRW(engine->fonts[engine->fonts_num].normal, engine->renderer, S_RWFromMem(data, len), 1, 28, F_MakeColor(0, 0, 0, 255), TTF_STYLE_NORMAL) == 0) return -1;
	if (F_LoadFontRW(engine->fonts[engine->fonts_num].bold, engine->renderer, S_RWFromMem(data, len), 1, 28, F_MakeColor(0, 0, 0, 255), TTF_STYLE_BOLD) == 0) return -1;
	engine->fonts[engine->fonts_num].name = (char*)malloc(strlen(path+1)+1);
	strcpy(engine->fonts[engine->fonts_num].name, path+1);
	if (!engine->fonts[engine->fonts_num].normal) return -1;
	engine->fonts_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Font successfully created");
	return 0;
}*/

/* Read in audio data. Based on "type" input, different
 * file types can be read from.
 */
/*static int init_audio(Engine* engine, unsigned char* data, size_t len, const char* path, int type) {
	Audio* tmp = (Audio*)realloc(engine->audio, (engine->audio_num+1)*sizeof(Audio));
	if (tmp == NULL) return -1;
	engine->audio = tmp;
	int err = 0;
	if (type == 0) {
		engine->audio[engine->audio_num].data = O_WavCreate();
		err = O_WavLoadMemEx(engine->audio[engine->audio_num].data, (unsigned char*)data, len, 1, 0);
	} else if (type == 1) {
		engine->audio[engine->audio_num].data = O_SfxrCreate();
		err = O_SfxrLoadParamsEx(engine->audio[engine->audio_num].data, (unsigned char*)data, len, 1, 0);
	}
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Soloud load error: %s", O_getErrorString(engine->soloud, err));
	engine->audio[engine->audio_num].name = (char*)malloc(strlen(path+1)+1);
	strcpy(engine->audio[engine->audio_num].name, path+1);
	if (!engine->audio[engine->audio_num].data) return -1;
	engine->audio_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio successfully created");
	return 0;
}*/

/* Part of WIP ui system */
/*static int init_ui(Engine* engine, int n) {
	Instance** tmp = (Instance**)realloc(engine->ui, (engine->ui_num+1)*sizeof(Instance*));
	if (tmp == NULL) return -1;
	engine->ui = tmp;
	engine->ui[engine->ui_num] = engine->instances + n;
	if (engine->ui_num == 0) {
		engine->ui_dst = engine->instances[n].dst;
		if (engine->instances[n].texture != NULL) {
			S_DestroyTexture(engine->ui_texture);
			engine->ui_texture = S_CreateTexture(engine->renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, engine->ui_dst.w + 10, engine->ui_dst.h + 10);
			S_SetRenderTarget(engine->renderer, engine->ui_texture);
			S_SetRenderDrawColor(engine->renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE);
			S_RenderDrawRect(engine->renderer, NULL);
			//S_SetRenderDrawColor(engine->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
			S_SetRenderTarget(engine->renderer, NULL);
		}
		if (engine->instances[n].font != NULL && engine->instances[n].text != NULL) {
			engine->ui_font = engine->instances[n].font->bold;
			engine->ui_text = engine->instances[n].text;
		}
	}
	engine->ui_num++;
	return 0;
}
