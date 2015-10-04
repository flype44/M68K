*-----------------------------------------------------------
* Title      : ICachesimpletest3
* Written by : pisklak
* Date       : 02/09/2015
* Description: Simple testcase for CPU Icache testing
*-----------------------------------------------------------

*    ORG    $1000

    jmp    START
code_to_copy:  
    addi.l  #0,D4
    jmp     do_test

Assert_zero_check:
    sub     #55,D4  ; this is sum of all numbers from 0 to Ntimes (for 10 = 55)
    move.l  D4,ASSERT_ZERO
    jmp END

*  ----------------- Constant declarations --------------------

Ntimes      EQU 10     ; how many times code will be copied
alias_step  EQU $4000   ; alias step... for Apolloo ICache should be 16k = $4000
ASSERT_ZERO EQU $00D0000C
Nbytes      EQU 1+Assert_zero_check-code_to_copy ; numbers of bytes to copy should be equal to your copied code size
memsize     EQU Nbytes+Ntimes*alias_step

* Put program code here
START:                  ; first instruction of program
    clr.l   D0
    clr.l   D1
    clr.l   D2
    clr.l   D3
    clr.l   D4
    lea     Memory,A1
    lea     Memory,A2
copy_N_times:  
    lea     code_to_copy,A0
    adda    #alias_step,A1
copy_N_times_loop:
    cmp.l   #Ntimes,D1
    bge     do_test
    jsr     copy_N_bytes          
    adda    #alias_step,A1
    add.l   #1,D1
    jmp     copy_N_times_loop

do_test:    
    cmp.l  #Ntimes,D2
    bge    Assert_zero_check
    add.l  #1,D2
    adda   #alias_step,A2
    jmp    (A2)

copy_N_bytes:
    cmp.w   #Nbytes,D0
    bge     return_fromCB
    move.b  (A0)+,(A1)+
    add.w   #1,D0
    jmp     copy_N_bytes
return_fromCB:
    clr.l   D0
    sub.l   #Nbytes,A0
    sub.l   #Nbytes,A1
    add.l   #1,D1
    move.l  D1,2(A1)
    sub.l   #1,D1  
    RTS

Memory:
    DS.L Nbytes+Ntimes*alias_step

END:

    STOP #-1
    ;SIMHALT             ; halt simulator

* Put variables and constants here

    END START

