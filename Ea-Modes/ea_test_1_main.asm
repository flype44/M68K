;==============================================================================
; ASM Testcase
; flype, 2015-09-28
; ea_test_1_main.asm
; WORK IN PROGRESS
;==============================================================================

;==============================================================================
; Constants
;==============================================================================

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
