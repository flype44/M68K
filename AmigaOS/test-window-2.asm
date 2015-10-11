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
Delay        EQU -198

WFLG_SIZEGADGET	    EQU $0001
WFLG_DRAGBAR		EQU $0002
WFLG_DEPTHGADGET	EQU $0004
WFLG_CLOSEGADGET	EQU $0008
WFLG_SIZEBRIGHT		EQU $0010
WFLG_SIZEBBOTTOM	EQU $0020
WFLG_SMART_REFRESH  EQU $0000
WFLG_SIMPLE_REFRESH EQU $0040
WFLG_REPORTMOUSE	EQU $0200
WFLG_ACTIVATE		EQU $1000
WFLG_BORDERLESS     EQU $8000
WFLG_HASZOOM		EQU $20000000

;==========================================================
; MAIN
;==========================================================

start:
    ;
    lea     DosName,a1         ; a1 = library name
    move.l  #37,d0             ; d0 = library version
    move.l  ExecBase,a6        ; a6 = exec base
    jsr     OpenLibrary(a6)    ; call OpenLibrary()
    tst.l   d0                 ; test d0
    beq     exit1              ; if library base is null
    move.l  d0,DosBase         ; store dos base
    ;
    lea     IntuiName,a1       ; a1 = library name
    move.l  #0,d0              ; d0 = library version
    move.l  ExecBase,a6        ; a6 = exec base
    jsr     OpenLibrary(a6)    ; call OpenLibrary()
    tst.l   d0                 ; test d0
    beq     exit2              ; if library base is null
    move.l  d0,IntuiBase       ; store intuition base
    ;
loop:
    ;
    lea     WndProps,a0        ; window properties
    add.w   #2,0(a0)           ; x + 2
    add.w   #1,2(a0)           ; y + 1
    add.w   #2,4(a0)           ; w + 2
    add.w   #1,6(a0)           ; h + 1
    move.l  IntuiBase,a6       ; a6 = intuition base
    jsr     OpenWindow(a6)     ; call OpenWindow()
    tst.l   d0                 ; test d0
    beq     exit3              ; if window pointer is null
    move.l  d0,WndPtr          ; store window pointer
    ;
    move.l  #5,d1              ; wait time
    move.l  DosBase,a6         ; a6 = dos base
    jsr     Delay(a6)          ; call Delay()
    ;
    move.l  WndPtr,a0          ; a0 = Window pointer
    move.l  IntuiBase,a6       ; a6 = intuition base
    jsr     CloseWindow(a6)    ; call OpenWindow()
    ;
    bra     loop               ; continue
    ;
exit3:
    move.l  IntuiBase,a1       ; a1 = intuition base
    move.l  ExecBase,a6        ; a6 = exec base
    jsr     CloseLibrary(a6)   ; call CloseLibrary()
exit2:
    move.l  DosBase,a1         ; a1 = dos base
    move.l  ExecBase,a6        ; a6 = exec base
    jsr     CloseLibrary(a6)   ; call CloseLibrary()
exit1:
    rts

;==========================================================
; Data Section
;==========================================================

WndPtr    dc.l 0
DosBase   dc.l 0
IntuiBase dc.l 0

DosName   dc.b 'dos.library',0
    even

IntuiName dc.b 'intuition.library',0
    even

WndProps:
    dc.w  0,0,40,20 ; x,y,w,h
    dc.b  0,1
    dc.l  0,$2000126F,0,0,0,0,0
    dc.w  0,0,0,0,1
    even

;==========================================================
; End of program
;==========================================================

    end
