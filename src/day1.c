#include <genesis.h>
#include <resources.h>
#include <string.h>
#include <day1.h>
#include <utils.h>

void day1() {
    u16 line = 1;
    char buf[200];
    // solve
    startTimer(0);
    drawText("Solving day 1...", 1, line++);
    void *memory = MEM_alloc(32768);
    u32 result = day1_asm(memory);
    sprintf(buf, "Solved day 1 in %lu ms", getTimer(0, FALSE) / SUBTICKPERMILLISECOND);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 1: %u", result >> 16);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 2: %u", result & 0xFFFF);
    drawText(buf, 1, line++);
    drawText("Day 1 done, press START to go back", 1, line + 1);
    MEM_free(memory);
}