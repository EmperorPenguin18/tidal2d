//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include <time.h>

#include "filesystem.h"
#include "stbttf.h"
#include "events.h"
#include "actions.h"
#include "embedded_assets.h"

#include "engine.h"

/* Loops over actions and runs them. */
void event_handler(Engine* e, event_t ev, Instance* caller) {
	if (ev == TIDAL_EVENT_CREATION || ev == TIDAL_EVENT_DESTRUCTION ||
	ev == TIDAL_EVENT_LEAVE || ev == TIDAL_EVENT_COLLISION ||
	ev == TIDAL_EVENT_ANIMATION || ev == TIDAL_EVENT_CLICKON) {
		//Special case: some events only trigger based on instance id
		for (size_t j = 0; j < caller->actions_num[ev]; j++) {
			Action* action = caller->actions[ev] + j;
			action->run(e, caller, action->args);
		}
		return;
	}
	for (size_t i = 0; i < e->instances_num; i++) {
		Instance* ins = e->instances + i;
		for (size_t j = 0; j < ins->actions_num[ev]; j++) {
			Action* action = ins->actions[ev] + j;
			action->run(e, ins, action->args);
		}
	}
}

/* Part of how Chipmunk2D handles collisions. Is called every time two things collide.
 * Will trigger an event for each body colliding.
 */
static unsigned char collisionCallback(cpArbiter *arb, cpSpace *space, void *data) {
	CP_ARBITER_GET_SHAPES(arb, a, b);
	bool* colliding = cpShapeGetUserData(a);
	*colliding = true;
	colliding = cpShapeGetUserData(b);
	*colliding = true;
	return 0;
}

int action_api(lua_State* L);

/* Setup libraries */
static int setup_env(Engine* e) {
	time_t t;
	srand((unsigned) time(&t));
#ifndef NDEBUG
	SDL_LogSetPriority(SDL_LOG_CATEGORY_CUSTOM, SDL_LOG_PRIORITY_DEBUG);
#endif
	SDL_LogSetPriority(SDL_LOG_CATEGORY_ERROR, SDL_LOG_PRIORITY_ERROR);
	if (SDL_Init(SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_TIMER) < 0) return ERROR("SDL init failed: %s", SDL_GetError());
	e->win_rect.w = 640.0;
	e->win_rect.h = 480.0;
	e->window = SDL_CreateWindow("Tidal Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, e->win_rect.w, e->win_rect.h, 0);
	if (!e->window) return ERROR("Create window failed: %s", SDL_GetError());
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Number of render drivers: %d", SDL_GetNumRenderDrivers());
	e->renderer = SDL_CreateRenderer(e->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!e->renderer) return ERROR("Create renderer failed: %s", SDL_GetError());
	SDL_RendererInfo info;
	if (SDL_GetRendererInfo(e->renderer, &info) < 0) return ERROR("Get renderer info failed: %s", SDL_GetError());
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Render driver name: %s", info.name);
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Number of audio devices: %d", SDL_GetNumAudioDevices(0));
	char* name;
	SDL_AudioSpec spec;
	if (SDL_GetDefaultAudioInfo(&name, &spec, 0) != 0) {
		if (SDL_GetAudioDeviceSpec(0, 0, &spec) != 0) {
			spec.freq = 48000;
			spec.format = AUDIO_S16SYS;
			spec.samples = 2048;
		}
	} else SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio device name: %s", name);
	e->audiodev = SDL_OpenAudioDevice(name, 0, &spec, &e->audio_buf, SDL_AUDIO_ALLOW_ANY_CHANGE);
	if (!e->audiodev) return ERROR("Open audio failed: %s", SDL_GetError());
	SDL_PauseAudioDevice(e->audiodev, 0);
	e->audio_buf.size = 0;
	SDL_free(name);
	e->space = cpSpaceNew();
	cpCollisionHandler* col_hand = cpSpaceAddDefaultCollisionHandler(e->space);
	col_hand->beginFunc = collisionCallback;
	col_hand->userData = e; //Set the collision handler's user data to the context
	e->L = luaL_newstate();
	luaL_openlibs(e->L);
	lua_pushcfunction(e->L, action_api);
	lua_setglobal(e->L, "action");
#ifndef NDEBUG
	e->fps = malloc(sizeof(float));
	e->vars = realloc(e->vars, sizeof(var));
	e->vars[0].name = "TIDAL_FPS";
	e->vars[0].len = sizeof(float);
	e->vars[0].data = e->fps;
#endif
	return 0;
}

/* Callback that is run for each file in a tar */
static zpl_isize tar_callback(zpl_file* archive, zpl_tar_record* file, void* user_data) {
	if (file->error != ZPL_TAR_ERROR_NONE || file->type != ZPL_TAR_TYPE_REGULAR)
		return 0; /* skip file */

	Engine* e = user_data;
	Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num+1)*sizeof(Asset));
	if (!tmp) return ERROR("Out of memory");
	e->assets = tmp;
	zpl_isize size = 0;
	void* bin = malloc(file->length);
	memcpy(bin, zpl_file_stream_buf(archive, &size)+file->offset, file->length);
	if (asset_init(e->assets+e->assets_num, base(file->path), bin, file->length) < 0)
		return ERROR("Asset init failed");
	e->assets_num++;
	return 0;
}

