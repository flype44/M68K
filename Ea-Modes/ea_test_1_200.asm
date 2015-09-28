;==============================================================================
; ASM Testcase
; flype, 2015-09-28
; ea_pal8.asm
; WORK IN PROGRESS
;==============================================================================

;==============================================================================
; Constants
;==============================================================================

DIS1 EQU 5
DIS2 EQU 32155

ASSERT_ZERO EQU $00D0000C

;==============================================================================

;	DC.L	0
;	DC.L	START
;	SECTION .FASTRAM

START:
	LEA     VALUES,A0          ; Load colors
	LEA     RUNNER,A1          ; Load runner
LOOP:
	CMPI.B  #-1,DIS2(A1)       ; If current byte = -1
	BEQ     EXIT               ; Then exit
	CLR.L   D0                 ; D0 = 0
	CLR.L   D1                 ; D1 = 0
	MOVE.B  DIS2(A1),D1        ; Value = Memory Index
	ADDQ    #1,A1              ; Value = Multiply Size
EAMUL1:
	CMPI.B  #1,DIS2(A1)        ; If MUL = 1 ?
	BNE     EAMUL2             ; 
	MOVE.L  DIS1(A0,D1.L*1),D0 ; Then D8(An,Dn.L*1)
	BRA     NEXT
EAMUL2:
	CMPI.B  #2,DIS2(A1)        ; MUL = 2 ?
	BNE     EAMUL4             ; 
	MOVE.L  DIS1(A0,D1.L*2),D0 ; Then D8(An,Dn.L*2)
	BRA     NEXT
EAMUL4:
	CMPI.B  #4,DIS2(A1)        ; MUL = 4 ?
	BNE     EAMUL8             ; 
	MOVE.L  DIS1(A0,D1.L*4),D0 ; Then D8(An,Dn.L*4)
	BRA     NEXT
EAMUL8:
	CMPI.B  #8,DIS2(A1)        ; MUL = 8 ?
	BNE     NEXT               ; 
	MOVE.L  DIS1(A0,D1.L*8),D0 ; Then D8(An,Dn.L*8)
NEXT:
	ADDA.W  #1,A1              ; Value = Precalc
	SUB.L   DIS2(A1),D0        ; Compare Result with Precalc
	ADD     #4,A1              ; Value = Next Memory Index
	MOVE.L  D0,ASSERT_ZERO     ; Assert D0 = 0
	BRA     LOOP
EXIT:
	;TST     $0                 ; FLUSH
	;STOP    #-1                ; STOP SIM
	RTS
;==========================================================
; Data Section
;==========================================================

