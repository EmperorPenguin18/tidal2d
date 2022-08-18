//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#pragma once
#include <SDL2/SDL.h>
#include <physfs.h>
#include <cjson/cJSON.h>
#include <SDL2/SDL_ttf.h>
#include <chipmunk/chipmunk.h>
#include <SDL2/SDL_mixer.h>

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
			SDL_Texture* text;
			cpBody* body;
			cpShape* shape;
			SDL_AudioDeviceID audiodev;
		};
		struct Font {
			char* name;
			char* raw;
			SDL_RWops* rw;
			TTF_Font* data;
		};
		struct Audio {
			char* name;
			Mix_Chunk* data;
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
		Font* m_fonts;
		size_t m_fonts_num;
		cpSpace* m_space;
		Audio* m_audio;
		size_t m_audio_num;

		void cleanup();
		int readfiles(const char*);
		const char* getextension(const char*);
		void prepend(char*, const char*);
		void draw();
		void events();
		void update();
		char* read_data(const char*, size_t*);
		int create_object(char*, size_t);
		int create_texture(SDL_Surface*, const char*);
		int create_font(char*, size_t, int, const char*);
		int create_audio(char*, size_t, const char*);
};
