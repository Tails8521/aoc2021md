#include <genesis.h>
#include <resources.h>
#include <string.h>
#include <day4.h>
#include <utils.h>

void day4() {
    u16 line = 1;
    char buf[200];
    // solve
    startTimer(0);
    drawText("Solving day 4...", 1, line++);
    void *memory = MEM_alloc(32768);
    day4_answers result = day4_asm(memory);
    sprintf(buf, "Solved day 4 in %lu ms", getTimer(0, FALSE) / SUBTICKPERMILLISECOND);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 1: %u", result.part1);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 2: %u", result.part2);
    drawText(buf, 1, line++);
    drawText("Day 4 done, press START to go back", 1, line + 1);
    MEM_free(memory);
}