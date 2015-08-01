;===================================================
; Motorola 68K - ASM test
; Uppercase a null-terminated string.
; "Hello World" => "HELLO WORLD"
;===================================================

;===================================================
; Constants
;===================================================

assert_zero EQU $00D0000C

;===================================================
; dc.l  0
; dc.l  START
; section .fastram
;===================================================

START:
    lea    STRING,A0  ; store string address in A0

;===================================================

LOOP:
    move.b (A0)+,D0   ; store byte value in D0 and increment string pointer
    beq    EXIT       ; exit on D0 = 0
    cmpi.b #97,D0     ; if D0 < 97, continue
    blt    LOOP
    cmpi.b #122,D0    ; if D0 > 122, continue
    bgt    LOOP
    sub.b  #32,D0     ; substract 32 to D0
    move.b D0,-1(A0)  ; write result
    bra    LOOP       ; continue

;===================================================

EXIT:
    stop   #-1        ; stop execution

;===================================================

STRING:
    dc.b   "Hello, i am a string !"
    dc.b   0

;===================================================
