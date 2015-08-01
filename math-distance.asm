;===================================================
; Testcase
; Distance between 2 points.
;===================================================

;===================================================
; Entry point
;===================================================

;      DC.L 0
;      DC.L START
;      SECTION .fastram

ASSERT EQU $00D0000C    ; Assert Zero Register

START:
      LEA    DATA,A0   ; Load DATA in A0
LOOP: MOVE.L (A0)+,D0  ; Read Ax
      CMPI.L #-1,D0    ; Test Ax
      BEQ    EXIT      ; If Ax = -1 Then Exit
      MOVE.L (A0)+,D1  ; Read Ay
      MOVE.L (A0)+,D2  ; Read Bx
      MOVE.L (A0)+,D3  ; Read By
      JSR    Dist      ; D7 = Dist(Ax, Ay, Bx, By)
      SUB.L  (A0)+,D7  ; D7 = D7 - Precalc
      BEQ    LOOP      ; If D7 = 0 Then branch to LOOP
      MOVE.L D7,ASSERT ; Assert Zero Register
      STOP   #-1       ; Stop with error
EXIT: RTS              ; Exit program

;===================================================
; Self-verifying data
; (Ax,Ay,Bx,By,Distance)*
;===================================================

DATA: DC.L 2,3,7,9,7     ; Dist(2,3,7,9) = 7
      DC.L 3,8,15,23,19  ; Dist(3,8,15,23) = 19
      DC.L 10,2,24,19,22 ; ...
      DC.L 42,38,120,247,223
      DC.L 142,138,1120,1247,1478
      DC.L $234,$345,$456,$654,954
      DC.L -1

;===================================================
; Dist(Ax, Ay, Bx, By)
; Input  : D0 = Ax
;          D1 = Ay
;          D2 = Bx
;          D3 = By
; Output : D7 = Result
;===================================================

Dist: MOVEM.L D0-D6,-(SP) ; Save registers
      MOVE.L  D0,D4       ; D4 = D0
      MOVE.L  D1,D5       ; D5 = D1
      SUB.L   D4,D2       ; D2 = Bx-Ax
      MOVE.L  D2,D0       ; D0 = D2
      MOVEQ   #2,D1       ; D1 = 2
      JSR     Pow         ; Pow(D0, D1)
      MOVE.L  D7,D6       ; D6 = D7
      SUB.L   D5,D3       ; D3 = By-Ay
      MOVE.L  D3,D0       ; D0 = D3
      MOVEQ   #2,D1       ; D1 = 2
      JSR     Pow         ; Pow(D0, D1)
      ADD.L   D7,D6       ; D6 = D6 + D7
      MOVE.L  D6,D0       ; D0 = D6
      JSR     Sqrt        ; Sqrt(D6)
DisX: MOVEM.L (SP)+,D0-D6 ; Restore registers
      RTS                 ; Exit SubRoutine

;===================================================
; Sqrt(Number)
; Input  : D0 = Number
; Output : D7 = Result
;===================================================

Sqrt: MOVEM.L D1-D2,-(SP) ; Save registers
      CLR.L   D7          ; D7 = 0
      CLR.L   D1          ; D1 = 0
      MOVE.L  #1,D2       ; D2 = 1
SqrL: ADD.L   D2,D1       ; D1 = D1 + D2
      ADDI.L  #2,D2       ; D2 = D2 + 2
      ADDI.L  #1,D7       ; D7 = D7 + 1
      CMP.L   D0,D1       ; Compare D0 and D1
      BLS     SqrL        ; While D1 <= D0
      SUBI.L  #1,D7       ; D7 = D7 - 1
SqrX: MOVEM.L (SP)+,D1-D2 ; Restore registers
      RTS                 ; Exit SubRoutine

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
