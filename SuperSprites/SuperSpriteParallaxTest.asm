***********************************************************
* 
* File:     SAGA SuperSprite Tests
* Author:   Flype, Apollo-Team 2016-2019
* Version:  0.1 (2019-07-06)
* Compiler: Devpac or vasmm68k_mot_os3
* 
***********************************************************

		INCLUDE	exec/memory.i
		INCLUDE	exec/exec_lib.i
		INCLUDE hardware/intbits.i
		INCLUDE	graphics/graphics_lib.i

***********************************************************

SCRW    EQU 640
SCRH    EQU 256
SCRD    EQU 8

***********************************************************

POKEPTR MACRO
		move.w   \1,6(\2)
		swap     \1
		move.w   \1,2(\2)
		swap     \1
		ENDM

***********************************************************
** 
** ENTRY POINT
** 
***********************************************************

		SECTION	S0,CODE
		
MAIN:

.OpenGfx
		lea      GfxName(pc),a1           ; Open Graphics
		move.l   #39,d0                   ; 
		CALLEXEC OpenLibrary              ; 
		move.l   d0,_GfxBase              ; Store result
		tst.l    d0                       ; 
		beq      .Exit                    ; Exit on error
		
.GetCopList
		move.l   4.w,a6                   ; Get CopperList
		move.l   156(a6),a1               ; 
		move.l   38(a1),OldCopper         ; 
		
.SetPlanes
		lea      CopListBPLxPTR,a0        ; Load CopList
		move.l   #ScreenData1,d0          ; Load Screen Data
		move.w   #8-1,d7                  ; Loop Count
.SetPlanesLoop
		POKEPTR  d0,a0                    ; BPLxPTR
		add.l    #(SCRW*SCRH)/SCRD,d0     ; Next Plane
		adda.l   #(4+4),a0                ; Next CopList->BPLxPTR
		dbf      d7,.SetPlanesLoop        ; Continue
		
.SetSprites
		lea      SpriteList(pc),a0        ; Load Sprites pointers
		lea      CopListSPRxPTR,a1        ; Load CopList->SPRxPTR
		moveq.l  #8-1,d0                  ; Sprite Count
.SetSpritesLoop
		move.l   (a0)+,d1                 ; Sprite Address
		POKEPTR  d1,a1                    ; Poke CopList->SPRxPTR
		adda.l   #8,a1                    ; Next CopList->SPRxPTR
		dbf      d0,.SetSpritesLoop       ; Continue

.AddInterrupt
		CALLEXEC Forbid                   ; Multitask OFF
		moveq.l  #INTB_VERTB,d0           ; Interrupt Number
		lea      VBLInterruptStruct,a1    ; Interrupt Struct
		CALLEXEC AddIntServer             ; AddIntServer(num, interrupt)
		
.SetCopList
		move.l   #CopListSTART,$dff080    ; COP1LCH/COP1LCL
		move.w   #0,$dff088               ; COPJMP1

.MainLoop
		CALLGRAF WaitTOF                  ; Wait
		bsr      IsPaused                 ; Pause
		btst.b   #6,$bfe001               ; CIAAPRA -> FIR0
		bne.s    .MainLoop                ; Continue
		
.PopCopList
		move.l   OldCopper(pc),$dff080    ; COP1LCH/COP1LCL
		move.l   #0,$dff088               ; COPJMP1
		
.RemoveInterrupt
		moveq.l  #INTB_VERTB,d0           ; Interrupt Number
		lea      VBLInterruptStruct,a1    ; Interrupt Struct
		CALLEXEC RemIntServer             ; RemIntServer(num, interrupt)
		CALLEXEC Permit                   ; Multitask ON
		
.CloseGfx
		move.l   _GfxBase,a1              ; Close Graphics
		CALLEXEC CloseLibrary             ; 
		
.Exit
		moveq.l  #0,d0                    ; Return Code
		rts                               ; Exit program

IsPaused:
		move.l   #1,_Paused               ; Paused
		btst.b   #7,$bfe001               ; CIAAPRA -> FIR0
		beq.s    IsPaused                 ; Continue
		move.l   #0,_Paused               ; Pause OFF
		rts

***********************************************************
** 
** VERTICAL BLANK INTERRUPT CODE
** 
***********************************************************

VBLInterruptCode:
		
		tst.l    _Paused                  ; Is paused ?
		bne.s    .Exit                    ; Exit VBL code
		movem.l  d0-a6,-(sp)              ; Push
		
		;--------------------------------------------------
		; Update Parallax
		;--------------------------------------------------
