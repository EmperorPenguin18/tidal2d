//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "engine.h"
#include <SDL2/SDL_main.h>

int main(int argc, char *argv[]) {
	Engine* e = engine_init(argc, argv);
	if (e == NULL) {
		engine_error();
		return 1;
	}
	engine_run(e);
	engine_cleanup(e);
	e = NULL;
	return 0;
}
