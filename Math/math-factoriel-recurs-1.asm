;===================================================
; ASM Testcase - Factoriel - Recursive
; flype, 2015-10-07
;===================================================
; https://github.com/flype44/M68K/blob/master/Math/math-factoriel-recurs-1.asm
;==========================================================
; function Main() {
;   for(var n = 1; n <= 12; n++) {
;     console.log(fact(n));
;   }
; }
; function Fact32(n) {
;   return (n == 1) ? 1 : n * Fact32(n-1);
; }
;===================================================

COUNT EQU 24 ; Max = Number of values in Precalc32 array.

ASSERT_ZERO EQU $00D0000C

;    DC.L    0
;    DC.L    Main
    section .fastram

;===================================================
; MAIN
;===================================================

Main:
    lea     Precalc32End,a0 ; load precalc
    clr.l   d0              ; fact = 0
    clr.l   d1              ; n = 0
    clr.l   d2              ; unused
    clr.l   d3              ; unused
    clr.l   d4              ; unused
    clr.l   d5              ; unused
    clr.l   d6              ; unused
    clr.l   d7              ; fact call counter
MainLoop:
    addi.l  #1,d1           ; n++
    cmpi.l  #COUNT,d1       ; if ( n > 12 )
    bgt     MainExit        ; then exit
    move.l  d1,-(sp)        ; store n
    jsr     Fact32          ; fact32(n)
    sub.l   -(a0),d0        ; check d0
    move.l  d0,ASSERT_ZERO  ; assert d0 = 0
    bra     MainLoop        ; next value
MainExit:
    sub.l   #COUNT+1,d1     ; check d1
    move.l  d1,ASSERT_ZERO  ; assert d1 = 0
    sub.l   #$12c,d7        ; check d7
    move.l  d7,ASSERT_ZERO  ; assert d7 = 0
    move.l  d6,ASSERT_ZERO  ; unused
    move.l  d5,ASSERT_ZERO  ; unused
    move.l  d4,ASSERT_ZERO  ; unused
    move.l  d3,ASSERT_ZERO  ; unused
    move.l  d2,ASSERT_ZERO  ; unused
    tst     $0              ; flush pipelines
    stop    #-1             ; stop execution

;===================================================
; Fact32(n)
;===================================================

Fact32:
    addi.l  #1,d7           ; increment call counter
    move.l  4(sp),d0        ; load n
    cmpi.l  #1,d0           ; if ( n != 1 )
    bne     Fact32n         ; continue
    move.l  #1,d0           ; else n = 1
    rts                     ; return
Fact32n:
    subi.l  #1,d0           ; n - 1
    move.l  d0,-(sp)        ; store n
    jsr     Fact32          ; fact( n - 1 )
    add.l   #4,sp           ; get result
    mulu.l  4(sp),d0        ; n * fact
    rts                     ; return

;===================================================
; Data Section
;===================================================

Precalc32:
    ; 32 bits overflow results
    dc.l $d1c00000,$33680000,$e0d80000,$b8c40000
    dc.l $82b40000,$06890000,$ca730000,$eecd8000
    dc.l $77758000,$77775800,$4c3b2800,$7328cc00
    ; 32 bits results
    dc.l $1c8cfc00,$02611500,$00375f00,$00058980
    dc.l $00009d80,$000013b0,$000002d0,$00000078
    dc.l $00000018,$00000006,$00000002,$00000001
Precalc32End:

;===================================================
; End of program
;===================================================

    end