.parallax
		lea      SpriteList1,a1           ; Load list
.parallaxLoop
		move.l   (a1)+,a0                 ; Sprite header
		tst.l    a0                       ; Last item ?
		beq.s    .parallaxDone            ; All done
		move.l   (a1)+,d2                 ; Speed
		bsr      SpritePositionDec64      ; Update position
		bra.s    .parallaxLoop            ; Continue
.parallaxDone
		
		;--------------------------------------------------
		; Update Sprites
		;--------------------------------------------------
.sprite
		lea      SpriteList2,a1           ; Load list
.spriteLoop
		move.l   (a1)+,a0                 ; Sprite header
		tst.l    a0                       ; Last item ?
		beq.s    .spriteDone              ; All done
		move.l   (a1)+,d2                 ; Speed
		moveq.l  #120,d3                  ; Left
		moveq.l  #200,d4                  ; Right
		bsr      SpritePositionInc64      ; Update position
		bra.s    .spriteLoop              ; Continue
.spriteDone

		;--------------------------------------------------
		; Update palette
		;--------------------------------------------------
.palette
		lea      .paletteTimer(pc),a0
		subq.l   #1,(a0)
		bne.s    .paletteDone
		move.l   #3,(a0)
		
		lea      CopListMidGradient,a0
		moveq.l  #8-1,d0
		moveq.l  #0,d1
.paletteLoop
		move.w   6(a0),d1
		sub.w    #$0001,d1
		and.w    #$000f,d1
		move.w   d1,6(a0)
		adda.l   #8,a0
		dbf      d0,.paletteLoop
.paletteDone
		
		movem.l  (sp)+,d0-a6              ; Pop
.Exit
		moveq.l  #0,d0                    ; Return code
		rts                               ; Return

.paletteTimer:
		DC.L     1
		
***********************************************************
** 
** HELPER ROUTINES
** 
***********************************************************

SpritePositionDec64:
		
		;--------------------------------------------------
		; Update the given 64-bits Sprite Header.
		; 
		; SPRxCTL Bit 0      (H0)
		; SPRxPOS Bit 0 to 7 (H1 to H8)
		;--------------------------------------------------
		
		bfextu   0(a0){08:08},d0          ; 00000000 11111111
		bfextu   8(a0){15:01},d1          ; 00000000 00000001
		lsl.w    #1,d0                    ; 00000001 11111110
		or.w     d0,d1                    ; 00000001 11111111
		
		cmpi.l   #64,d1                   ; If X > 64
		bhi.s    .scroll                  ; Then Do Scroll
		move.l   #128,d1                  ; Else X = 128
.scroll
		sub.w    d2,d1                    ; X - Speed
		move.w   d1,d0                    ; 00000001 11111111
		andi.w   #1,d1                    ; 00000000 00000001
		lsr.w    #1,d0                    ; 00000000 11111111
		bfins    d1,8(a0){15:01}          ; -------- 11111111
		bfins    d0,0(a0){08:08}          ; -------- -------1
		
		rts
		
***********************************************************

SpritePositionInc64:
		
		;--------------------------------------------------
		; Update the given 64-bits Sprite Header.
		; 
		; SPRxCTL Bit 0      (H0)
		; SPRxPOS Bit 0 to 7 (H1 to H8)
		;--------------------------------------------------
		
		bfextu   0(a0){08:08},d0          ; 00000000 11111111
		bfextu   8(a0){15:01},d1          ; 00000000 00000001
		lsl.w    #1,d0                    ; 00000001 11111110
		or.w     d0,d1                    ; 00000001 11111111
		
		cmp.w    d4,d1                    ; If X < D4
		blo.s    .scroll                  ; Then Do Scroll
		move.w   d3,d1                    ; Else X = D3
.scroll
		add.w    d2,d1                    ; X - Speed
		move.w   d1,d0                    ; 00000001 11111111
		andi.w   #1,d1                    ; 00000000 00000001
		lsr.w    #1,d0                    ; 00000000 11111111
		bfins    d1,8(a0){15:01}          ; -------- 11111111
		bfins    d0,0(a0){08:08}          ; -------- -------1
		
		rts
		
***********************************************************
** 
** PROGRAM DATA
** 
***********************************************************

_GfxBase:	 DS.L	1
_Paused:     DS.L	1
OldCopper:   DS.L	1
VBLCounter:  DC.W	0
GfxName:     GRAFNAME
		
		EVEN
