00f84a00 :  70fe                       moveq.l #-$2,d0
00f84a02 :  6102                       bsr.s $f84a06
00f84a04 :  4e75                       rts
00f84a06 :  48e7 2010                  movem.l d2/a3,-(a7)
00f84a0a :  2400                       move.l d0,d2
00f84a0c :  2649                       movea.l a1,a3
00f84a0e :  2f0e                       move.l a6,-(a7)
00f84a10 :  2c6e 0024                  movea.l $24(a6),a6
00f84a14 :  4eae ff88                  jsr -$78(a6)
00f84a18 :  2c5f                       movea.l (a7)+,a6
00f84a1a :  08eb 0007 001e             bset #$7,$1e(a3)
00f84a20 :  6660                       bne.s $f84a82
00f84a22 :  1342 001f                  move.b d2,$1f(a1)
00f84a26 :  082b 0005 001e             btst #$5,$1e(a3)
00f84a2c :  6718                       beq.s $f84a46
00f84a2e :  2053                       movea.l (a3),a0
00f84a30 :  226b 0004                  movea.l $4(a3),a1
00f84a34 :  2288                       move.l a0,(a1)
00f84a36 :  2149 0004                  move.l a1,$4(a0)
00f84a3a :  4a90                       tst.l (a0)
00f84a3c :  671c                       beq.s $f84a5a
00f84a3e :  08e8 0005 001e             bset #$5,$1e(a0)
00f84a44 :  6014                       bra.s $f84a5a
00f84a46 :  082b 0004 001e             btst #$4,$1e(a3)
00f84a4c :  670c                       beq.s $f84a5a
00f84a4e :  224b                       movea.l a3,a1
00f84a50 :  2059                       movea.l (a1)+,a0
00f84a52 :  2251                       movea.l (a1),a1
00f84a54 :  2288                       move.l a0,(a1)
00f84a56 :  2149 0004                  move.l a1,$4(a0)
00f84a5a :  2f0e                       move.l a6,-(a7)
00f84a5c :  2c6e 0024                  movea.l $24(a6),a6
00f84a60 :  4eae ff82                  jsr -$7e(a6)
00f84a64 :  2c5f                       movea.l (a7)+,a6
00f84a66 :  082b 0000 001e             btst #$0,$1e(a3)
00f84a6c :  660e                       bne.s $f84a7c
00f84a6e :  224b                       movea.l a3,a1
00f84a70 :  2f0e                       move.l a6,-(a7)
00f84a72 :  2c6e 0024                  movea.l $24(a6),a6
00f84a76 :  4eae fe86                  jsr -$17a(a6)
00f84a7a :  2c5f                       movea.l (a7)+,a6
00f84a7c :  4cdf 0804                  movem.l (a7)+,d2/a3
00f84a80 :  4e75                       rts
00f84a82 :  2f0e                       move.l a6,-(a7)
00f84a84 :  2c6e 0024                  movea.l $24(a6),a6
00f84a88 :  4eae ff82                  jsr -$7e(a6)
00f84a8c :  2c5f                       movea.l (a7)+,a6
00f84a8e :  60ec                       bra.s $f84a7c
00f84a90 :  224e                       movea.l a6,a1
00f84a92 :  2059                       movea.l (a1)+,a0
00f84a94 :  2251                       movea.l (a1),a1
00f84a96 :  2288                       move.l a0,(a1)
00f84a98 :  2149 0004                  move.l a1,$4(a0)
00f84a9c :  2f2e 0028                  move.l $28(a6),-(a7)
00f84aa0 :  224e                       movea.l a6,a1
00f84aa2 :  302e 0010                  move.w $10(a6),d0
00f84aa6 :  92c0                       suba.w d0,a1
00f84aa8 :  d06e 0012                  add.w $12(a6),d0
00f84aac :  48c0                       ext.l d0
00f84aae :  2f0e                       move.l a6,-(a7)
00f84ab0 :  2c6e 0024                  movea.l $24(a6),a6
00f84ab4 :  4eae ff2e                  jsr -$d2(a6)
00f84ab8 :  2c5f                       movea.l (a7)+,a6
00f84aba :  201f                       move.l (a7)+,d0
00f84abc :  4e75                       rts
00f84abe :  08ee 0003 000e             bset #$3,$e(a6)
00f84ac4 :  7000                       moveq.l #$0,d0
00f84ac6 :  4e75                       rts
00f84ac8 :  7000                       moveq.l #$0,d0
00f84aca :  2340 0018                  move.l d0,$18(a1)
00f84ace :  2340 0014                  move.l d0,$14(a1)
00f84ad2 :  536e 0020                  subq.w #$1,$20(a6)
00f84ad6 :  660c                       bne.s $f84ae4
00f84ad8 :  082e 0003 000e             btst #$3,$e(a6)
00f84ade :  6704                       beq.s $f84ae4
00f84ae0 :  4eee ffee                  jmp -$12(a6)
00f84ae4 :  4e75                       rts
00f84ae6 :  0000 70fd                  ori.b #-$3,d0
00f84aea :  6100 ff1a                  bsr $f84a06
00f84aee :  4e75                       rts
00f84af0 :  6100 000c                  bsr $f84afe
00f84af4 :  6100 0044                  bsr $f84b3a
00f84af8 :  6100 0014                  bsr $f84b0e
00f84afc :  4e75                       rts
00f84afe :  2069 0018                  movea.l $18(a1),a0
00f84b02 :  08e8 0000 0009             bset #$0,$9(a0)
00f84b08 :  6100 fefc                  bsr $f84a06
00f84b0c :  4e75                       rts
00f84b0e :  2f09                       move.l a1,-(a7)
00f84b10 :  2069 0018                  movea.l $18(a1),a0
00f84b14 :  08a8 0000 0009             bclr #$0,$9(a0)
00f84b1a :  2268 0014                  movea.l $14(a0),a1
00f84b1e :  4a91                       tst.l (a1)
00f84b20 :  6710                       beq.s $f84b32
00f84b22 :  3029 001c                  move.w $1c(a1),d0
00f84b26 :  e548                       lsl.w #$2,d0
00f84b28 :  206e 002c                  movea.l $2c(a6),a0
00f84b2c :  2070 0000                  movea.l $0(a0,d0.w),a0
00f84b30 :  4e90                       jsr (a0)
00f84b32 :  225f                       movea.l (a7)+,a1
00f84b34 :  6100 fed0                  bsr $f84a06
00f84b38 :  4e75                       rts
00f84b3a :  48e7 0060                  movem.l a1-a2,-(a7)
00f84b3e :  2469 0018                  movea.l $18(a1),a2
00f84b42 :  226a 0014                  movea.l $14(a2),a1
00f84b46 :  4a91                       tst.l (a1)
00f84b48 :  6706                       beq.s $f84b50
00f84b4a :  6100 feb4                  bsr $f84a00
00f84b4e :  60f2                       bra.s $f84b42
00f84b50 :  4cdf 0600                  movem.l (a7)+,a1-a2
00f84b54 :  6100 feb0                  bsr $f84a06
00f84b58 :  4e75                       rts
00f84b5a :  0000 6000                  ori.b #$0,d0
00f84b5e :  ff8a                       dc.w $ff8a ;illegal opcode
00f84b60 :  48e7 0020                  movem.l a2,-(a7)
00f84b64 :  2448                       movea.l a0,a2
00f84b66 :  157c 0004 0008             move.b #$4,$8(a2)
00f84b6c :  422a 000e                  clr.b $e(a2)
00f84b70 :  256e 0114 0010             move.l $114(a6),$10(a2)
00f84b76 :  41ea 0014                  lea.l $14(a2),a0
00f84b7a :  2148 0008                  move.l a0,$8(a0)
00f84b7e :  5888                       addq.l #$4,a0
00f84b80 :  4290                       clr.l (a0)
00f84b82 :  2108                       move.l a0,-(a0)
00f84b84 :  70ff                       moveq.l #-$1,d0
00f84b86 :  4eae feb6                  jsr -$14a(a6)
00f84b8a :  1540 000f                  move.b d0,$f(a2)
00f84b8e :  4cdf 0400                  movem.l (a7)+,a2
00f84b92 :  4e75                       rts
00f84b94 :  48e7 0002                  movem.l a6,-(a7)
00f84b98 :  c18e                       exg.l d0,a6
00f84b9a :  2d40 0024                  move.l d0,$24(a6)
00f84b9e :  2d48 0028                  move.l a0,$28(a6)
00f84ba2 :  41ee 0048                  lea.l $48(a6),a0
00f84ba6 :  2148 0008                  move.l a0,$8(a0)
00f84baa :  5888                       addq.l #$4,a0
00f84bac :  4290                       clr.l (a0)
00f84bae :  2108                       move.l a0,-(a0)
00f84bb0 :  41ee 0124                  lea.l $124(a6),a0
00f84bb4 :  2148 0008                  move.l a0,$8(a0)
00f84bb8 :  5888                       addq.l #$4,a0
00f84bba :  4290                       clr.l (a0)
00f84bbc :  2108                       move.l a0,-(a0)
00f84bbe :  91c8                       suba.l a0,a0
00f84bc0 :  7002                       moveq.l #$2,d0
00f84bc2 :  43ee 00f4                  lea.l $f4(a6),a1
00f84bc6 :  7200                       moveq.l #$0,d1
00f84bc8 :  2f0e                       move.l a6,-(a7)
00f84bca :  2c6e 0024                  movea.l $24(a6),a6
00f84bce :  4eae fe44                  jsr -$1bc(a6)
00f84bd2 :  2c5f                       movea.l (a7)+,a6
00f84bd4 :  4a80                       tst.l d0
00f84bd6 :  6636                       bne.s $f84c0e
00f84bd8 :  43fa 003c                  lea.l $f84c16(pc),a1
00f84bdc :  7000                       moveq.l #$0,d0
00f84bde :  2f0e                       move.l a6,-(a7)
00f84be0 :  2c6e 0024                  movea.l $24(a6),a6
00f84be4 :  4eae fe0e                  jsr -$1f2(a6)
00f84be8 :  2c5f                       movea.l (a7)+,a6
00f84bea :  2d40 0056                  move.l d0,$56(a6)
00f84bee :  671e                       beq.s $f84c0e
00f84bf0 :  6100 02aa                  bsr $f84e9c
00f84bf4 :  2d4e 0068                  move.l a6,$68(a6)
00f84bf8 :  7003                       moveq.l #$3,d0
00f84bfa :  43ee 005a                  lea.l $5a(a6),a1
00f84bfe :  2f0e                       move.l a6,-(a7)
00f84c00 :  2c6e 0056                  movea.l $56(a6),a6
00f84c04 :  4eae fffa                  jsr -$6(a6)
00f84c08 :  2c5f                       movea.l (a7)+,a6
00f84c0a :  6100 03c4                  bsr $f84fd0
00f84c0e :  200e                       move.l a6,d0
00f84c10 :  4cdf 4000                  movem.l (a7)+,a6
00f84c14 :  4e75                       rts
