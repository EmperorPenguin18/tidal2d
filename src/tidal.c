//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"
#include <physfs.h>
#include <SDL2/SDL_image.h>

static int lib_load();
static char* read_data(const char*, size_t*);
static int read_files(Engine*, const char*);
static const char* getextension(const char*);
static void prepend(char*, const char*);

static int create_object(Engine*, char*, size_t);
static int create_texture(Engine*, SDL_RWops*, const char*);
static int create_font(Engine*, char*, size_t, int, const char*);
static int create_audio(Engine*, char*, size_t, const char*);

static void events(Engine*);
static void update(Engine*);
static void draw(Engine*);

void* sdl_lib = NULL;
typedef void* (*pf_s_loadobject)(const char*);
pf_s_loadobject S_LoadObject = NULL;
typedef void* (*pf_s_loadfunction)(void*, const char*);
pf_s_loadfunction S_LoadFunction = NULL;
typedef void (*pf_s_log)(const char*, ...);
pf_s_log S_Log = NULL;
typedef void (*pf_s_destroytexture)(SDL_Texture*);
pf_s_destroytexture S_DestroyTexture = NULL;
typedef int (*pf_s_setrenderdrawblendmode)(SDL_Renderer*, SDL_BlendMode);
pf_s_setrenderdrawblendmode S_SetRenderDrawBlendMode = NULL;
typedef int (*pf_s_setrenderdrawcolor)(SDL_Renderer*, Uint8, Uint8, Uint8, Uint8);
pf_s_setrenderdrawcolor S_SetRenderDrawColor = NULL;
typedef int (*pf_s_renderclear)(SDL_Renderer*);
pf_s_renderclear S_RenderClear = NULL;
typedef int (*pf_s_rendercopy)(SDL_Renderer*, SDL_Texture*, const SDL_Rect*, const SDL_Rect*);
pf_s_rendercopy S_RenderCopy = NULL;
typedef void (*pf_s_renderpresent)(SDL_Renderer*);
pf_s_renderpresent S_RenderPresent = NULL;
typedef Uint64 (*pf_s_getperformancefrequency)();
pf_s_getperformancefrequency S_GetPerformanceFrequency = NULL;
typedef Uint64 (*pf_s_getperformancecounter)();
pf_s_getperformancecounter S_GetPerformanceCounter = NULL;
typedef SDL_Texture* (*pf_s_createtexturefromsurface)(SDL_Renderer*, SDL_Surface*);
pf_s_createtexturefromsurface S_CreateTextureFromSurface = NULL;
typedef void (*pf_s_freesurface)(SDL_Surface*);
pf_s_freesurface S_FreeSurface = NULL;
typedef void (*pf_s_quit)();
pf_s_quit S_Quit = NULL;
typedef SDL_Window* (*pf_s_createwindow)(const char*, int, int, int, int, Uint32);
pf_s_createwindow S_CreateWindow = NULL;
typedef SDL_RWops* (*pf_s_rwfrommem)(void*, int);
pf_s_rwfrommem S_RWFromMem = NULL;
typedef int (*pf_s_rwclose)(SDL_RWops*);
pf_s_rwclose S_RWclose = NULL;
typedef SDL_Renderer* (*pf_s_createrenderer)(SDL_Window*, int, Uint32);
pf_s_createrenderer S_CreateRenderer = NULL;
typedef void (*pf_s_destroyrenderer)(SDL_Renderer*);
pf_s_destroyrenderer S_DestroyRenderer = NULL;
typedef void (*pf_s_destroywindow)(SDL_Window*);
pf_s_destroywindow S_DestroyWindow = NULL;
typedef int (*pf_s_pollevent)(SDL_Event*);
pf_s_pollevent S_PollEvent = NULL;
typedef const char* (*pf_s_geterror)();
pf_s_geterror S_GetError = NULL;
typedef int (*pf_s_init)(Uint32);
pf_s_init S_Init = NULL;
typedef void (*pf_s_unloadobject)(void*);
pf_s_unloadobject S_UnloadObject = NULL;
void* physfs_lib = NULL;
typedef const char* (*pf_p_geterrorbycode)(PHYSFS_ErrorCode);
pf_p_geterrorbycode P_getErrorByCode = NULL;
typedef PHYSFS_ErrorCode (*pf_p_getlasterrorcode)();
pf_p_getlasterrorcode P_getLastErrorCode = NULL;
typedef PHYSFS_File* (*pf_p_openread)(const char*);
pf_p_openread P_openRead = NULL;
typedef PHYSFS_sint64 (*pf_p_filelength)(PHYSFS_File*);
pf_p_filelength P_fileLength = NULL;
typedef PHYSFS_sint64 (*pf_p_readbytes)(PHYSFS_File*, void*, PHYSFS_uint64);
pf_p_readbytes P_readBytes = NULL;
typedef int (*pf_p_close)(PHYSFS_File*);
pf_p_close P_close = NULL;
typedef int (*pf_p_stat)(const char*, PHYSFS_Stat*);
pf_p_stat P_stat = NULL;
typedef char** (*pf_p_enumeratefiles)(const char*);
pf_p_enumeratefiles P_enumerateFiles = NULL;
typedef const char* (*pf_p_getdirseparator)();
pf_p_getdirseparator P_getDirSeparator = NULL;
typedef void (*pf_p_freelist)(void*);
pf_p_freelist P_freeList = NULL;
typedef int (*pf_p_init)(const char*);
pf_p_init P_init = NULL;
typedef int (*pf_p_mount)(const char*, const char*, int);
pf_p_mount P_mount = NULL;
typedef int (*pf_p_deinit)();
pf_p_deinit P_deinit = NULL;
void* cjson_lib = NULL;
typedef cJSON* (*pf_j_getobjectitemcasesensitive)(const cJSON*, const char*);
pf_j_getobjectitemcasesensitive J_GetObjectItemCaseSensitive = NULL;
typedef cJSON* (*pf_j_parsewithlength)(const char*, size_t);
pf_j_parsewithlength J_ParseWithLength = NULL;
typedef void (*pf_j_delete)(cJSON*);
pf_j_delete J_Delete = NULL;
void* img_lib = NULL;
typedef SDL_Texture* (*pf_i_loadtexturerw)(SDL_Renderer*, SDL_RWops*, int);
pf_i_loadtexturerw I_LoadTexture_RW = NULL;
typedef int (*pf_i_init)(int);
pf_i_init I_Init = NULL;
typedef void (*pf_i_quit)();
pf_i_quit I_Quit = NULL;
void* ttf_lib = NULL;
typedef int (*pf_t_fontheight)(const TTF_Font*);
pf_t_fontheight T_FontHeight = NULL;
typedef SDL_Surface* (*pf_t_renderutf8solidwrapped)(TTF_Font*, const char*, SDL_Color, Uint32);
pf_t_renderutf8solidwrapped T_RenderUTF8_Solid_Wrapped = NULL;
typedef TTF_Font* (*pf_t_openfontrw)(SDL_RWops*, int, int);
pf_t_openfontrw T_OpenFontRW = NULL;
typedef int (*pf_t_init)();
pf_t_init T_Init = NULL;
typedef void (*pf_t_closefont)(TTF_Font*);
pf_t_closefont T_CloseFont = NULL;
typedef void (*pf_t_quit)();
pf_t_quit T_Quit = NULL;
void* mix_lib = NULL;
typedef int (*pf_m_playchannel)(int, Mix_Chunk*, int);
pf_m_playchannel M_PlayChannel = NULL;
typedef void (*pf_m_closeaudio)();
pf_m_closeaudio M_CloseAudio = NULL;
typedef int (*pf_m_openaudio)(int, Uint64, int, int);
pf_m_openaudio M_OpenAudio = NULL;
typedef Mix_Chunk* (*pf_m_loadwavrw)(SDL_RWops*, int);
pf_m_loadwavrw M_LoadWAV_RW = NULL;
typedef int (*pf_m_init)(int);
pf_m_init M_Init = NULL;
typedef void (*pf_m_freechunk)(Mix_Chunk*);
pf_m_freechunk M_FreeChunk = NULL;
typedef void (*pf_m_quit)();
pf_m_quit M_Quit = NULL;
void* cp_lib = NULL;
typedef cpFloat (*pf_c_momentforbox)(cpFloat, cpFloat, cpFloat);
pf_c_momentforbox C_MomentForBox = NULL;
typedef cpBody* (*pf_c_bodynew)(cpFloat, cpFloat);
pf_c_bodynew C_BodyNew = NULL;
typedef cpBody* (*pf_c_spaceaddbody)(cpSpace*, cpBody*);
pf_c_spaceaddbody C_SpaceAddBody = NULL;
typedef void (*pf_c_bodysetposition)(cpBody*, cpVect);
pf_c_bodysetposition C_BodySetPosition = NULL;
typedef cpShape* (*pf_c_boxshapenew)(cpBody*, cpFloat, cpFloat, cpFloat);
pf_c_boxshapenew C_BoxShapeNew = NULL;
typedef cpShape* (*pf_c_spaceaddshape)(cpSpace*, cpShape*);
pf_c_spaceaddshape C_SpaceAddShape = NULL;
typedef void (*pf_c_shapesetfriction)(cpShape*, cpFloat);
pf_c_shapesetfriction C_ShapeSetFriction = NULL;
typedef cpVect (*pf_c_bodygetposition)(const cpBody*);
pf_c_bodygetposition C_BodyGetPosition = NULL;
typedef cpVect (*pf_c_bodygetvelocity)(const cpBody*);
pf_c_bodygetvelocity C_BodyGetVelocity = NULL;
typedef void (*pf_c_spacestep)(cpSpace*, cpFloat);
pf_c_spacestep C_SpaceStep = NULL;
typedef cpSpace* (*pf_c_spacenew)();
pf_c_spacenew C_SpaceNew = NULL;
typedef void (*pf_c_spacesetgravity)(cpSpace*, cpVect);
pf_c_spacesetgravity C_SpaceSetGravity = NULL;
typedef void (*pf_c_shapefree)(cpShape*);
pf_c_shapefree C_ShapeFree = NULL;
typedef void (*pf_c_bodyfree)(cpBody*);
pf_c_bodyfree C_BodyFree = NULL;
typedef void (*pf_c_spacefree)(cpSpace*);
pf_c_spacefree C_SpaceFree = NULL;

