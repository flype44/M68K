;=================================================
; Number ==> Roman ==> Number
; flype, 2015-09-20
;=================================================

;=================================================
; Constants
;=================================================

assert_zero EQU $00D0000C ; magical register

;=================================================
; Entry Point
;=================================================

START:
    JSR    RomanToNumber
    STOP   #-1

INPUT:
	DC.B 'MMMMMMMMMDCCCLXXXVIII'

INPUTLEN:
	DC.B *-INPUT

;=================================================
; Number To Roman
; Input  D0 : 9888
; Output A0 : 'MMMMMMMMMDCCCLXXXVIII'
;=================================================

NumberToRoman:
    RTS

;=================================================
; Roman To Number
; Input  A0 : 'MMMMMMMMMDCCCLXXXVIII'
; Output D0 : 9888
;=================================================

RomanToNumber:
      LEA    INPUTLEN-1,A0 ; Roman Input End
      LEA    INPUT-1,A1    ; Roman Input Start
      CLR.L  D1            ; Value
      CLR.L  D2            ; Value Old
      CLR.L  D3            ; Result
R2N0: CMP.L  A0,A1         ; Check Start of string
	  BEQ    R2N9          ; Exit Routine
R2NI: CMPI.B #'I',(A0)
	  BNE    R2NV
	  MOVE.W #1,D1
	  BRA    R2N1
R2NV: CMPI.B #'V',(A0)
	  BNE    R2NX
	  MOVE.W #5,D1
	  BRA    R2N1
R2NX: CMPI.B #'X',(A0)
	  BNE    R2NL
	  MOVE.W #10,D1
	  BRA    R2N1
R2NL: CMPI.B #'L',(A0)
	  BNE    R2NC
	  MOVE.W #50,D1
	  BRA    R2N1
R2NC: CMPI.B #'C',(A0)
	  BNE    R2ND
	  MOVE.W #100,D1
	  BRA    R2N1
R2ND: CMPI.B #'D',(A0)
	  BNE    R2NM
	  MOVE.W #500,D1
	  BRA    R2N1
R2NM: CMPI.B #'M',(A0)
	  BNE    R2N1
	  MOVE.W #1000,D1
	  BRA    R2N1
R2N1: CMP.W  D1,D2 ; Compare Value, Old Value 
	  BGT    R2N3  ; If Value < Old Value Then Sub Else Add
R2N2: ADD.W  D1,D3 ; Result += Value
	  BRA    R2N4
R2N3: SUB.W  D1,D3 ; Result -= Value
R2N4: MOVE.W D1,D2 ; Remember Value
      SUB    #1,A0 ; Next Roman Digit
      BRA    R2N0  ; 
R2N9: RTS

;=================================================
; End
;=================================================
