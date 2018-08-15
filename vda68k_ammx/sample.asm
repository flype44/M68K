
; vasmm68k_mot_os3 -Fbin -m68080 -no-opt sample.asm -o sample

; notes:
; TRANSi-Lo          : not implemented in VASM
; LOAD #$0123.w,d0   : not implemented in VASM (splat)
; PADDW -(B0),D0,E14 : not implemented in VASM (pre-decrement)

*	SECTION S0,CODE

MAIN:
	
	moveq.l #1,d0
	nop
	
	LOAD    (A0),E0
	;        -------ABDMODREG  ----REGD--------
	dc.w    %1111111000010000,%0000100000000001
		
	C2P     E0,E1
	;        -------ABDMODREG  ----REGD--------
	dc.w    %1111111000001000,%0000100100101000
		
	C2P     E1,E0
	;        -------ABDMODREG  ----REGD--------
	dc.w    %1111111000001001,%0000100000101000
		
	STORE   E0,(A1)
	;        -------ABDMODREG  REGB------------
	dc.w    %1111111000010001,%1000000000000100
	nop

	LOAD    (a0),e0
	LOAD    (b0),e8
	LOADi   (b0),e15
	LOADi   (b0),e23
	nop
	
	STORE   e0,(a0)
	STORE   e8,(a0)
	STOREi  e15,(b0)
	STOREi  e23,(b0)
	nop
	
	TRANSLo e0-e3,e4:e5
	TRANSHi e0-e3,e4:e5
	TRANSLo e4-e7,e2:e3
	TRANSHi e4-e7,e2:e3
	TRANSLo e20-e23,e4:e5
	TRANSHi e20-e23,e4:e5
	nop

	moveq   #9,d7
.loop
	PADDW   (A0),E1,E2
	PADDW   (B0),E8,E16
	PADDW   (B0)+,D0,E14
	PADDW   (B0),D5,E23
	PADDW   E0,E1,E2
	PSUBW   E0,E1,E2
	dbf     d7,.loop
	nop
	
	VPERM   #$45cd67ef,e7,e6,e9
	VPERM   #$45cd67ef,e20,e21,e22
	nop
	
	LOAD    $0123.w,e10
	LOAD    $01234567.l,e11
	nop

	LOAD    buffer.w,e12
	LOAD    buffer.l,e13
	nop

	LOAD    buffer.w(pc),e14
	LOAD    buffer.l(pc),e14
	nop

	LOAD    .loop.w,e15
	LOAD    .loop.l,e16
	nop

	LOAD    .loop.w(a5),e17
	LOAD    .loop.w(b5),e18
	nop

	LOAD    .loop.l(a5),e17
	LOAD    .loop.l(b5),e18
	nop

	LOAD    (.loop.l,a0,d0.w*1),e18
	LOAD    (.loop.l,a1,d1.w*2),e18
	LOAD    (.loop.l,a2,d2.w*4),e18
	LOAD    (.loop.l,a3,d3.w*8),e18
	LOAD    (.loop.l,a4,d4.l*1),e18
	LOAD    (.loop.l,a5,d5.l*2),e18
	LOAD    (.loop.l,a6,d6.l*4),e18
	LOAD    (.loop.l,a7,d7.l*8),e18

	LOAD    (.loop.l,b0,d0.w*1),e18
	LOAD    (.loop.l,b1,d1.w*2),e18
	LOAD    (.loop.l,b2,d2.w*4),e18
	LOAD    (.loop.l,b3,d3.w*8),e18
	LOAD    (.loop.l,b4,d4.l*1),e18
	LOAD    (.loop.l,b5,d5.l*2),e18
	LOAD    (.loop.l,b6,d6.l*4),e18
	LOAD    (.loop.l,b7,d7.l*8),e18
	nop

	LOAD    (.loop.l,a0,a0.w*1),e18
	LOAD    (.loop.l,a1,a1.w*2),e18
	LOAD    (.loop.l,a2,a2.w*4),e18
	LOAD    (.loop.l,a3,a3.w*8),e18
	LOAD    (.loop.l,a4,a4.l*1),e18
	LOAD    (.loop.l,a5,a5.l*2),e18
	LOAD    (.loop.l,a6,a6.l*4),e18
	LOAD    (.loop.l,a7,a7.l*8),e18

	LOAD    .loop.w(pc),e17
	LOAD    .loop.l(pc),e18
	nop

	LOAD    (.loop.w,pc),e17
	LOAD    (.loop.l,pc),e18
	nop
	
*	LOAD    (.loop.w,pc,d0),e17
*	LOAD    (.loop.l,pc,d0),e18
*	nop
	
	;        -------A-DMODREG  ----REGD--------
	dc.w    %1111111100111100,%0000000000000001 ; LOAD #$1234.w,d0
	dc.w    $1234
	dc.w    %1111111101111100,%0000111100000001 ; LOAD #$5678.w,e23
	dc.w    $5678
	nop
	
	LOAD    #$0123,d0
	LOAD    #$01234567,d1
	LOAD    #$0123456789ab,d2
	LOAD    #$0123456789abcdef,d3
	nop
	
	LOAD    (a0)+,d1
	LOAD    (a1)+,d2
	VPERM   #$018923ab,d1,d2,d3
	nop
	
	LOAD    (a0),d4
	moveq   #0,d5
	VPERM   #$f0f1f2f3,d4,d5,d6
	VPERM   #$f4f5f6f7,d4,d5,d6
	nop
	
	moveq.l #0,d0
	nop
	
	RTS
	
*	SECTION S1,DATA

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
