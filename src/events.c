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
	} else if (strcmp(string, "animation_complete") == 0) {
		return TIDAL_EVENT_ANIMATION;
	} else if (strcmp(string, "timer_0") == 0) {
		return TIDAL_EVENT_TIMER_0;
	} else if (strcmp(string, "timer_1") == 0) {
		return TIDAL_EVENT_TIMER_1;
	} else if (strcmp(string, "timer_2") == 0) {
		return TIDAL_EVENT_TIMER_2;
	} else if (strcmp(string, "timer_3") == 0) {
		return TIDAL_EVENT_TIMER_3;
	} else if (strcmp(string, "timer_4") == 0) {
		return TIDAL_EVENT_TIMER_4;
	} else if (strcmp(string, "timer_5") == 0) {
		return TIDAL_EVENT_TIMER_5;
	} else if (strcmp(string, "timer_6") == 0) {
		return TIDAL_EVENT_TIMER_6;
	} else if (strcmp(string, "timer_7") == 0) {
		return TIDAL_EVENT_TIMER_7;
	} else if (strcmp(string, "timer_8") == 0) {
		return TIDAL_EVENT_TIMER_8;
	} else if (strcmp(string, "timer_9") == 0) {
		return TIDAL_EVENT_TIMER_9;
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
