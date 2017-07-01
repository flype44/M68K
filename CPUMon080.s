;==============================================================================
;
; Program:      CPUMon080
; Short:        AC68080 CPU monitor tool.
; Author:       APOLLO-Team, flype
; Type:         util/moni
; Version:      1.0a (Oct. 2016)
; Architecture: m68k-amigaos
; Required:     AmigaOS V36+, 68080 Core 3515+
; Copyright:    Do not distribute until SPECS are done.
; Compiler:     Devpac 3.18
;
;==============================================================================
;
; TODO:
; Toggle Log To File
; Detect and display PAL / NTSC
; Detect and display AmigaVideo P96 Env
; Detect screen depth < 8 bits and use different penlist
; Move to next PublicScreen
; Option: Plain Jauge Bars or with intervals
; Rename ValMHzMax to ValMaxMIPS
; Look at the FIXMEs
;==============================================================================


    MACHINE MC68040


;==============================================================================
; INCLUDES
;==============================================================================


    INCDIR  includes
    INCLUDE dos/dos.i
    INCLUDE dos/dosextens.i
    INCLUDE dos/dos_lib.i
    INCLUDE exec/types.i
    INCLUDE exec/memory.i
    INCLUDE exec/exec_lib.i
    INCLUDE intuition/intuition.i
    INCLUDE intuition/intuition_lib.i
    INCLUDE graphics/gfxbase.i
    INCLUDE graphics/graphics_lib.i
    INCLUDE graphics/text.i
;   INCLUDE workbench/workbench.i
;   INCLUDE workbench/startup.i
    
    INCLUDE SAGAFlash.i


;==============================================================================
; PUBLIC CONSTANTS
;==============================================================================


NULL            EQU 0
FALSE           EQU 0

TICK_PAL        EQU 50             ; Amiga PAL  Ticks per second
TICK_NTSC       EQU 60             ; Amiga NTSC Ticks per second
FREQ_PAL        EQU 7093790        ; Amiga PAL  Clock frequency
FREQ_NTSC       EQU 7159090        ; Amiga NTSC Clock frequency

SPR_CLK         EQU $809           ; Clock-Cycle Counter
SPR_IP1         EQU $80A           ; Instruction-Executed Pipe 1
SPR_IP2         EQU $80B           ; Instruction-Executed Pipe 2
SPR_BPC         EQU $80C           ; Branch-Predict Correct
SPR_BPW         EQU $80D           ; Branch-Predict Wrong
SPR_DCH         EQU $80E           ; Data-Cache Hit
SPR_DCM         EQU $80F           ; Data-Cache Miss
SPR_STR         EQU $00A           ; Stall-Registers
SPR_STC         EQU $00B           ; Stall-Cache
SPR_STH         EQU $00C           ; Stall-Hazard
SPR_STB         EQU $00D           ; Stall-Buffer
SPR_MWR         EQU $00E           ; Memory-Writes


;==============================================================================
; PRIVATE CONSTANTS
;==============================================================================


USE_DIVU100     EQU 1

TX              EQU 20
TY              EQU 7
TH              EQU 10

CX              EQU 68
CY              EQU 7
CH              EQU 10

WND_LEFT        EQU 20
WND_TOP         EQU 30
WND_WIDTH       EQU 250-4
WND_HEIGHT      EQU 318

CHAR_ON         EQU '*'       ; 
CHAR_OFF        EQU '-'       ; 

PCRBIT_ESS      EQU 0         ; PCR ESS Bit
PCRBIT_DFP      EQU 1         ; PCR DFP Bit
PCRLOC_ESS      EQU 11        ; PCR ESS CharIndex in buffer
PCRLOC_DFP      EQU 16        ; PCR DFP CharIndex in buffer

CACRBIT_IC      EQU 31
CACRBIT_DC      EQU 15
CACRLOC_IC      EQU 11
CACRLOC_DC      EQU 16

CTYPE_MHZ       EQU 0
CTYPE_PERCENT   EQU 1
CTYPE_POINT     EQU 2
CTEXT_LENGTH    EQU 9

    RSRESET
C_NEW      rs.l 1             ; New value
C_OLD      rs.l 1             ; Old value
C_VAL      rs.l 1             ; Value
C_VAL1     rs.l 1             ; Value Integer
C_VAL2     rs.l 1             ; Value Fraction
C_PEAK     rs.l 1             ; Peak Jauge
C_VALPEAK  rs.l 1             ; Peak value
C_X        rs.l 1             ; Left
C_Y        rs.l 1             ; Top
C_H        rs.l 1             ; Height
C_PEN      rs.l 1             ; Pen Identifier
C_FMT      rs.l 1             ; Format String
C_TYPE     rs.l 1             ; Format Type (MHZ, PERCENT)
C_MODE     rs.l 1             ; Mode (NORMAL, EXTENDED)
C_TEXT     rs.b CTEXT_LENGTH  ; Format Buffer
C_PAD      rs.b 3             ; Padding
C_SIZEOF   rs.l 0             ; SizeOf

    RSRESET                   ; Structure PenData
PEN_ID     rs.l 1             ; Pen identifier
PEN_R      rs.l 1             ; Red
PEN_G      rs.l 1             ; Green
PEN_B      rs.l 1             ; Blue
PEN_SIZEOF rs.l 0             ; SizeOf


;==============================================================================
; MACROS
;==============================================================================


DRAWCNT MACRO
    lea   \1,a4
    bsr   DrawCounter
    ENDM

MACRO_ITEXT MACRO
    dc.b  \1,1          ; apen, bpen
    dc.b  \2,0          ; drawmode
    dc.w  \3,\4         ; x, y, h
    dc.l  0             ; *textattrs
    dc.l  \5            ; *string
    dc.l  \6            ; *next
    ENDM

MACRO_BORDER MACRO
    dc.w  \1            ; x
    dc.w  \2            ; y
    dc.b  1             ; apen
    dc.b  1             ; bpen
    dc.b  0             ; drawmode
    dc.b  5             ; count
    dc.l  \3            ; *points
    dc.l  \4            ; *next
    ENDM

MACRO_POINT MACRO
    dc.w  \1,\2         ; P1
    dc.w  \1+\3,\2      ; P2
    dc.w  \1+\3,\2+\4   ; P3
    dc.w  \1,\2+\4      ; P4
    dc.w  \1,\2         ; P5
    ENDM

MACRO_COUNTER MACRO
    ds.l 7              ; raws
    dc.l \1,\2,\3       ; x, y, h
    dc.l \5             ; mode
    dc.l \6             ; pen
    dc.l \7             ; format
    dc.l \4             ; type
    ds.b CTEXT_LENGTH   ; buffer
    ds.b 3              ; pad
    ENDM

MACRO_DIVU100 MACRO             ; scrath regs: d1
    IFNE USE_DIVU100
      divu.l  #100,\1           ; divide by 100
    ELSE
      moveq.l #0,d1             ; divide by 100
      mulu.l  #42949673,d1:\1   ; magic constant
      move.l  d1,\1             ; result
    ENDC
    ENDM


;==============================================================================
	SECTION	S_0,CODE
;==============================================================================


MAIN:                                  ; **** ENTRY POINT ****

    ;-----------------------------------
    ; Initialize program
    ;-----------------------------------   

    move.l   #RETURN_FAIL,RC           ; Return Code

.findTask
    suba.l   a1,a1                     ; Find our task
    CALLEXEC FindTask                  ; 
    move.l   d0,MyTask                 ; 
    move.l   d0,a4                     ; 
    tst.l    pr_CLI(a4)                ; 
    bne.b    .openDOS                  ; 
    move.l   #99,RC           ; Return Code

.WBStart
    lea      pr_MsgPort(a4),a0         ; WB Message
    CALLEXEC WaitPort                  ; 
    lea	     pr_MsgPort(a4),a0         ; 
    CALLEXEC GetMsg                    ; 
    move.l   d0,WBStartMsg             ; 
    move.l   #98,RC           ; Return Code

.openDOS
    lea      dos_name,a1               ; Open DOS
    moveq.l  #36,d0                    ; 
    CALLEXEC OpenLibrary               ; 
    tst.l    d0                        ; 
    beq      .exit                     ; 
    move.l   d0,_DOSBase               ; 
    move.l   #97,RC           ; Return Code

.someinits1
    bsr      GetPCR                    ; Get some infos
    bsr      GetCACR                   ; 
    bsr      GetCoreID                 ; 
    bsr      GetBoardID                ; 
    bsr      CalibrateClock            ; Calibrate Clock
    move.l   #00005,ValDivider         ; Precalcs
    move.l   #10000/5,ValDivider10K      ; Precalcs
    move.l   #96,RC           ; Return Code

.openInt
    lea      int_name,a1               ; Open Intuition
    moveq    #36,d0                    ; 
    CALLEXEC OpenLibrary               ; 
    tst.l    d0                        ; 
    beq      .closeDOS                 ; 
    move.l   d0,_IntuitionBase         ; 
    move.l   #95,RC           ; Return Code

.openGfx
    lea      gfx_name,a1               ; Open Graphics
    moveq.l  #36,d0                    ; 
    CALLEXEC OpenLibrary               ; 
    tst.l    d0                        ; 
    beq      .closeInt                 ; 
    move.l   d0,_GfxBase               ; 
    move.l   #94,RC           ; Return Code

.openWin
    lea      MyNewWindow,a0            ; Open New Window
    CALLINT  OpenWindow                ; 
    tst.l    d0                        ; 
    beq      .closeGfx                 ; 
    move.l   d0,MyWindow               ; 
    move.l   #93,RC           ; Return Code

