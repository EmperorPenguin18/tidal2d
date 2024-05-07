#include <stdio.h>
#include <math.h>

#include "common.h"
#include "actions.h"

#include <sokol_gfx.h>
#include <sokol_gp.h>
#include <sokol_app.h>
#include <sokol_glue.h>
#define PHYSAC_STANDALONE
#include <physac.h>

#define NUM_INSTANCES PHYSAC_MAX_BODIES

engine e; // global state

extern const unsigned char data_array[];
extern const unsigned char data_info[];

static void frame(void) {
	int width = sapp_width(), height = sapp_height();
	float ratio = width/(float)height;

	sgp_begin(width, height);
	sgp_viewport(0, 0, width, height);
	sgp_project(-ratio, ratio, 1.0f, -1.0f);

	sgp_set_color(0.1f, 0.1f, 0.1f, 1.0f);
	sgp_clear();

	float time = sapp_frame_count() * sapp_frame_duration();
	float r = sinf(time)*0.5+0.5, g = cosf(time)*0.5+0.5;
	sgp_set_color(r, g, 0.3f, 1.0f);
	sgp_rotate_at(time, 0.0f, 0.0f);
	sgp_draw_filled_rect(-0.5f, -0.5f, 1.0f, 1.0f);

	sg_pass pass = {.swapchain = sglue_swapchain()};
	sg_begin_pass(&pass);
	sgp_flush();
	sgp_end();
	sg_end_pass();
	sg_commit();
}

static void event(const sapp_event* event) {
}

#define DATA_LOOP(...) \
	size_t offset = 0; \
	for (int i = 0; data_info[i];) { \
		size_t len = strlen(data_info+i)+1; \
		size_t size = (size_t)*(data_info+i+len); \
		__VA_ARGS__ \
		offset += size; \
		i += len + 8; \
	}


static void init(void) {
	sg_desc sgdesc = {
		.environment = sglue_environment(),
	};
	sg_setup(&sgdesc);
	if (!sg_isvalid()) exit(EXIT_FAILURE);

	sgp_desc sgpdesc = {0};
	sgp_setup(&sgpdesc);
	if (!sgp_is_valid()) exit(EXIT_FAILURE);

	e.L = luaL_newstate();
	luaL_openlibs(e.L);
	luaL_newlib(e.L, actions);
	lua_setglobal(e.L, "tidal");
	DATA_LOOP(
		if (strcmp(extension(data_info+i), "lua") == 0)
			if (luaL_dostring(e.L, data_array+offset) != 0)
				fprintf(stderr, "Script failed: %s\n%s\n%s\n", basename(data_info+i), data_array+offset, lua_tostring(e.L, -1));
	)
}

static void cleanup(void) {
	lua_close(e.L);
	sgp_shutdown();
	sg_shutdown();
}

sapp_desc sokol_main(int argc, char* argv[]) {
	(void)argc;
	(void)argv;
	return (sapp_desc){
		.init_cb = init,
		.frame_cb = frame,
		.cleanup_cb = cleanup,
		.event_cb = event,
		.window_title = "Tidal2D Game",
	};
}
