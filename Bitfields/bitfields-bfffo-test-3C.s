;===================================================================
; ASM Test : Bitfields - BFEXTS
; S C:\Users\FORMATION\Desktop\output12.txt 406f7574 75
;===================================================================

assert_zero EQU $00D0000C ; magical register

;===================================================================
; Main
;===================================================================

start:
    clr.l  d0             ; bitfield source
    clr.l  d1             ; bitfield offset
    clr.l  d2             ; bitfield width
    clr.l  d3             ; bitfield precalc result
    clr.l  d4             ; bitfield result
    clr.l  d7             ; error counter
    lea    precalc,a0     ; precalc array
.loop:
    move.b (a0)+,d0       ; read source
    cmpi.b #-1,d0         ; if last value = -1
    beq    .exit          ; then exit
    move.b (a0)+,d1       ; read offset
    move.b (a0)+,d2       ; read width
    move.b (a0)+,d3       ; read precalc result
    bfffo  d0{d1:d2},d4   ; bitfield operation
    sub.l  d3,d4          ; compare results
    beq.l  .loop          ; if d4=0, continue
    addi.l #1,d7          ; else increment error counter
    move.l d3,assert_zero ; and raise error
    move.l d4,-1(a0)      ; update table
    bra    .loop          ; continue
.exit:
    stop   #-1            ; stop execution

;===================================================================
; Data Section
;===================================================================

