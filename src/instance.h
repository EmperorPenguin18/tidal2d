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
	PHYSICS_STATIC,
	PHYSICS_NUM
};
typedef enum physics_t physics_t;

typedef struct Action Action;

/* Instance definition. These are organized into layers
 * and looped over frequently. Could definitely use some
 * optimization
 */
struct Instance {
	char* name;
	char* id;
	SDL_Rect dst;
	SDL_Texture* texture;
	void* font; //stbtt_fontinfo*
	char* text;
	physics_t physics;
	cpBody* body;
	cpShape* shape;
	size_t layer;
	Action* actions[EVENTS_NUM];
	size_t actions_num[EVENTS_NUM];
	bool* colliding;
};
typedef struct Instance Instance;

int instance_create(Asset*, SDL_Renderer*, Asset*, size_t, Instance*, size_t*);
void instance_cleanup(Instance*);

#endif
