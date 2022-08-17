//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#pragma once
#include <SDL2/SDL.h>
#include <physfs.h>
#include <cjson/cJSON.h>

class TidalEngine {
	public:
		TidalEngine();
		~TidalEngine();

		int init(int, char*[]);
		void run();

		struct Texture {
			char* name;
			SDL_Texture* data;
		};
		struct Object {
			cJSON* json;
			SDL_Rect dst;
			SDL_Texture* texture;
		};
	private:
		unsigned int m_width;
		unsigned int m_height;
		SDL_Window* m_window;
		SDL_Renderer* m_renderer;
		Texture* m_textures;
		size_t m_textures_num;
		bool m_running;
		Object* m_objects;
		size_t m_objects_num;

		void cleanup();
		int readfiles(const char*);
		const char* getextension(const char*);
		void prepend(char*, const char*);
		void draw();
		void events();
		char* read_data(const char*, size_t*);
		int create_object(char*, size_t);
		int create_texture(SDL_Surface*, const char*);
};
