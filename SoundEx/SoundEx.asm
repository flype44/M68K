;==========================================================
; ASM Testcase
; flype, 2015-10-03
; soundex('Script') = 'S613'
;==========================================================
; http://phpjs.org/functions/soundex/
; https://github.com/kvz/phpjs/blob/master/functions/strings/soundex.js
;==========================================================

;==========================================================
; Constants
;==========================================================

ASSERT_ZERO EQU $00D0000C

;==========================================================
; MAIN()
;==========================================================
    
    BRA     MAIN

RESULT:
    DS.B    4              ; result (4 bytes)
    EVEN

MAIN:
    CLR.L   D6             ; Error counter
    CLR.L   D7             ; Store precalc value
    LEA.L   VALUES,A0      ; values
    LEA.L   RESULT,A1      ; result
MAIN_LOOP:
    MOVE.L  (A0)+,D7       ; precalc value
    BEQ.B   MAIN_EXIT      ; exit if no more value
    JSR     SOUNDEX        ; soundex(value)
    SUB.L   (A1),D7        ; D7 = precalc - calc
    BEQ     MAIN_ASSERT    ; Branch to Assert if D7 = 0
    ADDQ.L  #1,D6          ; Increment Error counter
MAIN_ASSERT:
    MOVE.L  D7,ASSERT_ZERO ; Assert D7 = 0
    ADDA.L  D1,A0          ; addr + length of value
    ADDQ.L  #1,A0          ; next value
    BRA     MAIN_LOOP      ; else continue
MAIN_EXIT:
    MOVE.L  D6,ASSERT_ZERO ; Assert D6 = 0
    STOP #-1               ; stop the program

;==========================================================
; Result = SOUNDEX(String)
; Input  : A0 = Input String
; Input  : A1 = Result buffer blank
; Output : A1 = Result buffer filled
; Output : D1 = Intput String length
;==========================================================

SOUNDEX:
    CLR.L   D0             ; D0 = Current char in input
    CLR.L   D1             ; D1 = Current index in input
    CLR.L   D2             ; D2 = Value in SoundEx table
    CLR.L   D3             ; D3 = Value reminder
    CLR.L   D4             ; D4 = Current index in result
    LEA.L   SOUNDEX_TBL,A2 ; SoundEx table
    MOVE.L  #'0000',(A1)   ; var A1 = '0000'
SOUNDEX_LOOP:
    MOVE.B  (A0,D1),D0     ; D0 = A0.charAt(D1)
    TST.B   D0             ; if (D0 == 0)
    BEQ     SOUNDEX_EXIT   ; exit while
    CMPI.B  #4,D4          ; if (s < 4)
    BGT     SOUNDEX_EXIT   ; exit while
    ADDQ    #1,D1          ; D1++
    CMPI.B  #97,D0         ; if (D0 < 97)
    BLT     SOUNDEX_NEXT0  ; continue
    CMPI.B  #122,D0        ; if (D0 > 122)
    BGT     SOUNDEX_NEXT0  ; continue
    SUBI.B  #32,D0         ; D0 = To Upper
SOUNDEX_NEXT0:
    SUBI.B  #$41,D0        ; D0 = To Index in SoundEx table
    MOVE.B  (A2,D0),D2     ; D2 = A2[D0]
    BEQ     SOUNDEX_NEXT2  ; if (D2)
    CMP.B   D2,D3          ; if (D2 != D3)
    BEQ     SOUNDEX_NEXT4  ; continue
    MOVE.B  D2,D3          ; D3 = D2
    TST.B   D4             ; if (D4 != 0)
    BEQ     SOUNDEX_NEXT1  ; else
    ADDI.B  #$30,D2        ; D2 = To Char
    MOVE.B  D2,(A1,D4)     ; A1[D4] = D2
SOUNDEX_NEXT1:
    ADDQ    #1,D4          ; D4++
    BRA     SOUNDEX_NEXT4  ; continue
SOUNDEX_NEXT2:
    CMPI.L  #1,D1          ; if (D1 == 1)
    BNE     SOUNDEX_NEXT3  ; continue
    ADDQ    #1,D4          ; D4++
SOUNDEX_NEXT3:
    CLR.L   D3             ; D3 = 0
SOUNDEX_NEXT4:
    BRA     SOUNDEX_LOOP   ; continue
SOUNDEX_EXIT:
    MOVE.B  (A0),(A1)      ; A1[0] = A0.charAt(0)
    CMPI.B  #97,(A1)       ; if (A1[0] < 97)
    BLT     SOUNDEX_EXIT1  ; continue
    CMPI.B  #122,(A1)      ; if (A1[0] > 122)
    BGT     SOUNDEX_EXIT1  ; continue
    SUBI.B  #32,(A1)       ; A1[0] = To Upper
SOUNDEX_EXIT1:
    TST.B   (A0,D1)        ; Skip remaining chars
    BEQ     SOUNDEX_EXIT2  ; continue
    ADDQ    #1,D1          ; D1++
    BRA     SOUNDEX_EXIT1  ; skip next
