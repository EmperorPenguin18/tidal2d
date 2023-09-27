//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include "actions.h"

#include "instance.h"

/* Initialize Instance struct */
int instance_create(Asset* asset, SDL_Renderer* renderer, Asset* assets, size_t assets_num, Instance* instance, size_t* l) {
	json* data = asset->data;
	zpl_json_object* json = data->root;
	instance->name = asset->name;
	instance->id = NULL;
	zpl_json_object* layer = zpl_adt_query(json, "layer");
	if (layer == NULL) { //Layer is optional
		instance->layer = SIZE_MAX;
	} else {
		if (layer->type != ZPL_ADT_TYPE_INTEGER) return ERROR("Instance layer isn't integer");
		if (layer->integer < 0) return ERROR("Layer is less than 0");
		instance->layer = layer->integer;
	}
	*l = instance->layer;
	
	instance->dst.x = 0;
	instance->dst.y = 0;
	zpl_json_object* width = zpl_adt_query(json, "width");
	if (width == NULL) { //Width is optional
		instance->dst.w = 0;
	} else {
		if (width->type != ZPL_ADT_TYPE_INTEGER) return ERROR("Instance width isn't integer");
		instance->dst.w = width->integer;
	}
	zpl_json_object* height = zpl_adt_query(json, "height");
	if (height == NULL) { //Height is optional
		instance->dst.h = 0;
	} else {
		if (height->type != ZPL_ADT_TYPE_INTEGER) return ERROR("Instance height isn't integer");
		instance->dst.h = height->integer;
	}
	
	zpl_json_object* sprite = zpl_adt_query(json, "sprite");
	if (sprite == NULL) { //Sprite is optional
		instance->texture = NULL;
	} else {
		if (sprite->type != ZPL_ADT_TYPE_STRING) return ERROR("Instance sprite isn't string");
		//Don't have to check extension because texture
		//creation will fail if it's wrong
		for (size_t i = 0; i < assets_num; i++) {
			/* Not super efficient having a texture for each instance */
			if (strcmp(assets[i].name, sprite->string) == 0) {
				SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, assets[i].data);
				if (texture == NULL) return ERROR("Create texture failed: %s", SDL_GetError());
				instance->texture = texture;
				break;
			}
			if (i == assets_num - 1) return ERROR("Sprite file not found");
		}
	}

	zpl_json_object* font = zpl_adt_query(json, "font");
	if (font == NULL) { //Font is optional
		instance->font = NULL;
	} else {
		if (font->type != ZPL_ADT_TYPE_STRING) return ERROR("Instance font isn't string");
		if (strcmp(getextension(font->string), "ttf") != 0) return ERROR("Font isn't a ttf file"); // Better to fail early on this
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, font->string) == 0) {
				instance->font = assets[i].data;
				break;
			}
			if (i == assets_num - 1) return ERROR("Font file not found");
		}
	}

	zpl_json_object* text = zpl_adt_query(json, "text");
	if (text == NULL) { //Text is optional
		instance->text = NULL;
	} else {
		if (text->type != ZPL_ADT_TYPE_STRING) return ERROR("Instance text isn't string");
		instance->text = malloc(strlen(text->string)+1);
		strcpy(instance->text, text->string);
	}

	instance->body = NULL;
	instance->shape = NULL;
	instance->colliding = NULL;
	zpl_json_object* shape = zpl_adt_query(json, "shape");
	if (shape == NULL) { //Shape is optional
		instance->physics = PHYSICS_NONE;
	} else {
		if (shape->type != ZPL_ADT_TYPE_STRING) return ERROR("Instance shape isn't string");
		if (strcmp(shape->string, "box") == 0) {
			instance->physics = PHYSICS_BOX;
		} else if (strcmp(shape->string, "wall") == 0) {
			instance->physics = PHYSICS_STATIC;
		} else return ERROR("Invalid shape");
	}

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
				if (action_init(instance->actions[ev]+instance->actions_num[ev], action, assets, assets_num) < 0) return ERROR("Action init failed");
				instance->actions_num[ev]++;
			}
		}
	}

	return 0;
}

/* Cleanup Instance struct */
void instance_cleanup(Instance* instance) {
	SDL_DestroyTexture(instance->texture);
	if (instance->shape) { //Probably never gets executed
		cpShapeFree(instance->shape);
		cpBodyFree(instance->body);
	}
	for (size_t i = 0; i < EVENTS_NUM; i++) {
		for (size_t j = 0; j < instance->actions_num[i]; j++) {
			action_cleanup(instance->actions[i]+j);
		}
		free(instance->actions[i]);
	}
	if (instance->text) free(instance->text);
}
