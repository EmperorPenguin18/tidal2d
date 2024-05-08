#include <stdio.h>
#include <math.h>

#include "common.h"
#include "engine.h"
#include "actions.h"

engine e; // global state

static void frame(void) {
	int width = sapp_width(), height = sapp_height();
	float ratio = width/(float)height;

	sgp_begin(width, height);
	sgp_viewport(0, 0, width, height);

	sgp_set_color(0.5f, 0.5f, 0.5f, 1.0f);
	sgp_clear();
	sgp_reset_color();
	sgp_set_blend_mode(SGP_BLENDMODE_NONE);

	float time = sapp_frame_count() * sapp_frame_duration();
	for (int i = 0; i < e.ins_num; i++) {
		PhysicsBody body = GetPhysicsBody(i);
		if (body) {
			e.ins_rect[i].dst.x = body->position.x;
			e.ins_rect[i].dst.y = body->position.y;
		}
	}
	sgp_set_image(0, e.image);
	sgp_draw_textured_rects(0, &e.ins_rect[0], e.ins_num);
	sgp_reset_image(0);

	sg_pass pass = {.swapchain = sglue_swapchain()};
	sg_begin_pass(&pass);
	sgp_flush();
	sgp_end();
	sg_end_pass();
	sg_commit();
}

static void event(const sapp_event* event) {
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

	size_t offset;
	DATA_LOOP(offset);
	sg_range range = { .ptr = data_array, .size = offset };
	sg_image_data image_data = { .subimage[0][0] = range };
	sg_image_desc image_desc = {
		.width = offset/4,
		.height = 1,
		.data = image_data,
	};
	e.image = sg_make_image(&image_desc);
	if (sg_query_image_state(e.image) != SG_RESOURCESTATE_VALID) exit(EXIT_FAILURE);

	InitPhysics();

	e.L = luaL_newstate();
	luaL_openlibs(e.L);
	luaL_newlib(e.L, actions);
	lua_setglobal(e.L, "tidal");
	DATA_LOOP(offset,
		if (strcmp(extension(data_info+i), "lua") == 0)
			if (luaL_dostring(e.L, data_array+offset) != 0)
				fprintf(stderr, "Script failed: %s\n%s\n%s\n", basename(data_info+i), data_array+offset, lua_tostring(e.L, -1));
	)
}

static void cleanup(void) {
	lua_close(e.L);
	ClosePhysics();
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
