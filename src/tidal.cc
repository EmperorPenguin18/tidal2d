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
}

TidalEngine::~TidalEngine() {
	cleanup();
}

int TidalEngine::init(int argc, char *argv[]) {
	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) return -1;
#ifdef DEBUG
	SDL_Log("SDL initialized");
#endif
	if (SDL_CreateWindowAndRenderer(m_width, m_height, 0, &m_window, &m_renderer) < 0) return -1;
#ifdef DEBUG
	SDL_Log("Window and renderer created");
#endif
	if (PHYSFS_init(argv[0]) == 0) return -1;
#ifdef DEBUG
	SDL_Log("PHYSFS initialized");
#endif
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
		events();
		draw();
	}
}

void TidalEngine::events() {
	SDL_Event event;
	SDL_PollEvent(&event);
	if (event.type == SDL_QUIT) {
		m_running = false;
	}
}

void TidalEngine::cleanup() {
	PHYSFS_deinit();
	for (int i = 0; i < m_textures_num; i++) {
		SDL_DestroyTexture(m_textures[i].data);
		free(m_textures[i].name);
	}
	free(m_textures);
	SDL_DestroyRenderer(m_renderer);
	SDL_DestroyWindow(m_window);
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
			create_texture(surface, path);
			SDL_FreeSurface(surface);
			free(data);
		} else if (strcmp(ext, "json") == 0) {
			size_t len = 0;
			char* string = read_data(path, &len);
			if (string == NULL) return -1;
#ifdef DEBUG
			SDL_Log("Contents of json file:\n%s", string);
#endif
			create_object(string, len);
			free(string);
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
	for (int i = 0; i < m_objects_num; i++) SDL_RenderCopy(m_renderer, (m_objects + i)->texture, NULL, &((m_objects + i)->dst));
	SDL_RenderPresent(m_renderer);
}

int TidalEngine::create_object(char* string, size_t len) {
	m_objects_num++;
	m_objects = (Object*)realloc(m_objects, m_objects_num*sizeof(Object));
	(m_objects + m_objects_num-1)->json = cJSON_ParseWithLength(string, len);
	(m_objects + m_objects_num-1)->dst.x = 0;
	(m_objects + m_objects_num-1)->dst.y = 0;
	(m_objects + m_objects_num-1)->dst.w = cJSON_GetObjectItemCaseSensitive((m_objects + m_objects_num-1)->json, "width")->valueint;
	(m_objects + m_objects_num-1)->dst.h = cJSON_GetObjectItemCaseSensitive((m_objects + m_objects_num-1)->json, "height")->valueint;
	for (int i = 0; i < m_textures_num; i++) if (strcmp((m_textures+i)->name, cJSON_GetObjectItemCaseSensitive((m_objects + m_objects_num-1)->json, "sprite")->valuestring) == 0) (m_objects + m_objects_num-1)->texture = (m_textures+i)->data; //improve
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
