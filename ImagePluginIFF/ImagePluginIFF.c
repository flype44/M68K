/////////////////////////////////////////////////////////////////////////////////////////////////
// ImagePluginIFF.c
// Author: flype
// Date:   2014-10-04
/////////////////////////////////////////////////////////////////////////////////////////////////

/* TODO:
 * 
 * LoadImageIFF() => Read body line by line
 * CatchImageIFF() => Load image from memory
 * 
 * [X] PBM8
 * [ ] PBM24
 * [x] ILBM8
 * [ ] ILBM24
 * [x] EHB
 * [x] HAM5/6
 * [ ] HAM7/8
 */

/////////////////////////////////////////////////////////////////////////////////////////////////
// INCLUDES
/////////////////////////////////////////////////////////////////////////////////////////////////

#include "ImagePluginIFF.h"
#include <stdio.h>
#include <string.h>
#include <malloc.h>

/////////////////////////////////////////////////////////////////////////////////////////////////
// PRIVATE FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////

RGBTriple* ColorMapEHB(RGBTriple* cmap, int num_colors)
{
	cmap = (RGBTriple*)realloc(cmap, num_colors * sizeof(RGBTriple) * 2);
	if (cmap) {
		int i;
		for (i = num_colors; i < num_colors * 2; i++) {
			cmap[i].r = (cmap[i - num_colors].r >> 1);
			cmap[i].g = (cmap[i - num_colors].g >> 1);
			cmap[i].b = (cmap[i - num_colors].b >> 1);
		}
	}
	return cmap;
}

RGBTriple* ColorMapGrayscale(int num_colors)
{
	RGBTriple* cmap = (RGBTriple*)calloc(num_colors, sizeof(RGBTriple));
	if (cmap) {
		int i;
		for (i = 0; i < num_colors; i++ )
			cmap[i].r = cmap[i].g = cmap[i].b = (i * 255 / num_colors);
	}
	return cmap;
}

int GetPixelHAM(RGBTriple *rgb, int pixel, int color, int depth)
{
    int r, g, b;
    
    switch ( pixel >> ( depth - 2 ) ) {
      case 0:
        r = rgb[pixel & 0x3F].r;
        g = rgb[pixel & 0x3F].g;
        b = rgb[pixel & 0x3F].b;
		break;
      case 1:
        r = RED(color);
        g = GREEN(color);
        b = ( pixel & 0x3F ) << ( 10 - depth );
		break;
      case 2:
        r = ( pixel & 0x3F ) << ( 10 - depth );
        g = GREEN(color);
        b = BLUE(color);
		break;
      case 3:
        r = RED(color);
        g = ( pixel & 0x3F ) << ( 10 - depth );
        b = BLUE(color);
		break;
	}
    
    return RGB(r, g, b);
}

int PlanarToChunky(uint8_t* src, uint8_t* dest, uint16_t width, uint16_t height, uint8_t depth)
{
	int x, y, p, bit;
	int a, b, c, d, e, f, g, h;
    
	//if(depth > 8) depth = 8;

	a = 0;
	b = 0;
    c = (((width + 15) >> 4) << 1);
	d = (depth * c);
    for(y = 0; y < height; y++) {
		a += d;
		b += width;
		e = 0;
		for(p = 0; p < depth; p++) {
			f = 1 << p;
			g = a + e;
			for(x = 0; x < c; x++) {
				h = b + (x << 3);
				for(bit = 0; bit < 8; bit++) {
					if(src[g] & (1 << (7 - bit))) dest[h] |= f;
					h++;
				}
				g++;
			}
			e += c;
		}
	}

	return TRUE;
}

int UnPackBits(uint8_t *src, uint8_t *dest, int dest_size)
{
    int result = FALSE;
	while(dest_size >= 0) {
		int8_t n = *src++;
		if(n >= 0) {
			n++;
			dest_size -= n;
			if(dest_size < 0) return result;
			while(n--) *dest++ = *src++;
		}
		else if(n > -128) {
			n = -n + 1;
			dest_size -= n;
			if(dest_size < 0) return result;
			while(n--) *dest++ = *src;
			*src++;
		}
	}
	return TRUE;
}

