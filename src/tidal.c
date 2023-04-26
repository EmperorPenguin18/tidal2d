//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "tidal.h"
#include "embedded_assets.h"
#include <physfs.h>
#include <SDL2/SDL_image.h>
#include <time.h>
#include <openssl/evp.h>

#ifndef STATIC
#ifdef _WIN32
#include <windows.h>
#else
#include <dlfcn.h>
#endif
#endif

static int lib_load();
static unsigned char* read_data(const char*, size_t*);
static int read_files(Engine*, const char*, const char*);
static const char* getextension(const char*);

static int init_object(Engine*, unsigned char*, size_t, const char*);
static int init_texture(Engine*, unsigned char*, size_t, const char*);
static int init_font(Engine*, unsigned char*, size_t, const char*);
static int init_audio(Engine*, unsigned char*, size_t, const char*, int);

static void events(Engine*);
static void update(Engine*);
static void draw(Engine*);
static void event_handler(Engine*, event_t, char*);

static int init_ui(Engine*, int);
static char* gen_uuid();
static unsigned char collisionCallback(cpArbiter*, cpSpace*, void*);
static int action_spawn(Engine*, const char*, int, int);
static int action_checkui(Engine*);

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
typedef void (*pf_s_getwindowsize)(SDL_Window*, int*, int*);
pf_s_getwindowsize S_GetWindowSize = NULL;
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
typedef int (*pf_p_mountmemory)(const void*, PHYSFS_uint64, void(*)(void*), const char*, const char*, int);
pf_p_mountmemory P_mountMemory = NULL;
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
typedef cJSON_bool (*pf_j_isobject)(const cJSON*);
pf_j_isobject J_IsObject = NULL;
typedef cJSON_bool (*pf_j_isarray)(const cJSON*);
pf_j_isarray J_IsArray = NULL;
typedef cJSON_bool (*pf_j_isbool)(const cJSON*);
pf_j_isbool J_IsBool = NULL;
typedef char* (*pf_j_print)(cJSON*);
pf_j_print J_Print = NULL;
void* img_lib = NULL;
typedef SDL_Texture* (*pf_i_loadtexturerw)(SDL_Renderer*, SDL_RWops*, int);
pf_i_loadtexturerw I_LoadTexture_RW = NULL;
typedef SDL_Surface* (*pf_i_loadrw)(SDL_RWops*, int);
pf_i_loadrw I_Load_RW = NULL;
typedef int (*pf_i_init)(int);
pf_i_init I_Init = NULL;
typedef void (*pf_i_quit)();
pf_i_quit I_Quit = NULL;
void* cp_lib = NULL;
typedef cpFloat (*pf_c_momentforbox)(cpFloat, cpFloat, cpFloat);
pf_c_momentforbox C_MomentForBox = NULL;
typedef cpBody* (*pf_c_bodynew)(cpFloat, cpFloat);
pf_c_bodynew C_BodyNew = NULL;
typedef cpBody* (*pf_c_bodynewstatic)();
pf_c_bodynewstatic C_BodyNewStatic = NULL;
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
typedef cpCollisionHandler* (*pf_c_spaceadddefaultcollisionhandler)(cpSpace*);
pf_c_spaceadddefaultcollisionhandler C_SpaceAddDefaultCollisionHandler = NULL;
typedef cpCollisionHandler* (*pf_c_spaceaddcollisionhandler)(cpSpace*, cpCollisionType, cpCollisionType);
pf_c_spaceaddcollisionhandler C_SpaceAddCollisionHandler = NULL;
typedef void (*pf_c_arbitergetbodies)(const cpArbiter*, cpBody**, cpBody**);
pf_c_arbitergetbodies C_ArbiterGetBodies = NULL;
#define C_ARBITER_GET_BODIES(arb, a, b) cpBody *a, *b; C_ArbiterGetBodies(arb, &a, &b);
typedef void (*pf_c_arbitergetshapes)(const cpArbiter*, cpShape**, cpShape**);
pf_c_arbitergetshapes C_ArbiterGetShapes = NULL;
#define C_ARBITER_GET_SHAPES(arb, a, b) cpShape *a, *b; C_ArbiterGetShapes(arb, &a, &b);
typedef cpDataPointer (*pf_c_bodygetuserdata)(const cpBody*);
pf_c_bodygetuserdata C_BodyGetUserData = NULL;
typedef cpDataPointer (*pf_c_shapegetuserdata)(const cpShape*);
pf_c_shapegetuserdata C_ShapeGetUserData = NULL;
typedef void (*pf_c_bodysetuserdata)(cpBody*, const cpDataPointer);
pf_c_bodysetuserdata C_BodySetUserData = NULL;
typedef void (*pf_c_shapesetuserdata)(cpShape*, const cpDataPointer);
pf_c_shapesetuserdata C_ShapeSetUserData = NULL;
typedef void (*pf_c_bodysetvelocity)(cpBody*, const cpVect);
pf_c_bodysetvelocity C_BodySetVelocity = NULL;
typedef cpBody* (*pf_c_spacegetstaticbody)(const cpSpace*);
pf_c_spacegetstaticbody C_SpaceGetStaticBody = NULL;
typedef void (*pf_c_shapesetcollisiontype)(cpShape*, cpCollisionType);
pf_c_shapesetcollisiontype C_ShapeSetCollisionType = NULL;
typedef cpBool (*pf_c_spaceaddpoststepcallback)(cpSpace*, cpPostStepFunc, void*, void*);
pf_c_spaceaddpoststepcallback C_SpaceAddPostStepCallback = NULL;
typedef void (*pf_c_spaceremoveshape)(cpSpace*, cpShape*);
pf_c_spaceremoveshape C_SpaceRemoveShape = NULL;
typedef void (*pf_c_spaceremovebody)(cpSpace*, cpBody*);
pf_c_spaceremovebody C_SpaceRemoveBody = NULL;
typedef void (*pf_c_spacereindexshape)(cpSpace*, cpShape*);
pf_c_spacereindexshape C_SpaceReindexShape = NULL;
void* soloud_lib = NULL;
typedef Soloud* (*pf_o_soloudcreate)();
pf_o_soloudcreate O_SoloudCreate = NULL;
typedef Wav* (*pf_o_wavcreate)();
pf_o_wavcreate O_WavCreate = NULL;
typedef int (*pf_o_wavloadmemex)(Wav*, const unsigned char*, unsigned int, int, int);
pf_o_wavloadmemex O_WavLoadMemEx = NULL;
typedef int (*pf_o_init)(Soloud*);
pf_o_init O_init = NULL;
typedef int (*pf_o_initex)(Soloud*, unsigned int, unsigned int, unsigned int, unsigned int, unsigned int);
pf_o_initex O_initEx = NULL;
typedef unsigned int (*pf_o_playex)(Soloud*, AudioSource*, float, float, int, unsigned int);
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
typedef unsigned int (*pf_o_playbackgroundex)(Soloud*, AudioSource*, float, int, unsigned int);
pf_o_playbackgroundex O_playBackgroundEx = NULL;
typedef void (*pf_o_setlooping)(Soloud*, unsigned int, int);
pf_o_setlooping O_setLooping = NULL;
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
void* evp_lib;
typedef EVP_CIPHER_CTX* (*pf_e_cipherctxnew)();
pf_e_cipherctxnew E_CIPHER_CTX_new = NULL;
typedef const EVP_CIPHER* (*pf_e_aes256cbc)();
pf_e_aes256cbc E_aes_256_cbc = NULL;
typedef int (*pf_e_decryptinitex)(EVP_CIPHER_CTX*, const EVP_CIPHER*, ENGINE*, const unsigned char*, const unsigned char*);
pf_e_decryptinitex E_DecryptInit_ex = NULL;
typedef int (*pf_e_decryptupdate)(EVP_CIPHER_CTX*, unsigned char*, int*, const unsigned char*, int);
pf_e_decryptupdate E_DecryptUpdate = NULL;
typedef int (*pf_e_decryptfinalex)(EVP_CIPHER_CTX*, unsigned char*, int*);
pf_e_decryptfinalex E_DecryptFinal_ex = NULL;
typedef void (*pf_e_cipherctxfree)(EVP_CIPHER_CTX*);
pf_e_cipherctxfree E_CIPHER_CTX_free = NULL;

