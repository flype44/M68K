;==============================================================================
; ASM Testcase
; flype, 2015-09-28
; ea_pal8.asm
; WORK IN PROGRESS
;==============================================================================

;==============================================================================
; Constants
;==============================================================================

DIS1 EQU 7
DIS2 EQU 617

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
    DC.B $25,4,$8B,$E1,$D7,$6A
    DC.B $56,2,$0F,$1F,$A5,$0A
    DC.B $1B,2,$CA,$55,$FB,$EF
    DC.B $17,8,$A5,$C1,$4C,$62
    DC.B $3F,2,$A1,$05,$78,$A9
    DC.B $06,8,$6E,$B0,$6C,$5D
    DC.B $10,1,$3A,$83,$02,$FE
    DC.B $00,8,$43,$A0,$A5,$78
    DC.B $00,4,$43,$A0,$A5,$78
    DC.B $45,2,$F4,$B2,$C4,$E0
    DC.B $07,4,$11,$AE,$D3,$67
    DC.B $15,8,$6F,$9F,$A8,$66
    DC.B $38,4,$9D,$07,$F5,$04
    DC.B $25,2,$1E,$80,$22,$39
    DC.B $0B,2,$36,$31,$C6,$C7
    DC.B $D7,1,$3C,$6F,$28,$A5
    DC.B $30,4,$1C,$3E,$3B,$3A
    DC.B $07,8,$FB,$EF,$B8,$57
    DC.B $3B,2,$B3,$56,$7F,$A5
    DC.B $6A,1,$F5,$C6,$04,$F0
    DC.B $38,2,$3C,$69,$06,$E8
    DC.B $77,2,$AF,$E3,$85,$08
    DC.B $6F,2,$A4,$B6,$9D,$07
    DC.B $27,2,$A9,$CA,$3C,$D5
    DC.B $07,2,$98,$7F,$3A,$83
    DC.B $17,8,$A5,$C1,$4C,$62
    DC.B $00,8,$43,$A0,$A5,$78
    DC.B $37,4,$7D,$A7,$A4,$B6
    DC.B $18,1,$C6,$C7,$C9,$36
    DC.B $33,4,$D8,$AE,$6A,$21
    DC.B $0E,4,$FB,$EF,$B8,$57
    DC.B $0F,2,$D3,$67,$2E,$47
    DC.B $05,1,$D6,$B6,$5F,$ED
    DC.B $11,8,$22,$D2,$F4,$B2
    DC.B $85,1,$90,$22,$F6,$22
    DC.B $63,2,$1E,$67,$50,$BE
    DC.B $38,4,$9D,$07,$F5,$04
    DC.B $1B,1,$36,$11,$AE,$D3
    DC.B $0B,4,$8E,$02,$FA,$36
    DC.B $23,1,$E0,$5B,$11,$C3
    DC.B $EA,1,$1F,$3B,$EF,$E6
    DC.B $65,2,$13,$EC,$D8,$AE
    DC.B $EA,1,$1F,$3B,$EF,$E6
    DC.B $3A,2,$16,$08,$B3,$56
    DC.B $16,4,$97,$C3,$A9,$DF
    DC.B $18,1,$C6,$C7,$C9,$36
    DC.B $39,4,$08,$E3,$93,$02
    DC.B $33,1,$5D,$8E,$E1,$CA
    DC.B $12,4,$F2,$5E,$1E,$80
    DC.B $B5,1,$74,$84,$C9,$A5
    DC.B $1C,8,$9D,$07,$F5,$04
    DC.B $DD,1,$A7,$A4,$B6,$9D
    DC.B $69,1,$20,$F5,$C6,$04
    DC.B $00,8,$43,$A0,$A5,$78
    DC.B $2D,4,$E5,$74,$84,$C9
    DC.B $2A,1,$7F,$39,$8E,$02
    DC.B $4B,2,$D7,$6A,$4A,$03
    DC.B $E9,1,$51,$1F,$3B,$EF
    DC.B $AA,1,$A8,$66,$0F,$1F
    DC.B $0D,4,$8E,$E1,$CA,$55
    DC.B $7C,2,$BB,$F2,$B8,$5B
    DC.B $10,1,$3A,$83,$02,$FE
    DC.B $32,1,$6C,$5D,$8E,$E1
    DC.B $EC,1,$EF,$E6,$AF,$E3
    DC.B $8B,1,$B2,$C4,$E0,$A0
    DC.B $40,1,$D5,$DD,$5C,$96
    DC.B $79,2,$E6,$23,$B6,$DA
    DC.B $14,4,$3C,$D5,$E7,$8F
    DC.B $0F,8,$7F,$A5,$48,$3E
    DC.B $5F,2,$5B,$9E,$1C,$3E
    DC.B $19,4,$E6,$F6,$3C,$93
    DC.B $18,2,$6E,$B0,$6C,$5D
    DC.B $02,8,$3A,$83,$02,$FE
    DC.B $97,1,$6A,$4A,$03,$7B
    DC.B $24,4,$AD,$02,$FD,$C7
    DC.B $12,8,$AD,$02,$FD,$C7
    DC.B $6E,1,$6A,$40,$3C,$69
    DC.B $16,8,$6E,$6C,$31,$D3
    DC.B $15,8,$6F,$9F,$A8,$66
    DC.B $0B,8,$97,$C3,$A9,$DF
    DC.B $25,2,$1E,$80,$22,$39
    DC.B $11,8,$22,$D2,$F4,$B2
    DC.B $0C,8,$28,$D6,$5C,$10
    DC.B $86,1,$22,$F6,$22,$D2
    DC.B $03,8,$C6,$C7,$C9,$36
    DC.B $13,4,$22,$39,$A9,$CA
    DC.B $15,4,$3D,$BF,$DA,$FE
    DC.B $53,1,$8F,$3D,$BF,$DA
    DC.B $F7,1,$00,$BB,$F2,$B8
    DC.B $13,2,$C3,$22,$40,$AA
    DC.B $F3,1,$23,$B6,$DA,$B0
    DC.B $75,1,$08,$B3,$56,$7F
    DC.B $2F,2,$B0,$0D,$28,$D6
    DC.B $66,1,$3C,$93,$27,$20
    DC.B $9D,1,$A9,$37,$3D,$B2
    DC.B $DA,1,$A5,$62,$7D,$A7
    DC.B $13,4,$22,$39,$A9,$CA
    DC.B $1F,4,$39,$35,$A1,$05
    DC.B $32,4,$50,$BE,$13,$EC
    DC.B $11,8,$22,$D2,$F4,$B2
    DC.B -1

