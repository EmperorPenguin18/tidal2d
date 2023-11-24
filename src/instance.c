//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include "actions.h"

#include "instance.h"

static size_t generate_atlas(int** x, int** y, const int w, const int h, const int img_w, const int img_h) {
	size_t frames = 0;
	if (img_w > w && img_h > h) {
		frames = ceil(img_w/w) * ceil(img_h/h);
		*x = malloc(frames*sizeof(int));
		*y = malloc(frames*sizeof(int));
		for (size_t i = 0; i < frames/ceil(img_w/w); i++) {
			for (size_t j = 0; j < frames/ceil(img_h/h); j++) {
				(*x)[i+j] = j*w;
				(*y)[i+j] = i*h;
			}
		}
	} else if (img_w > w) {
		frames = ceil(img_w/w);
		*x = malloc(frames*sizeof(int));
		*y = malloc(frames*sizeof(int));
		for (size_t i = 0; i < frames; i++) {
			(*x)[i] = i*w;
			(*y)[i] = 0;
		}
	} else if (img_h > h) {
		frames = ceil(img_h/h);
		*x = malloc(frames*sizeof(int));
		*y = malloc(frames*sizeof(int));
		for (size_t i = 0; i < frames; i++) {
			(*x)[i] = 0;
			(*y)[i] = i*w;
		}
	} else {
		frames = 1;
		*x = malloc(frames*sizeof(int));
		*y = malloc(frames*sizeof(int));
		*x[0] = 0;
		*y[0] = 0;
	}
	return frames;
}

static int assign_int(void* component, zpl_json_object* json, const char* key, int fallback) {
	zpl_json_object* value = zpl_adt_query(json, key);
	if (value == NULL) {
		if (component != NULL) *(int*)component = fallback;
		return 0;
	}
	if (value->type == ZPL_ADT_TYPE_INTEGER) {
		*(int*)component = value->integer;
	} else return ERROR("Instance %s is the wrong type", key);
	return 0;
}

static int assign_float(float* component, zpl_json_object* json, const char* key, float fallback) {
	zpl_json_object* value = zpl_adt_query(json, key);
	if (value == NULL) {
		if (component != NULL) *component = fallback;
		return 0;
	}
	if (value->type == ZPL_ADT_TYPE_INTEGER) {
		*component = value->integer;
	} else if (value->type == ZPL_ADT_TYPE_REAL) {
		*component = value->real;
	} else return ERROR("Instance %s is the wrong type", key);
	return 0;
}

static int assign_string(char** component, zpl_json_object* json, const char* key) {
	zpl_json_object* value = zpl_adt_query(json, key);
	if (value == NULL || component == NULL || *component != NULL) {
		return 0;
	}
	if (value->type == ZPL_ADT_TYPE_STRING) {
		*component = malloc(strlen(value->string)+1);
		strcpy(*component, value->string);
	} else return ERROR("Instance %s is the wrong type", key);
	return 0;
}

