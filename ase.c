#include <stdlib.h>
#include <stdio.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include <stb/stb_image_write.h>

struct ase_header {
	uint32_t file_size;
	uint16_t magic_number;
	uint16_t frames;
	uint16_t width;
	uint16_t height;
	uint16_t color_depth;
	uint32_t flags;
	uint16_t speed; //deprecated
	uint32_t ignore_0;
	uint32_t ignore_1;
	uint8_t transparent_idx;
	uint8_t ignore_2[3];
	uint16_t num_colors;
	uint8_t pixel_width;
	uint8_t pixel_height;
	int16_t x;
	int16_t y;
	uint16_t grid_width;
	uint16_t grid_height;
	uint8_t ignore_3[80];
};
typedef struct ase_header ase_header;

void ase_print_header(ase_header* header) {
	printf("file_size: %d\n", header->file_size);
	printf("magic_number: %#x\n", header->magic_number);
	printf("frames: %d\n", header->frames);
	printf("width: %d\n", header->width);
	printf("height: %d\n", header->height);
	printf("color_depth: %d\n", header->color_depth);
	printf("flags: %#x\n", header->flags);
	printf("speed: %d\n", header->speed);
	printf("ignore_0: %d\n", header->ignore_0);
	printf("ignore_1: %d\n", header->ignore_1);
	printf("transparent_idx: %d\n", header->transparent_idx);
	for (int n = 0; n < 3; n++) printf("ignore_2[%d]: %d\n", n, header->ignore_2[n]);
	printf("num_colors: %d\n", header->num_colors);
	printf("pixel_width: %d\n", header->pixel_width);
	printf("pixel_height: %d\n", header->pixel_height);
	printf("x: %d\n", header->x);
	printf("y: %d\n", header->y);
	printf("grid_width: %d\n", header->grid_width);
	printf("grid_height: %d\n", header->grid_height);
	for (int n = 0; n < 80; n++) printf("ignore_3[%d]: %d\n", n, header->ignore_3[n]);
}

struct ase_frame {
	uint32_t size;
	uint16_t magic_number;
	uint16_t chunks_old;
	uint16_t duration;
	uint8_t ignore_0[2];
	uint32_t chunks;
};
typedef struct ase_frame ase_frame;

void ase_print_frame(ase_frame* frame) {
	printf("size: %d\n", frame->size);
	printf("magic_number: %#x\n", frame->magic_number);
	printf("chunks_old: %d\n", frame->chunks_old);
	printf("duration: %d\n", frame->duration);
	for (int n = 0; n < 2; n++) printf("ignore_0[%d]: %d\n", n, frame->ignore_0[n]);
	printf("chunks: %d\n", frame->chunks);
}

struct ase_chunk {
	uint32_t size;
	uint16_t type;
	uint8_t* data;
};
typedef struct ase_chunk ase_chunk;

int main(int argc, char** argv) {
	ase_header header;
	if (argc > 1) {
		unsigned char* pixels = malloc(0);
		size_t pixels_size = 0;
		FILE* file = fopen(argv[1], "rb");
		fread(&header, sizeof(header), 1, file);
		int bpp = header.color_depth / 8;
		assert(bpp == 1 || bpp == 2 || bpp == 4);
		assert(header.magic_number == 0xA5E0);
		assert(header.ignore_0 == 0);
		assert(header.ignore_1 == 0);
		for (int n = 0; n < 80; n++) assert(header.ignore_3[n] == 0);
		for (uint16_t i = 0; i < header.frames; i++) {
			ase_frame frame;
			fread(&frame, sizeof(frame), 1, file);
			assert(frame.magic_number == 0xF1FA);
			assert(frame.chunks != 0);
			for (int n = 0; n < 2; n++) assert(frame.ignore_0[n] == 0);
			for (uint32_t j = 0; j < frame.chunks; j++) {
				ase_chunk chunk;
				fread(&chunk, sizeof(uint32_t)+sizeof(uint16_t), 1, file);
				assert(chunk.size >= 6);
				assert(chunk.type != 0);
				chunk.data = malloc(chunk.size-6);
				fread(chunk.data, chunk.size-6, 1, file);
				switch (chunk.type) {
				case 0x2007:
					//Color Profile Chunk
					break;
				case 0x2019:
					//Palette Chunk
					break;
				case 0x2004:
					//Layer Chunk
					break;
				case 0x2005:
					//Cel Chunk
					uint16_t layer_idx = *(chunk.data+0);
					int16_t x = *(chunk.data+2);
					int16_t y = *(chunk.data+4);
					uint8_t opacity = *(chunk.data+6);
					uint16_t cel_type = *(chunk.data+7);
					int16_t z_idx = *(chunk.data+9);
					switch (cel_type) {
					case 0: {
						//Raw Image Data
						pixels = realloc(pixels, pixels_size+(header.width*header.height*bpp));
						memcpy(pixels+pixels_size, chunk.data+20, header.width*header.height*bpp);
						pixels_size += header.width*header.height*bpp;
						break;
					}
					case 1: {
						//Linked cel
						break;
					}
					case 2: {
						//Compressed Image
						//TODO handle transparency
						int uncompressed_size = 0;
						char* uncompressed =
							stbi_zlib_decode_malloc(chunk.data+20,
							header.width*header.height*bpp, &uncompressed_size);
						pixels = realloc(pixels, pixels_size+uncompressed_size);
						memcpy(pixels+pixels_size, uncompressed, uncompressed_size);
						free(uncompressed);
						pixels_size += uncompressed_size;
						break;
					}
					case 3: {
						//Compressed Tilemap
						break;
					}
					default: {
						//Error
						exit(1);
						break;
					}
					}
					break;
				default:
					//Ignore others
					break;
				}
				free(chunk.data);
			}
		}
		assert(ftell(file) == header.file_size);
		fclose(file);
		assert(pixels_size == header.width*header.height*header.frames*bpp);
		stbi_write_png("test.png", header.width, header.height*header.frames, bpp, pixels, 0);
		free(pixels);
	}
	return 0;
};
