#include "common.h"
#include <stdio.h>

#define FONTSTASH_IMPLEMENTATION
#include <fontstash.h>

#define SOKOL_GLCORE33
#define SOKOL_IMPL
#include <sokol_gfx.h>
#include <sokol_gp.h>
#include <sokol_app.h>
#include <sokol_glue.h>
#include <sokol_gl.h>
#include <sokol_fontstash.h>
#include <sokol_audio.h>

#define PHYSAC_IMPLEMENTATION
#define PHYSAC_STANDALONE
#include <physac.h>

#define LUA_IMPL
#include <minilua.h>
