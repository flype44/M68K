;===========================
; Bcc test
; S C:\Users\FORMATION\Desktop\output12.txt 4026f21a 40
;===========================

assert_zero EQU $00D0000C ; magical register

size equ 16

;===========================

start:
    lea     datas,a0
    lea     precalc,a1
    move.l  #4,d7
loop:
    clr.l   d0
    clr.l   d1
    move.l  (a0)+,d0
    bsr     branch1
    bsr     branch2
    bsr     branch3
    bsr     branch4
continue:
    add.l   d0,d1
selftest:
    ;move.l  d1,(a1)+
    sub.l   (a1)+,d1
    move.l  d1,assert_zero
    dbf     d7,loop
    bra     exit
    nop
exit:
    stop    #-1

;===========================

branch1:
    rol.l   d7,d0
    bcc     goto_cc
    bcs     goto_cs
    beq     goto_eq
    bge     goto_ge
    rts

branch2:
    ror.l   d7,d1
    bls     goto_ls
    blt     goto_lt
    bmi     goto_mi
    rts

branch3:
    ror.l   d7,d1
    bne     goto_ne
    bpl     goto_pl
    bvc     goto_vc
    bvs     goto_vs
    rts
    
branch4:
    rol.l   d7,d0
    bgt     goto_gt
    bhi     goto_hi
    ble     goto_le
    rts

;===========================

goto_cc:
    addi.l  #$11111111,d0
    rts
goto_cs:
    subi.l  #$22222222,d1
    rts
goto_eq:
    ror.l   #$8,d0
    rts
goto_ge:
    rol.l   #$1,d1
    rts
goto_gt:
    lsr.l   #$2,d0
    rts
goto_hi:
    lsl.l   #$3,d1
    rts
goto_le:
    asr.l   #$4,d0
    rts
goto_ls:
    asl.l   #$5,d1
    rts
goto_lt:
    roxl.l  #$6,d0
    rts
goto_mi:
    roxr.l  #$7,d1
    rts
goto_ne:
    mulu.l  #$BBBBBBBB,d0
    rts
goto_pl:
    divu.l  #$CCCCCCCC,d1
    rts
goto_vc:
    muls.l  #$DDDDDDDD,d0
    rts
goto_vs:
    mulu.l  #$EEEEEEEE,d1
    rts

;===========================

datas:
    dc.l $76,$56,$7A,$26
    dc.l $59,$6B,$D6,$9C
    dc.l $48,$64,$E6,$0D
    dc.l $5D,$86,$42,$E7

precalc:
    dc.l $044461C4,$88889E08,$111112F9,$088888AE
    dc.l $0444445A,$851A15BF,$000000E0,$2F5B7C07
    dc.l $00000052,$34C30550,$000000F0,$00000017
    dc.l $00000053,$00000090,$0000004C,$000000F1

;===========================
