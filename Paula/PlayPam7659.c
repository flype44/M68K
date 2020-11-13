/*********************************************************************
 ** Project: PlayPam7659.c
 ** Version: 7659
 ** Date:    2020-august
 ** Short:   Play sound on a given channel.
 ** Purpose: Test PAMELA logic implementation.
 ** Authors: (C) APOLLO-Team 2020.
 ** Build:   m68k-amigaos-gcc -noixemul -Os -m68040
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
 ** SAGA AUDIO CHANNELS DEFINITIONS
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
} aud[8];

/*********************************************************************
 ** PRIVATE DEFINITIONS
 *********************************************************************/
 
#define APPNAME  "PlayPam2020"

#define TEMPLATE "FILE/A,CHANNEL/N,RATE/N,VOLUME1/N,VOLUME2/N,IS16BITS/S,ISONESHOT/S"

#define OPT_FILE      0
#define OPT_CHANNEL   1
#define OPT_RATE      2
#define OPT_VOLUME1   3
#define OPT_VOLUME2   4
#define OPT_IS16BITS  5
#define OPT_ISONESHOT 6
#define OPT_LAST      7

const BYTE VERSTRING[] = "$VER: PlayPam 0.5 (29-5-2020)\n";

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
	BPTR   file = 0;
	BPTR   lock = 0;
	struct FileInfoBlock* fib = NULL;
	
	if ( lock = Lock( fileName, ACCESS_READ ) )
	{
		if ( fib = ( struct FileInfoBlock* ) AllocMem( sizeof ( struct FileInfoBlock ), 0 ) )
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

void sndPlay( int channel, UBYTE *ptr, int size, int rate, int vol1, int vol2, int is16bits, int isOneShot )
{
	if ( channel < 8 )
	{
		if ( vol1 > 128 ) vol1 = 128;
		if ( vol2 > 128 ) vol2 = 128;
		if ( rate > 56000 ) rate = 56000;
		if ( isOneShot > 1 ) isOneShot = 1;
		if ( is16bits > 1 ) is16bits = 1;
		if ( is16bits ) size >>= 1;
		
		sndBank[ channel ].ac_ptr = ( ULONG* ) ptr;
		sndBank[ channel ].ac_len = ( ULONG  ) size >> 1; // max = 0x00FFFFFF
		sndBank[ channel ].ac_vol = ( UWORD  ) ( vol2 << 8 ) | vol1; // max = 128.128
		sndBank[ channel ].ac_mod = ( UWORD  ) ( isOneShot << 1 ) | is16bits;
		sndBank[ channel ].ac_per = ( UWORD  ) 3546895 / rate; // min = 2, max = 0xFFFF
		
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
	else if ( channel < 8 )
	{
		// Disable DMA for AUD4..7
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

/*********************************************************************
 ** ENTRY POINT
 *********************************************************************/

int main( int argc, char *argv[] )
{
	struct RDArgs *rdargs;
	long opts[ OPT_LAST ];
	
	if( ( _DOSBase = ( struct DosLibrary* ) OpenLibrary( "dos.library", 0 ) ) == NULL )
	{
		fprintf( stderr, "%s\n", "OpenLibrary( dos ) failed" );
		exit( EXIT_FAILURE );
	}
	
	fprintf( stdout, "Paula Revision: %ld\n", GetPaulaID() );
	
  	memset( (char *) opts, 0, sizeof( opts ) );
	
	sndBank = ( struct SAGAChannel* ) 0xDFF400;
	
	if( rdargs = (struct RDArgs *) ReadArgs( TEMPLATE, opts, NULL ) )
	{
		BYTE*  fileName;
		UBYTE* fileData;
		LONG   fileSize;
		
		LONG   channel   = 0;
		LONG   rate      = 22050;
		LONG   volume1   = 128;
		LONG   volume2   = 64;
		LONG   is16bits  = FALSE;
		BOOL   isOneShot = FALSE;
		
		if( opts[ OPT_FILE      ] ) fileName  =  ( UBYTE* ) opts[ OPT_FILE    ];
		if( opts[ OPT_CHANNEL   ] ) channel   = *( LONG * ) opts[ OPT_CHANNEL ];
		if( opts[ OPT_RATE      ] ) rate      = *( LONG * ) opts[ OPT_RATE    ];
		if( opts[ OPT_VOLUME1   ] ) volume1   = *( LONG * ) opts[ OPT_VOLUME1 ];
		if( opts[ OPT_VOLUME2   ] ) volume2   = *( LONG * ) opts[ OPT_VOLUME2 ];
		if( opts[ OPT_IS16BITS  ] ) is16bits  = TRUE;
		if( opts[ OPT_ISONESHOT ] ) isOneShot = TRUE;
		
		fileData = sndLoad( fileName, &fileSize );
		
		if( fileData != NULL )
		{
			sndPlay( channel, fileData, fileSize, rate, volume1, volume2, is16bits, isOneShot );
			
			printf( "Ctrl+C to stop.\n" );
			
			do
			{
				Delay(10);
				
			} while ( ! CheckSignal( SIGBREAKF_CTRL_C ) );
			
			sndStop( channel );
			sndFree( fileData );
		}
		else
		{
			fprintf( stderr, "%s\n", "sndLoad() failed, sample not loaded" );
		}
		
		FreeArgs( rdargs );
	}
	else
	{
		PrintFault( IoErr(), APPNAME );
	}
	
	CloseLibrary( ( struct Library* ) _DOSBase );
	
	exit( EXIT_SUCCESS );
}
