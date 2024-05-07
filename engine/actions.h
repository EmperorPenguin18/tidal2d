#ifndef __ACTIONS_H__

#include <minilua.h>

int tidal_create(lua_State*);
int tidal_set_size(lua_State*);
int tidal_set_sprite(lua_State*);
int tidal_set_shape(lua_State*);

static const struct luaL_Reg actions[] = {
	{"create", tidal_create},
	{"set_size", tidal_set_size},
	{"set_sprite", tidal_set_sprite},
	{"set_shape", tidal_set_shape},
	{NULL, NULL}
};

#endif
