***********************************************************
** Amiga PAULA2 testcase
** Plays 8BITS SOUND on AUD5 (6th channel)
** Works with Core AAN_67_15.jic
***********************************************************

    MACHINE MC68020

    INCLUDE dos/dos.i
    INCLUDE dos/dos_lib.i
    INCLUDE exec/exec.i
    INCLUDE exec/exec_lib.i

;==========================================================
;   DEFINITIONS
;==========================================================

VECTOR EQU $50      ; Vector L4.b (NUM:20) (DEC:80) (HEX:$50)
DMAPAL EQU 3546895  ; Amiga PAL DMA clock

;==========================================================
    SECTION S_0,CODE
;==========================================================

MAIN:

.opendos
	lea      _DOSNAME(pc),a1         ; Name
	moveq.l  #36,d0                  ; Version
	CALLEXEC OpenLibrary             ; OpenLibrary(name,version)
	tst.l    d0                      ; Check result
	beq      .exit                   ; Exit on error
	lea      _DOSBase(pc),a0         ; Load _DOSBase
	move.l   d0,(a0)                 ; Store Library base
.prep
	lea      $DFF0A0,a0              ; Load AUD0 base
	moveq.l  #4-1,d0                 ; 4 channels
1$	move.w   #0,6(a0)                ; Audio Period
	move.w   #0,8(a0)                ; Audio Volume
	add.l    #$10,a0                 ; Next Channel
	dbf      d0,1$                   ; Continue
.int
	lea      _OLDINT(pc),a0          ; Load old interrupt
	lea      _NEWINT(pc),a1          ; Load new interrupt
	movec    VBR,a2                  ; Load vector base address
	move.l   VECTOR(a2),(a0)         ; Store old interupt
	move.l   a1,VECTOR(a2)           ; Install new interrupt
	move.w   #$8100,$DFF29A          ; SET INTENA2->AUDx
.play
	lea      $DFF2B0,a4              ; Load AUDx base
	lea      SND16DAT,a5             ; Load Sound data
	move.l   a5,(a4)                 ; Audio Location
	move.w   #$0002,$DFF296          ; CLR DMACON2->AUDx
;	move.w   #$0020,$DFF29E          ; SET ADKCON2->AUDx (8bits mode)
	move.w   #$8020,$DFF29E          ; SET ADKCON2->AUDx (16bits mode)
	move.w   #0,4(a4)                ; Audio Length (Max)
	move.w   #(DMAPAL/11000),6(a4)   ; Audio Period (Clock/Rate)
	move.w   #64,8(a4)               ; Audio Volume (Max)
	move.w   #$0100,$DFF29C          ; CLR INTREQ2->AUDx
	move.w   #$8002,$DFF296          ; SET DMACON2->AUDx
.wait
	btst.b   #6,$BFE001              ; Check CIAA PRA
	beq.s    .stop                   ; Exit on FIR0
	tst.l    _DOEXIT(pc)             ; Check counter
	beq.s    .wait                   ; Exit if counter != 0
.stop
	move.w   #$0002,$DFF296          ; CLR DMACON2->AUDxEN
	move.w   #$0100,$DFF29A          ; CLR INTENA2->AUDx
	movec    VBR,a0                  ; Load vector base address
	move.l   _OLDINT(pc),VECTOR(a0)  ; Restore old interrupt
.closedos
	move.l   _DOSBase,a1             ; Close DOS
	CALLEXEC CloseLibrary            ; 
.exit
	moveq.l  #0,d0                   ; Return code
	rts                              ; Return

;==========================================================
;== INTERRUPT CODE
;==========================================================

_NEWINT:
	movem.l d0-a6,-(sp)
	move.l  #1,_DOEXIT               ; _DOEXIT = TRUE
	move.w  #$0100,$DFF29C           ; CLR INTREQ2->AUDx
	movem.l (sp)+,d0-a6
	RTE

;==========================================================
;== DATA SECTION
;==========================================================

	CNOP 0,4

_DOEXIT:  dc.l 0
_OLDINT:  dc.l 0
_DOSBase: dc.l 0
_DOSNAME: DOSNAME
	
	CNOP 0,8
	
SND08DAT: INCBIN pcm_mono_8bits.aif  ; Mono  8bits uncompressed

	CNOP 0,8
	
SND16DAT: INCBIN pcm_mono_16bits.aif ; Mono 16bits uncompressed

	END