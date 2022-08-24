//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"

Engine* Tidal_init(int argc, char *argv[]) {
	Engine* engine = (Engine*)malloc(sizeof(Engine));
	if (engine == NULL) return NULL;
#ifdef DEBUG
	SDL_Log("Engine alloced");
#endif
	engine->width = 640;
	engine->height = 480;
	engine->running = true;
	engine->textures = NULL;
	engine->textures_num = 0;
	engine->objects = NULL;
	engine->objects_num = 0;
	engine->fonts = NULL;
	engine->fonts_num = 0;
	engine->space = NULL;
	engine->audio = NULL;
	engine->audio_num = 0;
	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) return NULL;
#ifdef DEBUG
	SDL_Log("SDL initialized");
#endif
	if (TTF_Init() < 0) return NULL;
#ifdef DEBUG
	SDL_Log("SDL_ttf initialized");
#endif
	if (Mix_Init(0) < 0) return NULL;
#ifdef DEBUG
	SDL_Log("SDL_mixer initialized");
#endif
	engine->window = SDL_CreateWindow("TidalEngine", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, engine->width, engine->height, 0); //change title
	if (!engine->window) return NULL;
#ifdef DEBUG
	SDL_Log("Window created");
#endif
	engine->renderer = SDL_CreateRenderer(engine->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!engine->renderer) return NULL;
#ifdef DEBUG
	SDL_Log("Renderer created");
#endif
	if (PHYSFS_init(argv[0]) == 0) return NULL;
#ifdef DEBUG
	SDL_Log("PHYSFS initialized");
#endif
	engine->space = cpSpaceNew();
	cpSpaceSetGravity(engine->space, cpv(0, -100));
	if (argc > 2) {
		SDL_Log("Too many arguments, only one expected");
		return NULL;
	} else {
		if (PHYSFS_mount(argv[1], NULL, 0) == 0) return NULL;
#ifdef DEBUG
		SDL_Log("Path mounted");
#endif
		if (read_files(engine, "") != 0) return NULL;
	}
#ifdef DEBUG
	SDL_Log("Files read");
#endif
	return engine;
}

static int read_files(Engine* engine, const char *path) {
	PHYSFS_Stat stat;
	if (PHYSFS_stat(path, &stat) == 0) return -1;
#ifdef DEBUG
	SDL_Log("Path stats acquired");
#endif
	if (stat.filetype == PHYSFS_FILETYPE_DIRECTORY) {
		if (path[0] == '.' || path[1] == '.') return 0;
		char **rc = PHYSFS_enumerateFiles(path);
#ifdef DEBUG
		for (char** i = rc; *i != NULL; i++) printf(" * We've got [%s].\n", *i);
		SDL_Log("Dir listed");
#endif
		for (char** i = rc; *i != NULL; i++) {
			*i = (char*)realloc(*i, sizeof(path)+sizeof(*i)+2);
			prepend(*i, PHYSFS_getDirSeparator());
			prepend(*i, path);
			if (read_files(engine, *i) < 0) return -1;
		}
#ifdef DEBUG
		SDL_Log("Files loaded");
#endif
		PHYSFS_freeList(rc);
#ifdef DEBUG
		SDL_Log("List freed");
#endif
	} else if (stat.filetype == PHYSFS_FILETYPE_REGULAR) {
#ifdef DEBUG
		SDL_Log("Is a regular file");
#endif
		const char* ext = getextension(path);
		size_t len = 0;
		char* data = read_data(path, &len);
		if (data == NULL) return -1;
		if (strcmp(ext, "bmp") == 0) {
			SDL_RWops* rw = SDL_RWFromMem(data, len);
			SDL_Surface* surface = SDL_LoadBMP_RW(rw, SDL_TRUE);
			if (!surface) return -1;
#ifdef DEBUG
			SDL_Log("Surface successfully created");
#endif
			if (create_texture(engine, surface, path) < 0) return -1;
			SDL_FreeSurface(surface);
			free(data);
		} else if (strcmp(ext, "json") == 0) {
#ifdef DEBUG
			SDL_Log("Contents of json file:\n%s", data);
#endif
			if (create_object(engine, data, len) < 0) return -1;
			free(data);
		} else if (strcmp(ext, "ttf") == 0) {
			if (create_font(engine, data, len, 24, path) < 0) return -1; //make size dynamic
		} else if (strcmp(ext, "wav") == 0) {
			if (create_audio(engine, data, len, path) < 0) return -1;
		}
		//Add more filetypes later
	}
	return 0;
}

static char* read_data(const char* path, size_t* len) {
	PHYSFS_File* file = PHYSFS_openRead(path);
	if (file == NULL) return NULL;
	*len = PHYSFS_fileLength(file);
	if (*len == -1) return NULL;
	char* data = (char*)malloc(*len);
	PHYSFS_readBytes(file, data, *len);
	if (PHYSFS_close(file) == 0) return NULL;
	return data;
}

