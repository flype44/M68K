00f84a00 :  70fe                            MOVEQ.L #$fe,d0                          ; 1
00f84a02 :  6102                            BSR.s   $f84a06                          ; 1
00f84a04 :  4e75                            RTS                                      ; 1
00f84a06 :  48e7 2010                       MOVEM.l d2/a3,-(a7)                      ; 2
00f84a0a :  2400                            MOVE.l  d0,d2                            ; 1
00f84a0c :  2649                            MOVEA.l a1,a3                            ; 1
00f84a0e :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84a10 :  2c6e 0024                       MOVEA.l $24(a6),a6                       ; 2
00f84a14 :  4eae ff88                       JSR     $ff88(a6)                        ; 2
00f84a18 :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84a1a :  08eb 0007 001e                  BSET    #$7,$1e(a3)                      ; 3
00f84a20 :  6660                            BNE.s   $f84a82                          ; 1
00f84a22 :  1342 001f                       MOVE.b  d2,$1f(a1)                       ; 2
00f84a26 :  082b 0005 001e                  BTST    #$5,$1e(a3)                      ; 3
00f84a2c :  6718                            BEQ.s   $f84a46                          ; 1
00f84a2e :  2053                            MOVEA.l (a3),a0                          ; 1
00f84a30 :  226b 0004                       MOVEA.l $4(a3),a1                        ; 2
00f84a34 :  2288                            MOVE.l  a0,(a1)                          ; 1
00f84a36 :  2149 0004                       MOVE.l  a1,$4(a0)                        ; 2
00f84a3a :  4a90                            TST.l   (a0)                             ; 1
00f84a3c :  671c                            BEQ.s   $f84a5a                          ; 1
00f84a3e :  08e8 0005 001e                  BSET    #$5,$1e(a0)                      ; 3
00f84a44 :  6014                            BRA.s   $f84a5a                          ; 1
00f84a46 :  082b 0004 001e                  BTST    #$4,$1e(a3)                      ; 3
00f84a4c :  670c                            BEQ.s   $f84a5a                          ; 1
00f84a4e :  224b                            MOVEA.l a3,a1                            ; 1
00f84a50 :  2059                            MOVEA.l (a1)+,a0                         ; 1
00f84a52 :  2251                            MOVEA.l (a1),a1                          ; 1
00f84a54 :  2288                            MOVE.l  a0,(a1)                          ; 1
00f84a56 :  2149 0004                       MOVE.l  a1,$4(a0)                        ; 2
00f84a5a :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84a5c :  2c6e 0024                       MOVEA.l $24(a6),a6                       ; 2
00f84a60 :  4eae ff82                       JSR     $ff82(a6)                        ; 2
00f84a64 :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84a66 :  082b 0000 001e                  BTST    #$0,$1e(a3)                      ; 3
00f84a6c :  660e                            BNE.s   $f84a7c                          ; 1
00f84a6e :  224b                            MOVEA.l a3,a1                            ; 1
00f84a70 :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84a72 :  2c6e 0024                       MOVEA.l $24(a6),a6                       ; 2
00f84a76 :  4eae fe86                       JSR     $fe86(a6)                        ; 2
00f84a7a :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84a7c :  4cdf 0804                       MOVEM.l (a7)+,d2/a3                      ; 2
00f84a80 :  4e75                            RTS                                      ; 1
00f84a82 :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84a84 :  2c6e 0024                       MOVEA.l $24(a6),a6                       ; 2
00f84a88 :  4eae ff82                       JSR     $ff82(a6)                        ; 2
00f84a8c :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84a8e :  60ec                            BRA.s   $f84a7c                          ; 1
00f84a90 :  224e                            MOVEA.l a6,a1                            ; 1
00f84a92 :  2059                            MOVEA.l (a1)+,a0                         ; 1
00f84a94 :  2251                            MOVEA.l (a1),a1                          ; 1
00f84a96 :  2288                            MOVE.l  a0,(a1)                          ; 1
00f84a98 :  2149 0004                       MOVE.l  a1,$4(a0)                        ; 2
00f84a9c :  2f2e 0028                       MOVE.l  $28(a6),-(a7)                    ; 2
00f84aa0 :  224e                            MOVEA.l a6,a1                            ; 1
00f84aa2 :  302e 0010                       MOVE.w  $10(a6),d0                       ; 2
00f84aa6 :  92c0                            SUBA.w  d0,a1                            ; 1
00f84aa8 :  d06e 0012                       ADD.w   $12(a6),d0                       ; 2
00f84aac :  48c0                            EXT.l  d0                                ; 1
00f84aae :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84ab0 :  2c6e 0024                       MOVEA.l $24(a6),a6                       ; 2
00f84ab4 :  4eae ff2e                       JSR     $ff2e(a6)                        ; 2
00f84ab8 :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84aba :  201f                            MOVE.l  (a7)+,d0                         ; 1
00f84abc :  4e75                            RTS                                      ; 1
00f84abe :  08ee 0003 000e                  BSET    #$3,$e(a6)                       ; 3
00f84ac4 :  7000                            MOVEQ.L #$00,d0                          ; 1
00f84ac6 :  4e75                            RTS                                      ; 1
00f84ac8 :  7000                            MOVEQ.L #$00,d0                          ; 1
00f84aca :  2340 0018                       MOVE.l  d0,$18(a1)                       ; 2
00f84ace :  2340 0014                       MOVE.l  d0,$14(a1)                       ; 2
00f84ad2 :  536e 0020                       SUBQ.w  #$1,$20(a6)                      ; 2
00f84ad6 :  660c                            BNE.s   $f84ae4                          ; 1
00f84ad8 :  082e 0003 000e                  BTST    #$3,$e(a6)                       ; 3
00f84ade :  6704                            BEQ.s   $f84ae4                          ; 1
00f84ae0 :  4eee ffee                       JMP     $ffee(a6)                        ; 2
00f84ae4 :  4e75                            RTS                                      ; 1
00f84ae6 :  0000 70fd                       ORI.b   #$fd,d0                          ; 2
00f84aea :  6100 ff1a                       BSR.w   $f84a06                          ; 2
00f84aee :  4e75                            RTS                                      ; 1
00f84af0 :  6100 000c                       BSR.w   $f84afe                          ; 2
00f84af4 :  6100 0044                       BSR.w   $f84b3a                          ; 2
00f84af8 :  6100 0014                       BSR.w   $f84b0e                          ; 2
00f84afc :  4e75                            RTS                                      ; 1
00f84afe :  2069 0018                       MOVEA.l $18(a1),a0                       ; 2
00f84b02 :  08e8 0000 0009                  BSET    #$0,$9(a0)                       ; 3
00f84b08 :  6100 fefc                       BSR.w   $f84a06                          ; 2
00f84b0c :  4e75                            RTS                                      ; 1
00f84b0e :  2f09                            MOVE.l  a1,-(a7)                         ; 1
00f84b10 :  2069 0018                       MOVEA.l $18(a1),a0                       ; 2
00f84b14 :  08a8 0000 0009                  BCLR    #$0,$9(a0)                       ; 3
00f84b1a :  2268 0014                       MOVEA.l $14(a0),a1                       ; 2
00f84b1e :  4a91                            TST.l   (a1)                             ; 1
00f84b20 :  6710                            BEQ.s   $f84b32                          ; 1
00f84b22 :  3029 001c                       MOVE.w  $1c(a1),d0                       ; 2
00f84b26 :  e548                            LSL.w   #$2,d0                           ; 1
00f84b28 :  206e 002c                       MOVEA.l $2c(a6),a0                       ; 2
00f84b2c :  2070 0000                       MOVEA.l $00(a0,d0.w*1),a0                ; 2
00f84b30 :  4e90                            JSR     (a0)                             ; 1
00f84b32 :  225f                            MOVEA.l (a7)+,a1                         ; 1
00f84b34 :  6100 fed0                       BSR.w   $f84a06                          ; 2
00f84b38 :  4e75                            RTS                                      ; 1
00f84b3a :  48e7 0060                       MOVEM.l a1-a2,-(a7)                      ; 2
00f84b3e :  2469 0018                       MOVEA.l $18(a1),a2                       ; 2
00f84b42 :  226a 0014                       MOVEA.l $14(a2),a1                       ; 2
00f84b46 :  4a91                            TST.l   (a1)                             ; 1
00f84b48 :  6706                            BEQ.s   $f84b50                          ; 1
00f84b4a :  6100 feb4                       BSR.w   $f84a00                          ; 2
00f84b4e :  60f2                            BRA.s   $f84b42                          ; 1
00f84b50 :  4cdf 0600                       MOVEM.l (a7)+,a1-a2                      ; 2
00f84b54 :  6100 feb0                       BSR.w   $f84a06                          ; 2
00f84b58 :  4e75                            RTS                                      ; 1
00f84b5a :  0000 6000                       ORI.b   #$00,d0                          ; 2
00f84b5e :  ff8a                            DC.w    $ff8a                            ; 1
00f84b60 :  48e7 0020                       MOVEM.l a2,-(a7)                         ; 2
00f84b64 :  2448                            MOVEA.l a0,a2                            ; 1
00f84b66 :  157c 0004 0008                  MOVE.b  #$04,$8(a2)                      ; 3
00f84b6c :  422a 000e                       CLR.b   $e(a2)                           ; 2
00f84b70 :  256e 0114 0010                  MOVE.l  $114(a6),$10(a2)                 ; 3
00f84b76 :  41ea 0014                       LEA     $14(a2),a0                       ; 2
00f84b7a :  2148 0008                       MOVE.l  a0,$8(a0)                        ; 2
00f84b7e :  5888                            ADDQ.l  #$4,a0                           ; 1
00f84b80 :  4290                            CLR.l   (a0)                             ; 1
00f84b82 :  2108                            MOVE.l  a0,-(a0)                         ; 1
00f84b84 :  70ff                            MOVEQ.L #$ff,d0                          ; 1
00f84b86 :  4eae feb6                       JSR     $feb6(a6)                        ; 2
00f84b8a :  1540 000f                       MOVE.b  d0,$f(a2)                        ; 2
00f84b8e :  4cdf 0400                       MOVEM.l (a7)+,a2                         ; 2
00f84b92 :  4e75                            RTS                                      ; 1
00f84b94 :  48e7 0002                       MOVEM.l a6,-(a7)                         ; 2
00f84b98 :  c18e                            EXG     d0,a6                            ; 1
00f84b9a :  2d40 0024                       MOVE.l  d0,$24(a6)                       ; 2
00f84b9e :  2d48 0028                       MOVE.l  a0,$28(a6)                       ; 2
00f84ba2 :  41ee 0048                       LEA     $48(a6),a0                       ; 2
00f84ba6 :  2148 0008                       MOVE.l  a0,$8(a0)                        ; 2
00f84baa :  5888                            ADDQ.l  #$4,a0                           ; 1
00f84bac :  4290                            CLR.l   (a0)                             ; 1
00f84bae :  2108                            MOVE.l  a0,-(a0)                         ; 1
00f84bb0 :  41ee 0124                       LEA     $124(a6),a0                      ; 2
00f84bb4 :  2148 0008                       MOVE.l  a0,$8(a0)                        ; 2
00f84bb8 :  5888                            ADDQ.l  #$4,a0                           ; 1
00f84bba :  4290                            CLR.l   (a0)                             ; 1
00f84bbc :  2108                            MOVE.l  a0,-(a0)                         ; 1
00f84bbe :  91c8                            SUBA.l  a0,a0                            ; 1
00f84bc0 :  7002                            MOVEQ.L #$02,d0                          ; 1
00f84bc2 :  43ee 00f4                       LEA     $f4(a6),a1                       ; 2
00f84bc6 :  7200                            MOVEQ.L #$00,d1                          ; 1
00f84bc8 :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84bca :  2c6e 0024                       MOVEA.l $24(a6),a6                       ; 2
00f84bce :  4eae fe44                       JSR     $fe44(a6)                        ; 2
00f84bd2 :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84bd4 :  4a80                            TST.l   d0                               ; 1
00f84bd6 :  6636                            BNE.s   $f84c0e                          ; 1
00f84bd8 :  43fa 003c                       LEA     $f84c16(pc),a1                   ; 2
00f84bdc :  7000                            MOVEQ.L #$00,d0                          ; 1
00f84bde :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84be0 :  2c6e 0024                       MOVEA.l $24(a6),a6                       ; 2
00f84be4 :  4eae fe0e                       JSR     $fe0e(a6)                        ; 2
00f84be8 :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84bea :  2d40 0056                       MOVE.l  d0,$56(a6)                       ; 2
00f84bee :  671e                            BEQ.s   $f84c0e                          ; 1
00f84bf0 :  6100 02aa                       BSR.w   $f84e9c                          ; 2
00f84bf4 :  2d4e 0068                       MOVE.l  a6,$68(a6)                       ; 2
00f84bf8 :  7003                            MOVEQ.L #$03,d0                          ; 1
00f84bfa :  43ee 005a                       LEA     $5a(a6),a1                       ; 2
00f84bfe :  2f0e                            MOVE.l  a6,-(a7)                         ; 1
00f84c00 :  2c6e 0056                       MOVEA.l $56(a6),a6                       ; 2
00f84c04 :  4eae fffa                       JSR     $fffa(a6)                        ; 2
00f84c08 :  2c5f                            MOVEA.l (a7)+,a6                         ; 1
00f84c0a :  6100 03c4                       BSR.w   $f84fd0                          ; 2
00f84c0e :  200e                            MOVE.l  a6,d0                            ; 1
00f84c10 :  4cdf 4000                       MOVEM.l (a7)+,a6                         ; 2
00f84c14 :  4e75                            RTS                                      ; 1
00f84c16 :  6369                            BLS.s   $f84c81                          ; 1
