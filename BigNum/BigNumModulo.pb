; Test Modulo sur un BigNumber
; http://www.javascripter.net/math/calculators/100digitbigintcalculator.htm

EnableExplicit

Procedure BigNumModulo(*number.String, divider)
  
  Protected result
  
  While PeekB(*number)
    result * 10
    result + PeekB(*number)
    result - $30
    result % divider
    *number + 1
  Wend
  
  ProcedureReturn result
  
EndProcedure

Define i, j, div, res, num.s

For i = 0 To 99
  num = ""
  For j = 0 To 59
    num + Str(Random(9,0))
  Next
  div = Random(255,1)
  res = BigNumModulo(@num, div)
  If res
    Debug "    DC.B $" + RSet(Hex(res),2,"0") + ",$" + RSet(Hex(div),2,"0") + ",'" + num + "',0"
  Else
    i - 1
  EndIf
Next
Debug "    DC.B 0"

; IDE Options = PureBasic 5.40 LTS Beta 3 (Linux - x64)
; CursorPosition = 4
; Folding = -
; EnableXP