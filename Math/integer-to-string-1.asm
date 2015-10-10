;==========================================================
; ASM Testcase
; flype, 2015-10-07
; Fibonacci + Integer To String + AmigaOS
;==========================================================
; https://github.com/flype44/M68K/blob/master/Math/integer-to-string-1.asm
;==========================================================

;==========================================================
; CONSTANTS
;==========================================================

CR           EQU  $0A         ; Carriage Return
ExecBase     EQU    4         ; Exec->Base
OpenLibrary  EQU -552         ; Exec->OpenLibrary(name,version)
CloseLibrary EQU -414         ; Exec->CloseLibrary(base)
PutStr       EQU -948         ; DOS->PutStr(str)

;==========================================================
; MAIN
;==========================================================

Main:
    jsr     OpenDOS           ; open DOS library
    move.l  #StrStart,d1      ; D1 = StrStart
    jsr     PrintString       ; output string in CLI
    lea     StrBuffer,a0      ; A0 = String Buffer
    lea     Precalc,a5        ; A1 = Precalc values
    moveq   #0,d5             ; D1 = 0 (1st fibonacci value)
    moveq   #1,d2             ; D2 = 1 (2nd fibonacci value)
    clr.l   d6                ; error counter
MainLoop:
    clr.l   d0                ; D0 = 0
    move.l  (a5)+,d4          ; D4 = next precalc value
    beq     MainExit          ; exit if d4 = 0
    move.l  d5,d3             ; D3 = D1
    add.l   d2,d3             ; D3 = D2 + D3
    move.l  d2,d5             ; D1 = D2
    move.l  d3,d2             ; D2 = D3
    move.l  d2,d0             ; D0 = calculated fibonacci
    jsr     PrintInteger      ; output number in CLI
    move.l  d4,d0             ; D0 = precalculated fibonacci
    jsr     PrintInteger      ; output number in CLI
    sub.l   d2,d4             ; D4 = D4 - D2
    beq.l   MainSuccess       ; branch to success if D4 = 0
    add.l   #1,d6             ; increment error counter
    move.l  #StrFailure,d1    ; D1 = StrStart
    bra     MainContinue      ; continue
MainSuccess:
    move.l  #StrSuccess,d1    ; D1 = StrStart
MainContinue:
    jsr     PrintString       ; output string in CLI
    bra     MainLoop          ; continue
MainExit:
    move.l  #StrErrCnt,d1     ; D1 = StrErrCnt
    jsr     PrintString       ; output string in CLI
    move.l  d6,d0             ; D0 = error count
    jsr     PrintInteger      ; output number in CLI
    jsr     CloseDOS          ; close DOS library
    move.l  #StrStop,d1       ; D1 = StrStop
    jsr     PrintString       ; output string in CLI
    moveq   #0,d0             ; return code
    rts                       ; stop execution

;==========================================================
;   ROUTINES PRINT
;==========================================================

PrintInteger:
    movem.l d0-d7/a0-a6,-(sp) ; store registers state
    move.b  #0,-(sp)          ; null char
    move.b  #CR,-(sp)         ; carriage return char
PrintInteger1:
    divul.l #10,d1:d0         ; d0 = d0 / 10
    add.b   #$30,d1           ; d1 to ascii
    move.b  d1,-(sp)          ; store d1 in stack
    cmpi.b  #0,d0             ; if d0 > 0
    bhi     PrintInteger1     ; continue
PrintInteger2:
    move.b  (sp)+,(a0)        ; restore char from stack, put it in StrBuffer
    cmpi.b  #0,(a0)+          ; if last char is not null
    bne     PrintInteger2     ; continue
PrintInteger3:
    move.l  #StrBuffer,d1     ; D1 = StrBuffer
    movea.l DosBase,a6        ; A6 = Exec base
    jsr     PutStr(a6)        ; print string
    movem.l (sp)+,d0-d7/a0-a6 ; restore registers state
    rts

PrintString:
    movem.l d0-d7/a0-a6,-(sp) ; store registers state
    movea.l DosBase,a6        ; A6 = Exec base
    jsr     PutStr(a6)        ; print string
    movem.l (sp)+,d0-d7/a0-a6 ; restore registers state
    rts

OpenDOS:
    movem.l d0/a1/a6,-(sp)    ; store registers state
    movea.l ExecBase,a6       ; A6 = Exec base
    lea     DosName,a1        ; A1 = Library name
    moveq.l #37,d0            ; D0 = Library version
    jsr     OpenLibrary(a6)   ; D0 = DOS base
    tst.l   d0                ; if D0 = NULL
    beq     MainExit          ; then exit
    move.l  d0,DosBase        ; store DOS base
    movem.l (sp)+,d0/a1/a6    ; restore registers state
    rts

CloseDOS:
    movem.l a1/a6,-(sp)       ; store registers state
    movea.l DosBase,a1        ; A1 = DOS base
    movea.l ExecBase,a6       ; A6 = Exec base
    jsr     CloseLibrary(a6)  ; close DOS library
    movem.l (sp)+,a1/a6       ; restore registers state
    rts

;==========================================================
; Data Section
;==========================================================

DosBase    dc.l 0
DosName    dc.b "dos.library",0
StrStart   dc.b "Start Fibonacci",CR,CR,0
StrStop    dc.b CR,"End of test",CR,0
StrSuccess dc.b "Success",CR,CR,0
StrFailure dc.b "Failure",CR,CR,0
StrErrCnt  dc.b "Error count : ",0

    EVEN

StrBuffer  ds.b 32 ; String Buffer for CLI output

Precalc:
    ; fibonacci values
    dc.l 1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181
    dc.l 6765,10946,17711,28657,46368,75025,121393,196418,317811
    dc.l 514229,832040,1346269,2178309,3524578,5702887,9227465
    dc.l 14930352,24157817,39088169,63245986,102334155,165580141
    dc.l 267914296,433494437,701408733,1134903170,1836311903,2971215073
    ; fibonacci overflow values
    dc.l 559680,3483774753,3996334433,3185141890,2886509027,1776683621
    dc.l 368225352,2144908973,2513134325,363076002,2876210327,3239286329
    ; last value
    dc.l 0

;==========================================================
; End of program
;==========================================================

    end