;    dc.l    0
;    dc.l    Main
;    section .fastram

ASSERT_ZERO EQU $00D0000C  ; Write a value <> 0 to it will kill SIM.
ASSERT_NORW EQU $00D0001C  ; Read or Write to/from it will kill SIM.

Main:
    lea     MainBase1,a0
    lea     MainBase2,a2
    lea     SomeValues,a1
    move.l  #123456789,d0
MainLoop:
    move.l  #5,d1       ; RoutineExit
    move.l  (a1)+,d2    ; next value
    beq     RoutineExit ; if value = 0 then RoutineExit
    and.l   #1,d2
    beq     Main3
    and.l   #$f000,d2
    beq     Main1
    or.l    #$111,d2
    beq     Main5
    btst.l  #19,d2
    beq     Main2
    or.l    #$1,d2
    beq     Main4
Main1:
    jsr     ([8*2+0,a0],0)
    dbf     d0,MainLoop
    bra     RoutineExit
Main2:
    jsr     ([8*2+4,a0],0)
    bra     MainLoop
Main3:
    jsr     ([a2],0)
    bra     MainLoop
Main4:
    jsr     ([8*2+12,a0],0)
    bra     MainLoop
Main5:
    jsr     ([8*2+8,a0],0)
    bra     MainLoop
Main6:
    jsr     ([8*2,a0],0)
    bra     MainLoop

Routine1:
    swap    d0
    jsr     Routine3(pc)
    rts

RoutineTrap1:
    move.l  d0,ASSERT_NORW

Routine2:
    addq    #1,d0
    rts

RoutineTrap2:
    move.l  d0,ASSERT_NORW

Routine3:
    bvs     Routine3
    jsr     Routine4(pc)
    bvc     Routine2
    rts

Routine4:
    btst    #7,d2
    bne     Routine5
    bsr     Routine5
    add.l   d2,d0
    rts

Routine5:
    sub.l   #123,d0
    rts

RoutineExit:
    sub.l   #$05eaca33,d0
    move.l  d0,ASSERT_ZERO
    sub.l   #$5,d1
    move.l  d1,ASSERT_ZERO
    stop    #-1

MainBase1:
    ds.w 8
    dc.l Routine1
    dc.l Routine2
    dc.l Routine3
    dc.l Routine4
    dc.l Routine5
    dc.l RoutineExit

MainBase2:
    dc.l Routine5
    dc.l Routine4
    dc.l Routine2
    dc.l Routine3
    dc.l Routine1
    dc.l RoutineExit

SomeValues:
    dc.l 15,20,3,4,88,120,14,33,5,0