
START:  LEA     lb1,A0
        LEA     lb2,A1
        MOVE.L  (A0),(A1)
EXIT:   RTS

lb1: dc.l $AABBCCDD
lb2: dc.l $00000000
