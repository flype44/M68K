;====================================================
; Apollo 68K documentation
; Instruction : ADDA
; http://apollo-core.com/m68k/ADDA.htm
;====================================================

Start:
    clr.l   D0           ; Clear D0 (D0 = $00000000)
    lea     Values,A0    ; Put Values1 address in A0
    adda.l  #20*1,A0     ; Add 20 bytes to A0 (A0 = A0 + 20 bytes)
    adda.l  #20*2,A0     ; Add 40 bytes to A0 (A0 = A0 + 40 bytes)
    adda.l  #20*4,A0     ; Add 80 bytes to A0 (A0 = A0 + 80 bytes)
    move.l  (A0),D0      ; Put A0 content in D0 (D0 = $12345678)
    stop    #-1          ; Stop execution

Values:
    ds.b 20        ; Space for 20 bytes (20 x 1 = 20 bytes)
    ds.w 20        ; Space for 20 words (20 x 2 = 40 bytes)
    ds.l 20        ; Space for 20 longs (20 x 4 = 80 bytes)
    dc.l $12345678 ; Space for 1 long
