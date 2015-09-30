;==============================================================================
; ASM Testcase
; flype, 2015-09-29
; load-ilbm.asm
;==============================================================================

;   DC.L    0
;   DC.L    START
    SECTION .FASTRAM

;==============================================================================
; CONSTANTS
;==============================================================================

; Assert register

ASSERT_ZERO EQU $00D0000C

; Error codes

ERROR_FORM EQU 1   ; Not a FORM chunk
ERROR_ILBM EQU 2   ; Not a ILBM chunk
ERROR_SIZE EQU 3   ; Incorrect or corrupted chunk size

; Chunk Names

ID_FORM EQU 'FORM' ; International File Format (IFF)
ID_ILBM EQU 'ILBM' ; Interleaved Bitmap
ID_BMHD EQU 'BMHD' ; BitmapHeader
ID_CMAP EQU 'CMAP' ; ColorMap
ID_CAMG EQU 'CAMG' ; ViewModes
ID_DPI  EQU 'DPI ' ; DPI
ID_BODY EQU 'BODY' ; Image data

; Struct BitmapHeader

BmWidth  EQU 0
BmHeight EQU 2
BmDepth  EQU 8
BmCompr  EQU 10

;==============================================================================
; MAIN PROGRAM
;==============================================================================

START:
	CLR.L   D0              ; FORM Name
	CLR.L   D1              ; Chunk name (4 bytes)
	CLR.L   D2              ; Chunk Size (in bytes)
	CLR.L   D6              ; Chunk counter
	CLR.L   D7              ; Error code
	LEA     PIC,A1          ; Load Picture in A1
GETFORM:
	CMPI.L  #ID_FORM,(A1)+  ; FORM ?
	BEQ     GETSIZE         ; If so, continue
	MOVE.L  #ERROR_FORM,D7  ; D7 = Error
	BRA     EXIT            ; Stop
GETSIZE:
	MOVE.L  (A1)+,D0        ; D0 = FORM Size
	SUB.L   #PICSZ-PIC-8,D0 ; If D0 = ( PICSIZE - PIC - 8 )
	BEQ     GETILBM         ; Then continue
	MOVE.L  #ERROR_SIZE,D7  ; D7 = Error
	BRA     EXIT            ; Stop
GETILBM:
	CMP.L   #ID_ILBM,(A1)+  ; ILBM ?
	BEQ     GETCHUNKS       ; If so, continue
	MOVE.L  #ERROR_ILBM,D7  ; D7 = Error
	BRA     EXIT            ; Stop
GETCHUNKS:
	MOVE.L  (A1)+,D1        ; Chunk Name
	MOVE.L  (A1)+,D0        ; Chunk Size
	CMPI.L  #ID_BMHD,D1     ; D1 = BHMD ?
	BEQ     GETBMHD         ; If so, parse BitmapHeader chunk
	CMPI.L  #ID_CMAP,D1     ; D1 = CMAP ?
	BEQ     GETCMAP         ; If so, parse ColorMap chunk
	CMPI.L  #ID_CAMG,D1     ; D1 = CAMG ?
	BEQ     GETCAMG         ; If so, parse ViewModes chunk
	CMPI.L  #ID_DPI,D1      ; D1 = DPI  ?
	BEQ     GETDPI          ; If so, parse DPI chunk
	CMPI.L  #ID_BODY,D1     ; D1 = BODY ?
	BEQ     GETBODY         ; If so, parse Body chunk
GETNEXT:
	ADDA.L  D0,A1           ; A1 + Chunk Size
	BRA     GETCHUNKS       ; Branch to Next chunk
GETBMHD:
	LEA     width,A2
	MOVE.W  BmWidth(A1),(A2)  ; $280=640
	LEA     height,A2
	MOVE.W  BmHeight(A1),(A2) ; $100=256
	LEA     depth,A2
	MOVE.B  BmDepth(A1),(A2)  ; $05
	LEA     compr,A2
	MOVE.B  BmCompr(A1),(A2)  ; $01
	ADDQ    #1,D6           ; Increment Chunk counter
	BRA     GETNEXT         ; Continue
GETCMAP:
	MOVE.L  D0,D3           ; Store size
	DIVU.W  #3,D3           ; Size / 3 bytes per color
	;SUBI.L  #32,D3          ; Should be 32 colors
	;MOVE.L  D3,ASSERT_ZERO  ; Assert no error
	;MOVE.L  #31,D3          ; Store size
	MOVEA.L A1,A2           ; Store ColorMap address
GETCMAP_LOOP:
	MOVE.B  (A2)+,D4        ; Red
	MOVE.B  (A2)+,D5        ; Green
	MOVE.B  (A2)+,D6        ; Blue
	DBF     D3,GETCMAP_LOOP ; Next color
	ADDQ    #1,D6           ; Increment Chunk counter
	BRA     GETNEXT         ; Continue
GETCAMG:
	MOVE.L  (A1),D3         ; Viewmodes
	SUBI.L  #$50091000,D3   ; Should be $50091000
	MOVE.L  D3,ASSERT_ZERO  ; Assert no error
	ADDQ    #1,D6           ; Increment Chunk counter
	BRA     GETNEXT         ; Continue
GETDPI:
	MOVE.L  (A1),D3         ; DPI
	SUBI.L  #$0029002C,D3   ; Should be $0029002C
	MOVE.L  D3,ASSERT_ZERO  ; Assert no error
	ADDQ    #1,D6           ; Increment Chunk counter
	BRA     GETNEXT         ; Continue
GETBODY:
	ADDQ    #1,D6           ; Increment Chunk counter
EXIT:
	SUBI.L  #5,D6           ; Check number of chunks in ILBM file.
	MOVE.L  D6,ASSERT_ZERO  ; Assert no error
	MOVE.L  D7,ASSERT_ZERO  ; Assert no error
	RTS

;==============================================================================
; Data Section
;==============================================================================

width:  DC.W 0
height: DC.W 0
depth:  DC.B 0
compr:  DC.B 0

PIC:
	INCBIN "Demo640x256x5.ilbm"

PICSZ:
	*-PIC1

;==============================================================================
; End of file
;==============================================================================
