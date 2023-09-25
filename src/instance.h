//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __INSTANCE_H__
#define __INSTANCE_H__

struct Instance;
typedef struct Instance Instance;

#include "common.h"
#include "actions.h"
#include "assets.h"

#include <SDL2/SDL.h>
#include <chipmunk/chipmunk.h>
#include <stb_truetype.h>

enum physics_t {
	PHYSICS_NONE,
	PHYSICS_BOX,
	PHYSICS_STATIC,
	PHYSICS_NUM
};
typedef enum physics_t physics_t;

/* Instance definition. These are organized into layers
 * and looped over frequently. Could definitely use some
 * optimization
 */
struct Instance {
	char* name;
	char* id;
	SDL_Rect dst;
	SDL_Texture* texture;
	stbtt_fontinfo* font;
	char* text;
	physics_t physics;
	cpBody* body;
	cpShape* shape;
	size_t layer;
	Action* actions[EVENTS_NUM];
	size_t actions_num[EVENTS_NUM];
	bool* colliding;
};

int instance_create(Asset*, SDL_Renderer*, Asset*, size_t, Instance*, size_t*);
void instance_cleanup(Instance*);

#endif
