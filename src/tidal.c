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

static int init_object(Engine*, char*, size_t, const char*);
static int init_texture(Engine*, char*, size_t, const char*);
static int init_font(Engine*, char*, size_t, const char*);
static int init_audio(Engine*, char*, size_t, const char*, int);

static void events(Engine*);
static void update(Engine*);
static void draw(Engine*);

static int init_ui(Engine*, int);
static int action_spawn(Engine*, const char*, int, int);

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
typedef void (*pf_s_logdebug)(int, const char*, ...);
pf_s_logdebug S_LogDebug = NULL;
typedef void (*pf_s_logsetpriority)(int, SDL_LogPriority);
pf_s_logsetpriority S_LogSetPriority = NULL;
typedef SDL_Texture* (*pf_s_createtexture)(SDL_Renderer*, Uint32, int, int, int);
pf_s_createtexture S_CreateTexture = NULL;
typedef int (*pf_s_setrendertarget)(SDL_Renderer*, SDL_Texture*);
pf_s_setrendertarget S_SetRenderTarget = NULL;
typedef int (*pf_s_renderdrawrect)(SDL_Renderer*, const SDL_Rect*);
pf_s_renderdrawrect S_RenderDrawRect = NULL;
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
typedef cJSON_bool (*pf_j_isnumber)(const cJSON*);
pf_j_isnumber J_IsNumber = NULL;
typedef cJSON_bool (*pf_j_isstring)(const cJSON*);
pf_j_isstring J_IsString = NULL;
typedef const char* (*pf_j_geterrorptr)();
pf_j_geterrorptr J_GetErrorPtr = NULL;
typedef cJSON_bool (*pf_j_istrue)(const cJSON*);
pf_j_istrue J_IsTrue = NULL;
void* img_lib = NULL;
typedef SDL_Texture* (*pf_i_loadtexturerw)(SDL_Renderer*, SDL_RWops*, int);
pf_i_loadtexturerw I_LoadTexture_RW = NULL;
typedef int (*pf_i_init)(int);
pf_i_init I_Init = NULL;
typedef void (*pf_i_quit)();
pf_i_quit I_Quit = NULL;
/*void* ttf_lib = NULL;
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
pf_m_quit M_Quit = NULL;*/
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
void* soloud_lib = NULL;
typedef Soloud* (*pf_o_soloudcreate)();
pf_o_soloudcreate O_SoloudCreate = NULL;
typedef Wav* (*pf_o_wavcreate)();
pf_o_wavcreate O_WavCreate = NULL;
typedef int (*pf_o_wavloadmemex)(Wav*, const unsigned char*, unsigned int, int, int);
pf_o_wavloadmemex O_WavLoadMemEx = NULL;
typedef int (*pf_o_init)(Soloud*);
pf_o_init O_init = NULL;
typedef unsigned int (*pf_o_playex)(Soloud*, AudioSource*, float, float, bool, unsigned int);
pf_o_playex O_playEx = NULL;
typedef void (*pf_o_deinit)(Soloud*);
pf_o_deinit O_deinit = NULL;
typedef void (*pf_o_wavdestroy)(Wav*);
pf_o_wavdestroy O_WavDestroy = NULL;
typedef void (*pf_o_solouddestroy)(Soloud*);
pf_o_solouddestroy O_SoloudDestroy = NULL;
typedef const char* (*pf_o_geterrorstring)(Soloud*, int);
pf_o_geterrorstring O_getErrorString = NULL;
typedef Sfxr* (*pf_o_sfxrcreate)();
pf_o_sfxrcreate O_SfxrCreate = NULL;
typedef int (*pf_o_sfxrloadparamsex)(Sfxr*, unsigned char*, unsigned int, int, int);
pf_o_sfxrloadparamsex O_SfxrLoadParamsEx = NULL;
typedef void (*pf_o_sfxrdestroy)(Sfxr*);
pf_o_sfxrdestroy O_SfxrDestroy = NULL;
void* fc_lib;
typedef FC_Font* (*pf_f_createfont)();
pf_f_createfont F_CreateFont = NULL;
typedef Uint8 (*pf_f_loadfontrw)(FC_Font*, SDL_Renderer*, SDL_RWops*, Uint8, Uint32, SDL_Color, int);
pf_f_loadfontrw F_LoadFontRW = NULL;
typedef FC_Rect (*pf_f_draw)(FC_Font*, FC_Target*, float, float, const char*, ...);
pf_f_draw F_Draw = NULL;
typedef void (*pf_f_freefont)(FC_Font*);
pf_f_freefont F_FreeFont = NULL;
typedef SDL_Color (*pf_f_makecolor)(Uint8, Uint8, Uint8, Uint8);
pf_f_makecolor F_MakeColor = NULL;

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
	S_LogDebug = &SDL_LogDebug;
	S_LogSetPriority = &SDL_LogSetPriority;
	S_CreateTexture = &SDL_CreateTexture;
	S_SetRenderTarget = &SDL_SetRenderTarget;
	S_RenderDrawRect = &SDL_RenderDrawRect;
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
	J_IsNumber = &cJSON_IsNumber;
	J_IsString = &cJSON_IsString;
	J_GetErrorPtr = &cJSON_GetErrorPtr;
	J_IsTrue = &cJSON_IsTrue;
	I_LoadTexture_RW = &IMG_LoadTexture_RW;
	I_Init = &IMG_Init;
	I_Quit = &IMG_Quit;
	/*T_FontHeight = &TTF_FontHeight;
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
	M_Quit = &Mix_Quit;*/
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
	O_SoloudCreate = &Soloud_create;
	O_WavCreate = &Wav_create;
	O_WavLoadMemEx = &Wav_loadMemEx;
	O_init = &Soloud_init;
	O_playEx = &Soloud_playEx;
	O_deinit = &Soloud_deinit;
	O_WavDestroy = &Wav_destroy;
	O_SoloudDestroy = &Soloud_destroy;
	O_getErrorString = &Soloud_getErrorString;
	O_SfxrCreate = &Sfxr_create;
	O_SfxrLoadParamsEx = &Sfxr_loadParamsMemEx;
	O_SfxrDestroy = &Sfxr_destroy;
	F_CreateFont = &FC_CreateFont;
	F_LoadFontRW = &FC_LoadFont_RW;
	F_Draw = &FC_Draw;
	F_FreeFont = &FC_FreeFont;
	F_MakeColor = &FC_MakeColor;
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
	/*ttf_lib = S_LoadObject("libSDL2_ttf.so");
	if (!ttf_lib) return -1;
	mix_lib = S_LoadObject("libSDL2_mixer.so");
	if (!mix_lib) return -1;*/
	cp_lib = S_LoadObject("libchipmunk.so");
	if (!cp_lib) return -1;
	soloud_lib = S_LoadObject("libsoloud.so");
	if (!soloud_lib) return -1;
	fc_lib = S_LoadObject("libSDL2_FontCache.so");
	if (!fc_lib) return -1;
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
	S_LogDebug = S_LoadFunction(sdl_lib, "SDL_LogDebug");
	if (!S_LogDebug) return -1;
	S_LogSetPriority = S_LoadFunction(sdl_lib, "SDL_LogSetPriority");
	if (!S_LogSetPriority) return -1;
	S_CreateTexture = S_LoadFunction(sdl_lib, "SDL_CreateTexture");
	if (!S_CreateTexture) return -1;
	S_SetRenderTarget = S_LoadFunction(sdl_lib, "SDL_SetRenderTarget");
	if (!S_SetRenderTarget) return -1;
	S_RenderDrawRect = S_LoadFunction(sdl_lib, "SDL_RenderDrawRect");
	if (!S_RenderDrawRect) return -1;
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
	J_IsNumber = S_LoadFunction(cjson_lib, "cJSON_IsNumber");
	if (!J_IsNumber) return -1;
	J_IsString = S_LoadFunction(cjson_lib, "cJSON_IsString");
	if (!J_IsString) return -1;
	J_GetErrorPtr = S_LoadFunction(cjson_lib, "cJSON_GetErrorPtr");
	if (!J_GetErrorPtr) return -1;
	J_IsTrue = S_LoadFunction(cjson_lib, "cJSON_IsTrue");
	if (!J_IsTrue) return -1;
	I_LoadTexture_RW = S_LoadFunction(img_lib, "IMG_LoadTexture_RW");
	if (!I_LoadTexture_RW) return -1;
	I_Init = S_LoadFunction(img_lib, "IMG_Init");
	if (!I_Init) return -1;
	I_Quit = S_LoadFunction(img_lib, "IMG_Quit");
	if (!I_Quit) return -1;
	/*T_FontHeight = S_LoadFunction(ttf_lib, "TTF_FontHeight");
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
	if (!M_Quit) return -1;*/
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
	O_SoloudCreate = S_LoadFunction(soloud_lib, "Soloud_create");
	if (!O_SoloudCreate) return -1;
	O_WavCreate = S_LoadFunction(soloud_lib, "Wav_create");
	if (!O_WavCreate) return -1;
	O_WavLoadMemEx = S_LoadFunction(soloud_lib, "Wav_loadMemEx");
	if (!O_WavLoadMemEx) return -1;
	O_init = S_LoadFunction(soloud_lib, "Soloud_init");
	if (!O_init) return -1;
	O_playEx = S_LoadFunction(soloud_lib, "Soloud_playEx");
	if (!O_playEx) return -1;
	O_deinit = S_LoadFunction(soloud_lib, "Soloud_deinit");
	if (!O_deinit) return -1;
	O_WavDestroy = S_LoadFunction(soloud_lib, "Wav_destroy");
	if (!O_WavDestroy) return -1;
	O_SoloudDestroy = S_LoadFunction(soloud_lib, "Soloud_destroy");
	if (!O_SoloudDestroy) return -1;
	O_getErrorString = S_LoadFunction(soloud_lib, "Soloud_getErrorString");
	if (!O_getErrorString) return -1;
	O_SfxrCreate = S_LoadFunction(soloud_lib, "Sfxr_create");
	if (!O_SfxrCreate) return -1;
	O_SfxrLoadParamsEx = S_LoadFunction(soloud_lib, "Sfxr_loadParamsMemEx");
	if (!O_SfxrLoadParamsEx) return -1;
	O_SfxrDestroy = S_LoadFunction(soloud_lib, "Sfxr_destroy");
	if (!O_SfxrDestroy) return -1;
	F_CreateFont = S_LoadFunction(fc_lib, "FC_CreateFont");
	if (!F_CreateFont) return -1;
	F_LoadFontRW = S_LoadFunction(fc_lib, "FC_LoadFont_RW");
	if (!F_LoadFontRW) return -1;
	F_Draw = S_LoadFunction(fc_lib, "FC_Draw");
	if (!F_Draw) return -1;
	F_FreeFont = S_LoadFunction(fc_lib, "FC_FreeFont");
	if (!F_FreeFont) return -1;
	F_MakeColor = S_LoadFunction(fc_lib, "FC_MakeColor");
	if (!F_MakeColor) return -1;
