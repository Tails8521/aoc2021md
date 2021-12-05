    .globl day4_asm
day4_asm:
    move.l 4(sp), a0
    move.l a0, a1
    movem.l d2-d7/a2-a6, -(sp)
    move.l &DAY4_INPUT, a4
    move.l &DAY4_INPUT_END - 1, a5
    moveq #0, d0
    moveq #0, d1
    moveq #0xFFFFFFFF, d3
read_number:
    moveq #0, d2
read_char:
    move.b (a4)+, d1 ;// read input
    cmp.b #',', d1 ;// have we reached the end of the current number?
    beq.s done_number ;// if so, store the current number and read the next one
    cmp.b #'\n', d1 ;// have we reached the end of the line?
    beq.s done_numbers ;// if so, move on to the next parsing task
    sub.b #'0', d1 ;// convert from ascii to digit
    mulu.w #10, d2 ;// decimal shift
    add.w d1, d2 ;// add the digit to the current value
    bra.s read_char ;// read next char
done_number:
    move.b d2, (a1)+ ;// store the number
    bra.s read_number ;// read the next one

done_numbers:
    move.b d2, (a1)+ ;// store the last number
    move.l a1, a2
    moveq #-1, d3 ;// counts how many boards -1 we have
read_boards:
    addq.l #1, a4 ;// skip newline
    cmp.l a4, a5 ;// have we reached the end of the input?
    bls.w done_boards ;// if so, branch
    .rept 25
        moveq #0, d1
        moveq #0, d2
        move.b (a4)+, d1 ;// read input
        cmp.b #' ', d1 ;// space is like a zero
        beq.s 1f ;// skip forward to the second digit
        sub.b #'0', d1 ;// convert from ascii to digit
        mulu.w #10, d1 ;// decimal shift
        add.b d1, d2
    1:
        add.b (a4)+, d2
        sub.b #'0', d2 ;// convert from ascii to digit
        move.b d2, (a2)+ ;// store number
        addq.l #1, a4 ;// skip space or newline
    .endr
    addq.w #1, d3
    bra.w read_boards

done_boards:
    move.l a2, a3
    move.l d3, d2
    moveq #0, d1
fill_loop: ;// initialize the markers at 0
    .rept 25
        move.b d1, (a3)+
    .endr
    dbf d3, fill_loop
    
    move.l d2, d4
    addq.w #1, d4
    moveq #0, d5
    ;// We parsed everything from the input and everything important is in RAM
    ;// Variables at this point:
    ;// a0: pointer to the bingo numbers array
    ;// a1: pointer to the bingo boards array
    ;// a2: pointer to the bingo boards marker array: 0 = not marked, 1 = marked
    ;// d2: how many boards we have - 1
    ;// d4: how many boards remaining to win
    ;// d5: have we found a winner yet?
draw_number:
    move.b (a0)+, d1
    move.l a1, a3
    move.l a2, a4
    move.l d2, d7
loop_boards: ;// fill the markers for the drawn number
    tst.b (a3) ;// has this board already won?
    blt skip_draw_number_board ;// if so, skip drawing the number for it
    jsr draw_number_board
continue_skip_draw_number_board:
    dbf d7, loop_boards
    move.l a1, a3
    move.l a2, a4
    move.l d2, d7
loop_boards_victory: ;// check the markers for victory
    move.l a4, a6 ;// backup of the pointer to the current marker array
    tst.b (a3) ;// has this board already won?
    blt skip_check_victory_board ;// if so, skip checking if it won
    jsr check_victory_board
    beq.s found_winner
continue_skip_check_victory_board:
continue_found_winner:
    add.l #25, a3 ;// point to next board
    dbf d7, loop_boards_victory
    bra.s draw_number

found_winner:
    ;// Fixes up a4 since check_victory_board returns early if it finds a winner
    move.l a6, a4
    add.l #25, a4

    tst.b d5 ;// was there a winner already?
    beq.s first_winner
continue_first_winner:
    subq.w #1, d4
    beq.s last_winner
    move.b #-1, (a3) ;// mark the board as already won
    bra.s continue_found_winner
last_winner:
    jsr calculate_winning_score
    move.w d0, d1
    move.w d6, d0
    movem.l (sp)+, d2-d7/a2-a6
    rts

first_winner:
    moveq #1, d5
    movem.l d2/a3/a6, -(sp)
    jsr calculate_winning_score
    movem.l (sp)+, d2/a3/a6
    move.w d0, d6 ;// stash the first winner (for part 1) in d6
    bra.s continue_first_winner

skip_draw_number_board:
    add.l #25, a3 ;// point to next board
    add.l #25, a4 ;// points to next board
    bra.s continue_skip_draw_number_board

skip_check_victory_board:
    add.l #25, a4 ;// points to next board
    bra.s continue_skip_check_victory_board

**************************************
* input: d1
* modified: a3, now points to the next board bingo numbers
* modified: a4, now points to the next board bingo markers
**************************************
draw_number_board:
    .rept 25
        cmp.b (a3)+, d1
        bne.s 1f
        move.b #1, (a4)+
        bra.s 2f
    1:
        addq.l #1, a4
    2:
    .endr
    rts

**************************************
* returns 0 in d0 if winning input, also sets the zero flag in the CCR
* clobbered: a5
* modified: a4, now points to the next board bingo markers (if not winning)
**************************************
check_victory_board:
    move.l a4, a5
    ;// check columns
    .rept 5
        moveq #5, d0
        .rept 5
            sub.b (a4), d0
            addq.l #5, a4
        .endr
        bne.s 1f ;// do we still have at least a number that isn't marked?
        rts ;// we don't, return
    1: ;// we do, check the next column
        sub.l #(25-1), a4
    .endr
    move.l a5, a4
    ;// check lines
    .rept 5
        moveq #5, d0
        .rept 5
            sub.b (a4)+, d0
        .endr
        bne.s 1f ;// do we still have at least a number that isn't marked?
        rts ;// we don't, return
    1: ;// we do, check the next line
    .endr
    rts

**************************************
* returns score in d0
* input: d1, last drawn number
* input: a3, pointer to the winning bingo board array
* input: a6, pointer to the winning bingo board marker array: 0 = not marked, 1 = marked
* clobbered: d2
**************************************
calculate_winning_score:
    moveq #0, d0
    moveq #0, d2
    .rept 25
        tst.b (a6)+
        bne.s 1f
        ;// if the marker isn't set, add to the score
        move.b (a3)+, d2
        add.w d2, d0
        bra.s 2f
    1: ;// skip adding
        addq.l #1, a3
    2:
    .endr
    mulu.w d1, d0
    rts
