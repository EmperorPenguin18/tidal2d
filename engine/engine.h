#ifndef __ENGINE_H__
#define __ENGINE_H__

//#include <stdbool.h>
//#define _STDBOOL_H

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

#define NUM_INSTANCES PHYSAC_MAX_BODIES

#ifndef NMOD
#define NMOD 0
#endif

typedef struct engine {
	void (*scripts[NMOD])();
	FONScontext* fs;
	float win_w, win_h;
	uint64_t music_offset, music_pos, music_len;
	uint64_t array_size, img_end;
	void (*events[_SAPP_EVENTTYPE_NUM])(const int);
	struct {
		float r, g, b, a;
	} bkg_col;
	int ins_num;
	struct {
		int font;
		uint32_t font_col;
		float font_size;
		char str[64]; // maybe could be changed at compile time?
		sg_image image;
		float orient;
		sgp_textured_rect rect;
	} ins[NUM_INSTANCES];
} engine;

extern const uint8_t data_array[];
extern const char data_info[];

#endif