#endif
	return 0;
}

Engine* Tidal_init(int argc, char *argv[]) {
	Engine* engine = (Engine*)malloc(sizeof(Engine));
	if (engine == NULL) return NULL;
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
	engine->soloud = NULL;
	engine->instances = NULL;
	engine->instances_num = 0;
	engine->layers = NULL;
	engine->layers_num = 0;
	engine->first_object = NULL;
	engine->first_layer = SIZE_MAX;
	engine->ui = NULL;
	engine->ui_num = 0;
	engine->ui_texture = NULL;
	engine->ui_font = NULL;
	engine->ui_text = NULL;
	if (lib_load() < 0) return NULL;
	if (S_Init(SDL_INIT_EVERYTHING) < 0) return NULL;
#ifdef DEBUG
	S_LogSetPriority(SDL_LOG_CATEGORY_CUSTOM, SDL_LOG_PRIORITY_DEBUG);
#endif
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "SDL initialized");
	engine->soloud = O_SoloudCreate();
	if (O_init(engine->soloud) != 0) return NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "SoLoud initialized");
	if (I_Init(IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_WEBP) != (IMG_INIT_JPG | IMG_INIT_PNG | IMG_INIT_WEBP)) return NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "SDL_image initialized");
	engine->window = S_CreateWindow("Tidal Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, 0);
	if (!engine->window) return NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Window created");
	engine->renderer = S_CreateRenderer(engine->window, -1, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);
	if (!engine->renderer) return NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Renderer created");
	if (P_init(argv[0]) == 0) return NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "PHYSFS initialized");
	engine->space = C_SpaceNew();
	C_SpaceSetGravity(engine->space, cpv(0, 100));
	if (argc > 2) {
		S_Log("Too many arguments, only one expected");
		return NULL;
	} else {
		if (P_mount(argv[1], NULL, 0) == 0) return NULL;
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Path mounted");
		if (read_files(engine, "") != 0) return NULL;
	}
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Files read");
	if (engine->objects_num > 0) action_spawn(engine, engine->first_object->name, 0, 0);
	return engine;
}