precalc:
    ; source,offset,width,result
    dc.b $10,$5F,$60,$3B
    dc.b $10,$5F,$5F,$3B
    dc.b $10,$5F,$5E,$3B
    dc.b $10,$5F,$5D,$3B
    dc.b $10,$5F,$5C,$3B
    dc.b $10,$5F,$40,$3B
    dc.b $10,$5F,$3F,$3B
    dc.b $10,$5F,$3E,$3B
    dc.b $10,$5F,$3D,$3B
    dc.b $10,$5F,$3C,$3B
    dc.b $10,$5F,$20,$3B
    dc.b $10,$5F,$1F,$3B
    dc.b $10,$5F,$1E,$3B
    dc.b $10,$5F,$1D,$3B
    dc.b $10,$5F,$1C,$3B
    dc.b $10,$5F,$00,$3B
    dc.b $10,$5E,$60,$3B
    dc.b $10,$5E,$5F,$3B
    dc.b $10,$5E,$5E,$3B
    dc.b $10,$5E,$5D,$3B
    dc.b $10,$5E,$40,$3B
    dc.b $10,$5E,$3F,$3B
    dc.b $10,$5E,$3E,$3B
    dc.b $10,$5E,$3D,$3B
    dc.b $10,$5E,$20,$3B
    dc.b $10,$5E,$1F,$3B
    dc.b $10,$5E,$1E,$3B
    dc.b $10,$5E,$1D,$3B
    dc.b $10,$5E,$00,$3B
    dc.b $10,$5D,$60,$3B
    dc.b $10,$5D,$5F,$3B
    dc.b $10,$5D,$5E,$3B
    dc.b $10,$5D,$40,$3B
    dc.b $10,$5D,$3F,$3B
    dc.b $10,$5D,$3E,$3B
    dc.b $10,$5D,$20,$3B
    dc.b $10,$5D,$1F,$3B
    dc.b $10,$5D,$1E,$3B
    dc.b $10,$5D,$00,$3B
    dc.b $10,$5C,$60,$3B
    dc.b $10,$5C,$5F,$3B
    dc.b $10,$5C,$40,$3B
    dc.b $10,$5C,$3F,$3B
    dc.b $10,$5C,$20,$3B
    dc.b $10,$5C,$1F,$3B
    dc.b $10,$5C,$00,$3B
    dc.b $10,$3F,$60,$3B
    dc.b $10,$3F,$5F,$3B
    dc.b $10,$3F,$5E,$3B
    dc.b $10,$3F,$5D,$3B
    dc.b $10,$3F,$5C,$3B
    dc.b $10,$3F,$40,$3B
    dc.b $10,$3F,$3F,$3B
    dc.b $10,$3F,$3E,$3B
    dc.b $10,$3F,$3D,$3B
    dc.b $10,$3F,$3C,$3B
    dc.b $10,$3F,$20,$3B
    dc.b $10,$3F,$1F,$3B
    dc.b $10,$3F,$1E,$3B
    dc.b $10,$3F,$1D,$3B
    dc.b $10,$3F,$1C,$3B
    dc.b $10,$3F,$00,$3B
    dc.b $10,$3E,$60,$3B
    dc.b $10,$3E,$5F,$3B
    dc.b $10,$3E,$5E,$3B
    dc.b $10,$3E,$5D,$3B
    dc.b $10,$3E,$40,$3B
    dc.b $10,$3E,$3F,$3B
    dc.b $10,$3E,$3E,$3B
    dc.b $10,$3E,$3D,$3B
    dc.b $10,$3E,$20,$3B
    dc.b $10,$3E,$1F,$3B
    dc.b $10,$3E,$1E,$3B
    dc.b $10,$3E,$1D,$3B
    dc.b $10,$3E,$00,$3B
    dc.b $10,$3D,$60,$3B
    dc.b $10,$3D,$5F,$3B
    dc.b $10,$3D,$5E,$3B
    dc.b $10,$3D,$40,$3B
    dc.b $10,$3D,$3F,$3B
    dc.b $10,$3D,$3E,$3B
    dc.b $10,$3D,$20,$3B
    dc.b $10,$3D,$1F,$3B
    dc.b $10,$3D,$1E,$3B
    dc.b $10,$3D,$00,$3B
    dc.b $10,$3C,$60,$3B
    dc.b $10,$3C,$5F,$3B
    dc.b $10,$3C,$40,$3B
    dc.b $10,$3C,$3F,$3B
    dc.b $10,$3C,$20,$3B
    dc.b $10,$3C,$1F,$3B
    dc.b $10,$3C,$00,$3B
    dc.b $10,$1F,$60,$3B
    dc.b $10,$1F,$5F,$3B
    dc.b $10,$1F,$5E,$3B
    dc.b $10,$1F,$5D,$3B
    dc.b $10,$1F,$5C,$3B
    dc.b $10,$1F,$40,$3B
    dc.b $10,$1F,$3F,$3B
    dc.b $10,$1F,$3E,$3B
    dc.b $10,$1F,$3D,$3B
    dc.b $10,$1F,$3C,$3B
    dc.b $10,$1F,$20,$3B
    dc.b $10,$1F,$1F,$3B
    dc.b $10,$1F,$1E,$3B
    dc.b $10,$1F,$1D,$3B
    dc.b $10,$1F,$1C,$3B
    dc.b $10,$1F,$00,$3B
    dc.b $10,$1E,$60,$3B
    dc.b $10,$1E,$5F,$3B
    dc.b $10,$1E,$5E,$3B
    dc.b $10,$1E,$5D,$3B
    dc.b $10,$1E,$40,$3B
    dc.b $10,$1E,$3F,$3B
    dc.b $10,$1E,$3E,$3B
    dc.b $10,$1E,$3D,$3B
    dc.b $10,$1E,$20,$3B
    dc.b $10,$1E,$1F,$3B
    dc.b $10,$1E,$1E,$3B
    dc.b $10,$1E,$1D,$3B
    dc.b $10,$1E,$00,$3B
    dc.b $10,$1D,$60,$3B
    dc.b $10,$1D,$5F,$3B
    dc.b $10,$1D,$5E,$3B
    dc.b $10,$1D,$40,$3B
    dc.b $10,$1D,$3F,$3B
    dc.b $10,$1D,$3E,$3B
    dc.b $10,$1D,$20,$3B
    dc.b $10,$1D,$1F,$3B
    dc.b $10,$1D,$1E,$3B
    dc.b $10,$1D,$00,$3B
    dc.b $10,$1C,$60,$3B
    dc.b $10,$1C,$5F,$3B
    dc.b $10,$1C,$40,$3B
    dc.b $10,$1C,$3F,$3B
    dc.b $10,$1C,$20,$3B
    dc.b $10,$1C,$1F,$3B
    dc.b $10,$1C,$00,$3B
    dc.b $08,$5F,$5C,$3B
    dc.b $08,$5F,$3C,$3B
    dc.b $08,$5F,$1C,$3B
    dc.b $08,$5E,$5D,$3B
    dc.b $08,$5E,$3D,$3B
    dc.b $08,$5E,$1D,$3B
    dc.b $08,$5D,$5E,$3B
    dc.b $08,$5D,$3E,$3B
    dc.b $08,$5D,$1E,$3B
    dc.b $08,$3F,$5C,$3B
    dc.b $08,$3F,$3C,$3B
    dc.b $08,$3F,$1C,$3B
    dc.b $08,$3E,$5D,$3B
    dc.b $08,$3E,$3D,$3B
    dc.b $08,$3E,$1D,$3B
    dc.b $08,$3D,$5E,$3B
    dc.b $08,$3D,$3E,$3B
    dc.b $08,$3D,$1E,$3B
    dc.b $08,$1F,$5C,$3B
    dc.b $08,$1F,$3C,$3B
    dc.b $08,$1F,$1C,$3B
    dc.b $08,$1E,$5D,$3B
    dc.b $08,$1E,$3D,$3B
    dc.b $08,$1E,$1D,$3B
    dc.b $08,$1D,$5E,$3B
    dc.b $08,$1D,$3E,$3B
    dc.b $08,$1D,$1E,$3B
    dc.b $04,$5F,$5C,$3B
    dc.b $04,$5F,$3C,$3B
    dc.b $04,$5F,$1C,$3B
    dc.b $04,$5E,$5D,$3B
    dc.b $04,$5E,$3D,$3B
    dc.b $04,$5E,$1D,$3B
    dc.b $04,$3F,$5C,$3B
    dc.b $04,$3F,$3C,$3B
    dc.b $04,$3F,$1C,$3B
    dc.b $04,$3E,$5D,$3B
    dc.b $04,$3E,$3D,$3B
    dc.b $04,$3E,$1D,$3B
    dc.b $04,$1F,$5C,$3B
    dc.b $04,$1F,$3C,$3B
    dc.b $04,$1F,$1C,$3B
    dc.b $04,$1E,$5D,$3B
    dc.b $04,$1E,$3D,$3B
    dc.b $04,$1E,$1D,$3B
    dc.b $02,$5F,$5C,$3B
    dc.b $02,$5F,$3C,$3B
    dc.b $02,$5F,$1C,$3B
    dc.b $02,$3F,$5C,$3B
    dc.b $02,$3F,$3C,$3B
    dc.b $02,$3F,$1C,$3B
    dc.b $02,$1F,$5C,$3B
    dc.b $02,$1F,$3C,$3B
    dc.b $02,$1F,$1C,$3B
    dc.b $08,$5F,$60,$3C
    dc.b $08,$5F,$5F,$3C
    dc.b $08,$5F,$5E,$3C
    dc.b $08,$5F,$5D,$3C
    dc.b $08,$5F,$40,$3C
    dc.b $08,$5F,$3F,$3C
    dc.b $08,$5F,$3E,$3C
    dc.b $08,$5F,$3D,$3C
    dc.b $08,$5F,$20,$3C
    dc.b $08,$5F,$1F,$3C
    dc.b $08,$5F,$1E,$3C
    dc.b $08,$5F,$1D,$3C
    dc.b $08,$5F,$00,$3C
    dc.b $08,$5E,$60,$3C
    dc.b $08,$5E,$5F,$3C
    dc.b $08,$5E,$5E,$3C
    dc.b $08,$5E,$40,$3C
    dc.b $08,$5E,$3F,$3C
    dc.b $08,$5E,$3E,$3C
    dc.b $08,$5E,$20,$3C
    dc.b $08,$5E,$1F,$3C
    dc.b $08,$5E,$1E,$3C
    dc.b $08,$5E,$00,$3C
    dc.b $08,$5D,$60,$3C
    dc.b $08,$5D,$5F,$3C
    dc.b $08,$5D,$40,$3C
    dc.b $08,$5D,$3F,$3C
    dc.b $08,$5D,$20,$3C
    dc.b $08,$5D,$1F,$3C
    dc.b $08,$5D,$00,$3C
    dc.b $08,$3F,$60,$3C
    dc.b $08,$3F,$5F,$3C
    dc.b $08,$3F,$5E,$3C
    dc.b $08,$3F,$5D,$3C
    dc.b $08,$3F,$40,$3C
    dc.b $08,$3F,$3F,$3C
    dc.b $08,$3F,$3E,$3C
    dc.b $08,$3F,$3D,$3C
    dc.b $08,$3F,$20,$3C
    dc.b $08,$3F,$1F,$3C
    dc.b $08,$3F,$1E,$3C
    dc.b $08,$3F,$1D,$3C
    dc.b $08,$3F,$00,$3C
    dc.b $08,$3E,$60,$3C
    dc.b $08,$3E,$5F,$3C
    dc.b $08,$3E,$5E,$3C
    dc.b $08,$3E,$40,$3C
    dc.b $08,$3E,$3F,$3C
    dc.b $08,$3E,$3E,$3C
    dc.b $08,$3E,$20,$3C
    dc.b $08,$3E,$1F,$3C
    dc.b $08,$3E,$1E,$3C
    dc.b $08,$3E,$00,$3C
    dc.b $08,$3D,$60,$3C
    dc.b $08,$3D,$5F,$3C
    dc.b $08,$3D,$40,$3C
    dc.b $08,$3D,$3F,$3C
    dc.b $08,$3D,$20,$3C
    dc.b $08,$3D,$1F,$3C
    dc.b $08,$3D,$00,$3C
    dc.b $08,$1F,$60,$3C
    dc.b $08,$1F,$5F,$3C
    dc.b $08,$1F,$5E,$3C
    dc.b $08,$1F,$5D,$3C
    dc.b $08,$1F,$40,$3C
    dc.b $08,$1F,$3F,$3C
    dc.b $08,$1F,$3E,$3C
    dc.b $08,$1F,$3D,$3C
    dc.b $08,$1F,$20,$3C
    dc.b $08,$1F,$1F,$3C
    dc.b $08,$1F,$1E,$3C
    dc.b $08,$1F,$1D,$3C
    dc.b $08,$1F,$00,$3C
    dc.b $08,$1E,$60,$3C
    dc.b $08,$1E,$5F,$3C
    dc.b $08,$1E,$5E,$3C
    dc.b $08,$1E,$40,$3C
    dc.b $08,$1E,$3F,$3C
    dc.b $08,$1E,$3E,$3C
    dc.b $08,$1E,$20,$3C
    dc.b $08,$1E,$1F,$3C
    dc.b $08,$1E,$1E,$3C
    dc.b $08,$1E,$00,$3C
    dc.b $08,$1D,$60,$3C
    dc.b $08,$1D,$5F,$3C
    dc.b $08,$1D,$40,$3C
    dc.b $08,$1D,$3F,$3C
    dc.b $08,$1D,$20,$3C
    dc.b $08,$1D,$1F,$3C
    dc.b $08,$1D,$00,$3C
    dc.b $04,$5F,$5D,$3C
    dc.b $04,$5F,$3D,$3C
    dc.b $04,$5F,$1D,$3C
    dc.b $04,$5E,$5E,$3C
    dc.b $04,$5E,$3E,$3C
    dc.b $04,$5E,$1E,$3C
    dc.b $04,$3F,$5D,$3C
    dc.b $04,$3F,$3D,$3C
    dc.b $04,$3F,$1D,$3C
    dc.b $04,$3E,$5E,$3C
    dc.b $04,$3E,$3E,$3C
    dc.b $04,$3E,$1E,$3C
    dc.b $04,$1F,$5D,$3C
    dc.b $04,$1F,$3D,$3C
    dc.b $04,$1F,$1D,$3C
    dc.b $04,$1E,$5E,$3C
    dc.b $04,$1E,$3E,$3C
    dc.b $04,$1E,$1E,$3C
    dc.b $02,$5F,$5D,$3C
    dc.b $02,$5F,$3D,$3C
    dc.b $02,$5F,$1D,$3C
    dc.b $02,$3F,$5D,$3C
    dc.b $02,$3F,$3D,$3C
    dc.b $02,$3F,$1D,$3C
    dc.b $02,$1F,$5D,$3C
    dc.b $02,$1F,$3D,$3C
    dc.b $02,$1F,$1D,$3C
    dc.b -1

;===================================================================
; End of program
;===================================================================
