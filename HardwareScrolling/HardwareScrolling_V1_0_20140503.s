;
; HardwareScrolling.s V1.0 20140503
; (c) 2014   Massimiliano Scarano   mscarano@libero.it
;
; Tested with TRASH'M-One V1.6 (based on ASM-One) by Deftronic of Crionics
;
; This demo shows how to make a hardware scrolling through a copperlist.
; A 640x256x5 playfield is scrolled in a 320x256x5 screen left and right.
; Press left mouse button to exit.
;



  SECTION MYCODE, CODE         ; Try to load this into Fast ram first, otherwise Chip is used



; StartUP
  move.l  4.w, a6              ; ExecBase in a6
  jsr     -$78(a6)             ; disable multitasking
  lea     GfxName, a1
  jsr     -$198(a6)            ; OpenLibrary()

  move.l  d0, GfxBase
  move.l  d0, a6
  move.l  $26(a6), OldCop      ; save address of system copperlist



; set bitplane pointers
  move.l  #PIC-2, d0           ; address of PIC, 1st bitplane (-2 trick to avoid a hardware display error)
  lea     BPLPOINTERS_0, a1
  moveq   #4, d1               ; number of bitplanes - 1, for dbra loop
POINTBP:
  move.w  d0, 6(a1)            ;
  swap    d0                   ;
  move.w  d0, 2(a1)            ;
  swap    d0                   ;
  add.l   #80*256, d0          ; add 10240*2 to d0, d0 points to next
  addq.w  #8, a1               ; a1 points to next
  dbra    d1, POINTBP          ; loop POINTBP d1 times



  move.l  #COPPERLIST, $dff080 ; COP1LC point to custom copperlist
  move.w  d0, $dff088          ; COPJMP1 (strobe register) start custom copperlist

  move.w  #0, $dff1fc          ; FMODE disable AGA
  move.w  #$c00, $dff106       ; BPLCON3 disable AGA
  move.w  #$11, $dff10c        ; BPLCON4 reset sprite palette



MainLoop:
  cmpi.b  #$ff, $dff006        ; video line 255 ?
  bne.s   MainLoop

  bsr.w   DoScrolling

WaitFrame:
  cmpi.b  #$ff, $dff006        ; video line 255 ?
  beq.s   WaitFrame

  ;
  bsr.w   ChangeScrollingDirection ; check if ...

  btst    #6, $bfe001          ; LMB ?
  bne.s   MainLoop



; CleanUp
  move.l  OldCop(pc), $dff080  ; COP1LC point to system copperlist
  move.w  d0, $dff088          ; COPJMP1 start system copperlist

  move.l  4.w, a6              ; ExecBase in a6
  jsr     -$7e(a6)             ; enable multitasking
  move.l  GfxBase(pc), a1
  jsr     -$19e(a6)            ; CloseLibrary()

  rts



DoScrolling:
; IsLeftScrolling = FALSE;
; if ( IsLeftScrolling == TRUE )
; {
;   DoLeftScrolling();
; }
; else
; {
;   DoRightScrolling();
; }
; ScrolledPixels += 1;
; if ( ScrolledPixels == 320 )
; {
;   ScrolledPixels = 0;
;   IsLeftScrolling = ! IsLeftScrolling;
; }

  btst   #1, IsLeftScrolling   ; right scrolling ?
  beq.w  DoLeftScrolling       ; scroll 1 pixel to right
  bsr.w  DoRightScrolling      ; scroll 1 pixel to left
  rts