/* This function is used instead of -l flags at compile time.
 * Should be moved to another source file, and the Windows
 * part needs work.
 */
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
	S_GetWindowSize = &SDL_GetWindowSize;
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
	P_mountMemory = &PHYSFS_mountMemory;
	J_GetObjectItemCaseSensitive = &cJSON_GetObjectItemCaseSensitive;
	J_ParseWithLength = &cJSON_ParseWithLength;
	J_Delete = &cJSON_Delete;
	J_IsNumber = &cJSON_IsNumber;
	J_IsString = &cJSON_IsString;
	J_GetErrorPtr = &cJSON_GetErrorPtr;
	J_IsTrue = &cJSON_IsTrue;
	J_IsObject = &cJSON_IsObject;
	J_IsArray = &cJSON_IsArray;
	J_IsBool = &cJSON_IsBool;
	J_Print = &cJSON_Print;
	I_LoadTexture_RW = &IMG_LoadTexture_RW;
	I_Load_RW = &IMG_Load_RW;
	I_Init = &IMG_Init;
	I_Quit = &IMG_Quit;
	C_MomentForBox = &cpMomentForBox;
	C_BodyNew = &cpBodyNew;
	C_BodyNewStatic = &cpBodyNewStatic;
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
	C_SpaceAddDefaultCollisionHandler = &cpSpaceAddDefaultCollisionHandler;
	C_SpaceAddCollisionHandler = &cpSpaceAddCollisionHandler;
	C_ArbiterGetBodies = &cpArbiterGetBodies;
	C_ArbiterGetShapes = &cpArbiterGetShapes;
	C_BodyGetUserData = &cpBodyGetUserData;
	C_ShapeGetUserData = &cpShapeGetUserData;
	C_BodySetUserData = &cpBodySetUserData;
	C_ShapeSetUserData = &cpShapeSetUserData;
	C_BodySetVelocity = &cpBodySetVelocity;
	C_SpaceGetStaticBody = &cpSpaceGetStaticBody;
	C_ShapeSetCollisionType = &cpShapeSetCollisionType;
	C_SpaceAddPostStepCallback = &cpSpaceAddPostStepCallback;
	C_SpaceRemoveShape = &cpSpaceRemoveShape;
	C_SpaceRemoveBody = &cpSpaceRemoveBody;
	C_SpaceReindexShape = &cpSpaceReindexShape;
	O_SoloudCreate = &Soloud_create;
	O_WavCreate = &Wav_create;
	O_WavLoadMemEx = &Wav_loadMemEx;
	O_init = &Soloud_init;
	O_initEx = &Soloud_initEx;
	O_playEx = &Soloud_playEx;
	O_deinit = &Soloud_deinit;
	O_WavDestroy = &Wav_destroy;
	O_SoloudDestroy = &Soloud_destroy;
	O_getErrorString = &Soloud_getErrorString;
	O_SfxrCreate = &Sfxr_create;
	O_SfxrLoadParamsEx = &Sfxr_loadParamsMemEx;
	O_SfxrDestroy = &Sfxr_destroy;
	O_playBackgroundEx = &Soloud_playBackgroundEx;
	O_setLooping = &Soloud_setLooping;
	F_CreateFont = &FC_CreateFont;
	F_LoadFontRW = &FC_LoadFont_RW;
	F_Draw = &FC_Draw;
	F_FreeFont = &FC_FreeFont;
	F_MakeColor = &FC_MakeColor;
	E_CIPHER_CTX_new = &EVP_CIPHER_CTX_new;
	E_aes_256_cbc = &EVP_aes_256_cbc;
	E_DecryptInit_ex = &EVP_DecryptInit_ex;
	E_DecryptUpdate = &EVP_DecryptUpdate;
	E_DecryptFinal_ex = &EVP_DecryptFinal_ex;
	E_CIPHER_CTX_free = &EVP_CIPHER_CTX_free;
