/*********************************************************************
 ** Project: PlayPam.c
 ** Version: 0.4alpha
 ** Date:    2017-may
 ** Short:   Play sound on a given channel.
 ** Purpose: Test PAMELA logic implementation.
 ** Authors: (C) APOLLO-Team 2017 (HW:Gunnar,Henryk,Claude) (SW:Flype)
 ** Compile: >gcc   PlayPam.c -o PlayPam
 **          >strip PlayPam
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
 ** PRIVATE DEFINITIONS
 *********************************************************************/

#define PAMELA_8BITS  0
#define PAMELA_16BITS 1

#define APPNAME  "PlayPam"
#define TEMPLATE "F=FILE/A,C=CHANNEL/N,M=MODE/N,R=RATE/N,V=VOLUME/N,S=STEREO/N,L=LOOP/S,P=PREPARE/S"

const BYTE VERSTRING[] = "$VER: PlayPam 0.4a (1-6-2017)\n";

struct Custom* bank1;
struct Custom* bank2;
struct DosLibrary* _DOSBase;

#define OPT_FILE    0
#define OPT_CHANNEL 1
#define OPT_MODE    2
#define OPT_RATE    3
#define OPT_VOLUME  4
#define OPT_STEREO  5
#define OPT_LOOP    6
#define OPT_PREPARE 7
#define OPT_LAST    8

const char        PAN[8] = {  'R','L','L','R','R','L','L','R' };
const UBYTE STEREO[3][8] = {{  0 , 1 , 2 , 3 , 4 , 5 , 6 , 7  },  //   L or R
                            {  3 , 2 , 1 , 0 , 7 , 6 , 5 , 4  },  // L/L or R/R
                            {  1 , 0 , 3 , 2 , 5 , 4 , 7 , 6  }}; // L/R or R/L

/*********************************************************************
 ** PROTOTYPES
 *********************************************************************/

void PreparePamela( void );

UBYTE* ReadFile( BYTE* fileName, 
                 LONG* fileSize );

BOOL ChannelPlay( UBYTE  chan,
                  UBYTE* wavform,
                  LONG   size,
                  UWORD  rate,
                  UWORD  volume,
                  LONG   mode );

BOOL ChannelIsFinished( UBYTE chan );

BOOL ChannelStop( UBYTE chan );

/*********************************************************************
 ** ENTRY POINT
 *********************************************************************/