.readWin
    
    move.l   d0,a1                     ; 
    move.b   wd_BorderTop(a1),d0       ; Get BorderTop size
    ext.w    d0                        ;
    add.w    d0,WndFold1
    add.w    d0,WndFold2
    add.w    d0,WndFold3
    add.w    d0,WndFold4
    add.w    d0,WndFold5
    
    move.b   wd_BorderBottom(a1),d0    ; Get BorderTop size
    ext.w    d0                        ;
    add.w    d0,WndFold1
    add.w    d0,WndFold2
    add.w    d0,WndFold3
    add.w    d0,WndFold4
    add.w    d0,WndFold5
    
    move.l   wd_UserPort(a1),MyUserPort ; Get UserPort
    move.l   wd_RPort(a1),MyRastPort   ; Get RastPort
    move.l   wd_WScreen(a1),a1         ; Get ColorMap
    add.l    #sc_ViewPort,a1           ; 
    add.l    #vp_ColorMap,a1           ; 
    move.l   (a1),MyColorMap           ; 

.someinits2
    bsr      LoadPenList               ; Load Pen Elements
   
    move.b   PenBG+3,iTxt23            ; Apply Allocated Pens
    move.b   PenText1+3,iTxt23         ; 
    move.b   PenText1+3,iTxt24         ; 
    move.b   PenText1+3,iTxt25         ; 
    move.b   PenText1+3,iTxt26         ; 
    move.b   PenText1+3,iTxt28         ; 
    
    bsr      InitJauge                 ; 

    lea      iTxt60,a0                 ; Load IntuiText List
    move.l   #16,d7                    ; Number of element
.bg move.b   PenBG+3,it_BackPen(a0)    ; Set BPen
    cmp.b    #3,it_FrontPen(a0)
    bne.s    .bh
    move.b   PenText1+3,it_FrontPen(a0)

.bh     
    add.l    #it_SIZEOF,a0             ; Next element
    dbf      d7,.bg                    ; Continue
    move.l   #92,RC           ; Return Code


    ;-----------------------------------
    ; Prepare the window
    ;-----------------------------------
    
.prepare
    
    move.l   MyRastPort,a1             ; Determine Jauge X
    move.l   #VERSTRING,a0
    move.w   #14,d0
    CALLGRAF TextLength
    move.w   d0,TextWidth
    add.w    #TX,d0
    addq.w   #8,d0
    move.w   d0,JaugeLeft

    move.l   MyRastPort,a1             ; Determine Counter X
    move.l   #VERSTRING,a0
    move.w   #8,d0
    CALLGRAF TextLength
    move.w   JaugeLeft,d1
    add.w    #60,d1
    move.w   d1,JaugeRight
    addq.l   #6,d1
    move.w   d1,CntLeft
    move.w   #60,JaugeWidth

    move.l   MyRastPort,a1             ; Determine Window W
    move.l   #VERSTRING,a0
    move.w   #10,d0
    CALLGRAF TextLength
    move.w   CntLeft,d1
    add.w    d0,d1
    addq.w   #8,d1
    move.w   d1,WndWidth
    
    move.l   MyRastPort,a1             ; Determine Identifier X
    move.l   #VERSTRING,a0
    move.w   #20,d0
    CALLGRAF TextLength
    move.w   WndWidth,d1
    sub.w    d0,d1
    sub.w    #20,d1
    move.w   d1,Ident1Left
    
    move.l   MyRastPort,a1             ; Determine Identifier X
    move.l   #VERSTRING,a0
    move.w   #16,d0
    CALLGRAF TextLength
    move.w   WndWidth,d1
    sub.w    d0,d1
    sub.w    #20,d1
    move.w   d1,Ident2Left
    
    move.l   MyRastPort,a1             ; Determine Identifier X
    move.l   #VERSTRING,a0
    move.w   #16,d0
    CALLGRAF TextLength
    move.w   WndWidth,d1
    sub.w    d0,d1
    sub.w    #20,d1
    move.w   d1,Ident3Left
    
    move.l   MyRastPort,a1             ; Determine Identifier X
    move.l   #VERSTRING,a0
    move.w   #21,d0
    CALLGRAF TextLength
    move.w   WndWidth,d1
    sub.w    d0,d1
    sub.w    #20,d1
    move.w   d1,Ident4Left

    move.l   #2,ValFold                ; 
    move.w   WndFold2,d3               ; Update Window dimensions
    bsr      FoldWindow                ; and redraw all components.
    
    ;-----------------------------------
    ; Main loop
    ;-----------------------------------
    move.l   #91,RC           ; Return Code
    
.doEvents
    bsr      ListenEvents              ; Listen messages until exit
    move.l   #RETURN_OK,RC             ; Return Code

    ;-----------------------------------
    ; Un-initialize program
    ;-----------------------------------
    
.closeWin
    move.l   MyWindow,a0               ; Close Window
    CALLINT  CloseWindow               ; 

.closeFont
    tst.l    MyFont                    ; Close Font
    beq.s    .closeGfx                 ; 
    move.l   MyFont,a1                 ; 
    CALLGRAF CloseFont                 ; 

.closeGfx
    move.l   _GfxBase,a1               ; Close Graphics
    CALLEXEC CloseLibrary              ; 

.closeInt
    move.l   _IntuitionBase,a1         ; Close Intuition
    CALLEXEC CloseLibrary              ; 

.closeDOS
    move.l   _DOSBase,a1               ; Close DOS
    CALLEXEC CloseLibrary              ; 

.closeWB
    move.l   WBStartMsg,d0             ; Close WB
    beq.s    .exit                     ; 
    CALLEXEC Forbid                    ; 
    move.l   WBStartMsg,a1             ; 
    CALLEXEC ReplyMsg                  ; 

    ;-----------------------------------
    ; Exit program
    ;-----------------------------------
    
.exit
    move.l   RC,d0                     ; Return Code
    rts                                ; End of program


;==============================================================================
; void ListEvents( void )
;==============================================================================


ListenEvents:

    movem.l  d0-a6,-(sp)               ; Store registers

    moveq.l  #0,d4                     ; Current Clock
    moveq.l  #0,d5                     ; Message Code
    moveq.l  #0,d6                     ; Message Class
    moveq.l  #0,d7                     ; Is Paused ?

    move.l   ValHz,d3                  ; ( ValHz / ValDivider )
    divu.l   ValDivider,d3             ; 
    
    ;-----------------------------------
    ; Listen and handle Window events
    ;-----------------------------------

.loop
    move.l   MyUserPort,a0             ; GetMsg(msgport)
    CALLEXEC GetMsg                    ; 
    tst.l    d0                        ; No Message ?
    beq.w    .skip                     ; Skip
    move.l   d0,a1                     ; Get Msg
    move.w   im_Code(a1),d5            ; Get Msg->Code
    move.l   im_Class(a1),d6           ; Get Msg->Class
    CALLEXEC ReplyMsg                  ; ReplyMsg(msg)
.close
    cmp.l    #IDCMP_CLOSEWINDOW,d6     ; [CloseWindow]
    beq      .exit                     ; Exit
.buttons
    cmp.l    #IDCMP_MOUSEBUTTONS,d6    ; [MouseButtons]
    bne.s    .resize                   ; Fold Window
.rmb
    cmp.w    #$69,d5                   ; [1] 
    bne.s    .resize                   ; Fold Window
.fold1
    cmp.l    #5,ValFold
    blo.s    .fold2
    move.l   #0,ValFold
.fold2
    add.l    #1,ValFold
    move.l   ValFold,d5
    bra.s    .key_01
.resize
    cmp.l    #IDCMP_NEWSIZE,d6         ; [NewSize]
    bne      .keys                     ; 
    bsr      DrawBackground            ; Draw Background
    bra      .skip                     ; 
.keys
    cmp.l    #IDCMP_RAWKEY,d6          ; [RawKey]
    bne.w    .skip                     ; 
.key_01
    cmp.w    #$01,d5                   ; [1] 
    bne.s    .key_02                   ; Fold Window
    move.l   #0,ValExtended            ; 
    move.l   #1,ValFold                ; 
    move.w   WndFold1,d3               ; 
    bsr      FoldWindow                ; 
    bra      .skip                     ; 
.key_02
    cmp.w    #$02,d5                   ; [2] 
    bne.s    .key_03                   ; Fold Window
    move.l   #0,ValExtended            ; 
    move.l   #2,ValFold                ; 
    move.w   WndFold2,d3               ; 
    bsr      FoldWindow                ; 
    bra      .skip                     ; 
.key_03
    cmp.w    #$03,d5                   ; [3] 
    bne.s    .key_04                   ; Fold Window
    move.l   #1,ValExtended            ; 
    move.l   #3,ValFold                ; 
    move.w   WndFold3,d3               ; 
    bsr      FoldWindow                ; 
    bra      .skip                     ; 
.key_04
    cmp.w    #$04,d5                   ; [4] 
    bne.s    .key_05                   ; Fold Window
    move.l   #1,ValExtended            ; 
    move.l   #4,ValFold                ; 
    move.w   WndFold4,d3               ; 
    bsr      FoldWindow                ; 
    bra      .skip                     ; 
.key_05
    cmp.w    #$05,d5                   ; [5] 
    bne.s    .key_06                   ; Fold Window
    move.l   #1,ValExtended            ; 
    move.l   #5,ValFold                ; 
    move.w   WndFold5,d3               ; 
    bsr      FoldWindow                ; 
    bra      .skip                     ; 
