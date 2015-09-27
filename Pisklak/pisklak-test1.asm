*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
range       EQU 11
arry_addr   EQU $3000
 
 START:                  ; first instruction of program
    lea     arry_addr,A1
    move.l  A1,A2
    move.l  #2,D1
   
 WL:
    cmp.l   #range,D1
    bgt     SIEVE
    move.l  D1,(A1)+
    add.l   #1,D1    
    jmp     WL  
 
FL:
 
    cmp.l   #1,(A2)
    bne     SIEVE
    cmp.l   #range,(A2)
    bgt     e    *
    adda.l  #4,A2
    jmp     FL
       
 
 
SIEVE:
    move.l (A2),D1
    move.l  D1,D2
    move.l  D2,D0
    lea     arry_addr,A1
   
.cl
   
    cmp.l   #range,D2
    bge     .a
    add.l   D0,D1  
    sub.l   #2,D1
    lsl.l   #2,D1
   
    move.l  A1,D3
    add.l   D1,D3
    cmp.l   $3024,D3
    bge     .a
    move.l  #1,(A1,D1)
    add.l   D0,D2
    move.l  D2,D1  
    jmp     .cl
 
.a  
    adda.l  #4,A2
    jmp     FL
   
* Put program code here
e:
    SIMHALT             ; halt simulator
 
* Put variables and constants here
 
    END    START        ; last line of source