void DrawIFF8(PicInfo *pic, void (cbDrawPixel)(int x, int y, int color))
{
	int x, y;
	RGBTriple color;
	uint8_t *bits = pic->bodyBits;
	for(y = 0; y < pic->bmhd.h; y++) {
		for(x = 0; x < pic->bmhd.w; x++) {
			color = pic->cmap[*bits++];
			//scanlines: if(y % 2 == 0) { color.r >>= 1; color.g >>= 1; color.b >>= 1; }
			cbDrawPixel(x, y, RGB(color.r, color.g, color.b));
		}
	}
}

void DrawIFF24_old(PicInfo *pic, void (cbDrawPixel)(int x, int y, int color))
{
	int x, y; 
	uint8_t r, g, b;
	uint8_t *bits = pic->bodyBits;
	for(y = 0; y < pic->bmhd.h; y++) {
		for(x = 0; x < pic->bmhd.w; x++) {
			r = *bits++; 
			g = *bits++; 
			b = *bits++;
			cbDrawPixel(x, y, RGB(r, g, b));
		}
	}
}

void DrawIFF24(PicInfo *pic, void (cbDrawPixel)(int x, int y, int color))
{
	// http://sourceforge.net/p/recoil/code/ci/master/tree/recoil.ci

	// 24-bit or 32-bit true color
	int i,x,y,d;
	int pixelsCount;
	pixelsCount = pic->bmhd.w * pic->bmhd.h;
	x = 0;
	y = 0;
	for (i = 0; i < pixelsCount; i++) {
		int offset = (i >> 3 & ~1) * pic->bmhd.nPlanes + (i >> 3 & 1);
		int bit = ~i & 7;
		int c = 0;
		for (d = 24; --d >= 0; )
			c = c << 1 | pic->bodyBits[offset + (d << 1)] >> bit & 1;
		// 0xBBGGRR -> 0xRRGGBB
		cbDrawPixel(x, y, (c & 0xff) << 16 | (c & 0xff00) | c >> 16);
		x++;
		if(x>=pic->bmhd.w) { x = 0; y++; }
	}
}

void DrawHAM(PicInfo *pic, void (cbDrawPixel)(int x, int y, int color))
{
	int x, y, color;
	uint8_t *bits = pic->bodyBits;
	for(y = 0; y < pic->bmhd.h; y++) {
		color = 0x000000;
		for(x = 0; x < pic->bmhd.w; x++) {
			color = GetPixelHAM(pic->cmap, *bits++, color, pic->bmhd.nPlanes);
			cbDrawPixel(x, y, color);
		}
	}
}

PicInfo* FreeIFF(PicInfo *pic)
{
	if (pic) {
		if (pic->file)
			fclose(pic->file);
		if (pic->cmap)
			free(pic->cmap);
		if (pic->bodyUnpack)
			free(pic->bodyUnpack);
		if (pic->bodyBits && pic->bodyBits != pic->body)
			free(pic->bodyBits);
		if (pic->body)
			free(pic->body);
		free(pic);
	}
	return NULL;
}

