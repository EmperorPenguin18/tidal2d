//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#include <string.h>
#include <stdlib.h>
#include <SDL_rwops.h>
#include <zpl.h>

#include "common.h"

#include "filesystem.h"

/* Checks if the path provided is a directory or a file. */
int is_dir(const char* path) {
	SDL_RWops* rw = SDL_RWFromFile(path, "rb+");
	if (!rw) return 1;
	return 0;
}

/* Create a listing of all items in a directory */
char** list_files(size_t* num, const char* path) {
	char** out = NULL;
	*num = 0;
	zpl_dir_info dir = {0};
	zpl_dirinfo_init(&dir, path);
	for (int i = 0; i < zpl_array_count(dir.entries); i++) {
		zpl_dir_entry* e = dir.entries + i;
		if (e->type == ZPL_DIR_TYPE_FILE) {
			char** tmp = realloc(out, (*num+1)*sizeof(char*));
			if (!tmp) {
				ERROR("Out of memory");
				return NULL;
			}
			out = tmp;
			out[*num] = (char*)malloc(strlen(e->filename)+1);
			strcpy(out[*num], e->filename);
			(*num)++;
		}
	}
	zpl_dirinfo_free(&dir);
	return out;
}
