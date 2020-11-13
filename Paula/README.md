# Vampire SAGA AUDIO chipset
PlayPAM is a small program to test the Vampire (V4+) AUDIO chipset.

Channels registers :

Channel 00 = DFF40_
Channel 01 = DFF41_
Channel 02 = DFF42_
Channel 03 = DFF43_
Channel 04 = DFF44_
Channel 05 = DFF45_
Channel 06 = DFF46_
Channel 07 = DFF47_

Features per channel :

DFF4_0 = (W) PTR HIGH
DFF4_2 = (W) PTR LOW
DFF4_4 = (W) LEN HIGH
DFF4_6 = (W) LEN LOW
DFF4_8 = (W) VOL 8.8
DFF4_A = (W) MODE (Bit0=16bit, Bit1=OneShot)
DFF4_C = (W) PERIOD
DFF4_E = (W) RESERVED

Control DMA and INT :

POTINP1   0xDFF016    // (R) Read Paula chip ID (0=Paula, 1=Pamela)
DMACONR1  0xDFF002    // (R) Control AUD DMA  (Bit0 to Bit3 ) AUD0..3
DMACONR2  0xDFF202    // (R) Control AUD DMA  (Bit0 to Bit11) AUD4..7
DMACON1   0xDFF096    // (W) Control AUD DMA  (Bit0 to Bit3 ) AUD0..3
DMACON2   0xDFF296    // (W) Control AUD DMA  (Bit0 to Bit11) AUD4..7
INTENAR1  0xDFF01C    // (R) Request INT BITS (Bit7 to Bit10) AUD0..3
INTENAR2  0xDFF21C    // (R) Request INT BITS (Bit0 to Bit11) AUD4..7
INTENA1   0xDFF09A    // (W) Request INT BITS (Bit7 to Bit10) AUD0..3
INTENA2   0xDFF29A    // (W) Request INT BITS (Bit0 to Bit11) AUD4..7
INTREQR1  0xDFF01E    // (R) Request INT BITS (Bit7 to Bit10) AUD0..3
INTREQR2  0xDFF21E    // (R) Request INT BITS (Bit0 to Bit11) AUD4..7
INTREQ1   0xDFF09C    // (W) Request INT BITS (Bit7 to Bit10) AUD0..3
INTREQ2   0xDFF29C    // (W) Request INT BITS (Bit0 to Bit11) AUD4..7
