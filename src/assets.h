//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __ASSETS_H__
#define __ASSETS_H__

#include <zpl.h>

#include "common.h"

/* Asset definition. Name is the file name
 * which will be unique and data can be anything.
 * Also has two function pointers, which will be
 * set based on the type of asset.
 */
struct Asset {
	char* name;
	void* data;
	int (*create)(void**, void*, const size_t);
	void (*destroy)(void*);
};
typedef struct Asset Asset;

struct json {
	zpl_json_object* root;
	char* raw;
};
typedef struct json json;

struct font {
	void* data;
	size_t len;
};
typedef struct font font;

int asset_init(Asset*, const char*, void*, const size_t);
void asset_cleanup(Asset*);

#endif
