;==============================================================================
; Program: BatTest2.asm
; Short:   Test the chipset planars and copper
; Requir:  Vampire with core V3_PLANAR_xx.jic or better
; Author:  APOLLO-Team, flype. 2017-April
;==============================================================================

    INCLUDE dos/dos.i
    INCLUDE dos/dos_lib.i
    INCLUDE exec/memory.i
    INCLUDE exec/exec_lib.i
    INCLUDE graphics/gfx.i
    INCLUDE graphics/gfxbase.i
    INCLUDE graphics/graphics_lib.i
    INCLUDE intuition/screens.i
    INCLUDE intuition/intuition_lib.i
    INCLUDE intuition/intuitionbase.i

    MACHINE MC68020

;==============================================================================
;   PUBLIC DEFINITIONS
;==============================================================================

CIAAPRA       EQU $bfe001

DMACONR       EQU $dff002
ADKCONR       EQU $dff010
INTENAR       EQU $dff01c
INTREQR       EQU $dff01e

DMACON        EQU $dff096
ADKCON        EQU $dff09e
INTENA        EQU $dff09a
INTREQ        EQU $dff09c

BLTCON0       EQU $dff040
BLTCON1       EQU $dff042
BLTAFWM       EQU $dff044
BLTALWM       EQU $dff046
BLTCPTH       EQU $dff048
BLTBPTH       EQU $dff04C
BLTAPTH       EQU $dff050
BLTDPTH       EQU $dff054
BLTSIZE       EQU $dff058
BLTBMOD       EQU $dff062
BLTCMOD       EQU $dff060
BLTAMOD       EQU $dff064
BLTDMOD       EQU $dff066
COP1LC        EQU $dff080

;==============================================================================
;   PRIVATES DEFINITIONS
;==============================================================================

WIDTH         EQU 320                      ; Visible width
HEIGHT        EQU 256                      ; Visible height
DEPTH         EQU 6                        ; Number of bitplanes
BYTESPERROW   EQU (WIDTH/8)                ; Bytes per row

;==============================================================================
    SECTION S_0,CODE
;==============================================================================

MAIN:
    
.opendos
    lea       _DOSNAME,a1                  ; Open DOS
    moveq.l   #0,d0                        ; 
    CALLEXEC  OpenLibrary                  ; 
    tst.l     d0                           ; 
    beq       .exit                        ; Exit on error
    move.l    d0,_DOSBase                  ; 

.openint
    lea       _INTNAME,a1                  ; Open Intuition
    move.l    #0,d0                        ; 
    CALLEXEC  OpenLibrary                  ; 
    tst.l     d0                           ; 
    beq       .closedos                    ; Exit on error
    move.l    d0,_IntuitionBase            ; 

.opengfx
    lea       _GFXNAME,a1                  ; Open Graphics
    moveq.l   #0,d0                        ; 
    CALLEXEC  OpenLibrary                  ; 
    tst.l     d0                           ; 
    beq       .closeint                    ; Exit on error
    move.l    d0,_GfxBase                  ; 

.fill
    lea       _USERPLANE2,a0               ; Load empty plane 2
    move.l    #HEIGHT/2,d0                   ; Number of rows
.fillY
    move.l    #WIDTH/4,d1                  ; Number of pixs/row
.fillX
;   move.w    #%0001000100010001,(a0)+     ; Draw pixels
    dbf       d1,.fillX                    ; Continue X
    add.l     #BYTESPERROW*2,a0            ; 
    dbf       d0,.fillY                    ; Continue Y

.init
    move.w    DMACONR,d0                   ; Store DMACON
    or.w      #$8000,d0                    ; 
    move.w    d0,_OldDMACON                ; 
    move.w    INTENAR,d0                   ; Store INTENA
    or.w      #$8000,d0                    ; 
    move.w    d0,_OldINTENA                ; 
    move.w    INTREQR,d0                   ; Store INTREQ
    or.w      #$8000,d0                    ; 
    move.w    d0,_OldINTREQ                ; 
    move.w    ADKCONR,d0                   ; Store ADKCON
    or.w      #$8000,d0                    ; 
    move.w    d0,_OldADKCON                ; 
    move.l    _GfxBase,a0                  ; 
    move.l    gb_ActiView(a0),_OldView     ; Store VIEW
    move.l    gb_copinit(a0),_OldCopper    ; Store COPPER

