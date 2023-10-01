//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __INSTANCE_H__
#define __INSTANCE_H__

#include <chipmunk/chipmunk.h>

#include "assets.h"
#include "events.h"

enum physics_t {
	PHYSICS_NONE,
	PHYSICS_BOX,
	PHYSICS_BOX_STATIC,
	PHYSICS_TRIANGLE,
	PHYSICS_TRIANGLE_STATIC,
	PHYSICS_GHOST,
	PHYSICS_NUM
};
typedef enum physics_t physics_t;

struct texture {
	SDL_Texture* atlas;
	int* x;
	int* y;
	size_t frames;
};
typedef struct texture texture;

typedef struct Action Action;

/* Instance definition. These are organized into layers
 * and looped over frequently. Could definitely use some
 * optimization
 */
struct Instance {
	char* name;
	char* id;
	SDL_FRect dst;
	texture texture;
	font* font;
	char* text;
	physics_t physics;
	cpBody* body;
	cpShape* shape;
	size_t layer;
	Action* actions[EVENTS_NUM];
	size_t actions_num[EVENTS_NUM];
	int* colliding;
	size_t frame;
	int end_frame;
	SDL_TimerID timer;
	cpCollisionType collision_type;
};
typedef struct Instance Instance;

int instance_create(Asset*, SDL_Renderer*, Asset*, size_t, Instance*, size_t*);
void instance_cleanup(Instance*);

#endif
