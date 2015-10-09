;==========================================================
; ASM Testcase - Factorial - Recursive
; flype, 2015-10-07
;==========================================================
; https://github.com/flype44/M68K/blob/master/Math/math-factoriel-recurs-1.asm
;==========================================================
; function Main() {
;   for(var n = 1; n <= 12; n++) {
;     console.log(fact(n));
;   }
; }
; function Fact32(n) {
;   return (n == 1) ? 1 : n * Fact32(n-1);
; }
;==========================================================

;==========================================================
; CONSTANTS
;==========================================================

COUNT        EQU 4        ; Max = Number of values in Precalc32 array.
ASSERT_ZERO  EQU $00d0000c ; Assert Register
ExecBase     EQU    4      ; Exec::Base()
OpenLibrary  EQU -552      ; Exec::OpenLibrary(name,version)
CloseLibrary EQU -414      ; Exec::CloseLibrary(base)
PutStr       EQU -948      ; DOS::PutStr(str)
Write        EQU  -48
Output       EQU  -60

;==========================================================
; HEADER
;==========================================================

;    DC.L    0
;    DC.L    Main
    section .fastram

;==========================================================
; MAIN
;==========================================================

Main:
    jsr     OpenDOS          ; Open DOS library
    lea     Precalc32End,a0  ; load precalc
    clr.l   d0               ; fact = 0
    clr.l   d1               ; PutStr argument
    clr.l   d2               ; n = 0
    clr.l   d3               ; unused
    clr.l   d4               ; unused
    clr.l   d5               ; unused
    clr.l   d6               ; unused
    clr.l   d7               ; fact call counter
MainLoop:
    addi.l  #1,d2            ; n++
    cmpi.l  #COUNT,d2        ; if ( n > 12 )
    bgt     MainExit         ; then exit
    move.l  d2,-(sp)         ; store n
    jsr     Fact32           ; fact32(n)
;    move.l  d2,-(sp)         ; store n
;    jsr     Print            ; Output result in CLI
;    move.l  (sp)+,d2         ; restore n
    sub.l   -(a0),d0         ; check d0
    bra     MainLoop         ; next value
MainExit:
    move.l  (sp)+,d0         ; restore n
    jsr     CloseDOS         ; Close DOS library
    moveq   #0,d0            ; AmigaDOS return code (success)
    rts                      ; stop execution
ExitWithError:
    moveq   #0,d0            ; AmigaDOS return code (error)
    rts                      ; stop execution

;==========================================================
; Fact32(n)
;==========================================================

Fact32:
    addi.l  #1,d7            ; increment call counter
    move.l  4(sp),d0         ; load n
    cmpi.l  #1,d0            ; if ( n != 1 )
    bne     Fact32n          ; continue
    move.l  #1,d0            ; else n = 1
    rts                      ; return
Fact32n:
    subi.l  #1,d0            ; n - 1
    move.l  d0,-(sp)         ; store n
    jsr     Fact32           ; fact( n - 1 )
    add.l   #4,sp            ; get result
    mulu.l  4(sp),d0         ; n * fact
    rts                      ; return

;==========================================================
;   ROUTINES
;==========================================================

OpenDOS:
    movea.l ExecBase,a6      ; A6 = Exec base
    lea     DosName,a1       ; A1 = Library name
    moveq.l #37,d0           ; D0 = Library version
    jsr     OpenLibrary(a6)  ; D0 = Open DOS library
    tst.l   d0               ; If D0 = NULL
    beq.s   ExitWithError    ; Then exit with error
    move.l  d0,DosBase       ; Store DOS base
    rts

CloseDOS:
    movea.l DosBase,a1       ; A1 = DOS base
    movea.l ExecBase,a6      ; A6 = Exec base
    jsr     CloseLibrary(a6) ; Close DOS library
    rts

Print:
    move.l  #StrResult,d1    ; string to print
    movea.l DosBase,a6       ; A6 = Exec base
    jsr     PutStr(a6)       ; Print string
    rts

;==========================================================
; Data Section
;==========================================================

DosBase dc.l 0
DosName dc.b "dos.library",0 ; Null-terminated string

StrResult dc.b '0x____ ____',$0a,0 ; DOS::PutStr(StrResult)

Precalc32:
    ; 32 bits overflow results
    dc.l $d1c00000,$33680000,$e0d80000,$b8c40000
    dc.l $82b40000,$06890000,$ca730000,$eecd8000
    dc.l $77758000,$77775800,$4c3b2800,$7328cc00
    ; 32 bits results
    dc.l $1c8cfc00,$02611500,$00375f00,$00058980
    dc.l $00009d80,$000013b0,$000002d0,$00000078
    dc.l $00000018,$00000006,$00000002,$00000001
Precalc32End:

;==========================================================
; End of program
;==========================================================

    end
