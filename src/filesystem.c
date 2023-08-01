//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "filesystem.h"

/* Basic reading data from file in virtual file system */
unsigned char* read_data(const char* path, size_t* len) {
	PHYSFS_File* file = P_openRead(path);
	if (file == NULL) return NULL;
	*len = P_fileLength(file);
	if (*len == -1) return NULL;
	unsigned char* data = (unsigned char*)calloc(*len+1, 1);
	if (data == NULL) return NULL;
	P_readBytes(file, data, *len);
	if (P_close(file) == 0) return NULL;
	return data;
}

/* Create a listing of all items in a directory */
char** list_files(const char* path) {
}

/* Create a listing of all items in embedded
 * binary.
 */
char** list_memory() {
}

