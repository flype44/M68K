;================================================
; ASM Test
; ParseInt - String to Value
;================================================

;=================================================
; Constants
;=================================================

assert_zero EQU $00D0000C  ; magical register

;=================================================
; Entry Point
;=================================================

start:
    
    lea     number1,a0     ; parse number 1
    bsr     ParseInt10     ; 
    move.l  d0,d1          ; 
    
    lea     number2,a0     ; parse number 2
    bsr     ParseInt10     ; 
    move.l  d0,d2          ; 

    lea     number3,a0     ; parse number 3
    bsr     ParseInt16     ; 
    move.l  d0,d3          ; 

    add.l   d1,d2          ; n1 + n2 + n3
    add.l   d3,d2          ;

    subi.l  #$6C575,d2     ; raise error if 
    move.l  d2,assert_zero ; d3 != precalc

    stop    #-1            ; stop execution

;================================================
; ParseInt Subroutine (string to value)
; Input  : A0 = Null-terminating string
; Output : D0 = Long value
;================================================

ParseInt10:
    move.l  #10,d6         ; decimal - base 10
    bra     ParseInt       ; 
ParseInt16:
    move.l  #16,d6         ; hexadecimal - base 16
ParseInt:
    clr.l   d0             ; reset digit
    move.l  #0,d7          ; reset result
.loop
    move.b  (a0)+,d0       ; read string
    beq.b   .exit          ; exit if null-char
    bsr     ParseDigit     ; read digit in d0
    mulu.l  d6,d7          ; result x 10
    add.l   d0,d7          ; result + digit
    bra     .loop          ; continue
.exit
    move.l  d7,d0          ; put result in d0
    rts                    ; exit subroutine

;================================================
; ParseDigit Subroutine (char to value)
; Input  : D0 = Digit char
; Output : D0 = Byte value
;================================================

ParseDigit:
    cmpi.b  #'0',d0        ; '0' <= d0 <= '9'
    blt     .exit          ; 
    cmpi.b  #'9',d0        ; 
    bls     .numeric       ; 
    cmpi.b  #'A',d0        ; 'A' <= d0 <= 'F'
    blt     .exit          ; 
    cmpi.b  #'F',d0        ; 
    bls     .alphanum1     ; 
    cmpi.b  #'a',d0        ; 'a' <= d0 <= 'f'
    blt     .exit          ; 
    cmpi.b  #'f',d0        ; 
    bls     .alphanum2     ; 
    bra     .exit          ; invalid char
.numeric
    subi.b  #'0',d0        ; numeric
    bra     .exit          ; 
.alphanum1
    subi.b  #'A'-10,d0     ; alphanum uppercase
    bra     .exit          ; 
.alphanum2
    subi.b  #'a'-10,d0     ; alphanum lowercase
.exit
    rts                    ; exit subroutine

;================================================
; Data Section
;================================================

number1: dc.b  '12345',0   ;   $00003039
number2: dc.b '400000',0   ; + $00061A80
number3: dc.b   '7AbC',0   ; + $00007ABC
                           ; -----------
                           ; = $0006C575
;================================================
; End of program
;================================================