PicInfo* ParseIFF(PicInfo *pic, uint8_t *buf, int buffer_size, errno_t *errno)
{
	// Read FORM header
	uint32_t ck[3];
	//uint8_t *buf = &*buffer;
	if (pic->file) fread(ck, 12, 1, pic->file); // Read from file
	else { memcpy(ck, buf, 12); *buf += 12; }  // Read from memory
	*errno=3;

	// Check FORM header
	if ((ck[0] == ID_FORM) && ((ck[2] == ID_ILBM) || (ck[2] == ID_PBM)))
	{
		// Remember FORM type
		pic->type = ck[2];

		// Remember FORM size
		ck[2] = BSWAP32(ck[1]);
		
		// Parse chunks
		*errno=4;
		while (1)
		{
			// Read chunk
			if (pic->file) { fread(ck, 8, 1, pic->file); *errno=41; } // Read from file
			else { memcpy(ck, buf, 8); *buf += 8; *errno=42; } // Read from memory
			ck[1] = BSWAP32(ck[1]);
			ck[1] += (ck[1] & 1);
			*errno=5;

			// Parse chunk
			if (ck[0] == ID_BODY) break;
			switch (ck[0])
			{
				case ID_BMHD: // Bitmap Header
					if (pic->file) fread(&pic->bmhd, ck[1], 1, pic->file); // Read from file
					else { memcpy(&pic->bmhd, buf, ck[1]); *buf += ck[1]; } // Read from memory
					pic->bmhd.w      = BSWAP16(pic->bmhd.w);
					pic->bmhd.h      = BSWAP16(pic->bmhd.h);
					pic->bmhd.tColor = BSWAP16(pic->bmhd.tColor);
					pic->bmhd.pw     = BSWAP16(pic->bmhd.pw);
					pic->bmhd.ph     = BSWAP16(pic->bmhd.ph);
					pic->rowsize     = (((pic->bmhd.w + 15) >> 4) << 1);
					*errno=6;
					break;

				case ID_CAMG: // Commodore Amiga flags
					if (pic->file) fread(&pic->camg, 1, 1, pic->file); // Read from file
					else { memcpy(&pic->camg, buf, 1); *buf++; } // Read from memory
					pic->camg = BSWAP32(pic->camg);
					*errno=7;
					break;

				case ID_CMAP: // ColorMap
					pic->ncolors = (ck[1] / 3);
					pic->cmap = (RGBTriple*)malloc(ck[1]);
					if (!pic->cmap) FreeIFF(pic);
					if (pic->file) fread(pic->cmap, ck[1], 1, pic->file); // Read from file
					else { memcpy(pic->cmap, buf, ck[1]); *buf += ck[1]; } // Read from memory
					*errno=8;
					break;

				default: // Ignore unsupported chunks.
					if (pic->file != NULL) fseek(pic->file, ck[1], SEEK_CUR);
					else *buf += ck[1];
					*errno=9;
					break;
			}

			// Check EOF
			if (pic->file != NULL) { if (ck[2] < (uint32_t)ftell(pic->file)) break; } // Read from file
			//else { if (ck[2] < (uint32_t)(*buf - *buffer)) break; } // Read from memory
		}

		// No BODY ?
		*errno=10;
		if (ck[0] != ID_BODY)
			return FreeIFF(pic);

		// No BMHD ?
		*errno=11;
		if (pic->bmhd.w == 0)
			return FreeIFF(pic);

		// Number of planes makes sense (1..8 and 24) ?
		*errno=12;
		if ((pic->bmhd.nPlanes > 8) && (pic->bmhd.nPlanes != 24))
			return FreeIFF(pic);

		// No CMAP ? If so, create a gray color table
		*errno=13;
		if (pic->bmhd.nPlanes <= 8 && !pic->cmap) {
			pic->ncolors = (1 << pic->bmhd.nPlanes); // 2^nPlanes
			pic->cmap = ColorMapGrayscale(pic->ncolors);
			if(!pic->cmap) return FreeIFF(pic);
			pic->isgray = TRUE;
		}

		// Is EHB ? If so, extend the color table
		*errno=14;
		if (pic->camg & CAMG_EHB) {
			pic->ncolors = 32;
			//pic->bmhd.nPlanes = 5;
			//pic->bmhd.nPlanes >>= 1; // nPlanes/2
			pic->cmap = ColorMapEHB(pic->cmap, pic->ncolors);
			if(!pic->cmap) return FreeIFF(pic);
			pic->ncolors = 64;
		}
	}
	//*errno=ck[0]; return FreeIFF(pic);

	// Allocate buffer for decoding bytes (unpack + desinterlace)
	*errno=15;
	pic->bodyBits = (uint8_t*)calloc(pic->bmhd.w * pic->bmhd.h, 32);
	if (!pic->bodyBits) return FreeIFF(pic);

	// Read Body
	*errno=16;
	pic->body = (uint8_t*)malloc(ck[1]);
	if (!pic->body) return FreeIFF(pic);
	if (pic->file) fread(pic->body, ck[1], 1, pic->file); // Read from file
	else { memcpy(pic->body, buf, ck[1]); *buf += ck[1]; } // Read from memory

	// Decode Body
	*errno=17;
	switch(pic->type) {
		case ID_ILBM: // (pic->body => UnPackBits? => PlanarToChunky => pic->bodyBits)
			switch(pic->bmhd.compression) {
				case cmpByteRun1:
					pic->unpackSize = (pic->rowsize * pic->bmhd.h * pic->bmhd.nPlanes);
					pic->bodyUnpack = (uint8_t*)calloc(pic->unpackSize * 2, 32);
					if(!pic->bodyUnpack) return FreeIFF(pic);
					UnPackBits(pic->body, pic->bodyUnpack, pic->unpackSize);
					PlanarToChunky(pic->bodyUnpack, pic->bodyBits, pic->bmhd.w, pic->bmhd.h, pic->bmhd.nPlanes);
					*errno=18;
					break;
				case cmpNone:
					PlanarToChunky(pic->body, pic->bodyBits, pic->bmhd.w, pic->bmhd.h, pic->bmhd.nPlanes);
					*errno=19;
					break;
			}
			break;
		case ID_PBM: // (pic->body => UnPackBits? => pic->bodyBits)
			switch(pic->bmhd.compression) {
				case cmpByteRun1:
					pic->unpackSize = (pic->rowsize * pic->bmhd.h * pic->bmhd.nPlanes);
					pic->bodyUnpack = (uint8_t*)calloc(pic->unpackSize * 2, 32);
					if(!pic->bodyUnpack) return FreeIFF(pic);
					UnPackBits(pic->body, pic->bodyBits, pic->unpackSize);
					*errno=20;
					break;
				case cmpNone:
					pic->bodyBits = pic->body;
					*errno=21;
					break;
			}
			break;
	}

	// Close file
	if (pic->file) {
		fclose(pic->file);
		pic->file = NULL;
	}

	// Return PicInfo
	return pic;
}

