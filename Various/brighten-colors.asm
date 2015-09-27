;=======================================================================
; Motorola 68K - ASM test
; Brighten color value
;=======================================================================

assert_zero EQU $00D0000C

;=======================================================================
;    DC.L     0
;    DC.L     START
;    SECTION  .fastram
;=======================================================================

VAL1 EQU 500
VAL2 EQU 8

;=======================================================================

start:
     clr.l   D0               ; current array value
     clr.l   D1               ; current buffer value
     clr.l   D2               ; overflow counter
     clr.l   D5               ; multiplicator
     clr.l   D6               ; divider
     clr.l   D7               ; loop counter
     move.w  #VAL1,D5         ; 
     move.w  #VAL2,D6         ; 

;=======================================================================

     lea     array,A0         ; array values
     lea     buffer,A1        ; buffer values
     move.w  #buffer-array,D7 ; init loop
loop:
     move.b  (A0)+,D0         ; read array value
     mulu.w  D5,D0            ; value x 500
     lsr.l   D6,D0            ; value / 256
     cmpi.w  #$00FF,D0        ; if value > 255
     bls     .nooverflow      ; overflow
     addi.l  #1,D2            ; overflow counter
     move.w  #$FF,D0          ; value = 255
.nooverflow
     move.b  D0,(A1)+         ; store value in buffer
     dbra    D7,loop          ; continue

;=======================================================================

selftest:
     lea     buffer,A0        ; calculated values
     lea     precalc,A1       ; precalculated values
     move.w  #buffer-array,D7 ; init loop
selfloop:
     move.b  (A0)+,D1         ; get calculated value
     sub.b   (A1)+,D1         ; compare with precalculated value
     move.l  D1,assert_zero   ; raise error if D1 != 0
     dbf     D7,selfloop      ; continue

;=======================================================================

     stop    #-1              ; stop execution

;=======================================================================

array:
     dc.b $85,$73,$3F,$C6,$77,$D5,$67,$95,$A8,$70,$31,$AC,$2D,$17,$CC,$80
     dc.b $F1,$75,$3C,$56,$74,$4A,$51,$88,$99,$A7,$54,$D2,$53,$1C,$F7,$B4
     dc.b $EF,$FF,$ED,$20,$C6,$34,$25,$90,$7F,$88,$F8,$9C,$4B,$1F,$F0,$7B
     dc.b $93,$E9,$BD,$36,$28,$0F,$E9,$50,$97,$DD,$2C,$26,$D4,$77,$F1,$3C
     dc.b $32,$BD,$C1,$A6,$F7,$46,$01,$4F,$FA,$75,$14,$FB,$69,$59,$5D,$07
     dc.b $AF,$82,$8A,$EE,$A1,$22,$5F,$6C,$D4,$E9,$D4,$2B,$17,$66,$93,$5C
     dc.b $7A,$6E,$BE,$1F,$6C,$F1,$B4,$34,$AE,$64,$BB,$93,$3A,$22,$55,$08
     dc.b $FB,$BD,$D2,$3C,$16,$AB,$20,$2A,$FB,$46,$4E,$0F,$C5,$64,$1A,$8C
     dc.b $AF,$E8,$58,$6B,$E9,$9D,$94,$DE,$B8,$86,$A9,$59,$3B,$10,$44,$57
     dc.b $21,$A4,$DA,$B5,$2C,$A0,$D9,$D9,$C9,$F8,$B1,$EC,$74,$06,$45,$2C
     dc.b $83,$A0,$D8,$FE,$3B,$F3,$D2,$08,$C2,$36,$5E,$88,$10,$27,$C5,$8A
     dc.b $E3,$C6,$5E,$E3,$9B,$58,$74,$50,$DA,$8D,$C5,$E9,$A3,$34,$2E,$5A
     dc.b $A5,$7B,$AC,$1B,$DB,$46,$40,$AA,$56,$AA,$48,$38,$B5,$8E,$BB,$1F
     dc.b $3F,$3B,$6B,$A8,$86,$26,$4B,$B1,$EE,$E0,$88,$69,$8E,$AF,$B9,$E9
     dc.b $ED,$3C,$3D,$28,$00,$69,$60,$AD,$1F,$0A,$BB,$D1,$ED,$9B,$42,$E5
     dc.b $07,$09,$E7,$35,$A0,$92,$EA,$0D,$0A,$D9,$02,$7A,$62,$6D,$16,$5D
     dc.b $5B,$EC,$1B,$0C,$0D,$7C,$4F,$C8,$3D,$02,$46,$67,$56,$8B,$CD,$9A
     dc.b $25,$D0,$45,$01,$98,$1E,$3D,$BE,$95,$29,$4F,$89,$22,$1B,$CC,$EF
     dc.b $7B,$31,$6E,$01,$22,$72,$45,$30,$97,$4D,$C8,$32,$C4,$8E,$A9,$D2
     dc.b $A3,$A3,$09,$14,$89,$FD,$0C,$71,$08,$36,$02,$5A,$3E,$CC,$9A,$07
     dc.b $CB,$C9,$BE,$13,$87,$C6,$5D,$AA,$01,$56,$0C,$E5,$1A,$71,$BD,$C5
     dc.b $EC,$BE,$68,$9A,$EC,$C9,$73,$F5,$9D,$19,$72,$C1,$B6,$00,$ED,$4E
     dc.b $B7,$77,$B3,$0A,$51,$BE,$64,$EC,$7D,$12,$06,$B3,$DA,$9D,$72,$3A
     dc.b $58,$BC,$04,$EB,$69,$C6,$E9,$34,$62,$65,$98,$9E,$F5,$62,$9A,$1C
     dc.b $1D,$ED,$24,$DE,$FE,$45,$08,$3D,$46,$4A,$88,$67,$62,$9D,$21,$0C

