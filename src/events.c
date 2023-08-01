//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "events.h"

/* Action to instantiate an object. Currently quite complex because all the processing
 * of JSON and assigning resources happens in this function. Also has to sort out the
 * layers each time. Will probably eventually be a performance bottleneck. Should add
 * more error messages to inform developer there object is malformed.
 */
static int action_spawn(Engine* engine, const char* name, int x, int y) {
	instance_copy();
	event_handler(engine, TIDAL_EVENT_CREATION, engine->instances[sum].id);
	return 0;
}

/* Free resources used by instance. See action documentation. */
static int action_destroy(Engine* engine, char* id) {
	event_handler(engine, TIDAL_EVENT_DESTRUCTION, id);
	instance_cleanup();
	return 0;
}

/* Do a Chipmunk "teleport". See action documentation */
static int action_move(Engine* engine, char* id, int x, int y, bool relative) {
	cpBody* body = NULL;
	cpShape* shape = NULL;
	for (size_t i = 0; i < engine->instances_num; i++) {
		if (strcmp(engine->instances[i].id, id) == 0) {
			body = engine->instances[i].body;
			shape = engine->instances[i].shape;
			break;
		}
	}

	if (relative) {
		cpVect v = C_BodyGetPosition(body);
		int rel_x = v.x + x;
		int rel_y = v.y + y;
		C_BodySetPosition(body, cpv(rel_x, rel_y));
	} else C_BodySetPosition(body, cpv(x, y));

	C_SpaceReindexShape(engine->space, shape);
	return 0;
}

/* Change a physics body velocity. See action documentation. */
static int action_speed(Engine* engine, char* id, int h, int v) {
	for (size_t i = 0; i < engine->instances_num; i++) {
		if (strcmp(engine->instances[i].id, id) == 0) {
			C_BodySetVelocity(engine->instances[i].body, cpv(h, v));
			break;
		}
	}
	return 0;
}

/* Set the space's gravity. See action documentation. */
static int action_gravity(Engine* engine, int h, int v) {
	C_SpaceSetGravity(engine->space, cpv(h, v));
	return 0;
}

/* Play audio once. See action documentation. */
static int action_sound(Engine* engine, char* file) {
	for (size_t i = 0; i < engine->audio_num; i++) {
		if (strcmp(engine->audio[i].name, file) == 0) {
			O_playEx(engine->soloud, engine->audio[i].data, 1.0, 0.0, 0, 0);
			break;
		}
	}
	return 0;
}

/* Play audio on loop. See action documentation. */
static int action_music(Engine* engine, char* file) {
	for (size_t i = 0; i < engine->audio_num; i++) {
		if (strcmp(engine->audio[i].name, file) == 0) {
			unsigned int h = O_playBackgroundEx(engine->soloud, engine->audio[i].data, 1.0, 0, 0);
			O_setLooping(engine->soloud, h, 1);
			break;
		}
	}
	return 0;
}

/* End the game loop. See action documentation. */
static int action_close(Engine* engine) {
	engine->running = false;
	return 0;
}

/* Part of the WIP ui system. */
static int action_checkui(Engine* engine) {
	event_handler(engine, TIDAL_EVENT_CHECKUI, NULL);
	return 0;
}

/* Engine struct stores a 2D array. The first dimension is the different event types (LEAVE, CREATION etc).
 * The second dimension is dynamically sized and re-sized, and stores all the different actions that instances
 * have added.
 *
 * This function takes the context, event type, and the id of the calling instance, and will loop over
 * all the actions executing them based on the specifications provided by an object.
 */
static void event_handler(Engine* engine, event_t ev, char* id) {
	for (int i = 0; i < engine->events_num[ev]; i++) {
		Action* action = engine->events[ev] + i;
		//Special case: some events only trigger based on instance id
		if (ev == TIDAL_EVENT_CREATION || ev == TIDAL_EVENT_DESTRUCTION ||
		    ev == TIDAL_EVENT_LEAVE || ev == TIDAL_EVENT_COLLISION) {
			if (strcmp(action->id, id) != 0) continue;
		}
		const cJSON* type = J_GetObjectItemCaseSensitive(action->data, "type");
		if (J_IsString(type) && (type->valuestring != NULL)) {
			if (strcmp(type->valuestring, "spawn") == 0) {
				const cJSON* object = J_GetObjectItemCaseSensitive(action->data, "object");
				const cJSON* x = J_GetObjectItemCaseSensitive(action->data, "x");
				const cJSON* y = J_GetObjectItemCaseSensitive(action->data, "y");
				if (J_IsString(object) && (object->valuestring != NULL) && J_IsNumber(x) && J_IsNumber(y)) {
					action_spawn(engine, object->valuestring, x->valueint, y->valueint);
				}
			} else if (strcmp(type->valuestring, "destroy") == 0) {
				action_destroy(engine, action->id);
			} else if (strcmp(type->valuestring, "move") == 0) {
				const cJSON* x = J_GetObjectItemCaseSensitive(action->data, "x");
				const cJSON* y = J_GetObjectItemCaseSensitive(action->data, "y");
				const cJSON* relative = J_GetObjectItemCaseSensitive(action->data, "relative");
				if (J_IsNumber(x) && J_IsNumber(y) && J_IsBool(relative)) {
					action_move(engine, action->id, x->valueint, y->valueint, relative->valueint);
				}
			} else if (strcmp(type->valuestring, "speed") == 0) {
				const cJSON* h = J_GetObjectItemCaseSensitive(action->data, "h");
				const cJSON* v = J_GetObjectItemCaseSensitive(action->data, "v");
				if (J_IsNumber(h) && J_IsNumber(v)) {
					action_speed(engine, action->id, h->valueint, v->valueint);
				}
			} else if (strcmp(type->valuestring, "gravity") == 0) {
				const cJSON* h = J_GetObjectItemCaseSensitive(action->data, "h");
				const cJSON* v = J_GetObjectItemCaseSensitive(action->data, "v");
				if (J_IsNumber(h) && J_IsNumber(v)) {
					action_gravity(engine, h->valueint, v->valueint);
				}
			} else if (strcmp(type->valuestring, "sound") == 0) {
				const cJSON* file = J_GetObjectItemCaseSensitive(action->data, "file");
				if (J_IsString(file) && (file->valuestring != NULL)) {
					action_sound(engine, file->valuestring);
				}
			} else if (strcmp(type->valuestring, "music") == 0) {
				const cJSON* file = J_GetObjectItemCaseSensitive(action->data, "file");
				if (J_IsString(file) && (file->valuestring != NULL)) {
					action_music(engine, file->valuestring);
				}
			} else if (strcmp(type->valuestring, "close") == 0) {
				action_close(engine);
			} else if (strcmp(type->valuestring, "checkui") == 0) {
				action_checkui(engine);
			} else {
				S_Log("Invalid action type found");
			}
		}
	}
}

