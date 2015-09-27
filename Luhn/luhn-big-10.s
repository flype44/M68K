;==========================================================
; ASM Testcase
; flype, 2015-09-26
; luhn_checksum()
;==========================================================
; http://www.simplycalc.com/luhn-source.php
;==========================================================

;==========================================================
; Constants
;==========================================================

ASSERT_ZERO EQU $00D0000C

;==========================================================
; MAIN()
; A0 = VALUES
; A1 = PRECALC
; D0 = Result
; D1 = Value Bytes Length
; D7 = Total Result
;==========================================================

;	DC.L	0
;	DC.L	START
;	SECTION .FASTRAM

START:
	LEA		VALUES,A0		; Values
	LEA		PRECALC,A1		; Checksums
	CLR.L	D7				; Total Result
LOOP:
	CLR.L	D0				; Result
	CLR.L	D1				; Value Bytes Length
	MOVE.B	(A0),D1			; Read length
	JSR		LUHN			; Luhn(Value)
	ADD.L	D0,D7			; Total Result
	SUB.B	(A1)+,D0		; Result - Precalc
	MOVE.L	D0,ASSERT_ZERO	; Assert D0 == 0
	MOVE.B	(A0),D1			; Read length
	ADD.L	D1,A0			; Next Value
	ADD.L	#1,A0			; 
	CMP.B	#0,(A0)			; Check if last value
	BNE		LOOP			; Continue while != 0
EXIT:
	SUB.W	(A1),D7			; Total Result - Total Precalc
	MOVE.L	D0,ASSERT_ZERO	; Assert D0 == 0
	TST		$0				; FLUSH
	;STOP	#-1				; STOP SIM
	RTS

;==========================================================
; LUHN()
; Input  : A0 = Value
; Input  : D1 = Value Bytes Length
; Output : D0 = Checksum
;==========================================================

LUHN:
	CLR.L	D0				; Checksum
	CLR.L	D3				; Digit
	MOVE.L	D1,D2			; Parity = Length
	ANDI.L	#1,D2			; Parity % 2
	SUBI.L	#1,D1			; Length - 1
LUHNLOOP:
	MOVE.B	1(A0,D1),D3		; Digit = code.charAt(i)
	SUBI.B 	#$30,D3			; Digit = parseInt(Digit)
	MOVE.L	D1,D4			; i
	ANDI.L	#1,D4			; i % 2
	CMP.L	D4,D2			; Compare D4 and D2
	BNE		LUHNNEXT1		; If (i % 2 == Parity)
	LSL.L	#1,D3			; Digit * 2
LUHNNEXT1:
	CMPI.L	#9,D3			; Compare 9 and D3
	BLE		LUHNNEXT2		; If (Digit > 9)
	SUBI.L	#9,D3			; Digit - 9
LUHNNEXT2:
	ADD.L	D3,D0			; Checksum + Digit
	DBF		D1,LUHNLOOP		; Continue
LUHNEXIT:
	DIVU.W	#10,D0			; Checksum / 10
	SWAP	D0				; 
	MOVE.W	D0,D1			; Checksum % 10
	MOVE.L	#10,D0			; 
	SUB.L	D1,D0			; 10 - Checksum
	RTS						; return Checksum

;==========================================================
; Data Section
;==========================================================

VALUES:
 DC.B 25,'8328862298578202205379720'
 DC.B 56,'50631684681189315926863300553082879705989939976166111450'
 DC.B 44,'20094585914287136288132640154424825050549200'
 DC.B 22,'9751705353913203069600'
 DC.B 22,'1773857760424286031740'
 DC.B 32,'93416676664628444183053578753810'
 DC.B 48,'193468087118714843223838567503465233582375949090'
 DC.B 23,'01638279059940134397700'
 DC.B 33,'602127703682311858806168622305370'
 DC.B 36,'785774249107485202381580950755958530'
 DC.B 0
 DC.B 0

PRECALC:
 DC.W 67

;==========================================================
; End of file
;==========================================================