.key_06
    cmp.w    #$06,d5                   ; [6] 
    bne.s    .key_07                   ; Fold Window
    ;move.l   #1,ValExtended            ; 
    ;move.l   #6,ValFold                ; 
    ;move.w   WndFold6,d3               ; 
    ;bsr      FoldWindow                ; 
    bra      .skip                     ; 
.key_07
    cmp.w    #$07,d5                   ; [7] 
    bne.s    .key_10                   ; Fold Window
    ;move.l   #1,ValExtended            ; 
    ;move.l   #7,ValFold                ; 
    ;move.w   WndFold7,d3               ; 
    ;bsr      FoldWindow                ; 
    bra      .skip                     ; 
.key_10
    cmp.w    #$10,d5                   ; [Q] 
    bne.s    .key_11                   ; 
    move.l   ValHz,d3                  ; ( ValHz / ValDivider )
    move.l   #1,ValDivider             ; 
    move.l   #10000,ValDivider10K      ; 
    bsr      UpdateTitle               ; 
    bra      .skip                     ; 
.key_11
    cmp.w    #$11,d5                   ; [W] 
    bne.s    .key_12                   ; 
    move.l   ValHz,d3                  ; ( ValHz / ValDivider )
    divu.l   #2,d3                     ; 
    move.l   #2,ValDivider             ; 
    move.l   #10000/2,ValDivider10K    ; 
    bsr      UpdateTitle               ; 
    bra      .skip                     ; 
.key_12
    cmp.w    #$12,d5                   ; [E] 
    bne.s    .key_13                   ; 
    move.l   ValHz,d3                  ; ( ValHz / ValDivider )
    divu.l   #5,d3                     ; 
    move.l   #5,ValDivider             ; 
    move.l   #10000/5,ValDivider10K    ; 
    bsr      UpdateTitle               ; 
    bra      .skip                     ; 
.key_13
    cmp.w    #$13,d5                   ; [R] 
    bne.s    .key_19                   ; 
    move.l   ValHz,d3                  ; ( ValHz / ValDivider )
    divu.l   #10,d3                    ; 
    move.l   #10,ValDivider            ; 
    move.l   #10000/10,ValDivider10K   ; 
    bsr      UpdateTitle               ; 
    bra      .skip                     ; 
.key_19
    cmp.w    #$19,d5                   ; [P] 
    bne.s    .key_40                   ; Toggle PAUSE
    not.l    d7                        ; 
    move.l   d7,ValPAUSED              ; 
    bsr      UpdateTitle               ; 
    bra      .skip                     ; 
.key_40
    cmp.w    #$40,d5                   ; [SPACE] 
    bne.s    .key_46                   ; 
    nop                                ; 
    nop                                ; 
    bra      .skip                     ; 
.key_46
    cmp.w    #$46,d5                   ; [DEL] 
    bne.s    .key_5F                   ; 
;    lea      ValMIPS,a0                ; 
;    move.l   C_VAL1(a0),ValMHzMax      ; Reset Max MHz
    clr.l    ValMHzMax                 ; 
    clr.l    ValMaxP1                  ; 
    clr.l    ValMaxP2                  ; 
    clr.l    ValMaxIPC                 ; 
    clr.l    ValMaxPIPE                ; 
    bsr      ResetPeaks                ; Reset Peak counters
    bsr      UpdateTitle               ; Update Window title
.key_5F
    cmp.w    #$5F,d5                   ; [RELP] 
    bne.s    .skip                     ;     
    move.l   MyWindow,a0               ; 
    move.l   #MyEasyStruct,a1          ; 
    sub.l    a2,a2                     ; 
    sub.l    a3,a3                     ; 
    CALLINT  EasyRequestArgs           ; 
    
.skip
    move.l   #2,d1                     ; Delay(ticks)
    CALLDOS  Delay                     ; 
    tst.l    d7                        ; Is Paused ?
    bne.w    .loop                     ; Continue

    ;-----------------------------------
    ; Check Clock for interval
    ;-----------------------------------
    
.clock
    dc.w     $4e7a,SPR_CLK             ; MOVEC SPR_CLK,d0
    move.l   d0,d1                     ; 
    sub.l    d4,d1                     ; (Clock-PreviousClock) < (ValHz/ValDivider)
    cmp.l    d3,d1                     ; 
    bls      .loop                     ; Continue
    move.l   d0,d4                     ; PreviousClock = Clock

    ;-----------------------------------
    ; Update and draw counters
    ;-----------------------------------
    
.update
    bsr      GetCounters               ; Get CPU Counters
    bsr      DrawCounters              ; Draw CPU Counters
    bsr      DrawHisto                 ; Draw Histo MIPS
    
    ;-----------------------------------
    ; Continue or Exit
    ;-----------------------------------
    
    bra.w    .loop                     ; Continue    
.exit
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void RawDoFmtCallback( D0:CharCode, A3:*UserData )
;==============================================================================


RawDoFmtCallback:
    move.b   d0,(a3)+                  ; Push character in the buffer
    rts                                ; Return


;==============================================================================
; void DrawHisto( void )
;==============================================================================


DrawHisto:    
    movem.l  d0-a6,-(sp)               ; Store registers
.scroll
    move.l   MyWindow,a1               ; ScrollWindowRaster(rp,dx,dy,...)
    move.w   #1,d0                     ; 
    move.w   #0,d1                     ; 
    move.w   JaugeLeft,d2              ; 
    move.w   #CY+(CH*0)+6,d3           ; 
    move.w   JaugeRight,d4             ; 
    move.w   #CY+(CH*0)+6,d5           ; 
    CALLINT  ScrollWindowRaster        ; 
.getpen
    lea      ValMIPS,a0                ; Draw Colored ###MHz
    lea      PenGradient0,a1           ; 
    move.l   C_VAL1(a0),d0             ; Obtain Color Index
    mulu.l   #9,d0                     ; 
    divu.l   ValMHz,d0                 ; 
    cmp.l    #9-1,d0                   ; 
    bls.s    .plot                     ; 
    move.l   #9-1,d0                   ; 
.plot
    mulu.l   #PEN_SIZEOF,d0            ; Obtain Pen Element
    add.l    d0,a1                     ; 
    move.l   PEN_ID(a1),d0             ; 
    move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    CALLGRAF SetAPen                   ; 
    move.l   d4,d0                     ; Plot pixel
    move.l   d5,d1                     ; 
    CALLGRAF WritePixel                ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void FoldWindow( D3:WindowHeight )
;==============================================================================


FoldWindow:
    movem.l  d0-a6,-(sp)               ; Store registers
    move.l   MyWindow,a0               ; 
    move.w   wd_LeftEdge(a0),d0        ; 
    move.w   wd_TopEdge(a0),d1         ; 
    move.w   WndWidth,d2               ; 
    CALLINT  ChangeWindowBox           ; 
    bsr      UpdateTitle               ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void CalibrateClock( void )
;==============================================================================


CalibrateClock:
    movem.l  d0-a6,-(sp)               ; Store registers
    dc.w     $4e7a,SPR_CLK             ; Get Clock
    move.l   d0,d2                     ; 
    move.l   #TICK_PAL,d1              ; Delay(ticks)
    CALLDOS  Delay                     ; 
    dc.w     $4e7a,SPR_CLK             ; Get Clock
    sub.l    d2,d0                     ; Get Hertz
    move.l   d0,ValHz                  ; 
    move.l   d0,d1                     ; Get MegaHertz
    divu.l   #1000000,d1               ; 
    move.l   d1,ValMHz                 ; 
    move.l   d1,ValMHzMax              ; 
    move.l   d0,d2                     ; Get Multiplier
    divu.l   #FREQ_PAL,d2              ; 
    move.l   d2,ValMult                ; 
    lea      FmtMHz,a0                 ; RawDoFmt(fmt,args,cb,data)
    lea      ValMHz,a1                 ; 
    lea      RawDoFmtCallback,a2       ; 
    lea      MHZ_Buffer,a3             ; 
    CALLEXEC RawDoFmt                  ; 
    lea      FmtMult,a0                ; RawDoFmt(fmt,args,cb,data)
    lea      ValMult,a1                ; 
    lea      RawDoFmtCallback,a2       ; 
    lea      MUL_Buffer,a3             ; 
    CALLEXEC RawDoFmt                  ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void GetCounters( void )
;==============================================================================


GetCounters:

    movem.l  d0-a6,-(sp)               ; Store registers

    ;-----------------------------------
    ; Read CPU Counters (MOVEC SPR,d0)
    ;-----------------------------------

.read1
    dc.w     $4e7a,SPR_IP1             ; MAIN COUNTERS
    move.l   d0,ValIP1                 ; 
    dc.w     $4e7a,SPR_IP2             ; 
    move.l   d0,ValIP2                 ; 
.read2    
    tst.l    ValExtended               ; EXTENDED COUNTERS
    beq.s    .calc                     ; 
    dc.w     $4e7a,SPR_BPC             ; 
    move.l   d0,ValBPC                 ; 
    dc.w     $4e7a,SPR_BPW             ; 
    move.l   d0,ValBPW                 ; 
    dc.w     $4e7a,SPR_DCH             ; 
    move.l   d0,ValDCH                 ; 
    dc.w     $4e7a,SPR_DCM             ; 
    move.l   d0,ValDCM                 ; 
    dc.w     $4e7a,SPR_STR             ; 
    move.l   d0,ValSTR                 ; 
    dc.w     $4e7a,SPR_STC             ; 
    move.l   d0,ValSTC                 ; 
    dc.w     $4e7a,SPR_STH             ; 
    move.l   d0,ValSTH                 ; 
    dc.w     $4e7a,SPR_STB             ; 
    move.l   d0,ValSTB                 ; 
    dc.w     $4e7a,SPR_MWR             ; 
    move.l   d0,ValMWR                 ; 

    ;-----------------------------------
    ; Calculate the difference between
    ; current counters and previous ones
    ;-----------------------------------

