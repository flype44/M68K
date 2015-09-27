;=================================================
; Base64 Encode (v1.3)
;=================================================

; +----------------+---------+---------+---------+ 
; | Text content   |       M |       a |       n | Input: 3 chars
; +----------------+---------+---------+---------+ 
; | ASCII          |      77 |      97 |     110 | 
; +----------------+---------+---------+---------+ 
; | Bit pattern    |010011|01|0110|0001|01|101110| Step1: Bits operations
; +----------------+------+-------+-------+------+ 
; | Index          |   19 |    22 |     5 |   46 | Step2: Base64 Encode Table
; +----------------+------+-------+-------+------+ 
; | Base64-encoded |    T |     W |     F |    u | Output: 4 chars
; +----------------+------+-------+-------+------+ 

;=================================================
; Constants
;=================================================

assert_zero EQU $00D0000C       ; magical register

;=================================================
; Entry Point
;=================================================

Start:
     
     lea     String1,a1          ; encode 1st string
     lea     Buffer1,a2          ; 
     jsr     Base64Encode        ; 

     lea     String2,a1          ; encode 2nd string
     lea     Buffer2,a2          ; 
     jsr     Base64Encode        ; 
     
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
     rts

;=================================================
; Base64 Encode SubRoutine
; A1 = String to encode in Base64
; A2 = Buffer for encoded string
;=================================================

Base64Encode:
     lea     B64EncodeTbl,a0     ; base64 encode table
     clr.l   d0                  ; init registers
     clr.l   d1                  ; 
     clr.l   d2                  ; 

.Base64EncodeLoop:
     move.b  (a1)+,d0            ; encode 1st char
     beq     .Base64EncodeExit   ; exit if null char
     move.b  d0,d1               ; ( a >> 2 )
     lsr.b   #2,d1               ; 
     move.b  (a0,d1),(a2)+       ; 
     move.b  (a1)+,d1            ; encode 2nd char
     move.b  d1,d2               ; ( ( a << 4 ) & %00111111 | ( b >> 4 )
     lsl.b   #4,d0               ; 
     andi.b  #%00111111,d0       ; 
     lsr.b   #4,d2               ; 
     or.b    d0,d2               ; 
     move.b  (a0,d2),(a2)+       ; 
     move.b  (a1)+,d2            ; encode 3rd char
     move.b  d2,d0               ; ( ( b << 2 ) & %00111111 ) | ( c >> 6 )
     lsl.b   #2,d1               ; 
     andi.b  #%00111111,d1       ; 
     lsr.b   #6,d0               ; 
     or.b    d1,d0               ; 
     move.b  (a0,d0),(a2)+       ; 
     andi.b  #%00111111,d2       ; encode 4th char
     move.b  (a0,d2),(a2)+       ; ( c & %00111111 )
     bra     .Base64EncodeLoop   ; continue

.Base64EncodeExit:
     rts                         ; exit subroutine

;=================================================
; Base64 Encode Table
;=================================================

B64EncodeTbl:
     dc.b 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     dc.b 'abcdefghijklmnopqrstuvwxyz'
     dc.b '0123456789+/'

;=================================================
; ASCII strings to encode in Base64
;=================================================

String1: dc.b 'Amiga Rulez!',0
Buffer1: dc.b '________________',0
Precal1: dc.b 'QW1pZ2EgUnVsZXoh',0

;=================================================

String2: dc.b 'ASM 68K is fun.',0
Buffer2: dc.b '____________________',0
Precal2: dc.b 'QVNNIDY4SyBpcyBmdW4u',0

;=================================================
