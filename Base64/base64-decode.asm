;=================================================
; Base64 Decode (v1.1)
;=================================================

; +----------------+------+-------+-------+------+ 
; | Base64-encoded |    T |     W |     F |    u | Input: 4 chars
; +----------------+------+-------+-------+------+ 
; | Index          |   19 |    22 |     5 |   46 | Step1: Base64 Decode Table
; +----------------+------+-------+-------+------+ 
; | Bit pattern    |010011|01|0110|0001|01|101110| Step2: Bits operations
; +----------------+---------+---------+---------+ 
; | ASCII          |      77 |      97 |     110 | 
; +----------------+---------+---------+---------+ 
; | Text content   |       M |       a |       n | Output: 3 chars
; +----------------+---------+---------+---------+ 

;=================================================
; Constants
;=================================================

assert_zero EQU $00D0000C       ; magical register

;=================================================
; Entry Point
;=================================================

Start:
     
     lea     String1,a1          ; decode 1st string
     lea     Buffer1,a2          ; 
     jsr     Base64Decode        ; 

     lea     String2,a1          ; decode 2nd string
     lea     Buffer2,a2          ; 
     jsr     Base64Decode        ; 
     
     lea     Buffer1,a0          ; check 1st string
     lea     Precal1,a1          ; 
     jsr     SelfTest            ; 

     lea     Buffer2,a0          ; check 2nd string
     lea     Precal2,a1          ; 
     jsr     SelfTest            ; 

     stop    #-1                 ; stop execution

;=================================================
; SelfTest SubRoutine
; A0 = Calculated string
; A1 = Precalculated string
;=================================================

SelfTest:
     move.b  (a0)+,d0            ; read calculated char
     beq     .SelfTestExit       ; exit if null-char
     sub.b   (a1)+,d0            ; compare with precalculated char
     move.l  d0,assert_zero      ; raise error if D0 != 0
     bra     SelfTest            ; continue

.SelfTestExit:
     rts                         ; exit subroutine

;=================================================
; Base64 Decode SubRoutine
; A1 = String encoded in Base64
; A2 = Buffer for decoded string
;=================================================

Base64Decode:
     lea     B64DecodeTbl-43,a0  ; base64 decode table
     clr.l   d0                  ; init registers
     clr.l   d1                  ; 
     clr.l   d2                  ; 

.Base64DecodeLoop:
     move.b  (a1)+,d0            ; decode 1st char
     beq     .Base64DecodeExit   ; exit if null-char
     move.b  (a1)+,d1            ; ( a << 2 ) | ( b >> 4 )
     move.b  (a0,d0),d0          ; 
     move.b  (a0,d1),d1          ; 
     move.b  d1,d2               ; 
     lsl.b   #2,d0               ; 
     lsr.b   #4,d2               ; 
     or.b    d0,d2               ; 
     move.b  d2,(a2)+            ; 
     move.b  (a1)+,d0            ; decode 2nd char
     move.b  (a0,d0),d0          ; ( b << 4 ) | ( c >> 2 )
     move.b  d0,d2               ; 
     lsl.b   #4,d1               ; 
     lsr.b   #2,d2               ; 
     or.b    d1,d2               ; 
     move.b  d2,(a2)+            ; 
     move.b  (a1)+,d1            ; decode 3rd char
     move.b  (a0,d1),d1          ; ( c << 6 ) | d
     lsl.b   #6,d0               ; 
     or.b    d0,d1               ; 
     move.b  d1,(a2)+            ; 
     bra     .Base64DecodeLoop   ; continue

.Base64DecodeExit:
     rts                         ; exit subroutine

;=================================================
; Base64 Decode Table
;=================================================

B64DecodeTbl:
     dc.b 62                                     ; +
     ds.b 3                                      ; unused
     dc.b 63                                     ; /
     dc.b 52,53,54,55,56,57,58,59,60,61          ; 0..9
     ds.b 7                                      ; unused
     dc.b 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14     ; A..Z
     dc.b 15,16,17,18,19,20,21,22,23,24,25       ; 
     ds.b 6                                      ; unused
     dc.b 26,27,28,29,30,31,32,33,34,35,36,37,38 ; a..z
     dc.b 39,40,41,42,43,44,45,46,47,48,49,50,51 ; 

;=================================================
; Data Section
;=================================================

String1: dc.b 'QW1pZ2EgUnVsZXoh',0
Buffer1: dc.b '____________',0
Precal1: dc.b 'Amiga Rulez!',0

;=================================================

String2: dc.b 'QVNNIDY4SyBpcyBmdW4u',0
Buffer2: dc.b '_______________',0
Precal2: dc.b 'ASM 68K is fun.',0

;=================================================