int main( int argc, char *argv[] )
{
	struct RDArgs *rdargs;
	long opts[ OPT_LAST ];

	bank1 = ( struct Custom* ) 0xdff000;
	bank2 = ( struct Custom* ) 0xdff200;

	if ( ( _DOSBase = ( struct DosLibrary* ) OpenLibrary( "dos.library", 0 ) ) == NULL )
	{
		fprintf( stderr, "%s\n", "OpenLibrary( dos ) failed" );
		exit( EXIT_FAILURE );
	}
  	
	memset( (char *) opts, 0, sizeof( opts ) );
	
	if( rdargs = (struct RDArgs *) ReadArgs( TEMPLATE, opts, NULL ) )
	{
		BYTE*  fileName;
		UBYTE* fileData;
		LONG   fileSize;
		LONG   channel = 0;
		LONG   rate    = 48000;
		LONG   volume  = 64;
		LONG   mode    = PAMELA_8BITS;
		LONG   stereo  = 0;
		BOOL   oneshot = TRUE;
		
		if( opts[ OPT_PREPARE ] )
		{
			PreparePamela();
		}
			
		if( opts[ OPT_STEREO ] )
		{
			stereo = *( LONG * ) opts[ OPT_STEREO ];
			
			if ( stereo > 2 )
			{
				printf("Invalid stereo mode. 0 (default) to 2.\n");
				goto ABORT;
			}
		}

		if( opts[ OPT_LOOP ] )
		{
			oneshot = FALSE;
		}

		if( opts[ OPT_FILE ] )
		{
			fileName = ( UBYTE* ) opts[ OPT_FILE ];
		}
		
		if( opts[ OPT_CHANNEL ] )
		{
			channel = *( LONG * ) opts[ OPT_CHANNEL ];
			
			if ( channel > 7 )
			{
				printf("Invalid channel. 0 (default) to 7.\n");
				goto ABORT;
			}
		}
		
		if( opts[ OPT_VOLUME ] )
		{
			volume = *( LONG * ) opts[ OPT_VOLUME ];
			
			if ( volume > 64 )
			{
				printf("Invalid volume. 0 to 64 (default).\n");
				goto ABORT;
			}
		}
		
		if( opts[ OPT_RATE ] )
		{
			rate = *( LONG * ) opts[ OPT_RATE ];
			
			if ( rate < 1 || rate > 56000 )
			{
				printf("Invalid rate. 1 to 56000 (default: 48000 Hz).\n");
				goto ABORT;
			}
		}
		
		if( opts[ OPT_MODE ] )
		{
			mode = *( LONG * ) opts[ OPT_MODE ];
			
			if ( mode > PAMELA_16BITS )
			{
				printf("Invalid mode. 0=8bits (default), 1=16bits.\n");
				goto ABORT;
			}
			
			if ( mode == PAMELA_16BITS && channel < 4 )
			{
				printf("Invalid mode. 16bits mode is only for channels 4,5,6,7.\n");
				goto ABORT;
			}
		}

		fileData = ReadFile( fileName, &fileSize );
		
		if( fileData != NULL )
		{
			UBYTE* wavData = fileData;
			LONG   wavSize = fileSize;
			
			printf( "FileName:  %s\n",       fileName );
			printf( "FileSize:  %d bytes\n", fileSize );
			
			if ( mode == PAMELA_8BITS  && wavSize > ( 128 * 1024 ) )
				wavSize = ( 128 * 1024 );
			
			if ( mode == PAMELA_16BITS && wavSize > ( 256 * 1024 ) )
				wavSize = ( 256 * 1024 );
			
			if ( ChannelPlay( channel, wavData, wavSize, 
			                  rate, volume, mode ) )
			{
				if ( stereo )
					ChannelPlay( STEREO[ stereo ][ channel ], 
					             wavData, wavSize, rate, volume, mode );
				
				printf( "Ctrl+C to stop.\n" );
				
				do
				{
					if( oneshot && ChannelIsFinished( channel ) )
						break;
				
					Delay(5);
					
				} while ( ! CheckSignal( SIGBREAKF_CTRL_C ) );

				ChannelStop( channel );

				if ( stereo )
					ChannelStop( STEREO[ stereo ][ channel ] );
			}
			
			FreeMem( fileData, fileSize );
		}
		else
		{
			fprintf( stderr, "%s\n", "ReadFile() failed, sample not loaded" );
		}
		
ABORT:
		FreeArgs( rdargs );
	}
	else
	{
		PrintFault( IoErr(), APPNAME );
	}

	CloseLibrary( ( struct Library* ) _DOSBase );
  
	exit( EXIT_SUCCESS );
}

/*********************************************************************
 ** UBYTE* ReadFile( BYTE* fileName, LONG* fileSize )
 ** Open a file, read the content into a buffer.
 *********************************************************************/

UBYTE* ReadFile( BYTE* fileName, LONG* fileSize )
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

				if ( buffer = ( UBYTE* ) AllocMem( *fileSize, MEMF_ANY | MEMF_CLEAR ) )
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

/*********************************************************************
 ** PreparePamela()
 ** Temporary trick, core-side, to prepare real Paula for receiving 
 ** data in 14bits. Paula needs 8 dummy writes for this to work.
 ** As soon as Pamela will use audio HDMI output, this can be removed.
 *********************************************************************/

void PreparePamela( void )
{
	int chan;

	for( chan = 0; chan < 4; chan++ )
	{
		bank1->aud[ chan ].ac_per = ( UWORD ) 0x0000;
		bank1->aud[ chan ].ac_vol = ( UWORD ) 0x0000;
	}
}

/*********************************************************************
 ** BOOL ChannelPlay( chan, data, size, rate, volume, mode )
 ** Play a sound to the given channel.
 *********************************************************************/

