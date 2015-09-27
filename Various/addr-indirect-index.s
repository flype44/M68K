;===========================
; Bcc test
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
    lea     values,a1
    lea     buffer,a2
    move.l  #precalc,(0,a5)
    move.l  #buffer,(4,a5)
    move.l  #values,(8,a5)
    move.l  #$FFFFFFFF,(12,a5)
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
    dc.b $99,$99,$99,$99,$99,$99,$99,$99 ; unused
    dc.b $99,$99,$99,$99,$99,$99,$99,$99 ; unused
    dc.b $18,$71,$02,$DB,$08,$DB,$73,$A2
    dc.b $03,$08,$D7,$7B,$60,$11,$1C,$A2
    dc.b $4C,$CC,$B9,$DC,$44,$B5,$59,$D9
    dc.b $7F,$61,$86,$37,$78,$3A,$F6,$5A
    dc.b $90,$ED,$89,$69,$49,$A7,$33,$8D
    dc.b $0C,$73,$4F,$D5,$A3,$FA,$26,$36
    dc.b $CC,$24,$1A,$6D,$82,$C9,$B5,$37
    dc.b $C9,$D3,$B1,$7F,$DF,$1E,$EB,$86
    dc.b $5F,$EE,$75,$3F,$4B,$90,$B3,$F9
    dc.b $89,$2A,$76,$9F,$C3,$C8,$A3,$98
    dc.b $0F,$5A,$A0,$24,$51,$CE,$82,$10
    dc.b $8D,$9D,$8C,$0E,$48,$66,$14,$58
    dc.b $E7,$2E,$7D,$07,$CC,$60,$B4,$7E
    dc.b $AB,$02,$D6,$A2,$3E,$0B,$3E,$E3
    dc.b $F3,$92,$20,$3F,$1C,$86,$D1,$11
    dc.b $59,$37,$29,$B8,$DD,$F8,$6C,$8B
    dc.b $89,$13,$BD,$46,$FE,$24,$7E,$96
    dc.b $E7,$D7,$81,$74,$7A,$34,$60,$62
    dc.b $9C,$0F,$89,$C0,$BF,$54,$6C,$51
    dc.b $DD,$75,$E8,$5E,$3E,$86,$45,$D1
    dc.b $49,$4A,$0F,$6F,$9B,$6E,$6A,$52
    dc.b $EC,$ED,$1F,$8D,$5D,$3E,$FF,$2D
    dc.b $BC,$EC,$EE,$4D,$62,$C6,$87,$63
    dc.b $14,$2A,$A7,$44,$B9,$F3,$1E,$64
    dc.b $49,$55,$BB,$49,$6B,$D6,$02,$AF
    dc.b $A5,$EA,$9B,$83,$39,$2C,$A5,$C9
    dc.b $E1,$5C,$E3,$F2,$F5,$EE,$BA,$14
    dc.b $45,$82,$C5,$EA,$11,$E3,$23,$FD
    dc.b $A7,$63,$18,$B2,$47,$CF,$1E,$AA
    dc.b $EB,$B8,$C5,$B3,$94,$7F,$4E,$BB
    dc.b $AF,$2F,$26,$81,$22,$4D,$2D,$7C
    dc.b $0E,$38,$ED,$83,$BC,$BC,$F5,$A9
    dc.b $88,$88,$88,$88,$88,$88,$88,$88 ; unused
    dc.b $88,$88,$88,$88,$88,$88,$88,$88 ; unused

buffer:
    dc.b $99,$99,$99,$99,$99,$99,$99     ; unused
    ds.b size*4
    dc.b $99,$99,$99,$99,$99,$99,$99,$99 ; unused

precalc:
    dc.b $EF,$84,$25,$24,$FF,$1A,$5E,$5D
    dc.b $FF,$ED,$85,$84,$9F,$E4,$5E,$5D
    dc.b $BF,$29,$24,$23,$BF,$40,$27,$26
    dc.b $8F,$94,$C9,$C8,$8F,$BB,$A6,$A5
    dc.b $6F,$08,$97,$96,$BF,$4E,$73,$72
    dc.b $FF,$82,$2B,$2A,$5F,$FB,$CA,$C9
    dc.b $3F,$D1,$93,$92,$7F,$2C,$C9,$C8
    dc.b $3F,$22,$81,$80,$2F,$D7,$7A,$79
    dc.b $AF,$07,$C1,$C0,$BF,$65,$07,$06
    dc.b $7F,$CB,$61,$60,$3F,$2D,$68,$67
    dc.b $FF,$9B,$DC,$DB,$AF,$27,$F0,$EF
    dc.b $7F,$58,$F2,$F1,$BF,$8F,$A8,$A7
    dc.b $1F,$C7,$F9,$F8,$3F,$95,$82,$81
    dc.b $5F,$F3,$5E,$5D,$CF,$EA,$1D,$1C
    dc.b $0F,$63,$C1,$C0,$EF,$6F,$EF,$EE
    dc.b $AF,$BE,$48,$47,$2F,$FD,$75,$74
    dc.b $7F,$E2,$BA,$B9,$0F,$D1,$6A,$69
    dc.b $1F,$1E,$8C,$8B,$8F,$C1,$9E,$9D
    dc.b $6F,$E6,$40,$3F,$4F,$A1,$AF,$AE
    dc.b $2F,$80,$A2,$A1,$CF,$6F,$2F,$2E
    dc.b $BF,$AB,$91,$90,$6F,$87,$AE,$AD
    dc.b $1F,$08,$73,$72,$AF,$B7,$D3,$D2
    dc.b $4F,$09,$B3,$B2,$9F,$2F,$9D,$9C
    dc.b $EF,$CB,$BC,$BB,$4F,$02,$9C,$9B
    dc.b $BF,$A0,$B7,$B6,$9F,$1F,$51,$50
    dc.b $5F,$0B,$7D,$7C,$CF,$C9,$37,$36
    dc.b $1F,$99,$0E,$0D,$0F,$07,$EC,$EB
    dc.b $BF,$73,$16,$15,$EF,$12,$03,$02
    dc.b $5F,$92,$4E,$4D,$BF,$26,$56,$55
    dc.b $1F,$3D,$4D,$4C,$6F,$76,$45,$44
    dc.b $5F,$C6,$7F,$7E,$DF,$A8,$84,$83
    dc.b $FF,$BD,$7D,$7C,$4F,$39,$57,$56

;===========================
