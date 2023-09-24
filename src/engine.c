//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "engine.h"
#include "embedded_assets.h"
#include "filesystem.h"
#include "fonts.h"

#include <time.h>

static Engine* engine_alloc() {
	Engine* e = (Engine*)malloc(sizeof(Engine));
	if (e == NULL) return NULL;
	e->running = false;
	e->space = NULL;
	e->assets = NULL;
	e->assets_num = 0;
	e->instances = NULL;
	e->instances_num = 0;
	e->inert_ins = NULL;
	e->inert_ins_num = 0;
	e->layers = NULL;
	e->layers_num = 0;
	e->first = NULL;
	e->first_layer = SIZE_MAX;
	e->audiodev = 0;
	e->music = NULL;
	return e;
}

/* Engine struct stores a 2D array. The first dimension is the different event types (LEAVE, CREATION etc).
 * The second dimension is dynamically sized and re-sized, and stores all the different actions that instances
 * have added.
 *
 * This function takes the context, event type, and the id of the calling instance, and will loop over
 * all the actions executing them based on the specifications provided by an object.
 */
static void event_handler(Engine* e, event_t ev, Instance* caller) {
	if (ev == TIDAL_EVENT_CREATION || ev == TIDAL_EVENT_DESTRUCTION ||
	ev == TIDAL_EVENT_LEAVE || ev == TIDAL_EVENT_COLLISION) {
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
 * Triggers an event for each body colliding.
 */
static unsigned char collisionCallback(cpArbiter *arb, cpSpace *space, void *data) {
	CP_ARBITER_GET_SHAPES(arb, a, b);
	bool* colliding = cpShapeGetUserData(a);
	*colliding = true;
	colliding = cpShapeGetUserData(b);
	*colliding = true;
	return 0;
}

static int setup_env(Engine* e) {
	time_t t;
	srand((unsigned) time(&t));
	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "SDL init failed: %s", SDL_GetError());
		return -1;
	}
#ifndef NDEBUG
	SDL_LogSetPriority(SDL_LOG_CATEGORY_CUSTOM, SDL_LOG_PRIORITY_DEBUG);
#endif
	SDL_LogSetPriority(SDL_LOG_CATEGORY_ERROR, SDL_LOG_PRIORITY_ERROR);
	e->window = SDL_CreateWindow("Tidal Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, 0);
	if (!e->window) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Create window failed: %s", SDL_GetError());
		return -1;
	}
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Number of render drivers: %d", SDL_GetNumRenderDrivers());
	e->renderer = SDL_CreateRenderer(e->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!e->renderer) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Create renderer failed: %s", SDL_GetError());
		return -1;
	}
	SDL_RendererInfo info;
	if (SDL_GetRendererInfo(e->renderer, &info) < 0) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Get renderer info failed: %s", SDL_GetError());
		return -1;
	}
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Render driver name: %s", info.name);
	char* name;
	SDL_AudioSpec spec;
	if (SDL_GetDefaultAudioInfo(&name, &spec, 0) != 0) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Get audio info failed: %s", SDL_GetError());
		return -1;
	}
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio device name: %s", name);
	e->audiodev = SDL_OpenAudioDevice(name, 0, &spec, NULL, SDL_AUDIO_ALLOW_ANY_CHANGE);
	if (!e->audiodev) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Open audio failed: %s", SDL_GetError());
		return -1;
	}
	SDL_PauseAudioDevice(e->audiodev, 0);
	SDL_free(name);
	e->space = cpSpaceNew();
	cpCollisionHandler* col_hand = cpSpaceAddDefaultCollisionHandler(e->space);
	col_hand->beginFunc = collisionCallback;
	col_hand->userData = e; //Set the collision handler's user data to the context
	return 0;
}

static zpl_isize tar_callback(zpl_file* archive, zpl_tar_record* file, void* user_data) {
	if (file->error != ZPL_TAR_ERROR_NONE || file->type != ZPL_TAR_TYPE_REGULAR)
		return 0; /* skip file */

	Engine* e = user_data;
	Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num+1)*sizeof(Asset));
	if (!tmp) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Out of memory");
		return -1;
	}
	e->assets = tmp;
	zpl_isize size = 0;
	if (asset_init(e->assets+e->assets_num+1, file->path,
		zpl_file_stream_buf(archive, &size)+file->offset, file->length) < 0) {
		SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Asset init failed");
		return -1;
	}
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
			if (!names) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "List files failed");
				return -1;
			}
			Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num+num)*sizeof(Asset));
			if (!tmp) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Out of memory");
				return -1;
			}
			e->assets = tmp;
			for (size_t j = 0; j < num; j++) {
				size_t filesize = 0;
				void* bin = SDL_LoadFile(names[j], &filesize);
				if (!bin) {
					SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Load file failed: %s", SDL_GetError());
					return -1;
				}
				if (asset_init(e->assets+e->assets_num+j, basename(names[j]), bin, filesize) < 0) {
					SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Asset init failed: %s", names[j]);
					return -1;
				}
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
			if (!bin) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Load file failed: %s", SDL_GetError());
				return -1;
			}
			if (asset_init(e->assets+e->assets_num, argv[i], bin, filesize) < 0) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Asset init failed: %s", argv[i]);
				return -1;
			}
			e->assets_num++;
		}
	}
	return 0;
}

