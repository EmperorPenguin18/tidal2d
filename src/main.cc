//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"

int main(int argc, char *argv[]) {
	TidalEngine engine;
	if (engine.init(argc, argv) < 0) {
		SDL_Log("SDL error: %s", SDL_GetError());
		SDL_Log("PHYSFS error: %s", PHYSFS_getErrorByCode(PHYSFS_getLastErrorCode()));
		return 1;
	}
	engine.run();
	return 0;
}
