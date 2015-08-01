;=========================================
; 68K ASM Test
; Memory Indirect Access / Branches in Chip and Fast
; S C:\Users\FORMATION\Desktop\output12.txt 40270EBC D0
;=========================================

;=========================================
;=========================================
;section .fastram
;=========================================
;=========================================

assert_zero EQU $00D0000C

size equ 60

;=========================================

Start:
    clr.l   d0                 ; 
    clr.l   d1                 ; 
    clr.l   d2                 ; 
    clr.l   d3                 ; 
    clr.l   d4                 ; 
    clr.l   d5                 ; 
    clr.l   d6                 ; 
    clr.l   d7                 ; 
    lea     data1,a0           ; 
    lea     datatbl,a1         ; 
    lea     precalc,a3         ; 
    move.l  #0,d7              ; init loop
loop:
    clr.l   d0                 ; 
    clr.l   d1                 ; 
    move.b  (a0)+,d0           ; read value from data1
    divu.w  #4,d0              ; is modulo 4 even or odd ?
    swap    d0                 ; 
    btst    #0,d0              ; 
    beq.s   even               ; 
    bsr     testfast           ; call routine in fast
    bra.s   continue           ; 
even:
    bsr     testchip           ; call routine in chip
continue:
    bsr     selftest           ; call selftest in chip
    addi.l  #1,d7              ; increment loop
    cmpi.l  #size-4,d7         ; 
    ble     loop               ; 
exit:
    stop    #-1                ; stop execution

;=========================================
;=========================================
;section .fastram
;=========================================
;=========================================

precalc:
    dc.l $E33973E3,$DF8D183A,$B9183ADE,$543ADEB9
    dc.l $CAC672D4,$A355D600,$FF545400,$AA58F448
    dc.l $5EF448AB,$1E48AB5F,$0A0C083F,$5070F01E
    dc.l $70F01D8C,$990BFC5D,$E1FC5D98,$D1338FAA
    dc.l $22D2D590,$9537EEF6,$94ADF5EC,$19F5EC94
    dc.l $09B5F3FE,$C1400F06,$400F0506,$81E1F5F4
    dc.l $0505BFE9,$EBF4802E,$071E940B,$E82EEBAB
    dc.l $8A2A0B31,$6BABE99E,$6D912210,$CD22106D
    dc.l $CC106DCD,$DB91A6D3,$19195A8A,$B0B25AB9
    dc.l $5A89D3DA,$89D3D9D8,$D3D9D723,$484C51BB
    dc.l $02B65394,$D635FE0B,$5B9403EA,$FE0AD2C7
    dc.l $B50DAA53,$D2C61DF0,$C61DEFD8,$E1B574EB
    dc.l $062051F3,$D7067CBF,$D9F30682,$41BF4002
    dc.l $5FFEDFF5,$93C6994A,$C699496B,$99496A7F
    dc.l $496A7E74,$00000000,$00000000,$00000000

testfast:
    lea     ([0,a1,d0.w*4]),a2 ; read value 
    move.l  (a2,d7),d1         ; 
    neg.l   d1                 ; some op
    rts

;=========================================
;=========================================
;section .chipram
;=========================================
;=========================================

testchip:
    lea     ([4,a1,d0.w*4]),a2 ; read value
    move.l  (a2,d7),d1         ; 
    ror.l   #7,d1              ; some op
    rts

selftest:
    sub.l   (a3)+,d1           ; compare with precalc
    beq     selfnext           ; 
    addi.l  #1,d6              ; error counter
selfnext:
    move.l  d1,assert_zero     ; raise error if != 0
    rts

;=========================================

data1:
    dc.b $77,$56,$7A,$26,$59,$6B,$D6,$9C
    dc.b $48,$64,$E6,$0D,$5D,$86,$42,$E7
    dc.b $E4,$F5,$1E,$26,$C7,$85,$01,$30
    dc.b $D5,$50,$1A,$CC,$7D,$84,$56,$9A
    dc.b $1E,$51,$DB,$38,$13,$0B,$6B,$8E
    dc.b $48,$9D,$BC,$D9,$62,$99,$11,$76
    dc.b $A4,$E1,$E0,$F2,$9F,$61,$95,$D1

;=========================================

data2:
    dc.b $AD,$91,$E6,$CC,$35,$39,$8D,$2C
    dc.b $7A,$24,$55,$AF,$8F,$0F,$E2,$74
    dc.b $69,$6A,$C8,$11,$0A,$3E,$BF,$F0
    dc.b $FA,$FA,$40,$17,$75,$D5,$F4,$CF
    dc.b $35,$24,$6E,$59,$2D,$5C,$D8,$00
    dc.b $5B,$29,$CA,$01,$F5,$2D,$39,$E2
    dc.b $10,$28,$F9,$83,$41,$6C,$39,$66

;=========================================

data3:
    dc.b $B6,$95,$81,$8C,$07,$2D,$E8,$C6
    dc.b $D1,$1F,$12,$0D,$46,$CE,$7F,$66
    dc.b $4B,$E3,$05,$92,$ED,$47,$CB,$65
    dc.b $32,$B7,$F8,$EC,$B0,$0D,$A9,$BE
    dc.b $F5,$7C,$17,$69,$27,$3C,$23,$C7
    dc.b $24,$A7,$A9,$CF,$72,$84,$67,$1A
    dc.b $DB,$ED,$5A,$8D,$0D,$5A,$1E,$8D

;=========================================

data4:
    dc.b $1C,$C6,$8C,$1D,$6F,$5C,$AA,$2A
    dc.b $00,$7F,$06,$04,$1F,$85,$FE,$2E
    dc.b $CC,$70,$56,$FA,$F6,$4A,$0C,$02
    dc.b $7D,$A3,$8F,$4A,$05,$83,$C8,$91
    dc.b $08,$36,$E6,$E6,$A5,$76,$2C,$26
    dc.b $28,$DD,$A4,$5B,$86,$D5,$29,$DA
    dc.b $BA,$75,$F0,$DF,$A0,$01,$20,$0B

;=========================================

datatbl:
    dc.l data1
    dc.l data2
    dc.l data3
    dc.l data4

;=========================================
