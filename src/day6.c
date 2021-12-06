#include <genesis.h>
#include <resources.h>
#include <string.h>
#include <day6.h>
#include <utils.h>

void day6() {
    u16 line = 1;
    char buf[200];
    // solve
    startTimer(0);
    drawText("Solving day 6...", 1, line++);
    day6_answers result = day6_asm();
    sprintf(buf, "Solved day 6 in %lu ms", getTimer(0, FALSE) / SUBTICKPERMILLISECOND);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 1: %u", result.part1);
    drawText(buf, 1, line++);
    // sprintf(buf, "Part 2: %u", result.part2);
    // drawText(buf, 1, line++);
    drawText("Day 6 done, press START to go back", 1, line + 1);
}