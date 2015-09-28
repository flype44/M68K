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
 DC.B 57,'534644328612648683437765238292788989580848073444006641000'
 DC.B 16,'2617524076194960'
 DC.B 20,'94157767773532752230'
 DC.B 55,'5014882815169637389123934036186918852710027605737723900'
 DC.B 41,'32901973753182275872892713210516892251340'
 DC.B 35,'04534772735184783494914500203173640'
 DC.B 45,'912860672380468332297531562436704496387783290'
 DC.B 31,'5653869542452120250259027216250'
 DC.B 19,'4559127952724186030'
 DC.B 47,'63070384034821651414527542604868485287553454060'
 DC.B 44,'95738829279965641710631685108609806913962500'
 DC.B 30,'519681810372519070084903293160'
 DC.B 47,'28998973822701993035239272342484316572893141440'
 DC.B 26,'48146858791973646836049680'
 DC.B 23,'35107336675616199295760'
 DC.B 50,'24742334559574204513068280778768738796368866771350'
 DC.B 53,'02238877608100750447409127240511335051185966118175920'
 DC.B 32,'38272068127280789902350073359220'
 DC.B 21,'711073992163988537730'
 DC.B 52,'9632632315809617973728910977912216605643200520189420'
 DC.B 43,'3203160714748508545485115994905587663888320'
 DC.B 19,'9249779341481158420'
 DC.B 31,'4439435790616819420539385111750'
 DC.B 19,'3376337576014872680'
 DC.B 43,'4603654809829579413400523845899921108629400'
 DC.B 56,'33500582136075761672250843687706868010850187663458674480'
 DC.B 55,'9502676699600867121889690975951467127200990988729230170'
 DC.B 40,'8964856102679705660824904343496651803810'
 DC.B 45,'385632165691320625528767984766845302797074300'
 DC.B 23,'12902547642127909476150'
 DC.B 27,'660477590321897725761156940'
 DC.B 36,'930753397253695398929051678846576300'
 DC.B 46,'8869125388862767301630110073460596258939842720'
 DC.B 22,'8152234483606112678850'
 DC.B 59,'71798400731085472530691900649326106973345865851721422975430'
 DC.B 30,'341334630374839086762914366520'
 DC.B 20,'48663898656786926010'
 DC.B 26,'04071142504172952989136130'
 DC.B 51,'527833959116536273781772003302722547539512802694880'
 DC.B 28,'5011001212645689515678532900'
 DC.B 60,'768291536589824092491189269667165329410551904422483257241900'
 DC.B 59,'11125173376749371954259851644374926174313027682830923174950'
 DC.B 36,'216625065104547171051761281640246560'
 DC.B 35,'46790898719848424173134833191135130'
 DC.B 54,'116074840639885974930444516624384568517014052277271550'
 DC.B 24,'483823899527081671168660'
 DC.B 35,'93561798706355349955764936339750990'
 DC.B 33,'775769418827517477262399022706080'
 DC.B 52,'7173088479736590749120179900424085750436912320733160'
 DC.B 28,'3706970055581515330846158180'
 DC.B 0
 DC.B 0

PRECALC:
 DC.B 05,08,05,07,05,03,03,08,07,04
 DC.B 07,10,05,09,10,05,08,04,07,09
 DC.B 10,07,07,07,05,09,01,01,10,01
 DC.B 07,03,05,03,07,01,07,01,01,09
 DC.B 04,05,03,10,09,06,10,09,03,03
 DC.W 293

;==========================================================
; End of file
;==========================================================
