#include <genesis.h>
#include <resources.h>
#include <utils.h>
#include <day1.h>
#include <day2.h>
#include <day3.h>
#include <day4.h>
#include <day6.h>

#define PLANE_W 64
#define PLANE_H 32

#define INITIAL_FISH 20
#define MAX_FISH 40
#define FISH_DELAY 64

typedef enum {
    NONE = 0,
    DOWN,
    UP,
    START
} KeyPressed;

typedef enum {
    MENU = 0,
    DAY
} ProgramState;

typedef struct Fish {
    Sprite* sprite;
    union {
        struct {
            s16 x_pixels;
            u16 x_subpixels;
        };
        s32 x_position;
    };
    union {
        struct {
            s16 y_pixels;
            u16 y_subpixels;
        };
        s32 y_position;
    };
    s32 x_speed;
    s32 y_speed;
    s16 life_stage;
    s16 delay;
    bool enabled;
    bool initial;
} Fish;

u16 frame_counter;
s16 horizontal_scroll_array[28];
u16 vertical_scroll_speedup_threshold[20];
s16 bottom_text_horizontal_scroll;
s16 cloud_layer_1_horizontal_scroll;
s16 cloud_layer_2_horizontal_scroll;
s16 waves_far_horizontal_scroll;
s16 waves_near_horizontal_scroll;
Fish fish_array[MAX_FISH];
u16 controller_state;
u16 controller_changed;

s16 selected_item;
KeyPressed key_pressed;
ProgramState program_state;

void joyCallback(u16 joy, u16 changed, u16 state);
void setScroll();
void draw_menu();
void clear_screen();


void (*const days_fcts[])() = {
    &day1,
    &day2,
    &day3,
    &day4,
    &day6,
};

void joyCallback(u16 joy, u16 changed, u16 state) {
    if (joy == JOY_1) {
        controller_changed = changed;
        if (~controller_state & controller_changed & BUTTON_DOWN) {
            key_pressed = DOWN;
        } else if (~controller_state & controller_changed & BUTTON_UP) {
            key_pressed = UP;
        } else if (~controller_state & controller_changed & BUTTON_BTN) {
            key_pressed = START;
        }
        controller_state = state;
    }
}

void init_fish_array() {
    for (u16 i = 0; i < MAX_FISH; i++) {
        if (i < INITIAL_FISH) {
            fish_array[i].enabled = TRUE;
            fish_array[i].initial = TRUE;
            fish_array[i].sprite = SPR_addSpriteEx(&fish_sprite, 128, -64, TILE_ATTR(PAL1, 0, 0, 0), 0, SPR_FLAG_AUTO_SPRITE_ALLOC);
        } else {
            fish_array[i].enabled = FALSE;
            fish_array[i].initial = FALSE;
            fish_array[i].sprite = SPR_addSpriteEx(&fish_sprite, 128, -64, TILE_ATTR(PAL1, 0, 0, 0), 0, SPR_FLAG_AUTO_SPRITE_ALLOC);
        }
        fish_array[i].x_pixels = random() % 352 - 32;
        fish_array[i].y_pixels = 0;
        fish_array[i].x_speed = 0x10000;
        fish_array[i].y_speed = 0;
        fish_array[i].delay = FISH_DELAY;
        fish_array[i].life_stage = random() % 8;
        SPR_setVRAMTileIndex(fish_array[i].sprite, TILE_USERINDEX);
    }
    
}

void respawn_fish(Fish* fish) {
    if (! fish->initial) {
        // don't respawn
        fish->enabled = FALSE;
        SPR_setPosition(fish->sprite, -32, -32);
        return;
    }
    fish->x_position = -32 * 0x10000;
    fish->y_position = (random() % 128 + 64) * 0x10000;
    SPR_setPosition(fish->sprite, fish->x_pixels, fish->y_pixels);
    fish->delay = random() % FISH_DELAY + 1;
    fish->life_stage = random() % 8;
    fish->x_speed = random() / 2 + 0x10000;
    fish->y_speed = random() * 2 - 0x10000;
}

void reproduce_fish(Fish* fish) {
    fish->life_stage = 6;
    for (u16 i = INITIAL_FISH; i < MAX_FISH; i++) {
        if (! fish_array[i].enabled) {
            fish_array[i].enabled = TRUE;
            fish_array[i].delay = FISH_DELAY;
            fish_array[i].life_stage = 9;
            fish_array[i].x_position = fish->x_position - 0x100000;
            fish_array[i].y_position = fish->y_position;
            fish_array[i].x_speed = fish->x_speed - 0x1000;
            fish_array[i].y_speed = fish->y_speed + 0x10000;
            fish->y_speed -= 0x10000;
            return;
        }
    }
}

