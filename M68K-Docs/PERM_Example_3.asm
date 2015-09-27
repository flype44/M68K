; M68K
; PERM BytesOrder,Dx,Dy
; Permute individual bytes in register

; Example 3 :
; PERM that does nothing.

; PERM #@2301,Dx,Dx
; Equivalent to SWAP Dx
; Dx                    = $11223344 11223344
; @2___ = Byte2 from Dx = $____33__ ________
; @_3__ = Byte3 from Dx = $______44 ________
; @__0_ = Byte0 from Dx = $11______ ________
; @___1 = Byte1 from Dx = $__22____ ________
; Dx (affected)         = $33441122 33441122

; PERM #@3210,Dx,Dx
; Perform Big Endian to Little Endian
; Dx, Dx                = $11223344 11223344
; @3___ = Byte3 from Dx = $______44 ________
; @_2__ = Byte2 from Dx = $____33__ ________
; @__1_ = Byte1 from Dx = $__22____ ________
; @___0 = Byte0 from Dx = $11______ ________
; Dx, Dx                = $44332211 44332211

; PERM #@7654,Dx,Dx
; Perform Big Endian to Little Endian
; Dx, Dx                = $11223344 11223344
; @7___ = Byte3 from Dx = $________ ______44
; @_6__ = Byte2 from Dx = $________ ____33__
; @__5_ = Byte1 from Dx = $________ __22____
; @___4 = Byte0 from Dx = $________ 11______
; Dx, Dx                = $44332211 44332211

; PERM #@0123,Dx,Dy
; Equivalent to MOVE.L Dx,Dy
; Dx, Dy                = $11223344 AABBCCDD
; @0___ = Byte0 from Dx = $11______ ________
; @_1__ = Byte1 from Dx = $__22____ ________
; @__2_ = Byte2 from Dx = $____33__ ________
; @___3 = Byte3 from Dx = $______44 ________
; Dx, Dy                = $11223344 11223344

; PERM #0,Dx,Dy
; Dx, Dy                = $11223344 AABBCCDD
; @0___ = Byte0 from Dx = $11______ ________
; @_0__ = Byte0 from Dx = $11______ ________
; @__0_ = Byte0 from Dx = $11______ ________
; @___0 = Byte0 from Dx = $11______ ________
; Dx, Dy                = $11223344 11111111

; PERM #1,Dx,Dy
; Dx, Dy                = $11223344 AABBCCDD
; @0___ = Byte0 from Dx = $11______ ________
; @_0__ = Byte0 from Dx = $11______ ________
; @__0_ = Byte0 from Dx = $11______ ________
; @___1 = Byte1 from Dx = $__22____ ________
; Dx, Dy                = $11223344 11111122

; PERM #7,Dx,Dy
; Dx, Dy                = $11223344 AABBCCDD
; @0___ = Byte0 from Dx = $11______ ________
; @_0__ = Byte0 from Dx = $11______ ________
; @__0_ = Byte0 from Dx = $11______ ________
; @___7 = Byte3 from Dy = $________ ______DD
; Dx, Dy                = $11223344 111111DD

; PERM #2222,Dx,Dy
; Fill Byte2 from Dx into Dy
; Dx, Dy                = $11223344 AABBCCDD
; @0___ = Byte0 from Dx = $____33__ ________
; @_0__ = Byte0 from Dx = $____33__ ________
; @__0_ = Byte0 from Dx = $____33__ ________
; @___7 = Byte3 from Dy = $____33__ ________
; Dx, Dy                = $11223344 33333333

; PERM #@7034,Dx,Dy
; Permute bytes from Dx and Dy into Dy
; Dx                    = $11223344 AABBCCDD
; @7___ = Byte3 from Dy = $________ ______DD
; @_0__ = Byte0 from Dx = $11______ ________
; @__3_ = Byte3 from Dx = $______44 ________
; @___4 = Byte0 from Dy = $________ AA______ 
; Dx, Dy                = $11223344 DD1144AA


STAR:   LEA     lb1,A0
        LEA     lb2,A1
        MOVE.L  (A0),(A1) ; AABBCCDD

START:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #@0123,D0,D0  ; AABBCCDD
EXIT:   RTS

START:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #@4567,D0,D0  ; AABBCCDD
EXIT:   RTS

START:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #0,D0,D0      ; AAAAAAAA
EXIT:   RTS

START:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #1,D0,D0      ; AAAAAABB
EXIT:   RTS

lb1: dc.l $AABBCCDD
lb2: dc.l $00000000