static int lib_load() {
#ifdef STATIC
	S_LoadObject = &SDL_LoadObject;
	S_LoadFunction = &SDL_LoadFunction;
	S_Log = &SDL_Log;
	S_DestroyTexture = &SDL_DestroyTexture;
	S_SetRenderDrawBlendMode = &SDL_SetRenderDrawBlendMode;
	S_SetRenderDrawColor = &SDL_SetRenderDrawColor;
	S_RenderClear = &SDL_RenderClear;
	S_RenderCopy = &SDL_RenderCopy;
	S_RenderPresent = &SDL_RenderPresent;
	S_GetPerformanceFrequency = &SDL_GetPerformanceFrequency;
	S_GetPerformanceCounter = &SDL_GetPerformanceCounter;
	S_CreateTextureFromSurface = &SDL_CreateTextureFromSurface;
	S_FreeSurface = &SDL_FreeSurface;
	S_Quit = &SDL_Quit;
	S_CreateWindow = &SDL_CreateWindow;
	S_RWFromMem = &SDL_RWFromMem;
	S_RWclose = &SDL_RWclose;
	S_CreateRenderer = &SDL_CreateRenderer;
	S_DestroyRenderer = &SDL_DestroyRenderer;
	S_DestroyWindow = &SDL_DestroyWindow;
	S_PollEvent = &SDL_PollEvent;
	S_GetError = &SDL_GetError;
	S_Init = &SDL_Init;
	S_UnloadObject = &SDL_UnloadObject;
	P_getErrorByCode = &PHYSFS_getErrorByCode;
	P_getLastErrorCode = &PHYSFS_getLastErrorCode;
	P_openRead = &PHYSFS_openRead;
	P_fileLength = &PHYSFS_fileLength;
	P_readBytes = &PHYSFS_readBytes;
	P_close = &PHYSFS_close;
	P_stat = &PHYSFS_stat;
	P_enumerateFiles = &PHYSFS_enumerateFiles;
	P_getDirSeparator = &PHYSFS_getDirSeparator;
	P_freeList = &PHYSFS_freeList;
	P_init = &PHYSFS_init;
	P_mount = &PHYSFS_mount;
	P_deinit = &PHYSFS_deinit;
	J_GetObjectItemCaseSensitive = &cJSON_GetObjectItemCaseSensitive;
	J_ParseWithLength = &cJSON_ParseWithLength;
	J_Delete = &cJSON_Delete;
	I_LoadTexture_RW = &IMG_LoadTexture_RW;
	I_Init = &IMG_Init;
	I_Quit = &IMG_Quit;
	T_FontHeight = &TTF_FontHeight;
	T_RenderUTF8_Solid_Wrapped = &TTF_RenderUTF8_Solid_Wrapped;
	T_OpenFontRW = &TTF_OpenFontRW;
	T_Init = &TTF_Init;
	T_CloseFont = &TTF_CloseFont;
	T_Quit = &TTF_Quit;
	M_PlayChannel = &Mix_PlayChannel;
	M_CloseAudio = &Mix_CloseAudio;
	M_OpenAudio = &Mix_OpenAudio;
	M_LoadWAV_RW = &Mix_LoadWAV_RW;
	M_Init = &Mix_Init;
	M_FreeChunk = &Mix_FreeChunk;
	M_Quit = &Mix_Quit;
	C_MomentForBox = &cpMomentForBox;
	C_BodyNew = &cpBodyNew;
	C_SpaceAddBody = &cpSpaceAddBody;
	C_BodySetPosition = &cpBodySetPosition;
	C_BoxShapeNew = &cpBoxShapeNew;
	C_SpaceAddShape = &cpSpaceAddShape;
	C_ShapeSetFriction = &cpShapeSetFriction;
	C_BodyGetPosition = &cpBodyGetPosition;
	C_BodyGetVelocity = &cpBodyGetVelocity;
	C_SpaceStep = &cpSpaceStep;
	C_SpaceNew = &cpSpaceNew;
	C_SpaceSetGravity = &cpSpaceSetGravity;
	C_ShapeFree = &cpShapeFree;
	C_BodyFree = &cpBodyFree;
	C_SpaceFree = &cpSpaceFree;
#else
#ifdef _WIN32
	//Add Windows dependent code
#else
	sdl_lib = dlopen("libSDL2.so", RTLD_LAZY);
	if (!sdl_lib) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	S_LoadObject = dlsym(sdl_lib, "SDL_LoadObject");
	if (!S_LoadObject) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	S_LoadFunction = dlsym(sdl_lib, "SDL_LoadFunction");
	if (!S_LoadFunction) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	S_Log = dlsym(sdl_lib, "SDL_Log");
	if (!S_Log) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	S_GetError = dlsym(sdl_lib, "SDL_GetError");
	if (!S_GetError) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	physfs_lib = dlopen("libphysfs.so", RTLD_LAZY);
	if (!physfs_lib) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	P_getErrorByCode = dlsym(physfs_lib, "PHYSFS_getErrorByCode");
	if (!P_getErrorByCode) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	P_getLastErrorCode = dlsym(physfs_lib, "PHYSFS_getLastErrorCode");
	if (!P_getLastErrorCode) {
		fprintf(stderr, "INFO: %s\n", dlerror());
		exit(EXIT_FAILURE);
	}
	cjson_lib = S_LoadObject("libcjson.so");
	if (!cjson_lib) return -1;
	img_lib = S_LoadObject("libSDL2_image.so");
	if (!img_lib) return -1;
	ttf_lib = S_LoadObject("libSDL2_ttf.so");
	if (!ttf_lib) return -1;
	mix_lib = S_LoadObject("libSDL2_mixer.so");
	if (!mix_lib) return -1;
	cp_lib = S_LoadObject("libchipmunk.so");
	if (!cp_lib) return -1;
#endif
	S_DestroyTexture = S_LoadFunction(sdl_lib, "SDL_DestroyTexture");
	if (!S_DestroyTexture) return -1;
	S_SetRenderDrawBlendMode = S_LoadFunction(sdl_lib, "SDL_SetRenderDrawBlendMode");
	if (!S_SetRenderDrawBlendMode) return -1;
	S_SetRenderDrawColor = S_LoadFunction(sdl_lib, "SDL_SetRenderDrawColor");
	if (!S_SetRenderDrawColor) return -1;
	S_RenderClear = S_LoadFunction(sdl_lib, "SDL_RenderClear");
	if (!S_RenderClear) return -1;
	S_RenderCopy = S_LoadFunction(sdl_lib, "SDL_RenderCopy");
	if (!S_RenderCopy) return -1;
	S_RenderPresent = S_LoadFunction(sdl_lib, "SDL_RenderPresent");
	if (!S_RenderPresent) return -1;
	S_GetPerformanceFrequency = S_LoadFunction(sdl_lib, "SDL_GetPerformanceFrequency");
	if (!S_GetPerformanceFrequency) return -1;
	S_GetPerformanceCounter = S_LoadFunction(sdl_lib, "SDL_GetPerformanceCounter");
	if (!S_GetPerformanceCounter) return -1;
	S_CreateTextureFromSurface = S_LoadFunction(sdl_lib, "SDL_CreateTextureFromSurface");
	if (!S_CreateTextureFromSurface) return -1;
	S_FreeSurface = S_LoadFunction(sdl_lib, "SDL_FreeSurface");
	if (!S_FreeSurface) return -1;
	S_Quit = S_LoadFunction(sdl_lib, "SDL_Quit");
	if (!S_Quit) return -1;
	S_CreateWindow = S_LoadFunction(sdl_lib, "SDL_CreateWindow");
	if (!S_CreateWindow) return -1;
	S_RWFromMem = S_LoadFunction(sdl_lib, "SDL_RWFromMem");
	if (!S_RWFromMem) return -1;
	S_RWclose = S_LoadFunction(sdl_lib, "SDL_RWclose");
	if (!S_RWclose) return -1;
	S_CreateRenderer = S_LoadFunction(sdl_lib, "SDL_CreateRenderer");
	if (!S_CreateRenderer) return -1;
	S_DestroyRenderer = S_LoadFunction(sdl_lib, "SDL_DestroyRenderer");
	if (!S_DestroyRenderer) return -1;
	S_DestroyWindow = S_LoadFunction(sdl_lib, "SDL_DestroyWindow");
	if (!S_DestroyWindow) return -1;
	S_PollEvent = S_LoadFunction(sdl_lib, "SDL_PollEvent");
	if (!S_PollEvent) return -1;
	S_Init = S_LoadFunction(sdl_lib, "SDL_Init");
	if (!S_Init) return -1;
	S_UnloadObject = S_LoadFunction(sdl_lib, "SDL_UnloadObject");
	if (!S_UnloadObject) return -1;
	P_openRead = S_LoadFunction(physfs_lib, "PHYSFS_openRead");
	if (!P_openRead) return -1;
	P_fileLength = S_LoadFunction(physfs_lib, "PHYSFS_fileLength");
	if (!P_fileLength) return -1;
	P_readBytes = S_LoadFunction(physfs_lib, "PHYSFS_readBytes");
	if (!P_readBytes) return -1;
	P_close = S_LoadFunction(physfs_lib, "PHYSFS_close");
	if (!P_close) return -1;
	P_stat = S_LoadFunction(physfs_lib, "PHYSFS_stat");
	if (!P_stat) return -1;
	P_enumerateFiles = S_LoadFunction(physfs_lib, "PHYSFS_enumerateFiles");
	if (!P_enumerateFiles) return -1;
	P_getDirSeparator = S_LoadFunction(physfs_lib, "PHYSFS_getDirSeparator");
	if (!P_getDirSeparator) return -1;
	P_freeList = S_LoadFunction(physfs_lib, "PHYSFS_freeList");
	if (!P_freeList) return -1;
	P_init = S_LoadFunction(physfs_lib, "PHYSFS_init");
	if (!P_init) return -1;
	P_mount = S_LoadFunction(physfs_lib, "PHYSFS_mount");
	if (!P_mount) return -1;
	P_deinit = S_LoadFunction(physfs_lib, "PHYSFS_deinit");
	if (!P_deinit) return -1;
	J_GetObjectItemCaseSensitive = S_LoadFunction(cjson_lib, "cJSON_GetObjectItemCaseSensitive");
	if (!J_GetObjectItemCaseSensitive) return -1;
	J_ParseWithLength = S_LoadFunction(cjson_lib, "cJSON_ParseWithLength");
	if (!J_ParseWithLength) return -1;
	J_Delete = S_LoadFunction(cjson_lib, "cJSON_Delete");
	if (!J_Delete) return -1;
	I_LoadTexture_RW = S_LoadFunction(img_lib, "IMG_LoadTexture_RW");
	if (!I_LoadTexture_RW) return -1;
	I_Init = S_LoadFunction(img_lib, "IMG_Init");
	if (!I_Init) return -1;
	I_Quit = S_LoadFunction(img_lib, "IMG_Quit");
	if (!I_Quit) return -1;
	T_FontHeight = S_LoadFunction(ttf_lib, "TTF_FontHeight");
	if (!T_FontHeight) return -1;
	T_RenderUTF8_Solid_Wrapped = S_LoadFunction(ttf_lib, "TTF_RenderUTF8_Solid_Wrapped");
	if (!T_RenderUTF8_Solid_Wrapped) return -1;
	T_OpenFontRW = S_LoadFunction(ttf_lib, "TTF_OpenFontRW");
	if (!T_OpenFontRW) return -1;
	T_Init = S_LoadFunction(ttf_lib, "TTF_Init");
	if (!T_Init) return -1;
	T_CloseFont = S_LoadFunction(ttf_lib, "TTF_CloseFont");
	if (!T_CloseFont) return -1;
	T_Quit = S_LoadFunction(ttf_lib, "TTF_Quit");
	if (!T_Quit) return -1;
	M_PlayChannel = S_LoadFunction(mix_lib, "Mix_PlayChannel");
	if (!M_PlayChannel) return -1;
	M_CloseAudio = S_LoadFunction(mix_lib, "Mix_CloseAudio");
	if (!M_CloseAudio) return -1;
	M_OpenAudio = S_LoadFunction(mix_lib, "Mix_OpenAudio");
	if (!M_OpenAudio) return -1;
	M_LoadWAV_RW = S_LoadFunction(mix_lib, "Mix_LoadWAV_RW");
	if (!M_LoadWAV_RW) return -1;
	M_Init = S_LoadFunction(mix_lib, "Mix_Init");
	if (!M_Init) return -1;
	M_FreeChunk = S_LoadFunction(mix_lib, "Mix_FreeChunk");
	if (!M_FreeChunk) return -1;
	M_Quit = S_LoadFunction(mix_lib, "Mix_Quit");
	if (!M_Quit) return -1;
	C_MomentForBox = S_LoadFunction(cp_lib, "cpMomentForBox");
	if (!C_MomentForBox) return -1;
	C_BodyNew = S_LoadFunction(cp_lib, "cpBodyNew");
	if (!C_BodyNew) return -1;
	C_SpaceAddBody = S_LoadFunction(cp_lib, "cpSpaceAddBody");
	if (!C_SpaceAddBody) return -1;
	C_BodySetPosition = S_LoadFunction(cp_lib, "cpBodySetPosition");
	if (!C_BodySetPosition) return -1;
	C_BoxShapeNew = S_LoadFunction(cp_lib, "cpBoxShapeNew");
	if (!C_BoxShapeNew) return -1;
	C_SpaceAddShape = S_LoadFunction(cp_lib, "cpSpaceAddShape");
	if (!C_SpaceAddShape) return -1;
	C_ShapeSetFriction = S_LoadFunction(cp_lib, "cpShapeSetFriction");
	if (!C_ShapeSetFriction) return -1;
	C_BodyGetPosition = S_LoadFunction(cp_lib, "cpBodyGetPosition");
	if (!C_BodyGetPosition) return -1;
	C_BodyGetVelocity = S_LoadFunction(cp_lib, "cpBodyGetVelocity");
	if (!C_BodyGetVelocity) return -1;
	C_SpaceStep = S_LoadFunction(cp_lib, "cpSpaceStep");
	if (!C_SpaceStep) return -1;
	C_SpaceNew = S_LoadFunction(cp_lib, "cpSpaceNew");
	if (!C_SpaceNew) return -1;
	C_SpaceSetGravity = S_LoadFunction(cp_lib, "cpSpaceSetGravity");
	if (!C_SpaceSetGravity) return -1;
	C_ShapeFree = S_LoadFunction(cp_lib, "cpShapeFree");
	if (!C_ShapeFree) return -1;
	C_BodyFree = S_LoadFunction(cp_lib, "cpBodyFree");
	if (!C_BodyFree) return -1;
	C_SpaceFree = S_LoadFunction(cp_lib, "cpSpaceFree");
	if (!C_SpaceFree) return -1;
#endif
	return 0;
}

