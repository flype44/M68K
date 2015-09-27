;=================================================
; RLE, Run-Length Encoding and Decoding
; It is used, for example, 
; in IFF-ILBM Body compression.
;=================================================

MAIN:   LEA     DATA,A0           ; RLEEncode(DATA,BUFENC)
        LEA     BUFENC,A1         ; 
        JSR     RLEEncode         ; 
        LEA     BUFENC,A0         ; RLEDecode(BUFENC,BUFDEC)
        LEA     BUFDEC,A1         ; 
        JSR     RLEDecode         ; 
RETURN: STOP    #-1               ; Stop execution

;=================================================
; RLE Encode SubRoutine
; A0 = Source buffer
; A1 = Destination buffer
;=================================================

RLEEncode:
        MOVEM.L D0-D1/A0-A1,-(SP) ; Save registers state
.LOOP1  CLR.W   D1                ; Counter
.LOOP2: MOVE.B  (A0)+,D0          ; Read byte in D0
        BEQ     .EXIT             ; If Null byte then Exit
        ADDI.B  #1,D1             ; Increment counter
        CMP.B   (A0),D0           ; Compare next byte with D0
        BEQ     .LOOP2            ; While next byte = D0
        MOVE.B  D1,(A1)+          ; Write n
        MOVE.B  D0,(A1)+          ; Write byte
        BRA     .LOOP1            ; Continue
.EXIT:  MOVEM.L (SP)+,D0-D1/A0-A1 ; Restore registers state
        RTS                       ; Exit SubRoutine

;=================================================
; RLE Decode SubRoutine
; A0 = Source buffer
; A1 = Destination buffer
;=================================================

RLEDecode:
        MOVEM.L D0-D1/A0-A1,-(SP) ; Save registers state
.LOOP1: CLR.W   D0                ; Clear n
        MOVE.B  (A0)+,D0          ; Read n
        BEQ     .EXIT             ; If n=0 then Exit
        SUBI.B  #1,D0             ; Loop counter - 1
.LOOP2: MOVE.B  (A0),(A1)+        ; Copy byte
        DBF     D0,.LOOP2         ; Until D0 = 0
        ADDQ    #1,A0             ; Next n
        BRA     .LOOP1            ; Continue
.EXIT:  MOVEM.L (SP)+,D0-D1/A0-A1 ; Restore registers state
        RTS                       ; Exit SubRoutine

;=================================================
; Data Section
;=================================================

; Data to encode :
DATA:   DC.B 'RRRRRGGGGBBGGGGGGWBBBRRRRRBGG',0

; RLE Encoded Data :
BUFENC: DS.B 50 ; 5R4G2B6G1W3B5R1B2G

; RLE Decoded Data :
BUFDEC: DS.B 50 ; RRRRRGGGGBBGGGGGGWBBBRRRRRBGG

;=================================================
; End of program
;=================================================
