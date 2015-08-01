;===================================================
; Motorola 68K - ASM test
; Square Root, Unsigned Integer.
; Result is computed with multiplications.
;===================================================
; 
; function sqrt(a) {
;   int b = 0;
;   while ( (b * b) <= a )
;     b = b + 1;
;   return (b - 1);
; }
; 
;===================================================

;===================================================
; Entry point
;===================================================

TEST1: MOVEQ #0,D0         ; D0 = 0
       JSR   Sqrt          ; D7 = Sqrt(0) = 0

TEST2: MOVEQ #1,D0         ; D0 = 1
       JSR   Sqrt          ; D7 = Sqrt(1) = 1

TEST3: MOVEQ #9,D0         ; D0 = 9
       JSR   Sqrt          ; D7 = Sqrt(9) = 3

TEST4: MOVEQ #85,D0        ; D0 = 85
       JSR   Sqrt          ; D7 = Sqrt(85) = 9

EXIT:  RTS                 ; Stop execution

;===================================================
; Sqrt(a)
; Input  : D0 = a
; Output : D7 = Result
;===================================================

Sqrt:  MOVEM.L D1,-(SP) ; Save registers
       CLR.L   D7       ; D7 = 0
       CLR.L   D1       ; D1 = 0
.Next  ADDI.L  #1,D7    ; D7 = D7 + 1
       MOVE.L  D7,D1    ; D1 = D7
       MULU.W  D1,D1    ; D1 = D1 * D1
       CMP.L   D0,D1    ; If D1 <= D0
       BLE     .Next    ; Then continue
.Exit: SUBI.L  #1,D7    ; D7 = D7 - 1
       MOVEM.L (SP)+,D1 ; Restore registers
       RTS              ; Exit SubRoutine

;===================================================