#else
#ifdef _WIN32
	sdl_lib = LoadLibrary(TEXT("SDL2.dll"));
	if (!sdl_lib) {
		fprintf(stderr, "INFO: Failed to load SDL2 object\n");
		exit(EXIT_FAILURE);
	}
	S_LoadObject = GetProcAddress(sdl_lib, "SDL_LoadObject");
	if (!S_LoadObject) {
		fprintf(stderr, "INFO: Failed to bind SDL_LoadObject\n");
		exit(EXIT_FAILURE);
	}
	S_LoadFunction = GetProcAddress(sdl_lib, "SDL_LoadFunction");
	if (!S_LoadFunction) {
		fprintf(stderr, "INFO: Failed to bind SDL_LoadFunction\n");
		exit(EXIT_FAILURE);
	}
	S_Log = GetProcAddress(sdl_lib, "SDL_Log");
	if (!S_Log) {
		fprintf(stderr, "INFO: Failed to bind SDL_Log\n");
		exit(EXIT_FAILURE);
	}
	S_GetError = GetProcAddress(sdl_lib, "SDL_GetError");
	if (!S_GetError) {
		fprintf(stderr, "INFO: Failed to bind SDL_GetError\n");
		exit(EXIT_FAILURE);
	}
	physfs_lib = LoadLibrary(TEXT("libphysfs.so"));
	if (!physfs_lib) {
		fprintf(stderr, "INFO: code %d\n", GetLastError());
		exit(EXIT_FAILURE);
	}
	P_getErrorByCode = GetProcAddress(physfs_lib, "PHYSFS_getErrorByCode");
	if (!P_getErrorByCode) {
		fprintf(stderr, "INFO: Failed to bind PHYSFS_getErrorByCode\n");
		exit(EXIT_FAILURE);
	}
	P_getLastErrorCode = GetProcAddress(physfs_lib, "PHYSFS_getLastErrorCode");
	if (!P_getLastErrorCode) {
		fprintf(stderr, "INFO: Failed to bind PHYSFS_getLastErrorCode\n");
		exit(EXIT_FAILURE);
	}
	cjson_lib = S_LoadObject("libcjson.so");
	img_lib = S_LoadObject("libSDL2_image.so");
	cp_lib = S_LoadObject("libchipmunk.so");
	soloud_lib = S_LoadObject("soloud.dll");
	fc_lib = S_LoadObject("libFontCache.dll");
	evp_lib = S_LoadObject("libcrypto.dll");
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
	img_lib = S_LoadObject("libSDL2_image.so");
	cp_lib = S_LoadObject("libchipmunk.so");
	soloud_lib = S_LoadObject("libsoloud.so");
	fc_lib = S_LoadObject("libSDL2_FontCache.so");
	evp_lib = S_LoadObject("libcrypto.so");
#endif
	if (!cjson_lib) return -1;
	if (!img_lib) return -1;
	if (!cp_lib) return -1;
	if (!soloud_lib) return -1;
	if (!fc_lib) return -1;
	if (!evp_lib) return -1;
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
	S_GetWindowSize = S_LoadFunction(sdl_lib, "SDL_GetWindowSize");
	if (!S_GetWindowSize) return -1;
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
	P_mountMemory = S_LoadFunction(physfs_lib, "PHYSFS_mountMemory");
	if (!P_mountMemory) return -1;
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
	J_IsObject = S_LoadFunction(cjson_lib, "cJSON_IsObject");
	if (!J_IsObject) return -1;
	J_IsArray = S_LoadFunction(cjson_lib, "cJSON_IsArray");
	if (!J_IsArray) return -1;
	J_IsBool = S_LoadFunction(cjson_lib, "cJSON_IsBool");
	if (!J_IsBool) return -1;
	J_Print = S_LoadFunction(cjson_lib, "cJSON_Print");
	if (!J_Print) return -1;
	I_LoadTexture_RW = S_LoadFunction(img_lib, "IMG_LoadTexture_RW");
	if (!I_LoadTexture_RW) return -1;
	I_Load_RW = S_LoadFunction(img_lib, "IMG_Load_RW");
	if (!I_Load_RW) return -1;
	I_Init = S_LoadFunction(img_lib, "IMG_Init");
	if (!I_Init) return -1;
	I_Quit = S_LoadFunction(img_lib, "IMG_Quit");
	if (!I_Quit) return -1;
	C_MomentForBox = S_LoadFunction(cp_lib, "cpMomentForBox");
	if (!C_MomentForBox) return -1;
	C_BodyNew = S_LoadFunction(cp_lib, "cpBodyNew");
	if (!C_BodyNew) return -1;
	C_BodyNewStatic = S_LoadFunction(cp_lib, "cpBodyNewStatic");
	if (!C_BodyNewStatic) return -1;
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
	C_SpaceAddDefaultCollisionHandler = S_LoadFunction(cp_lib, "cpSpaceAddDefaultCollisionHandler");
	if (!C_SpaceAddDefaultCollisionHandler) return -1;
	C_SpaceAddCollisionHandler = S_LoadFunction(cp_lib, "cpSpaceAddCollisionHandler");
	if (!C_SpaceAddCollisionHandler) return -1;
	C_ArbiterGetBodies = S_LoadFunction(cp_lib, "cpArbiterGetBodies");
	if (!C_ArbiterGetBodies) return -1;
	C_ArbiterGetShapes = S_LoadFunction(cp_lib, "cpArbiterGetShapes");
	if (!C_ArbiterGetShapes) return -1;
	C_BodyGetUserData = S_LoadFunction(cp_lib, "cpBodyGetUserData");
	if (!C_BodyGetUserData) return -1;
	C_ShapeGetUserData = S_LoadFunction(cp_lib, "cpShapeGetUserData");
	if (!C_ShapeGetUserData) return -1;
	C_BodySetUserData = S_LoadFunction(cp_lib, "cpBodySetUserData");
	if (!C_BodySetUserData) return -1;
	C_ShapeSetUserData = S_LoadFunction(cp_lib, "cpShapeSetUserData");
	if (!C_ShapeSetUserData) return -1;
	C_BodySetVelocity = S_LoadFunction(cp_lib, "cpBodySetVelocity");
	if (!C_BodySetVelocity) return -1;
	C_SpaceGetStaticBody = S_LoadFunction(cp_lib, "cpSpaceGetStaticBody");
	if (!C_SpaceGetStaticBody) return -1;
	C_ShapeSetCollisionType = S_LoadFunction(cp_lib, "cpShapeSetCollisionType");
	if (!C_ShapeSetCollisionType) return -1;
	C_SpaceAddPostStepCallback = S_LoadFunction(cp_lib, "cpSpaceAddPostStepCallback");
	if (!C_SpaceAddPostStepCallback) return -1;
	C_SpaceRemoveShape = S_LoadFunction(cp_lib, "cpSpaceRemoveShape");
	if (!C_SpaceRemoveShape) return -1;
	C_SpaceRemoveBody = S_LoadFunction(cp_lib, "cpSpaceRemoveBody");
	if (!C_SpaceRemoveBody) return -1;
	C_SpaceReindexShape = S_LoadFunction(cp_lib, "cpSpaceReindexShape");
	if (!C_SpaceReindexShape) return -1;
	O_SoloudCreate = S_LoadFunction(soloud_lib, "Soloud_create");
	if (!O_SoloudCreate) return -1;
	O_WavCreate = S_LoadFunction(soloud_lib, "Wav_create");
	if (!O_WavCreate) return -1;
	O_WavLoadMemEx = S_LoadFunction(soloud_lib, "Wav_loadMemEx");
	if (!O_WavLoadMemEx) return -1;
	O_init = S_LoadFunction(soloud_lib, "Soloud_init");
	if (!O_init) return -1;
	O_initEx = S_LoadFunction(soloud_lib, "Soloud_initEx");
	if (!O_initEx) return -1;
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
	O_playBackgroundEx = S_LoadFunction(soloud_lib, "Soloud_playBackgroundEx");
	if (!O_playBackgroundEx) return -1;
	O_setLooping = S_LoadFunction(soloud_lib, "Soloud_setLooping");
	if (!O_setLooping) return -1;
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
	E_CIPHER_CTX_new = S_LoadFunction(evp_lib, "EVP_CIPHER_CTX_new");
	if (!E_CIPHER_CTX_new) return -1;
	E_aes_256_cbc = S_LoadFunction(evp_lib, "EVP_aes_256_cbc");
	if (!E_aes_256_cbc) return -1;
	E_DecryptInit_ex = S_LoadFunction(evp_lib, "EVP_DecryptInit_ex");
	if (!E_DecryptInit_ex) return -1;
	E_DecryptUpdate = S_LoadFunction(evp_lib, "EVP_DecryptUpdate");
	if (!E_DecryptUpdate) return -1;
	E_DecryptFinal_ex = S_LoadFunction(evp_lib, "EVP_DecryptFinal_ex");
	if (!E_DecryptFinal_ex) return -1;
	E_CIPHER_CTX_free = S_LoadFunction(evp_lib, "EVP_CIPHER_CTX_free");
	if (!E_CIPHER_CTX_free) return -1;