/* Initialize Instance struct */
int instance_create(Asset* asset, SDL_Renderer* renderer, Asset* assets, size_t assets_num, cpSpace* space, Instance* instance) {
	json* data = asset->data;
	zpl_json_object* json = data->root;
	instance->name = asset->name;

	if (assign_int(&instance->layer, json, "layer", INT_MAX) < 0) return -1;
	instance->dst.x = 0.0;
	instance->dst.y = 0.0;
	if (assign_float(&instance->dst.w, json, "width", 0.0) < 0) return -1;
	if (assign_float(&instance->dst.h, json, "height", 0.0) < 0) return -1;
	
	instance->frame = 0;
	instance->end_frame = -1;
	char* str = NULL;
	if (assign_string(&str, json, "sprite") < 0) return -1;
	if (str == NULL) {
		instance->texture.atlas = NULL;
		instance->texture.x = NULL;
		instance->texture.y = NULL;
	} else {
		//Don't have to check extension because texture
		//creation will fail if it's wrong
		for (size_t i = 0; i < assets_num; i++) {
			/* Not super efficient having a texture for each instance */
			if (strcmp(assets[i].name, str) == 0) {
				SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, assets[i].data);
				if (texture == NULL) return ERROR("Create texture failed: %s", SDL_GetError());
				instance->texture.atlas = texture;
				int w, h; SDL_QueryTexture(texture, NULL, NULL, &w, &h);
				instance->texture.frames =
					generate_atlas(&instance->texture.x, &instance->texture.y,
					instance->dst.w, instance->dst.h, w, h);
				if (instance->texture.frames < 0) return ERROR("Atlas generation failed");
				break;
			}
			if (i == assets_num - 1) return ERROR("Sprite file not found");
		}
		free(str);
	}

	str = NULL;
	if (assign_string(&str, json, "font") < 0) return -1;
	if (str == NULL) {
		instance->font = NULL;
	} else {
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, str) == 0) {
				font* font = assets[i].data;
				instance->font = STBTTF_OpenFontRW(renderer, SDL_RWFromConstMem(font->data, font->len), 28);
				if (!instance->font) return ERROR("Open font failed");
				break;
			}
			if (i == assets_num - 1) return ERROR("Font file not found");
		}
		free(str);
	}

	instance->text = NULL;
	if (assign_string(&instance->text, json, "text") < 0) return -1;

	if (assign_int(&instance->collision_type, json, "collision_type", 0) < 0) return -1;

	for (size_t i = 0; i < EVENTS_NUM; i++) {
		instance->actions[i] = NULL;
		instance->actions_num[i] = 0;
	}
	zpl_json_object* events = zpl_adt_query(json, "events");
	if (events != NULL) { //Events is optional
		if (events->type != ZPL_ADT_TYPE_OBJECT) return ERROR("Instance events isn't object");
		for (size_t i = 0; i < zpl_array_count(events->nodes); i++) {
			if (events->nodes[i].type != ZPL_ADT_TYPE_ARRAY) return ERROR("Event does not contain an array");
			event_t ev = str2ev(events->nodes[i].name);
			if (ev == TIDAL_EVENT_ERR) return ERROR("Invalid event type found");
			for (size_t j = 0; j < zpl_array_count(events->nodes[i].nodes); j++) {
				if (events->nodes[i].nodes[j].type != ZPL_ADT_TYPE_OBJECT) return ERROR("Event array does not contain an object");
				zpl_json_object* action = events->nodes[i].nodes + j;
				Action* tmp = (Action*)realloc(instance->actions[ev], (instance->actions_num[ev]+1)*sizeof(Action));
				if (tmp == NULL) return ERROR("Out of memory");
				instance->actions[ev] = tmp;
				if (action_init(instance->actions[ev]+instance->actions_num[ev], action, assets, assets_num) < 0) return ERROR("Action init failed: %s", instance->name);
				instance->actions_num[ev]++;
			}
		}
	}

	str = NULL;
	if (assign_string(&str, json, "shape") < 0) return -1;
	if (str == NULL) {
		instance->body = NULL;
		instance->shape = NULL;
		instance->colliding = NULL;
	} else {
		cpFloat w = instance->dst.w;
		cpFloat h = instance->dst.h;
		if (strcmp(str, "box") == 0) {
			instance->body = cpSpaceAddBody(space, cpBodyNew(1, INFINITY));
			instance->shape = cpSpaceAddShape(space, cpBoxShapeNew(instance->body, w, h, 0));
		} else if (strcmp(str, "wall") == 0) {
			instance->body = cpBodyNewKinematic();
			instance->shape = cpSpaceAddShape(space, cpBoxShapeNew(instance->body, w, h, 0));
		} else if (strcmp(str, "triangle") == 0) {
			instance->body = cpSpaceAddBody(space, cpBodyNew(1, INFINITY));
			cpVect verts[3];
			verts[0].x = 0; verts[0].y = -h/2;
			verts[1].x = -w/2; verts[1].y = h/2;
			verts[2].x = w/2; verts[2].y = h/2;
			instance->shape = cpSpaceAddShape(space, cpPolyShapeNewRaw(instance->body, 3, verts, 0));
		} else if (strcmp(str, "triangle-wall") == 0) {
			instance->body = cpBodyNewKinematic();
			cpVect verts[3];
			verts[0].x = 0; verts[0].y = -h/2;
			verts[1].x = -w/2; verts[1].y = h/2;
			verts[2].x = w/2; verts[2].y = h/2;
			instance->shape = cpSpaceAddShape(space, cpPolyShapeNewRaw(instance->body, 3, verts, 0));
		} else return ERROR("Invalid shape");
		cpShapeSetFriction(instance->shape, 1.0);
		instance->colliding = malloc(sizeof(int));
		*(instance->colliding) = -1;
		cpShapeSetUserData(instance->shape, instance->colliding);
		cpShapeSetCollisionType(instance->shape, instance->collision_type);
		free(str);
	}

	return 0;
}

/* Cleanup Instance struct */
void instance_cleanup(cpSpace* space, Instance* instance) {
	if (instance->texture.atlas) {
		SDL_DestroyTexture(instance->texture.atlas);
		free(instance->texture.x);
		free(instance->texture.y);
	}
	for (size_t i = 0; i < EVENTS_NUM; i++) {
		for (size_t j = 0; j < instance->actions_num[i]; j++) {
			action_cleanup(instance->actions[i]+j);
		}
		free(instance->actions[i]);
	}
	if (instance->text) free(instance->text);
	if (instance->shape) {
		free(instance->colliding); instance->colliding = NULL;
		cpSpaceRemoveShape(space, instance->shape);
		if (cpSpaceContainsBody(space, instance->body)) {
			cpSpaceRemoveBody(space, instance->body);
		}
		cpShapeFree(instance->shape); instance->shape = NULL;
		cpBodyFree(instance->body); instance->body = NULL;
	}
	SDL_RemoveTimer(instance->timer);
	if (instance->font) STBTTF_CloseFont(instance->font);
	memset(instance, 0, sizeof(Instance));
}
