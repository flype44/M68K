;==========================================================
; "Hello World" in AmigaOS
; https://github.com/flype44/M68K/blob/master/AmigaOS/flype-helloworld.asm
;==========================================================

ExecBase     EQU    4        ; Exec.Base()
OpenLibrary  EQU -552        ; D0:libBase = Exec.OpenLibrary(A1:libName,D0:version)
CloseLibrary EQU -414        ; Exec.CloseLibrary(A1:libBase)
PutStr       EQU -948        ; DOS.PutStr(D1:str)

;==========================================================
;   MAIN
;==========================================================

Start:
    jsr     OpenDOS          ; Open DOS library
    jsr     Print            ; Print Hello World in CLI
    jsr     Print            ; Print Hello World in CLI
    jsr     Print            ; Print Hello World in CLI
    jsr     CloseDOS         ; Close DOS library
Exit:
    moveq   #0,d0            ; AmigaDOS return code
    rts

;==========================================================
;   ROUTINES
;==========================================================

OpenDOS:
    move.l  ExecBase,a6      ; A6 = Exec base
    lea     DosName,a1       ; A1 = Library name
    moveq   #0,d0            ; D0 = Library version
    jsr     (OpenLibrary,a6) ; D0 = Open DOS library
    move.l  d0,a6            ; A6 = DOS base
    rts

CloseDOS:
    move.l  a6,a1            ; A1 = DOS base
    move.l  ExecBase,a6      ; A6 = Exec base
    jsr     CloseLibrary(a6) ; Close DOS library
    rts

Print:
    move.l  #StrHello,d1     ; D1 = Hello World !
    jsr     PutStr(a6)       ; Print string
    rts

;==========================================================
;   DATA SECTION
;==========================================================

DosName  dc.b "dos.library",0      ; Null-terminated string
StrHello dc.b "Hello World!",$0A,0 ; Null-terminated string + Return Carriage

;==========================================================
