;===================================================================
; ASM Test : Bitfields - BFEXTS
; S C:\Users\FORMATION\Desktop\output12.txt 402750e6 3A8
;===================================================================

assert_zero EQU $00D0000C   ; magical register

TESTVAL EQU $3B ; BFFFO Dn{offset:width},Dm  =>  Dm = $3C

;===================================================================
; Main
;===================================================================

start:
    clr.l  d5
    clr.l  d6
    clr.l  d7
    lea    precalc,a0
    move.l #32,d0 ; value bit position
.l0
    clr.l  d3
    bset.l d0,d3
    move.l #100,d1 ; bitfield offset
.l1
    move.l #100,d2 ; bitfield width
.l2
    addi.l #1,d5
    bfffo  d3{d1:d2},d4
    cmpi.l #TESTVAL,d4
    bne.l  .l3
    
    ; D4 = TESTVALUE
    addi.l #1,d6
    move.l d3,(a0)+
    move.w d1,(a0)+
    move.w d2,(a0)+
    sub.l  (a1)+,d4
    beq    .l3
    move.l d4,assert_zero
    addi.l #1,d7

.l3
    dbf    d2,.l2
    dbf    d1,.l1
    dbf    d0,.l0
    stop   #-1

;===================================================================
; Data Section
;===================================================================

precalc:
    ds.l $ffff

;===================================================================
; End of program
;===================================================================
