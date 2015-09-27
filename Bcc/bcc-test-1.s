;===========================
; Bcc test
; S C:\Users\FORMATION\Desktop\output12.txt 402718a8 40
;===========================

assert_zero EQU $00D0000C ; magical register

;===========================

start:
    
    clr.l   d0
    clr.l   d1
    clr.l   d2
    clr.l   d3
    clr.l   d6
    clr.l   d7

    move.l  #10,d6
redo:
    lea     datas,a0
    lea     buffer,a1
    move.l  #16*4,d7
loop:
    cmpi.b  #$55,(a0)
    bge     gotoge
    bra     gotolt
continue:
    bne     loop
    cmpi.l  #0,d6
    beq     exit
    subi.l  #1,d6
    bra     redo
    bra     exit

gotolt:
    bsr     branch1
    subi.b  #1,d7
    bra     continue

gotoge:
    bsr     branch2
    subi.b  #1,d7
    bra     continue

branch1:
    move.b  (a0)+,d0
    add.b   d6,d0
    move.b  d0,(a1)+
    rts

branch2:
    move.b  (a0)+,d0
    sub.b   d6,d0
    move.b  d0,(a1)+
    rts
    
exit:
    bsr     selftest
    stop    #-1

selftest:
    lea     buffer,a0
    lea     precalc,a1
    move.l  #16*4,d7
    ;move.l  #16*4-1,d7 ; -1 for dbf
.selfloop
    move.b  (a0)+,d0
    sub.b   (a1)+,d0
    move.b  d0,assert_zero
    subi.b  #1,d7
    bne     .selfloop
    ;dbf     d7,.selfloop
    rts

;===========================

datas:
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88
    dc.b $11,$22,$33,$44
    dc.b $55,$66,$77,$88

buffer:
    ds.b 4*16

precalc:
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89
    dc.b $12,$23,$34,$45
    dc.b $54,$65,$76,$89

;===========================