VBLInterruptStruct:
		DC.L	0                         ; Succ
		DC.L	0                         ; Pred
		DC.B	NT_INTERRUPT              ; Type
		DC.B	0                         ; Prio
		DC.L	VBLInterruptName          ; Name
		DC.L	0                         ; Data
		DC.L	VBLInterruptCode          ; Code
		
		EVEN
VBLInterruptName:
		DC.B	"VBLCounter",0
		
		EVEN
SpriteList:
		DC.L	SPR0Data	; PARALLAX   (LEVEL 1)
		DC.L	SPR1Data	; SHIP
		DC.L	SPR2Data	; SHIP
		DC.L	SPR3Data	; SHIP
		DC.L	SPR4Data	; SHIP
		DC.L	SPR5Data	; PARALLAX   (LAYER 2)
		DC.L	SPR6Data	; PARALLAX   (LAYER 3)
		DC.L	SPR7Data	; BACKGROUND (LAYER 4)

		EVEN
SpriteList1:
		DC.L	SPR0Data1,8
		DC.L	SPR0Data2,8
		DC.L	SPR5Data1,4
		DC.L	SPR5Data2,4
		DC.L	SPR6Data1,2
		DC.L	SPR6Data2,2
		DC.L	SPR7Data,1
		DC.L	0
		
		EVEN
SpriteList2:
		DC.L	SPR1Data1,8
		DC.L	SPR1Data2,1
		DC.L	SPR1Data3,2
		DC.L	SPR1Data4,4
		DC.L	SPR2Data1,2
		DC.L	SPR2Data2,8
		DC.L	SPR2Data3,1
		DC.L	SPR3Data1,2
		DC.L	SPR3Data2,1
		DC.L	SPR3Data3,8
		DC.L	SPR3Data4,4
		DC.L	SPR3Data5,1
		DC.L	SPR4Data1,4
		DC.L	SPR4Data2,2
		DC.L	SPR4Data3,1
		DC.L	SPR4Data4,2
		DC.L	SPR4Data5,8
		DC.L	0
		
***********************************************************
** 
** COPPER LIST (CHIPMEM)
** 
***********************************************************

		SECTION S1,DATA_C
		
CopListSTART:
		dc.w	$01fc,%0000000000011111   ; FMODE   (---- ---- ---S SSPP)
*		dc.w	$008e,$2C81               ; DIWSTRT
*		dc.w	$0090,$2CC1               ; DIWSTOP
*		dc.w	$0092,$0038               ; DDFSTRT
*		dc.w	$0094,$00C8               ; DDFSTOP
		dc.w	$0100,%1000001000010001   ; BPLCON0 (HIRES, COLOR)
		dc.w	$0102,%0000000000000000   ; BPLCON1
		dc.w	$0104,$0024               ; BPLCON2
		dc.w	$0108,$0000               ; BPL1MOD
		dc.w	$010a,$0000               ; BPL2MOD
		dc.w	$0096,$83a0               ; DMACON  (BPL, COP, SPR)
		
CopListSPRxPTR:
		dc.w	$0120,0,$0122,0           ; SPR0PTR
		dc.w	$0124,0,$0126,0           ; SPR1PTR
		dc.w	$0128,0,$012a,0           ; SPR2PTR
		dc.w	$012C,0,$012e,0           ; SPR3PTR
		dc.w	$0130,0,$0132,0           ; SPR4PTR
		dc.w	$0134,0,$0136,0           ; SPR5PTR
		dc.w	$0138,0,$013a,0           ; SPR6PTR
		dc.w	$013c,0,$013e,0           ; SPR7PTR
		
CopListBPLxPTR:
		dc.w	$00e0,0,$00e2,0           ; BPL1PTR
		dc.w	$00e4,0,$00e6,0           ; BPL2PTR
		dc.w	$00e8,0,$00ea,0           ; BPL3PTR
		dc.w	$00ec,0,$00ee,0           ; BPL4PTR
		dc.w	$00f0,0,$00f2,0           ; BPL5PTR
		dc.w	$00f4,0,$00f6,0           ; BPL6PTR
		dc.w	$00f8,0,$00fa,0           ; BPL7PTR
		dc.w	$00fc,0,$00fe,0           ; BPL8PTR

CopListPaletteSPR:
		INCLUDE SuperSprite.pal
		
