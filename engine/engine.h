#ifndef __ENGINE_H__

#include <sokol_gfx.h>
#include <sokol_gp.h>
#include <sokol_app.h>
#include <sokol_glue.h>
#define PHYSAC_STANDALONE
#include <physac.h>
#include <minilua.h>

#define NUM_INSTANCES PHYSAC_MAX_BODIES

typedef struct engine {
	lua_State* L;
	sg_image image;
	int ins_num;
	sgp_textured_rect ins_rect[NUM_INSTANCES];
	float ins_w[NUM_INSTANCES];
	float ins_h[NUM_INSTANCES];
} engine;

extern const unsigned char data_array[];
extern const unsigned char data_info[];

#endif
