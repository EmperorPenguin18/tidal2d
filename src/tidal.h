//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __TIDAL_H__
#define __TIDAL_H__

#include <SDL2/SDL.h>
#include <physfs.h>
#include <cjson/cJSON.h>
#include <SDL2/SDL_ttf.h>
#include <chipmunk/chipmunk.h>
#include <SDL2/SDL_mixer.h>

#include <stdbool.h>

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
	SDL_AudioDeviceID audiodev;
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
	Mix_Chunk* data;
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
};
typedef struct Engine Engine;

Engine* Tidal_init(int, char*[]);
static char* read_data(const char*, size_t*);
static int read_files(Engine*, const char*);
static const char* getextension(const char*);
static void prepend(char*, const char*);

static int create_object(Engine*, char*, size_t);
static int create_texture(Engine*, SDL_Surface*, const char*);
static int create_font(Engine*, char*, size_t, int, const char*);
static int create_audio(Engine*, char*, size_t, const char*);

void Tidal_run(Engine*);
static void events(Engine*);
static void update(Engine*);
static void draw(Engine*);

void Tidal_cleanup(Engine*);

#endif
