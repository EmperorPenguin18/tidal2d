//Tidal2D by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidal2d/blob/main/LICENSE

#ifndef __COMMON_H__
#define __COMMON_H__

//#define ERROR() __FILE__ __LINE__

const char* getextension(const char*);
const char* base(const char*);
char* gen_uuid();
int ERROR(const char*, ...);

#endif