static int read_files(Engine* engine, const char *path) {
	PHYSFS_Stat stat;
	if (P_stat(path, &stat) == 0) return -1;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Path stats acquired");
	if (stat.filetype == PHYSFS_FILETYPE_DIRECTORY) {
		if (path[0] == '.' || path[1] == '.') return 0;
		char **rc = P_enumerateFiles(path);
		for (char** i = rc; *i != NULL; i++) {
			*i = (char*)realloc(*i, sizeof(path)+sizeof(*i)+2);
			prepend(*i, P_getDirSeparator());
			prepend(*i, path);
			if (read_files(engine, *i) < 0) return -1;
		}
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Files loaded");
		P_freeList(rc);
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "List freed");
	} else if (stat.filetype == PHYSFS_FILETYPE_REGULAR) {
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Is a regular file");
		const char* ext = getextension(path);
		size_t len = 0;
		char* data = read_data(path, &len);
		if (data == NULL) return -1;
		if (strcmp(ext, "bmp") == 0 || strcmp(ext, "jpg") == 0 || strcmp(ext, "png") == 0 || strcmp(ext, "webp") == 0 || strcmp(ext, "svg") == 0) {
			if (init_texture(engine, data, len, path) < 0) return -1;
			free(data);
		} else if (strcmp(ext, "json") == 0) {
			S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Contents of json file:\n%s", data);
			if (init_object(engine, data, len, path) < 0) return -1;
			free(data);
		} else if (strcmp(ext, "ttf") == 0) {
			if (init_font(engine, data, len, path) < 0) return -1;
			free(data);
		} else if (strcmp(ext, "wav") == 0 || strcmp(ext, "flac") == 0 || strcmp(ext, "mp3") == 0 || strcmp(ext, "ogg") == 0) {
			if (init_audio(engine, data, len, path, 0) < 0) return -1;
		} else if (strcmp(ext, "sfx") == 0) {
			if (init_audio(engine, data, len, path, 1) < 0) return -1;
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
	if (!dot || dot == filename) return "";
	return dot + 1;
}

static void prepend(char* s, const char* t) {
	size_t len = strlen(t);
	memmove(s + len, s, strlen(s) + 1);
	memcpy(s, t, len);
}

static int init_object(Engine* engine, char* data, size_t len, const char* path) {
	engine->objects = (Object*)realloc(engine->objects, (engine->objects_num+1)*sizeof(Object));
	engine->objects[engine->objects_num].data = J_ParseWithLength(data, len);
	engine->objects[engine->objects_num].name = (char*)malloc(strlen(path+1));
	strcpy(engine->objects[engine->objects_num].name, path+1);
	if (!engine->objects[engine->objects_num].data) {
		S_Log("cJSON error: %s", J_GetErrorPtr());
		return -1;
	}
	const cJSON* layer = J_GetObjectItemCaseSensitive(engine->objects[engine->objects_num].data, "layer");
	if (J_IsNumber(layer)) {
		if (layer->valueint < engine->first_layer) {
			engine->first_object = engine->objects + engine->objects_num;
			engine->first_layer = layer->valueint;
		}
	}
	engine->objects_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Object successfully created");
	return 0;
}

static int init_texture(Engine* engine, char* data, size_t len, const char* path) {
	engine->textures = (Texture*)realloc(engine->textures, (engine->textures_num+1)*sizeof(Texture));
	engine->textures[engine->textures_num].data = I_LoadTexture_RW(engine->renderer, S_RWFromMem(data, len), 1);
	engine->textures[engine->textures_num].name = (char*)malloc(strlen(path+1));
	strcpy(engine->textures[engine->textures_num].name, path+1);
	if (!engine->textures[engine->textures_num].data) return -1;
	engine->textures_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Texture successfully created");
	return 0;
}

static int init_font(Engine* engine, char* data, size_t len, const char* path) {
	engine->fonts = (Font*)realloc(engine->fonts, (engine->fonts_num+1)*sizeof(Font));
	engine->fonts[engine->fonts_num].normal = F_CreateFont();
	engine->fonts[engine->fonts_num].bold = F_CreateFont();
	F_LoadFontRW(engine->fonts[engine->fonts_num].normal, engine->renderer, S_RWFromMem(data, len), 1, 28, F_MakeColor(0, 0, 0, 255), TTF_STYLE_NORMAL);
	F_LoadFontRW(engine->fonts[engine->fonts_num].bold, engine->renderer, S_RWFromMem(data, len), 1, 28, F_MakeColor(0, 0, 0, 255), TTF_STYLE_BOLD);
	engine->fonts[engine->fonts_num].name = (char*)malloc(strlen(path+1));
	strcpy(engine->fonts[engine->fonts_num].name, path+1);
	if (!engine->fonts[engine->fonts_num].normal) return -1;
	engine->fonts_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Font successfully created");
	return 0;
}

static int init_audio(Engine* engine, char* data, size_t len, const char* path, int type) {
	engine->audio = (Audio*)realloc(engine->audio, (engine->audio_num+1)*sizeof(Audio));
	int err = 0;
	if (type == 0) {
		engine->audio[engine->audio_num].data = O_WavCreate();
		err = O_WavLoadMemEx(engine->audio[engine->audio_num].data, (unsigned char*)data, len, 0, 1);
	} else if (type == 1) {
		engine->audio[engine->audio_num].data = O_SfxrCreate();
		err = O_SfxrLoadParamsEx(engine->audio[engine->audio_num].data, (unsigned char*)data, len, 0, 1);
	}
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Soloud load error: %s", O_getErrorString(engine->soloud, err));
	engine->audio[engine->audio_num].name = (char*)malloc(strlen(path+1));
	strcpy(engine->audio[engine->audio_num].name, path+1);
	if (!engine->audio[engine->audio_num].data) return -1;
	engine->audio_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio successfully created");
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
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Current FPS: %f\n", 1.0/elapsed);
	}
}

