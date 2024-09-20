#ifndef GBA

#include <stdlib.h>
#include <stdio.h>
#ifdef _WIN32
#include <windows.h>
#endif
#define FONTSTASH_IMPLEMENTATION
#include <fontstash.h>

#ifdef EMSCRIPTEN
#define SOKOL_GLES3
#else
#define SOKOL_GLCORE33
#endif
#define SOKOL_IMPL
#include <sokol_gfx.h>
#include <sokol_gp.h>
#include <sokol_app.h>
#include <sokol_glue.h>
#include <sokol_gl.h>
#include <sokol_fontstash.h>
#include <sokol_audio.h>

//#define _STDBOOL_H
#define PHYSAC_IMPLEMENTATION
#define PHYSAC_STANDALONE
#include <physac.h>

#endif //GBA
