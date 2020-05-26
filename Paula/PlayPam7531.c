/*********************************************************************
 ** Project: PlayPam7531.c
 ** Version: 7531 (3)
 ** Date:    2020-may
 ** Short:   Play sound on a given channel.
 ** Purpose: Test PAMELA logic implementation.
 ** Authors: (C) APOLLO-Team 2020.
 *********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <hardware/dmabits.h>

/*********************************************************************
 ** SAGA Audio Channel
 *********************************************************************/

/*
	Channel 00 = DFF40_
	Channel 01 = DFF41_
	Channel 02 = DFF42_
	Channel 03 = DFF43_
	Channel 04 = DFF44_
	Channel 05 = DFF45_
	Channel 06 = DFF46_
	Channel 07 = DFF47_
	Channel 08 = DFF48_
	Channel 09 = DFF49_
	Channel 10 = DFF4A_
	Channel 11 = DFF4B_
	Channel 12 = DFF4C_
	Channel 13 = DFF4D_
	Channel 14 = DFF4E_
	Channel 15 = DFF4F_
	
	DFF4_0 = (W) PTR HIGH
	DFF4_2 = (W) PTR LOW
	DFF4_4 = (W) LEN HIGH
	DFF4_6 = (W) LEN LOW
	DFF4_8 = (W) VOL 8.8
	DFF4_A = (W) MODE (Bit0=16bit, Bit1=OneShot)
	DFF4_C = (W) PERIOD
	DFF4_E = (W) RESERVED
*/

#define GET16(a)  ( *( volatile UWORD* ) a )
#define CLR16(a, b) *( volatile UWORD* ) ( a ) = ( UWORD ) ( 0x0000 + ( b ) )
#define SET16(a, b) *( volatile UWORD* ) ( a ) = ( UWORD ) ( 0x8000 + ( b ) )

#define POTINP1   0xDFF016    // (R) Read Paula chip ID (0=Paula, 1=Pamela)

#define DMACONR1  0xDFF002    // (R) Control AUD DMA  (Bit0 to Bit3 ) AUD0..3
#define DMACONR2  0xDFF202    // (R) Control AUD DMA  (Bit0 to Bit11) AUD4..15
#define DMACON1   0xDFF096    // (W) Control AUD DMA  (Bit0 to Bit3 ) AUD0..3
#define DMACON2   0xDFF296    // (W) Control AUD DMA  (Bit0 to Bit11) AUD4..15

#define INTENAR1  0xDFF01C    // (R) Request INT BITS (Bit7 to Bit10) AUD0..3
#define INTENAR2  0xDFF21C    // (R) Request INT BITS (Bit0 to Bit11) AUD4..15
#define INTENA1   0xDFF09A    // (W) Request INT BITS (Bit7 to Bit10) AUD0..3
#define INTENA2   0xDFF29A    // (W) Request INT BITS (Bit0 to Bit11) AUD4..15

#define INTREQR1  0xDFF01E    // (R) Request INT BITS (Bit7 to Bit10) AUD0..3
#define INTREQR2  0xDFF21E    // (R) Request INT BITS (Bit0 to Bit11) AUD4..15
#define INTREQ1   0xDFF09C    // (W) Request INT BITS (Bit7 to Bit10) AUD0..3
#define INTREQ2   0xDFF29C    // (W) Request INT BITS (Bit0 to Bit11) AUD4..15

struct SAGAChannel
{
  ULONG *ac_ptr;   // Pointer
  ULONG  ac_len;   // Length
  UWORD  ac_vol;   // Volume (8.8)
  UWORD  ac_mod;   // Mode
  UWORD  ac_per;   // Period
  UWORD  ac_pad;   // Reserved
} aud[16];

struct SAGAChannel* sndBank;

struct DosLibrary* _DOSBase;

UWORD GetPaulaID()
{
	// Paula Chip ID (0 = Paula, 1 = Pamela).
	
	return ( ( GET16( POTINP1 ) & 0xFE ) >> 1 );
}

UBYTE* sndLoad( BYTE* fileName, LONG* fileSize )
{
	UBYTE* buffer;
	BPTR   file = NULL;
	BPTR   lock = NULL;
	struct FileInfoBlock* fib = NULL;
	
	if ( lock = Lock( fileName, ACCESS_READ ) )
	{
		if ( fib = ( struct FileInfoBlock* ) AllocMem( sizeof ( struct FileInfoBlock ), NULL ) )
		{
			if ( Examine( lock, fib ) )
			{
				*fileSize = fib->fib_Size;
				
				// SAGA AUDxPTR support FULL 32-bits address, this
				// means, either MEMF_CHIP or MEMF_FAST can be used.
				if ( buffer = ( UBYTE* ) AllocVec( *fileSize, MEMF_ANY | MEMF_CLEAR ) )
				{
					if ( file = Open( fileName, MODE_OLDFILE ) )
					{
						Read( file, buffer, *fileSize );
						Close( file );
					}
				}
			}
			FreeMem( fib, sizeof ( struct FileInfoBlock ) );
		}
		UnLock( lock );
	}
	
	return buffer;
}

