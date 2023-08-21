//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "fonts.h"

#define STB_TRUETYPE_IMPLEMENTATION
#include <stb/stb_truetype.h>

stbtt_fontinfo* load_font(unsigned char* in, const size_t len) {
	stbtt_fontinfo* font = malloc(sizeof(stbtt_fontinfo));
	if (stbtt_InitFont(font, in, stbtt_GetFontOffsetForIndex(in, 0)) == 0) return NULL;
	return font;
}

/*static SDL_Surface* render_font(stbtt_fontinfo* font, float pixels, char* text, int* total_width, int* total_height) {
	*total_width = 0;
	*total_height = 0;
	int bpp = 4;
	float scale = stbtt_ScaleForPixelHeight(font, pixels);
	int ascent = 0;
	stbtt_GetFontVMetrics(font, &ascent, 0, 0);
	int baseline = ascent*scale;
	unsigned char* bitmap = NULL;
	int x_cursor = 0;
	for (int i = 0; text[i]; i++) {
		int advance, lsb, x0, y0, x1, y1;
		stbtt_GetCodepointBitmapBox(font, text[i], scale, scale, &x0, &y0, &x1, &y1);
		int width = x1 - x0;
		*total_width += width;
		int height = y1 - y0;
		*total_height += height;
		//bitmap = realloc(bitmap, total_width*total_height*bpp*sizeof(unsigned char));
		bitmap = realloc(bitmap, (*total_width)*(*total_height + baseline)*bpp*sizeof(unsigned char));
		unsigned char* pixel = bitmap + ((baseline+y0) * (*total_width) * bpp) + ((x_cursor+x0) * bpp);
		stbtt_MakeCodepointBitmap(font, pixel, width*bpp, height*bpp, (*total_width)*bpp, scale, scale, text[i]);
		stbtt_GetCodepointHMetrics(font, text[i], &advance, &lsb);
		x_cursor += advance*scale;
		if (text[i+1])
			x_cursor += (scale*stbtt_GetCodepointKernAdvance(font, text[i], text[i+1]));
	}
	int depth = 32;
	int pitch = (*total_width)*bpp;
	SDL_Surface* surface = SDL_CreateRGBSurfaceWithFormatFrom(bitmap, *total_width, *total_height+baseline, depth, pitch, SDL_PIXELFORMAT_ARGB8888);
	if (!surface) {
		SDL_Log("Font render failed: %s", SDL_GetError());
		return NULL;
	}
	return surface;
}*/

static unsigned char* render_char(stbtt_fontinfo* font, float pixels, char c, int* width, int* height, int* xoff, int* yoff, int* baseline) {
	float scale = stbtt_ScaleForPixelHeight(font, pixels);
	int ascent = 0;
	stbtt_GetFontVMetrics(font, &ascent, 0, 0);
	*baseline = ascent*scale;
	return stbtt_GetCodepointBitmap(font, scale, scale, c, width, height, xoff, yoff);
}

void font_draw(SDL_Renderer* renderer, stbtt_fontinfo* font, float pixels, int x, int y, char *text) {
	if (!font || !text) return;
	int x_cursor = 0;
	for (int i = 0; text[i]; i++) {
		SDL_Rect r;
		int xoff, yoff, baseline;
		unsigned char* bitmap = render_char(font, pixels, text[i], &r.w, &r.h, &xoff, &yoff, &baseline);
		r.x = x + x_cursor + xoff;
		x_cursor += r.w + xoff;
		r.y = y + yoff + baseline;
		SDL_Surface* surface = SDL_CreateRGBSurfaceWithFormatFrom(bitmap, r.w, r.h, 8, r.w, SDL_PIXELFORMAT_INDEX8);
		SDL_Palette* palette = surface->format->palette;
		for (int j = 0; j < palette->ncolors; j++) {
			palette->colors[j].r = 0;
			palette->colors[j].g = 0;
			palette->colors[j].b = 0;
			palette->colors[j].a = SDL_ALPHA_OPAQUE;
		}
		SDL_SetColorKey(surface, SDL_TRUE, 0);
		SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
		SDL_FreeSurface(surface);
		stbtt_FreeBitmap(bitmap, NULL);
		SDL_RenderCopy(renderer, texture, NULL, &r);
		SDL_DestroyTexture(texture);
	}
}
