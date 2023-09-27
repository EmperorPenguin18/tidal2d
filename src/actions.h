//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __ACTIONS_H__
#define __ACTIONS_H__

#include "engine.h"

struct Action {
	void* args;
	void(*run)(Engine*, Instance*, void*);
};
//typedef is in instance.h

int action_init(Action*, zpl_json_object*, Asset*, const size_t);
void action_cleanup(Action*);

#endif
