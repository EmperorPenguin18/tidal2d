#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include <sokol_gfx.h>
#include <sokol_gp.h>
#include <sokol_app.h>
#include <sokol_glue.h>
#define PHYSAC_STANDALONE
#include <physac.h>

#define NUM_INSTANCES PHYSAC_MAX_BODIES

extern const unsigned char data_array[];
extern const unsigned char data_info[];

static void frame(void) {
    int width = sapp_width(), height = sapp_height();
    float ratio = width/(float)height;

    sgp_begin(width, height);
    sgp_viewport(0, 0, width, height);
    sgp_project(-ratio, ratio, 1.0f, -1.0f);

    sgp_set_color(0.1f, 0.1f, 0.1f, 1.0f);
    sgp_clear();

    float time = sapp_frame_count() * sapp_frame_duration();
    float r = sinf(time)*0.5+0.5, g = cosf(time)*0.5+0.5;
    sgp_set_color(r, g, 0.3f, 1.0f);
    sgp_rotate_at(time, 0.0f, 0.0f);
    sgp_draw_filled_rect(-0.5f, -0.5f, 1.0f, 1.0f);

    sg_pass pass = {.swapchain = sglue_swapchain()};
    sg_begin_pass(&pass);
    sgp_flush();
    sgp_end();
    sg_end_pass();
    sg_commit();
}

static void init(void) {
    sg_desc sgdesc = {
        .environment = sglue_environment(),
    };
    sg_setup(&sgdesc);
    if (!sg_isvalid()) {
        fprintf(stderr, "Failed to create Sokol GFX context!\n");
        exit(-1);
    }

    sgp_desc sgpdesc = {0};
    sgp_setup(&sgpdesc);
    if (!sgp_is_valid()) {
        fprintf(stderr, "Failed to create Sokol GP context: %s\n", sgp_get_error_message(sgp_get_last_error()));
        exit(-1);
    }
}

static void cleanup(void) {
    sgp_shutdown();
    sg_shutdown();
}

sapp_desc sokol_main(int argc, char* argv[]) {
    (void)argc;
    (void)argv;
    return (sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .window_title = "Rectangle (Sokol GP)",
    };
}