RUNNER:
    DS.B DIS2
    DC.B $87,1,$1B,$A1,$98,$53
    DC.B $66,2,$E8,$15,$25,$E1
    DC.B $30,2,$7A,$E2,$CF,$62
    DC.B $74,1,$FF,$62,$2E,$AF
    DC.B $34,4,$3D,$2F,$31,$19
    DC.B $6D,2,$AB,$B6,$8F,$F7
    DC.B $2D,4,$A6,$0A,$CB,$7B
    DC.B $02,4,$9C,$EE,$A1,$B6
    DC.B $2E,1,$53,$EB,$80,$C3
    DC.B $38,4,$6A,$B8,$6E,$65
    DC.B $16,8,$80,$A0,$F9,$7D
    DC.B $65,2,$1E,$1A,$E8,$15
    DC.B $0C,2,$90,$4C,$CA,$DC
    DC.B $BA,1,$7D,$4F,$32,$9A
    DC.B $2E,2,$84,$A5,$AB,$0D
    DC.B $0C,8,$7A,$E2,$CF,$62
    DC.B $A9,1,$D4,$10,$6D,$11
    DC.B $64,1,$1A,$AA,$9D,$14
    DC.B $07,8,$22,$6C,$31,$94
    DC.B $04,2,$9C,$EE,$A1,$B6
    DC.B $2D,1,$EF,$53,$EB,$80
    DC.B $27,2,$4F,$D5,$6B,$F5
    DC.B $33,1,$C7,$2B,$09,$E1
    DC.B $05,8,$60,$57,$99,$56
    DC.B $0A,8,$6B,$F5,$07,$07
    DC.B $05,4,$3D,$D2,$DA,$AB
    DC.B $02,8,$06,$28,$5D,$06
    DC.B $14,8,$BD,$3C,$03,$1D
    DC.B $02,2,$64,$51,$8C,$B4
    DC.B $3A,4,$5E,$B3,$ED,$D8
    DC.B $31,1,$C3,$6C,$C7,$2B
    DC.B $08,4,$BD,$94,$29,$41
    DC.B $26,2,$E3,$DD,$4F,$D5
    DC.B $65,2,$1E,$1A,$E8,$15
    DC.B $55,1,$13,$26,$55,$F2
    DC.B $08,8,$DE,$64,$4E,$FB
    DC.B $31,2,$CF,$62,$1A,$AA
    DC.B $24,2,$16,$AA,$A0,$7F
    DC.B $19,8,$18,$59,$1E,$1A
    DC.B $11,4,$D9,$D0,$51,$37
    DC.B $3C,4,$E9,$A1,$A9,$79
    DC.B $D0,1,$3D,$2F,$31,$19
    DC.B $38,4,$6A,$B8,$6E,$65
    DC.B $1B,8,$BE,$8E,$AB,$B6
    DC.B $6E,1,$CA,$48,$E8,$4C
    DC.B $18,8,$D6,$A8,$0F,$16
    DC.B $11,8,$A1,$98,$53,$E4
    DC.B $CF,1,$E1,$3D,$2F,$31
    DC.B $29,2,$07,$07,$3A,$13
    DC.B $2F,1,$EB,$80,$C3,$6C
    DC.B $D4,1,$9F,$51,$41,$D8
    DC.B $1E,4,$54,$13,$82,$BD
    DC.B $09,8,$16,$AA,$A0,$7F
    DC.B $03,8,$90,$4C,$CA,$DC
    DC.B $0F,8,$54,$13,$82,$BD
    DC.B $1B,4,$90,$81,$CA,$48
    DC.B $17,4,$84,$A5,$AB,$0D
    DC.B $0A,8,$6B,$F5,$07,$07
    DC.B $36,4,$BE,$8E,$AB,$B6
    DC.B $18,8,$D6,$A8,$0F,$16
    DC.B $0C,8,$7A,$E2,$CF,$62
    DC.B $39,2,$A5,$15,$FF,$62
    DC.B $22,2,$D9,$D0,$51,$37
    DC.B $18,2,$80,$C3,$6C,$C7
    DC.B $02,4,$9C,$EE,$A1,$B6
    DC.B $27,1,$88,$60,$57,$99
    DC.B $01,2,$A8,$0C,$64,$51
    DC.B $0D,4,$2B,$09,$E1,$7E
    DC.B $1A,4,$94,$12,$CF,$3F
    DC.B $1D,4,$FF,$62,$2E,$AF
    DC.B $0D,8,$94,$12,$CF,$3F
    DC.B $E3,1,$65,$0B,$CF,$0B
    DC.B $20,2,$DE,$64,$4E,$FB
    DC.B $1A,2,$2B,$09,$E1,$7E
    DC.B $4E,2,$E1,$C2,$93,$EB
    DC.B $68,2,$3D,$2F,$31,$19
    DC.B $00,8,$BA,$37,$A8,$0C
    DC.B $0B,8,$F2,$B6,$51,$43
    DC.B $2D,1,$EF,$53,$EB,$80
    DC.B $DE,1,$BE,$8B,$6A,$B8
    DC.B $02,4,$9C,$EE,$A1,$B6
    DC.B $14,2,$60,$57,$99,$56
    DC.B $2E,4,$72,$C9,$7D,$4F
    DC.B $13,4,$E3,$DD,$4F,$D5
    DC.B $16,2,$5F,$EF,$53,$EB
    DC.B $37,4,$8F,$F7,$BE,$8B
    DC.B $21,2,$4E,$FB,$D9,$D0
    DC.B $0D,8,$94,$12,$CF,$3F
    DC.B $16,4,$F2,$B6,$51,$43
    DC.B $00,2,$BA,$37,$A8,$0C
    DC.B $79,2,$A9,$79,$C0,$E4
    DC.B $41,2,$7A,$AC,$AD,$46
    DC.B $0A,8,$6B,$F5,$07,$07
    DC.B $05,4,$3D,$D2,$DA,$AB
    DC.B $13,2,$7B,$88,$60,$57
    DC.B $2B,4,$11,$3D,$A7,$1F
    DC.B $39,1,$6C,$31,$94,$8D
    DC.B $0B,8,$F2,$B6,$51,$43
    DC.B $17,8,$72,$C9,$7D,$4F
    DC.B $1F,4,$8F,$91,$C6,$3A
    DC.B $14,4,$6B,$F5,$07,$07
    DC.B $16,8,$80,$A0,$F9,$7D
    DC.B $1C,4,$E8,$4C,$A5,$15
    DC.B $D6,1,$41,$D8,$BE,$8E
    DC.B $60,1,$7A,$E2,$CF,$62
    DC.B $1E,2,$8D,$63,$12,$FB
    DC.B $DA,1,$AB,$B6,$8F,$F7
    DC.B $6D,2,$AB,$B6,$8F,$F7
    DC.B $DF,1,$8B,$6A,$B8,$6E
    DC.B $12,4,$16,$AA,$A0,$7F
    DC.B $81,1,$37,$7A,$AC,$AD
    DC.B $0A,4,$60,$57,$99,$56
    DC.B $53,1,$07,$3A,$13,$26
    DC.B $24,1,$D6,$3C,$7B,$88
    DC.B $1C,4,$E8,$4C,$A5,$15
    DC.B $13,8,$9A,$74,$4D,$B8
    DC.B $38,4,$6A,$B8,$6E,$65
    DC.B $2F,4,$32,$9A,$AA,$DA
    DC.B $1D,4,$FF,$62,$2E,$AF
    DC.B $37,2,$CA,$48,$E8,$4C
    DC.B $2B,4,$11,$3D,$A7,$1F
    DC.B $DA,1,$AB,$B6,$8F,$F7
    DC.B $EF,1,$0C,$E9,$A1,$A9
    DC.B $1D,4,$FF,$62,$2E,$AF
    DC.B $37,4,$8F,$F7,$BE,$8B
    DC.B $2F,2,$AB,$0D,$7A,$E2
    DC.B $11,8,$A1,$98,$53,$E4
    DC.B $1A,8,$3D,$2F,$31,$19
    DC.B $37,4,$8F,$F7,$BE,$8B
    DC.B $10,8,$F9,$37,$7A,$AC
    DC.B $09,8,$16,$AA,$A0,$7F
    DC.B $84,1,$AD,$46,$38,$1B
    DC.B $0E,8,$E8,$4C,$A5,$15
    DC.B $1B,8,$BE,$8E,$AB,$B6
    DC.B $03,2,$8C,$B4,$9C,$EE
    DC.B $9D,1,$C2,$93,$EB,$BD
    DC.B $00,4,$BA,$37,$A8,$0C
    DC.B $5C,2,$72,$C9,$7D,$4F
    DC.B $1C,8,$6A,$B8,$6E,$65
    DC.B $F0,1,$E9,$A1,$A9,$79
    DC.B $67,2,$25,$E1,$3D,$2F
    DC.B $38,4,$6A,$B8,$6E,$65
    DC.B $7A,2,$C0,$E4,$05,$60
    DC.B $49,2,$4A,$5D,$5A,$98
    DC.B $9A,1,$4D,$B8,$E1,$C2
    DC.B $06,4,$90,$4C,$CA,$DC
    DC.B $04,2,$9C,$EE,$A1,$B6
    DC.B $19,8,$18,$59,$1E,$1A
    DC.B $20,4,$F9,$37,$7A,$AC
    DC.B $7A,1,$82,$BD,$8F,$91
    DC.B $90,1,$6D,$4A,$4A,$5D
    DC.B $16,8,$80,$A0,$F9,$7D
    DC.B $0E,4,$22,$6C,$31,$94
    DC.B $69,2,$31,$19,$9F,$51
    DC.B $10,8,$F9,$37,$7A,$AC
    DC.B $5D,1,$A5,$AB,$0D,$7A
    DC.B $D1,1,$2F,$31,$19,$9F
    DC.B $18,4,$7A,$E2,$CF,$62
    DC.B $4B,2,$14,$03,$9A,$74
    DC.B $F1,1,$A1,$A9,$79,$C0
    DC.B $24,2,$16,$AA,$A0,$7F
    DC.B $05,4,$3D,$D2,$DA,$AB
    DC.B $0C,8,$7A,$E2,$CF,$62
    DC.B $00,2,$BA,$37,$A8,$0C
    DC.B $37,4,$8F,$F7,$BE,$8B
    DC.B $D8,1,$BE,$8E,$AB,$B6
    DC.B $98,1,$9A,$74,$4D,$B8
    DC.B $8F,1,$C0,$6D,$4A,$4A
    DC.B $01,8,$9C,$EE,$A1,$B6
    DC.B $68,2,$3D,$2F,$31,$19
    DC.B $16,8,$80,$A0,$F9,$7D
    DC.B $1B,8,$BE,$8E,$AB,$B6
    DC.B $D9,1,$8E,$AB,$B6,$8F
    DC.B $19,8,$18,$59,$1E,$1A
    DC.B $1E,2,$8D,$63,$12,$FB
    DC.B $98,1,$9A,$74,$4D,$B8
    DC.B $04,4,$06,$28,$5D,$06
    DC.B $0A,4,$60,$57,$99,$56
    DC.B $5C,2,$72,$C9,$7D,$4F
    DC.B $1C,8,$6A,$B8,$6E,$65
    DC.B $2D,1,$EF,$53,$EB,$80
    DC.B $CF,1,$E1,$3D,$2F,$31
    DC.B $15,8,$07,$D4,$10,$6D
    DC.B $1A,8,$3D,$2F,$31,$19
    DC.B $07,8,$22,$6C,$31,$94
    DC.B $00,4,$BA,$37,$A8,$0C
    DC.B $18,8,$D6,$A8,$0F,$16
    DC.B $10,2,$BD,$94,$29,$41
    DC.B $0B,4,$5F,$EF,$53,$EB
    DC.B $04,4,$06,$28,$5D,$06
    DC.B $00,8,$BA,$37,$A8,$0C
    DC.B $6F,2,$BE,$8B,$6A,$B8
    DC.B $45,1,$D0,$51,$37,$16
    DC.B $07,8,$22,$6C,$31,$94
    DC.B $10,4,$DE,$64,$4E,$FB
    DC.B $1C,2,$22,$6C,$31,$94
    DC.B $1B,8,$BE,$8E,$AB,$B6
    DC.B $26,4,$9A,$74,$4D,$B8
    DC.B $1C,8,$6A,$B8,$6E,$65
    DC.B $42,2,$AD,$46,$38,$1B
    DC.B -1

