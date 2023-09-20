//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __ENGINE_H__
#define __ENGINE_H__

struct Engine;
typedef struct Engine Engine;

#include "common.h"
#include "assets.h"
#include "instance.h"

#include <stdbool.h>
#include <SDL2/SDL.h>

/* The context struct. Keeps track of all state related
 * stuff, and asset arrays.
 */
struct Engine {
	SDL_Window* window;
	SDL_Renderer* renderer;
	bool running;
	Asset* assets;
	size_t assets_num;
	Instance* instances;
	size_t instances_num;
	Instance* inert_ins;
	size_t inert_ins_num;
	size_t* layers;
	size_t layers_num;
	char* first;
	size_t first_layer;
	SDL_AudioDeviceID audiodev;
	SDL_AudioSpec* music;
	SDL_Thread* phys_thread;
};

/* The functions that main() uses */
Engine* engine_init(int, char*[]);
void engine_run(Engine*);
void engine_cleanup(Engine*);

void action_spawn(Engine*, Instance*, void**);
void action_destroy(Engine*, Instance*, void**);

#endif
