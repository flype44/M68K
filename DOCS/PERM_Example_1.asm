; M68K
; PERM BytesOrder,Dx,Dy
; Permute individual bytes in register

; Example 1 :
; Use PERM like SWAP instruction

; Data Register = $AABBCCDD
; Bytes Order   = @2301
; 2 --> $CC
; 3 --> $DD
; 0 --> $AA
; 1 --> $BB

START:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #@2301,D0,D0  ; CCDDAABB
EXIT:   RTS
