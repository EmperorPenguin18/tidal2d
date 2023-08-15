//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "filesystem.h"

#define ZPL_NANO
#include <zpl.h>

/* Create a listing of all items in a directory */
char[][] list_files(size_t* num, const char* path) {
	char[][] out = NULL;
	size_t n = 0;
	zpl_dir_info dir = {0};
	zpl_dirinfo_init(&dir, path);
	for (int i = 0; i < zpl_array_count(dir.entries); i++) {
		zpl_dir_entry* e = dir.entries + i;
		if (e->type == ZPL_DIR_TYPE_FILE) {
			(char**) tmp = realloc(out, (n+1)*sizeof(char*));
			if (!tmp) return NULL;
			out = tmp;
			out[n] = (char*)malloc(strlen(e->filename)+1);
			strcpy(out[n], e->filename);
			n++;
		}
	}
	zpl_dirinfo_free(&dir);
	*num = n;
	return out;
}
