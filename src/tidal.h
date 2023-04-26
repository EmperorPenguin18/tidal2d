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

/* The different event types. Used when defining objects and by
 * the event handler.
 */
enum event_t {
	TIDAL_EVENT_COLLISION,
	TIDAL_EVENT_QUIT,
	TIDAL_EVENT_KEYW,
	TIDAL_EVENT_KEYA,
	TIDAL_EVENT_KEYS,
	TIDAL_EVENT_KEYD,
	TIDAL_EVENT_KEYSPACE,
	TIDAL_EVENT_KEYENTER,
	TIDAL_EVENT_MOUSELEFT,
	TIDAL_EVENT_MOUSERIGHT,
	TIDAL_EVENT_CREATION,
	TIDAL_EVENT_DESTRUCTION,
	TIDAL_EVENT_CHECKUI,
	TIDAL_EVENT_LEAVE,
	EVENTS_NUM
};
typedef enum event_t event_t;

/* Asset type definitions. Should probably clean this up
 * and unify them with void*
 */
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
struct Action {
	char* id;
	const cJSON* data;
};
typedef struct Action Action;

/* Instance definition. These are organized into layers
 * and looped over frequently. Could definitely use some
 * optimization
 */
struct Instance {
	char* id;
	SDL_Rect dst;
	SDL_Texture* texture;
	Font* font;
	const char* text;
	cpBody* body;
	cpShape* shape;
	size_t layer;
};
typedef struct Instance Instance;

/* The context struct. Keeps track of all state related
 * stuff, and asset arrays.
 */
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
	cpCollisionHandler* col_hand;
	Action* events[EVENTS_NUM];
	size_t events_num[EVENTS_NUM];
};
typedef struct Engine Engine;

/* The functions that main() uses */
Engine* Tidal_init(int, char*[]);
void Tidal_run(Engine*);
void Tidal_cleanup(Engine*);
void Tidal_error();

#endif
