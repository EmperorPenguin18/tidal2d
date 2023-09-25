//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include "common.h"

#include <SDL2/SDL.h>
#include <stdarg.h>

const char* getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
	if (!dot || dot == filename) return "";
	return dot + 1;
}

const char* basename(const char* filename) {
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

event_t str2ev(const char* string) {
	if (strcmp(string, "collision") == 0) {
		return TIDAL_EVENT_COLLISION;
	} else if (strcmp(string, "quit") == 0) {
		return TIDAL_EVENT_QUIT;
	} else if (strcmp(string, "key_w") == 0) {
		return TIDAL_EVENT_KEYW;
	} else if (strcmp(string, "key_a") == 0) {
		return TIDAL_EVENT_KEYA;
	} else if (strcmp(string, "key_s") == 0) {
		return TIDAL_EVENT_KEYS;
	} else if (strcmp(string, "key_d") == 0) {
		return TIDAL_EVENT_KEYD;
	} else if (strcmp(string, "key_space") == 0) {
		return TIDAL_EVENT_KEYSPACE;
	} else if (strcmp(string, "key_enter") == 0) {
		return TIDAL_EVENT_KEYENTER;
	} else if (strcmp(string, "mouse_left") == 0) {
		return TIDAL_EVENT_MOUSELEFT;
	} else if (strcmp(string, "mouse_right") == 0) {
		return TIDAL_EVENT_MOUSERIGHT;
	} else if (strcmp(string, "creation") == 0) {
		return TIDAL_EVENT_CREATION;
	} else if (strcmp(string, "destruction") == 0) {
		return TIDAL_EVENT_DESTRUCTION;
	} else if (strcmp(string, "check_ui") == 0) {
		return TIDAL_EVENT_CHECKUI;
	} else if (strcmp(string, "leave") == 0) {
		return TIDAL_EVENT_LEAVE;
	}
	return TIDAL_EVENT_ERR;
}

int ERROR(const char* format, ...) {
	va_list arg;
	va_start(arg, format);
	SDL_LogError(SDL_LOG_CATEGORY_ERROR, format, arg);
	va_end(arg);
	return -1;
}
