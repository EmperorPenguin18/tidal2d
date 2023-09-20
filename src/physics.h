//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __PHYSICS_H__
#define __PHYSICS_H__

#define PHYSAC_STANDALONE
#include <physac.h>

#include <SDL2/SDL.h>

enum physics_t {
	PHYSICS_NONE,
	PHYSICS_BOX,
	PHYSICS_STATIC,
	PHYSICS_NUM
};
typedef enum physics_t physics_t;

int physics_init(SDL_Thread**);
void physics_close(SDL_Thread*);

#endif
