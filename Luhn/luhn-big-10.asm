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
	MOVE.L	D7,ASSERT_ZERO	; Assert D7 == 0
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
 DC.B 45,'487367100705340405608930805511103671150647760'
 DC.B 39,'734108924535991497099231928800878444060'
 DC.B 41,'03773174856683380550761255573273783074890'
 DC.B 35,'25900622550294444004337430874302220'
 DC.B 56,'80521299531116078877266031293154412807895562407138720070'
 DC.B 52,'7287052292349582485921596139115345642231941827767390'
 DC.B 22,'8919816265804639764490'
 DC.B 20,'10251715072259637510'
 DC.B 44,'77802186293053180678706609821154623094853570'
 DC.B 28,'3515391118694099328306405320'
 DC.B 0
 DC.B 0

PRECALC:
 DC.B 05,02,04,08,09,02,04,02,09,06
 DC.W 51

;==========================================================
; End of file
;==========================================================
