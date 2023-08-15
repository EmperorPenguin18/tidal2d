//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "instance.h"

int instantiate() {
	cJSON* json = NULL;
	for (size_t i = 0; i < engine->objects_num; i++) {
		if (strcmp(name, engine->objects[i].name) == 0) {
			json = engine->objects[i].data;
			break;
		}
	}

	engine->instances = (Instance*)realloc(engine->instances, (engine->instances_num+1)*sizeof(Instance));
	const cJSON* layer = J_GetObjectItemCaseSensitive(json, "layer");
	int num = 0;
	if (J_IsNumber(layer)) num = layer->valueint;
	//If the specified layer is higher than the highest, fill them all out
	if (num+1 > engine->layers_num) {
		engine->layers = (size_t*)realloc(engine->layers, (num+1)*sizeof(size_t));
		for (size_t i = engine->layers_num; i < num+1; i++) engine->layers[i] = 0;
		engine->layers_num = num+1;
	}
	int sum = 0;
	//Get the spot where the new instance will slot in
	for (size_t i = 0; i < num; i++) sum += engine->layers[i];
	engine->layers[num]++;
	engine->instances_num++;
	//Make a spot in the array
	for (size_t i = engine->instances_num - 1; i > sum; i--) engine->instances[i] = engine->instances[i - 1];
	engine->instances[sum].id = gen_uuid();
	engine->instances[sum].layer = num; //Store layer for later
	
	engine->instances[sum].dst.x = x;
	engine->instances[sum].dst.y = y;
	const cJSON* width = J_GetObjectItemCaseSensitive(json, "width");
	if (J_IsNumber(width)) {
		engine->instances[sum].dst.w = width->valueint;
	} else engine->instances[sum].dst.w = 0;
	const cJSON* height = J_GetObjectItemCaseSensitive(json, "height");
	if (J_IsNumber(height)) {
		engine->instances[sum].dst.h = height->valueint;
	} else engine->instances[sum].dst.h = 0;
	
	engine->instances[sum].texture = NULL;
	const cJSON* sprite = J_GetObjectItemCaseSensitive(json, "sprite");
	if (J_IsString(sprite) && (sprite->valuestring != NULL)) {
		for (size_t i = 0; i < engine->textures_num; i++) {
			if (strcmp(engine->textures[i].name, sprite->valuestring) == 0) {
				engine->instances[sum].texture = engine->textures[i].data;
			}
		}
	}

	engine->instances[sum].font = NULL;
	const cJSON* font = J_GetObjectItemCaseSensitive(json, "font");
	if (J_IsString(font) && (font->valuestring != NULL)) {
		for (size_t i = 0; i < engine->fonts_num; i++) {
			if (strcmp(engine->fonts[i].name, font->valuestring) == 0) {
				engine->instances[sum].font = engine->fonts + i;
			}
		}
	}

	engine->instances[sum].text = NULL;
	const cJSON* text = J_GetObjectItemCaseSensitive(json, "text");
	if (J_IsString(text) && (text->valuestring != NULL)) {
		engine->instances[sum].text = text->valuestring;
	}

	engine->instances[sum].body = NULL;
	engine->instances[sum].shape = NULL;
	const cJSON* shape = J_GetObjectItemCaseSensitive(json, "shape");
	if (J_IsString(shape) && (shape->valuestring != NULL)) {
		if (strcmp(shape->valuestring, "box") == 0) { //set mass and friction dynamically
			engine->instances[sum].body = C_SpaceAddBody(engine->space,
				C_BodyNew(1, C_MomentForBox(1, engine->instances[sum].dst.w,
				engine->instances[sum].dst.h)));
			engine->instances[sum].shape = C_SpaceAddShape(engine->space,
				C_BoxShapeNew(engine->instances[sum].body,
				engine->instances[sum].dst.w, engine->instances[sum].dst.h, 0));
			C_ShapeSetFriction(engine->instances[sum].shape, 0.7);
		} else if (strcmp(shape->valuestring, "wall") == 0) {
			engine->instances[sum].body = C_BodyNewStatic();
			engine->instances[sum].shape = C_SpaceAddShape(engine->space,
				C_BoxShapeNew(engine->instances[sum].body , engine->instances[sum].dst.w,
					engine->instances[sum].dst.h, 0));
			C_ShapeSetFriction(engine->instances[sum].shape, 1);
		}//add other shapes
		C_BodySetPosition(engine->instances[sum].body, cpv(engine->instances[sum].dst.x,
			engine->instances[sum].dst.y));
		C_ShapeSetUserData(engine->instances[sum].shape, engine->instances[sum].id);
		C_ShapeSetCollisionType(engine->instances[sum].shape, 1);
		C_SpaceReindexShape(engine->space, engine->instances[sum].shape);
	}

	const cJSON* ui = J_GetObjectItemCaseSensitive(json, "ui");
	if (J_IsTrue(ui)) {
		init_ui(engine, sum);
	}

	const cJSON* events = J_GetObjectItemCaseSensitive(json, "events");
	if (J_IsObject(events)) {
		const cJSON* event = NULL;
		cJSON_ArrayForEach(event, events) {
			if (J_IsArray(event)) {
				event_t ev = 0;
				if (strcmp(event->string, "collision") == 0) {
					ev = TIDAL_EVENT_COLLISION;
				} else if (strcmp(event->string, "quit") == 0) {
					ev = TIDAL_EVENT_QUIT;
				} else if (strcmp(event->string, "key_w") == 0) {
					ev = TIDAL_EVENT_KEYW;
				} else if (strcmp(event->string, "key_a") == 0) {
					ev = TIDAL_EVENT_KEYA;
				} else if (strcmp(event->string, "key_s") == 0) {
					ev = TIDAL_EVENT_KEYS;
				} else if (strcmp(event->string, "key_d") == 0) {
					ev = TIDAL_EVENT_KEYD;
				} else if (strcmp(event->string, "key_space") == 0) {
					ev = TIDAL_EVENT_KEYSPACE;
				} else if (strcmp(event->string, "key_enter") == 0) {
					ev = TIDAL_EVENT_KEYENTER;
				} else if (strcmp(event->string, "mouse_left") == 0) {
					ev = TIDAL_EVENT_MOUSELEFT;
				} else if (strcmp(event->string, "mouse_right") == 0) {
					ev = TIDAL_EVENT_MOUSERIGHT;
				} else if (strcmp(event->string, "creation") == 0) {
					ev = TIDAL_EVENT_CREATION;
				} else if (strcmp(event->string, "destruction") == 0) {
					ev = TIDAL_EVENT_DESTRUCTION;
				} else if (strcmp(event->string, "check_ui") == 0) {
					ev = TIDAL_EVENT_CHECKUI;
				} else if (strcmp(event->string, "leave") == 0) {
					ev = TIDAL_EVENT_LEAVE;
				} else {
					S_Log("Invalid event type found");
					continue;
				}
				const cJSON* action = NULL;
				cJSON_ArrayForEach(action, event) {
					if (J_IsObject(action)) {
						//init_action(engine, ev, action, engine->instances[sum].id);
						Action* tmp = (Action*)realloc(engine->events[ev], (engine->events_num[ev]+1)*sizeof(Action));
						if (tmp == NULL) return -1;
						engine->events[ev] = tmp;
						engine->events[ev][engine->events_num[ev]].data = action;
						engine->events[ev][engine->events_num[ev]].id = id;
						engine->events_num[ev]++;
					}
				}
			} else {
				S_Log("Invalid object structure found");
			}
		}
	}

	const cJSON* layer = J_GetObjectItemCaseSensitive(engine->objects[engine->objects_num].data, "layer");
	if (J_IsNumber(layer)) {
		if (layer->valueint < engine->first_layer) {
			engine->first_object = engine->objects + engine->objects_num;
			engine->first_layer = layer->valueint;
		}
	}
	return 0;
}

int instance_cleanup() {
	Instance* instance = NULL;
	size_t n;
	for (n = 0; n < engine->instances_num; n++) {
		if (strcmp(id, engine->instances[n].id) == 0) {
			instance = engine->instances+n;
			break;
		}
	}

	C_SpaceRemoveShape(engine->space, instance->shape);
	C_SpaceRemoveBody(engine->space, instance->body);
	C_ShapeFree(instance->shape);
	C_BodyFree(instance->body);
	free(instance->id);

	for (size_t i = n; i < engine->instances_num-1; i++) engine->instances[i] = engine->instances[i + 1];
	engine->instances_num -= 1;

	engine->layers[instance->layer] -= 1;
}
