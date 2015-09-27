; M68K
; PERM
; Example 1

; Dx       Dy
; 11223344 AABBCCDD
; 00112233 44556677

TEST1:	MOVE.L  #$00112233,D0 ; D0    = 00112233
        MOVE.L  #$44556677,D1 ; D1    = 44556677
        PERM    #@1234,D0,D1  ; D0 D1 = 00112233 44556677
                              ; D0 D1 = --112233 44------
                              ; D1    = 11223344
EXIT:   RTS

TEST2:	MOVE.L  #$00112233,D0 ; D0    = 00112233
        MOVE.L  #$44556677,D1 ; D1    = 44556677
        PERM    #@0246,D0,D1  ; D0 D1 = 00112233 44556677
                              ; D0 D1 = 00--22-- 44--66--
                              ; D1    = 00224466
EXIT:   RTS
"eeeeeeeee"
TEST3A:	MOVE.L  #$00112233,D0 ; D0    = 00112233
        MOVE.L  #$44556677,D1 ; D1    = 44556677
        PERM    #@3072,D0,D1  ; D0 D1 = 00112233 44556677
                              ; D0 D1 = 00--2233 ------77
                              ; D1    = 33007722
EXIT:   RTS

TEST3B:	MOVE.L  #$00112233,D0 ; D0    = 00112233
        MOVE.L  #$44556677,D1 ; D1    = 44556677
        PERM    #@7203,D0,D1  ; D0 D1 = 00112233 44556677
                              ; D0 D1 = 00--2233 ------77
                              ; D1    = 77220033
EXIT:   RTS

TEST3C:	MOVE.L  #$00112233,D0 ; D0    = 00112233
        MOVE.L  #$44556677,D1 ; D1    = 44556677
        PERM    #@0237,D0,D1  ; D0 D1 = 00112233 44556677
                              ; D0 D1 = 00--2233 ------77
                              ; D1    = 00223377
EXIT:   RTS

; PERM act like SWAP D0
TEST5:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #@2301,D0,D0  ; CCDDAABB
EXIT:   RTS

; PERM Little Endian to Big Endian
TEST4:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #@3210,D0,D0  ; DDCCBBAA
EXIT:   RTS

; 
TEST4:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD
        PERM    #@1032,D0,D0  ; BBAADDCC
EXIT:   RTS

; 
TEST4:  MOVE.L  #$AABBCCDD,D0 ; AABBCCDD [0:AA, 1:BB, 2:CC, 3:DD]
        PERM    #@4567,D0,D0  ; AABBCCDD
EXIT:   RTS