BOOL ChannelPlay( UBYTE  chan, 
                  UBYTE* wavData, 
                  LONG   wavSize, 
                  UWORD  rate, 
                  UWORD  volume,
                  LONG   mode)
{
	struct Custom* bank;
	UWORD  period = ( UWORD ) ( 3546895 / rate );
	UWORD  myaudcon, myintreq, mydmacon0, mydmacon1;
	
	printf( "AUD%d (%c)\n", chan, PAN[ chan ] );
	
	if ( chan < 4 )
	{
		bank = bank1;
	}
	else if ( chan < 8 )
	{
		bank = bank2;
		chan -= 4;
	}
	else
	{
		// Unsupported.
		return FALSE;
	}
	
	if ( mode == PAMELA_8BITS )
	{
		wavSize >>= 1; // in words
		myaudcon  = ( UWORD ) ( 0x0000 + ( 1 << ( chan + 4 ) ) );
	}
	else if ( mode == PAMELA_16BITS )
	{
		wavSize >>= 2; // in longs
		myaudcon  = ( UWORD ) ( 0x8000 + ( 1 << ( chan + 4 ) ) );
	}
	else
	{
		// Unsupported.
		return FALSE;
	}
	
	mydmacon0 = ( UWORD ) ( 0x0000 + ( 1 << ( chan     ) ) );
	mydmacon1 = ( UWORD ) ( 0x8000 + ( 1 << ( chan     ) ) );
	myintreq  = ( UWORD ) ( 0x0000 + ( 1 << ( chan + 7 ) ) );

/*
	printf("BANKx: 0x%06lx\n", bank);
	printf("BANKx->DMACON:  0x%04x\n",  mydmacon0 );
	printf("BANK2->ADKCON:  0x%04x\n",  myaudcon  );
	printf("BANKx->AUDxPTR: 0x%08lx\n", wavData   );
	printf("BANKx->AUDxLEN: 0x%04lx\n", wavSize   );
	printf("BANKx->AUDxPER: 0x%04lx (%dHz)\n", period, rate );
	printf("BANKx->AUDxVOL: 0x%04lx\n", volume    );
	printf("BANKx->INTREQ:  0x%04x\n",  myintreq  );
	printf("BANKx->DMACON:  0x%04x\n",  mydmacon1 );
*/	

	bank->dmacon  = ( UWORD ) mydmacon0; // Disable DMA
	bank2->adkcon = ( UWORD ) myaudcon;  // Set 8/16 bits
	
	bank->aud[ chan ].ac_ptr = ( UWORD* ) wavData;
	bank->aud[ chan ].ac_len = ( UWORD  ) wavSize;
	bank->aud[ chan ].ac_per = ( UWORD  ) period;
	bank->aud[ chan ].ac_vol = ( UWORD  ) volume;
	
	bank->intreq = ( UWORD ) myintreq;  // Request finish-bit
	bank->dmacon = ( UWORD ) mydmacon1; // Enable DMA
	
	return TRUE;
}

/*********************************************************************
 ** BOOL ChannelStop( UBYTE chan )
 ** Stops the given audio DMA channel.
 *********************************************************************/

BOOL ChannelStop( UBYTE chan )
{
	if ( chan < 4 )
	{
		bank1->dmacon = ( UWORD ) ( 1 << chan ); // Disable DMA
		bank2->adkcon = ( UWORD ) ( 1 << chan ); // Reset to 8bits mode
		return TRUE;
	}
	
	if ( chan < 8 )
	{
		bank2->dmacon = ( UWORD ) ( 1 << ( chan - 4 ) ); // Disable DMA
		bank2->adkcon = ( UWORD ) ( 1 << ( chan     ) ); // Reset to 8bits mode
		return TRUE;
	}
	
	// Unsupported.
	return FALSE;
}

/*********************************************************************
 ** BOOL ChannelIsFinished( UBYTE chan )
 ** Poll the AUDx interrupt request finish-bit (INT Level 4).
 *********************************************************************/

BOOL ChannelIsFinished( UBYTE chan )
{
	if ( chan < 4 )
	{
		UWORD mask = ( 1 << ( chan + 7 ) );
		return ( ( bank1->intreqr & mask ) == mask );
	}
	
	if ( chan < 8 )
	{
		UWORD mask = ( 1 << ( chan + 7 - 4 ) );
		return ( ( bank2->intreqr & mask ) == mask );
	}
	
	// Unsupported.
	return FALSE;
}

/*********************************************************************
 ** END OF FILE
 *********************************************************************/

// Amiga Rulez
