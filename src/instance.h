//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __INSTANCE_H__
#define __INSTANCE_H__

/* Instance definition. These are organized into layers
 * and looped over frequently. Could definitely use some
 * optimization
 */
struct Instance {
	char* id;
	SDL_Rect dst;
	SDL_Texture* texture;
	Font* font;
	const char* text;
	cpBody* body;
	cpShape* shape;
	size_t layer;
};
typedef struct Instance Instance;

#endif

