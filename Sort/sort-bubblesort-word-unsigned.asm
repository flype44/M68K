;==================================================================================
; ASM-Test case, flype, 2015
; BubbleSort WORD UNSIGNED testcase
; Based on PROGRAM 4 tutorial here :
; http://users.encs.concordia.ca/~tahar/coen311/coen311.mc68000-samples.html
;==================================================================================

assert_zero EQU $00D0000C

;==================================================================================

;       DC.L     0
;       DC.L     START
;       SECTION  .fastram

;==================================================================================

START:
        LEA      VALUES,A0       ; Store VALUES array address
        CLR.L    D0              ; Get number of items in array
        MOVE.W   VALUESLEN,D0    ; 
        DIVS     #2,D0           ; 
LOOP2:
        MOVE.L   A0,A2           ; BubbleSort start here
        MOVE.L   A0,A1           ; 
        ADD.L    #2,A2           ; 
        MOVE.W   D0,D1           ; 
        SUBI.W   #1,D1           ; 
LOOP1:
        CMP.W    (A1)+,(A2)+     ; 
        BHS      SKIP            ; 
        MOVE.W   (A1),D3         ; Swap values
        MOVE.W   -2(A1),(A1)     ; 
        MOVE.W   D3,-2(A1)       ; 
SKIP:
        DBRA     D1,LOOP1        ; 
        SUBI.W   #1,D0           ; 
        BGT      LOOP2           ; 

;==================================================================================

SELEFTEST:
        LEA     VALUES,A0       ; Store VALUES array address
        LEA     PRECALC,A1      ; Store PRECALC array address
        CLR.L   D0              ; Get number of items in array
        MOVE.W  VALUESLEN,D0    ; 
        DIVS    #2,D0           ; 
SELFLOOP:
        MOVE.W  (A0)+,D1        ; Read value from VALUES array
        SUB.W   (A1)+,D1        ; Substract value with PRECALC value
        MOVE.W  D1,assert_zero  ; If equals, D1 should be 0, otherwise EXIT
        DBF     D0,SELFLOOP     ; Continue

;==================================================================================

EXIT:   STOP    #-1             ; Stop execution

;==================================================================================

VALUES:
    DC.W    $EEEE,$1111,$9999,$2222,$3333,$BBBB,$4444,$8888
    DC.W    $7777,$6666,$AAAA,$CCCC,$DDDD,$5555,$FFFF,$0000
VALUESLEN:
    DC.W    *-VALUES

;==================================================================================

PRECALC:
    DC.W    $0000,$1111,$2222,$3333,$4444,$5555,$6666,$7777
    DC.W    $8888,$9999,$AAAA,$BBBB,$CCCC,$DDDD,$EEEE,$FFFF
PRECALCLEN:
    DC.W    *-PRECALC

;==================================================================================