Engine* Tidal_init(int argc, char *argv[]) {
	Engine* engine = (Engine*)malloc(sizeof(Engine));
	if (engine == NULL) return NULL;
	engine->height = 480;
	engine->running = true;
	engine->textures = NULL;
	engine->textures_num = 0;
	engine->objects = NULL;
	engine->objects_num = 0;
	engine->fonts = NULL;
	engine->fonts_num = 0;
	engine->space = NULL;
	engine->audio = NULL;
	engine->audio_num = 0;
	if (lib_load() < 0) return NULL;
	if (S_Init(SDL_INIT_EVERYTHING) < 0) return NULL;
#ifdef DEBUG
	S_Log("SDL initialized");
#endif
	if (T_Init() < 0) return NULL;
#ifdef DEBUG
	S_Log("SDL_ttf initialized");
#endif
	if (M_Init(0) < 0) return NULL;
#ifdef DEBUG
	S_Log("SDL_mixer initialized");
#endif
	if (I_Init(IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_WEBP) != (IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_WEBP)) return NULL;
#ifdef DEBUG
	S_Log("SDL_image initialized");
#endif
	engine->window = S_CreateWindow("TidalEngine", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, engine->width, engine->height, 0); //change title
	if (!engine->window) return NULL;
#ifdef DEBUG
	S_Log("Window created");
#endif
	engine->renderer = S_CreateRenderer(engine->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!engine->renderer) return NULL;
#ifdef DEBUG
	S_Log("Renderer created");
#endif
	if (P_init(argv[0]) == 0) return NULL;
#ifdef DEBUG
	S_Log("PHYSFS initialized");
#endif
	engine->space = C_SpaceNew();
	C_SpaceSetGravity(engine->space, cpv(0, -100));
	if (argc > 2) {
		S_Log("Too many arguments, only one expected");
		return NULL;
	} else {
		if (P_mount(argv[1], NULL, 0) == 0) return NULL;
#ifdef DEBUG
		S_Log("Path mounted");
#endif
		if (read_files(engine, "") != 0) return NULL;
	}
#ifdef DEBUG
	S_Log("Files read");
#endif
	return engine;
}

