//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include <string.h>

#include "actions.h"

/* Copy new active instance. See action documentation. */
static void action_spawn(Engine* e, Instance* instance, char* args) {
	char* object = args;
	double x = *(double*)(args+strlen(object)+1);
	double y = *(double*)(args+strlen(object)+1+sizeof(double));
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Spawn: %s %f %f", object, x, y);
	instance_copy(e, object, x, y);
}

/* Free resources used by instance. See action documentation. */
static void action_destroy(Engine* e, Instance* instance, char* args) {
	instance_destroy(e, instance);
}

/* Set a global variable to arbitray data. See action documentation. */
static void action_setvar(Engine* e, Instance* instance, char* args) {
	return; //Not implemented
}

/* Do a Chipmunk "teleport". See action documentation */
static void action_move(Engine* e, Instance* instance, char* args) {
	double x = *(double*)args;
	double y = *(double*)(args+sizeof(double));
	bool relative = *(bool*)(args+(2*sizeof(double)));
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Move: %f %f %d", x, y, relative);
	if (relative) {
		cpVect v = cpBodyGetPosition(instance->body);
		cpVect rel = cpvadd(v, cpv(x, y));
		cpBodySetPosition(instance->body, rel);
	} else cpBodySetPosition(instance->body, cpv(x, y));
}

/* Change a physics body velocity. See action documentation. */
static void action_speed(Engine* e, Instance* instance, char* args) {
	double h = *(double*)args;
	double v = *(double*)(args+sizeof(double));
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Speed: %f %f", h, v);
	cpBodySetVelocity(instance->body, cpv(h, v));
}

/* Set the space's gravity. See action documentation. */
static void action_gravity(Engine* e, Instance* instance, char* args) {
	double h = *(double*)args;
	double v = *(double*)(args+sizeof(double));
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Gravity: %f %f", h, v);
	cpSpaceSetGravity(e->space, cpv(h, v));
}

/* Play audio once. See action documentation. */
static void action_sound(Engine* e, Instance* instance, char* args) {
	SDL_AudioSpec* spec = (SDL_AudioSpec*)args;
	Uint32 queued = SDL_GetQueuedAudioSize(e->audiodev);
	Uint32 pos = e->audio_buf.size - queued;
	if (!queued) {
		pos = 0;
		memset(e->audio_buf.userdata, e->audio_buf.silence, e->audio_buf.size);
	}
	if (e->audio_buf.size < spec->size) {
		e->audio_buf.userdata = realloc(e->audio_buf.userdata, spec->size);
		memset(((Uint8*)e->audio_buf.userdata)+e->audio_buf.size, e->audio_buf.silence, spec->size - e->audio_buf.size);
		e->audio_buf.size = spec->size;
	}
	queued = e->audio_buf.size - pos;
	if (queued >= spec->size) {
		SDL_ClearQueuedAudio(e->audiodev);
		SDL_MixAudioFormat(((Uint8*)e->audio_buf.userdata)+pos, spec->userdata, spec->format, spec->size, SDL_MIX_MAXVOLUME);
		SDL_QueueAudio(e->audiodev, ((Uint8*)e->audio_buf.userdata)+pos, queued);
	}
}

/* Play audio on loop. See action documentation. */
static void action_music(Engine* e, Instance* instance, char* args) {
	action_sound(e, instance, args);
	e->music = (SDL_AudioSpec*)args;
}

/* End the game loop. See action documentation. */
static void action_close(Engine* e, Instance* instance, char* args) {
	e->running = false;
}

/* Part of the WIP ui system. */
/*static void action_checkui(Engine* e, Instance* instance, char* args) {
	event_handler(engine, TIDAL_EVENT_CHECKUI);
}*/

/* Fill in memory with specified structure.
 * Variadic arguments must be in pairs of two.
 * STRING is string, INTEGER is number, and REAL is bool.
 */
