;==============================================
; Lowercase a string.
; flype, 2015
; 
; Upper-chars : 65 to 90 
; Lower-chars : 97 to 122 
; 
; Input  : HELLO, I AM A STRING !
; Output : hello, i am a string !
;==============================================

START:  LEA    STR,A0    ; Address of string
LOOP:   MOVE.B (A0)+,D0  ; Read byte from string
        BEQ    EXIT      ; Exit if end of string
        CMPI.B #65,D0    ; If byte < 65
        BLT    LOOP      ; Then continue
        CMPI.B #90,D0    ; If byte > 90
        BGT    LOOP      ; Then continue
        ADDI.B #32,D0    ; Lowercase
UPDATE: MOVE.B D0,-1(A0) ; Overwrite byte
        BRA    LOOP      ; Continue
EXIT:   RTS              ; Stop execution

;==============================================

STR:    DC.B   "HELLO, I AM A STRING !",0

;==============================================
