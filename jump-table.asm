;=========================================
; 68K ASM Test
; Jump Table using Indirect Memory Access
;=========================================

assert_zero EQU $00D0000C

size equ 13

;=========================================

Start:
    clr.l   d0             ; Current value
    clr.l   d1             ; Calculated result
    clr.l   d2             ; Precalculated result
    clr.l   d7             ; Loop counter
    lea     Values,a0      ; Address of values
    lea     Precalcs,a1    ; Address of precalculated results
    lea     MyRoutines,a2  ; Address of the routines table
    move.l  #size-1,d7     ; Init loop counter
.loop
    move.l  (a0)+,d0       ; Read value
    chk.l   #4,d0          ; Check bounds
    bsr     MyRoutine      ; Jump in routines table
    add.l   d0,d1          ; Calculate result
    move.l  d1,d2          ; Store result
    sub.l   (a1)+,d2       ; Compare with precalculated result
    move.l  d2,assert_zero ; Raise error if != 0
.continue
    dbf     d7,.loop       ; Continue
.exit
    stop    #-1            ; Stop execution

;=========================================
    
MyRoutine:
    jmp     ([a2,d0*4])    ; Memory Indirect Jump
MyRoutine0:
    not.l   #1,d0
    rts
MyRoutine1:
    sub.l   #3,d0
    rts
MyRoutine2:
    ror.l   #7,d0
    rts
MyRoutine3:
    rol.l   #1,d0
    rts
MyRoutine4:
    muls.l  #2,d0
    rts
MyRoutines:
    dc.l MyRoutine0
    dc.l MyRoutine1
    dc.l MyRoutine2
    dc.l MyRoutine3
    dc.l MyRoutine4

;=========================================

Values:
    dc.l 2,5,1,4,0,0,0,4,1,2,2,3,1

Precalcs:
    dc.l $04000000,$04000006,$04000004,$0400000C
    dc.l $0400000D,$0400000E,$0400000F,$04000017
    dc.l $04000015,$08000015,$0C000015,$0C00001B
    dc.l $0C000019

;=========================================
