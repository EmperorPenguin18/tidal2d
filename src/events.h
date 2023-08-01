//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __EVENTS_H__
#define __EVENTS_H__

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
	EVENTS_NUM
};
typedef enum event_t event_t;

#endif