static int load_assets(Engine* e, int argc, char* argv[]) {
	if (sizeof(embedded_binary) > 0) {
		zpl_file file;
		zpl_file_stream_open(&file, zpl_heap(), embedded_binary, sizeof(embedded_binary), 0);
		zpl_tar_unpack(&file, tar_callback, e);
		zpl_file_close(&file);
	}
	//embedded_path at some point
	for (size_t i = 1; i < argc; i++) {
		if (is_dir(argv[i])) {
			size_t num = 0;
			char** names = list_files(&num, argv[i]);
			if (!names) return ERROR("List files failed");
			Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num+num)*sizeof(Asset));
			if (!tmp) return ERROR("Out of memory");
			e->assets = tmp;
			for (size_t j = 0; j < num; j++) {
				size_t filesize = 0;
				void* bin = SDL_LoadFile(names[j], &filesize);
				if (!bin) return ERROR("Load file failed: %s", SDL_GetError());
				if (asset_init(e->assets+e->assets_num+j, base(names[j]), bin, filesize) < 0) return ERROR("Asset init failed: %s", names[j]);
				free(names[j]);
			}
			e->assets_num += num;
			free(names);
		} else {
			Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num+1)*sizeof(Asset));
			if (!tmp) return -1;
			e->assets = tmp;
			size_t filesize = 0;
			void* bin = SDL_LoadFile(argv[i], &filesize);
			if (!bin) return ERROR("Load file failed: %s", SDL_GetError());
			if (asset_init(e->assets+e->assets_num, base(argv[i]), bin, filesize) < 0) return ERROR("Asset init failed: %s", argv[i]);
			e->assets_num++;
		}
	}
	return 0;
}

