#include <stdio.h>
#include <math.h>
#include <time.h>

#include "common.h"
#include "engine.h"

engine e; // global state

static const char* extension(const char* filename) {
	return strrchr(filename, '.')+1;
}

static void frame(void) {
#ifndef GBA
	const float width = sapp_widthf(), height = sapp_heightf();

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

	for (int i = 0; i < e.ins_num; i++) {
		sgp_scale(scale, scale);
		sgp_rect* dst = &e.ins[i].rect.dst;
		PhysicsBody body = GetPhysicsBody(i);
		if (body) {
			dst->x = body->position.x;
			dst->y = body->position.y;
			e.ins[i].orient = body->orient;
		}
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
#endif //GBA
}

static void event(const sapp_event* event) {
	if (e.events[event->type]) e.events[event->type](event->key_code);
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

void register_script(void (*script)()) {
	static int counter = 0;
	e.scripts[counter] = script;
	counter++;
}

static void init(void) {
	srand(time(NULL));

	DATA_LOOP(e.array_size,;);
	DATA_LOOP(e.img_end, // works because images are at beginning of array
		if (strcmp("bmp", extension(data_info+i)) != 0 &&
		strcmp("jpg", extension(data_info+i)) != 0 &&
		strcmp("png", extension(data_info+i)) != 0 &&
		strcmp("svg", extension(data_info+i)) != 0) break;
	);

#ifndef GBA
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
	uint64_t offset;
	DATA_LOOP(offset,
		if (strcmp(extension(data_info+i), "ttf") == 0)
			fonsAddFontMem(e.fs, basename(data_info+i), (unsigned char*)data_array+offset, size, 0); // ignore warning
	);

	saudio_setup(&(saudio_desc){
		.stream_cb = stream_cb,
		.sample_rate = 48000,
		.num_channels = 2,
		.buffer_frames = 1024,
	});
	if (!saudio_isvalid()) exit(EXIT_FAILURE);

	InitPhysics();

	for (int i = 0; i < NMOD; i++) e.scripts[i]();
#endif //GBA
}

static void cleanup(void) {
#ifndef GBA
	for (int i = 0; i < e.ins_num; i++) sg_destroy_image(e.ins[i].image);
	ClosePhysics();
	saudio_shutdown();
	sfons_destroy(e.fs);
	sgp_shutdown();
	sgl_shutdown();
	sg_shutdown();
#endif //GBA
}

#ifndef GBA
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
#else //GBA
int main(int argc, char* argv[]) {
	init();
	while (true) frame();
	cleanup();
	return 0;
}
#endif //GBA
