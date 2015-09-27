; http://www.simplycalc.com/crc32-text.php#
; function CRC32REV(polynomial) {
;   reversed = 0
;   for (i = 0; i < 32; i++) {
;     reversed = reversed << 1
;     reversed = reversed | ((polynomial >> i) & 1)
;   }
;   return reversed
; }

Procedure CRC32REV(polynomial)
  Protected reversed = 0
  For i = 0 To 31
    reversed = (reversed << 1) | ((polynomial >> i) & 1)
  Next
  ProcedureReturn reversed
EndProcedure

Debug Hex(CRC32REV($04C11DB7))
; IDE Options = PureBasic 5.31 (Linux - x64)
; CursorPosition = 11
; Folding = -
; EnableUnicode
; EnableXP