/* Creates an instance that will actually show up in the world. Probably slow. */
void instance_copy(Engine* e, const char* name, float x, float y) {
	e->instances = (Instance*)realloc(e->instances, (e->instances_num+1)*sizeof(Instance));
	Instance* instance = NULL;
	for (size_t i = 0; i < e->inert_ins_num; i++) { /* Not super efficient */
		if (strcmp(e->inert_ins[i].name, name) == 0) {
			instance = e->inert_ins+i;
			break;
		}
	}
	if (!instance) return; // uh-oh

	if (instance->layer+1 > e->layers_num) {//If the specified layer is higher than the highest, fill them all out
		e->layers = (size_t*)realloc(e->layers, (instance->layer+1)*sizeof(size_t));
		for (size_t i = e->layers_num; i < instance->layer+1; i++) e->layers[i] = 0;
		e->layers_num = instance->layer+1;
	}
	size_t sum = 0;
	for (size_t i = 0; i < instance->layer+1; i++) sum += e->layers[i];//Get the spot where the new instance will slot in
	e->layers[instance->layer]++;
	//Make a spot in the array
	for (size_t i = e->instances_num; i > sum; i--) e->instances[i] = e->instances[i - 1];
	e->instances_num++;
	*(e->instances + sum) = *instance; //Shallow copy
	instance = e->instances + sum;

	instance->id = gen_uuid();
	instance->dst.x = x;
	instance->dst.y = y;
	if (instance->physics != PHYSICS_NONE) {
		cpFloat w = instance->dst.w;
		cpFloat h = instance->dst.h;
		if (instance->physics == PHYSICS_BOX) {
			instance->body = cpSpaceAddBody(e->space, cpBodyNew(1, INFINITY));
			instance->shape = cpSpaceAddShape(e->space, cpBoxShapeNew(instance->body, w, h, 0));
			cpShapeSetFriction(instance->shape, 0.7);
		} else if (instance->physics == PHYSICS_BOX_STATIC) {
			instance->body = cpBodyNewKinematic();
			instance->shape = cpSpaceAddShape(e->space, cpBoxShapeNew(instance->body, w, h, 0));
			cpShapeSetFriction(instance->shape, 1.0);
		} else if (instance->physics == PHYSICS_TRIANGLE) {
			instance->body = cpSpaceAddBody(e->space, cpBodyNew(1, INFINITY));
			cpVect verts[3];
			verts[0].x = 0;
			verts[0].y = -h/2;
			verts[1].x = -w/2;
			verts[1].y = h/2;
			verts[2].x = w/2;
			verts[2].y = h/2;
			instance->shape = cpSpaceAddShape(e->space, cpPolyShapeNewRaw(instance->body, 3, verts, 0));
			cpShapeSetFriction(instance->shape, 0.7);
		} else if (instance->physics == PHYSICS_TRIANGLE_STATIC) {
			instance->body = cpBodyNewKinematic();
			cpVect verts[3];
			verts[0].x = 0;
			verts[0].y = -h/2;
			verts[1].x = -w/2;
			verts[1].y = h/2;
			verts[2].x = w/2;
			verts[2].y = h/2;
			instance->shape = cpSpaceAddShape(e->space, cpPolyShapeNewRaw(instance->body, 3, verts, 0));
			cpShapeSetFriction(instance->shape, 1.0);
		}
		cpBodySetPosition(instance->body, cpv(x, y));
		instance->colliding = malloc(sizeof(bool));
		*(instance->colliding) = false;
		cpShapeSetUserData(instance->shape, instance->colliding);
	}

	event_handler(e, TIDAL_EVENT_CREATION, instance);
}

/* Removes instance from world. Doesn't shrink array */
void instance_destroy(Engine* e, Instance* instance) {
	event_handler(e, TIDAL_EVENT_DESTRUCTION, instance);

	free(instance->id); instance->id = NULL;
	if (instance->shape) {
		free(instance->colliding); instance->colliding = NULL;
		cpSpaceRemoveShape(e->space, instance->shape);
		if (cpBodyGetType(instance->body) != CP_BODY_TYPE_STATIC &&
		cpBodyGetType(instance->body) != CP_BODY_TYPE_KINEMATIC) {
			cpSpaceRemoveBody(e->space, instance->body);
		}
		cpShapeFree(instance->shape); instance->shape = NULL;
		cpBodyFree(instance->body); instance->body = NULL;
	}
	e->layers[instance->layer] -= 1;
	memset(instance, 0, sizeof(Instance));
}

