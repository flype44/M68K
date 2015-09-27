; M68K
; PERM BytesOrder,Dx,Dy
; Permute individual bytes in register

; Example 2 :
; Use PERM to perform Little Endian to Big Endian

; Data Register = $AABBCCDD
; Bytes Order   = @3210
; 3 --> $DD
; 2 --> $CC
; 1 --> $BB
; 0 --> $AA

START:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #@3210,D0,D0  ; DDCCBBAA
EXIT:   RTS
