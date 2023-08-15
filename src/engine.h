//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __ENGINE_H__
#define __ENGINE_H__

#include <stdbool.h>

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
	size_t* layers;
	size_t layers_num;
	Asset* first_object;
	size_t first_layer;
	Instance** ui;
	size_t ui_num;
	SDL_Rect ui_dst;
	SDL_Texture* ui_texture;
	FC_Font* ui_font;
	const char* ui_text;
	cpCollisionHandler* col_hand;
	Asset* events[EVENTS_NUM];
	size_t events_num[EVENTS_NUM];
	SDL_AudioDeviceID audiodev;
};
typedef struct Engine Engine;

/* The functions that main() uses */
Engine* engine_init(int, char*[]);
void engine_run(Engine*);
void engine_cleanup(Engine*);
void engine_error();

#endif
