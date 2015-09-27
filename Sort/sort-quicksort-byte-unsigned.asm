;==================================================================================
; Motorola 68K - ASM test
; QuickSort BYTE UNSIGNED testcase
; Based on tutorial here :
; http://stackoverflow.com/questions/1367452/sort-numbers-using-easy68k
;==================================================================================

assert_zero EQU $00D0000C

min equ 0   ; min and max indexes of main table to be sorted
max equ $3F ; $3F = MEMORY window size

;==================================================================================
; DC.L     0
; DC.L     START
; SECTION  .fastram
;==================================================================================

START:
    LEA     $7FFE,A7                ; Stack pointer init, 
    ORI.W   #$700,SR                ; IT masking and full speed mode setting
    ANDI.W  #$7FFF,SR               ; 
    LEA     $2000,A0                ; A0 holds start address of table
    MOVE.L  #MIN,D0                 ; D0 holds min index
    MOVE.L  #MAX,D1                 ; D1 holds max index
    BSR     QSORT                   ; QSORT subroutine call
    STOP    #-1                     ; End of program

;==================================================================================

QSORT:
    MOVE.W  D0,-(A7)                ; Save min and max indexes in the stack
    MOVE.W  D1,-(A7)                ; 
    MOVE.W  D1,D2                   ; D2 = "middle" index = D0 + ((D1 - D0) / 2) = "pivot" index
    SUB.W   D0,D2                   ; Why is this formula better than (D1+D0)/2 ?
    LSR.W   #1,D2                   ; 
    ADD.W   D0,D2                   ; 
    MOVE.B  0(A0,D2.W),D3           ; D3 = table "pivot" element

NEXT1:
    CMP.B   0(A0,D0.W),D3           ; Search for table 1st element > pivot, 
    BLS     NEXT2                   ; starting from table top
    ADDQ.W  #1,D0                   ; 
    BRA     NEXT1                   ; 

NEXT2:
    MOVE.B  0(A0,D1.W),D4           ; Search for table 1st element < pivot, 
    CMP.B   D3,D4                   ; starting from table bottom
    BLS     SWAP                    ; 
    SUBQ.W  #1,D1                   ; 
    BRA     NEXT2                   ; 

SWAP:
    CMP.W   D1,D0                   ; 
    BGT     SWAP2                   ; 
    MOVE.B  0(A0,D0.W),D5           ; Swap elements through D5   
    MOVE.B  0(A0,D1.W),0(A0,D0.W)   ; 
    MOVE.B  D5,0(A0,D1.W)           ; 
    ADDQ.W  #1,D0                   ; Refresh indexes
    SUBQ.W  #1,D1                   ; 
    CMP.W   D1,D0                   ; 
    BGT     SWAP2                   ; 
    BRA     NEXT1                   ; 

SWAP2:
    CMP.W   2(A7),D1                ; 
    BLE     NEXT3                   ; 
    MOVE.W  2(A7),D6                ; Save current registers in stack      
    MOVE.W  D0,-(A7)                ; 
    MOVE.W  D1,-(A7)                ; 
    MOVE.W  D6,D0                   ; 
    BSR     QSORT                   ; Sort sub-table
    MOVE.W  (A7)+,D1                ; Get current registers from stack
    MOVE.W  (A7)+,D0

NEXT3:
    CMP.W   (A7),D0                 ; 
    BGE     EXIT                    ; 
    MOVE.W  (A7),D6                 ; Save current registers in stack     
    MOVE.W  D0,-(A7)                ; 
    MOVE.W  D1,-(A7)                ; 
    MOVE.W  D6,D1                   ; 
    BSR     QSORT                   ; Sort sub-table, recursive call with new indexes
    MOVE.W  (A7)+,D1                ; Get current registers from stack
    MOVE.W  (A7)+,D0                ; 

EXIT:
    ADDA.L  #4,A7                   ; Remove indexes from stack
    RTS

;==================================================================================

VALUES:
    DC.B    $EE,$11,$99,$22,$33,$BB,$44,$88
    DC.B    $77,$66,$DD,$CC,$AA,$55,$FF,$00
VALUESLEN:
    DC.L    *-VALUES

;==================================================================================

PRECALC:
    DC.B    $00,$11,$22,$33,$44,$55,$66,$77
    DC.B    $88,$99,$AA,$BB,$CC,$DD,$EE,$FF
PRECALCLEN:
    DC.L    *-PRECALC

;==================================================================================
