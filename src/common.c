//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include <SDL_log.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include "common.h"

const char* getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
	if (!dot || dot == filename) return "";
	return dot + 1;
}

const char* base(const char* filename) {
	const char *dot = strrchr(filename, '/');
	if (!dot || dot == filename) {
		dot = strrchr(filename, '\\');
		if (!dot || dot == filename) return "";
	}
	return dot + 1;
}

int ERROR(const char* format, ...) {
	va_list arg;
	va_start(arg, format);
	//fprintf(stderr, "[%s: %d] ", __FILE__, __LINE__);
	SDL_LogMessageV(SDL_LOG_CATEGORY_ERROR, SDL_LOG_PRIORITY_ERROR, format, arg);
	va_end(arg);
	return -1;
}