static void events(Engine* engine) {
	SDL_Event event;
	S_PollEvent(&event);
	if (event.type == SDL_QUIT) {
		engine->running = false;
	}
}

static int init_ui(Engine* engine, int n) {
	engine->ui = (Instance**)realloc(engine->ui, (engine->ui_num+1)*sizeof(Instance*));
	engine->ui[engine->ui_num] = engine->instances + n;
	if (engine->ui_num == 0) {
		engine->ui_dst = engine->instances[n].dst;
		if (engine->instances[n].texture != NULL) {
			S_DestroyTexture(engine->ui_texture);
			engine->ui_texture = S_CreateTexture(engine->renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, engine->ui_dst.w + 10, engine->ui_dst.h + 10);
			S_SetRenderTarget(engine->renderer, engine->ui_texture);
			S_SetRenderDrawColor(engine->renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE);
			S_RenderDrawRect(engine->renderer, NULL);
			//S_SetRenderDrawColor(engine->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
			S_SetRenderTarget(engine->renderer, NULL);
		}
		if (engine->instances[n].font != NULL && engine->instances[n].text != NULL) {
			engine->ui_font = engine->instances[n].font->bold;
			engine->ui_text = engine->instances[n].text;
		}
	}
	engine->ui_num++;
	return 0;
}