/* Create all the objects, then spawn the first one. */
static int spawn_level(Engine* e) {
	for (size_t i = 0; i < e->assets_num; i++) {
		if (strcmp(getextension(e->assets[i].name), "json") == 0) {
			Instance* tmp = (Instance*)realloc(e->inert_ins, (e->inert_ins_num+1)*sizeof(Instance));
			if (!tmp) return ERROR("Out of memory");
			e->inert_ins = tmp;
			size_t layer = SIZE_MAX;
			if (instance_create(e->assets+i, e->renderer, e->assets, e->assets_num, e->inert_ins+e->inert_ins_num, &layer) < 0)
				return ERROR("Instance creation failed");
			if (layer < e->first_layer) {
				e->first = e->inert_ins[e->inert_ins_num].name;
				e->first_layer = layer;
			}
			e->inert_ins_num++;
		} else if (strcmp(getextension(e->assets[i].name), "lua") == 0) {
			luaL_dostring(e->L, e->assets[i].data);
		}
	}
	if (e->first) {
		instance_copy(e, e->first, 0, 0);
		e->running = true; //Something is actually in the game
	}
	return 0;
}

/* Initializes the engine, in four parts */
Engine* engine_init(int argc, char *argv[]) {
	Engine* e = (Engine*)malloc(sizeof(Engine));
	if (e == NULL) return NULL;
	memset(e, 0, sizeof(Engine));
	e->first_layer = SIZE_MAX;
	if (setup_env(e) < 0) return NULL;
	if (load_assets(e, argc, argv) < 0) return NULL;
	if (spawn_level(e) < 0) return NULL;
	return e;
}

/* Update instance position based on physics. Watch out for destroying instances in the loop. */
static void update(Engine* e) {
	int mouse_x, mouse_y;
	Uint32 mouse = SDL_GetMouseState(&mouse_x, &mouse_y);
	SDL_FPoint point; point.x = mouse_x; point.y = mouse_y;
	for (size_t i = 0; i < e->instances_num; i++) {
		Instance* instance = e->instances+i;
		SDL_FRect* dst = &(instance->dst);
		if (instance->body != NULL) {
			cpVect pos = cpBodyGetPosition(instance->body);
			SDL_FRect result;
			dst->x = pos.x - dst->w/2;
			dst->y = pos.y - dst->h/2;
			if (!SDL_IntersectFRect(&e->win_rect, dst, &result)) {
				event_handler(e, TIDAL_EVENT_LEAVE, instance);
				continue;
			}
			bool* colliding = instance->colliding;
			if (*colliding) {
				*colliding = false;
				event_handler(e, TIDAL_EVENT_COLLISION, instance);
				continue;
			}
		}
		if (instance->frame > instance->end_frame) {
			instance->frame = instance->end_frame;
			instance->end_frame = -1;
			event_handler(e, TIDAL_EVENT_ANIMATION, instance);
			continue;
		}
		if (mouse && SDL_PointInFRect(&point, dst)) {
			event_handler(e, TIDAL_EVENT_CLICKON, instance);
		}
	}
	for (int i = 0; i < 10; i++) {
		if (e->timer_triggered[i]) {
			e->timer_triggered[i] = false;
			event_handler(e, TIDAL_EVENT_TIMER_0+i, NULL);
		}
	}
	cpSpaceStep(e->space, 1.0/60.0);
}

