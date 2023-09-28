//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __FONTS_H__
#define __FONTS_H__

#include <SDL.h>

#include <stb_truetype.h>

struct font_t {
	SDL_Surface* surface;
	stbtt_bakedchar* chars;
};
typedef struct font_t font_t;

font_t* load_font(const unsigned char*, const size_t);
void font_draw(SDL_Renderer*, font_t*, int, int, char*);

#endif
