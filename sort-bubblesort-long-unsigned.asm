;==================================================================================
; Motorola 68K - ASM test
; BubbleSort LONG UNSIGNED
;==================================================================================

assert_zero EQU $00D0000C

;==================================================================================
;       DC.L     0
;       DC.L     START
;       SECTION  .fastram
;==================================================================================

START:
        LEA      VALUES,A0       ; Store VALUES array address
        MOVE.L   VALUESLEN,D0    ; Get number of items in array
        DIVS     #4,D0           ; LONG values in array so divide by 4
        SUBI.L   #1,D0           ; -1
LOOP2:
        MOVE.L   A0,A2           ; BubbleSort start here
        MOVE.L   A0,A1           ; 
        ADDA.L   #4,A2           ; 
        MOVE.L   D0,D1           ; 
        SUBI.L   #1,D1           ; 
LOOP1:
        CMPM.L   (A1)+,(A2)+     ; 
        BHS      SKIP            ; 
        MOVE.L   (A1),D3         ; Swap values
        MOVE.L   -4(A1),(A1)     ; 
        MOVE.L   D3,-4(A1)       ; 
SKIP:
        DBRA     D1,LOOP1        ; 
        SUBI.L   #1,D0           ; 
        BGT      LOOP2           ; 

;==================================================================================

SELFTEST:
        LEA      VALUES,A0       ; Store VALUES array address
        LEA      PRECALC,A1      ; Store PRECALC array address
        MOVE.L   VALUESLEN,D0    ; Get number of items in array
        DIVS     #4,D0           ; LONG values in array so divide by 4
        SUBI.L   #1,D0           ; -1
SELFLOOP:
        MOVE.L   (A0)+,D1        ; Read value from VALUES array
        SUB.L    (A1)+,D1        ; Substract value with PRECALC value
        MOVE.L   D1,assert_zero  ; If equals, D1 should be 0, otherwise EXIT
        DBF      D0,SELFLOOP     ; Continue

;==================================================================================

EXIT:   STOP    #-1              ; Stop execution

;==================================================================================

VALUES:
    DC.L    $EEEEEEEE,$11111111,$99999999,$22222222
    DC.L    $33333333,$BBBBBBBB,$44444444,$88888888
    DC.L    $77777777,$66666666,$DDDDDDDD,$CCCCCCCC
    DC.L    $AAAAAAAA,$55555555,$FFFFFFFF,$00000000
VALUESLEN:
    DC.L    *-VALUES

;==================================================================================

PRECALC:
    DC.L    $00000000,$11111111,$22222222,$33333333
    DC.L    $44444444,$55555555,$66666666,$77777777
    DC.L    $88888888,$99999999,$AAAAAAAA,$BBBBBBBB
    DC.L    $CCCCCCCC,$DDDDDDDD,$EEEEEEEE,$FFFFFFFF
PRECALCLEN:
    DC.L    *-PRECALC

;==================================================================================
