**************************************
* variables:
* a0: pointer to writeable memory for part2
* a1: pointer to the start of writeable memory for part2
* a2: pointer to input
* a3: pointer to input end
* d0: upper word: part1 result, lower word: part2 result
* d1: current decimal digit for part1, loop counter for part2
* d2: current value
* d3: previous value
**************************************

    .globl day1_asm
day1_asm:
    move.l 4(sp), a0
    move.l a0, a1
    movem.l d2-d3/a2-a3, -(sp)
    move.l &DAY1_INPUT, a2
    move.l &DAY1_INPUT_END - 1, a3
    moveq #0, d0
    moveq #0, d1
    moveq #0xFFFFFFFF, d3
read_line:
    cmp.l a2, a3 // have we reached the end of the input?
    bls.s part2 // if so, branch
    moveq #0, d2
read_char:
    move.b (a2)+, d1 // read input
    cmp.b #'\n', d1 // have we reached the end of the line?
    beq.s done_line // if so, branch
    sub.b #'0', d1 // convert from ascii to digit
    mulu.w #10, d2 // decimal shift
    add.w d1, d2 // add the digit to the current value
    bra.s read_char // read next char
done_line:
    move.w d2, (a0)+ // store the number we read for part2
    cmp.w d3, d2 // has the measurment increased?
    bls.s not_increased
    addq.w #1, d0
not_increased:
    move.w d2, d3 // previous = current
    bra.s read_line

part2:
    moveq #0xFFFFFFFF, d3
    sub.l a1, a0 // how much many values have we stored? (*2 because we store them as words)
    move.l a0, d1
    lsr.w #1, d1 // we divide by 2 to get the value count
    subq.w #3, d1 // minus 2 iterations because of the sliding window of 3, minus 1 because of dbf loop
    swap d0 // stash part1 result in the upper word of d0
loop:
    move.w (a1)+, d2
    add.w (a1), d2
    add.w 2(a1), d2
    cmp.w d3, d2 // has the measurment increased?
    bls.s window_not_increased
    addq.w #1, d0
window_not_increased:
    move.w d2, d3 // previous = current
    dbf d1, loop
    movem.l (sp)+, d2-d3/a2-a3
    rts
