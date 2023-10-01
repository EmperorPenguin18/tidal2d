//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include "events.h"

event_t str2ev(const char* string) {
	if (strcmp(string, "collision") == 0) {
		return TIDAL_EVENT_COLLISION_0;
	} else if (strcmp(string, "collision_0") == 0) {
		return TIDAL_EVENT_COLLISION_0;
	} else if (strcmp(string, "collision_1") == 0) {
		return TIDAL_EVENT_COLLISION_1;
	} else if (strcmp(string, "collision_2") == 0) {
		return TIDAL_EVENT_COLLISION_2;
	} else if (strcmp(string, "collision_3") == 0) {
		return TIDAL_EVENT_COLLISION_3;
	} else if (strcmp(string, "collision_4") == 0) {
		return TIDAL_EVENT_COLLISION_4;
	} else if (strcmp(string, "collision_5") == 0) {
		return TIDAL_EVENT_COLLISION_5;
	} else if (strcmp(string, "collision_6") == 0) {
		return TIDAL_EVENT_COLLISION_6;
	} else if (strcmp(string, "collision_7") == 0) {
		return TIDAL_EVENT_COLLISION_7;
	} else if (strcmp(string, "collision_8") == 0) {
		return TIDAL_EVENT_COLLISION_8;
	} else if (strcmp(string, "collision_9") == 0) {
		return TIDAL_EVENT_COLLISION_9;
	} else if (strcmp(string, "quit") == 0) {
		return TIDAL_EVENT_QUIT;
	} else if (strcmp(string, "key_f1") == 0) {
		return TIDAL_EVENT_KEY_F1;
	} else if (strcmp(string, "key_f2") == 0) {
		return TIDAL_EVENT_KEY_F2;
	} else if (strcmp(string, "key_f3") == 0) {
		return TIDAL_EVENT_KEY_F3;
	} else if (strcmp(string, "key_f4") == 0) {
		return TIDAL_EVENT_KEY_F4;
	} else if (strcmp(string, "key_f5") == 0) {
		return TIDAL_EVENT_KEY_F5;
	} else if (strcmp(string, "key_f6") == 0) {
		return TIDAL_EVENT_KEY_F6;
	} else if (strcmp(string, "key_f7") == 0) {
		return TIDAL_EVENT_KEY_F7;
	} else if (strcmp(string, "key_f8") == 0) {
		return TIDAL_EVENT_KEY_F8;
	} else if (strcmp(string, "key_f9") == 0) {
		return TIDAL_EVENT_KEY_F9;
	} else if (strcmp(string, "key_f10") == 0) {
		return TIDAL_EVENT_KEY_F10;
	} else if (strcmp(string, "key_f11") == 0) {
		return TIDAL_EVENT_KEY_F11;
	} else if (strcmp(string, "key_f12") == 0) {
		return TIDAL_EVENT_KEY_F12;
	} else if (strcmp(string, "key_1") == 0) {
		return TIDAL_EVENT_KEY_1;
	} else if (strcmp(string, "key_2") == 0) {
		return TIDAL_EVENT_KEY_2;
	} else if (strcmp(string, "key_3") == 0) {
		return TIDAL_EVENT_KEY_3;
	} else if (strcmp(string, "key_4") == 0) {
		return TIDAL_EVENT_KEY_4;
	} else if (strcmp(string, "key_5") == 0) {
		return TIDAL_EVENT_KEY_5;
	} else if (strcmp(string, "key_6") == 0) {
		return TIDAL_EVENT_KEY_6;
	} else if (strcmp(string, "key_7") == 0) {
		return TIDAL_EVENT_KEY_7;
	} else if (strcmp(string, "key_8") == 0) {
		return TIDAL_EVENT_KEY_8;
	} else if (strcmp(string, "key_9") == 0) {
		return TIDAL_EVENT_KEY_9;
	} else if (strcmp(string, "key_0") == 0) {
		return TIDAL_EVENT_KEY_0;
	} else if (strcmp(string, "key_q") == 0) {
		return TIDAL_EVENT_KEY_Q;
	} else if (strcmp(string, "key_w") == 0) {
		return TIDAL_EVENT_KEY_W;
	} else if (strcmp(string, "key_e") == 0) {
		return TIDAL_EVENT_KEY_E;
	} else if (strcmp(string, "key_r") == 0) {
		return TIDAL_EVENT_KEY_R;
	} else if (strcmp(string, "key_t") == 0) {
		return TIDAL_EVENT_KEY_T;
	} else if (strcmp(string, "key_y") == 0) {
		return TIDAL_EVENT_KEY_Y;
	} else if (strcmp(string, "key_u") == 0) {
		return TIDAL_EVENT_KEY_U;
	} else if (strcmp(string, "key_i") == 0) {
		return TIDAL_EVENT_KEY_I;
	} else if (strcmp(string, "key_o") == 0) {
		return TIDAL_EVENT_KEY_O;
	} else if (strcmp(string, "key_p") == 0) {
		return TIDAL_EVENT_KEY_P;
	} else if (strcmp(string, "key_a") == 0) {
		return TIDAL_EVENT_KEY_A;
	} else if (strcmp(string, "key_s") == 0) {
		return TIDAL_EVENT_KEY_S;
	} else if (strcmp(string, "key_d") == 0) {
		return TIDAL_EVENT_KEY_D;
	} else if (strcmp(string, "key_f") == 0) {
		return TIDAL_EVENT_KEY_F;
	} else if (strcmp(string, "key_g") == 0) {
		return TIDAL_EVENT_KEY_G;
	} else if (strcmp(string, "key_h") == 0) {
		return TIDAL_EVENT_KEY_H;
	} else if (strcmp(string, "key_j") == 0) {
		return TIDAL_EVENT_KEY_J;
	} else if (strcmp(string, "key_k") == 0) {
		return TIDAL_EVENT_KEY_K;
	} else if (strcmp(string, "key_l") == 0) {
		return TIDAL_EVENT_KEY_L;
	} else if (strcmp(string, "key_z") == 0) {
		return TIDAL_EVENT_KEY_Z;
	} else if (strcmp(string, "key_x") == 0) {
		return TIDAL_EVENT_KEY_X;
	} else if (strcmp(string, "key_c") == 0) {
		return TIDAL_EVENT_KEY_C;
	} else if (strcmp(string, "key_v") == 0) {
		return TIDAL_EVENT_KEY_V;
	} else if (strcmp(string, "key_b") == 0) {
		return TIDAL_EVENT_KEY_B;
	} else if (strcmp(string, "key_n") == 0) {
		return TIDAL_EVENT_KEY_N;
	} else if (strcmp(string, "key_m") == 0) {
		return TIDAL_EVENT_KEY_M;
	} else if (strcmp(string, "key_space") == 0) {
		return TIDAL_EVENT_KEY_SPACE;
	} else if (strcmp(string, "key_enter") == 0) {
		return TIDAL_EVENT_KEY_ENTER;
	} else if (strcmp(string, "key_up") == 0) {
		return TIDAL_EVENT_KEY_UP;
	} else if (strcmp(string, "key_right") == 0) {
		return TIDAL_EVENT_KEY_RIGHT;
	} else if (strcmp(string, "key_down") == 0) {
		return TIDAL_EVENT_KEY_DOWN;
	} else if (strcmp(string, "key_left") == 0) {
		return TIDAL_EVENT_KEY_LEFT;
	} else if (strcmp(string, "keyp_w") == 0) {
		return TIDAL_EVENT_KEYP_W;
	} else if (strcmp(string, "keyp_a") == 0) {
		return TIDAL_EVENT_KEYP_A;
	} else if (strcmp(string, "keyp_s") == 0) {
		return TIDAL_EVENT_KEYP_S;
	} else if (strcmp(string, "keyp_d") == 0) {
		return TIDAL_EVENT_KEYP_D;
	} else if (strcmp(string, "keyr_w") == 0) {
		return TIDAL_EVENT_KEYR_W;
	} else if (strcmp(string, "keyr_a") == 0) {
		return TIDAL_EVENT_KEYR_A;
	} else if (strcmp(string, "keyr_s") == 0) {
		return TIDAL_EVENT_KEYR_S;
	} else if (strcmp(string, "keyr_d") == 0) {
		return TIDAL_EVENT_KEYR_D;
	} else if (strcmp(string, "keyp_wd") == 0) {
		return TIDAL_EVENT_KEYP_WD;
	} else if (strcmp(string, "keyp_sd") == 0) {
		return TIDAL_EVENT_KEYP_SD;
	} else if (strcmp(string, "keyp_as") == 0) {
		return TIDAL_EVENT_KEYP_AS;
	} else if (strcmp(string, "keyp_wa") == 0) {
		return TIDAL_EVENT_KEYP_WA;
	} else if (strcmp(string, "mouse_left") == 0) {
		return TIDAL_EVENT_MOUSE_LEFT;
	} else if (strcmp(string, "mouse_right") == 0) {
		return TIDAL_EVENT_MOUSE_RIGHT;
	} else if (strcmp(string, "mouse_motion") == 0) {
		return TIDAL_EVENT_MOUSE_MOTION;
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
	} else if (strcmp(string, "timer") == 0) {
		return TIDAL_EVENT_TIMER_0;
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
	} else if (strcmp(string, "clickon") == 0) {
		return TIDAL_EVENT_CLICKON;
	}
	return TIDAL_EVENT_ERR;
}