static const char* getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
#ifdef DEBUG
	SDL_Log("getextension() input: %s", filename);
	SDL_Log("getextension() output: %s", dot);
#endif
	if (!dot || dot == filename) return "";
	return dot + 1;
}

static void prepend(char* s, const char* t) {
	size_t len = strlen(t);
	memmove(s + len, s, strlen(s) + 1);
	memcpy(s, t, len);
}

static int create_object(Engine* engine, char* string, size_t len) {
	engine->objects_num++;
	engine->objects = (Object*)realloc(engine->objects, engine->objects_num*sizeof(Object));
	(engine->objects + engine->objects_num-1)->json = cJSON_ParseWithLength(string, len);
	const cJSON* json = (engine->objects + engine->objects_num-1)->json;
	(engine->objects + engine->objects_num-1)->dst.x = 0;
	(engine->objects + engine->objects_num-1)->dst.y = 0;
	(engine->objects + engine->objects_num-1)->dst.w = cJSON_GetObjectItemCaseSensitive(json, "width")->valueint;
	(engine->objects + engine->objects_num-1)->dst.h = cJSON_GetObjectItemCaseSensitive(json, "height")->valueint;
	(engine->objects + engine->objects_num-1)->texture = NULL;
	for (int i = 0; i < engine->textures_num; i++) {
		if (strcmp((engine->textures+i)->name, cJSON_GetObjectItemCaseSensitive(json, "sprite")->valuestring) == 0) {
			(engine->objects + engine->objects_num-1)->texture = (engine->textures+i)->data; //improve
		}
	}
#ifdef DEBUG
	if ((engine->objects + engine->objects_num-1)->texture != NULL) SDL_Log("Texture attached");
#endif
	(engine->objects + engine->objects_num-1)->text = NULL;
	for (int i = 0; i < engine->fonts_num; i++) { //improve
		if (strcmp((engine->fonts+i)->name, cJSON_GetObjectItemCaseSensitive(json, "font")->valuestring) == 0) {
			TTF_Font* font = (engine->fonts+i)->data;
#ifdef DEBUG
			SDL_Log("Font height: %d", TTF_FontHeight(font));
#endif
			SDL_Color color = {255, 255, 255, 255}; //make dynamic
			const char* string = cJSON_GetObjectItemCaseSensitive(json, "text")->valuestring;
#ifdef DEBUG
			SDL_Log("Text to output: %s", string);
#endif
			SDL_Surface* text = TTF_RenderUTF8_Solid_Wrapped(font, string, color, 0);
			if (text == NULL) return -1;
			(engine->objects + engine->objects_num-1)->text = SDL_CreateTextureFromSurface(engine->renderer, text);
			SDL_FreeSurface(text);
		}
	}
#ifdef DEBUG
	if ((engine->objects + engine->objects_num-1)->text != NULL) SDL_Log("Font attached");
#endif
	(engine->objects + engine->objects_num-1)->body = NULL;
	(engine->objects + engine->objects_num-1)->shape = NULL;
	if (strcmp(cJSON_GetObjectItemCaseSensitive(json, "shape")->valuestring, "box") == 0) { //set mass and friction dynamically
		(engine->objects + engine->objects_num-1)->body = cpSpaceAddBody(engine->space, cpBodyNew(1, cpMomentForBox(1, (engine->objects + engine->objects_num-1)->dst.w, (engine->objects + engine->objects_num-1)->dst.h)));
		cpBodySetPosition((engine->objects + engine->objects_num-1)->body, cpv(0, 0));
		(engine->objects + engine->objects_num-1)->shape = cpSpaceAddShape(engine->space, cpBoxShapeNew((engine->objects + engine->objects_num-1)->body, (engine->objects + engine->objects_num-1)->dst.w, (engine->objects + engine->objects_num-1)->dst.h, 0));
		cpShapeSetFriction((engine->objects + engine->objects_num-1)->shape, 0.7);
	} //add other shapes
#ifdef DEBUG
	SDL_Log("Physics applied to object");
#endif
	for (int i = 0; i < engine->audio_num; i++) { //temporary
		if (strcmp((engine->audio+i)->name, cJSON_GetObjectItemCaseSensitive(json, "sound")->valuestring) == 0) {
			Mix_PlayChannel(-1, (engine->audio+i)->data, 0);
		}
	}
#ifdef DEBUG
	SDL_Log("Object successfully created");
#endif
	return 0;
}

