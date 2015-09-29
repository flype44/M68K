*-----------------------------------------------------------
* Title      : eratosieve
* Written by : pisklak
* Date       : 2015-09-28
* Description: eratostenes sieve
*-----------------------------------------------------------

RANGE       EQU 8192
ASSERT_ZERO EQU $00D0000C

;   DC.L    0
;   DC.L    START
    SECTION .FASTRAM

;==============================================================================
; MAIN PROGRAM
;==============================================================================

START:
    clr.    D2
    move.l  #2,D1
    lea     VALUES,A1
    lea     PRECALC,A3
    move.l  #RANGE*4,D6
    sub.l   #8,D6
    add.l   A1,D6
    move.l  #2,D0

*------------ This is write arry loop. It populates mem arry with numbers from 2 to range  

WL:
    cmp.l   #RANGE,D0
    bgt     SIEVE
    move.l  D0,(A1)+
    add.l   #1,D0
    jmp     WL

*------------- Start of the main progeam      

SIEVE:
    lea     VALUES,A1
    lea     VALUES,A2

*------------- This is Find Loop - it reads numbers from arry and chscks if it is not 0. Then we jump into our Clear Loop

SIEVE_FL:
    cmp.l   A2,D6
    blt     SIEVE_CHECK  
    cmp.l   #0,(A2)
    bne     SIEVE_CL
    adda.l  #4,A2
    jmp     SIEVE_FL

*------------- Clear loop  clears all multiplies of the number finded by Find Loop

SIEVE_CL:
    move.l  (A2),D1
    move.l  D1,D2
    add.l   D2,D1
    clr.l   D0

*------------- This is main loop in CL

SIEVE_L:
    move.l  D1,D0
    sub.l   #2,D0
    lsl.l   #2,D0
    move.l  A1,D3
    add.l   D0,D3
    cmp.l   D3,D6
    blt     SIEVE_A
    clr.l   (A1,D0)

*------------- ASSERT_ZERO checking in Clear Loop

    move.l  (A1,D0),D4
    sub.l   (A3,D0),D5
    sub.l   D4,D5
    move.l  D5,ASSERT_ZERO
    add.l   D2,D1
    jmp     SIEVE_L

*------------- at the end we move one number ahead and will check in Fl

SIEVE_A:
    adda.l  #4,A2
    jmp     SIEVE_FL

;==============================================================================
; Assert Section
;==============================================================================

SIEVE_CHECK:      
    lea     VALUES,A1
    lea     PRECALC,A2
    clr     D0
SIEVE_CHECK_LOOP:
    move.l  (A1,D0),D1
    sub.l   (A2,D0),D1
    move.l  D1,ASSERT_ZERO
    cmp.l   #RANGE*4-8,D0
    bgt     SIEVE_CHECK_END
    add.l   #4,D0
    jmp     SIEVE_CHECK_LOOP
SIEVE_CHECK_END:
    RTS         ; stop aos
    ;STOP #-1   ; stop sim
    ;SIMHALT    ; stop easy68k

;==============================================================================
; Data Section
;==============================================================================

    SECTION .FASTRAM

VALUES:
    DS.L 8192
    DS.B 16

;==============================================================================
; Precalculated Data Section
;==============================================================================

    SECTION .CHIPRAM

PRECALC:
    INCBIN "sieve-8192.bin"

;==============================================================================
; End of file
;==============================================================================
