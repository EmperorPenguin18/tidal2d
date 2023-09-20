//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "physics.h"

//#undef PHYSAC_H
#define PHYSAC_IMPLEMENTATION
//#define PHYSAC_STATIC
#define PHYSAC_NO_THREADS
#define PHYSAC_STANDALONE
#ifndef NDEBUG
#define PHYSAC_DEBUG
#endif
#include <physac.h>

int physics_init(SDL_Thread** thread) {
	*thread = SDL_CreateThread(PhysicsLoop, NULL, NULL);
	if (!*thread) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Create thread failed: %s", SDL_GetError());
		return -1;
	}
	SetPhysicsTimeStep(10.0);
	InitPhysics();
	return 0;
}

void physics_close(SDL_Thread* thread) {
	//SDL_WaitThread(thread, NULL);
	ClosePhysics();
}
