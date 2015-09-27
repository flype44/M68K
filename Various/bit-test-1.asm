;=======================================================================
; Bits related instructions asm test
; BCHG/BCLR/BSET/BTST
;=======================================================================

assert_zero EQU $00D0000C

;=======================================================================
;    DC.L     0
;    DC.L     START
;    SECTION  .fastram
;=======================================================================

start:
     clr.l   D0               ; value 1
     clr.l   D1               ; value 2
     clr.l   D2               ; value 3
     clr.l   D3               ; odd counter
     clr.l   D4               ; even counter
     lea     array,A0         ; load array

loop:
     cmpi.b  #-1,(A0)         ; if value = -1
     beq     .exit            ; then exit loop

     move.b  (A0)+,D0         ; read values
     move.b  (A0)+,D1         ; 
     move.b  (A0)+,D2         ; 
     
     bchg    #4,D2            ; do some 
     bclr    #1,D0            ; bchg/bclr/bset
     bset    #7,D1            ; on values

     btst    #0,D1            ; is ODD value ?
     beq     .even            ; 

     addi.w  #1,D3            ; increment odd counter
     bclr    #2,D2            ; do some other 
     bset    #5,D0            ; bchg/bclr/bset
     bchg    #3,D1            ; on values
     bra     .next

.even
     addi.w  #1,D4            ; increment even counter
     bset    #5,D2            ; do some other 
     bclr    #1,D0            ; bchg/bclr/bset
     bchg    #6,D1            ; on values

.next
     move.b  D0,-3(A0)        ; write new values
     move.b  D1,-2(A0)        ; 
     move.b  D2,-1(A0)        ; 
     bra     loop             ; continue

.exit

;=======================================================================

selftest:
     clr.l   D5               ; init d5/d7
     clr.l   D7               ; 
     move.w  D3,D7            ; init loop counter = 
     add.w   D4,D7            ; odd count + even count
     subi.b  #pre_odd,D3      ; check odd/even count
     subi.b  #pre_even,D4     ; 
     move.l  D3,assert_zero   ; raise error if D3/D4 != 0
     move.l  D4,assert_zero   ; 
     lea     array,A0         ; calculated values
     lea     precalc,A1       ; precalculated values
selfloop:
     move.b  (A0)+,D5         ; get calculated value
     sub.b   (A1)+,D5         ; compare with precalculated value
     move.l  D5,assert_zero   ; raise error if D5 != 0
     dbf     D7,selfloop      ; continue

;=======================================================================

     stop    #-1              ; stop execution

;=======================================================================

array:
     dc.b $85,$73,$3F,$C6,$77,$D5,$67,$95,$A8,$70,$31,$AC,$2D,$17,$CC,$80
     dc.b $F1,$75,$3C,$56,$74,$4A,$51,$88,$99,$A7,$54,$D2,$53,$1C,$F7,$B4
     dc.b $EF,$FE,$ED,$20,$C6,$34,$25,$90,$7F,$88,$F8,$9C,$4B,$1F,$F0,$7B
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
     dc.b $1D,$ED,$24,$DE,$FE,$45,$08,$3D,$46,$4A,$88,$67,$62,$9D,$21,-1

;=======================================================================

precalc:
     dc.b $A5,$FB,$2B,$E4,$FF,$C1,$65,$9D,$B8,$70,$B9,$B8,$2D,$9F,$D8,$A0
     dc.b $F9,$61,$3C,$96,$64,$68,$D9,$98,$B9,$AF,$40,$F0,$DB,$08,$F5,$F4
     dc.b $FF,$FC,$E5,$30,$C4,$F4,$35,$B0,$F7,$98,$F8,$DC,$7B,$1D,$B0,$6B
     dc.b $B1,$E1,$A9,$34,$E8,$3F,$E9,$90,$A7,$DD,$EC,$36,$F4,$FF,$E1,$3C
     dc.b $F2,$AD,$C1,$E6,$E7,$64,$89,$5B,$F8,$FD,$00,$F9,$E1,$49,$7D,$8F
     dc.b $BB,$80,$CA,$FE,$A1,$E2,$6F,$6C,$94,$F9,$F4,$A3,$03,$64,$9B,$48
     dc.b $78,$AE,$AE,$1D,$AC,$E1,$B4,$F4,$BE,$64,$B3,$83,$38,$E2,$65,$28
     dc.b $F3,$A9,$D0,$FC,$26,$A9,$E0,$3A,$F9,$86,$7E,$2D,$CD,$70,$18,$CC
     dc.b $BF,$E8,$98,$7B,$E9,$95,$80,$DC,$F8,$B6,$A9,$D1,$2B,$10,$84,$67
     dc.b $21,$E4,$EA,$B5,$EC,$B0,$F9,$D1,$D9,$F8,$B9,$F8,$74,$C6,$75,$2C
     dc.b $8B,$B0,$D8,$BE,$2B,$F1,$92,$38,$C0,$F6,$6E,$88,$D0,$37,$C5,$CA
     dc.b $F3,$C4,$9E,$F3,$99,$98,$64,$50,$9A,$BD,$E5,$E1,$B3,$34,$EE,$6A
     dc.b $A5,$F3,$B8,$39,$D3,$52,$40,$EA,$66,$A8,$88,$28,$B5,$CE,$AB,$3D
     dc.b $B7,$2B,$69,$E8,$B6,$24,$C3,$A1,$EC,$A0,$B8,$69,$CE,$BF,$B9,$E1
     dc.b $F9,$3C,$B5,$38,$20,$E1,$70,$AD,$97,$1A,$B9,$D9,$F9,$99,$82,$F5
     dc.b $25,$81,$F3,$35,$E0,$A2,$E8,$85,$1A,$D9,$C2,$6A,$60,$E5,$02,$7D
     dc.b $D3,$F8,$19,$CC,$3D,$7C,$C7,$D8,$3D,$C2,$76,$65,$96,$BB,$CD,$DA
     dc.b $35,$F0,$CD,$11,$98,$DE,$2D,$BC,$9D,$39,$6D,$81,$32,$19,$8C,$FF
     dc.b $79,$B9,$7A,$01,$E2,$62,$45,$F0,$A7,$4D,$88,$22,$C4,$CE,$B9,$F0
     dc.b $AB,$B3,$09,$D4,$B9,$FD,$CC,$61,$08,$F6,$32,$58,$FE,$FC,$B8,$8F
     dc.b $DB,$C9,$FE,$23,$85,$86,$6D,$A8,$89,$42,$2C,$ED,$0A,$71,$B5,$D1
     dc.b $EC,$FE,$78,$98,$AC,$F9,$71,$FD,$89,$19,$B2,$F1,$B4,$C0,$FD,$6C
     dc.b $BF,$63,$B1,$CA,$61,$BC,$A4,$FC,$7D,$D2,$36,$B1,$9A,$AD,$70,$FA
     dc.b $68,$BC,$C4,$FB,$69,$86,$F9,$34,$A2,$75,$98,$DE,$E5,$60,$DA,$2C
     dc.b $3D,$E5,$30,$DC,$BE,$75,$28,$B5,$52,$48,$C8,$77,$60,$95,$31,-1

pre_odd  EQU $38
pre_even EQU $4D

;=======================================================================