#endif
	return 0;
}

/* Get the number of digits in an int */
static int findn(int num) {
	if (num == 0) return 1;
	int n = 0;
	while (num) {
		num /= 10;
		n++;
	}
	return n;
}

static void handleErrors(void)
{
    //ERR_print_errors_fp(stderr);
    abort();
}

/* The symmetric decrypt example from openssl */
static int decrypt(const unsigned char *ciphertext, int ciphertext_len, const unsigned char *key, const unsigned char *iv, unsigned char *plaintext) {
    EVP_CIPHER_CTX *ctx;
    int len;
    int plaintext_len;

    /* Create and initialise the context */
    if(!(ctx = E_CIPHER_CTX_new()))
        handleErrors();

    /*
     * Initialise the decryption operation. IMPORTANT - ensure you use a key
     * and IV size appropriate for your cipher
     * In this example we are using 256 bit AES (i.e. a 256 bit key). The
     * IV size for *most* modes is the same as the block size. For AES this
     * is 128 bits
     */
    if(1 != E_DecryptInit_ex(ctx, E_aes_256_cbc(), NULL, key, iv))
        handleErrors();

    /*
     * Provide the message to be decrypted, and obtain the plaintext output.
     * EVP_DecryptUpdate can be called multiple times if necessary.
     */
    if(1 != E_DecryptUpdate(ctx, plaintext, &len, ciphertext, ciphertext_len))
        handleErrors();
    plaintext_len = len;

    /*
     * Finalise the decryption. Further plaintext bytes may be written at
     * this stage.
     */
    if(1 != E_DecryptFinal_ex(ctx, plaintext + len, &len))
        handleErrors();
    plaintext_len += len;

    /* Clean up */
    E_CIPHER_CTX_free(ctx);

    return plaintext_len;
}

/* Initializes all libraries, and reads in assets */
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
	engine->col_hand = NULL;
	for (size_t i = 0; i < EVENTS_NUM; i++) {
		engine->events[i] = NULL;
		engine->events_num[i] = 0;
	}
	time_t t;
	srand((unsigned) time(&t));
	if (lib_load() < 0) return NULL;
	if (S_Init(SDL_INIT_EVERYTHING) < 0) return NULL;
#ifdef DEBUG
	S_LogSetPriority(SDL_LOG_CATEGORY_CUSTOM, SDL_LOG_PRIORITY_DEBUG);
#endif
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "SDL initialized");
	engine->soloud = O_SoloudCreate();
	int err = O_initEx(engine->soloud, 0, SOLOUD_SDL2, SOLOUD_AUTO, SOLOUD_AUTO, SOLOUD_AUTO);
	if (err != 0) {
		S_Log("Soloud error: %s", O_getErrorString(engine->soloud, err));
	       	return NULL;
	}
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "SoLoud initialized");
	if (I_Init(IMG_INIT_JPG | IMG_INIT_PNG) != (IMG_INIT_JPG | IMG_INIT_PNG)) return NULL;
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
	engine->col_hand = C_SpaceAddCollisionHandler(engine->space, 1, 1);
	engine->col_hand->beginFunc = collisionCallback;
	engine->col_hand->userData = engine; //Set the collision handler's user data to the context
	/* If assets have been embedded, then mount those files */
	if (sizeof(embedded_binary) > 0) {
		unsigned char* d_binary = (unsigned char*)malloc(sizeof(embedded_binary));
		int len = decrypt(embedded_binary, sizeof(embedded_binary), embedded_key, embedded_iv, d_binary);
		if (P_mountMemory(d_binary, len, free, "embedded.zip", "embedded", 1) == 0) return NULL;
		if (read_files(engine, "", "embedded") != 0) return NULL;
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Files read");
	}
	int dig = findn(argc); //Get the max number of digits
	for (size_t i = 1; i < argc; i++) {
		char* dir = (char*)calloc(6+dig, 1);
		sprintf(dir, "input%ld", i);
		if (P_mount(argv[i], dir, 1) == 0) return NULL;
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Path mounted");
		if (read_files(engine, "", dir) != 0) return NULL;
		free(dir);
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Files read");
	}
	if (engine->objects_num > 0) action_spawn(engine, engine->first_object->name, 0, 0);
	return engine;
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

