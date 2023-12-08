//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include <string.h>
#include <unistd.h>

#include "actions.h"

/* Copy new active instance. See action documentation. */
static void action_spawn(Engine* e, Instance* instance, char* args) {
	char* object = args;
	float x = *(float*)(args+strlen(object)+1);
	float y = *(float*)(args+strlen(object)+1+sizeof(float));
	bool relative = *(bool*)(args+strlen(object)+1+(2*sizeof(float)));
	if (relative && instance->body) {
		cpVect v = cpBodyGetPosition(instance->body);
		x += v.x;
		y += v.y;
	}
	instance_copy(e, object, x, y);
}

/* Free resources used by instance. See action documentation. */
static void action_destroy(Engine* e, Instance* instance, char* args) {
	instance_destroy(e, instance);
}

/* Do a Chipmunk "teleport". See action documentation */
static void action_move(Engine* e, Instance* instance, char* args) {
	float x = *(float*)args;
	float y = *(float*)(args+sizeof(float));
	bool relative = *(bool*)(args+(2*sizeof(float)));
	if (instance->body) {
		if (relative) {
			cpVect v = cpBodyGetPosition(instance->body);
			cpVect rel = cpvadd(v, cpv(x, y));
			cpBodySetPosition(instance->body, rel);
		} else cpBodySetPosition(instance->body, cpv(x, y));
	} else {
		if (relative) {
			instance->dst.x += x;
			instance->dst.y += y;
		} else {
			instance->dst.x = x;
			instance->dst.y = y;
		}
	}
}

/* Change a physics body velocity. See action documentation. */
static void action_speed(Engine* e, Instance* instance, char* args) {
	float h = *(float*)args;
	float v = *(float*)(args+sizeof(float));
	if (instance->body) {
		cpBodySetVelocity(instance->body, cpv(h, v));
	}
}

