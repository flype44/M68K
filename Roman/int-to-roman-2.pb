
EnableExplicit

Procedure.s ParseNumber(number.l)
  Protected i.l, value.l, result.s
  For i = 0 To 12
    Select i
      Case  0: value = 1000
      Case  1: value = 900
      Case  2: value = 500
      Case  3: value = 400
      Case  4: value = 100
      Case  5: value = 90
      Case  6: value = 50
      Case  7: value = 40
      Case  8: value = 10
      Case  9: value = 9
      Case 10: value = 5
      Case 11: value = 4
      Case 12: value = 1
    EndSelect
    While number >= value
      Select i
        Case  0: result + "M"
        Case  1: result + "CM"
        Case  2: result + "D"
        Case  3: result + "CD"
        Case  4: result + "C"
        Case  5: result + "XC"
        Case  6: result + "L"
        Case  7: result + "XL"
        Case  8: result + "X"
        Case  9: result + "IX"
        Case 10: result + "V"
        Case 11: result + "IV"
        Case 12: result + "I"
      EndSelect
      number - value
    Wend
  Next
  ProcedureReturn result
EndProcedure 

Procedure ParseRoman(number.s)
  Protected result, value, old, pos = Len(number)
  While pos > 0
    Select Mid(number, pos, 1)
      Case "I": value = 1
      Case "V": value = 5
      Case "X": value = 10
      Case "L": value = 50
      Case "C": value = 100
      Case "D": value = 500
      Case "M": value = 1000
    EndSelect
    If value < old
      result - value
    Else
      result + value
    EndIf
    old = value
    pos - 1
  Wend
  ProcedureReturn result
EndProcedure

Debug "====================================================="
Debug Bool( ParseRoman( ""     ) =   0 )
Debug Bool( ParseRoman( "IV"   ) =   4 )
Debug Bool( ParseRoman( "VI"   ) =   6 )
Debug Bool( ParseRoman( "IX"   ) =   9 )
Debug Bool( ParseRoman( "XI"   ) =  11 )
Debug Bool( ParseRoman( "XIII" ) =  13 )
Debug Bool( ParseRoman( "CDXC" ) = 490 )
Debug Bool( ParseRoman( "DX"   ) = 510 )
Debug Bool( ParseRoman( "MMMMMCDXXXVIII"        ) = 5438 )
Debug Bool( ParseRoman( "MMMMMMMMMDCCCLXXXVIII" ) = 9888 )
Debug Bool( ParseRoman( "MMMMMMMMMCMXCIX"       ) = 9999 )
Debug "====================================================="
Debug Bool( ParseNumber(    0 ) = ""     )
Debug Bool( ParseNumber(    4 ) = "IV"   )
Debug Bool( ParseNumber(    6 ) = "VI"   )
Debug Bool( ParseNumber(    9 ) = "IX"   )
Debug Bool( ParseNumber(   11 ) = "XI"   )
Debug Bool( ParseNumber(   13 ) = "XIII" )
Debug Bool( ParseNumber(  490 ) = "CDXC" )
Debug Bool( ParseNumber(  510 ) = "DX"   )
Debug Bool( ParseNumber( 5438 ) = "MMMMMCDXXXVIII"        )
Debug Bool( ParseNumber( 9888 ) = "MMMMMMMMMDCCCLXXXVIII" )
Debug Bool( ParseNumber( 9999 ) = "MMMMMMMMMCMXCIX"       )
Debug "====================================================="

Define i, roman$, number
; 
For i = 0 To 9999
  roman$ = ParseNumber(i)
  number = ParseRoman(roman$)
  Debug Str(i) + " ==> " + 
        Chr(34) + roman$ + Chr(34) + " ==> " + 
        Str(number) + " ==> " + 
        StringField("ERROR,SUCCESS", Bool(i = number) + 1, ",")
Next

; For i = 0 To 9999
;   Debug "DC.B '" + i + ", 0, " + ParseRoman(ParseNumber(i))
; Next

; IDE Options = PureBasic 5.40 LTS Beta 3 (Linux - x64)
; CursorPosition = 105
; FirstLine = 55
; Folding = -
; EnableUnicode
; EnableXP
; SubSystem = gtk2