
#include <stdio.h>
#include <string.h>
#include "m68k_disasm.h"

uint16 read16u  (uint16 *);
 int16 read16s  (uint16 *);
uint32 read32u  (uint16 *);
 int32 read32s  (uint16 *);
uint64 read64u  (uint16 *);

void addstr     (dis_buffer_t *, const char *);
void iaddstr    (dis_buffer_t *, const char *);

void prints     (dis_buffer_t *, uint64, uint8);
void printu     (dis_buffer_t *, uint64, uint8);
void prints_wb  (dis_buffer_t *, uint64, uint8, uint8);
void printu_wb  (dis_buffer_t *, uint64, uint8, uint8);

void iprints    (dis_buffer_t *, uint64, uint8);
void iprintu    (dis_buffer_t *, uint64, uint8);
void iprints_wb (dis_buffer_t *, uint64, uint8, uint8);
void iprintu_wb (dis_buffer_t *, uint64, uint8, uint8);

uint16 read16u(ushort * p) {
	return 
		((uint16) *  (uint8 *) p) << 8 | 
		 (uint16) * ((uint8 *) p + 1);
}

uint32 read32u(ushort * p) {
	return 
		((uint32) *  (uint8 *) p)      << 24 | 
		((uint32) * ((uint8 *) p + 1)) << 16 |
		((uint32) * ((uint8 *) p + 2)) <<  8 | 
		 (uint32) * ((uint8 *) p + 3);
}

int16 read16s(uint16 * p) {
	return (int16)
		((uint16) *  (uint8 *) p) << 8 | 
		 (uint16) * ((uint8 *) p + 1);
}

int32 read32s(uint16 * p) {
	return (int32)
		((uint32) *  (uint8 *) p)      << 24 | 
		((uint32) * ((uint8 *) p + 1)) << 16 |
		((uint32) * ((uint8 *) p + 2)) <<  8 | 
		 (uint32) * ((uint8 *) p + 3);
}

uint64 read64u(uint16 * p) {
	return ((((uint64)read32u(p)) << 32) + (read32u(p + 2)));
}

void addstr(dis_buffer_t * dbuf, const char * s) {
	while ((* dbuf->casm++ = * s++));
	dbuf->casm--;
}

void iaddstr(dis_buffer_t * dbuf, const char * s) {
	while (( * dbuf->cinfo++ = * s++))
	;
	dbuf->cinfo--;
}

void prints(dis_buffer_t * dbuf, uint64 val, uint8 sz) {
	
	if (val == 0)
	{
		dbuf->casm[0] = '0';
		dbuf->casm[1] = 0;
	}
	else if (sz == SIZE_BYTE)
		prints_wb(dbuf,  (uint8)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_WORD)
		prints_wb(dbuf, (uint16)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_LONG)
		prints_wb(dbuf, (uint32)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_QUAD)
		prints_wb(dbuf, (uint64)val, sz, dbuf->dp->radix);

	dbuf->casm = & dbuf->casm[strlen(dbuf->casm)];
}

void printu(dis_buffer_t * dbuf, uint64 val, uint8 sz) {
	
	if (val == 0)
	{
		dbuf->casm[0] = '0';
		dbuf->casm[1] = 0;
	}
	else if (sz == SIZE_BYTE)
		printu_wb(dbuf,  (uint8)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_WORD)
		printu_wb(dbuf, (uint16)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_LONG)
		printu_wb(dbuf, (uint32)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_QUAD)
		printu_wb(dbuf, (uint64)val, sz, dbuf->dp->radix);

	dbuf->casm = & dbuf->casm[strlen(dbuf->casm)];
}

void prints_wb(dis_buffer_t * dbuf, uint64 val, uint8 sz, uint8 base) {
	
	if (val < 0)
	{
		addchar('-');
		val = -val;
	}
	
	printu_wb(dbuf, val, sz, base);
}

void printu_wb(dis_buffer_t * dbuf, uint64 val, uint8 sz, uint8 base) {
	static char buf[sizeof(uint64) * NBBY / 3 + 2];
	char * p, ch;

	if (base == 2)
		addchar('%');
	else if (base == 8)
		addchar('0');
	else {
		base = 16;
		addchar('$');
	}
	
	p = buf;
	do {
		*++p = "0123456789abcdef" [val % base];
	} while (val /= base);

	while ((ch = * p--))
		addchar(ch);

	* dbuf->casm = 0;
}

void iprints(dis_buffer_t * dbuf, uint64 val, uint8 sz) {
	
	if (val == 0)
	{
		dbuf->cinfo[0] = '0';
		dbuf->cinfo[1] = 0;
	}
	else if (sz == SIZE_BYTE)
		iprints_wb(dbuf,  (uint8)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_WORD)
		iprints_wb(dbuf, (uint16)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_LONG)
		iprints_wb(dbuf, (uint32)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_QUAD)
		iprints_wb(dbuf, (uint64)val, sz, dbuf->dp->radix);
	
	dbuf->cinfo = & dbuf->cinfo[strlen(dbuf->cinfo)];
}

void iprintu(dis_buffer_t * dbuf, uint64 val, uint8 sz) {
	
	if (val == 0)
	{
		dbuf->cinfo[0] = '0';
		dbuf->cinfo[1] = 0;
	}
	else if (sz == SIZE_BYTE)
		iprintu_wb(dbuf,  (uint8)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_WORD)
		iprintu_wb(dbuf, (uint16)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_LONG)
		iprintu_wb(dbuf, (uint32)val, sz, dbuf->dp->radix);
	else if (sz == SIZE_QUAD)
		iprintu_wb(dbuf, (uint64)val, sz, dbuf->dp->radix);
	
	dbuf->cinfo = & dbuf->cinfo[strlen(dbuf->cinfo)];
}

void iprints_wb(dis_buffer_t * dbuf, uint64 val, uint8 sz, uint8 base) {
	
	if (val < 0) {
		iaddchar('-');
		val = -val;
	}
	
	iprintu_wb(dbuf, val, sz, base);
}

void iprintu_wb(dis_buffer_t * dbuf, uint64 val, uint8 sz, uint8 base) {
	static char buf[sizeof(uint64) * NBBY / 3 + 2];
	char * p, ch;

	if (base == 2)
		iaddchar('%');
	else if (base == 8)
		iaddchar('0');
	else {
		base = 16;
		iaddchar('$');
	}
	
	p = buf;
	do {
		*++p = "0123456789abcdef" [val % base];
	} while (val /= base);

	while ((ch = * p--))
		iaddchar(ch);

	* dbuf->cinfo = 0;
}