static char* args_generator(zpl_json_object* json, size_t n, ...) {
	char* args = NULL;
	size_t size = 0;
	size_t pos = 0;
	va_list list;
	va_start(list, n);
	for (size_t i = 0; i < n; i++) {
		void* src = NULL;
		char* name = va_arg(list, char*);
		zpl_adt_type type = va_arg(list, zpl_adt_type);
		zpl_json_object* key = zpl_adt_query(json, name);
		if (key == NULL) {
			ERROR("Required action parameter missing: %s", name);
			return NULL;
		}
		if (type == ZPL_ADT_TYPE_STRING) {
			if (key->type != type) {
				ERROR("Action parameter wrong type: %s", name);
				return NULL;
			}
			size += strlen(key->string)+1;
			src = (char*)key->string;
		} else if (type == ZPL_ADT_TYPE_INTEGER) {
			if (key->type != type && key->type != ZPL_ADT_TYPE_REAL) {
				ERROR("Action parameter wrong type: %s", name);
				return NULL;
			}
			size += sizeof(double);
			double f = key->integer;
			if (key->type == type) src = &f;
			else src = &key->real;
		} else if (type == ZPL_ADT_TYPE_REAL) {
			if (key->props != ZPL_ADT_PROPS_TRUE && key->props != ZPL_ADT_PROPS_FALSE) {
				ERROR("Action parameter wrong type: %s", name);
				return NULL;
			}
			size += sizeof(bool);
			src = &key->real;
		} else {
			ERROR("Not a supported type");
			return NULL;
		}
		char* tmp = realloc(args, size);
		if (tmp == NULL) {
			ERROR("Out of memory");
			return NULL;
		}
		args = tmp;
		memcpy(args+pos, src, size-pos);
		pos = size;
	}
	return args;
}

/* Based on the type provided, setup args so calling an action is faster. */
static int action_handler(Action* action, zpl_json_object* json, Asset* assets, const size_t assets_num) {
	char* type = args_generator(json, 1, "type", ZPL_ADT_TYPE_STRING);

	if (strcmp(type, "spawn") == 0) {
		action->args =
			args_generator(json, 3, "object", ZPL_ADT_TYPE_STRING, "x", ZPL_ADT_TYPE_INTEGER, "y", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed");
		action->run = &action_spawn;

	} else if (strcmp(type, "destroy") == 0) {
		action->args = NULL;
		action->run = &action_destroy;

	} else if (strcmp(type, "move") == 0) {
		action->args =
			args_generator(json, 3, "x", ZPL_ADT_TYPE_INTEGER, "y", ZPL_ADT_TYPE_INTEGER, "relative", ZPL_ADT_TYPE_REAL);
		if (action->args == NULL) return ERROR("Args generator failed");
		action->run = &action_move;

	} else if (strcmp(type, "speed") == 0) {
		action->args =
			args_generator(json, 2, "h", ZPL_ADT_TYPE_INTEGER, "v", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed");
		action->run = &action_speed;

	} else if (strcmp(type, "gravity") == 0) {
		action->args =
			args_generator(json, 2, "h", ZPL_ADT_TYPE_INTEGER, "v", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed");
		action->run = &action_gravity;

	} else if (strcmp(type, "sound") == 0) {
		char* file = args_generator(json, 1, "file", ZPL_ADT_TYPE_STRING);
		action->args = malloc(sizeof(SDL_AudioSpec));
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file) == 0) {
				memcpy(action->args, assets[i].data, sizeof(SDL_AudioSpec));
				break;
			}
			if (i == assets_num - 1) return ERROR("Sound file not found");
		}
		action->run = &action_sound;

	} else if (strcmp(type, "music") == 0) {
		char* file = args_generator(json, 1, "file", ZPL_ADT_TYPE_STRING);
		action->args = malloc(sizeof(SDL_AudioSpec));
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file) == 0) {
				memcpy(action->args, assets[i].data, sizeof(SDL_AudioSpec));
				break;
			}
			if (i == assets_num - 1) return ERROR("Music file not found");
		}
		action->run = &action_music;

	} else if (strcmp(type, "close") == 0) {
		action->args = NULL;
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
	free(action->args);
}
