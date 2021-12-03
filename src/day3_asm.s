    .globl day3_asm
day3_asm:
    movem.l d2-d6/a2, -(sp)
    move.l &DAY3_INPUT, a0
    move.l a0, a1
    move.l sp, a2
    moveq #0, d0
    move.b #'\n', d6
    ;// calculate the length of a line
line_len_calc:
    addq.w #1, d0
    cmp.b (a0)+, d6 ;// is it a newline?
    bne.s line_len_calc ;// if not, loop back
    move.l a1, a0
    move.l &DAY3_INPUT_END, d1
    sub.l &DAY3_INPUT, d1
    divu.w d0, d1
    subq.w #2, d0 ;// remove the newline from the count and 1 for dbf adjust
    ;// d0 now holds the number of digits per line - 1
    ;// d1 now holds the number of lines
    move.l d0, d2
    moveq #0, d3
array_init_loop: ;// fill the array with zeroes
    move.w d3, -(sp)
    dbf d2, array_init_loop
    subq.l #1, a0 ;// fake newline we'll instantly skip
    move.l d1, d4
    subq.w #1, d4 ;// remove 1 for dbf adjust

    move.b #'0', d6
read_line:
    move.l d0, d2 ;// reset back the inner loop counter
    move.l sp, a1 ;// move the pointer to the front of the array
    addq.l #1, a0 ;// skip newline
read_char:
    move.b (a0)+, d3 ;// read char
    sub.b d6, d3 ;// convert from ascii to digit
    add.w d3, (a1)+ ;// add and store in the array
    dbf d2, read_char
    dbf d4, read_line

    move.l d1, d4
    lsr.w #1, d4 ;// half the number of lines
    move.l d0, d2
    moveq #0, d3 ;// this will hold gamma
    moveq #0, d5 ;// this will hold epsilon's mask
    move.l sp, a1 ;// move the pointer to the front of the array
compute_gamma:
    add.w d3, d3 ;// shift gamma left
    add.w d5, d5 ;// shift epsilon's mask left
    cmp.w (a1)+, d4 ;// is it over half the number of lines?
    blo.s skip_add;// if not, skip adding to gamma
    addq #1, d3
skip_add:
    addq #1, d5 ;// fill epsilon's mask
    dbf d2, compute_gamma
    move.w d3, d0
    not.w d0 ;// epsilon is just gamma with the bits flipped
    ;// but we still need to mask excess bits from epsilon, as it's less than 16 bits
    and.w d5, d0
    mulu.w d3, d0 ;// gamma * epsilon
    move.l a2, sp
    movem.l (sp)+, d2-d6/a2
    rts