;=======================================================================

buffer:
     ds.b *-array

;=======================================================================

precalc:
     dc.b $FF,$E0,$7B,$FF,$E8,$FF,$C9,$FF,$FF,$DA,$5F,$FF,$57,$2C,$FF,$FA
     dc.b $FF,$E4,$75,$A7,$E2,$90,$9E,$FF,$FF,$FF,$A4,$FF,$A2,$36,$FF,$FF
     dc.b $FF,$FF,$FF,$3E,$FF,$65,$48,$FF,$F8,$FF,$FF,$FF,$92,$3C,$FF,$F0
     dc.b $FF,$FF,$FF,$69,$4E,$1D,$FF,$9C,$FF,$FF,$55,$4A,$FF,$E8,$FF,$75
     dc.b $61,$FF,$FF,$FF,$FF,$88,$01,$9A,$FF,$E4,$27,$FF,$CD,$AD,$B5,$0D
     dc.b $FF,$FD,$FF,$FF,$FF,$42,$B9,$D2,$FF,$FF,$FF,$53,$2C,$C7,$FF,$B3
     dc.b $EE,$D6,$FF,$3C,$D2,$FF,$FF,$65,$FF,$C3,$FF,$FF,$71,$42,$A6,$0F
     dc.b $FF,$FF,$FF,$75,$2A,$FF,$3E,$52,$FF,$88,$98,$1D,$FF,$C3,$32,$FF
     dc.b $FF,$FF,$AB,$D0,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$AD,$73,$1F,$84,$A9
     dc.b $40,$FF,$FF,$FF,$55,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$E2,$0B,$86,$55
     dc.b $FF,$FF,$FF,$FF,$73,$FF,$FF,$0F,$FF,$69,$B7,$FF,$1F,$4C,$FF,$FF
     dc.b $FF,$FF,$B7,$FF,$FF,$AB,$E2,$9C,$FF,$FF,$FF,$FF,$FF,$65,$59,$AF
     dc.b $FF,$F0,$FF,$34,$FF,$88,$7D,$FF,$A7,$FF,$8C,$6D,$FF,$FF,$FF,$3C
     dc.b $7B,$73,$D0,$FF,$FF,$4A,$92,$FF,$FF,$FF,$FF,$CD,$FF,$FF,$FF,$FF
     dc.b $FF,$75,$77,$4E,$00,$CD,$BB,$FF,$3C,$13,$FF,$FF,$FF,$FF,$80,$FF
     dc.b $0D,$11,$FF,$67,$FF,$FF,$FF,$19,$13,$FF,$03,$EE,$BF,$D4,$2A,$B5
     dc.b $B1,$FF,$34,$17,$19,$F2,$9A,$FF,$77,$03,$88,$C9,$A7,$FF,$FF,$FF
     dc.b $48,$FF,$86,$01,$FF,$3A,$77,$FF,$FF,$50,$9A,$FF,$42,$34,$FF,$FF
     dc.b $F0,$5F,$D6,$01,$42,$DE,$86,$5D,$FF,$96,$FF,$61,$FF,$FF,$FF,$FF
     dc.b $FF,$FF,$11,$27,$FF,$FF,$17,$DC,$0F,$69,$03,$AF,$79,$FF,$FF,$0D
     dc.b $FF,$FF,$FF,$25,$FF,$FF,$B5,$FF,$01,$A7,$17,$FF,$32,$DC,$FF,$FF
     dc.b $FF,$FF,$CB,$FF,$FF,$FF,$E0,$FF,$FF,$30,$DE,$FF,$FF,$00,$FF,$98
     dc.b $FF,$E8,$FF,$13,$9E,$FF,$C3,$FF,$F4,$23,$0B,$FF,$FF,$FF,$DE,$71
     dc.b $AB,$FF,$07,$FF,$CD,$FF,$FF,$65,$BF,$C5,$FF,$FF,$FF,$BF,$FF,$36
     dc.b $38,$FF,$46,$FF,$FF,$86,$0F,$77,$88,$90,$FF,$C9,$BF,$FF,$40,$17

;=======================================================================
