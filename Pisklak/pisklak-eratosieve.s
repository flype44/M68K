*-----------------------------------------------------------
* Title      : eratosieve
* Written by : pisklak
* Date       : 23/09/2015
* Description: eratostenes sieve
*-----------------------------------------------------------
    ORG    $1000
zakres      EQU 50
arry_addr   EQU  $3000
 
 
START:                  ; first instruction of program
        move.l  #2,D1
        lea     arry_addr,A1
        move.l  #2,D0
WL:     cmp.l   #zakres,D0
        bge     SIEVE
        move.l  D0,(A1)+
        add.l   #1,D0
        jmp     WL
       
SIEVE:
         lea arry_addr,A1
         
.fl         cmp.l  #0,(A2)
            bne    .cl
            move.l A1,A2
            adda.l #4,A2
            cmp.l #zakres*4+arry_addr,A2
            bge e  
           
         
.cl      move.l (A1),D1
         lea    arry_addr,A1
         clr.l  D0
         move.l D1,D2          
.l:      cmp.l  #zakres,D1
         bge    .fl
         clr.l  (A1,D0)        
         add.l  D2,D1
         move.l D1,D0
         sub.l  #2,D0
         lsl.l  #2,D0
         jmp    .l
e:  
* Put program code here
END:
    SIMHALT             ; halt simulator
 
* Put variables and constants here
 
    END    START        ; last line of source