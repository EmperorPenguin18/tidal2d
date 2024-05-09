#include "common.h"
#include "engine.h"

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
	e.ins[index].w = luaL_checknumber(L, 2);
	e.ins[index].h = luaL_checknumber(L, 3);
	return 0;
}

int tidal_set_sprite(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	const char* name = luaL_checkstring(L, 2);
	size_t offset;
	DATA_LOOP(offset,
		if (strcmp(name, basename(data_info+i)) == 0) break;
	);
	e.ins_rect[index].dst.w = e.ins[index].w;
	e.ins_rect[index].dst.h = e.ins[index].h;
	e.ins_rect[index].src.x = (offset-e.img_begin)/4;
	e.ins_rect[index].src.y = 0;
	e.ins_rect[index].src.w = e.ins_rect[index].dst.w;
	e.ins_rect[index].src.h = e.ins_rect[index].dst.h;
	return 0;
}

int tidal_set_shape(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	const char* shape = luaL_checkstring(L, 2);
	PhysicsBody body;
	if (body = GetPhysicsBody(index)) DestroyPhysicsBody(body);
	if (strcmp(shape, "box") == 0) {
		sgp_rect dst = e.ins_rect[index].dst;
		Vector2 pos = {dst.x, dst.y};
		body = CreatePhysicsBodyRectangle(pos, e.ins[index].w, e.ins[index].h, 1.0f);
	} else if (strcmp(shape, "wall") == 0) {
		sgp_rect dst = e.ins_rect[index].dst;
		Vector2 pos = {dst.x, dst.y};
		body = CreatePhysicsBodyRectangle(pos, e.ins[index].w, e.ins[index].h, 1.0f);
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
	e.ins_rect[index].dst.x = luaL_checknumber(L, 2);
	e.ins_rect[index].dst.y = luaL_checknumber(L, 3);
	return 0;
}

int tidal_set_font(lua_State* L) {
	int index = luaL_checkinteger(L, 1);
	const char* font = luaL_checkstring(L, 2);
	e.ins[index].font = fonsGetFontByName(e.fs, font);
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
	size_t offset;
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
