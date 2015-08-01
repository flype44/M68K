;===================================================
; Multiplication
; Result is computed only with additions.
;===================================================
; 
; function mult(int a, int b) {
;   int c = 0;
;   if (a < b)
;     swap a, b;
;   while (b > 0) {
;     c = c + a;
;     b = b - 1;
;   }
;   return c;
; }
; 
;===================================================

;===================================================
; Entry point
;===================================================

TEST1: MOVEQ #0,D0  ; D0 = 0
       MOVEQ #4,D1  ; D1 = 4
       JSR   Mult   ; D7 = Mult(0,4) = 0

TEST2: MOVEQ #1,D0  ; D0 = 1
       MOVEQ #10,D1 ; D1 = 10
       JSR   Mult   ; D7 = Mult(1,10) = 10

TEST3: MOVEQ #5,D0  ; D0 = 5
       MOVEQ #6,D1  ; D1 = 6
       JSR   Mult   ; D7 = Mult(5,6) = 30

TEST4: MOVEQ #3,D0  ; D0 = 3
       MOVEQ #43,D1 ; D1 = 43
       JSR   Mult   ; D7 = Mult(3,43) = 129

EXIT:  RTS          ; Stop execution

;===================================================
; Mult(a, b)
; Input  : D0 = a
;          D1 = b
; Output : D7 = Result
;===================================================

Mult:  MOVEM.L D0-D1,-(SP) ; Save registers
       CLR.L   D7          ; D7 = 0
       CMP.L   D0,D1       ; If D0 < D1
       BLT     .Loop       ;   Exchange D0, D1
       EXG     D0,D1       ; EndIf
       CMPI.L  #0,D1       ; Check if D1 = 0
.Loop: BEQ     .Exit       ; While D1 > 0
       ADD.L   D0,D7       ;   D7 = D7 + D0
       SUBI.L  #1,D1       ;   D1 = D1 - 1
       BRA     .Loop       ; Wend
.Exit: MOVEM.L (SP)+,D0-D1 ; Restore registers
       RTS                 ; Exit SubRoutine

;===================================================
