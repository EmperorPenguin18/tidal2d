//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#ifndef __ASSETS_H__
#define __ASSETS_H__

/* Asset definition. Name is the file name
 * which will be unique and data can be anything.
 * Also has two function pointers, which will be
 * set based on the type of asset.
 */
struct Asset {
	char* name;
	void* data;
	int (*create)(void**, const unsigned char*);
	void (*destroy)();
};
typedef struct Asset Asset;

#endif
