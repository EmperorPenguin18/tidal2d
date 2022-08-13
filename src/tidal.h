//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#pragma once
#include <SDL.h>

class TidalEngine {
	public:
		TidalEngine();
		~TidalEngine();
	private:
		SDL_Window win;
		void readfiles();
}