static int read_files(Engine* engine, const char *path) {
	PHYSFS_Stat stat;
	if (P_stat(path, &stat) == 0) return -1;
#ifdef DEBUG
	S_Log("Path stats acquired");
#endif
	if (stat.filetype == PHYSFS_FILETYPE_DIRECTORY) {
		if (path[0] == '.' || path[1] == '.') return 0;
		char **rc = P_enumerateFiles(path);
#ifdef DEBUG
		for (char** i = rc; *i != NULL; i++) printf(" * We've got [%s].\n", *i);
		S_Log("Dir listed");
#endif
		for (char** i = rc; *i != NULL; i++) {
			*i = (char*)realloc(*i, sizeof(path)+sizeof(*i)+2);
			prepend(*i, P_getDirSeparator());
			prepend(*i, path);
			if (read_files(engine, *i) < 0) return -1;
		}
#ifdef DEBUG
		S_Log("Files loaded");
#endif
		P_freeList(rc);
#ifdef DEBUG
		S_Log("List freed");
#endif
	} else if (stat.filetype == PHYSFS_FILETYPE_REGULAR) {
#ifdef DEBUG
		S_Log("Is a regular file");
#endif
		const char* ext = getextension(path);
		size_t len = 0;
		char* data = read_data(path, &len);
		if (data == NULL) return -1;
		if (strcmp(ext, "bmp") == 0) {
			SDL_RWops* rw = S_RWFromMem(data, len);
			if (create_texture(engine, rw, path) < 0) return -1;
			free(data);
		} else if (strcmp(ext, "json") == 0) {
#ifdef DEBUG
			S_Log("Contents of json file:\n%s", data);
#endif
			if (create_object(engine, data, len) < 0) return -1;
			free(data);
		} else if (strcmp(ext, "ttf") == 0) {
			if (create_font(engine, data, len, 24, path) < 0) return -1; //make size dynamic
		} else if (strcmp(ext, "wav") == 0) {
			if (create_audio(engine, data, len, path) < 0) return -1;
		}
		//Add more filetypes later
	}
	return 0;
}