DoRightScrolling:
  cmp.b   #$ff, MYBPLCON1      ; max scrolling ?
  bne.w   Con1Add              ;

  lea     BPLPOINTERS_0, a0    ; these 4 statements get from copperlist the address where $dff0e0 points to
  move.w  2(a0), d0            ; and assign it to d0
  swap    d0                   ;
  move.w  6(a0), d0            ;
  subq.l  #2, d0               ; 16 pixel to right
  lea     BPLPOINTERS_1, a1    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a1), d1            ; and assign it to ...
  swap    d1                   ;
  move.w  6(a1), d1            ;
  subq.l  #2, d1               ; 16 pixel to right
  lea     BPLPOINTERS_2, a2    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a2), d2            ; and assign it to ...
  swap    d2                   ;
  move.w  6(a2), d2            ;
  subq.l  #2, d2               ; 16 pixel to right
  lea     BPLPOINTERS_3, a3    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a3), d3            ; and assign it to ...
  swap    d3                   ;
  move.w  6(a3), d3            ;
  subq.l  #2, d3               ; 16 pixel to right
  lea     BPLPOINTERS_4, a4    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a4), d4            ; and assign it to ...
  swap    d4                   ;
  move.w  6(a4), d4            ;
  subq.l  #2, d4               ; 16 pixel to right

  clr.b   MYBPLCON1            ; reset hardware scrolling

  move.w  d0, 6(a0)            ; update copperlist
  swap    d0                   ;
  move.w  d0, 2(a0)            ;
  move.w  d1, 6(a1)            ; update copperlist
  swap    d1                   ;
  move.w  d1, 2(a1)            ;
  move.w  d2, 6(a2)            ; update copperlist
  swap    d2                   ;
  move.w  d2, 2(a2)            ;
  move.w  d3, 6(a3)            ; update copperlist
  swap    d3                   ;
  move.w  d3, 2(a3)            ;
  move.w  d4, 6(a4)            ; update copperlist
  swap    d4                   ;
  move.w  d4, 2(a4)            ;

  rts



Con1Add:
  add.b  #$11, MYBPLCON1       ; + 1 pixel
  rts



DoLeftScrolling:
  tst.b   MYBPLCON1            ; min scrolling ?
  bne.w   Con1Sub              ;

  lea     BPLPOINTERS_0, a0    ; these 4 statements get from copperlist the address where $dff0e0 points to
  move.w  2(a0), d0            ; and assign it to d0
  swap    d0                   ;
  move.w  6(a0), d0            ;
  addq.l  #2, d0               ; 16 pixel to left
  lea     BPLPOINTERS_1, a1    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a1), d1            ; and assign it to ...
  swap    d1                   ;
  move.w  6(a1), d1            ;
  addq.l  #2, d1               ; 16 pixel to left
  lea     BPLPOINTERS_2, a2    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a2), d2            ; and assign it to ...
  swap    d2                   ;
  move.w  6(a2), d2            ;
  addq.l  #2, d2               ; 16 pixel to left
  lea     BPLPOINTERS_3, a3    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a3), d3            ; and assign it to ...
  swap    d3                   ;
  move.w  6(a3), d3            ;
  addq.l  #2, d3               ; 16 pixel to left
  lea     BPLPOINTERS_4, a4    ; these 4 statements get from copperlist the address where ... points to
  move.w  2(a4), d4            ; and assign it to ...
  swap    d4                   ;
  move.w  6(a4), d4            ;
  addq.l  #2, d4               ; 16 pixel to left

  move.b  #$ff, MYBPLCON1      ; max hardware scrolling

  move.w  d0, 6(a0)            ; update copperlist
  swap    d0                   ;
  move.w  d0, 2(a0)            ;
  move.w  d1, 6(a1)            ; update copperlist
  swap    d1                   ;
  move.w  d1, 2(a1)            ;
  move.w  d2, 6(a2)            ; update copperlist
  swap    d2                   ;
  move.w  d2, 2(a2)            ;
  move.w  d3, 6(a3)            ; update copperlist
  swap    d3                   ;
  move.w  d3, 2(a3)            ;
  move.w  d4, 6(a4)            ; update copperlist
  swap    d4                   ;
  move.w  d4, 2(a4)            ;

  rts



Con1Sub:
  sub.b  #$11, MYBPLCON1       ; - 1 pixel
  rts



