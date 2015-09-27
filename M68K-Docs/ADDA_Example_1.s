;====================================================
; Apollo 68K documentation
; Instruction : ADDA
; http://apollo-core.com/m68k/ADDA.htm
;====================================================

Start:
    clr.l   D0           ; D0 = $00000000
    lea     MyValues,A0  ; A0 = MyValues address
    move.l  (A0),D0      ; D0 = $01234567
    ADDA.l  #4,A0        ; A0 = A0 + 4 bytes
    move.l  (A0),D0      ; D0 = $89ABCDEF
    ADDA.l  #4,A0        ; A0 = A0 + 4 bytes
    move.l  (A0),D0      ; D0 = $EBACCABE
    stop    #-1          ; Stop execution

MyValues:
    dc.l $01234567
    dc.l $89ABCDEF
    dc.l $EBACCABE
