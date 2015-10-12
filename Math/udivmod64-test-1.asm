;----------------------------------------
; ASM Testcase
; flype, 2015-10-12
; udivmod64-test-1.asm
; Based on meynaf 'udivmod64' routine
; http://eab.abime.net/showpost.php?p=1045340&postcount=15
; 23:12 --> 23:30
;----------------------------------------

ASSERT_ZERO EQU $00D0000C ; magical register

;----------------------------------------

    section .fastram

    bra     start ; comment this for sim

    dc.l    0
    dc.l    start

;----------------------------------------

runner:
    ;       <========   div     ========>,<==== precalc ====>,<==== precalc ====>
    ;       <======== arguments ========>,<==== native  ====>,<==== meynaf  ====>
    ;              d0        d1        d2        d0        d1        d0        d1
    dc.l    $00000000,$00002710,$00000011,$00000004,$0000024c,$00000004,$0000024c
    dc.l    $00000000,$70002710,$70000011,$000026ff,$00000001,$000026ff,$00000001
    dc.l    $00000010,$70002710,$70000011,$000026ff,$00000001,$4000249b,$00000025
    dc.l    $00000000,$7f00abcd,$abcdabcd,$7f00abcd,$00000000,$7f00abcd,$00000000
    dc.l    $00000100,$7f00abcd,$abcdabcd,$7f00abcd,$00000000,$221a4fe7,$0000017e
    dc.l    $ffffffff,$ffffffff,$ffffffff,$00000000,$00000001,$00000000,$fffffffe
    dc.l    $00000000,$7fffffff,$10000001,$0ffffff8,$00000007,$0ffffff8,$00000007
    dc.l    $7fffffff,$7fffffff,$10000001,$0ffffff8,$00000007,$cffffffa,$fffffffe
    dc.l    $00000000,$7ffffffe,$0007ffff,$00000ffe,$00001000,$00000ffe,$00001000
    dc.l    $00000000,$12345678,$01020304,$00102030,$00000012,$00102030,$00000012
    dc.l    $00000000,$00005678,$56780000,$00005678,$00000000,$00005678,$00000000
    dc.l    $00000000,$56780000,$00005678,$00000000,$00010000,$00000000,$00010000
    dc.l    $00000000,$56780000,$00005678,$00000000,$00010000,$00000000,$00010000
    dc.l    $00000000,$09080706,$0001eeee,$0001b60c,$000004ab,$0001b60c,$000004ab
    dc.l    $00000000,$1edcba01,$01234567,$00246824,$0000001b,$00246824,$0000001b
    dc.l    $00000000,$99cc44aa,$10203044,$08aa9246,$00000009,$08aa9246,$00000009
    dc.l    $00000000,$a1b1c1d1,$1a1b1c1d,$050f1923,$00000006,$050f1923,$00000006
    dc.l    $7fffffff,$7fffffff,$7fffffff,$00000000,$00000001,$fffffffe,$ffffffff
    dc.l    $00000000,$7fffffff,$7fffffff,$00000000,$00000001,$00000000,$00000001
    dc.l    $00000000,$0000007f,$00000033,$00000019,$00000002,$00000019,$00000002
    dc.l    0,0

;----------------------------------------

start:
    lea     runner,a0      ; load runner
    clr.l   d7             ; error count
.loop:
    tst.l   0(a0)          ; last value ?
    bne     .native        ; if not, continue
    tst.l   4(a0)          ; last value ?
    beq     .exit          ; then exit
.native:
    move.l  0(a0),d0       ; load values
    move.l  4(a0),d1       ; 
    move.l  8(a0),d2       ; 
    move.l  12(a0),d3      ; precalc remainder
    move.l  16(a0),d4      ; precalc quotient
    divul.l d2,d0:d1       ; div64 (68020+)
    jsr     selftest       ; check results
.meynaf:
    move.l  (a0)+,d0       ; load values
    move.l  (a0)+,d1       ; 
    move.l  (a0)+,d2       ; 
    move.l  (a0)+,d3       ; ignore native
    move.l  (a0)+,d4       ; ignore native
    move.l  (a0)+,d3       ; precalc remainder
    move.l  (a0)+,d4       ; precalc quotient
    jsr     udivmod64      ; div64 (68000+)
    jsr     selftest       ; check results
.next:
    bra     .loop          ; continue
.exit:
    move.l  d7,ASSERT_ZERO ; assert error counter = 0
    stop    #-1            ; stop sim
    rts                    ; stop program

selftest:
    sub.l   d3,d0          ; check remainder
    move.l  d0,ASSERT_ZERO ; assert d0 = 0
    bne     .selftest_err  ; error counter
    sub.l   d4,d1          ; check quotient
    move.l  d1,ASSERT_ZERO ; assert d1 = 0
    bne     .selftest_err  ; error counter
    rts                    ; exit routine
.selftest_err:
    add.l   #1,d7          ; increment error counter
    rts                    ; exit routine

;----------------------------------------

udivmod64:
    move.l  d3,-(a7)
    moveq   #31,d3
udivmod64_loop:
    add.l   d1,d1
    addx.l  d0,d0
    bcs.s   udivmod64_over
    cmp.l   d2,d0
    bcs.s   udivmod64_sui
    sub.l   d2,d0
udivmod64_re:
    addq.b  #1,d1
udivmod64_sui
    dbf     d3,udivmod64_loop
    move.l  (a7)+,d3 ; v=0
    rts
udivmod64_over:
    sub.l   d2,d0
    bcs.s   udivmod64_re
    move.l  (a7)+,d3
    ori     #4,ccr ; v=1
    rts

;----------------------------------------

    end
