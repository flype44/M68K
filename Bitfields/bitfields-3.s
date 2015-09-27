;===================================================================
; ASM Test : Bitfields
; S C:\Users\FORMATION\Desktop\output12.txt 4026DCEA 3C
;===================================================================

assert_zero EQU $00D0000C       ; magical register

size = 60

;===================================================================
; Main
;===================================================================

Start:

    clr.l  d0
    clr.l  d1
    
    lea    values,a0
    lea    calcs,a1
    lea    precalcs,a2
    
    move.w #((size/6)-1),d7

.MainLoop
    
    ; Test #1 : Dn{0:16}

    move.l (a0)+,d0         ; read value
    bfffo  d0{0:16},d1      ; bfffo
    move.b d1,(a1)+         ; store value
    sub.b  (a2)+,d1         ; test value
    move.l d1,assert_zero   ; raise error if d1 != 0
    
    ; Test #2 : Dn{2:31}
    
    move.l (a0)+,d0         ; 
    bfffo  d0{2:31},d1      ; 
    move.b d1,(a1)+         ; 
    sub.b  (a2)+,d1         ; 
    move.l d1,assert_zero   ; 

    ; Test #3 : Dn{9:22}
    
    move.l (a0)+,d0         ; 
    bfffo  d0{9:22},d1      ; 
    move.b d1,(a1)+         ; 
    sub.b  (a2)+,d1         ; 
    move.l d1,assert_zero   ; 

    ; Test #4 : Dn{16:16}
    
    move.l (a0)+,d0         ; 
    bfffo  d0{16:16},d1     ; 
    move.b d1,(a1)+         ; 
    sub.b  (a2)+,d1         ; 
    move.l d1,assert_zero   ; 

    ; Test #5 : Dn{30:32}
    
    move.l (a0)+,d0         ; 
    bfffo  d0{30:32},d1     ; 
    move.b d1,(a1)+         ; 
    sub.b  (a2)+,d1         ; 
    move.l d1,assert_zero   ; 

    ; Test #6 : Dn{30:32}
    
    move.l (a0)+,d0         ; 
    bfffo  d0{30:32},d1     ; 
    move.b d1,(a1)+         ; 
    sub.b  (a2)+,d1         ; 
    move.l d1,assert_zero   ; 

    ; Continue ?

    dbf    d7,.MainLoop
    stop   #-1

;===================================================================
; Data Section
;===================================================================

values:
    dc.l $00F79C9A,$EAF02A00,$180F8E02,$5450C3F5,$AD335F61,$F1065E68
    dc.l $0000CC4D,$A1360000,$34F0F843,$AB000000,$5FFB9D00,$D545E228
    dc.l $000000F2,$4D000000,$FC9F5DA9,$F3C9D12B,$9AE00F6B,$3B96CE3A
    dc.l $001C84AB,$52824700,$6A000000,$119FD257,$3333610B,$E50000AC
    dc.l $00004E52,$51E60000,$A8EA5C74,$000016E8,$6000FBB5,$E7311515
    dc.l $0000009D,$F7000000,$525EB51D,$E0759795,$E6504A39,$69B3682F
    dc.l $00B9CBD9,$24B28E00,$B6CFB1E5,$22223C32,$00000080,$1700060E
    dc.l $00002A5A,$7F800000,$7D4F2353,$44CB6D6A,$8D1D0426,$D575C6EF
    dc.l $000000F5,$49000000,$0000BBBA,$CC92257A,$AAAAAA7D,$BAD80DC8
    dc.l $5A9576AC,$EDE95334,$A2C10000,$DD5B9D02,$AAAAB7CB,$00000000

calcs:
    ds.b size

precalcs:
    dc.b $08,$02,$0C,$10,$1F,$20
    dc.b $10,$02,$09,$20,$21,$20
    dc.b $10,$04,$0B,$10,$1E,$1E
    dc.b $0B,$03,$1F,$10,$1E,$20
    dc.b $10,$03,$09,$13,$1F,$1F
    dc.b $10,$02,$09,$10,$1F,$1E
    dc.b $08,$02,$09,$12,$38,$1E
    dc.b $10,$02,$09,$11,$1E,$1E
    dc.b $10,$04,$10,$12,$1F,$20
    dc.b $01,$02,$09,$10,$1E,$3E

;===================================================================
; End of program
;===================================================================
