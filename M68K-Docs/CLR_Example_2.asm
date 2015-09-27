; M68K
; CLR (An)
; Example 2

START:	LEA		BUFFER,A0  ; 11223344 
		CLR.B	(A0)       ; --223344 
		CLR.W	(A0)       ; ----3344 
		CLR.L	(A0)       ; -------- 
EXIT:	STOP	#-1        ; 00000000
BUFFER: DC.L	$11223344  ; 
