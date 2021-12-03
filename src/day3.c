#include <genesis.h>
#include <resources.h>
#include <string.h>
#include <day3.h>
#include <utils.h>

void day3() {
    u16 line = 1;
    char buf[200];
    // solve
    startTimer(0);
    drawText("Solving day 3...", 1, line++);
    day3_answers result = day3_asm();
    sprintf(buf, "Solved day 3 in %lu ms", getTimer(0, FALSE) / SUBTICKPERMILLISECOND);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 1: %u", result.part1);
    drawText(buf, 1, line++);
    // sprintf(buf, "Part 2: %u", result.part2);
    // drawText(buf, 1, line++);
    drawText("Day 3 done, press START to go back", 1, line + 1);
}