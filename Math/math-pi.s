;=====================================================
; 68k test
; Calc Pi
;=====================================================

assert_zero EQU $00D0000C  ; Magical register

SCALE  EQU 10000
VALUE  EQU  2000
DIGITS EQU    50

;=====================================================

Start:
	clr.l  d0
	clr.l  d1
	clr.l  d6
	clr.l  d7
	lea    values,a0    ; Load values array in A0
	lea    result,a1    ; Load result space in A1
	move.l #DIGITS-1,d7 ; i = decimals
InitVals:               ; For i = 0 To decimals
	move.w #VALUE,(a0)+ ;   values(i) = #VALUE
	dbf    d7,InitVals  ; Next i
	move.l #DIGITS-1,d7 ; i = decimals
LoopI:                  ; While i > 0
	move.l #0,d0        ; sum = 0
	move.l d7,d6        ; j = i
	lea    values,a0    ; Load values array in A0
LoopJ:
	move.w (a0,d6.W),d1 ; values(j)
	mulu   #SCALE,d1    ; SCALE * values(j)
	mulu   d6,d0        ; sum * j
	add.l  d1,d0        ; (sum * j) + (SCALE * values(j))
	nop                 ; values(j) = sum % ( j * 2 - 1 )
	nop                 ; sum / ( j * 2 - 1 )
	dbf    d6,LoopJ     ; j - 1
	nop                 ; Store "carry + sum / #SCALE" in Result
	nop                 ; carry = sum % SCALE
	sub.l  #14,d7       ; i - 14
	bge    LoopI        ; 
	stop   #-1          ; stop execution

;=====================================================

values: ds.w DIGITS    ; Dim values(decimals)
result: ds.b 100        ; Dim result

;=====================================================