/* Loop over every texture, including text, and render them with SDL. */
static void draw(Engine* e) {
	SDL_SetRenderDrawBlendMode(e->renderer, SDL_BLENDMODE_BLEND);
	SDL_SetRenderDrawColor(e->renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE);
	SDL_RenderClear(e->renderer);
	SDL_SetRenderDrawColor(e->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	SDL_RenderFillRectF(e->renderer, &e->win_rect);
	SDL_SetRenderDrawColor(e->renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE);
	for (size_t i = 0; i < e->instances_num; i++) {
		Instance* instance = e->instances + i;
		if (instance->texture.atlas) {
			SDL_Rect src;
			src.x = instance->texture.x[instance->frame];
			src.y = instance->texture.y[instance->frame];
			src.w = instance->dst.w;
			src.h = instance->dst.h;
			double angle = cpBodyGetAngle(instance->body)*(180/CP_PI);
			//SDL_FPoint center; cpVect v = cpBodyLocalToWorld(instance->body, cpBodyGetCenterOfGravity(instance->body)); center.x = v.x; center.y = v.y;
			SDL_RenderCopyExF(e->renderer, instance->texture.atlas, &src, &instance->dst, angle, NULL, SDL_FLIP_NONE);
		}
		if (instance->font) {
			STBTTF_Font* font = STBTTF_OpenFontRW(e->renderer, SDL_RWFromConstMem(instance->font->data, instance->font->len), 28);
			STBTTF_RenderText(e->renderer, font, instance->dst.x, instance->dst.y+28, instance->text);
			STBTTF_CloseFont(font);
		}
#ifndef NDEBUG
		SDL_RenderDrawRectF(e->renderer, &instance->dst);
#endif
	}
	SDL_RenderPresent(e->renderer);
}

/* The main game loop. Avoid including debug code in this function
 * or functions called by it, for performance reasons.
 */
void engine_run(void* p) {
	Engine* e = p;
	Uint64 start = SDL_GetPerformanceCounter();
	event_t ev = get_event();
	if (ev != TIDAL_EVENT_ERR) event_handler(e, ev, NULL);
	update(e);
	draw(e);
	if (SDL_GetQueuedAudioSize(e->audiodev) == 0 && e->music) { // Loop music
		e->audio_buf.userdata = realloc(e->audio_buf.userdata, e->music->size);
		e->audio_buf.size = e->music->size;
		memset(e->audio_buf.userdata, e->audio_buf.silence, e->audio_buf.size);
		SDL_MixAudioFormat(e->audio_buf.userdata, e->music->userdata, e->music->format, e->music->size, SDL_MIX_MAXVOLUME);
		SDL_QueueAudio(e->audiodev, e->audio_buf.userdata, e->audio_buf.size);
	}
#ifndef NDEBUG
	Uint64 end = SDL_GetPerformanceCounter();
	float elapsed = (end - start) / (float)SDL_GetPerformanceFrequency();
	float fps = 1.0/elapsed;
	memcpy(e->fps, &fps, sizeof(float));
#endif
}

/* Free resources used by the engine. Could be cleaned up with
 * generic type cleaners.
 */
void engine_cleanup(Engine* e) {
	for (size_t i = 0; i < e->assets_num; i++) {
		asset_cleanup(e->assets+i);
	}
	free(e->assets); e->assets = NULL;
	for (size_t i = 0; i < e->instances_num; i++) {
		instance_destroy(e, e->instances+i);
	}
	free(e->instances); e->instances = NULL;
	for (size_t i = 0; i < e->inert_ins_num; i++) {
		instance_cleanup(e->inert_ins+i);
	}
	free(e->inert_ins); e->inert_ins = NULL;
	free(e->layers); e->layers = NULL;
	if (e->audio_buf.userdata) {
		free(e->audio_buf.userdata);
		e->audio_buf.userdata = NULL;
	}
	/*for (size_t i = 0; i < e->var_num; i++) {
		free(e->vars[i].name);
		free(e->vars[i].data);
	}*/
	if (e->vars) { free(e->vars); e->vars = NULL; }
	lua_close(e->L);
	cpSpaceFree(e->space); e->space = NULL;
	SDL_CloseAudioDevice(e->audiodev);
	SDL_DestroyRenderer(e->renderer); e->renderer = NULL;
	SDL_DestroyWindow(e->window); e->window = NULL;
	SDL_Quit();
#ifndef NDEBUG
	free(e->fps); e->fps = NULL;
#endif
	free(e); //Local so can't set to NULL
}
