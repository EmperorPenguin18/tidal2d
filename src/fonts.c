//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "fonts.h"

static void font_draw(SDL_Renderer* renderer, stbtt_fontinfo* font, int s, SDL_Rect rect, unsigned char *text)
{
  float scale = stbtt_ScaleForPixelHeight(font, s);
  int ascent = 0;
  stbtt_GetFontVMetrics(font, &ascent, 0, 0);
  int baseline = ascent*scale;
  void* pixels = malloc(4*30*30*strlen(text));

  int x_cursor = 0;
  while (*text) {
	int advance, lsb, x0, y0, x1, y1;

	stbtt_GetCodepointHMetrics(font, *text, &advance, &lsb);
	stbtt_GetCodepointBitmapBox(font, *text, scale, scale, &x0, &y0, &x1, &y1);

	unsigned char *pixel = pixels + (baseline+y0 * 30*strlen(text) * 4) + (x_cursor+x0 * 4);
	stbtt_MakeCodepointBitmap(font,
		pixel,
		4*(x1-x0),
		4*(y1-y0),
		30*strlen(text)*4,
		2*scale, scale,
		*text);

	x_cursor += (advance*scale);
	if (*(text+1))
		x_cursor += (scale*stbtt_GetCodepointKernAdvance(font, *text, *(text+1)));

	text++;
  }

  SDL_Surface* surface = SDL_CreateRGBSurfaceWithFormat(pixels, x_cursor, 30, 4, SDL_PIXELFORMAT_ARGB8888);
  free(pixels);
  SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
  SDL_DestroySurface(surface);
  SDL_RenderCopy(renderer, texture, NULL, rect);
  SDL_DestroyTexture(texture);
}
