#include <genesis.h>
#include <resources.h>
#include <string.h>
#include <day6.h>
#include <utils.h>

void day6() {
    u16 line = 1;
    char buf[200];
    char u64_result[30];
    // solve
    startTimer(0);
    drawText("Solving day 6...", 1, line++);
    day6_answers result = day6_asm();
    sprintf(buf, "Solved day 6 in %lu ms", getTimer(0, FALSE) / SUBTICKPERMILLISECOND);
    drawText(buf, 1, line++);
    u64ToStr(result.part1, u64_result);
    sprintf(buf, "Part 1: %s", u64_result);
    drawText(buf, 1, line++);
    u64ToStr(result.part2, u64_result);
    sprintf(buf, "Part 2: %s", u64_result);
    drawText(buf, 1, line++);
    drawText("Day 6 done, press START to go back", 1, line + 1);
}