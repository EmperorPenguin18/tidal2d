#include <stdio.h>
#include <math.h>

#include "common.h"
#include "engine.h"
#include "actions.h"

engine e; // global state

static void frame(void) {
	const float width = sapp_widthf(), height = sapp_heightf();
	const float ratio = e.win_w/e.win_h;

	printf("here0\n"); //debug
	sgp_begin(width, height);
	sgp_viewport(0, 0, width, height);
	fonsClearState(e.fs);
	sgl_defaults();
	sgl_matrix_mode_projection();
	sgl_ortho(0.0f, width, height, 0.0f, -1.0f, +1.0f);

	sgp_set_color(0.0f, 0.0f, 0.0f, 1.0f);
	sgp_clear();
	sgp_set_color(e.bkg_col.r, e.bkg_col.g, e.bkg_col.b, e.bkg_col.a);
	const float scale = MIN(width/e.win_w, height/e.win_h);
	sgp_draw_filled_rect(0, 0, scale*e.win_w, scale*e.win_h);
	sgp_reset_color();
	sgp_scissor(0, 0, scale*e.win_w, scale*e.win_h);
	sgp_set_blend_mode(SGP_BLENDMODE_BLEND);

	printf("here1\n"); //debug
	const float time = sapp_frame_count() * sapp_frame_duration();
	for (int i = 0; i < e.ins_num; i++) {
		sgp_scale(scale, scale);
		sgp_rect* dst = &e.ins[i].rect.dst;
		/*PhysicsBody body = GetPhysicsBody(i);
		if (body) {
			dst->x = body->position.x;
			dst->y = body->position.y;
			e.ins[i].orient = body->orient;
		}*/
		const float font_size = e.ins[i].font_size*scale;
		fonsSetFont(e.fs, e.ins[i].font);
		fonsSetSize(e.fs, font_size);
		fonsSetColor(e.fs, e.ins[i].font_col);
		fonsDrawText(e.fs, dst->x*scale, (dst->y*scale)+font_size, e.ins[i].str, NULL); // might want to tweak height offset
		sgp_set_image(0, e.ins[i].image);
		sgp_rotate_at(e.ins[i].orient, dst->x+(dst->w/2), dst->y+(dst->h/2));
		sgp_draw_textured_rect(0, *dst, e.ins[i].rect.src);
		sgp_reset_transform();
	}
	sgp_reset_image(0);

	sfons_flush(e.fs);
	sg_pass pass = {.swapchain = sglue_swapchain()};
	sg_begin_pass(&pass);
	sgp_flush();
	sgp_end();
	sgl_draw();
	sg_end_pass();
	sg_commit();
}

static void call_va(const char *sig, ...) {
	va_list vl;
	int narg, nres;  /* number of arguments and results */

	va_start(vl, sig);

	/* push arguments */
	narg = 0;
	while (*sig) {  /* push arguments */
		switch (*sig++) {

		case 'd':  /* double argument */
			lua_pushnumber(e.L, va_arg(vl, double));
			break;

		case 'i':  /* int argument */
			lua_pushnumber(e.L, va_arg(vl, int));
			break;

		case 's':  /* string argument */
			lua_pushstring(e.L, va_arg(vl, char *));
			break;

		default:
			luaL_error(e.L, "invalid option (%c)", *(sig - 1));
		}
		narg++;
		luaL_checkstack(e.L, 1, "too many arguments");
	}

	/* do the call */
	nres = strlen(sig);  /* number of expected results */
	if (lua_pcall(e.L, narg, nres, 0) != 0)  /* do the call */
		luaL_error(e.L, "error running callback: %s", lua_tostring(e.L, -1));

	va_end(vl);
}

static void event(const sapp_event* event) {
	int* type = e.events+event->type;
	if (*type) {
		lua_rawgeti(e.L, LUA_REGISTRYINDEX, *type);
		lua_pushvalue(e.L, 1);
		call_va("i", event->key_code);
		*type = luaL_ref(e.L, LUA_REGISTRYINDEX);
	}
}

/*void mix(const void* newbuf, size_t len) {
	//temp
	memcpy(e.buffer, newbuf, MIN(len, 1024));
}*/

static void stream_cb(float* buffer, int num_frames, int num_channels) {
	const int num_samples = num_frames * num_channels;
	const int cpy_size = MIN(num_samples*4, e.music_len-e.music_pos);
	memcpy(buffer, data_array+e.music_offset+e.music_pos, cpy_size);
	e.music_pos += cpy_size;
	if (e.music_pos >= e.music_len) e.music_pos = 0;
}

static void init(void) {
	DATA_LOOP(e.array_size);
	DATA_LOOP(e.img_end, // works because images are at beginning of array
		if (strcmp("bmp", extension(data_info+i)) != 0 &&
		strcmp("jpg", extension(data_info+i)) != 0 &&
		strcmp("png", extension(data_info+i)) != 0 &&
		strcmp("svg", extension(data_info+i)) != 0) break;
	);

	sg_desc sgdesc = {
		.environment = sglue_environment(),
	};
	sg_setup(&sgdesc);
	if (!sg_isvalid()) exit(EXIT_FAILURE);

	sgl_desc_t sgldesc = {0};
	sgl_setup(&sgldesc);

	sgp_desc sgpdesc = {0};
	sgp_setup(&sgpdesc);
	if (!sgp_is_valid()) exit(EXIT_FAILURE);
	e.bkg_col.r = 0.5f; e.bkg_col.g = 0.5f; e.bkg_col.b = 0.5f; e.bkg_col.a = 1.0f;

	e.fs = sfons_create(&(sfons_desc_t){
		.width = 512,
		.height = 512,
        });
	size_t offset;
	DATA_LOOP(offset,
		if (strcmp(extension(data_info+i), "ttf") == 0)
			fonsAddFontMem(e.fs, basename(data_info+i), (unsigned char*)data_array+offset, size, 0); // ignore warning
	);

	saudio_setup(&(saudio_desc){ .stream_cb = stream_cb });
	if (!saudio_isvalid()) exit(EXIT_FAILURE);

	//InitPhysics();

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
	for (int i = 0; i < e.ins_num; i++) sg_destroy_image(e.ins[i].image);
	for (int i = 0; i < _SAPP_EVENTTYPE_NUM; i++) luaL_unref(e.L, LUA_REGISTRYINDEX, e.events[i]);
	lua_close(e.L);
	//ClosePhysics();
	saudio_shutdown();
	sfons_destroy(e.fs);
	sgp_shutdown();
	sgl_shutdown();
	sg_shutdown();
}

sapp_desc sokol_main(int argc, char* argv[]) {
	(void)argc;
	(void)argv;
	e.win_w = 240;
	e.win_h = 160;
	return (sapp_desc){
		.init_cb = init,
		.frame_cb = frame,
		.cleanup_cb = cleanup,
		.event_cb = event,
		.window_title = "Tidal2D Game",
		.width = e.win_w,
		.height = e.win_h,
	};
}
