
Procedure PGCD2(a, b)
  ;Debug "a:"+a+",b:"+b
  If b
    ProcedureReturn PGCD2(b, a % b)
  EndIf
  ProcedureReturn a
EndProcedure

Procedure PGCD3(a, b, c)
  ProcedureReturn PGCD2(PGCD2(a, b), c)
EndProcedure

;Debug PGCD2(385,616) ; 77
;Debug PGCD2(385,616) ; 77

Debug "VALUES:"
tmp = 0
For i = 0 To 199
  a = Random(1000, 1)
  b = Random(1000, 1)
  If a <> b
    c = PGCD2(a, b)
    If b <> c And c > 40
      d = Random(3, 1)
      Debug "    DC.L " + a + "," + b + "," + c + "," + Int(Sqr(c)) + "," + d + "," + Int(Pow(c, d))
    Else
      i - 1
      tmp + 1
    EndIf
  Else
    i - 1
    tmp + 1
  EndIf
Next
Debug "    DC.L 0"
Debug ""
Debug tmp

; Debug "VALUES_PGCD3:"
; For i = 0 To 20
;   a = Random(1000, 1)
;   b = Random(1000, 1)
;   If a <> b
;     c = Random(1000, 1)
;     If b <> c
;       d = PGCD3(a, b, c)
;       If c <> d And d > 40
;         Debug "    DC.L " + a + "," + b + "," + c + "," + d
;       Else
;         i - 1
;       EndIf
;     Else
;       i - 1
;     EndIf
;   Else
;     i - 1
;   EndIf
; Next
; Debug "    DC.L 0"

; IDE Options = PureBasic 5.40 LTS Beta 3 (Linux - x64)
; CursorPosition = 25
; Folding = -
; EnableUnicode
; EnableXP