CopListPaletteBPL:
		
		dc.w	$0106,$0c40
		dc.w	$0180,$0000
		
		dc.w	$01a0,$0000-$0000         ; Sprite #0
		dc.w	$01a2,$0653-$0000         ; 
		dc.w	$01a4,$0774-$0000         ; 
		dc.w	$01a6,$0996-$0000         ; 

		dc.w	$01a8,$0000               ; Sprite #1
		dc.w	$01aa,$0653-$0000         ; 
		dc.w	$01ac,$0774-$0000         ; 
		dc.w	$01ae,$0996-$0000         ; 

		dc.w	$01b0,$0000               ; Sprite #2
		dc.w	$01b2,$0653-$0000         ; 
		dc.w	$01b4,$0774-$0000         ; 
		dc.w	$01b6,$0996-$0000         ; 

		dc.w	$01b8,$0000               ; Sprite #7
		dc.w	$01ba,$0653-$0000         ; 
		dc.w	$01bc,$0774-$0000         ; 
		dc.w	$01be,$0996-$0000         ; 

		dc.w	$3001,$fffe,$0180,$0400   ; TOP TUBE (RED)
		dc.w	$3101,$fffe,$0180,$0800   ; 
		dc.w	$3201,$fffe,$0180,$0a00   ; 
		dc.w	$3301,$fffe,$0180,$0c00   ; 
		dc.w	$3401,$fffe,$0180,$0c00   ; 
		dc.w	$3501,$fffe,$0180,$0a00   ; 
		dc.w	$3601,$fffe,$0180,$0800   ; 
		dc.w	$3701,$fffe,$0180,$0400   ; 
		dc.w	$3801,$fffe,$0180,$0000   ; 

CopListMidGradient:
		dc.w	$8001,$fffe,$0180,$0002   ; MIDDLE Gradient
		dc.w	$9201,$fffe,$0180,$0003   ; 
		dc.w	$9401,$fffe,$0180,$0003   ; 
		dc.w	$9601,$fffe,$0180,$0004   ; 
		dc.w	$9801,$fffe,$0180,$0006   ; 
		dc.w	$9a01,$fffe,$0180,$0004   ; 
		dc.w	$9c01,$fffe,$0180,$0003   ; 
		dc.w	$9e01,$fffe,$0180,$0002   ; 
		dc.w	$b001,$fffe,$0180,$0000   ; 

		dc.w	$f701,$fffe,$0180,$0040   ; BOTTOM TUBE (GREEN)
		dc.w	$f801,$fffe,$0180,$0080   ; 
		dc.w	$f901,$fffe,$0180,$00a0   ; 
		dc.w	$fa01,$fffe,$0180,$00c0   ; 
		dc.w	$fb01,$fffe,$0180,$00c0   ; 
		dc.w	$fc01,$fffe,$0180,$00a0   ; 
		dc.w	$fd01,$fffe,$0180,$0080   ; 
		dc.w	$fe01,$fffe,$0180,$0040   ; 
		dc.w	$ff01,$fffe,$0180,$0000   ; 
		
		INCLUDE SuperSprite.pal
		
CopListSTOP:
		dc.w	$ffff,$fffe               ; END
		
***********************************************************
** 
** SPRITES DATA (CHIPMEM)
** 
***********************************************************

ROWS1	MACRO
		REPT \1
		;        00112233445566778899AABBCCDDEEFF
		DC.L    %11110011001100110011001100110011	; Plane #0
		DC.L    %00001111000011110000111100001111	; Plane #1
		DC.L    %00000000111111110000000011111111	; Plane #2
		DC.L    %00000000000000001111111111111111	; Plane #3
		ENDR
		ENDM

ROWS2	MACRO
		REPT \1
		;        0123456789ABCDEF0123456789ABCDEF
		DC.L    %11010101010101011101010101010101	; Plane #0
		DC.L    %00110011001100110011001100110011	; Plane #1
		DC.L    %00001111000011110000111100001111	; Plane #2
		DC.L    %00000000111111110000000011111111	; Plane #3
		ENDR
		ENDM
		
***********************************************************
		
		CNOP	0,64
SPR0Data:
		; 
		; PARALLAX PATTERN - FRONTMOST
		; 
SPR0Data1:
		DC.W	$3000,$0000,$0000,$0002
		DC.W	$6000,$0000,$0000,$0000
		INCLUDE parallax64x48x4.spr
SPR0Data2:
		DC.W	$cf00,$0000,$0000,$0002
		DC.W	$ff00,$0000,$0000,$0000
		INCLUDE parallax64x48x4.spr
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************
		
		CNOP	0,64
SPR1Data:
		;
		; FREE TO USE
		;
SPR1Data1:
		DC.W	$4010,$0000,$0000,$0001
		DC.W	$7c00,$0000,$0000,$0000
		ROWS1   60
