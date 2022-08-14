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
	} else if (readfiles(argv[1]) != 0) return -1;
#ifdef DEBUG
	SDL_Log("Files read");
#endif
	return 0;
}

void TidalEngine::run() {
	SDL_Event event;
	while (m_running) {
		SDL_PollEvent(&event);
		if (event.type == SDL_QUIT) {
			m_running = false;
		}
		draw();
	}
}

void TidalEngine::cleanup() {
	PHYSFS_deinit();
	for (int i = 0; i < m_textures_num; i++) SDL_DestroyTexture(m_textures[i]);
	free(m_textures);
	SDL_DestroyRenderer(m_renderer);
	SDL_DestroyWindow(m_window);
	SDL_Quit();
	SDL_Log("Cleanup complete");
}

int TidalEngine::readfiles(const char *path) {
	if (PHYSFS_mount(path, NULL, 0) == 0) return -1;
#ifdef DEBUG
	SDL_Log("Path mounted");
#endif
	PHYSFS_Stat stat;
	if (PHYSFS_stat("", &stat) == 0) return -1;
#ifdef DEBUG
	SDL_Log("Path stats acquired");
#endif
	if (stat.filetype == PHYSFS_FILETYPE_DIRECTORY) {
		char **rc = PHYSFS_enumerateFiles("");
#ifdef DEBUG
		for (char** i = rc; *i != NULL; i++) printf(" * We've got [%s].\n", *i); //debug
		SDL_Log("Dir listed");
#endif
		for (char** i = rc; *i != NULL; i++) if (load_file(*i) < 0) return -1;
#ifdef DEBUG
		SDL_Log("Files loaded");
#endif
		PHYSFS_freeList(rc);
#ifdef DEBUG
		SDL_Log("List freed");
#endif
	} else {
		SDL_Log("Argument must be a directory");
		return -1;
	}
	return 0;
}

const char* TidalEngine::getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
	if (!dot || dot == filename) return "";
	return dot + 1;
}

int TidalEngine::load_file(const char* filename) {
	PHYSFS_Stat stat;
	if (PHYSFS_stat(filename, &stat) == 0) return -1;
	if (stat.filetype == PHYSFS_FILETYPE_REGULAR) {
#ifdef DEBUG
		SDL_Log("Is a regular file");
#endif
		const char* ext = getextension(filename);
		if (strcmp(ext, "bmp") == 0) {
			SDL_Surface* surface = SDL_LoadBMP(filename);
			if (!surface) return -1;
#ifdef DEBUG
			SDL_Log("Surface successfully created");
#endif
			m_textures_num++;
			m_textures = (SDL_Texture**)realloc(m_textures, m_textures_num*sizeof(SDL_Texture*));
			*(m_textures + m_textures_num-1) = SDL_CreateTextureFromSurface(m_renderer, surface);
			if (!*m_textures) return -1;
#ifdef DEBUG
			SDL_Log("Texture successfully created");
#endif
			SDL_FreeSurface(surface);
		}
		//Add more filetypes later
	}
	return 0;
}

void TidalEngine::draw() {
	SDL_SetRenderDrawColor(m_renderer, 0x00, 0x00, 0x00, 0x00);
	SDL_RenderClear(m_renderer);
	SDL_RenderCopy(m_renderer, *m_textures, NULL, NULL);
	SDL_RenderPresent(m_renderer);
}
