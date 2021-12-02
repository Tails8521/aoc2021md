#include <genesis.h>
#include <resources.h>
#include <string.h>
#include <day2.h>
#include <utils.h>

void day2() {
    u16 line = 1;
    char buf[200];
    // solve
    startTimer(0);
    drawText("Solving day 2...", 1, line++);
    day2_answers result = day2_asm();
    sprintf(buf, "Solved day 2 in %lu ms", getTimer(0, FALSE) / SUBTICKPERMILLISECOND);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 1: %u", result.part1);
    drawText(buf, 1, line++);
    sprintf(buf, "Part 2: %u", result.part2);
    drawText(buf, 1, line++);
    drawText("Day 2 done, press START to go back", 1, line + 1);
}