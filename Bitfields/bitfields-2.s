    opt     bit
START   org     $1000
        move.l  #$AAAAAAAA,D0
        move.l  #1,D1
        move.l  #2,D2
        move.l   #$2000,D3
        lea     data1,A1
 
        bfchg   D0{D1:D2}
        bfchg  (A1){8:D2}
        bfchg  (1,A1){8:D2}
        bfchg  (1,A1,D1){8:D2}
        bfchg  $2000{8:D2}
        bfchg  $2000.L{8:D2}
*        bfchg  $1000(PC){8:D2}      ; invalid addressing mode
*        bfchg  $1000(PC,D4){8:D2}   ; invalid addressing mode
 
        bfclr   D0{D1:D2}
        bfclr  (A1){8:D2}
        bfclr  (1,A1){8:D2}
        bfclr  (1,A1,D1){8:D2}
        bfclr  $2003{8:D2}
        bfclr  $2004.L{8:D2}
*        bfclr  $1000(PC){8:D2}      ; invalid addressing mode
*        bfclr  $1000(PC,D4){8:D2}   ; invalid addressing mode
 
        bfexts  D0{0:D2},D4
        bfexts  (A1){1:D2},D4
        bfexts  (1,A1){2:D2},D4
        bfexts  (1,A1,D1){3:D2},D4
        bfexts  $2000{4:D2},D4
        bfexts  $2000.L{5:D2},D4
        bfexts  $2000(PC){6:D2},D4
        bfexts  *+2(PC,D3){7:D2},D4
 
        bfextu  D0{0:D2},D4
        bfextu  (A1){1:D2},D4
        bfextu  (1,A1){2:D2},D4
        bfextu  (1,A1,D1){3:D2},D4
        bfextu  $2000{4:D2},D4
        bfextu  $2000.L{5:D2},D4
        bfextu  $2000(PC){6:D2},D4
        bfextu  *+2(PC,D3){7:D2},D4
 
        bfffo  D0{0:D2},D4
        bfffo  (A1){1:D2},D4
        bfffo  (1,A1){2:D2},D4
        bfffo  (1,A1,D1){3:D2},D4
        bfffo  $2000{4:D2},D4
        bfffo  $2000.L{5:D2},D4
        bfffo  $2000(PC){6:D2},D4
        bfffo  *+2(PC,D4){7:D2},D4
 
      move.l   #-1,D4
        bfins  D4,D0{0:D2}
        bfins  D4,(A1){1:D2}
        bfins  D4,(1,A1){2:D2}
        bfins  D4,(1,A1,D1){3:D2}
        bfins  D4,$2000{4:D2}
        bfins  D4,$2000.L{5:D2}
*        bfins  D4,$1000(PC){6:D2}   ; invalid addressing mode
*        bfins  D4,*-2(PC,D4){7:D2}   ; invalid addressing mode
 
        bfset   D0{D1:D2}
        bfset  (A1){1:D2}
        bfset  (1,A1){2:D2}
        bfset  (1,A1,D1){3:D2}
        bfset  $2000{4:D2}
        bfset  $2000.L{5:D2}
*        bfset  $1000(PC){6:D2}      ; invalid addressing mode
*        bfset  *+5(PC,D4){7:D2}   ; invalid addressing mode
 
        bftst   data4{10:5}
        bftst   D0{D1:D2}
        bftst  (A1){0:D2}
        bftst  (1,A1){1:D2}
        bftst  (1,A1,D1){2:D2}
        bftst  $2000{3:D2}
        bftst  $2000.L{4:D2}
        bftst  $2000(PC){5:D2}
        bftst  *+2(PC,D4){6:D2}
       
       
        stop    #$2000
       
        org     $2000
data1   dc.l    $AAAAAAAA
data2   dc.l    $55555555
        dc.l    $55555555
data3   dc.l    $AAAAAAAA
        dc.l    $AAAAAAAA
data4   dc.l    $00800000
        end     START