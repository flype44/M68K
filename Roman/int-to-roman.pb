;======================================================================================
; Roman to Number
;======================================================================================

Procedure ParseRoman(number.s)
  Protected result, i, j, k, l
  number = UCase(number)
  l = Len(number)
  While l
    i = FindString("IVXLCDM", Mid(number, l, 1))
    If i
      j = Val(StringField("1,5,10,50,100,500,1000", i, ","))
      If j < k
        j = -j
      EndIf
      result + j
      k = j
    Else
      result = -1
      Break
    EndIf
    l - 1
  Wend
  ProcedureReturn result
EndProcedure

;======================================================================================
; Number to Roman
;======================================================================================

Procedure.s ParseNumber(number.l)
  Protected result.s, i, j
  If number > 0 And number < 10000
    For i = 1 To 13
      j = Val(StringField("1000,900,500,400,100,90,50,40,10,9,5,4,1", i, ","))
      While number >= j
        result + StringField("M,CM,D,CD,C,XC,L,XL,X,IX,V,IV,I", i, ",")
        number - j
      Wend
    Next
  EndIf
  ProcedureReturn result
EndProcedure

;======================================================================================
; Conversion Tests
;======================================================================================

;Debug ParseNumber(1754)
;End


For i = 0 To 9999
  roman$ = ParseNumber(i)
  If Len(roman$) > Len(maxi$)
    maxi$ = roman$
  EndIf
  
;   number = ParseRoman(roman$)
;   Debug Str(i) + " ==> " + 
;         Chr(34) + roman$ + Chr(34) + " ==> " + 
;         Str(number) + " ==> " + 
;         StringField("ERROR,SUCCESS", Bool(i = number) + 1, ",")
Next
Debug maxi$
; IDE Options = PureBasic 5.40 LTS Beta 3 (Linux - x64)
; CursorPosition = 50
; FirstLine = 13
; Folding = -
; EnableUnicode
; EnableXP
; SubSystem = gtk2