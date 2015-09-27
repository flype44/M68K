;=================================================
; RLE, Run-Length Decoding (v1.0)
; It is used in IFF-ILBM body compression.
;=================================================
; 
; Packed:   12W1B12W3B24W1B14W
; Unpacked: WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW
; 

;=================================================
; Constants
;=================================================

assert_zero EQU $00D0000C       ; magical register

;=================================================
; Entry Point
;=================================================

Start:
    
    lea     BufSrc,a0           ; unpack buffer
    lea     BufDst,a1           ; 
    jsr     RLEDecode           ; 

    lea     BufDst,a0           ; check result
    lea     BufPre,a1           ; 
    jsr     SelfTest            ; 

    stop    #-1                 ; stop execution

;=================================================
; SelfTest SubRoutine
; A0 = Calculated string
; A1 = Precalculated string
;=================================================

SelfTest:
    move.b  (a0)+,d0            ; read calculated char
    beq     .SelfTestExit       ; exit if null-char
    sub.b   (a1)+,d0            ; compare with precalculated char
    move.l  d0,assert_zero      ; raise error if D0 != 0
    bra     SelfTest            ; continue

.SelfTestExit:
    rts                         ; exit subroutine

;=================================================
; RLE Decode SubRoutine
; A0 = source buffer
; A1 = destination buffer
;=================================================

RLEDecode:
    clr.l   d0                  ; init registers
    clr.l   d1                  ; 
    move.b  #67,d0              ; destination size
.RLEDecodeLoop
    move.b  (a0)+,d1            ; read n
    cmpi.b  #80,d1
    bge     .RLEDecode2         ; 0 <= n <= 127 ?
.RLEDecode1:                    ; -1..-128
    move.b  (a0),(a1)+          ; 
    dbf     d1,.RLEDecode1      ; 
    bra     .RLEDecodeNext      ; 
.RLEDecode2:                    ; 
    cmpi.b  #80,d1              ; n = -128 ?
    beq     .RLEDecodeNext      ; if so, continue
    bset    #7,d1               ; n = -n
    addi.b  #1,d1               ; n = n + 1
.RLEDecode3:                    ; 
    move.b  (a0)+,(a1)+         ; 
    dbf     d1,.RLEDecode3      ; continue
.RLEDecodeNext:
    dbf     d0,.RLEDecodeLoop   ; continue
.RLEDecodeExit:
    rts                         ; exit subroutine

;=================================================
; Data Section
;=================================================
; 12W1B12W3B24W1B14W
BufSrc: dc.b 12,'W',1,'B',12,'W',3,'B',24,'W',1,'B',14,'W',0
BufDst: dc.b '___________________________________________________________________',0
BufPre: dc.b 'WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW',0

;=================================================
; End of program
;=================================================
