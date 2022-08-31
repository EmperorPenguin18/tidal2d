//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"

int main(int argc, char *argv[]) {
	Engine* engine = Tidal_init(argc, argv);
	if (engine == NULL) {
		Tidal_error();
		return 1;
	}
	Tidal_run(engine);
	Tidal_cleanup(engine);
	engine = NULL;
	return 0;
}
