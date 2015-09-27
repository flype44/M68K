;==========================================================
;== Generate Luhn-big-yyyymmddhhiiss.s
;==========================================================

EnableExplicit

#VALUE_COUNT      = 50
#VALUE_MIN_LENGTH = 15
#VALUE_MAX_LENGTH = 60

;==========================================================

Macro W(s)
  WriteStringN(0, s)
EndMacro

Procedure luhn_checksum(code.s)
  Protected checksum, parity, length, digit, index
  length = Len(code)
  parity = length & 1
  For index = length - 1 To 0 Step -1
    digit = Val(Mid(code, index + 1, 1))
    If ( index & 1 ) = parity
      digit + digit
    EndIf
    If digit > 9
      digit - 9
    EndIf
    checksum + digit
  Next
  checksum % 10
  checksum = 10 - checksum
  ProcedureReturn checksum
EndProcedure

;==========================================================

NewList results.l()
Define i.l, j.l, length.l, total.l, value.s, line.s

;==========================================================

If CreateFile(0, "luhn-big-" + FormatDate("%yyyy%mm%dd%hh%ii", Date()) + ".s")
  
  ;==========================================================
  ; Merge main file
  ;==========================================================
  
  If ReadFile(1, "luhn-big-main.s")
    While Not Eof(1)
      WriteStringN(0, ReadString(1))
    Wend
    CloseFile(1)
  EndIf
  
  ;==========================================================
  ; Merge Data Section
  ;==========================================================
  
  W("")
  W(";==========================================================")
  W("; Data Section")
  W(";==========================================================")
  W("")
  W("VALUES:")
  
  For i = 0 To #VALUE_COUNT - 1
    length = Random(#VALUE_MAX_LENGTH, #VALUE_MIN_LENGTH)
    For j = 0 To length - 1
      value + Str(Random(9,0))
    Next
    value + "0"
    AddElement(results())
    results() = luhn_checksum(value)
    W(" DC.B " + Len(value) + ",'" + value + "'")
    value = ""
  Next
  
  W(" DC.B 0")
  W(" DC.B 0")
  W("")
  W("PRECALC:")
  
  i = 0
  ForEach results()
    total + results()
    line + results() + ","
    i + 1
    If i > 30
      W(" DC.B " + Left(line, Len(line) - 1))
      line = ""
      i = 0
    EndIf
  Next
  
  W(" DC.W " + Str(total))
  W("")
  W(";==========================================================")
  W("; End of file")
  W(";==========================================================")
  
  CloseFile(0)
  
EndIf
; IDE Options = PureBasic 5.31 (Linux - x64)
; CursorPosition = 6
; Folding = 9
; EnableUnicode
; EnableXP