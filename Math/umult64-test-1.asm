;--------------------------------------------------------------------------------
; ASM Testcase
; flype, 2015-10-12
; umult64-test-1.asm
; Based on meynaf 'umult64' routine
; http://eab.abime.net/showpost.php?p=1045340&postcount=15
;--------------------------------------------------------------------------------

ASSERT_ZERO EQU $00D0000C ; assert register

;--------------------------------------------------------------------------------
; HEAD
;--------------------------------------------------------------------------------

    section .fastram

    bra     start ; comment this for sim

    dc.l    0
    dc.l    start

;--------------------------------------------------------------------------------
; DATA
;--------------------------------------------------------------------------------

runner:
    ;       <=== arguments ===>,<=== precalcs ====>
    ;              d0        d1        d0        d1
    ;dc.l    $7fffffff,$10000001,$08000000,$6fffffff
    ;dc.l    $00002710,$00000011,$00000000,$00029810

    dc.l    $000050b7,$0000879d,$00000000,$2ac2013b ; 
    dc.l    $0000cdc1,$0000aa5b,$00000000,$88eb4d9b ; 
    dc.l    $000041ac,$0000aad8,$00000000,$2bd3a120 ; 
    dc.l    $00009bee,$00004885,$00000000,$2c2bf2a6 ; 
    dc.l    $00000835,$00007263,$00000000,$03aac67f ; 
    dc.l    $0000c90b,$0000d8f0,$00000000,$aa5dc250 ; 
    dc.l    $0000242c,$0000bdee,$00000000,$1ad61ce8 ; 
    dc.l    $00007f16,$00005bd6,$00000000,$2d970e64 ; 
    dc.l    $00000444,$00000b0e,$00000000,$002f27b8 ; 
    dc.l    $00006dc1,$00006a54,$00000000,$2d95ed54 ; 
    dc.l    $0000fefd,$0000c17d,$00000000,$c0b93e89 ; 
    dc.l    $0000fe0c,$0000cd5d,$00000000,$cbcbe65c ; 
    dc.l    $0000a1fe,$000047f7,$00000000,$2d89be12 ; 
    dc.l    $0000094c,$00002cd6,$00000000,$01a0d588 ; 
    dc.l    $00004e27,$0000bd98,$00000000,$39e13228 ; 
    dc.l    $0000b7ac,$0000296d,$00000000,$1db8c03c ; 
    dc.l    $0000ac46,$0000eb1e,$00000000,$9e387234 ; 
    dc.l    $0000d3a2,$00001f43,$00000000,$19d80166 ; 
    dc.l    $00008344,$00005e8b,$00000000,$307a3dec ; 
    dc.l    $000070ca,$0000e25e,$00000000,$63bbbe2c ; 
    dc.l    $de0d130e,$aaf4e442,$9449191a,$59af619c ; 
    dc.l    $3e1d2ad1,$017bf52f,$005c30ab,$b4bfe15f ; 
    dc.l    $3cb99c16,$75923cf0,$1be384a5,$81237ca0 ; 
    dc.l    $3c948fd8,$7ec72736,$1e003f8f,$8a283f90 ; 
    dc.l    $c1a67657,$5049c52a,$3cbbd297,$cd2f5d46 ; 
    dc.l    $dc972284,$797edfba,$68b0c27b,$4dd80fe8 ; 
    dc.l    $e876de5c,$614a66c8,$585899f2,$1c0e5fe0 ; 
    dc.l    $b5c21346,$f69af6ea,$af168493,$7e06e1fc ; 
    dc.l    $5a3f57bf,$7e7d616b,$2c976075,$92fc0bd5 ; 
    dc.l    $25f0f2e6,$d1e974d1,$1f1c4feb,$011c85c6 ; 
    dc.l    $df503324,$b2d8726f,$9c02930c,$b8ec349c ; 
    dc.l    $259a2016,$e448e4c6,$2187f986,$f7f86904 ; 
    dc.l    $445a6595,$1adad2af,$072b9b8c,$8401aadb ; 
    dc.l    $88da86ad,$96ea7726,$50ad625a,$5d2c68ae ; 
    dc.l    $45e8ade3,$a4befe95,$2cfd379c,$076e6f1f ; 
    dc.l    $b5caae43,$6ec5f358,$4ea9a8a6,$c4a48008 ; 
    dc.l    $3a670bc1,$882b5220,$1f10a049,$d0104a20 ; 
    dc.l    $91f71904,$96a97ba1,$55e76b45,$610fa784 ; 
    dc.l    $403286b4,$386b725c,$0e25ff43,$3f6090B0 ; 
    dc.l    $0a15f0eb,$118f1efb,$00b11879,$a403c069 ; 
    dc.l    0,0

;--------------------------------------------------------------------------------
; MAIN
;--------------------------------------------------------------------------------

start:
    lea     runner,a0      ; load runner
    clr.l   d7             ; error count
.loop:
    tst.l   0(a0)          ; last value ?
    bne     .native        ; if not, continue
    tst.l   4(a0)          ; last value ?
    beq     .exit          ; then exit
.native:
    clr.l   d2
    move.l  0(a0),d0       ; load values
    move.l  4(a0),d1       ; 
    move.l  8(a0),d3       ; precalc high
    move.l  12(a0),d4      ; precalc low
    mulu.l  d0,d0:d1       ; mul64 (68020+)
    jsr     selftest       ; check results
.meynaf:
    clr.l   d2
    move.l  (a0)+,d0       ; load values
    move.l  (a0)+,d1       ; 
    move.l  (a0)+,d3       ; precalc high
    move.l  (a0)+,d4       ; precalc low
    jsr     umult64        ; mul64 (68000+)
    jsr     selftest       ; check results
.next:
    bra     .loop          ; continue
.exit:
    move.l  d7,ASSERT_ZERO ; assert error counter = 0
    stop    #-1            ; stop sim
    rts                    ; stop program

selftest:
    sub.l   d3,d0          ; check d0
    move.l  d0,ASSERT_ZERO ; assert d0 = 0
    bne     .selftest_err  ; error counter
    sub.l   d4,d1          ; check d1
    move.l  d1,ASSERT_ZERO ; assert d1 = 0
    bne     .selftest_err  ; error counter
    rts                    ; exit routine
.selftest_err:
    add.l   #1,d7          ; increment error counter
    rts                    ; exit routine

;--------------------------------------------------------------------------------
; UMULT64
;--------------------------------------------------------------------------------

umult64:
    move.l  d2,-(sp)
    move.w  d0,d2
    mulu    d1,d2
    move.l  d2,-(sp)
    move.l  d1,d2
    swap    d2
    move.w  d2,-(sp)
    mulu    d0,d2
    swap    d0
    mulu    d0,d1
    mulu    (sp)+,d0
    add.l   d2,d1
    moveq   #0,d2
    addx.w  d2,d2
    swap    d2
    swap    d1
    move.w  d1,d2
    clr.w   d1
    add.l   (sp)+,d1
    addx.l  d2,d0
    move.l  (sp)+,d2
    rts

;--------------------------------------------------------------------------------

    end
