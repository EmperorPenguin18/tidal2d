//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __ENGINE_H__
#define __ENGINE_H__

#include "instance.h"

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

struct var {
	char* name;
	size_t len;
	void* data;
};
typedef struct var var;

/* The context struct. Keeps track of all state related
 * stuff, and asset arrays.
 */
struct Engine {
#ifndef NDEBUG
	float* fps;
#endif
	SDL_Window* window;
	SDL_Renderer* renderer;
	bool running;
	bool reload;
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
	var* vars;
	size_t var_num;
	SDL_TimerID timers[10];
	bool timer_triggered[10];
	SDL_Cursor* cursor;
	SDL_Thread** threads;
	size_t thread_num;
};
typedef struct Engine Engine;

/* The functions that main() uses */
Engine* engine_init(int, char*[]);
void engine_run(void*);
void engine_cleanup(Engine*);

Instance* instance_copy(Engine*, const char*, float, float);
void instance_destroy(Engine*, Instance*);
void event_handler(Engine*, event_t, Instance*);

#endif
