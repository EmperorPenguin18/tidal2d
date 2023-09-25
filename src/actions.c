//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include "actions.h"

/* Do a Chipmunk "teleport". See action documentation */
static void action_move(Engine* e, Instance* instance, void* args[]) {
	if (*(bool*)args[2]) {
		cpVect v = cpBodyGetPosition(instance->body);
		cpVect rel = cpvadd(v, cpv(*(float*)args[0], *(float*)args[1]));
		cpBodySetPosition(instance->body, rel);
	} else cpBodySetPosition(instance->body, cpv(*(float*)args[0], *(float*)args[1]));
}

/* Change a physics body velocity. See action documentation. */
static void action_speed(Engine* e, Instance* instance, void* args[]) {
	cpBodySetVelocity(instance->body, cpv(*(float*)args[0], *(float*)args[1]));
}

/* Set the space's gravity. See action documentation. */
static void action_gravity(Engine* e, Instance* instance, void* args[]) {
	cpSpaceSetGravity(e->space, cpv(*(float*)args[0], *(float*)args[1]));
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

/* Based on the type provided, setup args so calling an action is faster. */
static int action_handler(Action* action, zpl_json_object* json, Asset* assets, const size_t assets_num) {
	zpl_json_object* type = zpl_adt_query(json, "type");
	if (type == NULL) return ERROR("Missing action type");
	if (type->type != ZPL_ADT_TYPE_STRING) return ERROR("Action type isn't string");

	if (strcmp(type->string, "spawn") == 0) {
		action->args = malloc(3*sizeof(void*));
		zpl_json_object* object = zpl_adt_query(json, "object");
		if (object == NULL) return ERROR("Spawn action missing object");
		if (object->type != ZPL_ADT_TYPE_STRING) return ERROR("Object name isn't string");
		action->args[0] = malloc(strlen(object->string)+1);
		strcpy(action->args[0], object->string);
		zpl_json_object* x = zpl_adt_query(json, "x");
		if (x == NULL) return ERROR("Spawn action missing x");
		action->args[1] = malloc(sizeof(float));
		if (x->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[1] = x->integer;
		} else if (x->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[1] = x->real;
		} else return ERROR("X isn't number");
		zpl_json_object* y = zpl_adt_query(json, "y");
		if (y == NULL) return ERROR("Spawn action missing y");
		action->args[2] = malloc(sizeof(float));
		if (y->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[2] = y->integer;
		} else if (y->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[2] = y->real;
		} else return ERROR("Y isn't number");
		action->num = 3;
		action->run = &action_spawn;

	} else if (strcmp(type->string, "destroy") == 0) {
		action->args = NULL;
		action->num = 0;
		action->run = &action_destroy;

	} else if (strcmp(type->string, "move") == 0) {
		action->args = malloc(3*sizeof(void*));
		zpl_json_object* x = zpl_adt_query(json, "x");
		if (x == NULL) return ERROR("Move action missing x");
		action->args[0] = malloc(sizeof(float));
		if (x->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[0] = x->integer;
		} else if (x->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[0] = x->real;
		} else return ERROR("X isn't number");
		zpl_json_object* y = zpl_adt_query(json, "y");
		if (y == NULL) return ERROR("Move action missing y");
		action->args[1] = malloc(sizeof(float));
		if (y->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[1] = y->integer;
		} else if (y->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[1] = y->real;
		} else return ERROR("Y isn't number");
		zpl_json_object* relative = zpl_adt_query(json, "relative");
		if (relative == NULL) return ERROR("Move action missing relative");
		action->args[2] = malloc(sizeof(bool));
		if (relative->props != ZPL_ADT_PROPS_TRUE && relative->props != ZPL_ADT_PROPS_FALSE)
			return ERROR("Relative isn't bool");
		*(bool*)action->args[2] = relative->real;
		action->num = 3;
		action->run = &action_move;

	} else if (strcmp(type->string, "speed") == 0) {
		action->args = malloc(2*sizeof(void*));
		zpl_json_object* h = zpl_adt_query(json, "h");
		if (h == NULL) return ERROR("Speed action missing h");
		action->args[0] = malloc(sizeof(float));
		if (h->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[0] = h->integer;
		} else if (h->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[0] = h->real;
		} else return ERROR("H isn't number");
		zpl_json_object* v = zpl_adt_query(json, "v");
		if (v == NULL) return ERROR("Speed action missing v");
		action->args[1] = malloc(sizeof(float));
		if (v->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[1] = v->integer;
		} else if (v->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[1] = v->real;
		} else return ERROR("V isn't number");
		action->num = 2;
		action->run = &action_speed;

	} else if (strcmp(type->string, "gravity") == 0) {
		action->args = malloc(2*sizeof(void*));
		zpl_json_object* h = zpl_adt_query(json, "h");
		if (h == NULL) return ERROR("Gravity action missing h");
		action->args[0] = malloc(sizeof(float));
		if (h->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[0] = h->integer;
		} else if (h->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[0] = h->real;
		} else return ERROR("H isn't number");
		zpl_json_object* v = zpl_adt_query(json, "v");
		if (v == NULL) return ERROR("Gravity action missing v");
		action->args[1] = malloc(sizeof(float));
		if (v->type == ZPL_ADT_TYPE_INTEGER) {
			*(float*)action->args[1] = v->integer;
		} else if (v->type == ZPL_ADT_TYPE_REAL) {
			*(float*)action->args[1] = v->real;
		} else return ERROR("V isn't number");
		action->num = 2;
		action->run = &action_gravity;

	} else if (strcmp(type->string, "sound") == 0) {
		zpl_json_object* file = zpl_adt_query(json, "file");
		if (file == NULL) return ERROR("Sound action missing file");
		if (file->type != ZPL_ADT_TYPE_STRING) return ERROR("File isn't string");
		action->args = malloc(1*sizeof(void*));
		action->args[0] = malloc(sizeof(SDL_AudioSpec));
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file->string) == 0) {
				memcpy(action->args[0], assets[i].data, sizeof(SDL_AudioSpec));
				break;
			}
			if (i == assets_num - 1) return ERROR("Sound file not found");
		}
		action->num = 1;
		action->run = &action_sound;

	} else if (strcmp(type->string, "music") == 0) {
		zpl_json_object* file = zpl_adt_query(json, "file");
		if (file == NULL) return ERROR("Music action missing file");
		if (file->type != ZPL_ADT_TYPE_STRING) return ERROR("File isn't string");
		action->args = malloc(1*sizeof(void*));
		action->args[0] = malloc(sizeof(SDL_AudioSpec));
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file->string) == 0) {
				memcpy(action->args[0], assets[i].data, sizeof(SDL_AudioSpec));
				break;
			}
			if (i == assets_num - 1) return ERROR("Music file not found");
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

	} else return ERROR("Invalid action type found");
	return 0;
}

/* Initialize an Action struct. */
int action_init(Action* action, zpl_json_object* json, Asset* assets, const size_t assets_num) {
	if (action_handler(action, json, assets, assets_num) < 0)
		return ERROR("Action handler failed");
	return 0;
}

/* Cleanup an Action struct. */
void action_cleanup(Action* action) {
	for (int i = 0; i < action->num; i++) {
		free(action->args[i]);
	}
	free(action->args);
}
