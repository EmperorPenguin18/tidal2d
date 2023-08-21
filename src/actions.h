//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __ACTIONS_H__
#define __ACTIONS_H__

struct Action;
typedef struct Action Action;

#include "common.h"
#include "engine.h"
#include "instance.h"

#include <zpl.h>

struct Action {
	void** args;
	int num;
	void (*run)(Engine*, Instance*, void*[]);
};

int action_init(Action*, zpl_json_object*, Asset*, const size_t);
void action_cleanup(Action*);

#endif
