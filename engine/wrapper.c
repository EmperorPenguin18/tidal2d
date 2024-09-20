#include "actions.h"

#ifndef FILENAME
#define FILENAME "script.c"
#endif

extern const actions tidal;

//static void run() {
#include FILENAME
//}

void register_script(void (*)());

__attribute((constructor))
static void constructor() {
	register_script(script);
}