SOUNDEX_EXIT2:
    RTS                    ; exit subroutine
SOUNDEX_TBL:
    DC.B 0,1,2,3,0,1       ; A,B,C,D,E,F
    DC.B 2,0,0,2,2,4       ; G,H,I,J,K,L
    DC.B 5,5,0,1,2,6       ; M,N,O,P,Q,R
    DC.B 2,3,0,1,0,2       ; S,T,U,V,W,X
    DC.B 0,2               ; Y,Z
    EVEN

;==========================================================
; Data Section
;==========================================================

VALUES:
    DC.B 'L650','Lorem',0
    DC.B 'I125','ipsum',0
    DC.B 'D460','dolor',0
    DC.B 'S300','sit',0
    DC.B 'A530','amet',0
    DC.B 'C522','consectetur',0
    DC.B 'A312','adipiscing',0
    DC.B 'E430','elit',0
    DC.B 'I532','Integer',0
    DC.B 'A423','aliquet',0
    DC.B 'I500','in',0
    DC.B 'N200','nisi',0
    DC.B 'S300','sed',0
    DC.B 'P630','porta',0
    DC.B 'Q200','Quisque',0
    DC.B 'E300','et',0
    DC.B 'N240','nisl',0
    DC.B 'V160','viverra',0
    DC.B 'P260','posuere',0
    DC.B 'M620','mauris',0
    DC.B 'A200','ac',0
    DC.B 'P633','porttitor',0
    DC.B 'N520','nunc',0
    DC.B 'S300','Sed',0
    DC.B 'O656','ornare',0
    DC.B 'P415','pulvinar',0
    DC.B 'S342','sodales',0
    DC.B 'A425','Aliquam',0
    DC.B 'A300','at',0
    DC.B 'M320','metus',0
    DC.B 'T516','tempor',0
    DC.B 'B453','blandit',0
    DC.B 'E550','enim',0
    DC.B 'I300','id',0
    DC.B 'V160','viverra',0
    DC.B 'L000','leo',0
    DC.B 'D200','Duis',0
    DC.B 'C522','consectetur',0
    DC.B 'E230','est',0
    DC.B 'N200','neque',0
    DC.B 'N500','non',0
    DC.B 'I242','iaculis',0
    DC.B 'N520','nunc',0
    DC.B 'U436','ultricies',0
    DC.B 'V400','vel',0
    DC.B 'Q200','Quisque',0
    DC.B 'A300','at',0
    DC.B 'U650','urna',0
    DC.B 'V240','vehicula',0
    DC.B 'P260','posuere',0
    DC.B 'D460','dolor',0
    DC.B 'A300','at',0
    DC.B 'E415','eleifend',0
    DC.B 'L000','leo',0
    DC.B 'I500','In',0
    DC.B 'A300','at',0
    DC.B 'F212','faucibus',0
    DC.B 'A620','arcu',0
    DC.B 'N500','non',0
    DC.B 'A425','aliquam',0
    DC.B 'L160','libero',0
    DC.B 'N500','Nam',0
    DC.B 'M320','mattis',0
    DC.B 'M000','mi',0
    DC.B 'N200','neque',0
    DC.B 'V300','vitae',0
    DC.B 'V231','vestibulum',0
    DC.B 'E620','eros',0
    DC.B 'P426','placerat',0
    DC.B 'U300','ut',0
    DC.B 'S215','Suspendisse',0
    DC.B 'P353','potenti',0
    DC.B 'Q200','Quisque',0
    DC.B 'V160','viverra',0
    DC.B 'M000','mi',0
    DC.B 'E000','eu',0
    DC.B 'N400','nulla',0
    DC.B 'M423','molestie',0
    DC.B 'E300','et',0
    DC.B 'P636','pharetra',0
    DC.B 'O300','odio',0
    DC.B 'P633','porttitor',0
    DC.B 'D520','Donec',0
    DC.B 'E455','elementum',0
    DC.B 'S342','sodales',0
    DC.B 'C535','condimentum',0
    DC.B 'F200','Fusce',0
    DC.B 'F212','faucibus',0
    DC.B 'E620','eros',0
    DC.B 'I300','id',0
    DC.B 'T612','turpis',0
    DC.B 'S213','suscipit',0
    DC.B 'S516','semper',0
    DC.B 'P453','Pellentesque',0
    DC.B 'U650','urna',0
    DC.B 'E630','erat',0
    DC.B 'V431','volutpat',0
    DC.B 'Q200','quis',0
    DC.B 'E620','eros',0
    DC.B 'Q200','quis',0
    DC.B 'A425','aliquam',0
    DC.B 'F242','facilisis',0
    DC.B 'E430','elit',0
    DC.B 'M252','Maecenas',0
    DC.B 'P630','porta',0
    DC.B 'L250','lacinia',0
    DC.B 'N200','nisi',0
    DC.B 'E000','eu',0
    DC.B 'T516','tempor',0
    DC.B 'D500','diam',0
    DC.B 'C520','congue',0
    DC.B 'N200','nec',0
    DC.L 0

;==========================================================
; End of file
;==========================================================
    
    END
