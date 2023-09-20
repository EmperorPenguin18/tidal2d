//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "actions.h"

/* Do a Chipmunk "teleport". See action documentation */
static void action_move(Engine* e, Instance* instance, void* args[]) {
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Move: %d %d %d\n", *(float*)args[0], *(float*)args[1], *(bool*)args[2]);
	if (*(bool*)args[2]) {
		Vector2* v = &instance->body->position;
		v->x = v->x + *(float*)args[0];
		v->y = v->y + *(float*)args[1];
	} else {
		Vector2 v = {*(float*)args[0], *(float*)args[1]};
		instance->body->position = v;
	}
}

/* Change a physics body velocity. See action documentation. */
static void action_speed(Engine* e, Instance* instance, void* args[]) {
	Vector2 v = {*(float*)args[0], *(float*)args[1]};
	instance->body->velocity = v;
}

/* Set the space's gravity. See action documentation. */
static void action_gravity(Engine* e, Instance* instance, void* args[]) {
	SetPhysicsGravity(*(float*)args[0], *(float*)args[1]);
}

/* Play audio once. See action documentation. */
static void action_sound(Engine* e, Instance* instance, void* args[]) {
	SDL_ClearQueuedAudio(e->audiodev);
	SDL_AudioSpec* spec = args[0];
	SDL_QueueAudio(e->audiodev, spec->userdata, spec->size);
}

/* Play audio on loop. See action documentation. */
static void action_music(Engine* e, Instance* instance, void* args[]) {
	e->music = args[0];
}

/* End the game loop. See action documentation. */
static void action_close(Engine* e, Instance* instance, void* args[]) {
	e->running = false;
}

/* Part of the WIP ui system. */
/*static int action_checkui(Engine* engine, Instance* instance, void*[] args, int num) {
	event_handler(engine, TIDAL_EVENT_CHECKUI);
}*/