VALUES:
    DS.B DIS1
    DC.B $43,$A0,$A5,$78
    DC.B $87,$D6,$B6,$5F
    DC.B $ED,$CA,$1F,$9A
    DC.B $80,$AD,$98,$7F
    DC.B $3A,$83,$02,$FE
    DC.B $93,$5A,$36,$31
    DC.B $C6,$C7,$C9,$36
    DC.B $11,$AE,$D3,$67
    DC.B $2E,$47,$5C,$E0
    DC.B $5B,$11,$C3,$22
    DC.B $40,$AA,$7F,$39
    DC.B $8E,$02,$FA,$36
    DC.B $6E,$B0,$6C,$5D
    DC.B $8E,$E1,$CA,$55
    DC.B $FB,$EF,$B8,$57
    DC.B $EA,$BA,$96,$C0
    DC.B $D5,$DD,$5C,$96
    DC.B $F4,$D5,$55,$95
    DC.B $F2,$5E,$1E,$80
    DC.B $22,$39,$A9,$CA
    DC.B $3C,$D5,$E7,$8F
    DC.B $3D,$BF,$DA,$FE
    DC.B $97,$C3,$A9,$DF
    DC.B $86,$BC,$B0,$0D
    DC.B $28,$D6,$5C,$10
    DC.B $E6,$F6,$3C,$93
    DC.B $27,$20,$F5,$C6
    DC.B $04,$F0,$6A,$40
    DC.B $3C,$69,$06,$E8
    DC.B $16,$08,$B3,$56
    DC.B $7F,$A5,$48,$3E
    DC.B $39,$35,$A1,$05
    DC.B $78,$A9,$63,$06
    DC.B $F0,$90,$22,$F6
    DC.B $22,$D2,$F4,$B2
    DC.B $C4,$E0,$A0,$09
    DC.B $AD,$02,$FD,$C7
    DC.B $8B,$E1,$D7,$6A
    DC.B $4A,$03,$7B,$1F
    DC.B $DA,$A9,$37,$3D
    DC.B $B2,$32,$B8,$94
    DC.B $C7,$06,$A5,$59
    DC.B $6F,$9F,$A8,$66
    DC.B $0F,$1F,$A5,$0A
    DC.B $6E,$6C,$31,$D3
    DC.B $E5,$74,$84,$C9
    DC.B $A5,$C1,$4C,$62
    DC.B $D8,$72,$5B,$9E
    DC.B $1C,$3E,$3B,$3A
    DC.B $BC,$E1,$1E,$67
    DC.B $50,$BE,$13,$EC
    DC.B $D8,$AE,$6A,$21
    DC.B $AB,$72,$00,$87
    DC.B $8D,$ED,$D6,$3C
    DC.B $6F,$28,$A5,$62
    DC.B $7D,$A7,$A4,$B6
    DC.B $9D,$07,$F5,$04
    DC.B $08,$E3,$93,$02
    DC.B $81,$51,$1F,$3B
    DC.B $EF,$E6,$AF,$E3
    DC.B $85,$08,$E6,$23
    DC.B $B6,$DA,$B0,$00
    DC.B $BB,$F2,$B8,$5B
    DC.B $D7,$4F,$E8,$25
    DC.B $97,$E3,$B0,$A8
    DC.B $55,$F1,$21,$ED
    DC.B $AA,$19,$E1,$7F
    DC.B $8F,$4A,$22,$D7
    DC.B $5A,$1F,$7C,$17
    DC.B $B4,$73,$1E,$38
    DC.B $97,$7D,$5D,$9E
    DC.B $03,$60,$B9,$91
    DC.B $E9,$5C,$38,$76
    DC.B $06,$E7,$AC,$9E
    DC.B $61,$FC,$A7,$7D
    DC.B $2B,$99,$19,$07
    DC.B $1D,$85,$5B,$E1
    DC.B $BC,$82,$F5,$19
    DC.B $BE,$4B,$2C,$B9
    DC.B $A2,$03,$BE,$9C
    DC.B $A2,$58,$FD,$57
    DC.B $9C,$8E,$65,$59
    DC.B $FD,$07,$3C,$80
    DC.B $D1,$3A,$66,$FC
    DC.B $6B,$6D,$5C,$F5
    DC.B $1A,$83,$F0,$66
    DC.B $59,$40,$F9,$31
    DC.B $AE,$FE,$EF,$12
    DC.B $EF,$7F,$21,$98
    DC.B $98,$91,$3C,$9A
    DC.B $D3,$A6,$E3,$CD
    DC.B $92,$9A,$13,$AF
    DC.B $1C,$35,$A9,$C4
    DC.B $25,$A3,$B0,$13
    DC.B $6E,$D4,$C8,$1B
    DC.B $05,$F3,$A2,$08
    DC.B $61,$96,$F8,$8E
    DC.B $94,$5C,$1D,$E1
    DC.B $08,$93,$DC,$28
    DC.B $04,$42,$31,$11
    DC.B $C0,$D2,$2A,$6F
    DC.B $AB,$7B,$58,$CC
    DC.B $96,$9D,$30,$EE
    DC.B $8B,$FF,$C9,$03
    DC.B $FF,$A9,$86,$EE
    DC.B $29,$41,$37,$44
    DC.B $B7,$98,$45,$68
    DC.B $C8,$F8,$F9,$2B
    DC.B $8F,$9B,$B0,$81
    DC.B $90,$69,$73,$EC
    DC.B $B2,$11,$D4,$15
    DC.B $6B,$9A,$EF,$C6
    DC.B $9B,$41,$B1,$34
    DC.B $EE,$F0,$D1,$5C
    DC.B $04,$F1,$11,$CB
    DC.B $F6,$91,$8B,$2D
    DC.B $50,$C8,$1E,$0B
    DC.B $28,$44,$71,$F7
    DC.B $33,$4E,$5F,$0E
    DC.B $BD,$E8,$ED,$4C
    DC.B $7F,$84,$DB,$17
    DC.B $45,$AB,$BC,$41
    DC.B $30,$68,$BA,$1B
    DC.B $BD,$07,$A4,$92
    DC.B $9F,$EA,$C7,$53
    DC.B $44,$F7,$EC,$EE
    DC.B $4E,$F5,$A2,$29
    DC.B $B8,$FB,$04,$12
    DC.B $C8,$5E,$36,$F3
    DC.B $F6,$DF,$21,$C1
    DC.B $42,$B7,$03,$33
    DC.B $77,$D1,$E5,$5D
    DC.B $02,$CF,$98,$4B
    DC.B $32,$32,$5D,$D9
    DC.B $07,$EF,$51,$C1
    DC.B $FF,$A9,$D5,$12
    DC.B $A2,$5B,$8B,$30
    DC.B $C0,$3D,$AE,$01
    DC.B $43,$0F,$DE,$D1
    DC.B $A1,$69,$93,$5B
    DC.B $3B,$02,$64,$B4
    DC.B $CE,$91,$15,$47
    DC.B $AF,$F5,$FF,$C0
    DC.B $51,$AE,$0D,$62
    DC.B $F1,$82,$6D,$73
    DC.B $5D,$28,$47,$A8
    DC.B $71,$FD,$A4,$CD
    DC.B $E9,$38,$C4,$66
    DC.B $F1,$F9,$83,$62
    DC.B $24,$2F,$54,$A5
    DC.B $84,$1D,$4A,$7F
    DC.B $46,$0F,$08,$93
    DC.B $F2,$A6,$2F,$F8
    DC.B $98,$1D,$C8,$CF
    DC.B $61,$DF,$72,$2B
    DC.B $DE,$C6,$63,$D4
    DC.B $EB,$3E,$DF,$15
    DC.B $17,$5E,$D0,$13
    DC.B $DB,$90,$6F,$DF
    DC.B $AB,$F6,$72,$7A
    DC.B $02,$64,$FD,$48
    DC.B $A2,$E6,$4F,$99
    DC.B $D0,$F5,$4D,$04
    DC.B $65,$3E,$CA,$BC
    DC.B $BD,$77,$68,$22
    DC.B $82,$EB,$97,$75
    DC.B $57,$88,$8B,$00
    DC.B $99,$37,$97,$DC
    DC.B $89,$02,$A9,$3A
    DC.B $41,$9B,$8E,$26
    DC.B $6D,$74,$9E,$74
    DC.B $70,$00,$B3,$2F
    DC.B $7A,$FC,$42,$93
    DC.B $AE,$6B,$E5,$90
    DC.B $84,$86,$05,$F5
    DC.B $DD,$88,$B0,$5D
    DC.B $89,$D5,$F8,$67
    DC.B $07,$3D,$D5,$B7
    DC.B $5A,$48,$CA,$D0
    DC.B $77,$68,$1E,$45
    DC.B $D6,$1B,$91,$FF
    DC.B $ED,$25,$A9,$D8
    DC.B $2E,$7E,$CC,$59
    DC.B $E6,$EB,$77,$03
    DC.B $E4,$72,$03,$18
    DC.B $54,$04,$39,$07
    DC.B $88,$72,$F7,$30
    DC.B $88,$C1,$46,$89
    DC.B $49,$70,$A5,$F4
    DC.B $D0,$8B,$03,$27
    DC.B $CB,$CE,$B8,$5F
    DC.B $10,$0D,$86,$92
    DC.B $28,$A0,$C2,$AB
    DC.B $27,$7A,$E0,$C2
    DC.B $26,$E8,$ED,$D4
    DC.B $EF,$FD,$54,$F2
    DC.B $D8,$46,$04,$AD
    DC.B $48,$EB,$88,$4F
    DC.B $46,$D1,$D1,$92
    DC.B $55,$E0,$07,$F9
    DC.B $6C,$59,$92,$67
    DC.B $48,$67,$36,$A4
    DC.B $E6,$19,$F8,$D5
    DC.B $DC,$B2,$17,$50
    DC.B $D6,$CA,$10,$7A
    DC.B $73,$BF,$CD,$C6
    DC.B $B7,$02,$57,$62
    DC.B $E5,$97,$F4,$6E
    DC.B $BD,$40,$16,$CB
    DC.B $B6,$8F,$A8,$A7
    DC.B $9A,$A8,$6C,$FE
    DC.B $02,$D5,$F8,$64
    DC.B $49,$C3,$1C,$86
    DC.B $8B,$0F,$B3,$CC
    DC.B $A6,$6D,$A8,$5C
    DC.B $E8,$B1,$2F,$26
    DC.B $51,$3F,$1E,$CE
    DC.B $C6,$7C,$30,$9A
    DC.B $55,$1E,$26,$26
    DC.B $48,$14,$4A,$1D
    DC.B $F7,$7F,$C2,$F4
    DC.B $1B,$22,$62,$79
    DC.B $59,$60,$A7,$41
    DC.B $08,$E7,$7E,$B1
    DC.B $34,$2B,$B6,$78
    DC.B $77,$38,$D5,$69
    DC.B $1E,$26,$BC,$D5
    DC.B $E4,$F2,$4A,$EC
    DC.B $0C,$BE,$9C,$3C
    DC.B $34,$76,$6E,$06
    DC.B $72,$10,$D9,$5E
    DC.B $FF,$4D,$50,$94
    DC.B $95,$E5,$B9,$1C
    DC.B $96,$D3,$22,$FE
    DC.B $56,$89,$9F,$26
    DC.B $CD,$56,$53,$12
    DC.B $09,$ED,$85,$F2
    DC.B $5B,$D4,$A8,$93
    DC.B $42,$1E,$F4,$DD
    DC.B $6A,$67,$8B,$8E
    DC.B $A3,$67,$C3,$B4
    DC.B $D9,$08,$10,$2B
    DC.B $E6,$81,$13,$E4
    DC.B $59,$14,$E6,$01
    DC.B $3B,$13,$FD,$07
    DC.B $D3,$58,$B3,$F9
    DC.B $D5,$07,$18,$EA
    DC.B $2C,$A4,$3F,$32
    DC.B $71,$D1,$5D,$8A
    DC.B $3A,$EA,$D8,$6F
    DC.B $DF,$AA,$53,$91
    DC.B $56,$70,$E7,$2F
    DC.B $EB,$52,$89,$5D
    DC.B $87,$72,$7F,$65
    DC.B $D3,$31,$02,$00
    DC.B $00,$00,$00,$00

