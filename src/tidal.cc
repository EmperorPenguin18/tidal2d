//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"

TidalEngine::TidalEngine() {
	m_width = 640;
	m_height = 480;
	m_running = true;
	m_textures = NULL;
	m_textures_num = 0;
	m_objects = NULL;
	m_objects_num = 0;
	m_fonts = NULL;
	m_fonts_num = 0;
	m_space = NULL;
}

TidalEngine::~TidalEngine() {
	cleanup();
}

int TidalEngine::init(int argc, char *argv[]) {
	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) return -1;
#ifdef DEBUG
	SDL_Log("SDL initialized");
#endif
	if (TTF_Init() < 0) return -1;
#ifdef DEBUG
	SDL_Log("SDL_ttf initialized");
#endif
	m_window = SDL_CreateWindow("TidalEngine", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, m_width, m_height, 0); //change title
	if (!m_window) return -1;
#ifdef DEBUG
	SDL_Log("Window created");
#endif
	m_renderer = SDL_CreateRenderer(m_window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!m_renderer) return -1;
#ifdef DEBUG
	SDL_Log("Renderer created");
#endif
	if (PHYSFS_init(argv[0]) == 0) return -1;
#ifdef DEBUG
	SDL_Log("PHYSFS initialized");
#endif
	m_space = cpSpaceNew();
	cpSpaceSetGravity(m_space, cpv(0, -100));
	if (argc > 2) {
		SDL_Log("Too many arguments, only one expected");
		return -1;
	} else {
		if (PHYSFS_mount(argv[1], NULL, 0) == 0) return -1;
#ifdef DEBUG
		SDL_Log("Path mounted");
#endif
		if (readfiles("") != 0) return -1;
	}
#ifdef DEBUG
	SDL_Log("Files read");
#endif
	return 0;
}

void TidalEngine::run() {
	while (m_running) {
		Uint64 start = SDL_GetPerformanceCounter();
		events();
		update();
		draw();
		Uint64 end = SDL_GetPerformanceCounter();
		float elapsed = (end - start) / (float)SDL_GetPerformanceFrequency();
		printf("Current FPS: %f\n", 1.0/elapsed);
	}
}

void TidalEngine::events() {
	SDL_Event event;
	SDL_PollEvent(&event);
	if (event.type == SDL_QUIT) {
		m_running = false;
	}
}

void TidalEngine::update() {
	for (int i = 0; i < m_objects_num; i++) {
		if (m_objects[i].body != NULL) {
			cpVect pos = cpBodyGetPosition(m_objects[i].body);
			cpVect vel = cpBodyGetVelocity(m_objects[i].body);
			m_objects[i].dst.x = pos.x;
			m_objects[i].dst.y = pos.y;
		}
	}
	cpSpaceStep(m_space, 1.0/60.0);
}

void TidalEngine::cleanup() {
	PHYSFS_deinit();
	for (int i = 0; i < m_textures_num; i++) {
		SDL_DestroyTexture(m_textures[i].data);
		free(m_textures[i].name);
	}
	free(m_textures);
	for (int i = 0; i < m_objects_num; i++) {
		cJSON_Delete(m_objects[i].json);
		SDL_DestroyTexture(m_objects[i].text);
		cpShapeFree(m_objects[i].shape);
		cpBodyFree(m_objects[i].body);
	}
	free(m_objects);
	for (int i = 0; i < m_fonts_num; i++) {
		TTF_CloseFont(m_fonts[i].data);
		SDL_RWclose(m_fonts[i].rw);
		free(m_fonts[i].raw);
		free(m_fonts[i].name);
	}
	free(m_fonts);
	cpSpaceFree(m_space);
	SDL_DestroyRenderer(m_renderer);
	SDL_DestroyWindow(m_window);
	TTF_Quit();
	SDL_Quit();
	SDL_Log("Cleanup complete");
}

char* TidalEngine::read_data(const char* path, size_t* len) {
	PHYSFS_File* file = PHYSFS_openRead(path);
	if (file == NULL) return NULL;
	*len = PHYSFS_fileLength(file);
	if (*len == -1) return NULL;
	char* data = (char*)malloc(*len);
	PHYSFS_readBytes(file, data, *len);
	if (PHYSFS_close(file) == 0) return NULL;
	return data;
}

int TidalEngine::readfiles(const char *path) {
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
			if (readfiles(*i) < 0) return -1;
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
		if (strcmp(ext, "bmp") == 0) {
			size_t len = 0;
			char* data = read_data(path, &len);
			if (data == NULL) return -1;
			SDL_RWops* rw = SDL_RWFromMem(data, len);
			SDL_Surface* surface = SDL_LoadBMP_RW(rw, SDL_TRUE);
			if (!surface) return -1;
#ifdef DEBUG
			SDL_Log("Surface successfully created");
#endif
			if (create_texture(surface, path) < 0) return -1;
			SDL_FreeSurface(surface);
			free(data);
		} else if (strcmp(ext, "json") == 0) {
			size_t len = 0;
			char* string = read_data(path, &len);
			if (string == NULL) return -1;
#ifdef DEBUG
			SDL_Log("Contents of json file:\n%s", string);
#endif
			if (create_object(string, len) < 0) return -1;
			free(string);
		} else if (strcmp(ext, "ttf") == 0) {
			size_t len = 0;
			char* data = read_data(path, &len);
			if (data == NULL) return -1;
			if (create_font(data, len, 24, path) < 0) return -1; //make size dynamic
		}
		//Add more filetypes later
	}
	return 0;
}