static Instance* instance_copy(Engine* e, const char* name, float x, float y) {
	e->instances = (Instance*)realloc(e->instances, (e->instances_num+1)*sizeof(Instance));
	Instance* instance = NULL;
	for (size_t i = 0; i < e->inert_ins_num; i++) { /* Not super efficient */
		if (strcmp(e->inert_ins[i].name, name) == 0) {
			instance = e->inert_ins+i;
			break;
		}
	}
	if (!instance) return NULL;

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
		} else if (instance->physics == PHYSICS_STATIC) {
			instance->body = cpBodyNewKinematic();
			instance->shape = cpSpaceAddShape(e->space, cpBoxShapeNew(instance->body, w, h, 0));
			cpShapeSetFriction(instance->shape, 1.0);
		}
		cpBodySetPosition(instance->body, cpv(x, y));
		instance->colliding = malloc(sizeof(bool));
		*(instance->colliding) = false;
		cpShapeSetUserData(instance->shape, instance->colliding);
	}
	return instance;
}

static void instance_destroy(Engine* e, Instance* instance) {
	size_t n = 0;
	for (size_t i = 0; i < e->instances_num; i++) { /* Not super efficient */
		if (strcmp(instance->id, e->instances[i].id) == 0) {
			n = i;
			break;
		}
	}
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
	for (size_t i = n; i < e->instances_num-1; i++) e->instances[i] = e->instances[i + 1];
	e->instances_num -= 1;
	e->layers[instance->layer] -= 1;
}

void action_spawn(Engine* e, Instance* instance, void** args) {
	Instance* new_ins = instance_copy(e, args[0], *(float*)args[1], *(float*)args[2]);
	if (new_ins) event_handler(e, TIDAL_EVENT_CREATION, new_ins);
}

/* Free resources used by instance. See action documentation. */
void action_destroy(Engine* e, Instance* instance, void** args) {
	event_handler(e, TIDAL_EVENT_DESTRUCTION, instance);
	instance_destroy(e, instance);
}

/* Set a global variable to arbitray data. See action documentation. */
void action_setvar(Engine* e, Instance* instance, void* args[]) {
	return;
}

static int spawn_level(Engine* e) {
	for (size_t i = 0; i < e->assets_num; i++) {
		if (strcmp(getextension(e->assets[i].name), "json") == 0) {
			Instance* tmp = (Instance*)realloc(e->inert_ins, (e->inert_ins_num+1)*sizeof(Instance));
			if (!tmp) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Out of memory");
				return -1;
			}
			e->inert_ins = tmp;
			size_t layer = SIZE_MAX;
			if (instance_create(e->assets+i, e->renderer, e->assets, e->assets_num, e->inert_ins+e->inert_ins_num, &layer) < 0) {
				SDL_LogError(SDL_LOG_CATEGORY_ERROR, "Instance creation failed");
				return -1;
			}
			if (layer < e->first_layer) {
				e->first = e->inert_ins[e->inert_ins_num].name;
				e->first_layer = layer;
			}
			e->inert_ins_num++;
		}
	}
	if (e->first) {
		Instance* new_ins = instance_copy(e, e->first, 0, 0);
		event_handler(e, TIDAL_EVENT_CREATION, new_ins);
		e->running = true; //Something is actually in the game
	}
	return 0;
}

/* Initializes the engine, in four parts */
Engine* engine_init(int argc, char *argv[]) {
	Engine* e = engine_alloc();
	if (e == NULL) return NULL;
	if (setup_env(e) < 0) return NULL;
	if (load_assets(e, argc, argv) < 0) return NULL;
	if (spawn_level(e) < 0) return NULL;
	return e;
}

