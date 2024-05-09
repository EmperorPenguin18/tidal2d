#ifndef __ENGINE_H__

#include <fontstash.h>
#include <sokol_gfx.h>
#include <sokol_gp.h>
#include <sokol_app.h>
#include <sokol_glue.h>
#include <sokol_gl.h>
#include <sokol_fontstash.h>
#include <sokol_audio.h>
#define PHYSAC_STANDALONE
#include <physac.h>
#include <minilua.h>

#define NUM_INSTANCES PHYSAC_MAX_BODIES

typedef struct instance {
	float w;
	float h;
	int font;
	char str[64]; // maybe could be changed at compile time?
} instance;

typedef struct engine {
	lua_State* L;
	FONScontext* fs;
	size_t img_begin;
	sg_image image;
	int ins_num;
	float win_w;
	float win_h;
	size_t music_offset;
	size_t music_pos;
	size_t music_len;
	instance ins[NUM_INSTANCES];
	sgp_textured_rect ins_rect[NUM_INSTANCES];
} engine;

extern const unsigned char data_array[];
extern const unsigned char data_info[];

#endif