.calc

    ;-----------------------------------
    lea      CounterList,a4            ; Load elements
    moveq.l  #2-1,d7                   ; MODE NORMAL
    tst.l    ValExtended               ; 
    beq.s    .l1                       ; 
    moveq.l  #11-1,d7                  ; MODE EXTENDED
    ;-----------------------------------
.l1 move.l   C_NEW(a4),d0              ; D0  = NEW
    move.l   C_OLD(a4),d1              ; D1  = OLD
    move.l   d0,C_OLD(a4)              ; OLD = NEW
    sub.l    d1,d0                     ; NEW - OLD
    divu.l   ValDivider10K,d0          ; 
    move.l   d0,C_VAL(a4)              ; Store 
    moveq.l  #0,d1                     ; 
    divu.l   #100,d1:d0                ; 
    move.l   d0,C_VAL1(a4)             ; 
    move.l   d1,C_VAL2(a4)             ; 
    ;-----------------------------------    

    bra      .l7
.l4 cmp.l    #CTYPE_POINT,C_TYPE(a4)   ; Type POINT
    bne.s    .l5                       ; 
    move.l   C_VAL1(a4),d0             ; 
    moveq.l  #0,d1                     ; 
    divu.l   #100,d1:d0                ; 
    move.l   d0,args+0                 ; 
    move.l   d1,args+4                 ; 
    move.l   #args,a1                  ; 
    bra.s    .l6                       ; 
.l5 move.l   a4,a1                     ; 
    add.l    #C_VAL1,a1                ; 
.l6 lea      C_FMT(a4),a0              ; RawDoFmt(fmt,args,cb,userdata)
    move.l   (a0),a0                   ; 
    lea      RawDoFmtCallback,a2       ; 
    move.l   a4,a3                     ; 
    add.l    #C_TEXT,a3                ; 
    CALLEXEC RawDoFmt                  ; 
    
    ;-----------------------------------
.l7 add.l    #C_SIZEOF,a4              ; Next element
    dbf      d7,.l1                    ; Continue
    ;-----------------------------------

    ;-----------------------------------
    ; Calculate extra informations
    ;-----------------------------------

.extra1a
    lea      ValIP2,a0                 ; ValMIPS
    move.l   C_VAL(a0),d0              ; 
    move.l   d0,d1                     ; ( IP1 + IP2 )
    lea      ValIP1,a0                 ; 
    add.l    C_VAL(a0),d0              ; 
    lea      ValMIPS,a0                ; 
.extra1b
    move.l   d0,d7                     ; 
    moveq.l  #0,d1                     ; 
    divu.l   #100,d1:d0                ; 
    move.l   d0,C_VAL1(a0)             ; 
    move.l   d1,C_VAL2(a0)             ; 

.extra2a
    lea      ValIP2,a0                 ; ValPIPE
    move.l   C_VAL(a0),d0              ; 
    lea      ValIP1,a0                 ; ( Min(P1,P2) * 200 ) / MIPS
    move.l   C_VAL(a0),d1              ; 
    cmp.l    d0,d1                     ; 
    bls.s    .extra2b                  ; 
    move.l   d0,d1                     ; 
.extra2b    
    mulu.l   #200,d1                   ; 
    moveq.l  #0,d2                     ; 
    divu.l   d7,d2:d1                  ; 
    lea      ValPIPE,a0                ; 
    move.l   d1,C_VAL1(a0)             ; 
    MACRO_DIVU100 d2                   ; 
    move.l   d2,C_VAL2(a0)             ; 
    
.extra2c
;    lea      ValMIPS,a0                ; ValMHzMax
;    move.l   C_VAL1(a0),d0             ; 
;    move.l   ValMHzMax,d1              ; 
;    cmp.l    d1,d0                     ; Skip if ( MIPS < MHzMax )
;    blo.s    .extra3                   ; 
    
;    cmp.l    ValMHz,d0                 ; ( MIPS < MHz )
;    bls.s    .extra2d
;    move.l   d0,d2
;    sub.l    d1,d2                     ; Check too large jumps
;    cmp.l    #100,d2                   ; 
;    bhs.s    .extra3                   ; 
;.extra2d
;    move.l   d0,ValMHzMax              ; 
    
.extra3
    move.l   d7,d0                     ; ValIPC
    divu.l   ValMHz,d0                 ; ( MIPS / MHz )
    lea      ValIPC,a0                 ; 
    move.l   d0,C_VAL1(a0)             ; 

    moveq.b  #0,d1
.maxMIPS
    lea      ValMIPS,a0                ; 
    move.l   C_VAL1(a0),d0             ; 
    cmp.l    ValMHzMax,d0              ; 
    blo.s    .maxIP1                   ; 
    move.l   d0,ValMHzMax              ; 
    moveq.b  #1,d1
.maxIP1
    lea      ValIP1,a0                 ; 
    move.l   C_VAL1(a0),d0             ; 
    cmp.l    ValMaxP1,d0               ; 
    blo.s    .maxIP2                   ; 
    move.l   d0,ValMaxP1               ; 
    moveq.b  #1,d1
.maxIP2
    lea      ValIP2,a0                 ; 
    move.l   C_VAL1(a0),d0             ; 
    cmp.l    ValMaxP2,d0               ; 
    blo.s    .maxIPC                   ; 
    move.l   d0,ValMaxP2               ; 
    moveq.b  #1,d1
.maxIPC
    lea      ValIPC,a0                 ; 
    move.l   C_VAL1(a0),d0             ; 
    cmp.l    ValMaxIPC,d0              ; 
    blo.s    .maxPIPE                  ; 
    move.l   d0,ValMaxIPC              ; 
    moveq.b  #1,d1
.maxPIPE
    lea      ValPIPE,a0                ; 
    move.l   C_VAL1(a0),d0             ; 
    cmp.l    ValMaxPIPE,d0             ; 
    blo.s    .maxLAST                  ; 
    move.l   d0,ValMaxPIPE             ; 
    moveq.b  #1,d1
.maxLAST
    tst.b    d1
    beq.s    .maxSKIP
    bsr      UpdateTitle
.maxSKIP
    tst.l    ValExtended               ; MODE EXTENDED
    beq      .exit                     ; 

.extra4
    lea      ValDCM,a0                 ; ValDC Percent
    move.l   C_VAL(a0),d0              ; 
    beq      .extra5                   ; ( DCH * 100 ) / ( DCH + DCM )
    move.l   d0,d1                     ; 
    mulu.l   #100,d0                   ; 
    lea      ValDCH,a0                 ; 
    add.l    C_VAL(a0),d1              ; 
    moveq.l  #0,d2
    divu.l   d1,d2:d0                  ; 
    lea      ValDC,a0                  ; 
    move.l   d0,C_VAL1(a0)             ; 
    MACRO_DIVU100 d2                   ; 
    move.l   d2,C_VAL2(a0)             ; 

.extra5
    lea      ValBPW,a0                 ; ValBP Percent
    move.l   C_VAL(a0),d0              ; 
    beq.s    .extra6                   ; ( BPC * 100 ) / ( BPC + BPW )
    move.l   d0,d1                     ; 
    mulu.l   #100,d0                   ; 
    lea      ValBPC,a0                 ; 
    add.l    C_VAL(a0),d1              ; 
    moveq.l  #0,d2
    divu.l   d1,d2:d0                  ; 
    lea      ValBP,a0                  ; 
    move.l   d0,C_VAL1(a0)             ; 
    MACRO_DIVU100 d2                   ; 
    move.l   d2,C_VAL2(a0)             ; 

.extra6
    lea      ValSTR,a0                 ; ValST
    lea      ValSTC,a1                 ; 
    lea      ValSTH,a2                 ; 
    lea      ValSTB,a3                 ; 
    lea      ValST,a4                  ; 
    move.l   C_VAL(a0),d0              ; 
    add.l    C_VAL(a1),d0              ; 
    add.l    C_VAL(a2),d0              ; 
    add.l    C_VAL(a3),d0              ; 
    moveq.l  #0,d1                     ; 
    divu.l   #100,d1:d0                ; 
    move.l   d0,C_VAL1(a4)             ; 
    move.l   d1,C_VAL2(a4)             ; 

.exit

    ;-----------------------------------
    lea      CounterList,a4            ; Load elements
    moveq.l  #17-1,d7                  ; 
    ;-----------------------------------
.x0 move.l   C_VAL1(a4),d0             ; Clamp value to ###.##
    move.l   C_VAL2(a4),d1             ; 
    cmp.l    #999,d0                   ; 
    bls.s    .x1                       ; 
    move.l   #999,d0                   ; 
.x1 cmp.l    #099,d1                   ; 
    bls.s    .x2                       ; 
    move.l   #099,d1                   ; 
.x2 move.l   d0,C_VAL1(a4)             ; 
    move.l   d1,C_VAL2(a4)             ; 
    ;-----------------------------------
.x3 move.l   a4,a1                     ; 
    add.l    #C_VAL1,a1                ; 
    lea      C_FMT(a4),a0              ; RawDoFmt(fmt,args,cb,userdata)
    move.l   (a0),a0                   ; 
    lea      RawDoFmtCallback,a2       ; 
    move.l   a4,a3                     ; 
    add.l    #C_TEXT,a3                ; 
    CALLEXEC RawDoFmt                  ; 
    ;-----------------------------------
    add.l    #C_SIZEOF,a4              ; Next element
    dbf      d7,.x0                    ; Continue
    ;-----------------------------------

    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void UpdateTitle( void )
