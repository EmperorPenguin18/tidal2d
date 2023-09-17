//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "instance.h"
#include "actions.h"
#include "assets.h"
#include "zpl.h"

/* Instantiate an object. Currently quite complex because all the processing
 * of JSON and assigning resources happens in this function. Also has to sort out the
 * layers each time. Will probably eventually be a performance bottleneck. Should add
 * more error messages to inform developer there object is malformed.
 */
int instance_create(Asset* asset, SDL_Renderer* renderer, Asset* assets, size_t assets_num, Instance* instance, size_t* l) {
	json* data = asset->data;
	zpl_json_object* json = data->root;
	instance->name = asset->name;
	instance->id = NULL;
	zpl_json_object* layer = zpl_adt_query(json, "layer");
	if (layer == NULL) { //Layer is optional
		instance->layer = SIZE_MAX;
	} else {
		if (layer->type != ZPL_ADT_TYPE_INTEGER) return -1;
		instance->layer = layer->integer;
	}
	*l = instance->layer;
	
	instance->dst.x = 0;
	instance->dst.y = 0;
	zpl_json_object* width = zpl_adt_query(json, "width");
	if (width == NULL) { //Width is optional
		instance->dst.w = 0;
	} else {
		if (width->type != ZPL_ADT_TYPE_INTEGER) return -1;
		instance->dst.w = width->integer;
	}
	zpl_json_object* height = zpl_adt_query(json, "height");
	if (height == NULL) { //Height is optional
		instance->dst.h = 0;
	} else {
		if (height->type != ZPL_ADT_TYPE_INTEGER) return -1;
		instance->dst.h = height->integer;
	}
	
	zpl_json_object* sprite = zpl_adt_query(json, "sprite");
	if (sprite == NULL) { //Sprite is optional
		instance->texture = NULL;
	} else {
		if (sprite->type != ZPL_ADT_TYPE_STRING) return -1;
		//Don't have to check extension because texture
		//creation will fail if it's wrong
		for (size_t i = 0; i < assets_num; i++) {
			/* Not super efficient having a texture for each instance */
			if (strcmp(assets[i].name, sprite->string) == 0) {
				SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, assets[i].data);
				if (texture == NULL) return -1;
				instance->texture = texture;
				break;
			}
		}
	}

	zpl_json_object* font = zpl_adt_query(json, "font");
	if (font == NULL) { //Font is optional
		instance->font = NULL;
	} else {
		if (font->type != ZPL_ADT_TYPE_STRING) return -1;
		if (strcmp(getextension(font->string), "ttf") != 0) return -1; // Better to fail early on this
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, font->string) == 0) {
				instance->font = assets[i].data;
				break;
			}
		}
	}

	zpl_json_object* text = zpl_adt_query(json, "text");
	if (text == NULL) { //Text is optional
		instance->text = NULL;
	} else {
		if (text->type != ZPL_ADT_TYPE_STRING) return -1;
		instance->text = malloc(strlen(text->string)+1);
		strcpy(instance->text, text->string);
	}

	instance->body = NULL;
	instance->shape = NULL;
	zpl_json_object* shape = zpl_adt_query(json, "shape");
	if (shape == NULL) { //Shape is optional
		instance->physics = PHYSICS_NONE;
	} else {
		if (shape->type != ZPL_ADT_TYPE_STRING) return -1;
		if (strcmp(shape->string, "box") == 0) {
			instance->physics = PHYSICS_BOX;
		} else if (strcmp(shape->string, "wall") == 0) {
			instance->physics = PHYSICS_STATIC;
		} else {
			return -1;
		}
	}

	for (size_t i = 0; i < EVENTS_NUM; i++) {
		instance->actions[i] = NULL;
		instance->actions_num[i] = 0;
	}
	zpl_json_object* events = zpl_adt_query(json, "events");
	if (events != NULL) { //Events is optional
		if (events->type != ZPL_ADT_TYPE_OBJECT) return -1;
		for (size_t i = 0; i < zpl_array_count(events->nodes); i++) {
			if (events->nodes[i].type != ZPL_ADT_TYPE_ARRAY) {
				SDL_Log("Event does not contain an array");
				return -1;
			}
			event_t ev = str2ev(events->nodes[i].name);
			if (ev == TIDAL_EVENT_ERR) {
				SDL_Log("Invalid event type found");
				return -1;
			}
			for (size_t j = 0; j < zpl_array_count(events->nodes[i].nodes); j++) {
				if (events->nodes[i].nodes[j].type != ZPL_ADT_TYPE_OBJECT) return -1;
				zpl_json_object* action = events->nodes[i].nodes + j;
				Action* tmp = (Action*)realloc(instance->actions[ev], (instance->actions_num[ev]+1)*sizeof(Action));
				if (tmp == NULL) return -1;
				instance->actions[ev] = tmp;
				if (action_init(instance->actions[ev]+instance->actions_num[ev], action, assets, assets_num) < 0) return -1;
				instance->actions_num[ev]++;
			}
		}
	}

	return 0;
}

void instance_cleanup(Instance* instance) {
	SDL_DestroyTexture(instance->texture);
	if (instance->shape) {
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
