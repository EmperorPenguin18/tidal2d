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
//#include <uuid/uuid.h>

#ifndef STATIC
#include <dlfcn.h>
#endif

struct Texture {
	char* name;
	SDL_Texture* data;
};
typedef struct Texture Texture;

struct Instance {
	//uuid_t id;
	SDL_Rect dst;
	SDL_Texture* texture;
	SDL_Texture* text;
	cpBody* body;
	cpShape* shape;
};
typedef struct Instance Instance;

struct Object {
	char* name;
	cJSON* data;
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
	Instance* instances;
	size_t instances_num;
	size_t* layers;
	size_t layers_num;
	Object* first_object;
	size_t first_layer;
};
typedef struct Engine Engine;

Engine* Tidal_init(int, char*[]);
void Tidal_run(Engine*);
void Tidal_cleanup(Engine*);
void Tidal_error();

#endif
