//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"

int main() {
	TidalEngine engine;
	engine.init();
	engine.run();
	engine.cleanup();
	return 0;
}
