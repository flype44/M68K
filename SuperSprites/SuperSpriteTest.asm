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
		
.SetCopList
		move.l   #CopListSTART,$dff080    ; COP1LCH/COP1LCL
		move.w   #0,$dff088               ; COPJMP1
		
.MainLoop
		CALLGRAF WaitTOF                  ; Wait
		btst.b   #6,$bfe001               ; CIAAPRA -> FIR0
		bne.s    .MainLoop                ; Continue
		
.PopCopList
		move.l   OldCopper(pc),$dff080    ; COP1LCH/COP1LCL
		move.l   #0,$dff088               ; COPJMP1
		
.CloseGfx
		move.l   _GfxBase,a1              ; Close Graphics
		CALLEXEC CloseLibrary             ; 
		
.Exit
		moveq.l  #0,d0                    ; Return Code
		rts                               ; Exit program

***********************************************************

_GfxBase:
		DS.L	1

OldCopper:
		DS.L	1

SpriteList:
		DC.L	SpriteData0
		DC.L	SpriteData1
		DC.L	SpriteData2
		DC.L	SpriteData3
		DC.L	SpriteData4
		DC.L	SpriteData5
		DC.L	SpriteData6
		DC.L	SpriteData7
		
GfxName:
		GRAFNAME
		
***********************************************************

		SECTION S1,DATA_C
		
		;--------------------------------------------------
		; SAGA Super Sprites notes.
		;--------------------------------------------------
		; 
		; FMODE Bit(4) :
		; Enable/Disable 32 pixels-width sprites in 16 colors.
		; 
		; This special SAGA mode is only enabled if all the 
		; FMODE register bits 2, 3 and 4 are sets.
		; 
		; It is a global switch. That's for safety compatibility
		; with the OCS, ECS, and AGA original modes.
		; 
		;--------------------------------------------------
		
CopListSTART:
		dc.w	$01fc,%0000000000011111   ; FMODE   (---- ---- ---S SSPP)
		dc.w	$008e,$2C81               ; DIWSTRT
		dc.w	$0090,$2CC1               ; DIWSTOP
		dc.w	$0092,$0038               ; DDFSTRT
		dc.w	$0094,$00C8               ; DDFSTOP
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
		
CopListPaletteBPL:
		INCLUDE A600-640x256.pal
		
CopListPaletteSPR:

		;--------------------------------------------------
		; SAGA Super Sprites notes.
		;--------------------------------------------------
		;
		; BPLCON3 Bit(8) : Super Sprite palette bank
		; 
		; Bank #0 : $dff106 = $0100, $dff180 to $19e
		; Bank #1 : $dff106 = $0100, $dff1a0 to $1be
		; Bank #2 : $dff106 = $2100, $dff180 to $19e 
		; Bank #3 : $dff106 = $2100, $dff1a0 to $1be
		; Bank #4 : $dff106 = $4100, $dff180 to $19e 
		; Bank #5 : $dff106 = $6100, $dff1a0 to $1be
		; Bank #6 : $dff106 = $4100, $dff180 to $19e 
		; Bank #7 : $dff106 = $4100, $dff1a0 to $1be
		; 
		; There is one usable bank per sprite header.
		; 
		; This bit only have effect if both Global and Local
		; switches are enabled. See the other notes below.
		; 
		;--------------------------------------------------
		
		INCLUDE SuperSprite.pal
		
CopListSTOP:
		dc.w	$ffff,$fffe               ; END
		
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
		
		;--------------------------------------------------
		; SAGA Super Sprites notes.
		;--------------------------------------------------
		; 
		; In the sprite header, such as the representation below :
		; 
		; VVHH ---- ---- --BS
		; VV-- ---- ---- ----
		; 
		; SAGA introduces 2 features :
		; 
		; "B" = Bank palette selector.
		; "S" = Super Sprite switch.
		; 
		; "B" is a local, per sprite header selector (0 to 7).
		; This selects the palette bank to use for the given 
		; sprite data.
		; 
		; "S" is a local, per sprite header switch (0 to 1).
		; This enables the 32-pixels in 16 colors mode.
		; 
		;--------------------------------------------------
		
		CNOP	0,64
SpriteData0:
		DC.W	$3845,$0000,$0000,$0001 ; VVHH ---- ---- --BS
		DC.W	$8800,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS2	$50
		DC.W	$8944,$0000,$0000,$0021 ; VVHH ---- ---- --BS
		DC.W	$C000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	$37
		DC.W	$C143,$0000,$0000,$0031 ; VVHH ---- ---- --BS
		DC.W	$E100,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS2	$20
		DC.W	$E242,$0000,$0000,$0071 ; VVHH ---- ---- --BS
		DC.W	$F000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	14
		DC.W	$F141,$0000,$0000,$0011 ; VVHH ---- ---- --BS
		DC.W	$FF00,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS2	14
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************
		
		CNOP	0,64
SpriteData1:
		DC.W	$4065,$0000,$0000,$0011 ; VVHH ---- ---- --BS
		DC.W	$9000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	$50
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************

		CNOP	0,64
SpriteData2:
		DC.W	$4885,$0000,$0000,$0021 ; VVHH ---- ---- --BS
		DC.W	$C800,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	$80
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************

		CNOP	0,64
SpriteData3:
		DC.W	$4FA5,$0000,$0000,$0031 ; VVHH ---- ---- --BS
		DC.W	$AF00,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	$60
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************

		CNOP	0,64
SpriteData4:
		DC.W	$7858,$0000,$0000,$0041 ; VVHH ---- ---- --BS
		DC.W	$E800,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	$70
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************

		CNOP	0,64
SpriteData5:
		DC.W	$A078,$0000,$0000,$0051 ; VVHH ---- ---- --BS
		DC.W	$FF00,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	$5F
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************

		CNOP	0,64
SpriteData6:
		DC.W	$6898,$0000,$0000,$0061 ; VVHH ---- ---- --BS
		DC.W	$F800,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS2	$90
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************

		CNOP	0,64
SpriteData7:
		DC.W	$6FB8,$0000,$0000,$0071 ; VVHH ---- ---- --BS
		DC.W	$E800,$0000,$0000,$0000 ; VV-- ---- ---- ----
		ROWS1	$99
		DC.W	$0000,$0000,$0000,$0000 ; VVHH ---- ---- --BS
		DC.W	$0000,$0000,$0000,$0000 ; VV-- ---- ---- ----
		
***********************************************************

		CNOP	0,64
ScreenData1:
		INCBIN  A600-640x256.raw
		
***********************************************************
