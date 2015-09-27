;==================================================================================
; Motorola 68K - ASM test case
; Count occurences of chars in a given string.
;==================================================================================

assert_zero EQU $00D0000C

;==================================================================================
; dc.l 0
; dc.l start
; section .fastram
;==================================================================================

start:
   clr.l  d0               ; init d0
   clr.l  d1               ; init d1
   move.b size,d0          ; init loop
   lea    buf,a0           ; store buffer pointer
   lea    occ,a1           ; store occurences array pointer
   loop   move.b (a0)+,d1  ; read current value from buffer
   subi.b #97,d1           ; transform to index in the occurences array
   addq.b #1,(d1,a1)       ; increment occurences count of the value
skip:
   dbf    d0,loop          ; continue

;==================================================================================

selftest:
   clr.l  d0
   move.b #26,d0           ; init loop
   lea    occ,a0           ; store buffer pointer
   lea    precalc,a1       ; store occurences array pointer
selfloop:
   move.b (a0)+,d1         ; read value from occurences array
   sub.b  (a1)+,d1         ; substract value with precalc value
   move.b d1,assert_zero   ; should be 0, otherwise stop
   dbf    d0,selfloop      ; continue

;==================================================================================

exit:
   stop #-1                ; stop

;==================================================================================

buf:
   dc.b 'this program will search for the occurrences of each chars in a given string'
size:
   dc.b *-buf
occ:
   ds.b 26

precalc:
   dc.b 5,0,5,0,5,2,3,4,5,0,0,2,1,4,4,1,0,8,4,3,1,1,1,0,0,0
       ;a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z

;==================================================================================
