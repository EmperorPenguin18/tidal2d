//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#pragma once
#include <SDL2/SDL.h>
#include <physfs.h>

class TidalEngine {
	public:
		TidalEngine();
		~TidalEngine();

		int init(int, char*[]);
		void run();
	private:
		unsigned int m_width;
		unsigned int m_height;
		SDL_Window* m_window;
		SDL_Renderer* m_renderer;
		SDL_Texture** m_textures;
		size_t m_textures_num;
		bool m_running;

		void cleanup();
		int readfiles(const char*);
		const char* getextension(const char*);
		int load_file(const char*);
		void draw();
};