;==============================================================================

    
UpdateTitle:
    movem.l  d0-a6,-(sp)               ; Store registers
.format
    move.l   ValMHz,FmtArgs+00         ; MHz
    move.l   ValMult,FmtArgs+04        ; Mult
    move.l   ValMHzMax,FmtArgs+08      ; MHzMax
    move.l   ValMaxP1,FmtArgs+12       ; MIPS P1
    move.l   ValMaxP2,FmtArgs+16       ; MIPS P2
    move.l   ValMaxIPC,FmtArgs+20      ; IPC
    move.l   ValMaxPIPE,FmtArgs+24     ; PIPE
    move.l   ValExtended,FmtArgs+28    ; Mode
    move.l   ValDivider,FmtArgs+32     ; Divider
    lea      FmtScrTitle,a0            ; RawDoFmt(tmplt,args,cb,userdata)
    lea      FmtArgs,a1                ; 
    lea      RawDoFmtCallback,a2       ; 
    lea      TITLE_Buffer,a3           ; 
    CALLEXEC RawDoFmt                  ; 
.apply1
    move.l   MyWindow,a0               ; SetWindowTitles(wnd,wndtitle,scrtitle)
    move.l   #StrTitle,a1              ; 
    move.l   ValPAUSED,d0              ; 
    tst.l    d0                        ; Is Paused ?
    beq.s    .apply2                   ; 
    move.l   #StrPAUSED,a1             ; 
.apply2
    move.l   #TITLE_Buffer,a2          ; 
    CALLINT  SetWindowTitles           ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void LoadPenList( A3:*PenList )
;==============================================================================


LoadPenList:
    movem.l  d0-a6,-(sp)               ; Store registers
    lea      PenList,a3                ; Load Pen Elements
.loop
    cmp.l    #-1,PEN_ID(a3)            ; Last element ?
    beq.s    .exit                     ; Break
    move.l   MyWindow,a1               ; Wnd->Scr->ViewPort->ColorMap
    move.l   wd_WScreen(a1),a1         ; 
    add.l    #sc_ViewPort,a1           ; 
    add.l    #vp_ColorMap,a1           ; 
    move.l   (a1),a0                   ; ObtainBestPen(cm,r,g,b,tags)
    move.l   PEN_R(a3),d1              ; 
    move.l   PEN_G(a3),d2              ; 
    move.l   PEN_B(a3),d3              ; 
    lea      OBPTagList,a1             ; 
    CALLGRAF ObtainBestPenA            ; 
    move.l   d0,PEN_ID(a3)             ; Store Pen 
    add.l    #PEN_SIZEOF,a3            ; Next Element
    bra      .loop                     ; Continue
.exit
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void DrawBackground( void )
;==============================================================================


DrawBackground:
    movem.l  d0-a6,-(sp)               ; Store registers
.fill
    move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    move.l   PenBG,d0                  ; 
    CALLGRAF SetAPen                   ; 
    move.l   PenBG,d0                  ; SetBPen(rp,pen)
    CALLGRAF SetBPen                   ; 
    move.l   #0,d0                     ; RectFill(rp,x1,y1,x2,y2)
    move.l   #0,d1                     ; y1
    move.w   WndWidth,d2               ; x2
    move.l   #WND_HEIGHT,d3            ; y2
    CALLGRAF RectFill                  ; 
.band1
    move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    move.l   #2,d0                     ; 
    CALLGRAF SetAPen                   ; 
    move.l   #0,d0                     ; RectFill(rp,x1,y1,x2,y2)
    move.l   #0,d1                     ; y1
    move.l   #10,d2                    ; x2
    move.l   #WND_HEIGHT,d3            ; y2
    CALLGRAF RectFill                  ; 
.band2
    move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    move.l   #1,d0                     ; 
    CALLGRAF SetAPen                   ; 
    move.l   #0,d0                     ; RectFill(rp,x1,y1,x2,y2)
    move.l   #0,d1                     ; y1
    move.l   #9,d2                     ; x2
    move.l   #WND_HEIGHT,d3            ; y2
    CALLGRAF RectFill                  ; FIXME: Use Draw Line
.logo1
    move.l   MyRastPort,a0             ; rp
    move.l   #3,d0                     ; xstart
    move.l   #4,d1                     ; ystart
    move.l   d0,d2
    move.l   d1,d3
    add.l    #(3-1),d2                 ; xstop
    add.l    #(6*11)-1,d3              ; ystop
    move.l   #chunky1,a2               ; *array
    move.l   #3,d4                     ; bytesperrow
    CALLGRAF WriteChunkyPixels         ; 
.logo2
    move.l   MyRastPort,a0             ; rp
    move.l   #3,d0                     ; xstart
    move.l   MyWindow,a4               ; ystart
    move.w   wd_Height(a4),d1          ; 
    cmp.w    #165,d1                   ; 
    bls.s    .jauges                   ; 
    sub.b    wd_BorderBottom(a4),d2    ; 
    extb.l   d2
    sub.w    d2,d1                     ; 
    sub.w    #(6*9)+15,d1              ; 
    ext.l    d1                        ; 
    move.l   d0,d2                     ; xstop
    move.l   d1,d3                     ; ystop
    add.l    #(3-1),d2                 ; 
    add.l    #(6*9)-1,d3               ; 
    move.l   #chunky2,a2               ; *array
    move.l   #3,d4                     ; bytesperrow
    CALLGRAF WriteChunkyPixels         ; 
.jauges
    lea      CounterList,a4            ; Draw Jauges Background
    move.l   #17-1,d7                  ; Number of Jauges
.j1 move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    move.l   PenJaugeBG,d0             ; 
    CALLGRAF SetAPen                   ; 
    move.w   JaugeLeft,d0              ; RectFill(rp,x1,y1,x2,y2)
    subq.l   #2,d0                     ; 
    move.w   JaugeRight,d2             ; 
    addq.l   #2,d2                     ; 
    move.l   C_Y(a4),d1                ; 
    subq.l   #2,d1                     ; 
    move.l   d1,d3                     ; 
    addq.l   #8,d3                     ; 
    CALLGRAF RectFill                  ; 
    add.l    #C_SIZEOF,a4              ; Next element
    dbf      d7,.j1                    ; Continue
.others
    bsr      DrawTextList              ; Draw Text elements
    bsr      DrawBorderList            ; Draw Border elements
.exit
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void DrawTextList( A3:*TextList )
;==============================================================================


DrawTextList:
    movem.l  d0-a6,-(sp)               ; Store registers
    move.l   MyRastPort,a0             ; PrintIText(*rp,*itext,x,y)
    move.l   #iTxt01,a1                ; 
    move.l   #0,d0                     ; 
    move.l   #0,d1                     ; 
    CALLINT  PrintIText                ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return

DrawBorderList:
    movem.l  d0-a6,-(sp)               ; Store registers
    move.l   MyRastPort,a0             ; DrawBorder(*rp,*borders,x,y)
    move.l   #iBdr01,a1                ; 
    move.l   #0,d0                     ; 
    move.l   #0,d1                     ; 
    CALLINT  DrawBorder                ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return

ResetPeaks:
    movem.l  d0-a6,-(sp)               ; Store registers
    lea      CounterList,a0            ; Load counters
    move.l   #17-1,d0                  ; Number of counters
.l1 clr.l    C_PEAK(a0)                ; Reset Peak (jauge)
    clr.l    C_VALPEAK(a0)             ; Reset Peak (value)
    add.l    #C_SIZEOF,a0              ; Next element
    dbf      d0,.l1                    ; Continue
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void DrawCounters( void )
;==============================================================================


DrawCounters:
    movem.l  d0-a6,-(sp)               ; Store registers
    ;----------------------------------
    lea      CounterList,a4            ; Load counters
    move.l   #17-1,d7                  ; Number of elements
    ;----------------------------------
.jaugeloop
    tst.l    ValExtended               ; Extended mode ?
    bne      .jaugestate1              ; 
    tst.l    C_MODE(a4)                ; Extended element ?
    bne      .jaugenext                ; 
.jaugestate1
    move.l   C_VAL1(a4),d6             ; Calculate Jauge state
    move.l   C_TYPE(a4),d5             ; 
    cmp.l    #CTYPE_MHZ,d5             ; 
    bne.s    .jaugestate2              ; 
    mulu.w   #ChunkyJaugeW,d6          ; 
    divu.l   ValMHz,d6                 ; 
    bra.s    .jaugeleft1               ; 
.jaugestate2
    mulu.w   #ChunkyJaugeW,d6          ; 
    MACRO_DIVU100 d6                   ; 
.jaugeleft1
    move.l   MyRastPort,a0             ; WChunkyPixels(rp,x,y,x,y,*b,bytesperrow)
    move.w   JaugeLeft,d0              ; 
    move.l   d0,d2                     ; 
    cmp.l    #ChunkyJaugeW,d6          ; 
    bls.s    .jaugeleft2               ; 
    move.l   #ChunkyJaugeW,d6          ; 
.jaugeleft2
    add.l    d6,d2                     ; 
    move.l   C_Y(a4),d1                ; 
    move.l   d1,d3                     ; 
    add.l    C_H(a4),d3                ; 
    move.l   #ChunkyJauge,a2           ; 
    move.l   #ChunkyJaugeW,d4          ; 
    CALLGRAF WriteChunkyPixels         ; 
