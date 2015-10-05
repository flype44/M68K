;==========================================================
; ASM Testcase
; flype, 2015-10-05, v1.0
;==========================================================
; https://github.com/flype44/M68K/blob/master/DCache/dcache-test-3.asm
;==========================================================

assert_zero equ $00D0000C

COUNT  EQU   255 ; <<<< Modify it (bytes count in array)
SPACER EQU $8000 ; <<<< Modify it (32K for ex)

;==========================================================
    
;    DC.L    0
;    DC.L    Main
    section .fastram

;==========================================================
;   MAIN
;==========================================================

Main:
    jsr     ArrayLoad            ; Load buffers
    jsr     ArrayInit            ; Init buffers
    jsr     ArrayFill            ; Fill buffers
    jsr     SelfTest             ; Check buffers
MainExit:
    tst     $0                   ; Flush pipelines
    stop    #-1                  ; Stop sim

;==========================================================
;   Routines
;==========================================================

    section .chipram
    
ArrayLoad:
    lea     BUFFER0,a0           ; 
    lea     BUFFER1,a1           ; 
    lea     BUFFER2,a2           ; 
    lea     BUFFER3,a3           ; 
    lea     BUFFER4,a4           ; 
    lea     BUFFER5,a5           ; 
    lea     BUFFER6,a6           ; 
    rts

;==========================================================

ArrayInit:
    move.b  #0,(a0)+             ; 1rst value in a0
    move.b  #(COUNT-1),(a1)+     ; 1rst value in a1
    move.w  #0,(a2)+             ; 1rst value in a2
    move.w  #(COUNT-1),(a3)+     ; 1rst value in a3
    move.l  #0,(a4)+             ; 1rst value in a4
    move.l  #(COUNT-1),(a5)+     ; 1rst value in a5
    move.l  #(COUNT-1),(a6)+     ; 1rst value in a6
    rts

;==========================================================

    section .fastram

ArrayFill:
    tst.b   -1(a1)               ; last value in a6 array ?
    beq     ArrayFillExit        ; then exit
    move.b  -1(a0),(a0)+         ; 0,1,2,3...(COUNT-1)
    move.b  -1(a1),(a1)+         ; (COUNT-1)..3,2,1,0
    move.w  -2(a2),(a2)+         ; 0,1,2,3...(COUNT-1)
    move.w  -2(a3),(a3)+         ; (COUNT-1)..3,2,1,0
    move.l  -4(a4),(a4)+         ; 0,1,2,3...(COUNT-1)
    move.l  -4(a5),(a5)+         ; (COUNT-1)..3,2,1,0
    move.l  -4(a6),(a6)+         ; (COUNT-1)..3,2,1,0
    addi.b  #1,-1(a0)            ; increment value in a0
    subi.b  #1,-1(a1)            ; decrement value in a1
    addi.w  #1,-2(a2)            ; increment value in a2
    subi.w  #1,-2(a3)            ; decrement value in a3
    addi.l  #1,-4(a4)            ; increment value in a4
    subi.l  #1,-4(a5)            ; decrement value in a5
    subi.l  #1,-4(a6)            ; decrement value in a6
    bra     ArrayFill            ; continue
ArrayFillExit:
    rts

;==========================================================

SelfTest:
    jsr     ArrayLoad            ; Load buffers
    adda.l  #(COUNT*1),a1        ; Mem block + Size
    adda.l  #(COUNT*2),a3        ; Mem block + Size
    adda.l  #(COUNT*4),a5        ; Mem block + Size
    adda.l  #(COUNT*4),a6        ; Mem block + Size
    move.l  #(COUNT-1),d0        ; Loop counter
SelfTestLoop:
    move.l  #$FF,d1              ; Assert register != 0
    move.b  -(a1),d1             ; store a1 in d1 and decrement a1
    sub.b   (a0)+,d1             ; d1 should be 0
    move.l  d1,assert_zero       ; assert 0
    move.l  #$FFFF,d1            ; Assert register != 0
    move.w  -(a3),d1             ; store a3 in d1 and decrement a3
    sub.w   (a2)+,d1             ; d1 should be 0
    move.l  d1,assert_zero       ; assert 0
    move.l  #$FFFFFFFF,d1        ; Assert register != 0
    move.l  -(a5),d1             ; store a5 in d1 and decrement a5
    sub.l   (a4)+,d1             ; d1 should be 0
    move.l  d1,assert_zero       ; assert 0
    dbra    d0,SelfTestLoop      ; continue
    rts

;==========================================================
;   DATA SECTION
;==========================================================
    
    section .chipram

BUFFER0:
    ds.b COUNT
    ds.b SPACER
    even

BUFFER1:
    ds.b COUNT
    ds.b SPACER
    even

    section .fastram

BUFFER2:
    ds.w COUNT
    ds.b SPACER
    even

BUFFER3:
    ds.w COUNT
    ds.b SPACER
    even

BUFFER4:
    ds.l COUNT
    ds.b SPACER
    even

    section .chipram

BUFFER5:
    ds.l COUNT
    ds.b SPACER
    even
    
    section .fastram

BUFFER6:
    ds.l COUNT
    ds.b SPACER
    even

;==========================================================

    END

;==========================================================
