;==============================================================================
; ASM Testcase
; flype, 2015-09-28
; math_mulu.asm
;==============================================================================

ASSERT_ZERO EQU $00D0000C

;==============================================================================

;	DC.L	0
;	DC.L	START
;	SECTION .FASTRAM

START:
       lea     passA1,a0      ; load Dr
       lea     passB1,a1      ; load Dq
       lea     passA2,a2      ; load Dr precalc
       lea     passB2,a3      ; load Dq precalc
LOOP:
       cmpi.l  #0,(a0)        ; if (a0) = 0
       beq     EXIT           ; then exit
       move.l  (a0)+,-(sp)    ; pass a
       move.l  (a1)+,-(sp)    ; pass b
       jsr     UMUL32         ; form a * b
       sub.l   (a2)+,d0       ; Dr - precalc
       move.l  d0,ASSERT_ZERO ; Assert D0 = 0
       sub.l   (a3)+,d1       ; Dr - precalc
       move.l  d1,ASSERT_ZERO ; Assert D0 = 1
       bra     LOOP           ; continue
EXIT:
      ;tst     $0             ; flush
      ;stop    #-1            ; stop sim
       rts

a:     EQU 8
b:     EQU 4
psize: EQU 8

UMUL32:
       move.l (a,sp),d0       ; fetch a
       move.l (b,sp),d1       ; fetch b
       mulu.l d0,d0:d1        ; 32 x 32 multiply
       move.l (sp),(psize,sp) ; 
       addq.l #psize,sp       ; 
       rts

;==============================================================================
; Data Section
;==============================================================================

passA1: dc.l $01010101,$ffffffff,$01234567,$0000ABCD,$12953671,$31649728,$7fedcba9,0
passB1: dc.l $10101010,$ffffffff,$07ffffff,$12340000,$00010000,$007feeee,$00000003
passA2: dc.l $00102030,$fffffffe,$00091a2b,$00000c37,$00001295,$0018af00,$00000001
passB2: dc.l $40302010,$00000001,$36dcba99,$4fa40000,$36710000,$6ce3b730,$7fc962fb

;==============================================================================
; End of file
;==============================================================================
