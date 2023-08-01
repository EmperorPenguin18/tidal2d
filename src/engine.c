//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "engine.h"
#include "embedded_assets.h"
#include <time.h>

static Engine* engine_alloc() {
	Engine* e = (Engine*)malloc(sizeof(Engine));
	if (e == NULL) return NULL;
	e->running = true;
	e->space = NULL;
	e->assets = NULL;
	e->assets_num = 0;
	e->instances = NULL;
	e->instances_num = 0;
	e->layers = NULL;
	e->layers_num = 0;
	e->first_object = NULL;
	e->first_layer = SIZE_MAX;
	e->ui = NULL;
	e->ui_num = 0;
	e->ui_texture = NULL;
	e->ui_font = NULL;
	e->ui_text = NULL;
	e->col_hand = NULL;
	for (size_t i = 0; i < EVENTS_NUM; i++) {
		e->events[i] = NULL;
		e->events_num[i] = 0;
	}
	return e;
}

static int setup_env(Engine* e) {
	time_t t;
	srand((unsigned) time(&t));
	if (S_Init(SDL_INIT_EVERYTHING) < 0) return -1;
#ifdef DEBUG
	S_LogSetPriority(SDL_LOG_CATEGORY_CUSTOM, SDL_LOG_PRIORITY_DEBUG);
#endif
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "SDL initialized");
	e->window = S_CreateWindow("Tidal Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, 0);
	if (!engine->window) return -1;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Window created");
	e->renderer = S_CreateRenderer(engine->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!engine->renderer) return -1;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Renderer created");
	e->space = C_SpaceNew();
	e->col_hand = C_SpaceAddCollisionHandler(engine->space, 1, 1);
	e->col_hand->beginFunc = collisionCallback;
	e->col_hand->userData = e; //Set the collision handler's user data to the context
	return 0;
}

static int load_assets(Engine* e) {
	if (sizeof(embedded_binary) > 0) if (mount_memory() < 0) return -1;
	for (size_t i = 1; i < argc; i++) {
		if (mount(argv[i]) < 0) return -1;
	}
	char[][] names = NULL;
	void*[] binaries = NULL;
	if (read_files(&names, &binaries, &e->assets_num) < 0) return -1;
	Asset* tmp = (Asset*)realloc(e->assets, (e->assets_num)*sizeof(Asset));
	if (tmp == NULL) return -1;
	e->assets = tmp;
	for (size_t i = 0; i < assets_num; i++) {
		if (asset_init(e->assets+i, names[i], binaries[i]) < 0) return -1;
		free(names[i]);
	}
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Files read");
	return 0;
}

/* Initializes the engine, in three parts */
Engine* engine_init(int argc, char *argv[]) {
	Engine* e = engine_alloc();
	if (e == NULL) return NULL;
	if (setup_env(e) < 0) return NULL;
	if (load_assets(e) < 0) return NULL;
	if (e->objects_num > 0) action_spawn(e, e->first_object->name, 0, 0);
	return e;
}

static void postStep(cpSpace *space, cpShape *shape, void *data) {
	event_handler(data, TIDAL_EVENT_COLLISION, C_ShapeGetUserData(shape));
}

/* Part of how Chipmunk2D handles collisions. Is called every time two things collide.
 * Triggers an event for each body colliding.
 */
static unsigned char collisionCallback(cpArbiter *arb, cpSpace *space, void *data) {
	C_ARBITER_GET_SHAPES(arb, a, b);
	C_SpaceAddPostStepCallback(space, (cpPostStepFunc)postStep, a, data);
	C_SpaceAddPostStepCallback(space, (cpPostStepFunc)postStep, b, data);
	return 0;
}

/* The main game loop. Avoid including debug code in this function
 * or functions called by it, for performance reasons.
 */
void engine_run(Engine* e) {
	while (engine->running) {
		Uint64 start = S_GetPerformanceCounter();
		events(e);
		update(e);
		draw(e);
		Uint64 end = S_GetPerformanceCounter();
		float elapsed = (end - start) / (float)S_GetPerformanceFrequency();
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Current FPS: %f\n", 1.0/elapsed);
	}
}

/* Check for events from the player */
static void events(Engine* e) {
	SDL_Event event;
	S_PollEvent(&event);
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
	for (int i = 0; i < e->instances_num; i++) {
		if (e->instances[i].body != NULL) {
			SDL_Rect* dst = &(e->instances[i].dst);
			int w, h;
			S_GetWindowSize(e->window, &w, &h);
			cpVect pos = C_BodyGetPosition(e->instances[i].body);
			if ( (dst->x < w && pos.x > w) || (dst->x > 0-dst->w && pos.x < 0-dst->w) || (dst->y < h && pos.y > h) || (dst->y > 0-dst->h && pos.y < 0-dst->h) ) {
				event_handler(e, TIDAL_EVENT_LEAVE, engine->instances[i].id);
			}
			dst->x = pos.x;
			dst->y = pos.y;
		}
	}
	C_SpaceStep(e->space, 1.0/60.0);
}

/* Loop over every texture, including text, and render them with SDL. */
static void draw(Engine* e) {
	S_SetRenderDrawBlendMode(e->renderer, SDL_BLENDMODE_NONE);
	S_SetRenderDrawColor(e->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	S_RenderClear(e->renderer);
	for (int i = 0; i < e->instances_num; i++) {
		Instance* instance = e->instances + i;
		S_RenderCopy(e->renderer, instance->texture, NULL, &instance->dst);
		if (instance->text) F_Draw(instance->font->normal, e->renderer, instance->dst.x, instance->dst.y, "%s", instance->text);
	}
	S_RenderCopy(e->renderer, e->ui_texture, NULL, &e->ui_dst);
	F_Draw(e->ui_font, e->renderer, e->ui_dst.x, e->ui_dst.y, "%s", e->ui_text);
	S_RenderPresent(e->renderer);
}

/* Free resources used by the engine. Could be cleaned up with
 * generic type cleaners.
 */
void engine_cleanup(Engine* e) {
	for (size_t i = 0; i < e->assets_num; i++) {
		asset_cleanup(e->assets+i);
	}
	free(e->assets); e->assets = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Assets freed");
	for (int i = 0; i < engine->instances_num; i++) {
		instance_cleanup(e->instances+i);
	}
	free(engine->instances); engine->instances = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Instances freed");
	free(engine->layers); engine->layers = NULL;
	S_DestroyTexture(engine->ui_texture);
	free(engine->ui); engine->ui = NULL;
	for (int i = 0; i < EVENTS_NUM; i++) {
		free(engine->events[i]);
		engine->events[i] = NULL;
	}
	C_SpaceFree(engine->space); engine->space = NULL;
	S_DestroyRenderer(engine->renderer); engine->renderer = NULL;
	S_DestroyWindow(engine->window); engine->window = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Window freed");
	S_Quit();
	free(engine); //Local so can't set to NULL
	fprintf(stderr, "INFO: Cleanup complete\n");
}

void engine_error() {
	S_Log("SDL error: %s", S_GetError());
}