const char* TidalEngine::getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
#ifdef DEBUG
	SDL_Log("getextension() input: %s", filename);
	SDL_Log("getextension() output: %s", dot);
#endif
	if (!dot || dot == filename) return "";
	return dot + 1;
}

void TidalEngine::prepend(char* s, const char* t) {
	size_t len = strlen(t);
	memmove(s + len, s, strlen(s) + 1);
	memcpy(s, t, len);
}

void TidalEngine::draw() {
	SDL_SetRenderDrawBlendMode(m_renderer, SDL_BLENDMODE_NONE);
	SDL_SetRenderDrawColor(m_renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	SDL_RenderClear(m_renderer);
	for (int i = 0; i < m_objects_num; i++) {
		SDL_RenderCopy(m_renderer, (m_objects + i)->texture, NULL, &((m_objects + i)->dst));
		SDL_RenderCopy(m_renderer, (m_objects + i)->text, NULL, &((m_objects + i)->dst));
	}
	SDL_RenderPresent(m_renderer);
}

int TidalEngine::create_object(char* string, size_t len) {
	m_objects_num++;
	m_objects = (Object*)realloc(m_objects, m_objects_num*sizeof(Object));
	(m_objects + m_objects_num-1)->json = cJSON_ParseWithLength(string, len);
	const cJSON* json = (m_objects + m_objects_num-1)->json;
	(m_objects + m_objects_num-1)->dst.x = 0;
	(m_objects + m_objects_num-1)->dst.y = 0;
	(m_objects + m_objects_num-1)->dst.w = cJSON_GetObjectItemCaseSensitive(json, "width")->valueint;
	(m_objects + m_objects_num-1)->dst.h = cJSON_GetObjectItemCaseSensitive(json, "height")->valueint;
	(m_objects + m_objects_num-1)->texture = NULL;
	for (int i = 0; i < m_textures_num; i++) {
		if (strcmp((m_textures+i)->name, cJSON_GetObjectItemCaseSensitive(json, "sprite")->valuestring) == 0) {
			(m_objects + m_objects_num-1)->texture = (m_textures+i)->data; //improve
		}
	}
#ifdef DEBUG
	if ((m_objects + m_objects_num-1)->texture != NULL) SDL_Log("Texture attached");
#endif
	(m_objects + m_objects_num-1)->text = NULL;
	for (int i = 0; i < m_fonts_num; i++) { //improve
		if (strcmp((m_fonts+i)->name, cJSON_GetObjectItemCaseSensitive(json, "font")->valuestring) == 0) {
			TTF_Font* font = (m_fonts+i)->data;
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
			(m_objects + m_objects_num-1)->text = SDL_CreateTextureFromSurface(m_renderer, text);
			SDL_FreeSurface(text);
		}
	}
#ifdef DEBUG
	if ((m_objects + m_objects_num-1)->text != NULL) SDL_Log("Font attached");
#endif
	(m_objects + m_objects_num-1)->body = NULL;
	(m_objects + m_objects_num-1)->shape = NULL;
	if (strcmp(cJSON_GetObjectItemCaseSensitive(json, "shape")->valuestring, "box") == 0) { //set mass and friction dynamically
		(m_objects + m_objects_num-1)->body = cpSpaceAddBody(m_space, cpBodyNew(1, cpMomentForBox(1, (m_objects + m_objects_num-1)->dst.w, (m_objects + m_objects_num-1)->dst.h)));
		cpBodySetPosition((m_objects + m_objects_num-1)->body, cpv(0, 0));
		(m_objects + m_objects_num-1)->shape = cpSpaceAddShape(m_space, cpBoxShapeNew((m_objects + m_objects_num-1)->body, (m_objects + m_objects_num-1)->dst.w, (m_objects + m_objects_num-1)->dst.h, 0));
		cpShapeSetFriction((m_objects + m_objects_num-1)->shape, 0.7);
	} //add other shapes
#ifdef DEBUG
	SDL_Log("Object successfully created");
#endif
	return 0;
}

int TidalEngine::create_texture(SDL_Surface* surface, const char* path) {
	m_textures_num++;
	m_textures = (Texture*)realloc(m_textures, m_textures_num*sizeof(Texture));
	(m_textures + m_textures_num-1)->data = SDL_CreateTextureFromSurface(m_renderer, surface);
	(m_textures + m_textures_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((m_textures + m_textures_num-1)->name, path+1);
	if (!m_textures->data) return -1;
#ifdef DEBUG
	SDL_Log("Texture successfully created");
#endif
	return 0;
}

int TidalEngine::create_font(char* data, size_t len, int ptsize, const char* path) {
	m_fonts_num++;
	m_fonts = (Font*)realloc(m_fonts, m_fonts_num*sizeof(Font));
	(m_fonts + m_fonts_num-1)->raw = data;
	(m_fonts + m_fonts_num-1)->rw = SDL_RWFromMem((m_fonts + m_fonts_num-1)->raw, len);
	(m_fonts + m_fonts_num-1)->data = TTF_OpenFontRW((m_fonts + m_fonts_num-1)->rw, 0, ptsize);
	(m_fonts + m_fonts_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((m_fonts + m_fonts_num-1)->name, path+1);
	if (!m_fonts->data) return -1;
#ifdef DEBUG
	SDL_Log("Font successfully created");
#endif
	return 0;
}
