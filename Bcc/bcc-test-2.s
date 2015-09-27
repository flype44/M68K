;===========================
; Bcc test
; S C:\Users\FORMATION\Desktop\output12.txt 402718a8 40
;===========================

assert_zero EQU $00D0000C ; magical register

size equ 200

;===========================

start:
    clr.l   d0
    clr.l   d1
    clr.l   d2
    clr.l   d3
    clr.l   d4
    clr.l   d6
    clr.l   d7

    lea     lablist,a2

    move.l  #1,d6
redo:
    lea     datas,a0
    lea     buffer,a1
    move.l  #size,d7
loop:
    cmpi.b  #$55,(a0)
    bge     gotoge
    bra     gotolt
continue:
    bne     loop
    cmpi.l  #10,d6
    beq     exit
    addi.l  #1,d6
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
    move.l  #size,d7
.selfloop
    move.b  (a0)+,d0
    sub.b   (a1)+,d0
    move.b  d0,assert_zero
    subi.b  #1,d7
    bne     .selfloop
    rts

;===========================

datas:
    dc.b $76,$56,$7A,$26,$59,$6B,$D6,$9C
    dc.b $48,$64,$E6,$0D,$5D,$86,$42,$E7
    dc.b $E4,$F5,$1E,$26,$C7,$85,$01,$30
    dc.b $D5,$50,$1A,$CC,$7D,$84,$56,$9A
    dc.b $1E,$51,$DB,$38,$13,$3B,$6B,$8E
    dc.b $48,$9D,$BC,$D9,$62,$99,$11,$76
    dc.b $A4,$E1,$E0,$F2,$9F,$61,$95,$D1
    dc.b $4D,$08,$80,$70,$8F,$5A,$12,$59
    dc.b $79,$91,$08,$C1,$64,$E4,$41,$45
    dc.b $B4,$9B,$D7,$63,$CC,$AB,$23,$06
    dc.b $5F,$2E,$9B,$40,$5D,$DE,$B7,$5B
    dc.b $CD,$1F,$49,$F0,$55,$0A,$F0,$B7
    dc.b $61,$55,$48,$01,$B1,$97,$9C,$24
    dc.b $B2,$AF,$6B,$0C,$DE,$BE,$A1,$27
    dc.b $15,$8C,$8A,$DD,$50,$83,$0D,$5A
    dc.b $43,$25,$B1,$36,$EF,$97,$FE,$06
    dc.b $9C,$77,$08,$D9,$2A,$59,$D3,$0A
    dc.b $6D,$B6,$97,$6D,$FD,$5A,$7D,$C5
    dc.b $55,$7B,$71,$28,$01,$0E,$3A,$BD
    dc.b $8E,$88,$67,$35,$49,$4A,$7A,$4E
    dc.b $89,$3A,$72,$DA,$3D,$A2,$DC,$F5
    dc.b $D1,$F7,$34,$F4,$0E,$63,$5E,$CE
    dc.b $3B,$8D,$84,$82,$9E,$E8,$61,$9E
    dc.b $D7,$E3,$6C,$31,$DB,$6C,$CD,$DF
    dc.b $53,$20,$D2,$6D,$7B,$3B,$58,$FA

buffer:
    ds.b size

precalc:
    dc.b $6C,$4C,$70,$30,$4F,$61,$E0,$A6
    dc.b $52,$5A,$F0,$17,$53,$90,$4C,$F1
    dc.b $EE,$FF,$28,$30,$D1,$8F,$0B,$3A
    dc.b $DF,$5A,$24,$D6,$73,$8E,$4C,$A4
    dc.b $28,$5B,$E5,$42,$1D,$45,$61,$98
    dc.b $52,$A7,$C6,$E3,$58,$A3,$1B,$6C
    dc.b $AE,$EB,$EA,$FC,$A9,$57,$9F,$DB
    dc.b $57,$12,$8A,$66,$99,$50,$1C,$4F
    dc.b $6F,$9B,$12,$CB,$5A,$EE,$4B,$4F
    dc.b $BE,$A5,$E1,$59,$D6,$B5,$2D,$10
    dc.b $55,$38,$A5,$4A,$53,$E8,$C1,$51
    dc.b $D7,$29,$53,$FA,$4B,$14,$FA,$C1
    dc.b $57,$4B,$52,$0B,$BB,$A1,$A6,$2E
    dc.b $BC,$B9,$61,$16,$E8,$C8,$AB,$31
    dc.b $1F,$96,$94,$E7,$5A,$8D,$17,$50
    dc.b $4D,$2F,$BB,$40,$F9,$A1,$08,$10
    dc.b $A6,$6D,$12,$E3,$34,$4F,$DD,$14
    dc.b $63,$C0,$A1,$63,$07,$50,$73,$CF
    dc.b $4B,$71,$67,$32,$0B,$18,$44,$C7
    dc.b $98,$92,$5D,$3F,$53,$54,$70,$58
    dc.b $93,$44,$68,$E4,$47,$AC,$E6,$FF
    dc.b $DB,$01,$3E,$FE,$18,$59,$54,$D8
    dc.b $45,$97,$8E,$8C,$A8,$F2,$57,$A8
    dc.b $E1,$ED,$62,$3B,$E5,$62,$D7,$E9
    dc.b $5D,$2A,$DC,$63,$71,$45,$4E,$04

;===========================

lablist:
    dc.l continue
    dc.l redo

;===========================

;    move.l #1024,d7
;    move.l d7,d0
;.loop:
;    ror.l #1,d0
;    subq.l #w,d7
;    ble .skip
;    addq.l #1,d7
;.skip:
;    bgt .loop