static int action_spawn(Engine* engine, const char* name, int x, int y) {
	cJSON* json = NULL;
	for (int i = 0; i < engine->objects_num; i++) {
		if (strcmp(name, engine->objects[i].name) == 0) {
			json = engine->objects[i].data;
		}
	}

	engine->instances = (Instance*)realloc(engine->instances, (engine->instances_num+1)*sizeof(Instance));
	const cJSON* layer = J_GetObjectItemCaseSensitive(json, "layer");
	int num = 0, n, sum = 0;
	if (J_IsNumber(layer)) {
		num = layer->valueint;
	}
	if ((num+1) > engine->layers_num) {
		engine->layers = (size_t*)realloc(engine->layers, (num+1)*sizeof(size_t));
		for (int i = engine->layers_num; i < num+1; i++) engine->layers[i] = 0;
		engine->layers_num = num+1;
	}
	for (n = 0; n < num; n++) sum += engine->layers[n];
	engine->layers[num]++;
	engine->instances_num++;
	for (int i = engine->instances_num - 1; i >= sum; i--) engine->instances[i] = engine->instances[i - 1];
	//engine->instances[sum].id = something;
	
	engine->instances[sum].dst.x = x;
	engine->instances[sum].dst.y = y;
	const cJSON* width = J_GetObjectItemCaseSensitive(json, "width");
	if (J_IsNumber(width)) {
		engine->instances[sum].dst.w = width->valueint;
	} else engine->instances[sum].dst.w = 0;
	const cJSON* height = J_GetObjectItemCaseSensitive(json, "height");
	if (J_IsNumber(height)) {
		engine->instances[sum].dst.h = height->valueint;
	} else engine->instances[sum].dst.h = 0;
	
	engine->instances[sum].texture = NULL;
	const cJSON* sprite = J_GetObjectItemCaseSensitive(json, "sprite");
	if (J_IsString(sprite) && (sprite->valuestring != NULL)) {
		for (int i = 0; i < engine->textures_num; i++) {
			if (strcmp(engine->textures[i].name, sprite->valuestring) == 0) {
				engine->instances[sum].texture = engine->textures[i].data;
			}
		}
	}

	engine->instances[sum].font = NULL;
	const cJSON* font = J_GetObjectItemCaseSensitive(json, "font");
	if (J_IsString(font) && (font->valuestring != NULL)) {
		for (int i = 0; i < engine->fonts_num; i++) {
			if (strcmp(engine->fonts[i].name, font->valuestring) == 0) {
				engine->instances[sum].font = engine->fonts + i;
			}
		}
	}

	engine->instances[sum].text = NULL;
	const cJSON* text = J_GetObjectItemCaseSensitive(json, "text");
	if (J_IsString(text) && (text->valuestring != NULL)) {
		engine->instances[sum].text = text->valuestring;
	}

	engine->instances[sum].body = NULL;
	engine->instances[sum].shape = NULL;
	const cJSON* shape = J_GetObjectItemCaseSensitive(json, "shape");
	if (J_IsString(shape) && (shape->valuestring != NULL)) {
		if (strcmp(shape->valuestring, "box") == 0) { //set mass and friction dynamically
			engine->instances[sum].body = C_SpaceAddBody(engine->space,
				C_BodyNew(1, C_MomentForBox(1, engine->instances[sum].dst.w,
						engine->instances[sum].dst.h)));
			C_BodySetPosition(engine->instances[sum].body, cpv(engine->instances[sum].dst.x,
						engine->instances[sum].dst.y));
			engine->instances[sum].shape = C_SpaceAddShape(engine->space, C_BoxShapeNew(engine->instances[sum].body,
						engine->instances[sum].dst.w, engine->instances[sum].dst.h, 0));
			C_ShapeSetFriction(engine->instances[sum].shape, 0.7);
		} //add other shapes
	}

	const cJSON* ui = J_GetObjectItemCaseSensitive(json, "ui");
	if (J_IsTrue(ui)) {
		init_ui(engine, sum);
	}

	return 0;
}

