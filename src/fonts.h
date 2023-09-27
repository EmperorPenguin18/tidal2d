//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __FONTS_H__
#define __FONTS_H__

#include <SDL.h>
#include <stb_truetype.h>

stbtt_fontinfo* load_font(unsigned char*, const size_t);
void font_draw(SDL_Renderer*, stbtt_fontinfo*, float, int, int, char*);

#endif
