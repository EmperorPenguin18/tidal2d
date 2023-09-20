//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __INSTANCE_H__
#define __INSTANCE_H__

struct Instance;
typedef struct Instance Instance;

#include "common.h"
#include "actions.h"
#include "assets.h"
#include "physics.h"

#include <SDL2/SDL.h>
#include <stb_truetype.h>

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
	PhysicsBody body;
	size_t layer;
	Action* actions[EVENTS_NUM];
	size_t actions_num[EVENTS_NUM];
};

int instance_create(Asset*, SDL_Renderer*, Asset*, size_t, Instance*, size_t*);
void instance_cleanup(Instance*);

#endif