/* Recursive function to traverse the PHYSFS virtual file
 * system and read in the data for all asset files based
 * on file extension.
 */
static int read_files(Engine* engine, const char *path, const char* opt) {
	char* fullpath = (char*)calloc(strlen(path)+strlen(opt)+1, 1);
	if (opt == NULL) strcpy(fullpath, path);
	else sprintf(fullpath, "%s%s", opt, path);
	PHYSFS_Stat stat;
	if (P_stat(fullpath, &stat) == 0) return -1;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Path stats acquired");
	if (stat.filetype == PHYSFS_FILETYPE_DIRECTORY) {
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Dir found");
		if (path[0] == '.' || path[1] == '.') return 0;
		char **rc = P_enumerateFiles(fullpath);
		if (rc == NULL) return 0;
		for (char** i = rc; *i != NULL; i++) {
			char* newpath = (char*)calloc(strlen(path)+strlen(*i)+2, 1);
			if (newpath == NULL) continue;
			sprintf(newpath, "%s/%s", path, *i);
			if (read_files(engine, newpath, opt) < 0) return -1;
			free(newpath);
		}
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Files loaded");
		P_freeList(rc);
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "List freed");
	} else if (stat.filetype == PHYSFS_FILETYPE_REGULAR) {
		S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "File found");
		const char* ext = getextension(path);
		size_t len = 0;
		unsigned char* data = read_data(fullpath, &len);
		if (data == NULL) return -1;

		/* This decryption part probably won't work right because
		 * file names.
		*/
		unsigned char* d_data = (unsigned char*)malloc(len);
		if (strcmp(ext, "tidal") == 0) {
			len = decrypt(data, len, embedded_key, embedded_iv, d_data);
		} else memcpy(d_data, data, len);

		if (strcmp(ext, "bmp") == 0 || strcmp(ext, "jpg") == 0 || strcmp(ext, "png") == 0 || strcmp(ext, "svg") == 0) {
			if (init_texture(engine, d_data, len, path) < 0) return -1;
		} else if (strcmp(ext, "json") == 0) {
			S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Contents of json file:\n%s", d_data);
			if (init_object(engine, d_data, len, path) < 0) return -1;
		} else if (strcmp(ext, "ttf") == 0) {
			if (init_font(engine, d_data, len, path) < 0) return -1;
		} else if (strcmp(ext, "wav") == 0 || strcmp(ext, "flac") == 0 || strcmp(ext, "mp3") == 0 || strcmp(ext, "ogg") == 0) {
			if (init_audio(engine, d_data, len, path, 0) < 0) return -1;
		} else if (strcmp(ext, "sfx") == 0) {
			if (init_audio(engine, d_data, len, path, 1) < 0) return -1;
		} else {
			S_Log("Unsupported file type");
		}
		//Add more filetypes later
		free(data);
		free(d_data);
	}
	free(fullpath);
	return 0;
}

/* Basic reading data from file PHYSFS virtual file system */
static unsigned char* read_data(const char* path, size_t* len) {
	PHYSFS_File* file = P_openRead(path);
	if (file == NULL) return NULL;
	*len = P_fileLength(file);
	if (*len == -1) return NULL;
	unsigned char* data = (unsigned char*)calloc(*len+1, 1);
	if (data == NULL) return NULL;
	P_readBytes(file, data, *len);
	if (P_close(file) == 0) return NULL;
	return data;
}

static const char* getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
	if (!dot || dot == filename) return "";
	return dot + 1;
}

