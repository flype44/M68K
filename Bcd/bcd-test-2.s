;===========================
; BCD test
; S C:\Users\FORMATION\Desktop\output12.txt 4026ded2 30
; 4026ff4c
;===========================

assert_zero EQU $00D0000C ; magical register

;===========================

start:
    lea     values,a0
    lea     buffer,a1
    lea     precalc,a2
    clr.l   d0
    clr.l   d1
    clr.l   d2
    clr.l   d4
    clr.l   d5
unpack:
    move.w  (a0)+,d0          ; store packed number in d0
    beq     exit              ; exit if 0
    clr.l   d1                ; clear word in d1
    moveq   #3,d2             ; four bcd digits
unpack1:
    move.b  d0,d1             ; extend bcd digit to a byte
    andi.b  #$0f,d1           ; store unpacked digit
    ror.l   #8,d1             ; 
    lsr.w   #4,d0             ; 
    dbra    d2,unpack1        ; next bcd digit
    move.l  d1,(a1)+          ; save unpacked number
mytest:
    abcd    d4,d1             ; src+dest+X->dest
    move    ccr,(a1)+         ; save bcd ccr
    move    d1,(a1)+          ; save bcd result
    move.l  d1,d4             ; save old unpacked number
selftest:
    move.l  (a2)+,d5          ; test number
    sub.l   -8(a1),d5
    move.l  d5,assert_zero
    move.w  (a2)+,d5          ; test ccr
    sub.w   -4(a1),d5
    move.l  d5,assert_zero
    move.w  (a2)+,d5          ; test result
    sub.w   -2(a1),d5
    move.l  d5,assert_zero
next:
    bra     unpack            ; next packed number
exit:
    stop    #-1


;===========================

values:
    dc.w 1,248,1235,100,512,3,320,64
    dc.w 197,219,1,99,1997,61,10,17
    dc.w 34,2410,100,4,41,55,833,14
    dc.w 0

buffer: ds.l 24*2 ; values count * 2 

precalc:
    ; number.L, ccr.W, result.W
    dc.w $0000,$0001,$0000,$0001
    dc.w $0000,$0F08,$0000,$0F09
    dc.w $0004,$0D03,$0000,$0D12
    dc.w $0000,$0604,$0000,$0616
    dc.w $0002,$0000,$0000,$0016
    dc.w $0000,$0003,$0000,$0019
    dc.w $0001,$0400,$0000,$0419
    dc.w $0000,$0400,$0000,$0419
    dc.w $0000,$0C05,$0000,$0C24
    dc.w $0000,$0D0B,$0000,$0D35
    dc.w $0000,$0001,$0000,$0036
    dc.w $0000,$0603,$0000,$0639
    dc.w $0007,$0C0D,$0000,$0C4C
    dc.w $0000,$030D,$0000,$035F
    dc.w $0000,$000A,$0000,$006F
    dc.w $0000,$0101,$0000,$0176
    dc.w $0000,$0202,$0000,$0278
    dc.w $0009,$060A,$0008,$0688
    dc.w $0000,$0604,$0008,$0692
    dc.w $0000,$0004,$0008,$0096
    dc.w $0000,$0209,$0011,$0205
    dc.w $0000,$0307,$0000,$0312
    dc.w $0003,$0401,$0000,$0413
    dc.w $0000,$000E,$0000,$0027

;===========================
