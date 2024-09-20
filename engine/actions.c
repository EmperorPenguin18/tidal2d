#include "common.h"
#include "engine.h"
#include "actions.h"

#include <math.h>
#include <stdio.h>
#include <stdarg.h>

extern engine e;
void mix(const void*, size_t);

int tidal_create() {
	if (e.ins_num == NUM_INSTANCES) return -1;
	e.ins_num++;
	return e.ins_num-1;
}

void tidal_set_size(const int index, const int w, const int h) {
	e.ins[index].rect.dst.w = w;
	e.ins[index].rect.dst.h = h;
}

void tidal_set_sprite(const int index, const char* name) {
	sgp_rect* dst = &e.ins[index].rect.dst;

	uint64_t offset;
	DATA_LOOP(offset,
		if (strcmp(name, basename(data_info+i)) == 0) break;
	);
	//sg_query_row_pitch
	//sg_query_surface_pitch
	sg_destroy_image(e.ins[index].image);
	const sg_range range = { .ptr = data_array+offset, .size = e.img_end-offset };
	const sg_image_data image_data = { .subimage[0][0] = range };
	const sg_image_desc image_desc = {
		.width = dst->w,
		.height = (e.img_end-offset)/(4*dst->w),
		.data = image_data,
	};
	e.ins[index].image = sg_make_image(&image_desc);
	const sg_resource_state state = sg_query_image_state(e.ins[index].image);
	if (state != SG_RESOURCESTATE_VALID) {
		fprintf(stderr, "image state invalid: %d\n", state);
		exit(EXIT_FAILURE);
	}

	e.ins[index].rect.src.x = 0;
	e.ins[index].rect.src.y = 0;
	e.ins[index].rect.src.w = dst->w;
	e.ins[index].rect.src.h = dst->h;
}

void tidal_set_shape(const int index, const char* shape) {
	PhysicsBody body;
	if ((body = GetPhysicsBody(index))) DestroyPhysicsBody(body);
	if (strcmp(shape, "box") == 0) {
		sgp_rect dst = e.ins[index].rect.dst;
		Vector2 pos = {dst.x, dst.y};
		body = CreatePhysicsBodyRectangle(pos, dst.w, dst.h, 1.0f);
	} else if (strcmp(shape, "wall") == 0) {
		sgp_rect dst = e.ins[index].rect.dst;
		Vector2 pos = {dst.x, dst.y};
		body = CreatePhysicsBodyRectangle(pos, dst.w, dst.h, 1.0f);
		body->enabled = false;
	// add more shapes
	} else {
		fprintf(stderr, "incorrect shape name\n");
	}
}

void tidal_set_gravity(const float x, const float y) {
	SetPhysicsGravity(x, y);
}

void tidal_set_pos(const int index, const float x, const float y) {
	e.ins[index].rect.dst.x = x;
	e.ins[index].rect.dst.y = y;
}

void tidal_set_font(const int index, const char* font) {
	e.ins[index].font = fonsGetFontByName(e.fs, font);
	e.ins[index].font_size = 16.0f;
	e.ins[index].font_col = sfons_rgba(0, 0, 0, 255);
}

void tidal_set_text(const int index, const char* format, ...) {
	va_list arg;
	va_start(arg, format);
	int err = vsnprintf(e.ins[index].str, 64, format, arg);
	if (err > 63 || err < 0) {
		fprintf(stderr, "text format error\n");
		exit(EXIT_FAILURE);
	}
	va_end(arg);
}

void tidal_set_music(const char* name) {
	uint64_t offset;
	DATA_LOOP(offset,
		if (strcmp(name, basename(data_info+i)) == 0) {
			e.music_offset = offset;
			e.music_len = size;
			e.music_pos = 0;
			break;
		}
	);
}

void tidal_set_cb_keydown(void (*func)(const int)) {
	if (!func) {
		fprintf(stderr, "must call back to a function\n");
		exit(EXIT_FAILURE);
	}
	e.events[SAPP_EVENTTYPE_KEY_DOWN] = func;
}

void tidal_set_background_colour(const int r, const int g, const int b, const int a) {
	if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 255) {
		fprintf(stderr, "invalid colour values\n");
		exit(EXIT_FAILURE);
	}
	e.bkg_col.r = (float)r / 255.0f;
	e.bkg_col.g = (float)g / 255.0f;
	e.bkg_col.b = (float)b / 255.0f;
	e.bkg_col.a = (float)a / 255.0f;
}

void tidal_set_font_colour(const int index, const int r, const int g, const int b, const int a) {
	if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 255) {
		fprintf(stderr, "invalid colour values\n");
		exit(EXIT_FAILURE);
	}
	e.ins[index].font_col = sfons_rgba(r, g, b, a);
}

void tidal_set_font_size(const int index, const float size) {
	if (size <= 0) fprintf(stderr, "font size must be greater than 0\n");
	e.ins[index].font_size = size;
}

void tidal_set_rotation(const int index, const float orient) {
	e.ins[index].orient = orient * M_PI / 180;
}

void tidal_quit() {
	sapp_quit();
}

const actions tidal = {
	.create = tidal_create,
	.set_size = tidal_set_size,
	.set_sprite = tidal_set_sprite,
	.set_shape = tidal_set_shape,
	.set_gravity = tidal_set_gravity,
	.set_pos = tidal_set_pos,
	.set_font = tidal_set_font,
	.set_text = tidal_set_text,
	.set_music = tidal_set_music,
	.set_cb_keydown = tidal_set_cb_keydown,
	.set_background_colour = tidal_set_background_colour,
	.set_font_colour = tidal_set_font_colour,
	.set_font_size = tidal_set_font_size,
	.set_rotation = tidal_set_rotation,
	.quit = tidal_quit,
};