static int create_texture(Engine* engine, SDL_Surface* surface, const char* path) {
	engine->textures_num++;
	engine->textures = (Texture*)realloc(engine->textures, engine->textures_num*sizeof(Texture));
	(engine->textures + engine->textures_num-1)->data = SDL_CreateTextureFromSurface(engine->renderer, surface);
	(engine->textures + engine->textures_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((engine->textures + engine->textures_num-1)->name, path+1);
	if (!engine->textures->data) return -1;
#ifdef DEBUG
	SDL_Log("Texture successfully created");
#endif
	return 0;
}

static int create_font(Engine* engine, char* data, size_t len, int ptsize, const char* path) {
	engine->fonts_num++;
	engine->fonts = (Font*)realloc(engine->fonts, engine->fonts_num*sizeof(Font));
	(engine->fonts + engine->fonts_num-1)->raw = data;
	(engine->fonts + engine->fonts_num-1)->rw = SDL_RWFromMem((engine->fonts + engine->fonts_num-1)->raw, len);
	(engine->fonts + engine->fonts_num-1)->data = TTF_OpenFontRW((engine->fonts + engine->fonts_num-1)->rw, 0, ptsize);
	(engine->fonts + engine->fonts_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((engine->fonts + engine->fonts_num-1)->name, path+1);
	if (!engine->fonts->data) return -1;
#ifdef DEBUG
	SDL_Log("Font successfully created");
#endif
	return 0;
}

static int create_audio(Engine* engine, char* data, size_t len, const char* path) {
	engine->audio_num++;
	engine->audio = (Audio*)realloc(engine->audio, engine->audio_num*sizeof(Audio));
	Mix_CloseAudio();
	Mix_OpenAudio(48000, AUDIO_S16SYS, 1, 2048);
	(engine->audio + engine->audio_num-1)->data = Mix_LoadWAV_RW(SDL_RWFromMem(data, len), 1);
	(engine->audio + engine->audio_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((engine->audio + engine->audio_num-1)->name, path+1);
	if (!engine->audio->data) return -1;
#ifdef DEBUG
	SDL_Log("Audio successfully created");
#endif
	return 0;
}

void Tidal_run(Engine* engine) {
	while (engine->running) {
		Uint64 start = SDL_GetPerformanceCounter();
		events(engine);
		update(engine);
		draw(engine);
		Uint64 end = SDL_GetPerformanceCounter();
		float elapsed = (end - start) / (float)SDL_GetPerformanceFrequency();
		printf("Current FPS: %f\n", 1.0/elapsed);
	}
}

static void events(Engine* engine) {
	SDL_Event event;
	SDL_PollEvent(&event);
	if (event.type == SDL_QUIT) {
		engine->running = false;
	}
}

static void update(Engine* engine) {
	for (int i = 0; i < engine->objects_num; i++) {
		if (engine->objects[i].body != NULL) {
			cpVect pos = cpBodyGetPosition(engine->objects[i].body);
			cpVect vel = cpBodyGetVelocity(engine->objects[i].body);
			engine->objects[i].dst.x = pos.x;
			engine->objects[i].dst.y = pos.y;
		}
	}
	cpSpaceStep(engine->space, 1.0/60.0);
}

static void draw(Engine* engine) {
	SDL_SetRenderDrawBlendMode(engine->renderer, SDL_BLENDMODE_NONE);
	SDL_SetRenderDrawColor(engine->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	SDL_RenderClear(engine->renderer);
	for (int i = 0; i < engine->objects_num; i++) {
		SDL_RenderCopy(engine->renderer, (engine->objects + i)->texture, NULL, &((engine->objects + i)->dst));
		SDL_RenderCopy(engine->renderer, (engine->objects + i)->text, NULL, &((engine->objects + i)->dst));
	}
	SDL_RenderPresent(engine->renderer);
}

void Tidal_cleanup(Engine* engine) {
	PHYSFS_deinit();
	for (int i = 0; i < engine->textures_num; i++) {
		SDL_DestroyTexture(engine->textures[i].data);
		free(engine->textures[i].name);
	}
	free(engine->textures);
	for (int i = 0; i < engine->objects_num; i++) {
		cJSON_Delete(engine->objects[i].json);
		SDL_DestroyTexture(engine->objects[i].text);
		cpShapeFree(engine->objects[i].shape);
		cpBodyFree(engine->objects[i].body);
		SDL_CloseAudioDevice(engine->objects[i].audiodev);
	}
	free(engine->objects);
	for (int i = 0; i < engine->fonts_num; i++) {
		TTF_CloseFont(engine->fonts[i].data);
		SDL_RWclose(engine->fonts[i].rw);
		free(engine->fonts[i].raw);
		free(engine->fonts[i].name);
	}
	free(engine->fonts);
	for (int i = 0; i < engine->audio_num; i++) {
		Mix_FreeChunk(engine->audio[i].data);
		free(engine->audio[i].name);
	}
	free(engine->audio);
	cpSpaceFree(engine->space);
	SDL_DestroyRenderer(engine->renderer);
	SDL_DestroyWindow(engine->window);
	Mix_CloseAudio();
	Mix_Quit();
	TTF_Quit();
	SDL_Quit();
	free(engine);
	SDL_Log("Cleanup complete");
}
