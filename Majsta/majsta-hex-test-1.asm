
        BRA     START
        
HDIGIT: DS.B 1
ACHAR:  DS.B 1

START:         
        MOVE.B  HDIGIT,D0
        JSR     HEXDIGIT
        MOVE.B  D0,ACHAR
        MOVE.B  #9,D0
        STOP    #-1 ; halt simulator

HEXDIGIT:
        CMP.B   #$0A,D0
        BLT.S   ADDZ
        ADD.B   #'A'-'0'-$0A,D0
ADDZ:
        ADD.B   #'0',D0
        RTS

        END
