;==========================================================
;== Generate ea_test_2_yyyymmddhhiiss.s
;==========================================================

EnableExplicit

#DIS1   = 7
#DIS2   = 617
#NBTEST = 10
#COUNT  = 256 * 4

;==============================================================================

Macro W(s)
  WriteStringN(0, s)
EndMacro

Macro EA(dis, an, dn, size)
  PeekL( dis + ( an + dn * size ) )
EndMacro

Macro H1(x)
  RSet(Hex(x, #PB_Byte), 2, "0")
EndMacro

Macro H4(x)
  RSet(Hex(x, #PB_Word), 4, "0")
EndMacro

Macro H8(x)
  RSet(Hex(x, #PB_Long), 8, "0")
EndMacro

Macro BE(a)
  "$"+Mid(a,7,2)+",$"+Mid(a,5,2)+",$"+Mid(a,3,2)+",$"+Mid(a,1,2)
EndMacro

;==============================================================================

Define mem, i, eamul, size, index, precalc, oldprecalc, line$

;==============================================================================

If CreateFile(0, "ea_test_2_" + FormatDate("%yyyy%mm%dd%hh%ii", Date()) + ".asm")
  
  ;==========================================================
  ; Merge main file
  ;==========================================================
  
  If ReadFile(1, "ea_test_2_main.asm")
    While Not Eof(1)
      line$ = ReadString(1)
      If Left(line$, 15) = "ASSERT_ZERO EQU"
        W("DIS1 EQU " + #DIS1)
        W("DIS2 EQU " + #DIS2)
        W("")
      EndIf
      W(line$)
    Wend
    CloseFile(1)
  EndIf
  
  ;==========================================================
  ; Merge Data Section
  ;==========================================================
  
  W(";==========================================================")
  W("; Data Section")
  W(";==========================================================")
  W("")
  
  mem = AllocateMemory(#COUNT)
  
  If mem
    
    ; Generate random values
    
    OpenCryptRandom()
    CryptRandomData(mem, #COUNT)
    
    ; Output runner section
    
    W("RUNNER:")
    W("    DS.B DIS2")
    For i = 0 To #NBTEST - 1
      eamul = Random(3, 0)
      size  = Int(Pow(2, eamul))
      index = Random( ( ( #COUNT / 4 ) >> eamul ) - 4, 0)
      precalc = EA(#DIS1, mem, index, size)
      W("    DC.B $" + RSet(Hex(index), 2, "0") + "," + size + "," + BE(H8(oldprecalc + precalc)))
      oldprecalc = precalc
    Next
    W("    DC.B -1")
    W("")
    
    ; Output values section
    
    W("VALUES:")
    W("    DS.B DIS1")
    For i = 0 To #COUNT - 1 Step 4
      W("    DC.B " + 
            "$" + H1(PeekB(#DIS1+mem+i+0)) + "," + 
            "$" + H1(PeekB(#DIS1+mem+i+1)) + "," + 
            "$" + H1(PeekB(#DIS1+mem+i+2)) + "," + 
            "$" + H1(PeekB(#DIS1+mem+i+3)))
    Next
    W("")
    
  EndIf
  
  ;==========================================================
  ; Close file
  ;==========================================================
  
  CloseFile(0)
  
EndIf

End

;==============================================================================

; IDE Options = PureBasic 5.40 LTS Beta 3 (Linux - x64)
; CursorPosition = 6
; Folding = --
; EnableXP