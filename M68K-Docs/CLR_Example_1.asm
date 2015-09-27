; M68K
; CLR Dn
; Example 1

START:	MOVE.L	#%11223344,D0 ; 11223344 
		CLR.B	D0            ; 112233-- 
		CLR.W	D0            ; 1122---- 
		CLR.L	D0            ; -------- 
EXIT:	STOP	#-1           ; 00000000