.jaugeright1
    move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    move.l   PenJaugeBG,d0             ; 
    CALLGRAF SetAPen                   ; 
    move.l   d2,d0                     ; RectFill(rp,x1,y1,x2,y2)
    move.w   JaugeRight,d2             ; 
    move.l   C_Y(a4),d1                ; 
    move.l   d1,d3                     ; 
    add.l    C_H(a4),d3                ; 
    CALLGRAF RectFill                  ; 
.jaugepeak1
    move.l   C_PEAK(a4),d3             ; Get Peak value
    cmp.l    d3,d6                     ; 
    bls.s    .jaugepeak2               ; 
    move.l   d6,C_PEAK(a4)             ; 
    move.l   d6,d3                     ; 
.jaugepeak2
    move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    move.l   PenText1,d0               ; 
    CALLGRAF SetAPen                   ; 
    move.w   JaugeLeft,d0              ; Move(rp,x1,y1)
    add.l    d3,d0                     ; 
    move.l   C_Y(a4),d1                ; 
    CALLGRAF Move                      ; 
    add.l    C_H(a4),d1                ; Draw(rp,x,y) 
    CALLGRAF Draw                      ; 
    ;----------------------------------
.jaugenext
    add.l    #C_SIZEOF,a4              ; Next element
    dbf      d7,.jaugeloop             ; Continue
    ;----------------------------------
  IFEQ 1
.colorTxt1
    lea      ValMIPS,a0                ; Draw Colored ###MHz
    lea      PenGradient0,a1           ; 
    move.l   C_VAL1(a0),d0             ; Obtain Color Index
    mulu.l   #10,d0                    ; 
    divu.l   ValMHz,d0                 ; 
    cmp.l    #10-1,d0                  ; 
    bls.s    .colorTxt2                ; 
    move.l   #10-2,d0                  ; 
.colorTxt2
    mulu.l   #PEN_SIZEOF,d0            ; Obtain Pen Element
    add.l    d0,a1                     ; 
    move.l   PEN_ID(a1),d0             ; 
    move.l   MyRastPort,a1             ; SetAPen(rp,pen)
    CALLGRAF SetAPen                   ; 
    move.w   #TX,d0                    ; Move(rp,x,y)
    move.l   #TY+(TH*2)-4,d1           ; 
    CALLGRAF Move                      ; 
    move.l   #MHZ_Buffer,a0            ; Text(rp,string,length)
    move.l   #5,d0                     ; 
    CALLGRAF Text                      ; 
  ENDC
    ;----------------------------------
.text1
    move.l   MyRastPort,a0             ; PrintIText(rp,itext,x,y)
    move.l   #iTxt60,a1                ; 
    move.w   JaugeLeft,d0              ; 
    move.l   #0,d1                     ; 
    CALLINT  PrintIText                ; 
    tst.l    ValExtended               ; Extended Mode ?
    beq      .exit                     ; 
.text2
    move.l   MyRastPort,a0             ; PrintIText(rp,itext,x,y)
    move.l   #iTxt65,a1                ; 
    move.w   JaugeLeft,d0              ; 
    move.l   #0,d1                     ; 
    CALLINT  PrintIText                ; 
    ;----------------------------------
.exit
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void DrawCounter( A4:*Counter )
;==============================================================================

args: ds.l 2

  IFEQ 1

DrawCounter:

    movem.l  d0-a6,-(sp)               ; Store registers

    cmp.l    #CTYPE_POINT,C_TYPE(a4)   ; Type POINT
    bne.s    .k3                       ; 
    move.l   C_VAL1(a4),d0             ; 
    moveq.l  #0,d1                     ; 
    divu.l   #100,d1:d0                ; 
    move.l   d0,args+0                 ; 
    move.l   d1,args+4                 ; 
    move.l   #args,a1                  ; 
    bra.s    .k4                       ; 
.k3 move.l   a4,a1                     ; 
    add.l    #C_VAL1,a1                ; 
.k4 lea      C_FMT(a4),a0              ; RawDoFmt(fmt,args,cb,userdata)
    move.l   (a0),a0                   ; 
    lea      RawDoFmtCallback,a2       ; 
    move.l   a4,a3                     ; 
    add.l    #C_TEXT,a1                ; 
    CALLEXEC RawDoFmt                  ; 
    
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return
  ENDC


;==============================================================================
; void GetBoardID( void )
;==============================================================================


GetBoardID:
    movem.l  d0-a6,-(sp)               ; Store registers
.readuniqueid                          ; Read Serial Number
    bsr      flashuniqueid             ; 64bits (d0 and d1)
.tostring                              ; 
    lea	     BOARD_Buffer+18,a4        ; Convert to String
    clr.l    d7                        ; checksum
    moveq.l  #1,d6                     ; 
.loop2                                 ; 
    move.l   d1,d2                     ; 
    andi.l   #$88888888,d2             ; 
    lsr.l    #3,d2                     ; 
    move.l   d1,d3                     ; 
    andi.l   #$44444444,d3             ; 
    lsr.l    #2,d3                     ; 
    move.l   d1,d4                     ; 
    andi.l   #$22222222,d4             ; 
    lsr.l    #1,d4                     ; 
    or.l     d3,d4                     ; 
    and.l    d2,d4                     ; 
    mulu.l   #7,d4                     ; 
    moveq.l  #3,d5                     ; 
.loop1                                 ; 
    unpk     d1,d3,#$3030              ; 
    unpk     d4,d2,#0                  ; 
    add.w    d3,d2                     ; 
    add.b    d3,d7                     ; checksum
    lsr.w    #8,d3                     ; checksum
    add.b    d3,d7                     ; checksum
    move.w   d2,-(a4)                  ; 
    lsr.l    #8,d1                     ; 
    lsr.l    #8,d4                     ; 
    dbra     d5,.loop1                 ; 
    move.l   d0,d1                     ; 
    dbra     d6,.loop2                 ; 
    and.b    #$0f,d7                   ; checksum
    sub.b    #10,d7                    ; checksum
    sge      d6                        ; checksum
    and.b    #$07,d6                   ; checksum
    add.b    #$3A,d7                   ; checksum
    add.b    d6,d7                     ; checksum
    lea      BOARD_Buffer,a4           ; 
    move.w   #"0x",(a4)                ; 
    move.b   #"-",18(a4)               ; 
    move.b   d7,19(a4)                 ; 
.exit
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void GetCoreID( void )
;==============================================================================


GetCoreID:
    movem.l  d0-a6,-(sp)               ; Store registers
.read
    clr.l    d5                        ; Read Revision
    moveq.l  #31,d6                    ; 
    lea	     CORE1_Buffer,a3           ; 
.loop
    move.l   a3,a2                     ; 
    move.l   d5,d1                     ; 
    move.l   #256,d3                   ; 
    bsr	     flashread                 ; 
    addi.l   #65536,d5                 ; 
    cmpi.l   #VAMPIRE_MAGIC,(a3)       ; 
    dbeq     d6,.loop                  ; 
.exit
    move.b   #NULL,CORE1_Buffer+16     ; Define end of substring #1
    move.b   #NULL,CORE2_Buffer+32     ; Define end of substring #2
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void GetPCR( void )
;==============================================================================


GetPCR:
    movem.l  d0-a6,-(sp)               ; Store registers
    dc.w     $4e7a,$0808               ; MOVEC PCR,d0
    move.l   d0,ValPCR                 ; Store PCR
    lea      PCR_Buffer,a0             ; 
    move.b   #CHAR_OFF,PCRLOC_ESS(a0)  ; 
    move.b   #CHAR_OFF,PCRLOC_DFP(a0)  ; 
.l1 btst.l   #PCRBIT_ESS,d0            ; Check ESS Bit
    beq.s    .l2                       ; 
    move.b   #CHAR_ON,PCRLOC_ESS(a0)   ; 
.l2 btst.l   #PCRBIT_DFP,d0            ; Check DFP Bit
    beq.s    .l3                       ; 
    move.b   #CHAR_ON,PCRLOC_DFP(a0)   ; 
.l3 lea      FmtPCR,a0                 ; RawDoFmt(tmplt,args,cb,userdata)
    lea      ValPCR,a1                 ; 
    lea      RawDoFmtCallback,a2       ; 
    lea      PCR_Buffer,a3             ; 
    CALLEXEC RawDoFmt                  ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; void GetCACR( void )
;==============================================================================


GetCACR:
    movem.l  d0-a6,-(sp)               ; Store registers
    dc.w     $4e7a,$1002               ; MOVEC CACR,d0
    move.l   d1,ValCACR                ; Store CACR
    lea      CACR_Buffer,a0            ; 
    move.b   #CHAR_OFF,CACRLOC_IC(a0)  ; 
    move.b   #CHAR_OFF,CACRLOC_DC(a0)  ; 
.l1 btst.l   #CACRBIT_IC,d0            ; Check ICache Bit
    beq.s    .l2                       ; 
    move.b   #CHAR_ON,CACRLOC_IC(a0)   ; 
.l2 btst.l   #CACRBIT_DC,d0            ; Check DCache Bit
    beq.s    .l3                       ; 
    move.b   #CHAR_ON,CACRLOC_DC(a0)   ; 
.l3 lea      FmtCACR,a0                ; RawDoFmt(tmplt,args,cb,userdata)
    lea      ValCACR,a1                ; 
    lea      RawDoFmtCallback,a2       ; 
    lea      CACR_Buffer,a3            ; 
    CALLEXEC RawDoFmt                  ; 
    movem.l  (sp)+,d0-a6               ; Restore registers
    rts                                ; Return


