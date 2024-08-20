#ifndef __ACTIONS_H__
#define __ACTIONS_H__

#include <minilua.h>

#define FUNC_DEF(NAME) int tidal_##NAME(lua_State*);

#define FUNC_ENTRY(NAME) { #NAME, tidal_##NAME },

#define FUNC_LIST \
	X(create) \
	X(set_size) \
	X(set_sprite) \
	X(set_shape) \
	X(set_gravity) \
	X(set_pos) \
	X(set_font) \
	X(set_text) \
	X(set_music) \
	X(set_cb_keydown) \
	X(set_background_colour) \
	X(set_font_colour) \
	X(set_font_size) \
	X(set_rotation) \
	X(quit) \

#ifndef GBA

#define X(name) FUNC_DEF(name)
FUNC_LIST
#undef X

#define X(name) FUNC_ENTRY(name)
static const struct luaL_Reg actions[] = { \
	FUNC_LIST
	{NULL, NULL} \
};
#undef X

#endif //GBA

#endif //__ACTIONS_H__
