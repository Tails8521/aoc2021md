    .globl day6_asm
day6_asm:
    movem.l d2/a2-a3, -(sp)
    move.l &DAY6_INPUT, a2
    moveq #0, d0
    moveq #'0', d1
    moveq #',', d2

    ;// push an array of 9 32bit counters
    ;// they will store how many fishes have their timer to this particular number of days (0-8)
    .rept 9
        move.l d0, -(sp)
    .endr

read_number:
    move.b (a2)+, d0 ;// read input
    sub.b d1, d0 ;// convert from ascii to digit
    ;// multiply d0 by 4 (since the counters are 32 bits)
    add.b d0, d0
    add.b d0, d0
    addq.l #1, 0(sp, d0.w) ;// add 1 to the counter of what we just read
    cmp.b (a2)+, d2 ;// is the next character a comma?
    beq.s read_number ;// if so, branch to read the next number

    move.l #80-1, d1 ;// 80 iterations
day_iter:
    move.l sp, a2 ;// src
    move.l sp, a3 ;// dest
    move.l (a2)+, d0 ;// d0 now holds how many were at 0 day
    move.l (a2)+, (a3)+ ;// 1 -> 0
    move.l (a2)+, (a3)+ ;// 2 -> 1
    move.l (a2)+, (a3)+ ;// 3 -> 2
    move.l (a2)+, (a3)+ ;// 4 -> 3
    move.l (a2)+, (a3)+ ;// 5 -> 4
    move.l (a2)+, (a3)+ ;// 6 -> 5
    move.l (a2)+, (a3)  ;// 7 -> 6
    add.l d0, (a3)+ ;// the 0 day ones return at 6 days
    move.l (a2)+, (a3)+  ;// 8 -> 7
    move.l d0, (a3) ;// new ones spawn at 8 days
    dbf d1, day_iter

    move.l sp, a2
    moveq #0, d0
    .rept 9
        add.l (a2)+, d0 ;// add all the numbers together
    .endr

    add.l #4*9, sp ;// pop the counter array off the stack
    movem.l (sp)+, d2/a2-a3
    rts

