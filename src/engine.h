//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __ENGINE_H__
#define __ENGINE_H__

#include "instance.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* The context struct. Keeps track of all state related
 * stuff, and asset arrays.
 */
struct Engine {
	SDL_Window* window;
	SDL_Renderer* renderer;
	bool running;
	Asset* assets;
	size_t assets_num;
	cpSpace* space;
	Instance* instances;
	size_t instances_num;
	Instance* inert_ins;
	size_t inert_ins_num;
	size_t* layers;
	size_t layers_num;
	char* first;
	size_t first_layer;
	SDL_AudioDeviceID audiodev;
	SDL_AudioSpec audio_buf;
	SDL_AudioSpec* music;
	lua_State* L;
	SDL_FRect win_rect;
};
typedef struct Engine Engine;

/* The functions that main() uses */
Engine* engine_init(int, char*[]);
void engine_run(void*);
void engine_cleanup(Engine*);

void instance_copy(Engine*, const char*, float, float);
void instance_destroy(Engine*, Instance*);
void event_handler(Engine*, event_t, Instance*);

#endif