;==============================================================================
; INCLUDES
;==============================================================================


    EVEN
    INCLUDE SAGAFlash.s

    EVEN
    INCLUDE ChunkyLogo.s

    EVEN
    INCLUDE ChunkyJauge.s


;==============================================================================
    SECTION S_1,DATA
;==============================================================================


OBPTagList	dc.l OBP_Precision,PRECISION_EXACT
		dc.l OBP_FailIfBad,FALSE
		dc.l TAG_DONE

;==============================================================================

MyEasyStruct	dc.l es_SIZEOF  ; SizeOf
		dc.l NULL       ; Flags
		dc.l StrAbout   ; *Title
		dc.l StrHelp    ; *TextFormat
		dc.l StrOK      ; *GadgetFormat

;==============================================================================

MyNewWindow	dc.w WND_LEFT          ; nw_LeftEdge
		dc.w WND_TOP           ; nw_TopEdge
		dc.w WND_WIDTH         ; nw_Width
		dc.w 50                ; nw_Height
		dc.b 0                 ; nw_DetailPen
		dc.b 1                 ; nw_BlockPen
		dc.l IDCMP_CLOSEWINDOW!IDCMP_NEWSIZE!IDCMP_RAWKEY
;		dc.l $0000060A         ; nw_IDCMPFlags
					; IDCMP_CLOSEWINDOW
					; IDCMP_RAWKEY
					; IDCMP_NEWSIZE
					; IDCMP_MOUSEBUTTONS
		dc.l WFLG_CLOSEGADGET!WFLG_DEPTHGADGET!WFLG_DRAGBAR!WFLG_GIMMEZEROZERO!WFLG_RMBTRAP
;		dc.l $00031400!2!4!8    ; nw_Flags
					; WFLG_ACTIVATE
					; WFLG_SIZEGADGET    $00000001
					; WFLG_DRAGBAR       $00000002
					; WFLG_DEPTHGADGET   $00000004
					; WFLG_CLOSEGADGET   $00000008
					; WFLG_SIZEBBOTTOM   $00000020
					; WFLG_NOCAREREFRESH
					; WFLG_SMART_REFRESH
					; WFLG_GIMMEZEROZERO
					; WFLG_RMBTRAP
		dc.l NULL              ; nw_FirstGadget
		dc.l FALSE             ; nw_CheckMark
		dc.l StrTitle          ; nw_Title
		dc.l NULL              ; nw_Screen
		dc.l NULL              ; nw_BitMap
		dc.w WND_WIDTH         ; nw_MinWidth
		dc.w 50                ; nw_MinHeight
		dc.w WND_WIDTH         ; nw_MaxWidth
		dc.w 0                 ; nw_MaxHeight
		dc.w PUBLICSCREEN      ; nw_Type

;==============================================================================


iBdr1   	;             X,Y,PT,   *NEXT
iBdr01		MACRO_BORDER  0,0,iPt01,iBdr02
iBdr02		MACRO_BORDER  0,0,iPt02,iBdr03
iBdr03		MACRO_BORDER  0,0,iPt03,iBdr04
iBdr04		MACRO_BORDER  0,0,iPt04,iBdr05
iBdr05		MACRO_BORDER  0,0,iPt05,iBdr06
iBdr06		MACRO_BORDER  0,0,iPt06,iBdr07
iBdr07		MACRO_BORDER  0,0,iPt07,NULL

                ;           X  Y   W            H
iPt01		MACRO_POINT 15,002,WND_WIDTH-28,36
iPt02		MACRO_POINT 15,042,WND_WIDTH-28,26
iPt03		MACRO_POINT 15,072,WND_WIDTH-28,46
iPt04		MACRO_POINT 15,122,WND_WIDTH-28,36
iPt05		MACRO_POINT 15,162,WND_WIDTH-28,56
iPt06		MACRO_POINT 15,222,WND_WIDTH-28,36
iPt07		MACRO_POINT 15,262,WND_WIDTH-28,26


;==============================================================================

iTxt01		;         PEN M X  Y          *TEXT   *NEXT
iTxt02		MACRO_ITEXT 2,0,TX,TY+(TH*00),StrMIPS,iTxt03
iTxt03		MACRO_ITEXT 3,0,TX,TY+(TH*01),StrIP1,iTxt04
iTxt04		MACRO_ITEXT 3,0,TX,TY+(TH*02),StrIP2,iTxt05
iTxt05		MACRO_ITEXT 2,0,TX,TY+(TH*04),StrIPC,iTxt06
iTxt06		MACRO_ITEXT 2,0,TX,TY+(TH*05),StrPIPE,iTxt07
iTxt07		MACRO_ITEXT 3,0,TX,TY+(TH*07),StrDCH,iTxt08
iTxt08		MACRO_ITEXT 3,0,TX,TY+(TH*08),StrDCM,iTxt09
iTxt09		MACRO_ITEXT 3,0,TX,TY+(TH*09),StrMW,iTxt10
iTxt10		MACRO_ITEXT 2,0,TX,TY+(TH*10),StrDC,iTxt11
iTxt11		MACRO_ITEXT 3,0,TX,TY+(TH*12),StrBPC,iTxt12
iTxt12		MACRO_ITEXT 3,0,TX,TY+(TH*13),StrBPW,iTxt13
iTxt13		MACRO_ITEXT 2,0,TX,TY+(TH*14),StrBP,iTxt14
iTxt14		MACRO_ITEXT 3,0,TX,TY+(TH*16),StrSTR,iTxt15
iTxt15		MACRO_ITEXT 3,0,TX,TY+(TH*17),StrSTC,iTxt16
iTxt16		MACRO_ITEXT 3,0,TX,TY+(TH*18),StrSTH,iTxt17
iTxt17		MACRO_ITEXT 3,0,TX,TY+(TH*19),StrSTB,iTxt18
iTxt18		MACRO_ITEXT 2,0,TX,TY+(TH*20),StrST,iTxt19
iTxt19		MACRO_ITEXT 3,0,TX,TY+(TH*24),StrBOARDID,iTxt20
iTxt20		MACRO_ITEXT 3,0,TX,TY+(TH*22),StrCACR,iTxt21
iTxt21		MACRO_ITEXT 3,0,TX,TY+(TH*23),StrPCR,iTxt22
iTxt22		MACRO_ITEXT 3,0,TX+00,TY+(TH*01),MHZ_Buffer,iTxt23
iTxt23		MACRO_ITEXT 3,0,TX+00,TY+(TH*02),MUL_Buffer,iTxt24
iTxt24		MACRO_ITEXT 3,0,TX+89,TY+(TH*24),BOARD_Buffer,iTxt25
iTxt25		MACRO_ITEXT 3,0,TX+89,TY+(TH*22),CACR_Buffer,iTxt26
iTxt26		MACRO_ITEXT 3,0,TX+89,TY+(TH*23),PCR_Buffer,iTxt27
iTxt27		MACRO_ITEXT 2,0,TX+00,TY+(TH*26),CORE1_Buffer,iTxt28
iTxt28		MACRO_ITEXT 3,0,TX+00,TY+(TH*27),CORE2_Buffer,NULL

iTxt60		MACRO_ITEXT 2,1,CX,CY+(CH*00),ValMIPS+C_TEXT,iTxt61
iTxt61		MACRO_ITEXT 3,1,CX,CY+(CH*01),ValIP1+C_TEXT,iTxt62
iTxt62		MACRO_ITEXT 3,1,CX,CY+(CH*02),ValIP2+C_TEXT,iTxt63
iTxt63		MACRO_ITEXT 2,1,CX,CY+(CH*04),ValIPC+C_TEXT,iTxt64
iTxt64		MACRO_ITEXT 3,1,CX,CY+(CH*05),ValPIPE+C_TEXT,NULL

iTxt65		MACRO_ITEXT 3,1,CX,CY+(CH*07),ValDCH+C_TEXT,iTxt66
iTxt66		MACRO_ITEXT 3,1,CX,CY+(CH*08),ValDCM+C_TEXT,iTxt67
iTxt67		MACRO_ITEXT 3,1,CX,CY+(CH*09),ValMWR+C_TEXT,iTxt68
iTxt68		MACRO_ITEXT 2,1,CX,CY+(CH*10),ValDC+C_TEXT,iTxt69
iTxt69		MACRO_ITEXT 3,1,CX,CY+(CH*12),ValBPC+C_TEXT,iTxt70
iTxt70		MACRO_ITEXT 3,1,CX,CY+(CH*13),ValBPW+C_TEXT,iTxt71
iTxt71		MACRO_ITEXT 2,1,CX,CY+(CH*14),ValBP+C_TEXT,iTxt72
iTxt72		MACRO_ITEXT 3,1,CX,CY+(CH*16),ValSTR+C_TEXT,iTxt73
iTxt73		MACRO_ITEXT 3,1,CX,CY+(CH*17),ValSTC+C_TEXT,iTxt74
iTxt74		MACRO_ITEXT 3,1,CX,CY+(CH*18),ValSTH+C_TEXT,iTxt75
iTxt75		MACRO_ITEXT 3,1,CX,CY+(CH*19),ValSTB+C_TEXT,iTxt76
iTxt76		MACRO_ITEXT 2,1,CX,CY+(CH*20),ValST+C_TEXT,NULL

;==============================================================================

CounterList

