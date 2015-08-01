;==================================================================================
; ASM-Testcase, flype, 2015
; Copy arrays (bytes/words/longs)
;==================================================================================

assert_zero EQU $00D0000C

;==================================================================================
;   DC.L     0
;   DC.L     START
;   SECTION  .fastram
;==================================================================================
          
START     BSR    INIT           ; 
LOOP      MOVE.B (A0)+,(A1)+    ; Copy bytes
          MOVE.W (A2)+,(A3)+    ; Copy words
          MOVE.L (A4)+,(A5)+    ; Copy longs
          DBF    D0,LOOP        ; Continue

;==================================================================================

START2    BSR    INIT           ; 
LOOP2     MOVE.B (A0)+,D1       ; Check bytes array
          SUB.B  (A1)+,D1       ; 
          MOVE.B D1,assert_zero ; 
          MOVE.W (A2)+,D2       ; Check words array
          SUB.W  (A3)+,D2       ; 
          MOVE.W D2,assert_zero ; 
          MOVE.L (A4)+,D3       ; Check longs array
          SUB.L  (A5)+,D3       ; 
          MOVE.L D3,assert_zero ; 
          DBF    D0,LOOP2       ; Continue

;==================================================================================

EXIT      STOP   #-1            ; Stop execution

;==================================================================================

INIT      LEA    UBYTES1,A0     ; Bytes arrays
          LEA    UBYTES2,A1     ; 
          LEA    UWORDS1,A2     ; Words arrays
          LEA    UWORDS2,A3     ; 
          LEA    ULONGS1,A4     ; Longs arrays
          LEA    ULONGS2,A5     ; 
          MOVEQ  #NBVAL,D0      ; Number of values in arrays
          RTS

;==================================================================================

NBVAL     EQU 16

UBYTES1:  DC.B $00,$11,$22,$33
          DC.B $44,$55,$66,$77
          DC.B $88,$99,$AA,$BB
          DC.B $CC,$DD,$EE,$FF
UBYTES2:  DS.B NBVAL

UWORDS1:  DC.W $0000,$1111,$2222,$3333
          DC.W $4444,$5555,$6666,$7777
          DC.W $8888,$9999,$AAAA,$BBBB
          DC.W $CCCC,$DDDD,$EEEE,$FFFF
UWORDS2:  DS.W NBVAL

ULONGS1:  DC.L $00000000,$11111111,$22222222,$33333333
          DC.L $44444444,$55555555,$66666666,$77777777
          DC.L $88888888,$99999999,$AAAAAAAA,$BBBBBBBB
          DC.L $CCCCCCCC,$DDDDDDDD,$EEEEEEEE,$FFFFFFFF
ULONGS2:  DS.L NBVAL

;==================================================================================

