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
 DC.B 61,'5670974488298753995448116342931435344270115110442811654385500'
 DC.B 26,'62460188030671876933881140'
 DC.B 50,'53572357641892904426736736399863909810135118954990'
 DC.B 55,'1644249247928304167393518735930454873090914746653626450'
 DC.B 61,'4497102332846622125559266033003863229151147365951183076465950'
 DC.B 22,'3727206060194862809720'
 DC.B 25,'2332333545182468788492180'
 DC.B 20,'01350657679268267170'
 DC.B 37,'0517194635293988944380926991896323870'
 DC.B 60,'236833357295401633683358177548802724837174620762222589990630'
 DC.B 18,'472697652002392520'
 DC.B 31,'3538999728167391109532496629770'
 DC.B 33,'516436365076293757718697830259500'
 DC.B 61,'7408152568434455417970415084942920327459445962368944782321220'
 DC.B 57,'718505669156349572391967369877008382453116811159452007250'
 DC.B 38,'79503002915556827124734734388824922400'
 DC.B 53,'66925898476017309409886070718360309378417252446883910'
 DC.B 49,'1685697941749650663686837967238785112161306046000'
 DC.B 49,'0065493906976204523835663605144379210903122815300'
 DC.B 45,'514417162795609038962501448985195539821839170'
 DC.B 0
 DC.B 0

PRECALC:
 DC.B 04,09,01,10,04,07,05,01,10,03
 DC.B 07,04,02,07,02,02,05,10,01,08
 DC.W 102

;==========================================================
; End of file
;==========================================================