SPR1Data2:
		DC.W	$8060,$0000,$0000,$0041
		DC.W	$bc00,$0000,$0000,$0000
		ROWS1   60
SPR1Data3:
		DC.W	$c020,$0000,$0000,$0061
		DC.W	$e800,$0000,$0000,$0000
		ROWS1   40
SPR1Data4:
		DC.W	$e990,$0000,$0000,$0021
		DC.W	$ff00,$0000,$0000,$0000
		ROWS1   22
SPR1Data5:
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************

		CNOP	0,64
SPR2Data:
		;
		; FREE TO USE
		;
SPR2Data1:
		DC.W	$7035,$0000,$0000,$0031
		DC.W	$8E00,$0000,$0000,$0000
		ROWS1   30
SPR2Data2:
		DC.W	$9055,$0000,$0000,$0071
		DC.W	$f400,$0000,$0000,$0000
		ROWS1   100
SPR2Data3:
		DC.W	$f575,$0000,$0000,$0061
		DC.W	$ff00,$0000,$0000,$0000
		ROWS1   10
SPR2Data4:
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************

		CNOP	0,64
SPR3Data:
		;
		; FREE TO USE
		;
SPR3Data1:
		DC.W	$4020,$0000,$0000,$0001
		DC.W	$4a00,$0000,$0000,$0000
		ROWS1	10
SPR3Data2:
		DC.W	$4b45,$0000,$0000,$0021
		DC.W	$5f00,$0000,$0000,$0000
		ROWS1	20
SPR3Data3:
		DC.W	$6085,$0000,$0000,$0031
		DC.W	$8800,$0000,$0000,$0000
		ROWS1	40
SPR3Data4:
		DC.W	$8990,$0000,$0000,$0061
		DC.W	$a700,$0000,$0000,$0000
		ROWS1	30
SPR3Data5:
		DC.W	$a8a0,$0000,$0000,$0071
		DC.W	$e400,$0000,$0000,$0000
		ROWS1	60
SPR3Data6:
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************

		CNOP	0,64
SPR4Data:
		;
		; FREE TO USE
		;
SPR4Data1:
		DC.W	$3b90,$0000,$0000,$0011
		DC.W	$4b00,$0000,$0000,$0000
		ROWS1	16
SPR4Data2:
		DC.W	$4c70,$0000,$0000,$0031
		DC.W	$8800,$0000,$0000,$0000
		ROWS1	60
SPR4Data3:
		DC.W	$8938,$0000,$0000,$0041
		DC.W	$9d00,$0000,$0000,$0000
		ROWS1	20
SPR4Data4:
		DC.W	$9e90,$0000,$0000,$0001
		DC.W	$d000,$0000,$0000,$0000
		ROWS1	50
SPR4Data5:
		DC.W	$d222,$0000,$0000,$0071
		DC.W	$f000,$0000,$0000,$0000
		ROWS1	35
SPR4Data6:
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************

		CNOP	0,64
SPR5Data:
		;
		; PARALLAX PATTERN
		;
SPR5Data1:
		DC.W	$3800,$0000,$0000,$0002
		DC.W	$6800,$0000,$0000,$0000
		INCLUDE parallax64x48x4.spr
SPR5Data2:
		DC.W	$c000,$0000,$0000,$0002
		DC.W	$f000,$0000,$0000,$0000
		INCLUDE parallax64x48x4.spr
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************

		CNOP	0,64
SPR6Data:
		;
		; PARALLAX PATTERN
		; 
SPR6Data1:
		DC.W	$3f00,$0000,$0000,$0002
		DC.W	$6f00,$0000,$0000,$0000
		INCLUDE parallax64x48x4.spr
SPR6Data2:
		DC.W	$b000,$0000,$0000,$0002
		DC.W	$e000,$0000,$0000,$0000
		INCLUDE parallax64x48x4.spr
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************
		
		CNOP	0,64
SPR7Data:
		; 
		; BACKGROUND PATTERN
		; 
		DC.W	$384a,$0000,$0000,$0002
		DC.W	$f700,$0000,$0000,$0000
		INCLUDE parallax64x191x4.spr
		DC.W	$0000,$0000,$0000,$0000
		DC.W	$0000,$0000,$0000,$0000
		
***********************************************************

		CNOP	0,64
SPRXData:
		DC.B	16
		
***********************************************************
** 
** BITPLANES DATA (CHIPMEM)
** 
***********************************************************

		CNOP	0,64
ScreenData1:
		DCB.B   (SCRW*SCRH*2),$00
		
***********************************************************
