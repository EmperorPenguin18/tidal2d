//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "engine.h"
#include <SDL2/SDL_main.h>
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

int main(int argc, char *argv[]) {
	Engine* e = engine_init(argc, argv);
	if (e == NULL) return 1;
#ifdef __EMSCRIPTEN__
	emscripten_set_main_loop_arg(engine_run, e, 0, 1);
#else
	while (e->running) {
		engine_run(e);
	}
#endif
	engine_cleanup(e);
	e = NULL;
	return 0;
}