/* Read in JSON data */
static int init_object(Engine* engine, unsigned char* data, size_t len, const char* path) {
	Object* tmp = (Object*)realloc(engine->objects, (engine->objects_num+1)*sizeof(Object));
	if (tmp == NULL) return -1;
	engine->objects = tmp;
	engine->objects[engine->objects_num].data = J_ParseWithLength((char*)data, len);
	engine->objects[engine->objects_num].name = (char*)malloc(strlen(path+1)+1);
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

/* Read in image data */
static int init_texture(Engine* engine, unsigned char* data, size_t len, const char* path) {
	Texture* tmp = (Texture*)realloc(engine->textures, (engine->textures_num+1)*sizeof(Texture));
	if (tmp == NULL) return -1;
	engine->textures = tmp;
	SDL_Surface* surface = I_Load_RW(S_RWFromMem(data, len), 1);
	engine->textures[engine->textures_num].data = S_CreateTextureFromSurface(engine->renderer, surface);
	S_FreeSurface(surface);
	engine->textures[engine->textures_num].name = (char*)malloc(strlen(path+1)+1);
	strcpy(engine->textures[engine->textures_num].name, path+1);
	if (!engine->textures[engine->textures_num].data) return -1;
	engine->textures_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Texture successfully created");
	return 0;
}

/* Read in font data */
static int init_font(Engine* engine, unsigned char* data, size_t len, const char* path) {
	Font* tmp = (Font*)realloc(engine->fonts, (engine->fonts_num+1)*sizeof(Font));
	if (tmp == NULL) return -1;
	engine->fonts = tmp;
	engine->fonts[engine->fonts_num].normal = F_CreateFont();
	engine->fonts[engine->fonts_num].bold = F_CreateFont();
	if (F_LoadFontRW(engine->fonts[engine->fonts_num].normal, engine->renderer, S_RWFromMem(data, len), 1, 28, F_MakeColor(0, 0, 0, 255), TTF_STYLE_NORMAL) == 0) return -1;
	if (F_LoadFontRW(engine->fonts[engine->fonts_num].bold, engine->renderer, S_RWFromMem(data, len), 1, 28, F_MakeColor(0, 0, 0, 255), TTF_STYLE_BOLD) == 0) return -1;
	engine->fonts[engine->fonts_num].name = (char*)malloc(strlen(path+1)+1);
	strcpy(engine->fonts[engine->fonts_num].name, path+1);
	if (!engine->fonts[engine->fonts_num].normal) return -1;
	engine->fonts_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Font successfully created");
	return 0;
}

/* Read in audio data. Based on "type" input, different
 * file types can be read from.
 */
static int init_audio(Engine* engine, unsigned char* data, size_t len, const char* path, int type) {
	Audio* tmp = (Audio*)realloc(engine->audio, (engine->audio_num+1)*sizeof(Audio));
	if (tmp == NULL) return -1;
	engine->audio = tmp;
	int err = 0;
	if (type == 0) {
		engine->audio[engine->audio_num].data = O_WavCreate();
		err = O_WavLoadMemEx(engine->audio[engine->audio_num].data, (unsigned char*)data, len, 1, 0);
	} else if (type == 1) {
		engine->audio[engine->audio_num].data = O_SfxrCreate();
		err = O_SfxrLoadParamsEx(engine->audio[engine->audio_num].data, (unsigned char*)data, len, 1, 0);
	}
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Soloud load error: %s", O_getErrorString(engine->soloud, err));
	engine->audio[engine->audio_num].name = (char*)malloc(strlen(path+1)+1);
	strcpy(engine->audio[engine->audio_num].name, path+1);
	if (!engine->audio[engine->audio_num].data) return -1;
	engine->audio_num++;
	S_LogDebug(SDL_LOG_CATEGORY_CUSTOM, "Audio successfully created");
	return 0;
}

/* The main game loop. Avoid including debug code in this function
 * or functions called by it, for performance reasons.
 */
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

/* Check for events from the player */
static void events(Engine* engine) {
	SDL_Event event;
	S_PollEvent(&event);
	switch (event.type) {
		case SDL_QUIT:
			event_handler(engine, TIDAL_EVENT_QUIT, NULL);
			break;
		case SDL_KEYDOWN:
			switch (event.key.keysym.sym) {
				case SDLK_w:
					event_handler(engine, TIDAL_EVENT_KEYW, NULL);
					break;
				case SDLK_a:
					event_handler(engine, TIDAL_EVENT_KEYA, NULL);
					break;
				case SDLK_s:
					event_handler(engine, TIDAL_EVENT_KEYS, NULL);
					break;
				case SDLK_d:
					event_handler(engine, TIDAL_EVENT_KEYD, NULL);
					break;
				case SDLK_SPACE:
					event_handler(engine, TIDAL_EVENT_KEYSPACE, NULL);
					break;
				case SDLK_RETURN:
					event_handler(engine, TIDAL_EVENT_KEYENTER, NULL);
					break;
			}
			break;
		case SDL_MOUSEBUTTONUP:
			switch (event.button.button) {
				case SDL_BUTTON_LEFT:
					event_handler(engine, TIDAL_EVENT_MOUSELEFT, NULL);
					break;
				case SDL_BUTTON_RIGHT:
					event_handler(engine, TIDAL_EVENT_MOUSERIGHT, NULL);
					break;
			}
			break;
	}
}

/* Part of WIP ui system */
static int init_ui(Engine* engine, int n) {
	Instance** tmp = (Instance**)realloc(engine->ui, (engine->ui_num+1)*sizeof(Instance*));
	if (tmp == NULL) return -1;
	engine->ui = tmp;
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

static int init_action(Engine* engine, event_t ev, const cJSON* action, char* id) {
	Action* tmp = (Action*)realloc(engine->events[ev], (engine->events_num[ev]+1)*sizeof(Action));
	if (tmp == NULL) return -1;
	engine->events[ev] = tmp;
	engine->events[ev][engine->events_num[ev]].data = action;
	engine->events[ev][engine->events_num[ev]].id = id;
	engine->events_num[ev]++;
	return 0;
}

/* UUIDs are used to identify an instance, because two instances
 * could be based on the same object.
 */
static char* gen_uuid() {
	char v[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
	//3fb17ebc-bc38-4939-bc8b-74f2443281d4
	//8 dash 4 dash 4 dash 4 dash 12
	char* buf = (char*)calloc(37, 1);
	
	//gen random for all spaces because lazy
	for(int i = 0; i < 36; ++i) {
		buf[i] = v[rand()%16];
	}
	
	//put dashes in place
	buf[8] = '-';
	buf[13] = '-';
	buf[18] = '-';
	buf[23] = '-';
	
	//needs end byte
	buf[36] = '\0';
	
	return buf;
}

/* Action to instantiate an object. Currently quite complex because all the processing
 * of JSON and assigning resources happens in this function. Also has to sort out the
 * layers each time. Will probably eventually be a performance bottleneck. Should add
 * more error messages to inform developer there object is malformed.
 */
static int action_spawn(Engine* engine, const char* name, int x, int y) {
	cJSON* json = NULL;
	for (size_t i = 0; i < engine->objects_num; i++) {
		if (strcmp(name, engine->objects[i].name) == 0) {
			json = engine->objects[i].data;
			break;
		}
	}

	engine->instances = (Instance*)realloc(engine->instances, (engine->instances_num+1)*sizeof(Instance));
	const cJSON* layer = J_GetObjectItemCaseSensitive(json, "layer");
	int num = 0;
	if (J_IsNumber(layer)) num = layer->valueint;
	//If the specified layer is higher than the highest, fill them all out
	if (num+1 > engine->layers_num) {
		engine->layers = (size_t*)realloc(engine->layers, (num+1)*sizeof(size_t));
		for (size_t i = engine->layers_num; i < num+1; i++) engine->layers[i] = 0;
		engine->layers_num = num+1;
	}
	int sum = 0;
	//Get the spot where the new instance will slot in
	for (size_t i = 0; i < num; i++) sum += engine->layers[i];
	engine->layers[num]++;
	engine->instances_num++;
	//Make a spot in the array
	for (size_t i = engine->instances_num - 1; i > sum; i--) engine->instances[i] = engine->instances[i - 1];
	engine->instances[sum].id = gen_uuid();
	engine->instances[sum].layer = num; //Store layer for later
	
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
		for (size_t i = 0; i < engine->textures_num; i++) {
			if (strcmp(engine->textures[i].name, sprite->valuestring) == 0) {
				engine->instances[sum].texture = engine->textures[i].data;
			}
		}
	}

	engine->instances[sum].font = NULL;
	const cJSON* font = J_GetObjectItemCaseSensitive(json, "font");
	if (J_IsString(font) && (font->valuestring != NULL)) {
		for (size_t i = 0; i < engine->fonts_num; i++) {
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
			engine->instances[sum].shape = C_SpaceAddShape(engine->space,
				C_BoxShapeNew(engine->instances[sum].body,
				engine->instances[sum].dst.w, engine->instances[sum].dst.h, 0));
			C_ShapeSetFriction(engine->instances[sum].shape, 0.7);
		} else if (strcmp(shape->valuestring, "wall") == 0) {
			engine->instances[sum].body = C_BodyNewStatic();
			engine->instances[sum].shape = C_SpaceAddShape(engine->space,
				C_BoxShapeNew(engine->instances[sum].body , engine->instances[sum].dst.w,
					engine->instances[sum].dst.h, 0));
			C_ShapeSetFriction(engine->instances[sum].shape, 1);
		}//add other shapes
		C_BodySetPosition(engine->instances[sum].body, cpv(engine->instances[sum].dst.x,
			engine->instances[sum].dst.y));
		C_ShapeSetUserData(engine->instances[sum].shape, engine->instances[sum].id);
		C_ShapeSetCollisionType(engine->instances[sum].shape, 1);
		C_SpaceReindexShape(engine->space, engine->instances[sum].shape);
	}

	const cJSON* ui = J_GetObjectItemCaseSensitive(json, "ui");
	if (J_IsTrue(ui)) {
		init_ui(engine, sum);
	}

	const cJSON* events = J_GetObjectItemCaseSensitive(json, "events");
	if (J_IsObject(events)) {
		const cJSON* event = NULL;
		cJSON_ArrayForEach(event, events) {
			if (J_IsArray(event)) {
				event_t ev = 0;
				if (strcmp(event->string, "collision") == 0) {
					ev = TIDAL_EVENT_COLLISION;
				} else if (strcmp(event->string, "quit") == 0) {
					ev = TIDAL_EVENT_QUIT;
				} else if (strcmp(event->string, "key_w") == 0) {
					ev = TIDAL_EVENT_KEYW;
				} else if (strcmp(event->string, "key_a") == 0) {
					ev = TIDAL_EVENT_KEYA;
				} else if (strcmp(event->string, "key_s") == 0) {
					ev = TIDAL_EVENT_KEYS;
				} else if (strcmp(event->string, "key_d") == 0) {
					ev = TIDAL_EVENT_KEYD;
				} else if (strcmp(event->string, "key_space") == 0) {
					ev = TIDAL_EVENT_KEYSPACE;
				} else if (strcmp(event->string, "key_enter") == 0) {
					ev = TIDAL_EVENT_KEYENTER;
				} else if (strcmp(event->string, "mouse_left") == 0) {
					ev = TIDAL_EVENT_MOUSELEFT;
				} else if (strcmp(event->string, "mouse_right") == 0) {
					ev = TIDAL_EVENT_MOUSERIGHT;
				} else if (strcmp(event->string, "creation") == 0) {
					ev = TIDAL_EVENT_CREATION;
				} else if (strcmp(event->string, "destruction") == 0) {
					ev = TIDAL_EVENT_DESTRUCTION;
				} else if (strcmp(event->string, "check_ui") == 0) {
					ev = TIDAL_EVENT_CHECKUI;
				} else if (strcmp(event->string, "leave") == 0) {
					ev = TIDAL_EVENT_LEAVE;
				} else {
					S_Log("Invalid event type found");
					continue;
				}
				const cJSON* action = NULL;
				cJSON_ArrayForEach(action, event) {
					if (J_IsObject(action)) {
						init_action(engine, ev, action, engine->instances[sum].id);
					}
				}
			} else {
				S_Log("Invalid object structure found");
			}
		}
	}

	event_handler(engine, TIDAL_EVENT_CREATION, engine->instances[sum].id);

	return 0;
}

/* Free resources used by instance. See action documentation. */
static int action_destroy(Engine* engine, char* id) {
	event_handler(engine, TIDAL_EVENT_DESTRUCTION, id);

	Instance* instance = NULL;
	size_t n;
	for (n = 0; n < engine->instances_num; n++) {
		if (strcmp(id, engine->instances[n].id) == 0) {
			instance = engine->instances+n;
			break;
		}
	}

	C_SpaceRemoveShape(engine->space, instance->shape);
	C_SpaceRemoveBody(engine->space, instance->body);
	C_ShapeFree(instance->shape);
	C_BodyFree(instance->body);
	free(instance->id);

	for (size_t i = n; i < engine->instances_num-1; i++) engine->instances[i] = engine->instances[i + 1];
	engine->instances_num -= 1;

	engine->layers[instance->layer] -= 1;

	return 0;
}

/* Do a Chipmunk "teleport". See action documentation */
static int action_move(Engine* engine, char* id, int x, int y, bool relative) {
	cpBody* body = NULL;
	cpShape* shape = NULL;
	for (size_t i = 0; i < engine->instances_num; i++) {
		if (strcmp(engine->instances[i].id, id) == 0) {
			body = engine->instances[i].body;
			shape = engine->instances[i].shape;
			break;
		}
	}

	if (relative) {
		cpVect v = C_BodyGetPosition(body);
		int rel_x = v.x + x;
		int rel_y = v.y + y;
		C_BodySetPosition(body, cpv(rel_x, rel_y));
	} else C_BodySetPosition(body, cpv(x, y));

	C_SpaceReindexShape(engine->space, shape);
	return 0;
}

/* Change a physics body velocity. See action documentation. */
static int action_speed(Engine* engine, char* id, int h, int v) {
	for (size_t i = 0; i < engine->instances_num; i++) {
		if (strcmp(engine->instances[i].id, id) == 0) {
			C_BodySetVelocity(engine->instances[i].body, cpv(h, v));
			break;
		}
	}
	return 0;
}

/* Set the space's gravity. See action documentation. */
static int action_gravity(Engine* engine, int h, int v) {
	C_SpaceSetGravity(engine->space, cpv(h, v));
	return 0;
}

/* Play audio once. See action documentation. */
static int action_sound(Engine* engine, char* file) {
	for (size_t i = 0; i < engine->audio_num; i++) {
		if (strcmp(engine->audio[i].name, file) == 0) {
			O_playEx(engine->soloud, engine->audio[i].data, 1.0, 0.0, 0, 0);
			break;
		}
	}
	return 0;
}

/* Play audio on loop. See action documentation. */
static int action_music(Engine* engine, char* file) {
	for (size_t i = 0; i < engine->audio_num; i++) {
		if (strcmp(engine->audio[i].name, file) == 0) {
			unsigned int h = O_playBackgroundEx(engine->soloud, engine->audio[i].data, 1.0, 0, 0);
			O_setLooping(engine->soloud, h, 1);
			break;
		}
	}
	return 0;
}

/* End the game loop. See action documentation. */
static int action_close(Engine* engine) {
	engine->running = false;
	return 0;
}

/* Part of the WIP ui system. */
static int action_checkui(Engine* engine) {
	event_handler(engine, TIDAL_EVENT_CHECKUI, NULL);
	return 0;
}

/* Update instance position based on physics. Could probably be combined with draw(). */
static void update(Engine* engine) {
	for (int i = 0; i < engine->instances_num; i++) {
		if (engine->instances[i].body != NULL) {
			SDL_Rect* dst = &(engine->instances[i].dst);
			int w, h;
			S_GetWindowSize(engine->window, &w, &h);
			cpVect pos = C_BodyGetPosition(engine->instances[i].body);
			if ( (dst->x < w && pos.x > w) || (dst->x > 0-dst->w && pos.x < 0-dst->w) || (dst->y < h && pos.y > h) || (dst->y > 0-dst->h && pos.y < 0-dst->h) ) {
				event_handler(engine, TIDAL_EVENT_LEAVE, engine->instances[i].id);
			}
			dst->x = pos.x;
			dst->y = pos.y;
		}
	}
	C_SpaceStep(engine->space, 1.0/60.0);
}

/* Loop over every texture, including text, and render them with SDL. */
static void draw(Engine* engine) {
	S_SetRenderDrawBlendMode(engine->renderer, SDL_BLENDMODE_NONE);
	S_SetRenderDrawColor(engine->renderer, 0xc1, 0xc1, 0xc1, SDL_ALPHA_OPAQUE);
	S_RenderClear(engine->renderer);
	for (int i = 0; i < engine->instances_num; i++) {
		Instance* instance = engine->instances + i;
		S_RenderCopy(engine->renderer, instance->texture, NULL, &instance->dst);
		if (instance->text) F_Draw(instance->font->normal, engine->renderer, instance->dst.x, instance->dst.y, "%s", instance->text);
	}
	S_RenderCopy(engine->renderer, engine->ui_texture, NULL, &engine->ui_dst);
	F_Draw(engine->ui_font, engine->renderer, engine->ui_dst.x, engine->ui_dst.y, "%s", engine->ui_text);
	S_RenderPresent(engine->renderer);
}

/* Engine struct stores a 2D array. The first dimension is the different event types (LEAVE, CREATION etc).
 * The second dimension is dynamically sized and re-sized, and stores all the different actions that instances
 * have added.
 *
 * This function takes the context, event type, and the id of the calling instance, and will loop over
 * all the actions executing them based on the specifications provided by an object.
 */
static void event_handler(Engine* engine, event_t ev, char* id) {
	for (int i = 0; i < engine->events_num[ev]; i++) {
		Action* action = engine->events[ev] + i;
		//Special case: some events only trigger based on instance id
		if (ev == TIDAL_EVENT_CREATION || ev == TIDAL_EVENT_DESTRUCTION ||
		    ev == TIDAL_EVENT_LEAVE || ev == TIDAL_EVENT_COLLISION) {
			if (strcmp(action->id, id) != 0) continue;
		}
		const cJSON* type = J_GetObjectItemCaseSensitive(action->data, "type");
		if (J_IsString(type) && (type->valuestring != NULL)) {
			if (strcmp(type->valuestring, "spawn") == 0) {
				const cJSON* object = J_GetObjectItemCaseSensitive(action->data, "object");
				const cJSON* x = J_GetObjectItemCaseSensitive(action->data, "x");
				const cJSON* y = J_GetObjectItemCaseSensitive(action->data, "y");
				if (J_IsString(object) && (object->valuestring != NULL) && J_IsNumber(x) && J_IsNumber(y)) {
					action_spawn(engine, object->valuestring, x->valueint, y->valueint);
				}
			} else if (strcmp(type->valuestring, "destroy") == 0) {
				action_destroy(engine, action->id);
			} else if (strcmp(type->valuestring, "move") == 0) {
				const cJSON* x = J_GetObjectItemCaseSensitive(action->data, "x");
				const cJSON* y = J_GetObjectItemCaseSensitive(action->data, "y");
				const cJSON* relative = J_GetObjectItemCaseSensitive(action->data, "relative");
				if (J_IsNumber(x) && J_IsNumber(y) && J_IsBool(relative)) {
					action_move(engine, action->id, x->valueint, y->valueint, relative->valueint);
				}
			} else if (strcmp(type->valuestring, "speed") == 0) {
				const cJSON* h = J_GetObjectItemCaseSensitive(action->data, "h");
				const cJSON* v = J_GetObjectItemCaseSensitive(action->data, "v");
				if (J_IsNumber(h) && J_IsNumber(v)) {
					action_speed(engine, action->id, h->valueint, v->valueint);
				}
			} else if (strcmp(type->valuestring, "gravity") == 0) {
				const cJSON* h = J_GetObjectItemCaseSensitive(action->data, "h");
				const cJSON* v = J_GetObjectItemCaseSensitive(action->data, "v");
				if (J_IsNumber(h) && J_IsNumber(v)) {
					action_gravity(engine, h->valueint, v->valueint);
				}
			} else if (strcmp(type->valuestring, "sound") == 0) {
				const cJSON* file = J_GetObjectItemCaseSensitive(action->data, "file");
				if (J_IsString(file) && (file->valuestring != NULL)) {
					action_sound(engine, file->valuestring);
				}
			} else if (strcmp(type->valuestring, "music") == 0) {
				const cJSON* file = J_GetObjectItemCaseSensitive(action->data, "file");
				if (J_IsString(file) && (file->valuestring != NULL)) {
					action_music(engine, file->valuestring);
				}
			} else if (strcmp(type->valuestring, "close") == 0) {
				action_close(engine);
			} else if (strcmp(type->valuestring, "checkui") == 0) {
				action_checkui(engine);
			} else {
				S_Log("Invalid action type found");
			}
		}
	}
}

/* Free resources used by the engine. Could be cleaned up with
 * generic type cleaners.
 */
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
		free(engine->instances[i].id);
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
	for (int i = 0; i < EVENTS_NUM; i++) {
		free(engine->events[i]);
		engine->events[i] = NULL;
	}
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
	S_UnloadObject(cp_lib); cp_lib = NULL;
	S_UnloadObject(soloud_lib); soloud_lib = NULL;
	S_UnloadObject(fc_lib); fc_lib = NULL;
	S_UnloadObject(evp_lib); evp_lib = NULL;
	S_Quit();
#ifdef _WIN32
	FreeLibrary(sdl_lib); sdl_lib = NULL;
	FreeLibrary(physfs_lib); physfs_lib = NULL;
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
