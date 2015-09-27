;=================================================
; Number ==> Roman ==> Number
; flype, 2015-09-20
;=================================================

;=================================================
; Constants
;=================================================

assert_zero EQU $00D0000C ; Magical register

;=================================================
; Entry Point
;=================================================

START:
    LEA    VALUES,A0      ; Address of first Data
NEXT:
    CLR.L  D0             ; 
    CLR.L  D1             ; 
    CLR.L  D7             ; Error Counter
    MOVE.B (A0)+,D0       ; A0 = Data Address
                          ; D0 = Data Length
    JSR    RomanToNumber  ; Jump to Sub-Routine
                          ; D1 = Result
    ADDA.L D0,A0          ; A0 = Precalc Value Address
	MOVE.L A0,D5          ; Store A0 in D5 for Odd check
	ANDI.L #1,D5          ; Check if Odd Address
	ADD.L  D5,A0          ; Add 0 or 1 to the address
    MOVE.W (A0)+,D0       ; D0 = Precalc Value
    SUB.W  D1,D0          ; D0 = D0 - D1
    MOVE.B D0,assert_zero ; If D0 != 0 Then Assert
    CMPI.B #0,D0          ; If (A0) != 0 Then
    BEQ    NEXT2
    ADDQ   #1,D7          ; Increment Error Counter
NEXT2:
    CMPI.B #0,(A0)        ; If (A0) != 0 Then
    BNE    NEXT           ; Jump to Next Data
EXIT:
    RTS                   ; STOP   #-1

;=================================================
; Roman To Number
; Input  A0 : Data Address ==> 'MMMMMMMMMDCCCLXXXVIII'
; Input  D0 : Data Length  ==> 21
; Output D1 : Result       ==> 9888
;=================================================

RomanToNumber:
      MOVEA.L A0,A1         ; A1 = Roman Input Start Address
      ADDA.L  D0,A1         ; A1 = Roman Input End Address
      SUBA.L  #1,A1         ; A1 = Roman Input End Address - 1
      CLR.L   D1            ; D1 = 0
      CLR.L   D2            ; D2 = 0
      CLR.L   D3            ; D3 = 0
      CLR.L   D4            ; D4 = 0
      MOVE.L  A0,D4         ; D4 = Roman Input Start Address
      SUBI.L  #1,D4         ; D4 = Roman Input Start Address - 1
R2N0: CMP.L   D4,A1         ; If Start of string Then Exit
	  BEQ     R2N9          ; Jump to Exit
R2NI: CMPI.B  #'I',(A1)     ; If A1 = I Then +1
	  BNE     R2NV          ; 
	  MOVE.W  #1,D2         ; 
	  BRA     R2N1          ; 
R2NV: CMPI.B  #'V',(A1)     ; If A1 = V Then +5
	  BNE     R2NX          ; 
	  MOVE.W  #5,D2         ; 
	  BRA     R2N1          ; 
R2NX: CMPI.B  #'X',(A1)     ; If A1 = X Then +10
	  BNE     R2NL          ; 
	  MOVE.W  #10,D2        ; 
	  BRA     R2N1          ; 
R2NL: CMPI.B  #'L',(A1)     ; If A1 = L Then +50
	  BNE     R2NC          ; 
	  MOVE.W  #50,D2        ; 
	  BRA     R2N1          ; 
R2NC: CMPI.B  #'C',(A1)     ; If A1 = C Then +100
	  BNE     R2ND          ; 
	  MOVE.W  #100,D2       ; 
	  BRA     R2N1          ; 
R2ND: CMPI.B  #'D',(A1)     ; If A1 = D Then +500
	  BNE     R2NM          ; 
	  MOVE.W  #500,D2       ; 
	  BRA     R2N1          ; 
R2NM: CMPI.B  #'M',(A1)     ; If A1 = M Then +1000
	  BNE     R2N1          ; 
	  MOVE.W  #1000,D2      ; 
	  BRA     R2N1          ; 
R2N1: CMP.W   D2,D3         ; Compare Value and Old Value 
	  BGT     R2N3          ; If Value < Old Value
R2N2: ADD.W   D2,D1         ;   Result += Value
	  BRA     R2N4          ; Else
R2N3: SUB.W   D2,D1         ;   Result -= Value
R2N4: MOVE.W  D2,D3         ; Remember Value
      SUB.L   #1,A1         ; Next Roman Digit
      BRA     R2N0          ; Jump to Start
R2N9: RTS                   ; Exit Sub-Routine

;=================================================
; Data Section
;=================================================

VALUES:
	DC.B 2,'I','V'
	DC.W 4
	DC.B 2,'V','I'
	DC.W 6
	DC.B 2,'IX'
	DC.W 9
	DC.B 2,'XI'
	DC.W 11
	DC.B 4,'XIII'
	DC.W 13
	DC.B 4,'CDXC'
	DC.W 490
	DC.B 2,'DX'
	DC.W 510
	DC.B 8,'CMXXVIII'
	DC.W 928
	DC.B 8,'MMCDXXIV'
	DC.W 2424
	DC.B 12,'MMMMMMCCXVII'
	DC.W 6217
	DC.B 14,'MMMMMCDXXXVIII'
	DC.W 5438
	DC.B 21,'MMMMMMMMMDCCCLXXXVIII'
	DC.W 9888
	DC.B 15,'MMMMMMMMMCMXCIX'
	DC.W 9999
	DC.B 0

;=================================================
; End
;=================================================