/* Set the space's gravity. See action documentation. */
static void action_gravity(Engine* e, Instance* instance, char* args) {
	float h = *(float*)args;
	float v = *(float*)(args+sizeof(float));
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
		SDL_MixAudioFormat(((Uint8*)e->audio_buf.userdata)+pos, spec->userdata, spec->format, spec->size, VOLUME);
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

static Uint32 animation_callback(Uint32 interval, void* param) {
	Instance* instance = param;
	instance->inc_frame = true;
	return interval;
}

/* Set animation frame timer. See action documentation. */
static void action_animation(Engine* e, Instance* instance, char* args) {
	int start = floor(*(float*)args);
	int end = floor(*(float*)(args+sizeof(float)));
	float time = *(float*)(args+(2*sizeof(float)));
	if (start < 0 || end < 0 || time < 0 || end > instance->texture.frames-1) return;
	instance->frame = start;
	if (end > start) {
		instance->end_frame = end;
		SDL_RemoveTimer(instance->timer);
		instance->timer = SDL_AddTimer(time*1000, animation_callback, instance);
	}
}

/* Set the rotation of the object. See action documentation. */
static void action_rotation(Engine* e, Instance* instance, char* args) {
	cpFloat angle = *(float*)args;
	if (instance->body) {
		cpBodySetAngle(instance->body, angle*(CP_PI/180));
		cpSpaceReindexShapesForBody(e->space, instance->body);
	}
}

/* Set a global variable to arbitray data. See action documentation. */
static void action_variable(Engine* e, Instance* instance, char* args) {
	char* name = args;
	char* string = args+strlen(name)+1;
	float number = *(float*)(args+strlen(name)+strlen(string)+2);
	for (size_t i = 0; i < e->var_num; i++) {
		if (strcmp(name, e->vars[i].name) == 0) { //update existing var
			if (strlen(string) > 0) {
				e->vars[i].len = strlen(string)+1;
				e->vars[i].data = string;
			} else {
				e->vars[i].len = sizeof(float);
				e->vars[i].data = args+strlen(name)+strlen(string)+2;
			}
			return;
		}
	}
	//new var
	e->vars = realloc(e->vars, (e->var_num+1)*sizeof(var));
	e->vars[e->var_num].name = name;
	if (strlen(string) > 0) {
		e->vars[e->var_num].len = strlen(string)+1;
		e->vars[e->var_num].data = string;
	} else {
		e->vars[e->var_num].len = sizeof(float);
		e->vars[e->var_num].data = args+strlen(name)+strlen(string)+2;
	}
	e->var_num++;
}

/* Save the global vars to a file. See action documentation. */
static void action_save(Engine* e, Instance* instance, char* args) {
	char* file = args;
	SDL_RWops* rw = SDL_RWFromFile(file, "wb");
	for (size_t i = 0; i < e->var_num; i++) {
		size_t namelen = strlen(e->vars[i].name);
		SDL_RWwrite(rw, &namelen, sizeof(size_t), 1);
		SDL_RWwrite(rw, e->vars[i].name, namelen, 1);
		SDL_RWwrite(rw, &e->vars[i].len, sizeof(size_t), 1);
		SDL_RWwrite(rw, e->vars[i].data, e->vars[i].len, 1);
	}
	SDL_RWclose(rw);
}

/* Load global vars from a file. See action documentation. */
static void action_load(Engine* e, Instance* instance, char* args) {
	char* file = args;
	SDL_RWops* rw = SDL_RWFromFile(file, "rb");
	int eof;
	while (1) {
		e->vars = realloc(e->vars, (e->var_num+1)*sizeof(var));
		size_t namelen = 0;
		eof = SDL_RWread(rw, &namelen, sizeof(size_t), 1);
		if (!eof) break;
		eof = SDL_RWread(rw, e->vars[e->var_num].name, namelen, 1);
		if (!eof) break;
		eof = SDL_RWread(rw, &e->vars[e->var_num].len, sizeof(size_t), 1);
		if (!eof) break;
		eof = SDL_RWread(rw, e->vars[e->var_num].data, e->vars[e->var_num].len, 1);
		if (!eof) break;
		e->var_num++;
	}
	SDL_RWclose(rw);
}

static Uint32 timer_callback(Uint32 interval, void* param) {
	bool* triggered = param;
	*triggered = true;
	return 0;
}

/* Set a custom timer. See action documentation. */
static void action_timer(Engine* e, Instance* instance, char* args) {
	int num = floor(*(float*)args);
	float time = *(float*)(args+sizeof(float));
	if (num < 0 || num > 9 || time < 0) return;
	SDL_RemoveTimer(e->timers[num]);
	e->timers[num] = SDL_AddTimer(time*1000, timer_callback, &e->timer_triggered[num]);
}

/* Set the texture colour mod. See action documentation. */
static void action_colour(Engine* e, Instance* instance, char* args) {
	Uint8 r = floor(*(float*)args);
	Uint8 g = floor(*(float*)args+sizeof(float));
	Uint8 b = floor(*(float*)args+(2*sizeof(float)));
	SDL_SetTextureColorMod(instance->texture.atlas, r, g, b);
}

/* Open the given URI externally. See action documentation. */
static void action_uri(Engine* e, Instance* instance, char* args) {
	char* link = args;
	SDL_OpenURL(link);
}

/* Restart the game. See action documentation. */
static void action_reload(Engine* e, Instance* instance, char* args) {
	e->reload = true;
	action_close(e, NULL, NULL);
}

/* Run a Lua function. See action documentation. */
static void action_lua(Engine* e, Instance* instance, char* args) {
	char* function = args;
	lua_getglobal(e->L, function);
	lua_pushlightuserdata(e->L, e);
	lua_pushlightuserdata(e->L, instance);
	if (lua_pcall(e->L, 2, 0, 0) != 0)
		ERROR("error running function `%s': %s", function, lua_tostring(e->L, -1));
}

/* Set the cursor image. See action documentation. */
static void action_cursor(Engine* e, Instance* instance, char* args) {
	SDL_Surface* surface = (SDL_Surface*)args;
	if (e->cursor) SDL_FreeCursor(e->cursor);
	e->cursor = SDL_CreateColorCursor(surface, surface->w/2, surface->h/2);
	SDL_SetCursor(e->cursor);
}

/* Set the window size. See action documentation. */
static void action_window(Engine* e, Instance* instance, char* args) {
	float w = *(float*)args;
	float h = *(float*)(args+sizeof(float));
	if (w < 0 || h < 0) return;
	e->win_rect.w = w;
	e->win_rect.h = h;
	SDL_SetWindowMinimumSize(e->window, w, h);
	SDL_SetWindowSize(e->window, w, h);
}

/* Modify the text property of an instance. See action documentation. */
static void action_text(Engine* e, Instance* instance, char* args) {
	char* string = args;
	if (instance->text) free(instance->text);
	instance->text = string;
}

/* Set hidden. See action documentation. */
static void action_hide(Engine* e, Instance* instance, char* args) {
	bool state = *args;
	instance->hidden = state;
}

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
		float f; bool b;
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
			size += sizeof(float);
			if (key->type == type) f = key->integer;
			else f = key->real;
			src = &f;
		} else if (type == ZPL_ADT_TYPE_REAL) {
			if (key->props != ZPL_ADT_PROPS_TRUE && key->props != ZPL_ADT_PROPS_FALSE) {
				ERROR("Action parameter wrong type: %s", name);
				return NULL;
			}
			size += sizeof(bool);
			b = key->real;
			src = &b;
		} else {
			ERROR("Not a supported type: %d", type);
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
	if (type == NULL) return -1;

	if (strcmp(type, "spawn") == 0) {
		action->args =
			args_generator(json, 4, "object", ZPL_ADT_TYPE_STRING, "x", ZPL_ADT_TYPE_INTEGER, "y", ZPL_ADT_TYPE_INTEGER, "relative", ZPL_ADT_TYPE_REAL);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_spawn;

	} else if (strcmp(type, "destroy") == 0) {
		action->args = NULL;
		action->free = 0;
		action->run = &action_destroy;

	} else if (strcmp(type, "move") == 0) {
		action->args =
			args_generator(json, 3, "x", ZPL_ADT_TYPE_INTEGER, "y", ZPL_ADT_TYPE_INTEGER, "relative", ZPL_ADT_TYPE_REAL);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_move;

	} else if (strcmp(type, "speed") == 0) {
		action->args =
			args_generator(json, 2, "h", ZPL_ADT_TYPE_INTEGER, "v", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_speed;

	} else if (strcmp(type, "gravity") == 0) {
		action->args =
			args_generator(json, 2, "h", ZPL_ADT_TYPE_INTEGER, "v", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_gravity;

	} else if (strcmp(type, "sound") == 0) {
		char* file = args_generator(json, 1, "file", ZPL_ADT_TYPE_STRING);
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file) == 0) {
				action->args = assets[i].data;
				break;
			}
			if (i == assets_num - 1) return ERROR("Sound file not found");
		}
		free(file);
		action->free = 0;
		action->run = &action_sound;

	} else if (strcmp(type, "music") == 0) {
		char* file = args_generator(json, 1, "file", ZPL_ADT_TYPE_STRING);
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file) == 0) {
				action->args = assets[i].data;
				break;
			}
			if (i == assets_num - 1) return ERROR("Music file not found");
		}
		free(file);
		action->free = 0;
		action->run = &action_music;

	} else if (strcmp(type, "close") == 0) {
		action->args = NULL;
		action->free = 0;
		action->run = &action_close;

	/*} else if (strcmp(type->string, "checkui") == 0) {
		action->args = NULL;
		action->num = 0;
		action->run = &action_checkui;*/

	} else if (strcmp(type, "animation") == 0) {
		action->args =
			args_generator(json, 3, "start", ZPL_ADT_TYPE_INTEGER, "end", ZPL_ADT_TYPE_INTEGER, "time", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_animation;

	} else if (strcmp(type, "rotation") == 0) {
		action->args =
			args_generator(json, 1, "angle", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_rotation;

	} else if (strcmp(type, "variable") == 0) {
		action->args =
			args_generator(json, 2, "name", ZPL_ADT_TYPE_STRING, "string", ZPL_ADT_TYPE_STRING, "number", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_variable;

	} else if (strcmp(type, "save") == 0) {
		action->args =
			args_generator(json, 1, "file", ZPL_ADT_TYPE_STRING);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_save;

	} else if (strcmp(type, "load") == 0) {
		action->args =
			args_generator(json, 1, "file", ZPL_ADT_TYPE_STRING);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_load;

	} else if (strcmp(type, "timer") == 0) {
		action->args =
			args_generator(json, 2, "num", ZPL_ADT_TYPE_INTEGER, "time", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_timer;

	} else if (strcmp(type, "color") == 0) {
		action->args =
			args_generator(json, 3, "r", ZPL_ADT_TYPE_INTEGER, "g", ZPL_ADT_TYPE_INTEGER, "b", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_colour;

	} else if (strcmp(type, "uri") == 0) {
		action->args =
			args_generator(json, 1, "link", ZPL_ADT_TYPE_STRING);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_uri;

	} else if (strcmp(type, "reload") == 0) {
		action->args = NULL;
		action->free = 0;
		action->run = &action_reload;

	} else if (strcmp(type, "lua") == 0) {
		action->args =
			args_generator(json, 1, "function", ZPL_ADT_TYPE_STRING);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_lua;

	} else if (strcmp(type, "cursor") == 0) {
		char* file = args_generator(json, 1, "file", ZPL_ADT_TYPE_STRING);
		for (size_t i = 0; i < assets_num; i++) {
			if (strcmp(assets[i].name, file) == 0) {
				action->args = assets[i].data;
				break;
			}
			if (i == assets_num - 1) return ERROR("Image file not found");
		}
		free(file);
		action->free = 0;
		action->run = &action_cursor;

	} else if (strcmp(type, "window") == 0) {
		action->args =
			args_generator(json, 2, "w", ZPL_ADT_TYPE_INTEGER, "h", ZPL_ADT_TYPE_INTEGER);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_window;

	} else if (strcmp(type, "text") == 0) {
		action->args =
			args_generator(json, 1, "string", ZPL_ADT_TYPE_STRING);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 0;
		action->run = &action_text;

	} else if (strcmp(type, "hide") == 0) {
		action->args =
			args_generator(json, 1, "state", ZPL_ADT_TYPE_REAL);
		if (action->args == NULL) return ERROR("Args generator failed: %s", type);
		action->free = 1;
		action->run = &action_hide;

	} else return ERROR("Invalid action type found: %s", type);
	free(type);
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
	if (action->free) free(action->args);
}

/* Automatically run action based on json description. Should probably
 * be separated into individual functions for performance reasons.
 */
int action_api(lua_State *L) {
	Engine* e = lua_touserdata(L, 1);
	if (e == NULL) {
		ERROR("Engine is nil");
		return 0;
	}
	Instance* instance = lua_touserdata(L, 2);
	if (instance == NULL) {
		ERROR("Instance is nil");
		return 0;
	}
	const char* string = luaL_checkstring(L, 3);
	char* str = malloc(strlen(string)+1);
	strcpy(str, string);
	Action action;
	zpl_json_object json;
	zpl_json_parse(&json, str, zpl_heap());
	if (action_init(&action, &json, e->assets, e->assets_num) < 0) {
		exit(1);
		//return 0; //should improve error handling later
	}
	free(str);
	zpl_json_free(&json);
	action.run(e, instance, action.args);
	action_cleanup(&action);
	return 0;
}

/* Unique spawn function because we want to return the new instance. */
int spawn_api(lua_State *L) {
	Engine* e = lua_touserdata(L, 1);
	if (e == NULL) {
		ERROR("Engine is nil");
		return 0;
	}
	Instance* instance = lua_touserdata(L, 2);
	if (instance == NULL) {
		ERROR("Instance is nil");
		return 0;
	}
	const char* object = luaL_checkstring(L, 3);
	float x = luaL_checknumber(L, 4);
	float y = luaL_checknumber(L, 5);
	bool relative = lua_toboolean(L, 6);
	if (relative && instance->body) {
		cpVect v = cpBodyGetPosition(instance->body);
		x += v.x;
		y += v.y;
	}
	Instance* new_instance = instance_copy(e, object, x, y);
	lua_pushlightuserdata(L, new_instance);
	return 1;
}

/* Add action to event. */
int register_action(lua_State *L) {
	SDL_Log("Not implemented");
	return 0;
}

/*  */
int measure_api(lua_State *L) {
	Instance* instance = lua_touserdata(L, 1);
	if (instance == NULL) {
		ERROR("Instance is nil");
		return 0;
	}
	const char* str = luaL_checkstring(L, 2);
	lua_pushnumber(L, STBTTF_MeasureText(instance->font, str));
	return 1;
}

/*  */
int sleep_api(lua_State *L) {
	double time = luaL_checknumber(L, 1);
	sleep(time);
	return 0;
}

