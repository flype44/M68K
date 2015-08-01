;====================================================
; Motorola 68K - ASM test
; Fibonacci
;====================================================

assert_zero EQU $00D0000C  ; ASSERT ZERO Register

;====================================================

Start:
     lea     Precalc,A0     ; Put precalculated values in A0
     moveq   #0,D1          ; D1 = 0 (1st fibonacci value)
     moveq   #1,D2          ; D2 = 1 (2nd fibonacci value)
Loop:
     move.l  (A0)+,D0       ; Put precalculated value in D0
     cmpi.l  #-1,D0         ; If D0 = -1
     beq     Exit           ; Then Exit
     move.l  D1,D3          ; D3 = D1
     add.l   D2,D3          ; D3 = D2 + D3
     move.l  D2,D1          ; D1 = D2
     move.l  D3,D2          ; D2 = D3
     sub.l   D2,D0          ; Should be 0
     move.l  D0,assert_zero ; Raise error if D0 != 0
     bra     Loop           ; Continue
Exit:
     stop    #-1            ; Stop execution
  
;====================================================
  
Precalc:
     dc.l $00000001,$00000002,$00000003,$00000005
     dc.l $00000008,$0000000D,$00000015,$00000022
     dc.l $00000037,$00000059,$00000090,$000000E9
     dc.l $00000179,$00000262,$000003DB,$0000063D
     dc.l $00000A18,$00001055,$00001A6D,$00002AC2
     dc.l $0000452F,$00006FF1,$0000B520,$00012511
     dc.l $0001DA31,$0002FF42,$0004D973,$0007D8B5
     dc.l $000CB228,$00148ADD,$00213D05,$0035C7E2
     dc.l $005704E7,$008CCCC9,$00E3D1B0,$01709E79
     dc.l $02547029,$03C50EA2,$06197ECB,$09DE8D6D
     dc.l $0FF80C38,$19D699A5,$29CEA5DD,$43A53F82
     dc.l $6D73E55F,$B11924E1,$1E8D0A40,$CFA62F21
     dc.l $EE333961,$BDD96882,$AC0CA1E3,$69E60A65
     dc.l $15F2AC48,$7FD8B6AD,$95CB62F5,$15A419A2
     dc.l $AB6F7C97,$C1139639,$6C8312D0,$2D96A909
     dc.l $9A19BBD9,$C7B064E2,$61CA20BB,$297A859D
     dc.l -1
