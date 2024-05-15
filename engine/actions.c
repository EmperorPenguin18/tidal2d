#include "common.h"
#include "engine.h"

#include <math.h>

extern engine e;
void mix(const void*, size_t);

int tidal_create(lua_State* L) {
	if (e.ins_num == NUM_INSTANCES) return luaL_error(L, "reached max instances");
	e.ins_num++;
	lua_pushinteger(L, e.ins_num-1);
	return 1;
}

int tidal_set_size(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	e.ins[index].rect.dst.w = luaL_checknumber(L, 2);
	e.ins[index].rect.dst.h = luaL_checknumber(L, 3);
	return 0;
}

int tidal_set_sprite(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	const char* name = luaL_checkstring(L, 2);
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
	return 0;
}

int tidal_set_shape(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	const char* shape = luaL_checkstring(L, 2);
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
		return luaL_error(L, "incorrect shape name");
	}
	return 0;
}

int tidal_set_gravity(lua_State* L) {
	float x = luaL_checknumber(L, 1);
	float y = luaL_checknumber(L, 2);
	SetPhysicsGravity(x, y);
	return 0;
}

int tidal_set_pos(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	e.ins[index].rect.dst.x = luaL_checknumber(L, 2);
	e.ins[index].rect.dst.y = luaL_checknumber(L, 3);
	return 0;
}

int tidal_set_font(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	const char* font = luaL_checkstring(L, 2);
	e.ins[index].font = fonsGetFontByName(e.fs, font);
	e.ins[index].font_size = 16.0f;
	e.ins[index].font_col = sfons_rgba(0, 0, 0, 255);
	return 0;
}

int tidal_set_text(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	const char* string = luaL_checkstring(L, 2);
	if (strlen(string) > 63) return luaL_error(L, "text too long");
	strcpy(e.ins[index].str, string);
	return 0;
}

int tidal_set_music(lua_State* L) {
	const char* name = luaL_checkstring(L, 1);
	uint64_t offset;
	DATA_LOOP(offset,
		if (strcmp(name, basename(data_info+i)) == 0) {
			e.music_offset = offset;
			e.music_len = size;
			e.music_pos = 0;
			break;
		}
	);
	return 0;
}

static void register_callback(lua_State* L, sapp_event_type type) {
	e.events[type] = luaL_ref(L, LUA_REGISTRYINDEX);
}

int tidal_set_cb_keydown(lua_State* L) {
	if (!lua_isfunction(L, 1)) return luaL_error(L, "must call back to a function");
	register_callback(L, SAPP_EVENTTYPE_KEY_DOWN);
	return 0;
}

int tidal_set_background_colour(lua_State* L) {
	int r = luaL_checkinteger(L, 1);
	int g = luaL_checkinteger(L, 2);
	int b = luaL_checkinteger(L, 3);
	int a = luaL_checkinteger(L, 4);
	if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 255)
		return luaL_error(L, "invalid colour values");
	e.bkg_col.r = (float)r / 255.0f;
	e.bkg_col.g = (float)g / 255.0f;
	e.bkg_col.b = (float)b / 255.0f;
	e.bkg_col.a = (float)a / 255.0f;
	return 0;
}

int tidal_set_font_colour(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	int r = luaL_checkinteger(L, 2);
	int g = luaL_checkinteger(L, 3);
	int b = luaL_checkinteger(L, 4);
	int a = luaL_checkinteger(L, 5);
	if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 255)
		return luaL_error(L, "invalid colour values");
	e.ins[index].font_col = sfons_rgba(r, g, b, a);
	return 0;
}

int tidal_set_font_size(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	float size = luaL_checknumber(L, 2);
	if (size <= 0) return luaL_error(L, "font size must be greater than 0");
	e.ins[index].font_size = size;
	return 0;
}

int tidal_set_rotation(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	e.ins[index].orient = luaL_checknumber(L, 2) * M_PI / 180;
	return 0;
}

int tidal_quit(lua_State* L) {
	sapp_quit();
	return 0;
}
