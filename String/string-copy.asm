;===================================================
; Copy null-terminated string.
; flype, 2015
; 
; STR1 : Hello, i'm a string !
; STR2 : Hello, i'm a string !
;===================================================

START: LEA    STR1,A0     ; Address of source
       LEA    STR2,A1     ; Address of destination
LOOP:  MOVE.B (A0)+,(A1)+ ; Copy byte to destination
       BNE    LOOP        ; Continue if (A1) != null
EXIT:  RTS                ; Stop execution
;===================================================

STR1:  DC.B   "Hello, i'm a string !",0
STR2:  DC.B   "_____________________",0

;===================================================