ChangeScrollingDirection:
  addq.w  #1, ScrolledPixels
  cmp.w   #320, ScrolledPixels
  bne.w   DoNop                ;@@@
  bchg.b  #1, IsLeftScrolling
  clr.w   ScrolledPixels
  rts



DoNop:
  rts



; Data

GfxName:
  dc.b  "graphics.library", 0, 0

GfxBase:
  dc.l  0

OldCop:
  dc.l  0

ScrolledPixels: ; number of pixels already scrolled [ 1 ; 320 ]
  dc.w  0

IsLeftScrolling: ; boolean flag for scrolling direction
  dc.w  0



  SECTION MYGRAPHICS, DATA_C   ; Load this into Chip ram (mandatory)



COPPERLIST:
  ; reset sprite pointers
  dc.w  $120, $0000, $122, $0000 ; SPR0PT
  dc.w  $124, $0000, $126, $0000 ; SPR1PT
  dc.w  $128, $0000, $12a, $0000 ; SPR2PT
  dc.w  $12c, $0000, $12e, $0000 ; SPR3PT
  dc.w  $130, $0000, $132, $0000 ; SPR4PT
  dc.w  $134, $0000, $136, $0000 ; SPR5PT
  dc.w  $138, $0000, $13a, $0000 ; SPR6PT
  dc.w  $13c, $0000, $13e, $0000 ; SPR7PT

  ; redifinition of not used registers
  dc.w  $8e, $2c81 ; DIWSTRT
  dc.w  $90, $2cc1 ; DIWSTOP
  dc.w  $92, $0030 ; DDFSTRT (trick to avoid a hardware display error)
  dc.w  $94, $00d0 ; DDFSTOP
  dc.w  $102       ; BPLCON1

  dc.b  0          ; BPLCON1 high byte, not used
MYBPLCON1:
  dc.b  0          ; BPLCON1 low byte, used

  dc.w  $104, 0    ; BPLCON2
  dc.w  $108, 40-2 ; BPL1MOD (trick to avoid a hardware display error)
  dc.w  $10a, 40-2 ; BPL2MOD (trick to avoid a hardware display error)

  ; 5 bitplanes = 32 colors, Lowres 320x256
  dc.w  $100, %0101001000000000 ; BPLCON0 define colors and resolution

BPLPOINTERS_0:
  dc.w  $e0, $0000, $e2, $0000 ; BPL0PT 1 bitplane
BPLPOINTERS_1:
  dc.w  $e4, $0000, $e6, $0000 ; BPL1PT 2 bitplane
BPLPOINTERS_2:
  dc.w  $e8, $0000, $ea, $0000 ; BPL2PT 3 bitplane
BPLPOINTERS_3:
  dc.w  $ec, $0000, $ee, $0000 ; BPL3PT 4 bitplane
BPLPOINTERS_4:
  dc.w  $f0, $0000, $f2, $0000 ; BPL4PT 5 bitplane

  ; palette, generated by KEFCON IFF-Converter V1.35
  ; use of the whole 32 color registers $0180 - $01be
  ; ...
  dc.w $0180,$0100,$0182,$0f80,$0184,$0900,$0186,$0500
  dc.w $0188,$0300,$018a,$0300,$018c,$0200,$018e,$0c00
  dc.w $0190,$0a00,$0192,$0700,$0194,$0e00,$0196,$0b00
  dc.w $0198,$0500,$019a,$0600,$019c,$0d00,$019e,$0a00
  dc.w $01a0,$0800,$01a2,$0ffc,$01a4,$0fa0,$01a6,$0f90
  dc.w $01a8,$0fb0,$01aa,$0f00,$01ac,$0ffd,$01ae,$0f80
  dc.w $01b0,$0fa0,$01b2,$0f90,$01b4,$0fb0,$01b6,$0f00
  dc.w $01b8,$0700,$01ba,$0e00,$01bc,$0400,$01be,$0800

  ;@@@ WAIT special effects here ...

  dc.w  $ffff,     $fffe     ; end



PIC:
  incbin  "Demo640x256x5.raw"



  end

; EOF