.openscreen
    move.l    #0,a1                        ; LoadView(NULL)
    CALLGRAF  LoadView                     ; 
    CALLGRAF  WaitTOF                      ; Wait
    CALLGRAF  WaitTOF                      ; Wait for Laced
    CALLGRAF  OwnBlitter                   ; Own Blitter
    CALLGRAF  WaitBlit                     ; Wait Blitter
    CALLEXEC  Forbid                       ; Disable Multitasking    

.setdepth
    lea       CN0,a0                       ; Load Copper BPLCON0
    move.w    #DEPTH*$1000,2(a0)           ; Update Depth
;    move.w    #$0010,2(a0)                 ; Update Depth

.setcopper
    lea       _USERCOPPER,a0               ; Set Copperlist
    move.l    a0,COP1LC                    ; 

.mainloop

.buttons
    btst.b    #6,CIAAPRA                   ; Exit on FIR0
    beq.s     .restore                     ; 
    btst.b    #7,CIAAPRA                   ; Exit on FIR1
    beq.s     .restore                     ; 

.mouse
    move.l    _IntuitionBase,a0            ; IntuitionBase
    move.w    ib_MouseY(a0),d2             ; IntuitionBase->MouseY
    mulu.w    #BYTESPERROW,d2              ; MouseY * BytesPerRow

.update
    lea       _USERPLANE1,a0               ; Load Bitmap
    lea       P1H,a1                       ; Load Copper BPLxPTR
    moveq.l   #DEPTH-1,d1                  ; Number of planes to set
.doplane
    move.l    a0,d0                        ; Load plane
    move.w    d0,6(a1)                     ; dc.w BPLxPTH,PTH
    swap      d0                           ; Swap Low <=> High
    move.w    d0,2(a1)                     ; dc.w BPLxPTL,PTL
    addq.l    #8,a1                        ; Next BPLxPTR
    add.l     d2,a0                        ; Next BPLxPTR
    dbf       d1,.doplane                  ; Next plane

.continue
    CALLGRAF  WaitTOF                      ; Wait
    bra.s     .mainloop                    ; Continue

.restore
    move.w    #$7fff,DMACON                ; Restore DMACON
    move.w    _OldDMACON,DMACON            ; 
    move.w    #$7fff,INTENA                ; Restore INTENA
    move.w    _OldINTENA,INTENA            ; 
    move.w    #$7fff,INTREQ                ; Restore INTREQ
    move.w    _OldINTREQ,INTREQ            ; 
    move.w    #$7fff,ADKCON                ; Restore ADKCON
    move.w    _OldADKCON,ADKCON            ; 
    move.l    _OldCopper,COP1LC            ; Restore COPPER
    move.l    _OldView,a1                  ; Restore VIEW
    CALLGRAF  LoadView                     ; 
    CALLGRAF  WaitTOF                      ; Wait
    CALLGRAF  WaitTOF                      ; Wait for Laced
    CALLGRAF  WaitBlit                     ; Wait Blitter
    CALLGRAF  DisownBlitter                ; Disown Blitter
    CALLEXEC  Permit                       ; Enable Multitasking

.closegfx
    move.l    _GfxBase,a1                  ; Close Graphics
    CALLEXEC  CloseLibrary                 ; 

.closeint
    move.l    _IntuitionBase,a1            ; Close Intuition
    CALLEXEC  CloseLibrary                 ; 

.closedos
    move.l    _DOSBase,a1                  ; Close DOS
    CALLEXEC  CloseLibrary                 ; 

.exit
    moveq.l   #0,d0                        ; Return Code
    rts                                    ; Exit program

;==============================================================================
;   SUB-ROUTINES
;==============================================================================


; (sub-routines here)


