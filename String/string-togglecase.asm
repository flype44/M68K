;==================================================================================
; Motorola 68K - ASM test
; ToggleCase, Toggle the case of all chars in a given string.
;==================================================================================

assert_zero EQU $00D0000C

;==================================================================================
; dc.l 0
; dc.l START
; section .fastram
;==================================================================================

START:
   move.b  #1,D2          ; 1rst run.
   lea     STRING1,A0     ; Store string buffers.
   lea     STRING2,A1     ; 

;==================================================================================

RUN1:
   move.b  (A0)+,D0       ; Put byte from string in D0, and increment string pointer.
   beq     RUN2           ; Exit if end of string.

   cmpi.b  #65,D0         ; D0 < 65 ?
   blt     UPDATE         ; 

   cmpi.b  #91,D0         ; D0 < 91 ?
   blt     TOLOWER        ; 

   cmpi.b  #97,D0         ; D0 < 97 ?
   blt     UPDATE         ; 

   cmpi.b  #122,D0        ; D0 > 122 ?
   bgt     UPDATE         ; 

TOUPPER:
   sub.b   #32,D0         ; Substract 32 to D0.
   bra     UPDATE         ; 

TOLOWER:
   add.b   #32,D0         ; Add 32 to D0.

UPDATE:
   move.b  D0,(A1)+       ; Update string.
   bra     RUN1           ; Continue.

;==================================================================================

RUN2:
   cmpi.b  #2,D2          ; 2nd run ?
   beq     SELFTEST       ; Exit on 2nd run.
   move.b  #2,D2          ; 2nd run.
   lea     STRING2,A0     ; Store string buffers.
   lea     STRING2,A1     ; 
   bra     RUN1           ; Go for the 2nd run.

;==================================================================================

SELFTEST:
   lea     STRING1,A0     ; Store string buffers.
   lea     STRING2,A1     ; 

SELFLOOP:
   move.b  (A0)+,D0       ; Read byte from string 1.
   beq     EXIT           ; Exit if end of string.
   sub.b   (A1)+,D0       ; Substract byte from string 2.
   move.b  D0,assert_zero ; Stop if bytes are different.
   bra     SELFLOOP       ; Continue.

;==================================================================================

EXIT:
   stop    #-1            ; Stop execution.

;==================================================================================

STRING1:
   dc.b    "68K Amiga Rulez !"
   dc.b    0

;==================================================================================

STRING2:
   dc.b    "_________________"
   dc.b    0

;==================================================================================