void sndPlay( int channel, int *ptr, int size, int rate, int vol1, int vol2, int is16bits, int isOneShot )
{
	if ( ptr )
	{
		sndBank[ channel ].ac_ptr = ( ULONG* ) ( ( ULONG )ptr & 0xFFFFFFFE );
		sndBank[ channel ].ac_len = ( ULONG  ) ( ( size >> ( is16bits ? 2 : 1 ) ) & 0x00FFFFFF );
		sndBank[ channel ].ac_vol = ( UWORD  ) ( ( ( vol2 & 0x0040 ) << 8 ) | ( vol1 & 0x0040 ) );
		sndBank[ channel ].ac_mod = ( UWORD  ) ( ( ( isOneShot & 1 ) << 1 ) | ( ( is16bits & 1 ) << 0 ) );
		sndBank[ channel ].ac_per = ( UWORD  ) ( 3546895 / ( rate & 0xFFFF ) );
		
		if ( channel < 4 )
		{
			// Enable DMA for AUD0..3
			SET16( DMACON1, 1 << ( channel - 0 ) );
		}
		else
		{
			// Enable DMA for AUD4..15
			SET16( DMACON2, 1 << ( channel - 4 ) );
		}
	}
}

void sndStop( int channel )
{
	if ( channel < 4 )
	{
		// Disable DMA for AUD0..3
		CLR16( DMACON1, 1 << ( channel - 0 ) );
	}
	else
	{
		// Disable DMA for AUD4..15
		CLR16( DMACON2, 1 << ( channel - 4 ) );
	}
}

void sndFree( UBYTE* sndData )
{
	if ( sndData )
	{
		FreeVec( sndData );
	}
}

int main( int argc, char *argv[] )
{
	UBYTE* sndData[8];
	LONG   sndSize[8];
	
	if ( ( _DOSBase = ( struct DosLibrary* ) OpenLibrary( "dos.library", 0 ) ) == NULL )
	{
		fprintf( stderr, "%s\n", "OpenLibrary( dos ) failed" );
		exit( EXIT_FAILURE );
	}
  	
	sndBank = ( struct SAGAChannel* ) 0xDFF400;
	
	sndData[0] = sndLoad( "SOUND_00.iff", &sndSize[0] );
	sndData[1] = sndLoad( "SOUND_01.iff", &sndSize[1] );
	sndData[2] = sndLoad( "SOUND_02.iff", &sndSize[2] );
	sndData[3] = sndLoad( "SOUND_03.iff", &sndSize[3] );
	sndData[4] = sndLoad( "SOUND_04.iff", &sndSize[4] );
	sndData[5] = sndLoad( "SOUND_05.iff", &sndSize[5] );
	sndData[6] = sndLoad( "SOUND_06.iff", &sndSize[6] );
	sndData[7] = sndLoad( "SOUND_07.iff", &sndSize[7] );
	
	sndPlay( 0, sndData[0], sndSize[0], 22050, 64, 32, 0, 1 );
	sndPlay( 1, sndData[1], sndSize[1], 22050, 64, 32, 0, 1 );
	sndPlay( 2, sndData[2], sndSize[2], 22050, 64, 32, 0, 1 );
	sndPlay( 3, sndData[3], sndSize[3], 22050, 64, 32, 0, 1 );
	sndPlay( 4, sndData[4], sndSize[4], 22050, 64, 32, 0, 1 );
	sndPlay( 5, sndData[5], sndSize[5], 22050, 64, 32, 0, 1 );
	sndPlay( 6, sndData[6], sndSize[6], 22050, 64, 32, 0, 1 );
	sndPlay( 7, sndData[7], sndSize[7], 22050, 64, 32, 0, 1 );
	
	// INSERT PROGRAM LOOP HERE
	// INSERT PROGRAM LOOP HERE
	// INSERT PROGRAM LOOP HERE
	
	sndFree( sndData[0] );
	sndFree( sndData[1] );
	sndFree( sndData[2] );
	sndFree( sndData[3] );
	sndFree( sndData[4] );
	sndFree( sndData[5] );
	sndFree( sndData[6] );
	sndFree( sndData[7] );
	
	CloseLibrary( ( struct Library* ) _DOSBase );
	
	exit( EXIT_SUCCESS );
}


