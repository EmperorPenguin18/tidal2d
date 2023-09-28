//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include <SDL_log.h>
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
	if (!dot || dot == filename) return "";
	return dot + 1;
}

/* UUIDs are used to identify an instance, because two instances
 * could be based on the same object.
 */
char* gen_uuid() {
	char v[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
	//3fb17ebc-bc38-4939-bc8b-74f2443281d4
	//8 dash 4 dash 4 dash 4 dash 12
	char* buf = (char*)calloc(37, 1);
	
	//gen random for all spaces because lazy
	for(int i = 0; i < 36; ++i) {
		buf[i] = v[rand()%16];
	}
	
	//put dashes in place
	buf[8] = '-';
	buf[13] = '-';
	buf[18] = '-';
	buf[23] = '-';
	
	//needs end byte
	buf[36] = '\0';
	
	return buf;
}

int ERROR(const char* format, ...) {
	va_list arg;
	va_start(arg, format);
	SDL_LogError(SDL_LOG_CATEGORY_ERROR, format, arg);
	va_end(arg);
	return -1;
}
