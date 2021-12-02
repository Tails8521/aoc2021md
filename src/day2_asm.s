**************************************
* variables:
* a0: pointer to input
* a1: pointer to input end
* d0: current depth (part 1) and aim (part 2), returns part1 result
* d1: current depth (part 2), returns part2 result
* d2: current horizontal position
* d3: current character read
* d4: temporary
**************************************

    .globl day2_asm
day2_asm:
    movem.l d2-d4, -(sp)
    move.l &DAY2_INPUT, a0
    move.l &DAY2_INPUT_END - 1, a1
    moveq #0, d0
    moveq #0, d1
    moveq #0, d2
    moveq #0, d3
read_line:
    cmp.l a0, a1 ;// have we reached the end of the input?
    bls.s done ;// if so, branch
    move.b (a0)+, d3 ;// read first letter
    cmp.b #'d', d3 ;// is it down?
    beq.s down ;// if so, branch
    cmp.b #'f', d3 ;// is it forward?
    beq.s forward ;// if so, branch
up: ;// if we haven't branched yet, it's up
    addq.l #2, a0 ;// skip forward to the digit
    move.b (a0)+, d3 ;// read digit
    addq.l #1, a0 ;// skip newline
    sub.b #'0', d3 ;// convert from ascii to digit
    sub.w d3, d0 ;// update depth
    bra.s read_line
down:
    addq.l #4, a0 ;// skip forward to the digit
    move.b (a0)+, d3 ;// read digit
    addq.l #1, a0 ;// skip newline
    sub.b #'0', d3 ;// convert from ascii to digit
    add.w d3, d0 ;// update depth
    bra.s read_line
forward:
    addq.l #7, a0 ;// skip forward to the digit
    move.b (a0)+, d3 ;// read digit
    addq.l #1, a0 ;// skip newline
    sub.b #'0', d3 ;// convert from ascii to digit
    add.w d3, d2 ;// update horizontal position
    move.l d0, d4 ;// it is possible to do that without d4, using d3 instead of d4 to store the mulu result
    ;// but having d3 as the source operand is optimal here
    ;// as we know it won't have many bits sets, making the mulu faster
    mulu.w d3, d4 ;// X * aim
    add.l d4, d1 ;// depth += X * aim
    bra.s read_line
done:
    mulu.w d2, d0 ;// part1 result
    ;// at this point, d1 doesn't fit in 16bit so we can't rely on a simple mulu.w d2, d1 to get part2 result
    ;// Basically we need to do a 32x16 -> 32 multiplication rather than a 16x16 -> 32 one
    move.l d1, d3
    swap d3 ;// select the high word of the depth
    mulu.w d2, d3 ;// multiply the high word of the depth
    swap d3 ;// We need to multiply the result by 65536
    mulu.w d2, d1 ;// part2 result (bottom 16 bits)
    add.l d3, d1 ;// add the top 16 bits to it
    movem.l (sp)+, d2-d4
    rts