static int action_handler(Action* action, zpl_json_object* json, Asset* assets, const size_t assets_num) {
	zpl_json_object* type = zpl_adt_query(json, "type");
	if (type == NULL) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Missing action type");
		return -1;
	}
	if (type->type != ZPL_ADT_TYPE_STRING) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Action type isn't string");
		return -1;
	}

	if (strcmp(type->string, "spawn") == 0) {
		zpl_json_object* object = zpl_adt_query(json, "object");
		if (object == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Spawn action missing object");
			return -1;
		}
		if (object->type != ZPL_ADT_TYPE_STRING) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Object name isn't string");
			return -1;
		}
		zpl_json_object* x = zpl_adt_query(json, "x");
		if (x == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Spawn action missing x");
			return -1;
		}
		if (x->type != ZPL_ADT_TYPE_INTEGER) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "X isn't integer");
			return -1;
		}
		zpl_json_object* y = zpl_adt_query(json, "y");
		if (y == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Spawn action missing y");
			return -1;
		}
		if (y->type != ZPL_ADT_TYPE_INTEGER) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Y isn't integer");
			return -1;
		}
		action->args = malloc(3*sizeof(void*));
		action->args[0] = malloc(strlen(object->string)+1);
		strcpy(action->args[0], object->string);
		action->args[1] = malloc(sizeof(int));
		*(int*)action->args[1] = x->integer;
		action->args[2] = malloc(sizeof(int));
		*(int*)action->args[2] = y->integer;
		action->num = 3;
		action->run = &action_spawn;

	} else if (strcmp(type->string, "destroy") == 0) {
		action->args = NULL;
		action->num = 0;
		action->run = &action_destroy;

	} else if (strcmp(type->string, "move") == 0) {
		zpl_json_object* x = zpl_adt_query(json, "x");
		if (x == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Move action missing x");
			return -1;
		}
		if (x->type != ZPL_ADT_TYPE_REAL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "X isn't float");
			return -1;
		}
		zpl_json_object* y = zpl_adt_query(json, "y");
		if (y == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Move action missing y");
			return -1;
		}
		if (y->type != ZPL_ADT_TYPE_REAL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Y isn't float");
			return -1;
		}
		zpl_json_object* relative = zpl_adt_query(json, "relative");
		if (relative == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Move action missing relative");
			return -1;
		}
		if (relative->type != ZPL_ADT_TYPE_REAL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Relative isn't bool");
			return -1;
		}
		action->args = malloc(3*sizeof(void*));
		action->args[0] = malloc(sizeof(float));
		*(float*)action->args[0] = x->real;
		action->args[1] = malloc(sizeof(float));
		*(float*)action->args[1] = y->real;
		action->args[2] = malloc(sizeof(bool));
		*(bool*)action->args[2] = relative->real;
		action->num = 3;
		action->run = &action_move;

	} else if (strcmp(type->string, "speed") == 0) {
		zpl_json_object* h = zpl_adt_query(json, "h");
		if (h == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Speed action missing h");
			return -1;
		}
		if (h->type != ZPL_ADT_TYPE_REAL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "H isn't float: %s", type->string);
			return -1;
		}
		zpl_json_object* v = zpl_adt_query(json, "v");
		if (v == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Speed action missing v");
			return -1;
		}
		if (v->type != ZPL_ADT_TYPE_REAL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "V isn't float: %s", type->string);
			return -1;
		}
		action->args = malloc(2*sizeof(void*));
		action->args[0] = malloc(sizeof(float));
		*(float*)action->args[0] = h->real;
		action->args[1] = malloc(sizeof(float));
		*(float*)action->args[1] = v->real;
		action->num = 2;
		action->run = &action_speed;

	} else if (strcmp(type->string, "gravity") == 0) {
		zpl_json_object* h = zpl_adt_query(json, "h");
		if (h == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Gravity action missing h");
			return -1;
		}
		if (h->type != ZPL_ADT_TYPE_REAL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "H isn't float");
			return -1;
		}
		zpl_json_object* v = zpl_adt_query(json, "v");
		if (v == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Gravity action missing v");
			return -1;
		}
		if (v->type != ZPL_ADT_TYPE_REAL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "V isn't float: %s", type->string);
			return -1;
		}
		action->args = malloc(2*sizeof(void*));
		action->args[0] = malloc(sizeof(float));
		*(float*)action->args[0] = h->real;
		action->args[1] = malloc(sizeof(float));
		*(float*)action->args[1] = v->real;
		action->num = 2;
		action->run = &action_gravity;

	} else if (strcmp(type->string, "sound") == 0) {
		zpl_json_object* file = zpl_adt_query(json, "file");
		if (file == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Sound action missing file");
			return -1;
		}
		if (file->type != ZPL_ADT_TYPE_STRING) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "File isn't string");
			return -1;
		}
		action->args = malloc(1*sizeof(void*));
		action->args[0] = malloc(sizeof(SDL_AudioSpec));
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file->string) == 0) {
				memcpy(action->args[0], assets[i].data, sizeof(SDL_AudioSpec));
				break;
			}
			if (i == assets_num - 1) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Sound file not found");
				return -1;
			}
		}
		action->num = 1;
		action->run = &action_sound;

	} else if (strcmp(type->string, "music") == 0) {
		zpl_json_object* file = zpl_adt_query(json, "file");
		if (file == NULL) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Music action missing file");
			return -1;
		}
		if (file->type != ZPL_ADT_TYPE_STRING) {
			SDL_LogError(SDL_LOG_CATEGORY_ERROR, "File isn't string");
			return -1;
		}
		action->args = malloc(1*sizeof(void*));
		action->args[0] = malloc(sizeof(SDL_AudioSpec));
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file->string) == 0) {
				memcpy(action->args[0], assets[i].data, sizeof(SDL_AudioSpec));
				break;
			}
			if (i == assets_num - 1) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Music file not found");
				return -1;
			}
		}
		action->num = 1;
		action->run = &action_music;

	} else if (strcmp(type->string, "close") == 0) {
		action->args = NULL;
		action->num = 0;
		action->run = &action_close;

	/*} else if (strcmp(type->string, "checkui") == 0) {
		action->args = NULL;
		action->num = 0;
		action->run = &action_checkui;*/

	} else {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Invalid action type found");
		return -1;
	}
	return 0;
}

int action_init(Action* action, zpl_json_object* json, Asset* assets, const size_t assets_num) {
	if (action_handler(action, json, assets, assets_num) < 0) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Action handler failed");
		return -1;
	}
	return 0;
}

void action_cleanup(Action* action) {
	for (int i = 0; i < action->num; i++) {
		free(action->args[i]);
	}
	free(action->args);
}