void tick_fish(Fish* fish) {
    if (fish->enabled == FALSE) {
        return;
    }
    if (--fish->delay == 0) {
        if (--fish->life_stage < 0) {
            reproduce_fish(fish);
        }
        SPR_setVRAMTileIndex(fish->sprite, TILE_USERINDEX + 12 * fish->life_stage);
        fish->delay = FISH_DELAY;
    }
    fish->x_position += fish->x_speed;
    fish->y_position += fish->y_speed;
    if (fish->x_pixels > 320) {
        respawn_fish(fish);
        return;
    }
    if (fish->y_pixels < 64 || fish->y_pixels > 208) {
        fish->y_speed = -fish->y_speed;
    }
    SPR_setPosition(fish->sprite, fish->x_pixels, fish->y_pixels);
}

void tick_fish_array() {
    for (u16 i = 0; i < MAX_FISH; i++) {
        tick_fish(&fish_array[i]);
    }
}

void setScroll() {
    frame_counter++;

    if (frame_counter % 2 == 0) {
        waves_far_horizontal_scroll++;
        horizontal_scroll_array[5] = waves_far_horizontal_scroll;
        if (frame_counter % 4 == 0) {
            if (frame_counter % 8 == 0) {
                cloud_layer_2_horizontal_scroll++;
                horizontal_scroll_array[3] = cloud_layer_2_horizontal_scroll;
                horizontal_scroll_array[4] = cloud_layer_2_horizontal_scroll;
            }
            cloud_layer_1_horizontal_scroll++;
            horizontal_scroll_array[0] = cloud_layer_1_horizontal_scroll;
            horizontal_scroll_array[1] = cloud_layer_1_horizontal_scroll;
            horizontal_scroll_array[2] = cloud_layer_1_horizontal_scroll;
        }
    }
    waves_near_horizontal_scroll++;
    horizontal_scroll_array[6] = waves_near_horizontal_scroll;
    horizontal_scroll_array[7] = waves_near_horizontal_scroll;
    VDP_setHorizontalScrollTile(BG_B, 0, horizontal_scroll_array, 8, DMA);

    bottom_text_horizontal_scroll--;
    VDP_setHorizontalScrollTile(BG_A, 27, &bottom_text_horizontal_scroll, 1, CPU);

    tick_fish_array();
    SPR_update();
    DMA_flushQueue();
}

void draw_menu() {
    for (u16 i = 0; i < 5; i++) {
        char buf[70];
        if (i == 4) {
            sprintf(buf, "Day  6");
        } else {
            sprintf(buf, "Day %2u", i + 1);
        }
        drawText(buf, 10, i + 1);
    }
}

void clear_screen() {
    SYS_disableInts();
    VDP_clearTextArea(0, 0, 40, 27);
    SYS_enableInts();
}

int main() {
    VDP_setEnable(FALSE);
    SYS_disableInts();
    // SYS_showFrameLoad();
    VDP_setTextPlane(BG_A);
    VDP_setTextPriority(1);
    VDP_setTextPalette(PAL0);
    VDP_setPlaneSize(PLANE_W, PLANE_H, TRUE);
    VDP_clearPlane(BG_A, TRUE);
    VDP_clearPlane(BG_B, TRUE);
    VDP_setScrollingMode(HSCROLL_TILE, VSCROLL_PLANE);
    PAL_setPaletteColors(0, aoc2021bg.palette, DMA);
    SPR_init();
    for (u16 i = 0; i < 9; i++) {
        VDP_loadTileSet(fish_sprite.animations[0]->frames[i]->tileset, curTileInd, DMA);
        curTileInd += 12;
    }
    VDP_drawImage(BG_B, &aoc2021bg, 0, 0);
    init_fish_array();
    for (u16 i = 0; i < 320; i++) {
        tick_fish_array();
    }
    SPR_update();
    VDP_drawText("Advent of Code 2021 on a Sega MegaDrive, by Tails8521 :)", 0, 27);
    SYS_setVIntCallback(&setScroll);
    JOY_setEventHandler(&joyCallback);
    draw_menu();
    VDP_setEnable(TRUE);
    SYS_enableInts();
    while(TRUE) {
        if (program_state == MENU) {
            switch (key_pressed) {
            case DOWN:
                selected_item++;
                if (selected_item > 4) {
                    selected_item = 0;
                }
                break;
            case UP:
                selected_item--;
                if (selected_item < 0) {
                    selected_item = 4;
                }
                break;
            case START:
                if (days_fcts[selected_item]) {
                    program_state = DAY;
                    key_pressed = NONE;
                    clear_screen();
                    days_fcts[selected_item]();
                    MEM_pack();
                    continue;
                }
                break;
            default:
                break;
            }
            key_pressed = NONE;
            for (u16 i = 0; i < 6; i++) {
                if (i == selected_item) {
                    drawText(">", 8, i + 1);
                } else {
                    clearText(8, i + 1, 1);
                }
            }
        }
        else {
            switch (key_pressed) {
            case START:
                program_state = MENU;
                clear_screen();
                draw_menu();
                break;
            default:
                break;
            }
            key_pressed = NONE;
        }
        SYS_doVBlankProcess();
    }
    return 0;
}

