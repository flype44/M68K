
; vasmm68k_mot_os3 -Fbin -m68080 -no-opt sample.asm -o sample

; notes:
; TRANSi-Lo          : not implemented in VASM
; LOAD #$0123.w,d0   : not implemented in VASM (splat)
; PADDW -(B0),D0,E14 : not implemented in VASM (pre-decrement)

*	SECTION S0,CODE

MAIN:
	
	LOAD    d0,e10                    ; 000 reg
	LOAD    e8,e11                    ; 000 reg
	LOAD    e0,e12                    ; 001 reg
	LOAD    e16,e13                   ; 001 reg
	nop

	LOAD    (a0),e0                   ; 010 reg
	LOAD    (b0),e8                   ; 010 reg
	LOADi   (a0),e15                  ; 010 reg
	LOADi   (b0),e23                  ; 010 reg
	nop

	LOAD    (a1)+,d1                  ; 011 reg
	LOAD    (a3)+,d2                  ; 011 reg
	LOAD    (b1)+,e1                  ; 011 reg
	LOAD    (b3)+,e2                  ; 011 reg
	nop

	LOAD    -(a6),d1                  ; 100 reg
	LOAD    -(a7),d2                  ; 100 reg
	nop

.loop
.before

	LOAD     .before.w(a5),e20        ; 101 reg
	LOAD     .before.w(b5),e21        ; 101 reg
	LOAD    (.after.w,a5),e22         ; 101 reg
	LOAD    (.after.w,b5),e23         ; 101 reg
	nop

	LOAD    ($12.b,a2,d3.l*8),e18       ; 110 reg
	LOAD    ($1234.w,a2,d3.l*8),e18     ; 110 reg
	LOAD    ($12345678.l,a2,d3.l*8),e18 ; 110 reg

	LOAD    ($12.b,a0,d0.w*1),e18       ; 110 reg
	LOAD    ($12.b,a1,d1.w*2),e18       ; 110 reg
	LOAD    ($1234.w,a2,d2.w*4),e18     ; 110 reg
	LOAD    ($1234.w,a3,d3.w*8),e18     ; 110 reg
	LOAD    ($12345678.l,a4,d4.l*1),e18 ; 110 reg
	LOAD    ($12345678.l,a5,d5.l*2),e18 ; 110 reg
	LOAD    (.loop.l,a6,d6.l*4),e18     ; 110 reg
	LOAD    (.loop.l,a7,d7.l*8),e18     ; 110 reg
	nop

	LOAD    (.loop.l,b0,d0.w*1),e18   ; 110 reg
	LOAD    (.loop.l,b1,d1.w*2),e18   ; 110 reg
	LOAD    (.loop.l,b2,d2.w*4),e18   ; 110 reg
	LOAD    (.loop.l,b3,d3.w*8),e18   ; 110 reg
	LOAD    (.loop.l,b4,d4.l*1),e18   ; 110 reg
	LOAD    (.loop.l,b5,d5.l*2),e18   ; 110 reg
	LOAD    (.loop.l,b6,d6.l*4),e18   ; 110 reg
	LOAD    (.loop.l,b7,d7.l*8),e18   ; 110 reg
	nop

	LOAD    (.loop.l,a0,a0.w*1),e18   ; 110 reg
	LOAD    (.loop.l,a1,a1.w*2),e18   ; 110 reg
	LOAD    (.loop.l,a2,a2.w*4),e18   ; 110 reg
	LOAD    (.loop.l,a3,a3.w*8),e18   ; 110 reg
	LOAD    (.loop.l,a4,a4.l*1),e18   ; 110 reg
	LOAD    (.loop.l,a5,a5.l*2),e18   ; 110 reg
	LOAD    (.loop.l,a6,a6.l*4),e18   ; 110 reg
	LOAD    (.loop.l,a7,a7.l*8),e18   ; 110 reg
	nop
	
	LOAD    .loop.w,e14               ; 111 000
	LOAD    $0123.w,e15               ; 111 000
	nop
	
	LOAD    .loop.l,e16               ; 111 001
	LOAD    $01234567.l,e17           ; 111 001
	nop
	
	LOAD     .loop.w(pc),e17          ; 111 010
	LOAD    (.loop.w,pc),e18          ; 111 010
	nop

	LOAD     .loop.l(pc),e18          ; 111 011
	LOAD    (.loop.l,pc),e18          ; 111 011
	nop

	LOAD    (.loop.w,pc,d0),e17       ; 111 011
	LOAD    (.loop.l,pc,d0),e17       ; 111 011
	
	LOAD    (.loop.l,pc,d0.w*1),e18   ; 111 011
	LOAD    (.loop.l,pc,d1.w*2),e18   ; 111 011
	LOAD    (.loop.l,pc,d2.w*4),e18   ; 111 011
	LOAD    (.loop.l,pc,d3.w*8),e18   ; 111 011
	LOAD    (.loop.l,pc,d4.l*1),e18   ; 111 011
	LOAD    (.loop.l,pc,d5.l*2),e18   ; 111 011
	LOAD    (.loop.l,pc,d6.l*4),e18   ; 111 011
	LOAD    (.loop.l,pc,d7.l*8),e18   ; 111 011
	nop
	
	; LOAD  #$1234.w,d0               ; 111 100
	; LOAD  #$5678.w,e23              ; 111 100
	;        -------A-DMODREG  ----REGD--------
	dc.w    %1111111100111100,%0000000000000001,$1234
	dc.w    %1111111101111100,%0000111100000001,$5678
	nop
	
	LOAD    #$0123,d0                 ; 111 100
	LOAD    #$01234567,d1             ; 111 100
	LOAD    #$0123456789ab,d2         ; 111 100
	LOAD    #$0123456789abcdef,d3     ; 111 100
	nop

.after
	moveq.l #0,d0
	RTS
	
	nop
	nop
	nop
	nop
buffer:
	nop
	nop
	nop
	nop

	END