;==============================================================================
    SECTION S_1,DATA
;==============================================================================

    EVEN
_DOSBase       ds.l 1
_GfxBase       ds.l 1
_IntuitionBase ds.l 1

    EVEN
_OldView       ds.l 1
_OldCopper     ds.l 1
_OldDMACON     ds.l 1
_OldINTENA     ds.l 1
_OldINTREQ     ds.l 1
_OldADKCON     ds.l 1

    EVEN
_DOSNAME:      DOSNAME
_GFXNAME:      GRAFNAME
_INTNAME:      INTNAME

;==============================================================================
    SECTION S_2,DATA_C
;==============================================================================

    EVEN
_USERCOPPER:
    dc.w      $0106,$0000   ; BPLCON3
    dc.w      $0180,$0000   ; COLOR00
    dc.w      $0182,$0002   ; COLOR01
    dc.w      $0184,$0004   ; COLOR02
    dc.w      $0186,$0006   ; COLOR03
    dc.w      $0188,$0008   ; COLOR04
    dc.w      $018a,$000A   ; COLOR05
    dc.w      $018c,$000C   ; COLOR06
    dc.w      $018e,$000E   ; COLOR07

    dc.w      $0190,$0000   ; COLOR00
    dc.w      $0192,$0020   ; COLOR01
    dc.w      $0194,$0040   ; COLOR02
    dc.w      $0196,$0060   ; COLOR03
    dc.w      $0198,$0080   ; COLOR04
    dc.w      $019a,$00A0   ; COLOR05
    dc.w      $019c,$00C0   ; COLOR06
    dc.w      $019e,$00E0   ; COLOR07
    
    dc.w      $01a0,$0000   ; COLOR00
    dc.w      $01a2,$0200   ; COLOR01
    dc.w      $01a4,$0400   ; COLOR02
    dc.w      $01a6,$0600   ; COLOR03
    dc.w      $01a8,$0800   ; COLOR04
    dc.w      $01aa,$0A00   ; COLOR05
    dc.w      $01ac,$0C00   ; COLOR06
    dc.w      $01ae,$0E00   ; COLOR07
    
    dc.w      $01b0,$0000   ; COLOR00
    dc.w      $01b2,$0222   ; COLOR01
    dc.w      $01b4,$0444   ; COLOR02
    dc.w      $01b6,$0666   ; COLOR03
    dc.w      $01b8,$0888   ; COLOR04
    dc.w      $01ba,$0AAA   ; COLOR05
    dc.w      $01bc,$0CCC   ; COLOR06
    dc.w      $01be,$0EEE   ; COLOR07
    
    dc.w      $010c,$0011   ; BPLCON4
    dc.w      $008e,$2976   ; DIWSTRT
CN0 dc.w      $0100,$1000   ; BPLCON0 <<< number of planes
    dc.w      $0090,$39b6   ; DIWSTOP
    dc.w      $0092,$0038   ; DDFSTRT
    dc.w      $0094,$00d0   ; DDFSTOP
    dc.w      $0102,$0055   ; BPLCON1
    dc.w      $0108,$0000   ; BPL1MOD
    dc.w      $010a,$0000   ; BPL2MOD

S1H dc.w      $0120,$0000   ; SPR1PTR high
S1L dc.w      $0122,$0000   ; SPR1PTR low
S2H dc.w      $0124,$0000   ; SPR2PTR high
S2L dc.w      $0126,$0000   ; SPR2PTR low
S3H dc.w      $0128,$0000   ; SPR3PTR high
S3L dc.w      $012a,$0000   ; SPR3PTR low
S4H dc.w      $012c,$0000   ; SPR4PTR high
S4L dc.w      $012e,$0000   ; SPR4PTR low
S5H dc.w      $0130,$0000   ; SPR5PTR high
S5L dc.w      $0132,$0000   ; SPR5PTR low
S6H dc.w      $0134,$0000   ; SPR6PTR high
S6L dc.w      $0136,$0000   ; SPR6PTR low
S7H dc.w      $0138,$0000   ; SPR7PTR high
S7L dc.w      $013a,$0000   ; SPR7PTR low
S8H dc.w      $013c,$0000   ; SPR8PTR high
S8L dc.w      $013e,$0000   ; SPR8PTR low
    