/*static int action_sound(const char* name) {
	for (int i = 0; i < engine->audio_num; i++) { //temporary
		if (strcmp((engine->audio+i)->name, J_GetObjectItemCaseSensitive(json, "sound")->valuestring) == 0) {
			O_playEx(engine->soloud, (engine->audio+i)->data, 1.0, 0.0, 0, 0);
		}
	}
}*/

static void update(Engine* engine) {
	for (int i = 0; i < engine->instances_num; i++) {
		if (engine->instances[i].body != NULL) {
			cpVect pos = C_BodyGetPosition(engine->instances[i].body);
			engine->instances[i].dst.x = pos.x;
			engine->instances[i].dst.y = pos.y;
		}
	}
	C_SpaceStep(engine->space, 1.0/60.0);
}

static void draw(Engine* engine) {
	S_SetRenderDrawBlendMode(engine->renderer, SDL_BLENDMODE_NONE);
	S_SetRenderDrawColor(engine->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	S_RenderClear(engine->renderer);
	for (int i = 0; i < engine->instances_num; i++) {
		Instance* instance = engine->instances + i;
		S_RenderCopy(engine->renderer, instance->texture, NULL, &(instance->dst));
		F_Draw(instance->font->normal, engine->renderer, instance->dst.x, instance->dst.y, instance->text);
	}
	S_RenderCopy(engine->renderer, engine->ui_texture, NULL, &(engine->ui_dst));
	F_Draw(engine->ui_font, engine->renderer, engine->ui_dst.x, engine->ui_dst.y, engine->ui_text);
	S_RenderPresent(engine->renderer);
}

void Tidal_cleanup(Engine* engine) {
	P_deinit();
	for (int i = 0; i < engine->textures_num; i++) {
		S_DestroyTexture(engine->textures[i].data);
		free(engine->textures[i].name);
	}
	free(engine->textures); engine->textures = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Textures freed");
	for (int i = 0; i < engine->instances_num; i++) {
		C_ShapeFree(engine->instances[i].shape);
		C_BodyFree(engine->instances[i].body);
	}
	free(engine->instances); engine->instances = NULL;
	free(engine->layers); engine->layers = NULL;
	S_DestroyTexture(engine->ui_texture);
	free(engine->ui); engine->ui = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Instances freed");
	for (int i = 0; i < engine->objects_num; i++) {
		J_Delete(engine->objects[i].data);
		free(engine->objects[i].name);
	}
	free(engine->objects); engine->objects = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Objects freed");
	for (int i = 0; i < engine->fonts_num; i++) {
		F_FreeFont(engine->fonts[i].normal);
		F_FreeFont(engine->fonts[i].bold);
		free(engine->fonts[i].name);
	}
	free(engine->fonts); engine->fonts = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Fonts freed");
	for (int i = 0; i < engine->audio_num; i++) {
		O_WavDestroy(engine->audio[i].data);
		free(engine->audio[i].name);
	}
	free(engine->audio); engine->audio = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio freed");
	C_SpaceFree(engine->space); engine->space = NULL;
	S_DestroyRenderer(engine->renderer); engine->renderer = NULL;
	S_DestroyWindow(engine->window); engine->window = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Window freed");
	I_Quit();
	O_deinit(engine->soloud);
	O_SoloudDestroy(engine->soloud); engine->soloud = NULL;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Libs quit");
#ifdef STATIC
	S_Quit();
#else
	S_UnloadObject(cjson_lib); cjson_lib = NULL;
	S_UnloadObject(img_lib); img_lib = NULL;
	//S_UnloadObject(ttf_lib); ttf_lib = NULL;
	//S_UnloadObject(mix_lib); mix_lib = NULL;
	S_UnloadObject(cp_lib); cp_lib = NULL;
	S_UnloadObject(soloud_lib); soloud_lib = NULL;
	S_UnloadObject(fc_lib); fc_lib = NULL;
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