static char* read_data(const char* path, size_t* len) {
	PHYSFS_File* file = P_openRead(path);
	if (file == NULL) return NULL;
	*len = P_fileLength(file);
	if (*len == -1) return NULL;
	char* data = (char*)malloc(*len);
	P_readBytes(file, data, *len);
	if (P_close(file) == 0) return NULL;
	return data;
}

static const char* getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
#ifdef DEBUG
	S_Log("getextension() input: %s", filename);
	S_Log("getextension() output: %s", dot);
#endif
	if (!dot || dot == filename) return "";
	return dot + 1;
}

static void prepend(char* s, const char* t) {
	size_t len = strlen(t);
	memmove(s + len, s, strlen(s) + 1);
	memcpy(s, t, len);
}

static int create_object(Engine* engine, char* string, size_t len) {
	engine->objects_num++;
	engine->objects = (Object*)realloc(engine->objects, engine->objects_num*sizeof(Object));
	(engine->objects + engine->objects_num-1)->json = J_ParseWithLength(string, len);
	const cJSON* json = (engine->objects + engine->objects_num-1)->json;
	(engine->objects + engine->objects_num-1)->dst.x = 0;
	(engine->objects + engine->objects_num-1)->dst.y = 0;
	(engine->objects + engine->objects_num-1)->dst.w = J_GetObjectItemCaseSensitive(json, "width")->valueint;
	(engine->objects + engine->objects_num-1)->dst.h = J_GetObjectItemCaseSensitive(json, "height")->valueint;
	(engine->objects + engine->objects_num-1)->texture = NULL;
	for (int i = 0; i < engine->textures_num; i++) {
		if (strcmp((engine->textures+i)->name, J_GetObjectItemCaseSensitive(json, "sprite")->valuestring) == 0) {
			(engine->objects + engine->objects_num-1)->texture = (engine->textures+i)->data; //improve
		}
	}
#ifdef DEBUG
	if ((engine->objects + engine->objects_num-1)->texture != NULL) S_Log("Texture attached");
#endif
	(engine->objects + engine->objects_num-1)->text = NULL;
	for (int i = 0; i < engine->fonts_num; i++) { //improve
		if (strcmp((engine->fonts+i)->name, J_GetObjectItemCaseSensitive(json, "font")->valuestring) == 0) {
			TTF_Font* font = (engine->fonts+i)->data;
#ifdef DEBUG
			S_Log("Font height: %d", T_FontHeight(font));
#endif
			SDL_Color color = {255, 255, 255, 255}; //make dynamic
			const char* string = J_GetObjectItemCaseSensitive(json, "text")->valuestring;
#ifdef DEBUG
			S_Log("Text to output: %s", string);
#endif
			SDL_Surface* text = T_RenderUTF8_Solid_Wrapped(font, string, color, 0);
			if (text == NULL) return -1;
			(engine->objects + engine->objects_num-1)->text = S_CreateTextureFromSurface(engine->renderer, text);
			S_FreeSurface(text);
		}
	}
#ifdef DEBUG
	if ((engine->objects + engine->objects_num-1)->text != NULL) S_Log("Font attached");
#endif
	(engine->objects + engine->objects_num-1)->body = NULL;
	(engine->objects + engine->objects_num-1)->shape = NULL;
	if (strcmp(J_GetObjectItemCaseSensitive(json, "shape")->valuestring, "box") == 0) { //set mass and friction dynamically
		(engine->objects + engine->objects_num-1)->body = C_SpaceAddBody(engine->space, C_BodyNew(1, C_MomentForBox(1, (engine->objects + engine->objects_num-1)->dst.w, (engine->objects + engine->objects_num-1)->dst.h)));
		C_BodySetPosition((engine->objects + engine->objects_num-1)->body, cpv(0, 0));
		(engine->objects + engine->objects_num-1)->shape = C_SpaceAddShape(engine->space, C_BoxShapeNew((engine->objects + engine->objects_num-1)->body, (engine->objects + engine->objects_num-1)->dst.w, (engine->objects + engine->objects_num-1)->dst.h, 0));
		C_ShapeSetFriction((engine->objects + engine->objects_num-1)->shape, 0.7);
	} //add other shapes
#ifdef DEBUG
	S_Log("Physics applied to object");
#endif
	for (int i = 0; i < engine->audio_num; i++) { //temporary
		if (strcmp((engine->audio+i)->name, J_GetObjectItemCaseSensitive(json, "sound")->valuestring) == 0) {
			M_PlayChannel(-1, (engine->audio+i)->data, 0);
		}
	}
#ifdef DEBUG
	S_Log("Object successfully created");
#endif
	return 0;
}