/* Check for events from the player */
static void events(Engine* e) {
	SDL_Event event;
	SDL_PollEvent(&event);
	switch (event.type) {
		case SDL_QUIT:
			event_handler(e, TIDAL_EVENT_QUIT, NULL);
			break;
		case SDL_KEYDOWN:
			switch (event.key.keysym.sym) {
				case SDLK_w:
					event_handler(e, TIDAL_EVENT_KEYW, NULL);
					break;
				case SDLK_a:
					event_handler(e, TIDAL_EVENT_KEYA, NULL);
					break;
				case SDLK_s:
					event_handler(e, TIDAL_EVENT_KEYS, NULL);
					break;
				case SDLK_d:
					event_handler(e, TIDAL_EVENT_KEYD, NULL);
					break;
				case SDLK_SPACE:
					event_handler(e, TIDAL_EVENT_KEYSPACE, NULL);
					break;
				case SDLK_RETURN:
					event_handler(e, TIDAL_EVENT_KEYENTER, NULL);
					break;
			}
			break;
		case SDL_MOUSEBUTTONUP:
			switch (event.button.button) {
				case SDL_BUTTON_LEFT:
					event_handler(e, TIDAL_EVENT_MOUSELEFT, NULL);
					break;
				case SDL_BUTTON_RIGHT:
					event_handler(e, TIDAL_EVENT_MOUSERIGHT, NULL);
					break;
			}
			break;
	}
}

/* Update instance position based on physics. Could probably be combined with draw(). */
static void update(Engine* e) {
	for (size_t i = 0; i < e->instances_num; i++) {
		if (e->instances[i].body != NULL) {
			SDL_Rect* dst = &(e->instances[i].dst);
			int w, h;
			SDL_GetWindowSize(e->window, &w, &h);
			cpVect pos = cpBodyGetPosition(e->instances[i].body);
			if ( (dst->x < w && pos.x > w) || (dst->x > 0-dst->w && pos.x < 0-dst->w) || (dst->y < h && pos.y > h) || (dst->y > 0-dst->h && pos.y < 0-dst->h) ) {
				event_handler(e, TIDAL_EVENT_LEAVE, e->instances+i);
				continue;
			}
			dst->x = pos.x - dst->w/2;
			dst->y = pos.y - dst->h/2;
			bool* colliding = e->instances[i].colliding;
			if (*colliding) {
				*colliding = false;
				event_handler(e, TIDAL_EVENT_COLLISION, e->instances+i);
			}
		}
	}
	cpSpaceStep(e->space, 1.0/60.0);
}

/* Loop over every texture, including text, and render them with SDL. */
static void draw(Engine* e) {
	SDL_SetRenderDrawBlendMode(e->renderer, SDL_BLENDMODE_NONE);
	SDL_SetRenderDrawColor(e->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	SDL_RenderClear(e->renderer);
	for (size_t i = 0; i < e->instances_num; i++) {
		Instance* instance = e->instances + i;
		SDL_RenderCopy(e->renderer, instance->texture, NULL, &instance->dst);
		font_draw(e->renderer, instance->font, 28, instance->dst.x, instance->dst.y, instance->text);
#ifndef NDEBUG
		SDL_SetRenderDrawColor(e->renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE);
		SDL_RenderDrawRect(e->renderer, &instance->dst);
#endif
	}
	SDL_RenderPresent(e->renderer);
}

/* The main game loop. Avoid including debug code in this function
 * or functions called by it, for performance reasons.
 */
void engine_run(Engine* e) {
	while (e->running) {
		Uint64 start = SDL_GetPerformanceCounter();
		events(e);
		update(e);
		draw(e);
		if (SDL_GetQueuedAudioSize(e->audiodev) == 0) // Loop music
			SDL_QueueAudio(e->audiodev, e->music->userdata, e->music->size);
#ifndef NDEBUG
		Uint64 end = SDL_GetPerformanceCounter();
		float elapsed = (end - start) / (float)SDL_GetPerformanceFrequency();
		void** args = malloc(2*sizeof(void*));
		args[0] = malloc(strlen("TIDAL_FPS")+1);
		strcpy(args[0], "TIDAL_FPS");
		args[1] = malloc(sizeof(float));
		*(float*)args[1] = 1.0/elapsed;
		action_setvar(e, NULL, args);
		free(args[0]); free(args[1]); free(args);
#endif
	}
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
	cpSpaceFree(e->space); e->space = NULL;
	SDL_CloseAudioDevice(e->audiodev);
	SDL_DestroyRenderer(e->renderer); e->renderer = NULL;
	SDL_DestroyWindow(e->window); e->window = NULL;
	SDL_Quit();
	free(e); //Local so can't set to NULL
}
