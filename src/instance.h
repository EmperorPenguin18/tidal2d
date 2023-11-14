//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __INSTANCE_H__
#define __INSTANCE_H__

#include <chipmunk/chipmunk.h>

#include "assets.h"
#include "events.h"

struct texture {
	SDL_Texture* atlas;
	int* x;
	int* y;
	size_t frames;
};
typedef struct texture texture;

typedef struct Action Action;

typedef unsigned long long ID;

/* Instance definition. These are organized into layers
 * and looped over frequently. Could definitely use some
 * optimization
 */
struct Instance {
	char* name;
	ID id;
	SDL_FRect dst;
	texture texture;
	font* font;
	char* text;
	cpBody* body;
	cpShape* shape;
	size_t layer;
	Action* actions[EVENTS_NUM];
	size_t actions_num[EVENTS_NUM];
	int* colliding;
	size_t frame;
	int end_frame;
	bool inc_frame;
	SDL_TimerID timer;
	cpCollisionType collision_type;
};
typedef struct Instance Instance;

int instance_create(Asset*, SDL_Renderer*, Asset*, size_t, cpSpace*, Instance*);
void instance_cleanup(cpSpace*, Instance*);

#endif
