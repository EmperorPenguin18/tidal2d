//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __TIDAL_H__
#define __TIDAL_H__

#include <SDL2/SDL.h>
#include <cjson/cJSON.h>
#include <SDL2/SDL_ttf.h>
#include <chipmunk/chipmunk.h>
#include <stdbool.h>
#include <soloud/soloud_c.h>

#ifndef STATIC
#include <dlfcn.h>
#endif

struct Texture {
	char* name;
	SDL_Texture* data;
};
typedef struct Texture Texture;
struct Object {
	cJSON* json;
	SDL_Rect dst;
	SDL_Texture* texture;
	SDL_Texture* text;
	cpBody* body;
	cpShape* shape;
};
typedef struct Object Object;
struct Font {
	char* name;
	char* raw;
	SDL_RWops* rw;
	TTF_Font* data;
};
typedef struct Font Font;
struct Audio {
	char* name;
	AudioSource* data;
};
typedef struct Audio Audio;
struct Engine {
	unsigned int width;
	unsigned int height;
	SDL_Window* window;
	SDL_Renderer* renderer;
	Texture* textures;
	size_t textures_num;
	bool running;
	Object* objects;
	size_t objects_num;
	Font* fonts;
	size_t fonts_num;
	cpSpace* space;
	Audio* audio;
	size_t audio_num;
	Soloud* soloud;
};
typedef struct Engine Engine;

Engine* Tidal_init(int, char*[]);
void Tidal_run(Engine*);
void Tidal_cleanup(Engine*);
void Tidal_error();

#endif