//===============================================================
// PUBLIC FUNCTIONS
//===============================================================

extern PicInfo* CatchImageIFF(uint8_t *data, int size)
{
	uint32_t ck[3];

	// Allocate PicInfo struct
	PicInfo *pic = (PicInfo*)calloc(sizeof(PicInfo), 1);
	if (!pic) return NULL;

	// Read FORM header
	memcpy(ck, data, 12); data += 12;

	if ((ck[0] == ID_FORM) && ((ck[2] == ID_ILBM) || (ck[2] == ID_PBM)))
	{
		// Remember FORM type
		pic->type = ck[2];

		// Remember FORM size
		ck[2] = BSWAP32(ck[1]);

		while (1)
		{
			// Parse chunks
			memcpy(ck, data, 8); data += 8;
			ck[1] = BSWAP32(ck[1]);
			ck[1] += (ck[1] & 1);
			if (ck[0] == ID_BODY) break;
			switch (ck[0])
			{
				case ID_BMHD:
					memcpy(&pic->bmhd, data, ck[1]); data += ck[1];
					pic->bmhd.w      = BSWAP16(pic->bmhd.w);
					pic->bmhd.h      = BSWAP16(pic->bmhd.h);
					pic->bmhd.tColor = BSWAP16(pic->bmhd.tColor);
					pic->bmhd.pw     = BSWAP16(pic->bmhd.pw);
					pic->bmhd.ph     = BSWAP16(pic->bmhd.ph);
					pic->rowsize     = (((pic->bmhd.w + 15) >> 4) << 1);
					break;
				case ID_CAMG:
					memcpy(&pic->camg, data, ck[1]); data += ck[1];
					pic->camg = BSWAP32(pic->camg);
					break;
				case ID_CMAP:
					pic->ncolors = (ck[1] / 3);
					pic->cmap = (RGBTriple*)malloc(ck[1]);
					memcpy(pic->cmap, data, ck[1]); data += ck[1];
					break;
				default:
					data += ck[1];
					break;
			}

			// Check EOF
			//if (ck[2] < (uint32_t)ftell(pic->file))
			//	break;
		}

		// No BODY ?
		if (ck[0] != ID_BODY)
			return FreeIFF(pic);

		// No BMHD ?
		if (pic->bmhd.w == 0)
			return FreeIFF(pic);

		// Number of planes makes sense ?
		if ((pic->bmhd.nPlanes > 8) && (pic->bmhd.nPlanes != 24))
			return FreeIFF(pic);

		// No CMAP ? If so, create a gray color table
		if (pic->bmhd.nPlanes <= 8 && !pic->cmap) {
			pic->ncolors = (1 << pic->bmhd.nPlanes); // 2^nPlanes
			pic->cmap = ColorMapGrayscale(pic->ncolors);
			if(!pic->cmap) return FreeIFF(pic);
			pic->isgray = TRUE;
		}

		// Is EHB ? If so, extend the color table
		if (pic->camg & CAMG_EHB) {
			pic->ncolors = 32;
			//pic->bmhd.nPlanes = 5;
			//pic->bmhd.nPlanes >>= 1; // nPlanes/2
			pic->cmap = ColorMapEHB(pic->cmap, pic->ncolors);
			if(!pic->cmap) return FreeIFF(pic);
			pic->ncolors = 64;
		}
	}

	// Allocate buffer for decoding bytes (unpack + desinterlace)
	pic->bodyBits = (uint8_t*)calloc(pic->bmhd.w * pic->bmhd.h, 32);
	if (!pic->bodyBits) return FreeIFF(pic);

	// Read the body
	pic->body = (uint8_t*)malloc(ck[1]);
	if (!pic->body) return FreeIFF(pic);
	memcpy(pic->body, data, ck[1]); data += ck[1];

	// Decode Body
	switch(pic->type) {
		case ID_ILBM:
			switch(pic->bmhd.compression) {
				case cmpByteRun1:
					pic->unpackSize = (pic->rowsize * pic->bmhd.h * pic->bmhd.nPlanes);
					pic->bodyUnpack = (uint8_t*)calloc(pic->unpackSize * 2, 32);
					if(!pic->bodyUnpack) return FreeIFF(pic);
					UnPackBits(pic->body, pic->bodyUnpack, pic->unpackSize);
					PlanarToChunky(pic->bodyUnpack, pic->bodyBits, pic->bmhd.w, pic->bmhd.h, pic->bmhd.nPlanes);
					break;
				case cmpNone:
					PlanarToChunky(pic->body, pic->bodyBits, pic->bmhd.w, pic->bmhd.h, pic->bmhd.nPlanes);
					break;
			}
			break;
		case ID_PBM:
			switch(pic->bmhd.compression) {
				case cmpByteRun1:
					pic->unpackSize = (pic->rowsize * pic->bmhd.h * pic->bmhd.nPlanes);
					pic->bodyUnpack = (uint8_t*)calloc(pic->unpackSize * 2, 32);
					if(!pic->bodyUnpack) return FreeIFF(pic);
					UnPackBits(pic->body, pic->bodyBits, pic->unpackSize);
					break;
				case cmpNone:
					// No-op
					break;
			}
			break;
	}
	
	// Return PicInfo
	return pic;
}

