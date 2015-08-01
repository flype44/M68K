;======================================================
; Sort test
; From book : "Amiga Machine Language" - Page 68 to 69
;======================================================

assert_zero EQU $00D0000C        ; Magical register

table1size EQU 5
table2size EQU 25

;======================================================

start:
    
    clr.l   d6                   ; Error counter

    move.l  #table1,a0           ; Table 1
    move.l  #table1size,d0       ; 
    jsr     sort                 ; Sort 
    jsr     sortcheck            ; Check results

    move.l  #table2,a0           ; Table 2
    move.l  #table2size,d0       ; 
    jsr     sort                 ; Sort 
    jsr     sortcheck            ; Check results

    move.l  #table1,a0           ; Table 1 + Table 2
    move.l  #table1size,d0       ; 
    add.l   #table2size,d0       ; 
    jsr     sort                 ; Sort 
    jsr     sortcheck            ; Check results

    stop    #-1                  ; Stop execution

;======================================================

sortcheck:
    clr.l   d1                   ; Erase flag
    subq.w  #2,d0                ; Correct counter value
checkloop:
    move.w  2(a0),d1             ; b
    cmp.w   0(a0),d1             ; a
    bcc     checknext            ; Continue if a < b
    addq.l  #1,d6                ; Error counter
    move.l  #1,assert_zero       ; Otherwise, raise error
checknext:
    addq.l  #2,a0                ; Pointer + 2
    dbf     d0,checkloop         ; Continue
    rts                          ; Exit subroutine

;======================================================

sort:
    clr.l   d1                   ; Erase flag
    clr.l   d2                   ; Erase flag
    clr.l   d3                   ; Erase flag
    move.l  a0,a1                ; Copy address
    move.l  d0,d1                ; Copy number
    subq.w  #2,d1                ; Correct counter value
loop:
    move.w  2(a1),d2             ; Next value
    cmp.w   (a1),d2              ; Compare values
    bcc     noswap               ; Branch if no sort needed
doswap:
    move.w  (a1),d3              ; Save first value
    move.w  2(a1),(a1)           ; Copy second into first word
    move.w  d3,2(a1)             ; Move first into second
    moveq   #1,d3                ; Set flag
noswap:
    addq.l  #2,a1                ; Pointer + 2
    dbf     d1,loop              ; Continue Loop
    tst.w   d3                   ; Test flag
    bne     sort                 ; Continue Sort
    rts                          ; 

;======================================================

table1:
    dc.w 10,8,6,4,2

;======================================================

table2:
    dc.w 1,248,1235,100,512,3,320,64
    dc.w 197,219,1,99,1997,61,10,17
    dc.w 34,2410,100,4,41,55,833,14
    dc.w 0

;======================================================