/* Check for events from the player */
event_t get_event() {
	SDL_Event event;
	if (SDL_PollEvent(&event)) {
		switch (event.type) {
			case SDL_QUIT:
				return TIDAL_EVENT_QUIT;
				break;
			case SDL_KEYDOWN:
				switch (event.key.keysym.sym) {
					case SDLK_F1:
						return TIDAL_EVENT_KEY_F1;
						break;
					case SDLK_F2:
						return TIDAL_EVENT_KEY_F2;
						break;
					case SDLK_F3:
						return TIDAL_EVENT_KEY_F3;
						break;
					case SDLK_F4:
						return TIDAL_EVENT_KEY_F4;
						break;
					case SDLK_F5:
						return TIDAL_EVENT_KEY_F5;
						break;
					case SDLK_F6:
						return TIDAL_EVENT_KEY_F6;
						break;
					case SDLK_F7:
						return TIDAL_EVENT_KEY_F7;
						break;
					case SDLK_F8:
						return TIDAL_EVENT_KEY_F8;
						break;
					case SDLK_F9:
						return TIDAL_EVENT_KEY_F9;
						break;
					case SDLK_F10:
						return TIDAL_EVENT_KEY_F10;
						break;
					case SDLK_F11:
						return TIDAL_EVENT_KEY_F11;
						break;
					case SDLK_F12:
						return TIDAL_EVENT_KEY_F12;
						break;
					case SDLK_1:
						return TIDAL_EVENT_KEY_1;
						break;
					case SDLK_2:
						return TIDAL_EVENT_KEY_2;
						break;
					case SDLK_3:
						return TIDAL_EVENT_KEY_3;
						break;
					case SDLK_4:
						return TIDAL_EVENT_KEY_4;
						break;
					case SDLK_5:
						return TIDAL_EVENT_KEY_5;
						break;
					case SDLK_6:
						return TIDAL_EVENT_KEY_6;
						break;
					case SDLK_7:
						return TIDAL_EVENT_KEY_7;
						break;
					case SDLK_8:
						return TIDAL_EVENT_KEY_8;
						break;
					case SDLK_9:
						return TIDAL_EVENT_KEY_9;
						break;
					case SDLK_0:
						return TIDAL_EVENT_KEY_0;
						break;
					case SDLK_q:
						return TIDAL_EVENT_KEY_Q;
						break;
					case SDLK_w:
						return TIDAL_EVENT_KEY_W;
						break;
					case SDLK_e:
						return TIDAL_EVENT_KEY_E;
						break;
					case SDLK_r:
						return TIDAL_EVENT_KEY_R;
						break;
					case SDLK_t:
						return TIDAL_EVENT_KEY_T;
						break;
					case SDLK_y:
						return TIDAL_EVENT_KEY_Y;
						break;
					case SDLK_u:
						return TIDAL_EVENT_KEY_U;
						break;
					case SDLK_i:
						return TIDAL_EVENT_KEY_I;
						break;
					case SDLK_o:
						return TIDAL_EVENT_KEY_O;
						break;
					case SDLK_p:
						return TIDAL_EVENT_KEY_P;
						break;
					case SDLK_a:
						return TIDAL_EVENT_KEY_A;
						break;
					case SDLK_s:
						return TIDAL_EVENT_KEY_S;
						break;
					case SDLK_d:
						return TIDAL_EVENT_KEY_D;
						break;
					case SDLK_f:
						return TIDAL_EVENT_KEY_F;
						break;
					case SDLK_g:
						return TIDAL_EVENT_KEY_G;
						break;
					case SDLK_h:
						return TIDAL_EVENT_KEY_H;
						break;
					case SDLK_j:
						return TIDAL_EVENT_KEY_J;
						break;
					case SDLK_k:
						return TIDAL_EVENT_KEY_K;
						break;
					case SDLK_l:
						return TIDAL_EVENT_KEY_L;
						break;
					case SDLK_z:
						return TIDAL_EVENT_KEY_Z;
						break;
					case SDLK_x:
						return TIDAL_EVENT_KEY_X;
						break;
					case SDLK_c:
						return TIDAL_EVENT_KEY_C;
						break;
					case SDLK_v:
						return TIDAL_EVENT_KEY_V;
						break;
					case SDLK_b:
						return TIDAL_EVENT_KEY_B;
						break;
					case SDLK_n:
						return TIDAL_EVENT_KEY_N;
						break;
					case SDLK_m:
						return TIDAL_EVENT_KEY_M;
						break;
					case SDLK_SPACE:
						return TIDAL_EVENT_KEY_SPACE;
						break;
					case SDLK_RETURN:
						return TIDAL_EVENT_KEY_ENTER;
						break;
					case SDLK_UP:
						return TIDAL_EVENT_KEY_UP;
						break;
					case SDLK_RIGHT:
						return TIDAL_EVENT_KEY_RIGHT;
						break;
					case SDLK_DOWN:
						return TIDAL_EVENT_KEY_DOWN;
						break;
					case SDLK_LEFT:
						return TIDAL_EVENT_KEY_LEFT;
						break;
				}
				break;
			case SDL_KEYUP:
				switch (event.key.keysym.sym) {
					case SDLK_w:
						return TIDAL_EVENT_KEYR_W;
						break;
					case SDLK_a:
						return TIDAL_EVENT_KEYR_A;
						break;
					case SDLK_s:
						return TIDAL_EVENT_KEYR_S;
						break;
					case SDLK_d:
						return TIDAL_EVENT_KEYR_D;
						break;
				}
				break;
			case SDL_MOUSEBUTTONUP:
				switch (event.button.button) {
					case SDL_BUTTON_LEFT:
						return TIDAL_EVENT_MOUSE_LEFT;
						break;
					case SDL_BUTTON_RIGHT:
						return TIDAL_EVENT_MOUSE_RIGHT;
						break;
				}
				break;
			/*case SDL_MOUSEMOTION:
				return TIDAL_EVENT_MOUSE_MOTION;
				break;*/
		}
	}
	const Uint8* keystate = SDL_GetKeyboardState(NULL);
	if (keystate[SDL_SCANCODE_W] && keystate[SDL_SCANCODE_D]) {
		return TIDAL_EVENT_KEYP_WD;
	} else if (keystate[SDL_SCANCODE_S] && keystate[SDL_SCANCODE_D]) {
		return TIDAL_EVENT_KEYP_SD;
	} else if (keystate[SDL_SCANCODE_A] && keystate[SDL_SCANCODE_S]) {
		return TIDAL_EVENT_KEYP_AS;
	} else if (keystate[SDL_SCANCODE_W] && keystate[SDL_SCANCODE_A]) {
		return TIDAL_EVENT_KEYP_WA;
	} else if (keystate[SDL_SCANCODE_W]) {
		return TIDAL_EVENT_KEYP_W;
	} else if (keystate[SDL_SCANCODE_A]) {
		return TIDAL_EVENT_KEYP_A;
	} else if (keystate[SDL_SCANCODE_S]) {
		return TIDAL_EVENT_KEYP_S;
	} else if (keystate[SDL_SCANCODE_D]) {
		return TIDAL_EVENT_KEYP_D;
	}
	return TIDAL_EVENT_ERR;
}
