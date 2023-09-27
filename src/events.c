//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include "events.h"

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

/* Check for events from the player */
event_t get_event() {
	SDL_Event event;
	SDL_PollEvent(&event);
	switch (event.type) {
		case SDL_QUIT:
			return TIDAL_EVENT_QUIT;
			break;
		case SDL_KEYDOWN:
			switch (event.key.keysym.sym) {
				case SDLK_w:
					return TIDAL_EVENT_KEYW;
					break;
				case SDLK_a:
					return TIDAL_EVENT_KEYA;
					break;
				case SDLK_s:
					return TIDAL_EVENT_KEYS;
					break;
				case SDLK_d:
					return TIDAL_EVENT_KEYD;
					break;
				case SDLK_SPACE:
					return TIDAL_EVENT_KEYSPACE;
					break;
				case SDLK_RETURN:
					return TIDAL_EVENT_KEYENTER;
					break;
			}
			break;
		case SDL_MOUSEBUTTONUP:
			switch (event.button.button) {
				case SDL_BUTTON_LEFT:
					return TIDAL_EVENT_MOUSELEFT;
					break;
				case SDL_BUTTON_RIGHT:
					return TIDAL_EVENT_MOUSERIGHT;
					break;
			}
			break;
	}
	return TIDAL_EVENT_ERR;
}
