#ifndef __ACTIONS_H__
#define __ACTIONS_H__

typedef struct actions_t {
	int (*create)();
	void (*set_size)(const int, const int, const int);
	void (*set_sprite)(const int, const char*);
	void (*set_shape)(const int, const char*);
	void (*set_gravity)(const float, const float);
	void (*set_pos)(const int, const float, const float);
	void (*set_font)(const int, const char*);
	void (*set_text)(const int, const char*, ...);
	void (*set_music)(const char*);
	void (*set_cb_keydown)(void (*)(const int));
	void (*set_background_colour)(const int, const int, const int, const int);
	void (*set_font_colour)(const int, const int, const int, const int, const int);
	void (*set_font_size)(const int, const float);
	void (*set_rotation)(const int, const float);
	void (*quit)();
} actions;

#endif //__ACTIONS_H__
