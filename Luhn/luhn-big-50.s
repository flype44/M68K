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
 DC.B 54,'930561494977261640808195021642966300825734294543819640'
 DC.B 45,'137213527820354949959709973498103793166008700'
 DC.B 47,'03561563784215205199107476581946510819588940610'
 DC.B 32,'12929685624747589838182921849390'
 DC.B 50,'87651399682258399802098376028159981257451782155710'
 DC.B 35,'02537704266403660014211782462226100'
 DC.B 35,'77031623721934751520751083202931490'
 DC.B 41,'87177783734478883892799107055114618513680'
 DC.B 44,'63446213192027573878108987524662997517926070'
 DC.B 42,'947988274985618550662800249558352161270850'
 DC.B 21,'714978563435342195220'
 DC.B 61,'5792377680100291648447217832725206030696495889873860098770920'
 DC.B 56,'53080329171107144492569325897053469632489424040134536210'
 DC.B 42,'059799702378432453484811825803052350651220'
 DC.B 48,'926280809208185895212224871380450359720780001260'
 DC.B 56,'43613554329410078011807187895379020651919710729019586550'
 DC.B 34,'0108152785176550330842194173524000'
 DC.B 50,'77490088080015495494764019639778061549672213633440'
 DC.B 37,'9528239070487314628652430671315352200'
 DC.B 32,'81800475977579332791776351491400'
 DC.B 30,'745066039621893001188527930310'
 DC.B 24,'438186079761631796485430'
 DC.B 31,'4444792884875299080100923779160'
 DC.B 28,'4882030150878332631998797000'
 DC.B 28,'2055656329046246733082974970'
 DC.B 20,'89384703730282121340'
 DC.B 49,'5284701266532400710953159045073392292843904334030'
 DC.B 20,'55598854884413194830'
 DC.B 34,'8212008184703926300673153615331980'
 DC.B 52,'4731907942466406293537578473017260231055049646025650'
 DC.B 30,'782953052967603175680319242540'
 DC.B 55,'2535296068602526570186334381798568788978987717500229270'
 DC.B 47,'11782682947351594552860342561650952487502647950'
 DC.B 61,'0838678419769443441561418060072370102803797371988626820430090'
 DC.B 48,'273235001101335973837506731051332409779783497880'
 DC.B 33,'007314903537883536155657248289950'
 DC.B 43,'0470547609584906165599933153485621782153850'
 DC.B 20,'71071129663938750900'
 DC.B 57,'696517938197107093522767188383661841234336167660771879570'
 DC.B 19,'2764229190652676320'
 DC.B 42,'791806978304125043207706912521053625892080'
 DC.B 60,'646795389112927139618653358616384328991121133230450803490040'
 DC.B 26,'22501844244077801251962330'
 DC.B 44,'03758223066617605977010366546755063761433380'
 DC.B 55,'9375053254949056253643967579312666130580676842501253150'
 DC.B 19,'4740911412891656030'
 DC.B 41,'20158068185755739574959562235047754213680'
 DC.B 30,'408696120107580012245253214030'
 DC.B 27,'098867870438946881726290290'
 DC.B 33,'078180525167879600333950007091160'
 DC.B 0
 DC.B 0

PRECALC:
 DC.B 2,8,1,3,8,1,2,2,1,9,10,4,1,8,9,5,7,6,5,8,5,4,5,5,9,6,5,9,5,5,2
 DC.W 263

;==========================================================
; End of file
;==========================================================
