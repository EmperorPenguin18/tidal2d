//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __TIDAL_H__
#define __TIDAL_H__

#include <SDL2/SDL.h>
#include <cjson/cJSON.h>
#include <SDL2/SDL_FontCache.h>
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

struct Object {
	char* name;
	cJSON* data;
};
typedef struct Object Object;

struct Font {
	char* name;
	FC_Font* normal;
	FC_Font* bold;
};
typedef struct Font Font;

struct Audio {
	char* name;
	AudioSource* data;
};
typedef struct Audio Audio;

struct Instance {
	//uuid_t id;
	SDL_Rect dst;
	SDL_Texture* texture;
	Font* font;
	const char* text;
	cpBody* body;
	cpShape* shape;
};
typedef struct Instance Instance;

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
	Instance** ui;
	size_t ui_num;
	SDL_Rect ui_dst;
	SDL_Texture* ui_texture;
	FC_Font* ui_font;
	const char* ui_text;
};
typedef struct Engine Engine;

Engine* Tidal_init(int, char*[]);
void Tidal_run(Engine*);
void Tidal_cleanup(Engine*);
void Tidal_error();

#endif
