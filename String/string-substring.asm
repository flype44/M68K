;===================================================
; SubString
; Return part of a string
; flype, 2015
; 
; String   : "Hello, i'm a string !"
; StartPos : 7
; Length   : 12
; Result   : "i'm a string"
;===================================================

STARTPOS EQU 7
LENGTH   EQU 12

;===================================================

START: LEA    STR1,A0      ; Address of source
       LEA    STR2,A1      ; Address of destination
       ADDQ   #STARTPOS,A0 ; Start position
       MOVEQ  #LENGTH-1,D0 ; Substring length
LOOP:  MOVE.B (A0)+,(A1)+  ; Copy string
       BEQ    EXIT         ; Until null-char
       DBF    D0,LOOP      ; Or given length
       MOVE.B #0,(A1)      ; Null-char
EXIT:  RTS                 ; Stop execution

;===================================================

STR1:   DC.B "Hello, i'm a string !",0

STR2:   DS.B LENGTH+1 ; Destination string

;===================================================