VALUES:
    DS.B DIS1
    DC.B $BA,$37,$A8,$0C
    DC.B $64,$51,$8C,$B4
    DC.B $9C,$EE,$A1,$B6
    DC.B $D5,$03,$AE,$E4
    DC.B $06,$28,$5D,$06
    DC.B $3D,$D2,$DA,$AB
    DC.B $90,$4C,$CA,$DC
    DC.B $9D,$40,$B9,$1D
    DC.B $BD,$94,$29,$41
    DC.B $D6,$3C,$7B,$88
    DC.B $60,$57,$99,$56
    DC.B $5F,$EF,$53,$EB
    DC.B $80,$C3,$6C,$C7
    DC.B $2B,$09,$E1,$7E
    DC.B $22,$6C,$31,$94
    DC.B $8D,$63,$12,$FB
    DC.B $DE,$64,$4E,$FB
    DC.B $D9,$D0,$51,$37
    DC.B $16,$AA,$A0,$7F
    DC.B $E3,$DD,$4F,$D5
    DC.B $6B,$F5,$07,$07
    DC.B $3A,$13,$26,$55
    DC.B $F2,$B6,$51,$43
    DC.B $84,$A5,$AB,$0D
    DC.B $7A,$E2,$CF,$62
    DC.B $1A,$AA,$9D,$14
    DC.B $94,$12,$CF,$3F
    DC.B $90,$81,$CA,$48
    DC.B $E8,$4C,$A5,$15
    DC.B $FF,$62,$2E,$AF
    DC.B $54,$13,$82,$BD
    DC.B $8F,$91,$C6,$3A
    DC.B $F9,$37,$7A,$AC
    DC.B $AD,$46,$38,$1B
    DC.B $A1,$98,$53,$E4
    DC.B $19,$37,$45,$C0
    DC.B $6D,$4A,$4A,$5D
    DC.B $5A,$98,$14,$03
    DC.B $9A,$74,$4D,$B8
    DC.B $E1,$C2,$93,$EB
    DC.B $BD,$3C,$03,$1D
    DC.B $83,$BE,$71,$16
    DC.B $07,$D4,$10,$6D
    DC.B $11,$3D,$A7,$1F
    DC.B $80,$A0,$F9,$7D
    DC.B $A6,$0A,$CB,$7B
    DC.B $72,$C9,$7D,$4F
    DC.B $32,$9A,$AA,$DA
    DC.B $D6,$A8,$0F,$16
    DC.B $1B,$75,$0F,$DD
    DC.B $18,$59,$1E,$1A
    DC.B $E8,$15,$25,$E1
    DC.B $3D,$2F,$31,$19
    DC.B $9F,$51,$41,$D8
    DC.B $BE,$8E,$AB,$B6
    DC.B $8F,$F7,$BE,$8B
    DC.B $6A,$B8,$6E,$65
    DC.B $0B,$CF,$0B,$4D
    DC.B $5E,$B3,$ED,$D8
    DC.B $CD,$E9,$A1,$0C
    DC.B $E9,$A1,$A9,$79
    DC.B $C0,$E4,$05,$60
    DC.B $6D,$3D,$72,$3E
    DC.B $D0,$05,$0A,$C5
    DC.B $C0,$82,$3D,$DA
    DC.B $AB,$33,$49,$90
    DC.B $8A,$C2,$99,$E8
    DC.B $35,$65,$80,$E5
    DC.B $0F,$70,$08,$73
    DC.B $81,$B7,$5A,$37
    DC.B $44,$B3,$7F,$6A
    DC.B $B6,$32,$D7,$80
    DC.B $EF,$FB,$26,$25
    DC.B $EE,$57,$86,$32
    DC.B $C0,$84,$95,$B2
    DC.B $6A,$B4,$7E,$49
    DC.B $D2,$A2,$C9,$43
    DC.B $B1,$0C,$3B,$38
    DC.B $7B,$31,$44,$04
    DC.B $CB,$D0,$A2,$78
    DC.B $8E,$8F,$1D,$A2
    DC.B $AA,$D9,$72,$2F
    DC.B $E5,$A6,$C5,$18
    DC.B $C2,$FA,$BF,$03
    DC.B $32,$8F,$0E,$90
    DC.B $04,$1E,$9B,$FB
    DC.B $A1,$27,$67,$EE
    DC.B $AD,$CA,$BD,$25
    DC.B $07,$0D,$A3,$EB
    DC.B $E2,$99,$C7,$69
    DC.B $FD,$6F,$07,$07
    DC.B $E3,$54,$5D,$76
    DC.B $47,$EF,$7D,$18
    DC.B $38,$C8,$83,$B1
    DC.B $11,$FE,$0D,$8C
    DC.B $52,$B9,$92,$77
    DC.B $CA,$5C,$9E,$41
    DC.B $38,$54,$7C,$FF
    DC.B $EF,$55,$3A,$8C
    DC.B $11,$3F,$DD,$FE
    DC.B $0C,$B8,$13,$CE
    DC.B $BA,$FB,$49,$0E
    DC.B $3D,$5B,$01,$57
    DC.B $D3,$F6,$83,$C8
    DC.B $A8,$C2,$D2,$B9
    DC.B $F3,$14,$A1,$77
    DC.B $D6,$0B,$9C,$38
    DC.B $8A,$3A,$F2,$37
    DC.B $0F,$10,$1B,$3A
    DC.B $AD,$9D,$68,$0B
    DC.B $0F,$AF,$DC,$3A
    DC.B $05,$B9,$DD,$77
    DC.B $4A,$FB,$F5,$D9
    DC.B $25,$87,$30,$FF
    DC.B $9F,$27,$02,$87
    DC.B $51,$84,$65,$EB
    DC.B $4E,$3B,$08,$C6
    DC.B $3A,$69,$1D,$77
    DC.B $0E,$AC,$A1,$6A
    DC.B $57,$7B,$10,$4C
    DC.B $2F,$8C,$74,$0E
    DC.B $3B,$E1,$75,$DC
    DC.B $5F,$F0,$6A,$A2
    DC.B $B6,$19,$C9,$5E
    DC.B $5C,$3E,$C7,$62
    DC.B $34,$C3,$B1,$59
    DC.B $54,$4B,$09,$A3
    DC.B $DB,$68,$07,$76
    DC.B $64,$28,$53,$DA
    DC.B $95,$D1,$1F,$F2
    DC.B $13,$16,$14,$5D
    DC.B $38,$26,$05,$94
    DC.B $2E,$A4,$0D,$99
    DC.B $D5,$8D,$E2,$CA
    DC.B $4E,$95,$8C,$B5
    DC.B $8C,$F9,$77,$7E
    DC.B $11,$B5,$1D,$3A
    DC.B $73,$65,$FF,$B4
    DC.B $F4,$0D,$B2,$08
    DC.B $04,$D2,$66,$C8
    DC.B $E6,$1C,$51,$45
    DC.B $D8,$96,$6A,$0F
    DC.B $24,$8A,$F7,$66
    DC.B $A9,$9F,$A4,$31
    DC.B $F8,$19,$E8,$92
    DC.B $D6,$EF,$8F,$D8
    DC.B $21,$70,$77,$28
    DC.B $E3,$DB,$1A,$2A
    DC.B $CD,$A2,$B0,$0A
    DC.B $D0,$AB,$D8,$43
    DC.B $FF,$97,$4B,$4A
    DC.B $69,$01,$E7,$DF
    DC.B $7B,$DE,$B3,$0C
    DC.B $34,$E1,$C2,$BD
    DC.B $25,$9E,$BD,$55
    DC.B $2E,$36,$55,$C3
    DC.B $47,$BE,$0A,$2A
    DC.B $FC,$21,$35,$A7
    DC.B $6B,$3C,$31,$35
    DC.B $CB,$32,$3D,$F4
    DC.B $D7,$DA,$3A,$89
    DC.B $F4,$89,$54,$24
    DC.B $BF,$4C,$7C,$6F
    DC.B $43,$83,$DB,$D2
    DC.B $3B,$D2,$56,$6B
    DC.B $99,$78,$24,$31
    DC.B $CD,$19,$A4,$47
    DC.B $00,$38,$28,$10
    DC.B $90,$28,$0F,$98
    DC.B $E5,$29,$AD,$A4
    DC.B $29,$B8,$67,$1F
    DC.B $ED,$0E,$4E,$59
    DC.B $8A,$94,$E7,$C5
    DC.B $61,$50,$86,$27
    DC.B $FD,$CB,$0A,$5B
    DC.B $06,$85,$96,$DD
    DC.B $88,$AC,$42,$B6
    DC.B $6E,$DF,$D4,$8F
    DC.B $45,$1F,$0C,$B1
    DC.B $D0,$E7,$3A,$B6
    DC.B $C4,$02,$37,$EB
    DC.B $09,$55,$03,$33
    DC.B $42,$FE,$DB,$C7
    DC.B $21,$1E,$82,$3D
    DC.B $4D,$40,$CC,$69
    DC.B $00,$DA,$1F,$6D
    DC.B $0B,$8C,$C4,$61
    DC.B $4D,$7B,$ED,$9E
    DC.B $1E,$58,$9F,$7B
    DC.B $68,$08,$5A,$72
    DC.B $71,$B3,$83,$FA
    DC.B $44,$51,$F2,$3C
    DC.B $CC,$F7,$BB,$42
    DC.B $70,$9B,$E2,$0C
    DC.B $81,$43,$1F,$89
    DC.B $C7,$21,$83,$1C
    DC.B $98,$CE,$B9,$F8
    DC.B $7F,$CD,$87,$32
    DC.B $05,$98,$72,$00
    DC.B $33,$99,$50,$54
    DC.B $77,$A4,$72,$3E
    DC.B $CF,$DD,$55,$C7
    DC.B $81,$AD,$79,$95
    DC.B $20,$96,$25,$64
    DC.B $B8,$F6,$73,$AE
    DC.B $CB,$EC,$A4,$53
    DC.B $30,$6C,$05,$22
    DC.B $A1,$22,$FA,$33
    DC.B $97,$11,$74,$8E
    DC.B $32,$CB,$4D,$43
    DC.B $CC,$5E,$1D,$4C
    DC.B $24,$B0,$80,$27
    DC.B $7E,$3A,$61,$59
    DC.B $E8,$F8,$5F,$64
    DC.B $7A,$4C,$4F,$23
    DC.B $35,$04,$DD,$EB
    DC.B $E0,$B3,$64,$40
    DC.B $56,$33,$FA,$AE
    DC.B $87,$51,$4C,$33
    DC.B $02,$31,$D0,$25
    DC.B $F7,$03,$4C,$FA
    DC.B $C7,$48,$75,$61
    DC.B $87,$B0,$FE,$CA
    DC.B $C4,$67,$E5,$9F
    DC.B $27,$15,$8F,$34
    DC.B $3A,$9A,$BA,$E3
    DC.B $C5,$24,$7F,$B0
    DC.B $EF,$57,$C0,$03
    DC.B $29,$88,$C4,$D4
    DC.B $41,$46,$76,$DA
    DC.B $13,$B6,$F1,$AA
    DC.B $CB,$72,$5E,$36
    DC.B $29,$B8,$0F,$24
    DC.B $28,$EF,$27,$05
    DC.B $93,$AC,$09,$BB
    DC.B $E4,$AF,$EA,$F6
    DC.B $D8,$16,$21,$3B
    DC.B $26,$95,$02,$BE
    DC.B $32,$B9,$D5,$1D
    DC.B $26,$D7,$65,$F7
    DC.B $4E,$5A,$90,$3E
    DC.B $64,$0D,$20,$36
    DC.B $47,$97,$E2,$E9
    DC.B $23,$A3,$DD,$1C
    DC.B $62,$C1,$8D,$CE
    DC.B $7A,$49,$8F,$30
    DC.B $60,$E8,$0C,$0D
    DC.B $6A,$25,$2F,$2E
    DC.B $B0,$C5,$D7,$CB
    DC.B $0C,$AC,$81,$09
    DC.B $E5,$C0,$D6,$7D
    DC.B $B6,$E8,$A2,$54
    DC.B $24,$08,$EF,$C2
    DC.B $80,$A1,$9E,$ED
    DC.B $82,$31,$02,$00
    DC.B $00,$00,$00,$00

