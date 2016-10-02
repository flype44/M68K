#ifndef __DISLIB_080_H__
#define __DISLIB_080_H__

#define APP_VSTRING "$VER: DisLib080 0.1 (1.10.2016) APOLLO-Team"

#define UINT32 unsigned long
#define UINT8  unsigned char
#define UINT16 unsigned short
#define UINT64 unsigned long long
#define APTR   unsigned short *

#define BIT(a,b)      (((a)>>(b))&1)
#define DOWNTO(a,b,c) (((a)>>(c))&((1<<((b)-(c)+1))-1))

#endif
