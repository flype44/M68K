;===========================
; BCD test
; S C:\Users\FORMATION\Desktop\output12.txt 4029a773 100
; 4026ff4c
;===========================

assert_zero EQU $00D0000C ; magical register

size = 64

;===========================

start:
    clr.l   d0
    clr.l   d1
    clr.l   d2
    clr.l   d3
    clr.l   d6
    clr.l   d7
init:
    lea     tbl,a5
    move.l  #buffer,(4,a5)
    move.l  #values,(8,a5)
    move.l  #size-1,d7
repeat:
    move.l  d7,a3
    move.l  (16,[8,a5],a3.w*4),(7,[4,a5],a3.w*4)
    move.l  (7,[4,a5],a3.l*4),d3
    andi.b  #$F0,(7,[4,a5],a3.l*4)
    not.l   (7,[4,a5],a3.l*4)
    subi.b  #10,(8,[4,a5],a3.l*4)
    move.b  d3,(9,a2,a3.l*4)
    neg.b   (9,a2,a3.l*4)
    jsr     selftest
    dbf     d7,repeat
exit:
    stop    #-1

selftest:
    move.l  (7,[4,a5],a3.l*4),d2
    sub.l   ([0,a5],a3.l*4),d2
    move.l  d2,assert_zero
    beq     noerror
    add.l   #1,d6
noerror:
    rts

;===========================

tbl:
    ds.l 4

;===========================

values:
    dc.b

;===========================
