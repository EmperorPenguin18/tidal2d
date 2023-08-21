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
	/*e->ui = NULL;
	e->ui_num = 0;
	e->ui_texture = NULL;
	e->ui_font = NULL;
	e->ui_text = NULL;*/
	e->col_hand = NULL;
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

static void postStep(cpSpace *space, cpShape *shape, void *data) {
	event_handler(data, TIDAL_EVENT_COLLISION, cpShapeGetUserData(shape));
}

/* Part of how Chipmunk2D handles collisions. Is called every time two things collide.
 * Triggers an event for each body colliding.
 */
static unsigned char collisionCallback(cpArbiter *arb, cpSpace *space, void *data) {
	CP_ARBITER_GET_SHAPES(arb, a, b);
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStep, a, data);
	cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStep, b, data);
	return 0;
}

static int setup_env(Engine* e) {
	time_t t;
	srand((unsigned) time(&t));
	if (SDL_Init(SDL_INIT_EVERYTHING) < 0) return -1;
#ifdef DEBUG
	SDL_LogSetPriority(SDL_LOG_CATEGORY_CUSTOM, SDL_LOG_PRIORITY_DEBUG);
#endif
	e->window = SDL_CreateWindow("Tidal Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, 0);
	if (!e->window) return -1;
	e->renderer = SDL_CreateRenderer(e->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!e->renderer) return -1;
	char* name;
	SDL_AudioSpec spec;
	if (SDL_GetDefaultAudioInfo(&name, &spec, 0) != 0) return -1;
	SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio device name: %s\n", name);
	e->audiodev = SDL_OpenAudioDevice(name, 0, &spec, NULL, SDL_AUDIO_ALLOW_ANY_CHANGE);
	if (!e->audiodev) return -1;
	SDL_PauseAudioDevice(e->audiodev, 0);
	SDL_free(name);
	e->space = cpSpaceNew();
	e->col_hand = cpSpaceAddCollisionHandler(e->space, 1, 1);
	e->col_hand->beginFunc = collisionCallback;
	e->col_hand->userData = e; //Set the collision handler's user data to the context
	return 0;
}

static zpl_isize tar_callback(zpl_file* archive, zpl_tar_record* file, void* user_data) {
	if (file->error != ZPL_TAR_ERROR_NONE || file->type != ZPL_TAR_TYPE_REGULAR)
		return 0; /* skip file */

	Engine* e = user_data;
	Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num+1)*sizeof(Asset));
	if (!tmp) return -1;
	e->assets = tmp;
	zpl_isize size = 0;
	if (asset_init(e->assets+e->assets_num+1, file->path,
		zpl_file_stream_buf(archive, &size)+file->offset, file->length) < 0) return -1;
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
			if (!names) return -1;
			Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num+num)*sizeof(Asset));
			if (!tmp) return -1;
			e->assets = tmp;
			for (size_t j = 0; j < num; j++) {
				size_t filesize = 0;
				void* bin = SDL_LoadFile(names[j], &filesize);
				if (!bin) {
					SDL_Log("Failed to load file");
					return -1;
				}
				if (asset_init(e->assets+e->assets_num+j, basename(names[j]), bin, filesize) < 0) {
					SDL_Log("Asset init failed: %s", names[j]);
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
				SDL_Log("Failed to load file");
				return -1;
			}
			if (asset_init(e->assets+e->assets_num, argv[i], bin, filesize) < 0) {
				SDL_Log("Asset init failed: %s", argv[i]);
				return -1;
			}
			e->assets_num++;
		}
	}
	return 0;
}

static Instance* instance_copy(Engine* e, const char* name, int x, int y) {
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
	/*instance->dst.x = x;
	instance->dst.y = y;*/
	if (instance->physics != PHYSICS_NONE) {
		if (instance->physics == PHYSICS_BOX) {
			instance->body = cpBodyNew(1, cpMomentForBox(1, instance->dst.w, instance->dst.h));
			instance->shape = cpBoxShapeNew(instance->body, instance->dst.w, instance->dst.h, 0);
			cpShapeSetFriction(instance->shape, 0.7);
		} else if (instance->physics == PHYSICS_STATIC) {
			instance->body = cpBodyNewStatic();
			instance->shape = cpBoxShapeNew(instance->body, instance->dst.w, instance->dst.h, 0);
			cpShapeSetFriction(instance->shape, 1);
		}
		cpShapeSetUserData(instance->shape, instance);
		cpShapeSetCollisionType(instance->shape, 1);
		cpBodySetPosition(instance->body, cpv(x, y));
		//if (!cpBodyGetSpace(instance->body)) { //fails if static
			cpSpaceAddBody(e->space, instance->body);
		//}
		cpSpaceAddShape(e->space, instance->shape);
		cpSpaceReindexShape(e->space, instance->shape);
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
	free(instance->id);
	if (instance->shape) {
		cpSpaceRemoveShape(e->space, instance->shape);
		cpSpaceRemoveBody(e->space, instance->body);
		cpShapeFree(instance->shape);
		cpBodyFree(instance->body);
	}
	for (size_t i = n; i < e->instances_num-1; i++) e->instances[i] = e->instances[i + 1];
	e->instances_num -= 1;
	e->layers[instance->layer] -= 1;
}

void action_spawn(Engine* e, Instance* instance, void** args) {
	Instance* new_ins = instance_copy(e, args[0], *(int*)args[1], *(int*)args[2]);
	if (new_ins) event_handler(e, TIDAL_EVENT_CREATION, new_ins);
}

/* Free resources used by instance. See action documentation. */
void action_destroy(Engine* e, Instance* instance, void** args) {
	event_handler(e, TIDAL_EVENT_DESTRUCTION, instance);
	instance_destroy(e, instance);
}

static int spawn_level(Engine* e) {
	for (size_t i = 0; i < e->assets_num; i++) {
		if (strcmp(getextension(e->assets[i].name), "json") == 0) {
			Instance* tmp = (Instance*)realloc(e->inert_ins, (e->inert_ins_num+1)*sizeof(Instance));
			if (!tmp) return -1;
			e->inert_ins = tmp;
			size_t layer = SIZE_MAX;
			if (instance_create(e->assets+i, e->renderer, e->assets, e->assets_num, e->inert_ins+e->inert_ins_num, &layer) < 0) {
				SDL_Log("Instance creation failed");
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
			}
			dst->x = pos.x;
			dst->y = pos.y;
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
	}
	//SDL_RenderCopy(e->renderer, e->ui_texture, NULL, &e->ui_dst);
	//F_Draw(e->ui_font, e->renderer, e->ui_dst.x, e->ui_dst.y, "%s", e->ui_text);
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
		Uint64 end = SDL_GetPerformanceCounter();
		float elapsed = (end - start) / (float)SDL_GetPerformanceFrequency();
		SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Current FPS: %f\n", 1.0/elapsed);
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
	/*SDL_DestroyTexture(engine->ui_texture);
	free(engine->ui); engine->ui = NULL;*/
	cpSpaceFree(e->space); e->space = NULL;
	SDL_CloseAudioDevice(e->audiodev);
	SDL_DestroyRenderer(e->renderer); e->renderer = NULL;
	SDL_DestroyWindow(e->window); e->window = NULL;
	SDL_Quit();
	free(e); //Local so can't set to NULL
}

void engine_error() {
	SDL_Log("SDL error: %s", SDL_GetError());
}