static int create_texture(Engine* engine, SDL_RWops* rw, const char* path) {
	engine->textures_num++;
	engine->textures = (Texture*)realloc(engine->textures, engine->textures_num*sizeof(Texture));
	(engine->textures + engine->textures_num-1)->data = I_LoadTexture_RW(engine->renderer, rw, 1);
	(engine->textures + engine->textures_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((engine->textures + engine->textures_num-1)->name, path+1);
	if (!engine->textures->data) return -1;
#ifdef DEBUG
	S_Log("Texture successfully created");
#endif
	return 0;
}

static int create_font(Engine* engine, char* data, size_t len, int ptsize, const char* path) {
	engine->fonts_num++;
	engine->fonts = (Font*)realloc(engine->fonts, engine->fonts_num*sizeof(Font));
	(engine->fonts + engine->fonts_num-1)->raw = data;
	(engine->fonts + engine->fonts_num-1)->rw = S_RWFromMem((engine->fonts + engine->fonts_num-1)->raw, len);
	(engine->fonts + engine->fonts_num-1)->data = T_OpenFontRW((engine->fonts + engine->fonts_num-1)->rw, 0, ptsize);
	(engine->fonts + engine->fonts_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((engine->fonts + engine->fonts_num-1)->name, path+1);
	if (!engine->fonts->data) return -1;
#ifdef DEBUG
	S_Log("Font successfully created");
#endif
	return 0;
}

static int create_audio(Engine* engine, char* data, size_t len, const char* path) {
	engine->audio_num++;
	engine->audio = (Audio*)realloc(engine->audio, engine->audio_num*sizeof(Audio));
	M_CloseAudio();
	M_OpenAudio(48000, AUDIO_S16SYS, 1, 2048);
	(engine->audio + engine->audio_num-1)->data = M_LoadWAV_RW(S_RWFromMem(data, len), 1);
	(engine->audio + engine->audio_num-1)->name = (char*)malloc(strlen(path+1));
	strcpy((engine->audio + engine->audio_num-1)->name, path+1);
	if (!engine->audio->data) return -1;
#ifdef DEBUG
	S_Log("Audio successfully created");
#endif
	return 0;
}

void Tidal_run(Engine* engine) {
	while (engine->running) {
		Uint64 start = S_GetPerformanceCounter();
		events(engine);
		update(engine);
		draw(engine);
		Uint64 end = S_GetPerformanceCounter();
		float elapsed = (end - start) / (float)S_GetPerformanceFrequency();
		printf("Current FPS: %f\n", 1.0/elapsed);
	}
}

static void events(Engine* engine) {
	SDL_Event event;
	S_PollEvent(&event);
	if (event.type == SDL_QUIT) {
		engine->running = false;
	}
}

static void update(Engine* engine) {
	for (int i = 0; i < engine->objects_num; i++) {
		if (engine->objects[i].body != NULL) {
			cpVect pos = C_BodyGetPosition(engine->objects[i].body);
			//cpVect vel = C_BodyGetVelocity(engine->objects[i].body);
			engine->objects[i].dst.x = pos.x;
			engine->objects[i].dst.y = pos.y;
		}
	}
	C_SpaceStep(engine->space, 1.0/60.0);
}

static void draw(Engine* engine) {
	S_SetRenderDrawBlendMode(engine->renderer, SDL_BLENDMODE_NONE);
	S_SetRenderDrawColor(engine->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	S_RenderClear(engine->renderer);
	for (int i = 0; i < engine->objects_num; i++) {
		S_RenderCopy(engine->renderer, (engine->objects + i)->texture, NULL, &((engine->objects + i)->dst));
		S_RenderCopy(engine->renderer, (engine->objects + i)->text, NULL, &((engine->objects + i)->dst));
	}
	S_RenderPresent(engine->renderer);
}

void Tidal_cleanup(Engine* engine) {
	P_deinit();
	for (int i = 0; i < engine->textures_num; i++) {
		S_DestroyTexture(engine->textures[i].data);
		free(engine->textures[i].name);
	}
	free(engine->textures); engine->textures = NULL;
#ifdef DEBUG
	S_Log("Textures freed");
#endif
	for (int i = 0; i < engine->objects_num; i++) {
		J_Delete(engine->objects[i].json);
		S_DestroyTexture(engine->objects[i].text);
		C_ShapeFree(engine->objects[i].shape);
		C_BodyFree(engine->objects[i].body);
	}
	free(engine->objects); engine->objects = NULL;
#ifdef DEBUG
	S_Log("Objects freed");
#endif
	for (int i = 0; i < engine->fonts_num; i++) {
		T_CloseFont(engine->fonts[i].data);
		S_RWclose(engine->fonts[i].rw);
		free(engine->fonts[i].raw);
		free(engine->fonts[i].name);
	}
	free(engine->fonts); engine->fonts = NULL;
#ifdef DEBUG
	S_Log("Fonts freed");
#endif
	for (int i = 0; i < engine->audio_num; i++) {
		M_FreeChunk(engine->audio[i].data);
		free(engine->audio[i].name);
	}
	free(engine->audio); engine->audio = NULL;
#ifdef DEBUG
	S_Log("Audio freed");
#endif
	C_SpaceFree(engine->space); engine->space = NULL;
	S_DestroyRenderer(engine->renderer); engine->renderer = NULL;
	S_DestroyWindow(engine->window); engine->window = NULL;
#ifdef DEBUG
	S_Log("Window freed");
#endif
	I_Quit();
	M_CloseAudio();
	M_Quit();
	T_Quit();
#ifdef DEBUG
	S_Log("Libs quit");
#endif
#ifdef STATIC
	S_Quit();
#else
	S_UnloadObject(cjson_lib); cjson_lib = NULL;
	S_UnloadObject(img_lib); img_lib = NULL;
	S_UnloadObject(ttf_lib); ttf_lib = NULL;
	S_UnloadObject(mix_lib); mix_lib = NULL;
	S_UnloadObject(cp_lib); cp_lib = NULL;
	S_Quit();
#ifdef _WIN32
	//Add Windows dependent code
#else
	dlclose(sdl_lib); sdl_lib = NULL;
	dlclose(physfs_lib); physfs_lib = NULL;
#endif
#endif
	free(engine); //Local so can't set to NULL
	fprintf(stderr, "INFO: Cleanup complete\n");
}

void Tidal_error() {
	S_Log("SDL error: %s", S_GetError());
	S_Log("PHYSFS error: %s", P_getErrorByCode(P_getLastErrorCode()));
}
