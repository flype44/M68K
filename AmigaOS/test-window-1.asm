;==========================================================
; ASM Testcase
; flype, 2015-10-11
;==========================================================

;==========================================================
; CONSTANTS
;==========================================================

ExecBase     EQU    4
OpenLibrary  EQU -552
CloseLibrary EQU -414
OpenWindow   EQU -204
CloseWindow  EQU  -72

;==========================================================
; MAIN
;==========================================================

start:
    move.l  ExecBase,a6        ; a6 = exec base
    move.l  #IntuiName,a1      ; a1 = library name
    jsr     OpenLibrary(a6)    ; call OpenLibrary()
    move.l  d0,IntuiBase       ; store intuition base
    move.l  d0,a6              ; a6 = intuition base
    move.l  #10,d5             ; loop counter
    lea     WindowSizes,a5     ; window sizes
loop:
    lea     WindowProps,a0
    move.w  (a5)+,4(a0)        ; load width
    move.w  (a5)+,6(a0)        ; load height
    movem.l d0-d7/a0-a6,-(sp)  ; store registers state
    jsr     OpenWindow(a6)     ; call OpenWindow()
    move.l  d0,WindowPtr       ; store window pointer
    move.l  WindowPtr,a0       ; a0 = Window pointer
    jsr     CloseWindow(a6)    ; call OpenWindow()
    movem.l (sp)+,d0-d7/a0-a6  ; restore registers state
    cmpi.l  #0,(a5)            ; check if last value
    bne     loop               ; else continue
exit:
    move.l  ExecBase,a6        ; a6 = exec base
    move.l  IntuiBase,a1       ; a1 = intuition base
    jsr     CloseLibrary(a6)   ; call CloseLibrary()
    rts

;==========================================================
; Data Section
;==========================================================

IntuiBase dc.l 0
WindowPtr dc.l 0

IntuiName dc.b 'intuition.library',0
    even

WindowProps:
    dc.w  0,0,0,0 ; x,y,w,h
    dc.b  0,1
    dc.l  0,$11800,0,0,0,0,0
    dc.w  0,0,0,0,1
    even

WindowSizes:
    dc.w  400,200
    dc.w  320,100
    dc.w  100,100
    dc.w  640,201
    dc.w  10,208
    dc.w  10,200
    dc.w  320,100
    dc.w  64,150
    dc.w  23,78
    dc.w  140,96
    dc.w  400,200
    dc.w  200,210
    dc.w  400,200
    dc.w  320,100
    dc.w  100,100
    dc.w  640,220
    dc.w  10,142
    dc.w  10,200
    dc.w  320,100
    dc.w  64,150
    dc.w  23,78
    dc.w  140,96
    dc.w  400,200
    dc.w  200,199
    dc.w  400,200
    dc.w  320,100
    dc.w  100,100
    dc.w  640,202
    dc.w  10,230
    dc.w  10,200
    dc.w  320,100
    dc.w  64,150
    dc.w  23,78
    dc.w  140,96
    dc.w  400,200
    dc.w  200,210
    dc.w  400,200
    dc.w  320,100
    dc.w  100,100
    dc.w  640,201
    dc.w  10,208
    dc.w  10,200
    dc.w  320,100
    dc.w  64,150
    dc.w  23,78
    dc.w  140,96
    dc.w  400,200
    dc.w  200,210
    dc.w  400,200
    dc.w  320,100
    dc.w  100,100
    dc.w  640,220
    dc.w  10,142
    dc.w  10,200
    dc.w  320,100
    dc.w  64,150
    dc.w  23,78
    dc.w  140,96
    dc.w  400,200
    dc.w  200,199
    dc.w  400,200
    dc.w  320,100
    dc.w  100,100
    dc.w  640,202
    dc.w  10,230
    dc.w  10,200
    dc.w  320,100
    dc.w  64,150
    dc.w  23,78
    dc.w  140,96
    dc.w  400,200
    dc.w  200,210
    dc.w  0
    even

;==========================================================
; End of program
;==========================================================

    end
