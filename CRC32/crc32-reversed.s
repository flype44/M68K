;==========================================================
; ASM Testcase
; flype, 2015-09-25
; crc32_reversed($04C11DB7) = $EDB88320
;==========================================================
; http://pastebin.com/3kpLUxMQ
; http://www.simplycalc.com/crc32-text.php#
;==========================================================

; function crc32_reversed(polynomial) {
;   reversed = 0
;   for (i = 0; i < 32; i++) {
;     reversed = ((reversed << 1) | ((polynomial >> i) & 1))
;   }
;   return reversed
; }

;==========================================================
; Constants
;==========================================================

ASSERT_ZERO EQU $00D0000C

;==========================================================
; MAIN()
; A0 = Polynomials
; A1 = Polynomials, Precalculated
; D0 = Result of CRC32REV()
;==========================================================

START:
	LEA		POLYNOMIAL,A0	; polynomial = $04C11DB7 (input)
	LEA		REVERSED,A1		; reversed = $EDB88320 (precalc)
LOOP:
	JSR		CRC32REV		; CRC32REV(polynomial)
	SUB.L   (A1)+,D0		; result = result - reversed
	MOVE.L  D0,ASSERT_ZERO	; Assert D0 == 0
	CMP.L   #0,(A0)+		; Check if last polynomial
	BNE     LOOP			; Continue while != 0
EXIT:
	RTS

;==========================================================
; CRC32REV()
; Input  : A0 = polynomial ($04C11DB7)
; Output : D0 = reversed   ($EDB88320)
;==========================================================

CRC32REV:
	CLR.L	D0				; reversed = 0
	CLR.L	D1				; polynomial = 0
	CLR.L	D2				; tmp = 0
	CLR.L	D3				; i = 0
CRC32REV_LOOP:				; for (i = 0; i < 32; i++)
	MOVE.L  (A0),D1			; polynomial
	ASR.L	D3,D1			; tmp = (polynomial >> i)
	ASL.L	#1,D0			; reversed = (reversed << 1)
	ANDI.L	#1,D1			; tmp = (tmp & 1)
	ADDQ.B	#1,D3			; i++
	OR.L	D1,D0			; reversed = (reversed | tmp)
	CMP.L	#32,D3			; i < 32
	BNE		CRC32REV_LOOP	; continue
	RTS						; return reversed

;==========================================================
; Data Section
;==========================================================

POLYNOMIAL:
	DC.L $04C11DB7,$71625344,$01010101,$0ABEEFC3
	DC.L $12345678,$00007FFF,$7FFFFFFF,$FFFFFFFF
	DC.L 0

REVERSED:
	DC.L $EDB88320,$22CA468E,$80808080,$C3F77D50
	DC.L $1E6A2C48,$FFFE0000,$FFFFFFFE,$FFFFFFFF
	DC.L 0

;==========================================================
; End of file
;==========================================================
