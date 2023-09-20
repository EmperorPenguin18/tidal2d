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
#include <chipmunk/chipmunk.h>

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
	/*Instance** ui;
	size_t ui_num;
	SDL_Rect ui_dst;
	SDL_Texture* ui_texture;
	FC_Font* ui_font;
	const char* ui_text;*/
	cpCollisionHandler* col_hand;
	SDL_AudioDeviceID audiodev;
	SDL_AudioSpec* music;
};

/* The functions that main() uses */
Engine* engine_init(int, char*[]);
void engine_run(Engine*);
void engine_cleanup(Engine*);
void action_spawn(Engine*, Instance*, void**);
void action_destroy(Engine*, Instance*, void**);

#endif
