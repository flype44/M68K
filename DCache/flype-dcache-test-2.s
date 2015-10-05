;==========================================================
; ASM Testcase
; flype, 2015-10-05, v1.0
;==========================================================
; https://github.com/flype44/M68K/blob/master/DCache/dcache-test-2.asm
;==========================================================

assert_zero equ $00D0000C

;==========================================================
    
    bra     Start

;==========================================================
;   MAIN
;==========================================================

Start:
    lea     BUFFER1,a0                  ; Mem block 1
    lea     (BUFFER1+BUFSIZE+SPACER),a1 ; Mem block 2

;==========================================================

Init1:
    move.b  #0,(a0)+             ; 1rst value
Loop1:
    cmpi.b  #(BUFSIZE-1),-1(a0)  ; until max
    beq     Init2                ; exit
    move.b  -1(a0),(a0)+         ; 0,1,2,3...10
    addi.b  #1,-1(a0)            ; increment value
    bra     Loop1                ; continue

;==========================================================

Init2:
    move.b  #(BUFSIZE-1),(a1)+   ; 1rst value
Loop2:
    cmpi.b  #0,-1(a1)            ; until max
    beq     Assert               ; exit
    move.b  -1(a1),(a1)+         ; 10,9,8,7...0
    subi.b  #1,-1(a1)            ; decrement value
    bra     Loop2                ; continue

;==========================================================

Assert:
    lea     BUFFER1,a0           ; Mem block 1
    lea     (BUFFER1+BUFSIZE+SPACER),a1 ; Mem block 2
    adda.l  #(BUFSIZE-0),a1      ; Mem block 2 + Size
    move.l  #(BUFSIZE-1),d0      ; Counter
    clr.l   d1                   ; d1 = 0
AssertLoop:
    move.b  -(a1),d1             ; store a1 in d1 and decrement a1
    sub.b   (a0)+,d1             ; d1 should be 0
    move.l  d1,assert_zero       ; assert 0
    dbra    d0,AssertLoop        ; 

;==========================================================

Exit:
    tst     $0                   ; flush pipelines
    stop    #-1                  ; stop sim

;==========================================================

BUFSIZE EQU 100 ; <<<< Modify it here (bytes count in array)
SPACER  EQU $8000 ; <<<< Modify it here (32K for ex)

BUFFER1: ds.b BUFSIZE
         ds.b SPACER
BUFFER2: ds.b BUFSIZE

;==========================================================

    END   START

;==========================================================
