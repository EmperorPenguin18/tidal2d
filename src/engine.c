//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include <time.h>

#include "filesystem.h"
#include "events.h"
#include "actions.h"
#include "embedded_assets.h"

#include "engine.h"

/* Loops over actions and runs them. */
void event_handler(Engine* e, event_t ev, Instance* caller) {
	if (ev == TIDAL_EVENT_CREATION || ev == TIDAL_EVENT_DESTRUCTION ||
	ev == TIDAL_EVENT_LEAVE || (ev >= TIDAL_EVENT_COLLISION_0 && ev <= TIDAL_EVENT_COLLISION_9) ||
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
	cpCollisionType type_a = cpShapeGetCollisionType(a);
	cpCollisionType type_b = cpShapeGetCollisionType(b);
	if (type_a < 10 && type_a >= 0 && type_b < 10 && type_b >= 0) {
		int* colliding = cpShapeGetUserData(a);
		*colliding = type_b;
		colliding = cpShapeGetUserData(b);
		*colliding = type_a;
		return cpTrue;
	}
	return cpFalse;
}

int action_api(lua_State* L);
int spawn_api(lua_State* L);
int register_action(lua_State* L);

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
			spec.freq = 44100;
			spec.format = AUDIO_F32;
		}
	} else SDL_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio device name: %s", name);
	e->audiodev = SDL_OpenAudioDevice(name, 0, &spec, &e->audio_buf, 0);
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
	lua_register(e->L, "action", action_api);
	lua_register(e->L, "spawn", spawn_api);
	lua_register(e->L, "register_action", register_action);
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
	char* bin = malloc(file->length+1);
	memcpy(bin, zpl_file_stream_buf(archive, &size)+file->offset, file->length);
	bin[file->length] = '\0';
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
Instance* instance_copy(Engine* e, const char* name, float x, float y) {
	if (e->instances_num == MAX_INSTANCES) return NULL;
	Asset* asset = NULL;
	for (size_t i = 0; i < e->assets_num; i++) { /* Not super efficient */
		if (strcmp(e->assets[i].name, name) == 0) {
			asset = e->assets+i;
			break;
		}
	}
	if (!asset) return NULL;

	Instance* instance = e->instances+e->instances_num;
	if (instance_create(asset, e->renderer, e->assets, e->assets_num, e->space, instance) < 0)
		return NULL;
	instance->id = e->instances_num;
	e->instances_num++;
	instance->dst.x = x;
	instance->dst.y = y;
	if (instance->body) {
		cpBodySetPosition(instance->body, cpv(x, y));
	}

	event_handler(e, TIDAL_EVENT_CREATION, instance);
	return instance;
}

/* Removes instance from world. Doesn't shrink array */
void instance_destroy(Engine* e, Instance* instance) {
	event_handler(e, TIDAL_EVENT_DESTRUCTION, instance);

	instance_cleanup(e->space, instance);
}

static void convert_audio(Engine* e, SDL_AudioSpec* spec) {
	SDL_AudioCVT cvt;
	SDL_BuildAudioCVT(&cvt, spec->format, spec->channels, spec->freq,
		e->audio_buf.format, e->audio_buf.channels, e->audio_buf.freq);
	if (cvt.needed) {
		cvt.len = spec->size;
		cvt.buf = SDL_malloc(cvt.len * cvt.len_mult);
		memcpy(cvt.buf, spec->userdata, spec->size);
		SDL_ConvertAudio(&cvt);
		free(spec->userdata);
		spec->userdata = cvt.buf;
		spec->size = cvt.len_cvt;
		spec->format = cvt.dst_format;
		spec->channels = e->audio_buf.channels;
		spec->freq = e->audio_buf.freq;
	}
}