extern void DrawPaletteIFF(PicInfo *pic, void (cbDrawPalette)(int index, int color))
{
	int i = 0;
	RGBTriple color;

	for(i = 0; i < (int)pic->ncolors; i++) {
		color = pic->cmap[i];
		cbDrawPalette(i, RGB(color.r, color.g, color.b));
	}
}

extern void DrawImageIFF(PicInfo *pic, void (cbDrawPixel)(int x, int y, int color))
{
	// HAM5/6 or HAM7/8
	if (pic->camg & CAMG_HAM) { DrawHAM(pic, cbDrawPixel); return; }

	// IFF24 Truecolor
	if(pic->bmhd.nPlanes > 8) { DrawIFF24(pic, cbDrawPixel); return; }

	// IFF8 Indexed
	DrawIFF8(pic, cbDrawPixel);
}

extern void FreeImageIFF(PicInfo *pic)
{
	FreeIFF(pic);
}

extern uint32_t ImageDepthIFF(PicInfo *pic)
{
	return pic->bmhd.nPlanes;
}

extern uint32_t ImageWidthIFF(PicInfo *pic)
{
	return pic->bmhd.w;
}

extern uint32_t ImageWidthRatioIFF(PicInfo *pic)
{
	float ratio;
	uint32_t width;

	ratio = ((pic->bmhd.yAspect == 0) ? 1 : ((float)pic->bmhd.xAspect / (float)pic->bmhd.yAspect));
	width = (uint32_t)(pic->bmhd.w * ratio);
	
	return ((pic->camg & CAMG_HIRES) ? width /** 2*/ : width);
}

