;===================================================
; Testcase
; Pow(Number, Exponent)
;===================================================

;===================================================
; Entry point
;===================================================

;      DC.L 0
;      DC.L START
;      SECTION .fastram

ASSERT EQU $00D0000C    ; Assert Zero Register

START: LEA    DATA,A0   ; Load DATA in A0
LOOP:  MOVE.L (A0)+,D0  ; Read Number
       MOVE.L (A0)+,D1  ; Read Exponent
       CMPI.L #-1,D0    ; Test Number
       BEQ    EXIT      ; If Number = -1 Then Exit
       JSR    Pow       ; D7 = Pow(Number, Exponent)
       SUB.L  (A0)+,D7  ; D7 = D7 - Precalc
       BEQ    LOOP      ; If D7 = 0 Then branch to LOOP
       MOVE.L D7,ASSERT ; Assert Zero Register
       STOP   #-1       ; Stop with error
EXIT:  RTS              ; Exit program

;===================================================
; Pow(Number, Exponent) = Precalc
;===================================================

DATA:  DC.L 0,3,0  ; Pow(0, 3) = 0
       DC.L 3,0,1  ; Pow(3, 0) = 1
       DC.L 3,1,3  ; Pow(3, 1) = 3
       DC.L 3,2,9  ; Pow(3, 2) = 9
       DC.L 3,3,27 ; ...
       DC.L 3,4,81
       DC.L 3,5,243
       DC.L 3,6,729
       DC.L 3,7,2187
       DC.L 3,8,6561
       DC.L 3,9,19683
       DC.L 3,10,59049
       DC.L 30,8,-1029996288
       DC.L 12,2,144
       DC.L 125,3,1953125
       DC.L 27,120,-942556895
       DC.L 80000,1,80000
       DC.L 80000,2,2105032704
       DC.L $FFFF,3,196607
       DC.L $FFFFF,3,3145727
      ;DC.L $7FFFFF,3,25165823
      ;DC.L $FFFFFF,3,50331647
       DC.L -1

;===================================================
; Pow(Number, Exponent)
; Input  : D0 = Number
;          D1 = Exponent
; Output : D7 = Result
;===================================================

Pow:  MOVEM.L D0-D3,-(SP) ; Save registers
      CLR.L   D2          ; D2 = 0
      CLR.L   D3          ; D3 = 0
      CLR.L   D7          ; D7 = 0
      CMPI.L  #0,D0       ; Test Number
      BEQ     PowX        ; If D0 = 0 Then Exit
      MOVE.L  #1,D7       ; D7 = 1
PowE: CMPI.L  #0,D1       ; Test Exponent
      BEQ     PowX        ; If D1 = 0 Then Exit
      SUBI.L  #1,D1       ; D1 = D1 - 1
      MOVE.L  D0,D2       ; D2 = D0
      MOVE.L  D7,D3       ; D3 = D7
PowN: CMPI.L  #1,D2       ; Test Number
      BEQ     PowE        ; If D2 = 1 Then branch to PowE
      SUBI.L  #1,D2       ; D2 = D2 - 1
      ADD.L   D3,D7       ; D7 = D7 + D3
      BRA     PowN        ; Branch to PowN
PowX: MOVEM.L (SP)+,D0-D3 ; Restore registers
      RTS                 ; Exit SubRoutine

;===================================================
