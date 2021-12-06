    .globl day6_asm
day6_asm:
    movem.l d2-d4/a2-a4, -(sp)
    move.l &DAY6_INPUT, a2
    moveq #0, d0
    moveq #'0', d1
    moveq #',', d2
    moveq #3, d3

    move.l sp, a4 ;// point after the array
    ;// push an array of 9 64bit counters
    ;// they will store how many fishes have their timer to this particular number of days (0-8)
    .rept 9
        move.l d0, -(sp)
        move.l d0, -(sp)
    .endr

read_number:
    move.b (a2)+, d0 ;// read input
    sub.b d1, d0 ;// convert from ascii to digit
    ;// multiply d0 by 8 (since the counters are 64 bits)
    lsl.b d3, d0
    ;// the displacement of 4 is there so we increment the least significant long of the counter (big endian)
    addq.l #1, 4(sp, d0.w) ;// add 1 to the counter of what we just read
    cmp.b (a2)+, d2 ;// is the next character a comma?
    beq.s read_number ;// if so, branch to read the next number

    moveq #80-1, d4 ;// 80 iterations
    move.l sp, a1
    jsr day_loop

    move.l a4, a2
    moveq #0, d0
    moveq #0, d1
    .rept 9
        ;// add all the numbers together
        add.l -(a2), d1 ;// add the lower 32 bits
        move.l -(a2), d2
        addx.l d2, d0 ;// add the upper 32 bits
    .endr
    move.l d0, (a0)+ ;// write part 1 upper long
    move.l d1, (a0)+ ;// write part 1 lower long
    
    move.l #256-80-1, d4 ;// remaining iterations
    move.l sp, a1
    jsr day_loop

    move.l a4, a2
    moveq #0, d0
    moveq #0, d1
    .rept 9
        ;// add all the numbers together
        add.l -(a2), d1 ;// add the lower 32 bits
        move.l -(a2), d2
        addx.l d2, d0 ;// add the upper 32 bits
    .endr
    move.l d0, (a0)+ ;// write part 2 upper long
    move.l d1, (a0)+ ;// write part 2 lower long

    move.l a4, sp ;// pop the counter array off the stack
    movem.l (sp)+, d2-d4/a2-a4
    rts

**************************************
* input: a1, array of counters
* input: d4, number of iterations - 1
* clobbered: a2, a3, d0, d1, d2, d4
**************************************
day_loop:
    move.l a1, a2 ;// src
    move.l a1, a3 ;// dest
    move.l (a2)+, d0 ;// d0 and d1 now hold how many were at 0 day
    move.l (a2)+, d1
    move.l (a2)+, (a3)+ ;// 1 -> 0
    move.l (a2)+, (a3)+ ;// 1 -> 0
    move.l (a2)+, (a3)+ ;// 2 -> 1
    move.l (a2)+, (a3)+ ;// 2 -> 1
    move.l (a2)+, (a3)+ ;// 3 -> 2
    move.l (a2)+, (a3)+ ;// 3 -> 2
    move.l (a2)+, (a3)+ ;// 4 -> 3
    move.l (a2)+, (a3)+ ;// 4 -> 3
    move.l (a2)+, (a3)+ ;// 5 -> 4
    move.l (a2)+, (a3)+ ;// 5 -> 4
    move.l (a2)+, (a3)+ ;// 6 -> 5
    move.l (a2)+, (a3)+ ;// 6 -> 5
    move.l (a2)+, (a3)+ ;// 7 -> 6
    move.l (a2)+, (a3)  ;// 7 -> 6

    ;// the 0 day ones return at 6 days
    add.l d1, (a3)+ ;// add the lower 32 bits
    move.l -8(a3), d2
    addx.l d0, d2 ;// add the upper 32bits
    move.l d2, -8(a3)

    move.l (a2)+, (a3)+  ;// 8 -> 7
    move.l (a2)+, (a3)+  ;// 8 -> 7
    move.l d0, (a3)+ ;// new ones spawn at 8 days
    move.l d1, (a3)
    dbf d4, day_loop
    rts