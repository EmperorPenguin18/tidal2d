//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __ASSETS_H__
#define __ASSETS_H__

#include "common.h"
#include "zpl.h"

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

int asset_init(Asset*, const char*, void*, const size_t);
void asset_cleanup(Asset*);

#endif