P1H dc.w      $00e0,$0000   ; BPL1PTR high
P1L dc.w      $00e2,$0000   ; BPL1PTR low
P2H dc.w      $00e4,$0000   ; BPL2PTR high
P2L dc.w      $00e6,$0000   ; BPL2PTR low
P3H dc.w      $00e8,$0000   ; BPL3PTR high
P3L dc.w      $00ea,$0000   ; BPL3PTR low
P4H dc.w      $00ec,$0000   ; BPL4PTR high
P4L dc.w      $00ee,$0000   ; BPL4PTR low
P5H dc.w      $00f0,$0000   ; BPL5PTR high
P5L dc.w      $00f2,$0000   ; BPL5PTR low
P6H dc.w      $00f4,$0000   ; BPL6PTR high
P6L dc.w      $00f6,$0000   ; BPL6PTR low
P7H dc.w      $00f8,$0000   ; BPL7PTR high
P7L dc.w      $00fa,$0000   ; BPL7PTR low
P8H dc.w      $00fc,$0000   ; BPL8PTR high
P8L dc.w      $00fe,$0000   ; BPL8PTR low
    
    dc.w      $7001,$fffe,$0180,$0300
    dc.w      $7101,$fffe,$0180,$0600
    dc.w      $7201,$fffe,$0180,$0900
    dc.w      $7301,$fffe,$0180,$0b00
    dc.w      $7401,$fffe,$0180,$0d00
    dc.w      $7501,$fffe,$0180,$0f00
    dc.w      $7a01,$fffe,$0180,$0d00
    dc.w      $7b01,$fffe,$0180,$0b00
    dc.w      $7c01,$fffe,$0180,$0900
    dc.w      $7d01,$fffe,$0180,$0600
    dc.w      $7e01,$fffe,$0180,$0300
    dc.w      $7f01,$fffe,$0180,$0000

    dc.w      $8001,$fffe,$0180,$0333
    dc.w      $8101,$fffe,$0180,$0666
    dc.w      $8201,$fffe,$0180,$0999
    dc.w      $8301,$fffe,$0180,$0bbb
    dc.w      $8401,$fffe,$0180,$0ddd
    dc.w      $8501,$fffe,$0180,$0fff
    dc.w      $8a01,$fffe,$0180,$0ddd
    dc.w      $8b01,$fffe,$0180,$0bbb
    dc.w      $8c01,$fffe,$0180,$0999
    dc.w      $8d01,$fffe,$0180,$0666
    dc.w      $8e01,$fffe,$0180,$0333
    dc.w      $8f01,$fffe,$0180,$0000
    
    dc.w      $9001,$fffe,$0180,$0003
    dc.w      $9101,$fffe,$0180,$0006
    dc.w      $9201,$fffe,$0180,$0009
    dc.w      $9301,$fffe,$0180,$000b
    dc.w      $9401,$fffe,$0180,$000d
    dc.w      $9501,$fffe,$0180,$000f
    dc.w      $9a01,$fffe,$0180,$000d
    dc.w      $9b01,$fffe,$0180,$000b
    dc.w      $9c01,$fffe,$0180,$0009
    dc.w      $9d01,$fffe,$0180,$0006
    dc.w      $9e01,$fffe,$0180,$0003
    dc.w      $9f01,$fffe,$0180,$0000
    
    dc.w      $ffff,$fffe   ; WAIT
    dc.w      $ffff,$fffe   ; WAIT

    EVEN
_USERPLANE1:
    incbin    PLANAR320x256_Bat.raw
    incbin    ApolloTeamRulez_1bit.raw
;   incbin    PLANAR320x256_Bat.raw
    incbin    PLANAR320x256_Bat.raw

    EVEN
_USERPLANE2:
    ds.b      WIDTH*HEIGHT

;==============================================================================
    END
;==============================================================================
