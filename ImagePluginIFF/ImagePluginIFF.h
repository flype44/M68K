/////////////////////////////////////////////////////////////////////////////////////////////////
// ImagePluginIFF.h
// Author: flype
// Date:   2014-10-04
/////////////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////////////////////////
// Includes
/////////////////////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdint.h>

/////////////////////////////////////////////////////////////////////////////////////////////////
// Macros
/////////////////////////////////////////////////////////////////////////////////////////////////

#define BSWAP16(a)      ((((a)<<8)&0xFF00)|(((a)>>8)&0xFF))
#define BSWAP32(a)      ((((a)&0xFF)<<24)|(((a)&0xFF00)<<8)|(((a)>>8)&0xFF00)|(((a)>>24)&0xFF))
#define MAKEID(a,b,c,d) ((a)|((b)<<8)|((c)<<16)|((d)<<24))
#define MAX2(a,b)       (((a)<(b))?(b):(a))
#define MIN2(a,b)       (((a)<(b))?(a):(b))
#define MIN3(a,b,c)     (MIN2(MIN2(a,b),c))
#define RGB(r,g,b)      ((r)|((g)<<8)|((b)<<16))
#define RED(a)          ((a)&0xFF)
#define GREEN(a)        (((a)&0xFF00)>>8)
#define BLUE(a)         (((a)&0xFF0000)>>16)

/////////////////////////////////////////////////////////////////////////////////////////////////
// Constants
/////////////////////////////////////////////////////////////////////////////////////////////////

#define TRUE  1
#define FALSE 0

/////////////////////////////////////////////////////////////////////////////////////////////////
// Chunk IDs
/////////////////////////////////////////////////////////////////////////////////////////////////

#define ID_FORM MAKEID('F','O','R','M') // IFF header
#define ID_ILBM MAKEID('I','L','B','M') // Interleaved bitmap
#define ID_PBM  MAKEID('P','B','M',' ') // Packed bitmap

#define ID__C__ MAKEID('(','c',')',' ') // Copyright
#define ID__VER MAKEID('$','V','E','R') // Version
#define ID_ANNO MAKEID('A','N','N','O') // Annotation
#define ID_AUTH MAKEID('A','U','T','H') // Author
#define ID_BMHD MAKEID('B','M','H','D') // Bitmap header
#define ID_BODY MAKEID('B','O','D','Y') // Bitmap data
#define ID_CAMG MAKEID('C','A','M','G') // Commodore Amiga flags
#define ID_CCRT	MAKEID('C','C','R','T') // Color cycle
#define ID_CMAP MAKEID('C','M','A','P') // Color map
#define ID_CRNG MAKEID('C','R','N','G') // Color range
#define ID_CTBL MAKEID('C','T','B','L') // Color table
#define ID_DRNG MAKEID('D','R','N','G') // Color DRange
#define ID_XS24 MAKEID('X','S','2','4') // 24bits color map

/////////////////////////////////////////////////////////////////////////////////////////////////
// BMHD Chunk
/////////////////////////////////////////////////////////////////////////////////////////////////

#define cmpNone     0  // No compression.
#define cmpByteRun1 1  // ByteRun1 (RLE) compression.

#define mskNone                0  // No mask.
#define mskHasMask             1  // There
#define mskHasTransparentColor 2  // 
#define mskLasso               3  // 

typedef struct BMHD {
   uint16_t w, h;         // Size
   int16_t  x, y;         // Coordinates
   uint8_t  nPlanes;      // Number of bitplanes
   uint8_t  masking;      // Masking mode
   uint8_t  compression;  // Compression mode
   uint8_t  pad1;         // Pad
   uint16_t tColor;       // Transparent color
   uint8_t  xAspect;      // Ratio x
   uint8_t  yAspect;      // Ratio y
   int16_t  pw, ph;       // Page size
} BMHD;

/////////////////////////////////////////////////////////////////////////////////////////////////
// CAMG Chunk
/////////////////////////////////////////////////////////////////////////////////////////////////

#define CAMG_LACE  0x0004 // Interlaced
#define CAMG_EHB   0x0080 // Extra Half Brite
#define CAMG_HAM   0x0800 // Hold And Modify
#define CAMG_HIRES 0x8000 // High Resolution

/////////////////////////////////////////////////////////////////////////////////////////////////
// CCRT Chunk
/////////////////////////////////////////////////////////////////////////////////////////////////

#define DRNG_ACTIVE      1 // 
#define DRNG_DP_RESERVED 4 // Do not use. Must be 0.

typedef struct CycleInfo {
    uint16_t direction;     // 
    uint8_t  low;           // 
    uint8_t  high;          // 
    uint32_t seconds;       // 
    uint32_t microseconds;  // 
    uint16_t pad;           // 
} CycleInfo;

/////////////////////////////////////////////////////////////////////////////////////////////////
// CMAP Chunk
/////////////////////////////////////////////////////////////////////////////////////////////////

#define MAXCOLORS 256

typedef struct RGBTriple {
	uint8_t r;  // 
	uint8_t g;  // 
	uint8_t b;  // 
} RGBTriple;

/////////////////////////////////////////////////////////////////////////////////////////////////
// CRNG Chunk
/////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct ColorRange {
    uint16_t pad;    // 
	uint16_t rate;   // 
	uint16_t flags;  // 
    uint8_t  low;    // 
    uint8_t  high;   // 
} ColorRange;

/////////////////////////////////////////////////////////////////////////////////////////////////
// DRNG Chunk
/////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct DRange {
   uint8_t  min;    // min cell value
   uint8_t  max;    // max cell value
   uint16_t rate;   // color cycling rate, 16384 = 60 steps/second
   uint16_t flags;  // 1=RNG_ACTIVE,4=RNG_DP_RESERVED
   uint8_t  ntrue;  // number of DColor structs to follow
   uint8_t  nregs;  // number of DIndex structs to follow
} DRange;

typedef struct DColor { 
	uint8_t cell;  // true color cell
	uint8_t r;     // 
	uint8_t g;     // 
	uint8_t b;     // 
} DColor;

typedef struct DIndex { 
	uint8_t cell;  // color register cell
	uint8_t index; // 
} DIndex;

/////////////////////////////////////////////////////////////////////////////////////////////////
// PicInfo Struct
/////////////////////////////////////////////////////////////////////////////////////////////////

typedef struct PicInfo {
	FILE      *file;        // File pointer
	uint32_t   type;        // File format (ILBM, PBM)
	uint32_t   camg;        // Amiga display mode
	uint32_t   isgray;      // TRUE if grayscale
	uint32_t   ncolors;     // Number of colors in color table
	uint32_t   rowsize;     // Bytes per bitplane row
	uint32_t   unpackSize;  // Unpacked size
	BMHD       bmhd;        // Bitmap header
	RGBTriple *cmap;        // Color table
	uint8_t   *body;        // Encoded bytes
	uint8_t   *bodyUnpack;  // Unpacked bytes
	uint8_t   *bodyBits;    // Decoded bytes (Unpacked + Desinterlaced)
} PicInfo;

/////////////////////////////////////////////////////////////////////////////////////////////////
// End of file
/////////////////////////////////////////////////////////////////////////////////////////////////
