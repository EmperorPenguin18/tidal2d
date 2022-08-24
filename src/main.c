//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"

int main(int argc, char *argv[]) {
	Engine* engine = Tidal_init(argc, argv);
	if (engine == NULL) {
		SDL_Log("SDL error: %s", SDL_GetError());
		SDL_Log("PHYSFS error: %s", PHYSFS_getErrorByCode(PHYSFS_getLastErrorCode()));
		return 1;
	}
	Tidal_run(engine);
	Tidal_cleanup(engine);
	return 0;
}
