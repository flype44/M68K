;============================================
; Debug 'gdra' part of
; WhichAmiga 1.3.3 (2.5.99)
; by Harry "Piru" Sintonen.
;
; flype, 2015-10-01
; Related to the bug described here (by ShK) :
; http://personal.inet.fi/surf/shk/v2626_x8_whichamiga.mp4
;============================================

;============================================
; AmigaOS Includes
;============================================

; TODO:
;LIB_VERSION(a6)
;Enable
;Disable
;vbr
;PCR
;BUSCR
;cacr

ExecBase   EQU $4
Supervisor EQU -30
AttnFlags  EQU 296

; Processors and Co-processors
AFB_68010 EQU 0 ; also set for 68020
AFB_68020 EQU 1 ; also set for 68030
AFB_68030 EQU 2 ; also set for 68040
AFB_68040 EQU 3 ; 
AFB_68881 EQU 4	; also set for 68882
AFB_68882 EQU 5 ; 
AFB_FPU40 EQU 6 ; Set if 68040 FPU

; Cache manipulation Bits
CACRB_EnableI EQU 0
CACRB_WriteAllocate EQU 13

; Cache manipulation Flags
CACRF_EnableI       EQU (1<<0)  ; Enable instruction cache
CACRF_FreezeI       EQU (1<<1)  ; Freeze instruction cache
CACRF_ClearI        EQU (1<<3)  ; Clear instruction cache
CACRF_IBE           EQU (1<<4)  ; Instruction burst enable
CACRF_EnableD       EQU (1<<8)  ; 68030 Enable data cache
CACRF_FreezeD       EQU (1<<9)  ; 68030 Freeze data cache
CACRF_ClearD        EQU (1<<11) ; 68030 Clear data cache
CACRF_DBE           EQU (1<<12) ; 68030 Data burst enable
CACRF_WriteAllocate EQU (1<<13) ; 68030 Write-Allocate mode
CACRF_CopyBack	    EQU (1<<31) ; Master enable for copyback caches

;============================================
; Main Program
;============================================

START:
    bsr     ExtAttnFlags
    move.w  d0,_AttnFlags
    rts

;============================================
; ExtAttnFlags
; OUT: d0=attnflags
;============================================

ExtAttnFlags:
    movem.l d1/d2/a0-a1/a6,-(sp)
    move.l  (4).w,a6             ; ExecBase
    move.w  (AttnFlags,a6),d2    ; 
    tst.l   NoHW                 ; 
    bne.b   .nohw                ; 
    cmp.w   #37,(LIB_VERSION,a6) ; 
    bhs.b   .test060             ; 
    jsr     Test_030_040_882     ; 
    or.w    d0,d2                ; 
.test060
    btst    #AFB_68040,d2        ; You must have 68040 flag
    beq.b   .no060               ; set to have 68060.
    tst.b   d2                   ; Test #AFB_68060
    bmi.b   .is060               ; Is already valid!
    jsr     Test060              ; Test for 68060.
.is060
.no060
.nohw
.xit
    move.w  d2,d0                ; 
    movem.l (sp)+,d1/d2/a0-a1/a6 ; 
    rts                          ; 

;============================================
; 030, 040, 882
; Test WITHOUT system (for KS1.x use)
; IN:  d2=attnflags
; IN:  a6=execbase
; OUT: d0=updated attnflags
;============================================

Test_030_040_882:
	move.l	a5,-(sp)
	lea	    (.sv,pc),a5
	call	Supervisor
	move.l	(sp)+,a5
	rts
.sv
	moveq	#0,d0
	btst	#AFB_68020,d2
	beq.b	.not68020
	movec	cacr,d1
	move.l	d1,-(sp)
	or.w	#CACRF_WriteAllocate,d1
	movec	d1,cacr
	movec	cacr,d1
	btst	#CACRB_WriteAllocate,d1
	beq.b	.not68030
	bset	#AFB_68030,d0
.not68030
	move.l	(sp)+,d1
	movec	d1,cacr
	movec	cacr,d1
	move.l	d1,-(sp)
	or.w	#CACRF_EnableI!CACRF_ClearI!CACRF_ClearD!CACRF_WriteAllocate,d1
	movec	d1,cacr
	movec	cacr,d1
	btst	#CACRB_EnableI,d1
	bne.b	.not68040
	or.b	#AFF_68040!AFF_68030,d0
.not68040	move.l	(sp)+,d1
	or.w	#CACRF_ClearI!CACRF_ClearD!CACRF_WriteAllocate,d1
	movec	d1,cacr              ;
.not68020
	btst	#AFB_68881,d2        ;
	beq.b	.no882               ;
	moveq	#0,d1                ;
	dc.w	$F201,$9000          ;
	dc.w	$F201,$B000          ;
	dc.w	$F327                ;
	dc.w	$0C2F,$0018,$0001    ;
	cmp.b	#$18,(1,sp)          ;
	beq.b	.flushstack          ;
	bset	#AFB_68882,d0        ;
.flushstack
	dc.w	$F35F                ;
.no882
	nop                          ; Synchronize Pipelines
	rte

;============================================
; 060
;============================================

Test060
    move.l  a5,-(sp)             ; 
    lea     (.test060,pc),a5     ; 
    call    Disable              ; No others playing around, please.
    call    Supervisor           ; Ramsey revision:
    call    Enable               ; 
    move.l  (sp)+,a5             ; 
    rts

.test060
    movec   vbr,a0               ; Hijack illegal instr. trap
    move.l  ($10,a0),-(sp)       ; 
    move.l  ($2C,a0),-(sp)       ; 
    move.l  a0,-(sp)             ; 
    lea     (.illegal,pc),a1     ; 
    move.l  a1,($10,a0)          ; 
    move.l  a1,($2C,a0)          ; 
    bsr     _flush040            ; 
    moveq   #0,d0                ; 
    dc.w    $4E7A,$0008          ; 
    movec   BUSCR,d0             ; 
    dc.w    $4E7A,$0808          ; 
    movec   PCR,d0               ; 
    nop                          ; 
    nop                          ;  
    moveq    #1,d0               ; 
.exit_illegal
    move.l  (sp)+,a0             ; Restore illegal instr. trap
    move.l  (sp)+,($2C,a0)       ; 
    move.l  (sp)+,($10,a0)       ; 
    move.l  d0,-(sp)             ; 
    bsr     _flush040            ; 
    move.l  (sp)+,d0             ; 
    beq.b   .no060               ; 
    or.w    #AFF_68060,d2        ; 
.no060
    nop                          ; Synchronize Pipelines
    rte                          ; 
    CNOP    0,4
.illegal
    lea     (.exit_illegal,pc),a0
    move.l  a0,(2,sp)
    nop
    rte

;============================================
; flush040
;============================================

_flush040
    dc.w    $F518 ; PFLUSHA   flush the address translation cache
    dc.w    $F4F8 ; CPUSHA BC flush the caches into memory
    dc.w    $F4D8 ; INVA BC   invalidate the data and inst caches
    rts

;============================================
; Data Section
;============================================

NoHW		ds.l	1
_AttnFlags	ds.w    1

;============================================
; End of program
;============================================

    END
