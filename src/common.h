//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __COMMON_H__
#define __COMMON_H__

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

/* The different event types. Used when defining objects and by
 * the event handler.
 */
enum event_t {
	TIDAL_EVENT_COLLISION,
	TIDAL_EVENT_QUIT,
	TIDAL_EVENT_KEYW,
	TIDAL_EVENT_KEYA,
	TIDAL_EVENT_KEYS,
	TIDAL_EVENT_KEYD,
	TIDAL_EVENT_KEYSPACE,
	TIDAL_EVENT_KEYENTER,
	TIDAL_EVENT_MOUSELEFT,
	TIDAL_EVENT_MOUSERIGHT,
	TIDAL_EVENT_CREATION,
	TIDAL_EVENT_DESTRUCTION,
	TIDAL_EVENT_CHECKUI,
	TIDAL_EVENT_LEAVE,
	EVENTS_NUM,
	TIDAL_EVENT_ERR
};
typedef enum event_t event_t;

const char* getextension(const char*);
const char* basename(const char*);
char* gen_uuid();
event_t str2ev(const char*);

#endif