extern uint32_t ImageHeightIFF(PicInfo *pic)
{
	return pic->bmhd.h;
}

extern uint32_t ImageHeightRatioIFF(PicInfo *pic)
{
	float ratio;
	uint32_t height;

	ratio = ((pic->bmhd.yAspect == 0) ? 1 : ((float)pic->bmhd.xAspect / (float)pic->bmhd.yAspect));
	height = (uint32_t)(pic->bmhd.h / ratio);
	
	return ((pic->camg & CAMG_LACE) ? height /** 2*/ : height);
}

extern uint32_t IsImageIFF(PicInfo *pic)
{
	return ((pic != NULL) && (sizeof(pic) == sizeof(PicInfo)) && pic->body);
}

extern PicInfo* LoadImageIFF(const char* filename)
{
	uint32_t ck[3];

	// Allocate PicInfo struct
	PicInfo *pic = (PicInfo*)calloc(sizeof(PicInfo), 1);
	if (!pic) return NULL;

	// Open file
	pic->file = fopen(filename, "rb");
	if (!pic->file) return FreeIFF(pic);

	// Read FORM header
	fread(ck, 12, 1, pic->file);
	if ((ck[0] == ID_FORM) && ((ck[2] == ID_ILBM) || (ck[2] == ID_PBM)))
	{
		// Remember FORM type
		pic->type = ck[2];

		// Remember FORM size
		ck[2] = BSWAP32(ck[1]);

		while (1)
		{
			// Parse chunks
			fread(ck, 8, 1, pic->file);
			ck[1] = BSWAP32(ck[1]);
			ck[1] += (ck[1] & 1);
			if (ck[0] == ID_BODY) break;
			switch (ck[0])
			{
				case ID_BMHD:
					fread(&pic->bmhd, ck[1], 1, pic->file);
					pic->bmhd.w      = BSWAP16(pic->bmhd.w);
					pic->bmhd.h      = BSWAP16(pic->bmhd.h);
					pic->bmhd.tColor = BSWAP16(pic->bmhd.tColor);
					pic->bmhd.pw     = BSWAP16(pic->bmhd.pw);
					pic->bmhd.ph     = BSWAP16(pic->bmhd.ph);
					pic->rowsize     = (((pic->bmhd.w + 15) >> 4) << 1);
					break;
				case ID_CAMG:
					fread(&pic->camg, ck[1], 1, pic->file);
					pic->camg = BSWAP32(pic->camg);
					break;
				case ID_CMAP:
					pic->ncolors = (ck[1] / 3);
					pic->cmap = (RGBTriple*)malloc(ck[1]);
					fread(pic->cmap, ck[1], 1, pic->file);
					break;
				default:
					fseek(pic->file, ck[1], SEEK_CUR);
					break;
			}

			// Check EOF
			if (ck[2] < (uint32_t)ftell(pic->file))
				break;
		}

		// No BODY ?
		if (ck[0] != ID_BODY)
			return FreeIFF(pic);

		// No BMHD ?
		if (pic->bmhd.w == 0)
			return FreeIFF(pic);

		// Number of planes makes sense ?
		if ((pic->bmhd.nPlanes > 8) && (pic->bmhd.nPlanes != 24))
			return FreeIFF(pic);

		// No CMAP ? If so, create a gray color table
		if (pic->bmhd.nPlanes <= 8 && !pic->cmap) {
			pic->ncolors = (1 << pic->bmhd.nPlanes); // 2^nPlanes
			pic->cmap = ColorMapGrayscale(pic->ncolors);
			if(!pic->cmap) return FreeIFF(pic);
			pic->isgray = TRUE;
		}

		// Is EHB ? If so, extend the color table
		if (pic->camg & CAMG_EHB) {
			pic->ncolors = 32;
			//pic->bmhd.nPlanes = 5;
			//pic->bmhd.nPlanes >>= 1; // nPlanes/2
			pic->cmap = ColorMapEHB(pic->cmap, pic->ncolors);
			if(!pic->cmap) return FreeIFF(pic);
			pic->ncolors = 64;
		}
	}

	// Allocate buffer for decoding bytes (unpack + desinterlace)
	pic->bodyBits = (uint8_t*)calloc(pic->bmhd.w * pic->bmhd.h, 32);
	if (!pic->bodyBits) return FreeIFF(pic);

	// Read the body
	pic->body = (uint8_t*)malloc(ck[1]);
	if (!pic->body) return FreeIFF(pic);
	fread(pic->body, ck[1], 1, pic->file);

	// Decode Body
	switch(pic->type) {
		case ID_ILBM:
			switch(pic->bmhd.compression) {
				case cmpByteRun1:
					pic->unpackSize = (pic->rowsize * pic->bmhd.h * pic->bmhd.nPlanes);
					pic->bodyUnpack = (uint8_t*)calloc(pic->unpackSize * 2, 32);
					if(!pic->bodyUnpack) return FreeIFF(pic);
					UnPackBits(pic->body, pic->bodyUnpack, pic->unpackSize);
					PlanarToChunky(pic->bodyUnpack, pic->bodyBits, pic->bmhd.w, pic->bmhd.h, pic->bmhd.nPlanes);
					break;
				case cmpNone:
					PlanarToChunky(pic->body, pic->bodyBits, pic->bmhd.w, pic->bmhd.h, pic->bmhd.nPlanes);
					break;
			}
			break;
		case ID_PBM:
			switch(pic->bmhd.compression) {
				case cmpByteRun1:
					pic->unpackSize = (pic->rowsize * pic->bmhd.h * pic->bmhd.nPlanes);
					pic->bodyUnpack = (uint8_t*)calloc(pic->unpackSize * 2, 32);
					if(!pic->bodyUnpack) return FreeIFF(pic);
					UnPackBits(pic->body, pic->bodyBits, pic->unpackSize);
					break;
				case cmpNone:
					// No-op
					break;
			}
			break;
	}

	// Close file
	fclose(pic->file);
	pic->file = NULL;

	// Return PicInfo
	return pic;
}

extern PicInfo* CatchImageIFF_OLD(uint8_t *data, int size, errno_t *errno)
{
	// Allocate PicInfo struct
	PicInfo *pic = (PicInfo*)calloc(sizeof(PicInfo), 1);
	if (!pic) return NULL;
	*errno=1;

	return ParseIFF(pic, data, size, errno);
}

extern PicInfo* LoadImageIFF_OLD(const char* filename, errno_t *errno)
{
	// Allocate PicInfo struct
	PicInfo *pic = (PicInfo*)calloc(sizeof(PicInfo), 1);
	if (!pic) return NULL;
	*errno=1;

	// Open file
	pic->file = fopen(filename, "rb");
	if (!pic->file) return FreeIFF(pic);
	*errno=2;

	return ParseIFF(pic, NULL, 0, errno);
}

//===============================================================
// END OF FILE
//===============================================================
