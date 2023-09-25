//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __FILESYSTEM_H__
#define __FILESYSTEM_H__

#include "common.h"

#include <SDL2/SDL.h>

int is_dir(const char*);
char** list_files(size_t*, const char*);

#endif
