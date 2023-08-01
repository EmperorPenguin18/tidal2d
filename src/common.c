//Tidalpp by Sebastien MacDougall-Landry
//License is available at
//https://github.com/EmperorPenguin18/tidalpp/blob/main/LICENSE

#include "common.h"

const char* getextension(const char* filename) {
	const char *dot = strrchr(filename, '.');
	if (!dot || dot == filename) return "";
	return dot + 1;
}

/* Get the number of digits in an int */
/*static int findn(int num) {
	if (num == 0) return 1;
	int n = 0;
	while (num) {
		num /= 10;
		n++;
	}
	return n;
}*/

/* UUIDs are used to identify an instance, because two instances
 * could be based on the same object.
 */
char* gen_uuid() {
	char v[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
	//3fb17ebc-bc38-4939-bc8b-74f2443281d4
	//8 dash 4 dash 4 dash 4 dash 12
	char* buf = (char*)calloc(37, 1);
	
	//gen random for all spaces because lazy
	for(int i = 0; i < 36; ++i) {
		buf[i] = v[rand()%16];
	}
	
	//put dashes in place
	buf[8] = '-';
	buf[13] = '-';
	buf[18] = '-';
	buf[23] = '-';
	
	//needs end byte
	buf[36] = '\0';
	
	return buf;
}
