;===================================================
; Motorola 68K - ASM test
; Inplace ReverseString on a null-terminated string
; ReverseString("Hello World") => "dlroW olleH"
;===================================================

;===================================================
; Constants
;===================================================

assert_zero EQU $00D0000C

;===================================================
; Entry point
;===================================================

Start:
     lea     string,a0           ; ReverseString(a0)
     bsr     ReverseString       ; 
     lea     string,a0           ; SelfTest(a0,a1)
     lea     precalc,a1          ; 
     bsr     SelfTest            ; 
     stop    #-1                 ; stop execution

;===================================================
; ReverseString SubRoutine
; A0 = Null-terminated String to reverse 
;===================================================

ReverseString:
     clr.l   d0                  ; init d0
     move.l  a0,a1               ; put string addr in a1

ReverseStringToEnd:
     tst.b   (a1)+               ; goto end of string
     bne     ReverseStringToEnd  ; exit if null-char
     sub.l   #1,a1               ; exclude null-char

ReverseStringLoop:
     move.b  -(a1),d0            ; permute first and last char
     move.b  (a0),(a1)           ; 
     move.b  d0,(a0)+            ; 
     cmpa.l  a0,a1               ; if first char pos <= last char pos
     bgt     ReverseStringLoop   ; continue
     rts                         ; exit subroutine

;===================================================
; Self-Test SubRoutine
; A0 = Null-terminated String to reverse 
; A1 = Precalculated Null-terminated String
;===================================================

SelfTest:
     clr.l   d0                  ; init d0
SelfTestLoop:
     move.b  (a0)+,d0            ; get calculated value
     beq     SelfTestExit        ; exit if null-char
     sub.b   (a1)+,d0            ; compare with precalculated value
     move.l  d0,assert_zero      ; raise error if d0 != 0
     bra     SelfTestLoop        ; continue
SelfTestExit:
     rts                         ; exit subroutine

;===================================================
; Data Section
;===================================================

string:
     dc.b 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
     dc.b 'Lorem Ipsum has been the industry s standard dummy text ever since the 1500s, '
     dc.b 'when an unknown printer took a galley of type and scrambled it to make a type specimen book. '
     dc.b 'It has survived not only five centuries, but also the leap into electronic typesetting, '
     dc.b 'remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset '
     dc.b 'sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like '
     dc.b 'Aldus PageMaker including versions of Lorem Ipsum.',0

precalc:
     dc.b '.muspI meroL fo snoisrev gnidulcni rekaMegaP sudlA'
     dc.b ' ekil erawtfos gnihsilbup potksed htiw yltnecer erom dna ,segassap muspI meroL gniniatnoc steehs'
     dc.b ' tesarteL fo esaeler eht htiw s0691 eht ni desiralupop saw tI .degnahcnu yllaitnesse gniniamer'
     dc.b ' ,gnittesepyt cinortcele otni pael eht osla tub ,seirutnec evif ylno ton devivrus sah tI'
     dc.b ' .koob nemiceps epyt a ekam ot ti delbmarcs dna epyt fo yellag a koot retnirp nwonknu na nehw'
     dc.b ' ,s0051 eht ecnis reve txet ymmud dradnats s yrtsudni eht neeb sah muspI meroL'
     dc.b ' .yrtsudni gnittesepyt dna gnitnirp eht fo txet ymmud ylpmis si muspI meroL',0

;===================================================
; End of program
;===================================================