/* Create all the objects, then spawn the first one. */
static int spawn_level(Engine* e) {
	char* first = NULL;
	size_t first_layer = SIZE_MAX;
	for (size_t i = 0; i < e->assets_num; i++) {
		const char* ext = getextension(e->assets[i].name);
		if (strcmp(ext, "json") == 0) {
			Instance instance;
			if (instance_create(e->assets+i, e->renderer, e->assets, e->assets_num, e->space, &instance) < 0)
				return ERROR("Instance creation failed: %s", e->assets[i].name);
			if (instance.layer < first_layer) {
				first = instance.name;
				first_layer = instance.layer;
			}
			instance_cleanup(e->space, &instance);
		} else if (strcmp(ext, "lua") == 0) {
			if (luaL_dostring(e->L, e->assets[i].data) != 0)
				return ERROR("Doing Lua failed: %s\n%s\n%s", e->assets[i].name, e->assets[i].data, lua_tostring(e->L, -1));
		} else if (strcmp(ext, "wav") == 0 || strcmp(ext, "ogg") == 0) {
			convert_audio(e, e->assets[i].data);
		}
	}
	if (first) {
		instance_copy(e, first, 0, 0);
		e->running = true; //Something is actually in the game
	}
	return 0;
}

/* Initializes the engine, in four parts */
Engine* engine_init(int argc, char *argv[]) {
	Engine* e = (Engine*)malloc(sizeof(Engine));
	if (e == NULL) return NULL;
	memset(e, 0, sizeof(Engine));
	if (setup_env(e) < 0) return NULL;
	if (load_assets(e, argc, argv) < 0) return NULL;
	if (spawn_level(e) < 0) return NULL;
	return e;
}

/* Update instance position based on physics. Watch out for destroying instances in the loop. */
static void update(Engine* e) {
	int mouse_x, mouse_y;
	Uint32 mouse_state = SDL_GetMouseState(&mouse_x, &mouse_y);
	bool mouse = !e->prev_mouse && mouse_state;
	e->prev_mouse = mouse_state;
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
			int* colliding = instance->colliding;
			if (*colliding >= 0) {
				int col = *colliding;
				*colliding = -1;
				event_handler(e, TIDAL_EVENT_COLLISION_0+col, instance);
				continue;
			}
		}
		if (instance->inc_frame) {
			instance->inc_frame = false;
			if (instance->frame == instance->end_frame) {
				SDL_RemoveTimer(instance->timer);
				instance->end_frame = -1;
				event_handler(e, TIDAL_EVENT_ANIMATION, instance);
				continue;
			} else {
				instance->frame++;
			}
		}
		SDL_FRect text_dst; text_dst.x = dst->x; text_dst.y = dst->y;
		text_dst.w = (instance->text) ? STBTTF_MeasureText(instance->font, instance->text) : 0;
		text_dst.h = 28.0f;
		if (mouse && (SDL_PointInFRect(&point, dst) || SDL_PointInFRect(&point, &text_dst))) {
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
			double angle;
			if (instance->body) angle = cpBodyGetAngle(instance->body)*(180/CP_PI);
			else angle = 0;
			//SDL_FPoint center; cpVect v = cpBodyLocalToWorld(instance->body, cpBodyGetCenterOfGravity(instance->body)); center.x = v.x; center.y = v.y;
			SDL_RenderCopyExF(e->renderer, instance->texture.atlas, &src, &instance->dst, angle, NULL, SDL_FLIP_NONE);
		}
		if (instance->font) {
			STBTTF_RenderText(e->renderer, instance->font, instance->dst.x, instance->dst.y+28, instance->text);
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
		SDL_MixAudioFormat(e->audio_buf.userdata, e->music->userdata, e->music->format, e->music->size, VOLUME);
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
		instance_cleanup(e->space, e->instances+i);
	}
	if (e->audio_buf.userdata) {
		free(e->audio_buf.userdata);
		e->audio_buf.userdata = NULL;
	}
	/*for (size_t i = 0; i < e->var_num; i++) {
		free(e->vars[i].name);
		free(e->vars[i].data);
	}*/
	if (e->vars) { free(e->vars); e->vars = NULL; }
	if (e->cursor) { SDL_FreeCursor(e->cursor); e->cursor = NULL; }
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