ValIP1		MACRO_COUNTER CX,1+CY+(CH*01),4,0,PenText1,FmtMega,CTYPE_MHZ
ValIP2		MACRO_COUNTER CX,1+CY+(CH*02),4,0,PenText1,FmtMega,CTYPE_MHZ
ValDCH		MACRO_COUNTER CX,1+CY+(CH*07),4,1,PenText1,FmtMega,CTYPE_MHZ
ValDCM		MACRO_COUNTER CX,1+CY+(CH*08),4,1,PenText1,FmtMega,CTYPE_MHZ
ValMWR		MACRO_COUNTER CX,1+CY+(CH*09),4,1,PenText1,FmtMega,CTYPE_MHZ
ValBPC		MACRO_COUNTER CX,1+CY+(CH*12),4,1,PenText1,FmtMega,CTYPE_MHZ
ValBPW		MACRO_COUNTER CX,1+CY+(CH*13),4,1,PenText1,FmtMega,CTYPE_MHZ
ValSTR		MACRO_COUNTER CX,1+CY+(CH*16),4,1,PenText1,FmtMega,CTYPE_MHZ
ValSTC		MACRO_COUNTER CX,1+CY+(CH*17),4,1,PenText1,FmtMega,CTYPE_MHZ
ValSTH		MACRO_COUNTER CX,1+CY+(CH*18),4,1,PenText1,FmtMega,CTYPE_MHZ
ValSTB		MACRO_COUNTER CX,1+CY+(CH*19),4,1,PenText1,FmtMega,CTYPE_MHZ

ValMIPS		MACRO_COUNTER CX,1+CY+(CH*00),3,0,PenText2,FmtMega,CTYPE_MHZ
ValPIPE		MACRO_COUNTER CX,1+CY+(CH*05),4,0,PenText1,FmtPercent,CTYPE_PERCENT
ValIPC		MACRO_COUNTER CX,1+CY+(CH*04),4,0,PenText2,FmtPoint,CTYPE_POINT
ValDC		MACRO_COUNTER CX,1+CY+(CH*10),4,1,PenText2,FmtPercent,CTYPE_PERCENT
ValBP		MACRO_COUNTER CX,1+CY+(CH*14),4,1,PenText2,FmtPercent,CTYPE_PERCENT
ValST		MACRO_COUNTER CX,1+CY+(CH*20),4,1,PenText2,FmtMega,CTYPE_MHZ

		dc.l -1

;==============================================================================

PenJaugeBG	dc.l 1 ; black
PenBox		dc.l 1 ; black
PenText2	dc.l 2 ; blue
PenLabel1	dc.l 3 ; blue
PenLabel2	dc.l 2 ; white

;PenJaugeBG	dc.l 1 ; black
;PenBox		dc.l 1 ; black
;PenText2	dc.l 2 ; blue
;PenLabel1	dc.l 3 ; blue
;PenLabel2	dc.l 2 ; white

PenList		;    Pen  Red       Green     Blue
PenBG		dc.l NULL,$11111111,$11111111,$22222222
PenText1	dc.l NULL,$cccccccc,$00000000,$44444444
PenGradient0	dc.l NULL,$00000000,$55555555,$00000000
PenGradient1	dc.l NULL,$00000000,$aaaaaaaa,$00000000
PenGradient2	dc.l NULL,$55555555,$ffffffff,$00000000
PenGradient3	dc.l NULL,$aaaaaaaa,$ffffffff,$00000000
PenGradient4	dc.l NULL,$ffffffff,$ffffffff,$88888888
PenGradient5	dc.l NULL,$ffffffff,$ffffffff,$00000000
PenGradient6	dc.l NULL,$ffffffff,$aaaaaaaa,$00000000
PenGradient7	dc.l NULL,$ffffffff,$55555555,$00000000
PenGradient8	dc.l NULL,$aaaaaaaa,$00000000,$00000000
PenGradient9	dc.l NULL,$55555555,$00000000,$00000000
		dc.l -1

;==============================================================================


WndFold1	dc.w 42
WndFold2	dc.w 72
WndFold3	dc.w 222
WndFold4	dc.w 262
WndFold5	dc.w 292


;==============================================================================
    SECTION S_2,DATA
;==============================================================================


dos_name	DOSNAME
int_name	INTNAME
tim_name	TIMERNAME
gfx_name	GRAPHICSNAME

FmtArgs		ds.b 256

FmtScrTitle	dc.b "CPU: AC68080 @ %luMHz (x%lu)   MIPS: %lu   P1: %lu   P2: %lu   IPC: %lu   SS: %lu%%   Mode: %lu   Refresh: x%lu",0
FmtMHz		dc.b "%luMHz",0
FmtMult		dc.b "x%llu",0
FmtPCR		dc.b "0x%08lx +DFP +ESS",0
FmtCACR		dc.b "0x%08lx +ICC +DCC",0
FmtMega		dc.b "%3lu.%02lu M",0
FmtPoint	dc.b "%3lu.%02lu i",0
FmtPercent	dc.b "%3lu.%02lu %%",0

StrAbout	dc.b "About",0
StrTitle	dc.b "CPU Monitor",0
StrOK		dc.b "  OK  ",0
StrPAUSED	dc.b "- Paused -",0
StrMIPS		dc.b "AC68080 MIPS  ",0
StrIP1		dc.b "        Pipe 1",0
StrIP2		dc.b "        Pipe 2",0
StrIPC		dc.b "Instr. Clock",0
StrPIPE		dc.b "Super Scalar",0
StrDCH		dc.b "Mem-Read Hit",0
StrDCM		dc.b "Mem-Read Miss",0
StrMW		dc.b "Mem-Write",0
StrDC		dc.b "Misses %",0
StrBPC		dc.b "Branch Correct",0
StrBPW		dc.b "Branch Wrong",0
StrBP		dc.b "Wrongs %",0
StrSTR		dc.b "Stall-Register",0
StrSTC		dc.b "Stall-Cache",0
StrSTH		dc.b "Stall-Hazard",0
StrSTB		dc.b "Stall-Buffer",0
StrST		dc.b "Total",0
StrCACR		dc.b "CPU CACR",0
StrPCR		dc.b "CPU  PCR",0
StrBOARDID	dc.b "Board ID",0

StrHelp		dc.b "CPUMon080 v0.1e (November 2016)",10
		dc.b 10
		dc.b "Monitor tool for the M68K AC68080 CPU.",10
		dc.b 10
		dc.b "Keys:",10
		dc.b "HLP .... Open Help window",10
		dc.b "DEL .... Reset Peak values",10
		dc.b "S ...... Change Refresh Speed",10
		dc.b "P ...... Toggle Pause/Unpaused",10
		dc.b "R ...... Toggle Record to file",10
		dc.b "UP ..... Fold Window",10
		dc.b "DOWN ... Unfold Window",10
		dc.b "RMB .... Fold/Unfold Window",10
		dc.b 10
		dc.b "Contact: flype44gmail.com",10
		dc.b "Provided by the APOLLO-TEAM.",10
		dc.b 0

VERSTRING	dc.b "$VER: CPUMon080 1.0e (22.11.2016) APOLLO-Team",10,0,0


;==============================================================================
    SECTION S_3,BSS
;==============================================================================


_DOSBase	ds.l 1       ; DOS Base
_GfxBase	ds.l 1       ; Graphics Base
_IntuitionBase	ds.l 1       ; Intuition Base

RC		ds.l 1       ; Return Code

MyTask		ds.l 1       ; Task
MyFont		ds.l 1       ; Font
MyWindow	ds.l 1       ; Window
MyUserPort	ds.l 1       ; Window->UserPort
MyRastPort	ds.l 1       ; Window->RastPort
MyColorMap	ds.l 1       ; Window->Screen->ViewPort->ColorMap
WBStartMsg	ds.l 1       ; WBStartup Message

WndWidth	ds.l 1
TextWidth	ds.l 1 
CntLeft		ds.l 1
JaugeLeft	ds.l 1
JaugeRight	ds.l 1
JaugeWidth	ds.l 1
Ident1Left	ds.l 1
Ident2Left	ds.l 1
Ident3Left	ds.l 1
Ident4Left	ds.l 1

TitleArgs
ValMHz		ds.l 1       ; MegaHertz per second     (eg. 70 MHz)
ValMult		ds.l 1       ; Core Multiplier          (eg. x10)
ValMHzMax	ds.l 1       ; Max MegaHertz per second (eg. 70 MHz * 1.n)
ValDivider	ds.l 1       ; 
ValHz		ds.l 1       ; Hertz per second         (eg. 70 000 000 Hz)
ValPCR		ds.l 1       ; CPUID value (PCR)
ValCACR		ds.l 1       ; CACHE value (CACR)
ValDivider10K	ds.l 1       ; 
ValExtended     ds.l 1       ; 
ValPAUSED	ds.l 1       ; 
ValFold		ds.l 1       ; 

ValMaxP1	ds.l 1       ; 
ValMaxP2	ds.l 1       ; 
ValMaxIPC	ds.l 1       ; 
ValMaxPIPE	ds.l 1       ; 

MUL_Buffer	ds.b 8       ; "x000"
MHZ_Buffer	ds.b 12      ; "0000MHz"
PCR_Buffer	ds.b 24      ; "0x00000000 -DFP -ESS"
CACR_Buffer	ds.b 24      ; "0x00000000 -ICC -DCC"
BOARD_Buffer	ds.b 24      ; "0x0000000000000000-0"
CORE1_Buffer	ds.b 17      ; "Vampire V600-128"
CORE2_Buffer	ds.b 256-17  ; "3564 x13 c7gk (gold2)"
TITLE_Buffer	ds.b 256     ; ""


;==============================================================================
