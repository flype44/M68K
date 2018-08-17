/* $VER: m68k_ammx.c V0.1 (12.08.2018)
 * 
 * Disassembler module for the AC68080 AMMX processor unit
 * Copyright (c) 2016-2018  APOLLO-Team
 * All rights reserved.
 * 
 * For use with the "vda68k" disassembler project by Frank Wille.
 * http://aminet.net/package/dev/asm/vda68k
 * 
 * v0.1  (12.08.2018) flype
 *       Supports for all the AC68080 AMMX2 instruction set (GOLD2.x cores).
 */

#include <stdio.h>
#include <string.h>
#include "m68k_disasm.h"
#include "m68k_ammx.h"

/* extern */

extern uint16 read16u(uint16 *);
extern  int16 read16s(uint16 *);
extern uint32 read32u(uint16 *);
extern  int32 read32s(uint16 *);
extern uint64 read64u(uint16 *);

extern void addstr(dis_buffer_t *, const char *);
extern void prints(dis_buffer_t *, int32, int32);
extern void printu(dis_buffer_t *, uint64, int32);

/* consts */

const char *const ammx_aregs[8*2] = {
	"a0","a1","a2","a3","a4","a5","a6","a7",
	"b0","b1","b2","b3","b4","b5","b6","b7"
};

const char *const ammx_dregs[8*4] = {
	"d0","d1","d2","d3","d4","d5","d6","d7",
	"e0","e1","e2","e3","e4","e5","e6","e7",
	"e8","e9","e10","e11","e12","e13","e14","e15",
	"e16","e17","e18","e19","e20","e21","e22","e23"
};

const char *const ammx_opid[128] = {
	"AMMX"      ,	// 0 0 0 0 0 0  FREE
	"LOAD"      ,	// 0 0 0 0 0 1  
	"TRANSHI"   ,	// 0 0 0 0 1 0  
	"TRANSLO"   ,	// 0 0 0 0 1 1  
	"STORE"     ,	// 0 0 0 1 0 0  
	"STOREM"    ,	// 0 0 0 1 0 1  
	"PACKUSWB"  ,	// 0 0 0 1 1 0  
	"PACK3216"  ,	// 0 0 0 1 1 1  
	"PAND"      ,	// 0 0 1 0 0 0  
	"POR"       ,	// 0 0 1 0 0 1  
	"PEOR"      ,	// 0 0 1 0 1 0  
	"PANDN"     ,	// 0 0 1 0 1 1  
	"PAVGB"     ,	// 0 0 1 1 0 0  
	"AMMX"      ,	// 0 0 1 1 0 1  FREE
	"PABSB"     ,	// 0 0 1 1 1 0  
	"PABSW"     ,	// 0 0 1 1 1 1  
	"PADDB"     ,	// 0 1 0 0 0 0  
	"PADDW"     ,	// 0 1 0 0 0 1  
	"PSUBB"     ,	// 0 1 0 0 1 0  
	"PSUBW"     ,	// 0 1 0 0 1 1  
	"PADDusB"   ,	// 0 1 0 1 0 0  
	"PADDssW"   ,	// 0 1 0 1 0 1  
	"PSUBusB"   ,	// 0 1 0 1 1 0  
	"PSUBssW"   ,	// 0 1 0 1 1 1  
	"PMUL88"    ,	// 0 1 1 0 0 0  
	"PMULA"     ,	// 0 1 1 0 0 1  
	"PMULHW"    ,	// 0 1 1 0 1 0  
	"PMULLW"    ,	// 0 1 1 0 1 1  
	"BFLYB"     ,	// 0 1 1 1 0 0  OBSOLETE
	"BFLYW"     ,	// 0 1 1 1 0 1  
	"UNPACK1632",	// 0 1 1 1 1 0  
	"AMMX"      ,	// 0 1 1 1 1 1  FREE
	"PCMPeqB"   ,	// 1 0 0 0 0 0  
	"PCMPeqW"   ,	// 1 0 0 0 0 1  
	"PCMPhiB"   ,	// 1 0 0 0 1 0  
	"PCMPhiW"   ,	// 1 0 0 0 1 1  
	"STOREC"    ,	// 1 0 0 1 0 0  
	"STOREM2"   ,	// 1 0 0 1 0 1  
	"STOREM3"   ,	// 1 0 0 1 1 0  
	"AMMX"      ,	// 1 0 0 1 1 1  FREE
	"C2P"       ,	// 1 0 1 0 0 0  
	"BSEL"      ,	// 1 0 1 0 0 1  
	"MINTERM"   ,	// 1 0 1 0 1 0  
	"PIXMRG"    ,	// 1 0 1 0 1 1  
	"PCMPgeB"   ,	// 1 0 1 1 0 0  
	"PCMPgeW"   ,	// 1 0 1 1 0 1  
	"PCMPgtB"   ,	// 1 0 1 1 1 0  
	"PCMPgtW"   ,	// 1 0 1 1 1 1  
	"PMINsB"    ,	// 1 1 0 0 0 0  
	"PMINsW"    ,	// 1 1 0 0 0 1  
	"PMINuB"    ,	// 1 1 0 0 1 0  
	"PMINuW"    ,	// 1 1 0 0 1 1  
	"PMAXsB"    ,	// 1 1 0 1 0 0  
	"PMAXsW"    ,	// 1 1 0 1 0 1  
	"PMAXuB"    ,	// 1 1 0 1 1 0  
	"PMAXuW"    ,	// 1 1 0 1 1 1  
	"LSRQ"      ,	// 1 1 1 0 0 0  
	"LSLQ"      ,	// 1 1 1 0 0 1  
	"AMMX"      ,	// 1 1 1 0 1 0  FREE
	"DTX"       ,	// 1 1 1 0 1 1  
	"AMMX"      ,	// 1 1 1 1 0 0  FREE
	"AMMX"      ,	// 1 1 1 1 0 1  FREE
	"LEA3D"     ,	// 1 1 1 1 1 0  
	"AMMX"       	// 1 1 1 1 1 1  FREE
};

const int ammx_operand[128][3] = {
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_VEA  , AMMX_REGD1, AMMX_IGNORE },	// LOAD
	{ AMMX_REGA2, AMMX_REGD2, AMMX_IGNORE },	// TRANSHI
	{ AMMX_REGA2, AMMX_REGD2, AMMX_IGNORE },	// TRANSLO
	{ AMMX_REGB1, AMMX_VEA  , AMMX_IGNORE },	// STORE
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// STOREM
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PACKUSWB
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PACK3216
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PAND
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// POR
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PEOR
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PANDN
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PAVGB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PABSB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PABSW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PADDB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PADDW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PSUBB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PSUBW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PADDusB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PADDssW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PSUBusB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PSUBssW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMUL88
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMULA
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMULHW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMULLW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// BFLYB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// BFLYW
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// UNPACK3216
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPeqB
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPeqW
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPhiB
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPhiW
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// STOREC
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// STOREM2
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// STOREM3
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_VEA  , AMMX_REGD1, AMMX_IGNORE },	// C2P
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// BSEL
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// MINTERM
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PIXMRG
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPgeB
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPgeW
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPgtB
	{ AMMX_REGB1, AMMX_REGD1, AMMX_VEA    },	// PCMPgtW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMINsB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMINsW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMINuB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMINuW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMAXsB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMAXsW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMAXuB
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// PMAXuW
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// LSRQ
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// LSLQ
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// DTX
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// LEA3D
	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX

	// Specials (id+64)

	{ AMMX_VEA  , AMMX_REGB1, AMMX_REGD1  },	// AMMX
	{ AMMX_VEA  , AMMX_REGDF, AMMX_IGNORE },	// LOADi
	{ AMMX_REGA2, AMMX_REGDF, AMMX_IGNORE },	// TRANSHIi
	{ AMMX_REGA2, AMMX_REGDF, AMMX_IGNORE },	// TRANSLOi
	{ AMMX_REGBF, AMMX_VEA  , AMMX_IGNORE },	// STOREi
};

/* privates */

void ammx_vea_d8(dis_buffer_t * dbuf, uint16 op1, uint16 ext, uint16 pcrel) {
	uint32 disp = 0;

	if (pcrel) disp = (((ulong) dbuf->sval) + 4);
	disp += DOWNTO(ext, 7, 0);
	prints(dbuf, disp, SIZE_BYTE);
}
void ammx_vea_bd(dis_buffer_t * dbuf, uint16 op1, uint16 ext, uint16 pcrel) {
	uint32 disp = 0;

	if (DOWNTO(ext, 1, 0))
		addchar('['); /* indexed. */

	switch (DOWNTO(ext, 5, 4)) {
	case 0: // Reserved
	case 1: // Null
		addchar('0');
		break;
	case 2: // Word
		if (pcrel) disp = (((ulong) dbuf->sval) + 4);
		disp = read16s(dbuf->val + 3);
		prints(dbuf, disp, SIZE_WORD);
		dbuf->used++;
		break;
	case 3: // Long
		if (pcrel) disp = (((ulong) dbuf->sval) + 4);
		disp = read32s(dbuf->val + 3);
		prints(dbuf, disp, SIZE_LONG);
		dbuf->used++;
		dbuf->used++;
		break;
	}
}
void ammx_vea_an(dis_buffer_t * dbuf, uint16 op1, uint16 ext) {
	uint32 bita = BIT(op1, 8);
	uint32 rega = DOWNTO(op1, 2, 0);

	addchar(',');
	if (BIT(ext, 7))
		addchar('z');
	addstr(dbuf, ammx_aregs[rega + (bita ? 8 : 0)]);
}
void ammx_vea_pc(dis_buffer_t * dbuf, uint16 op1, uint16 ext) {

	addchar(',');
	if (BIT(ext, 7))
		addchar('z');
	addchar('p');
	addchar('c');
}
void ammx_vea_xn(dis_buffer_t * dbuf, uint16 op1, uint16 ext) {
	uint32 reg;

	if (BIT(ext, 6)) {
		addchar(',');
		addchar('0');
		return;
	}

	if (BIT(ext, 8) && DOWNTO(ext, 1, 0) && BIT(ext, 2))
		addchar(']'); /* post-indexed. */

	reg = DOWNTO(ext, 14, 12);	
	addchar(','); // XN
	addstr(dbuf, BIT(ext, 15) ? ammx_aregs[reg] : ammx_dregs[reg]);
	addchar('.'); // SIZE
	addchar(BIT(ext, 11) ? 'l' : 'w');
	addchar('*'); // SCALE
	addchar('0' + (1 << DOWNTO(ext, 10, 9)));
}
void ammx_vea_od(dis_buffer_t * dbuf, uint16 op1, uint16 ext) {
	uint32 disp;
	uint32 pos = 4;

	if (BIT(ext, 8) && DOWNTO(ext, 1, 0) && !BIT(ext, 2)) 
		addchar(']'); /* pre-indexed */

	if (DOWNTO(ext, 5, 4) == 3) 
		pos++; // bd is a long

	switch (DOWNTO(ext, 1, 0)) {
	case 0: // None
	case 1: // Null
		addchar(',');
		addchar('0');
		break;
	case 2: // Word
		disp = read16s(dbuf->val + pos);
		addchar(',');
		prints(dbuf, disp, SIZE_WORD);
		dbuf->used++;
		break;
	case 3: // Long
		disp = read32s(dbuf->val + pos);
		addchar(',');
		prints(dbuf, disp, SIZE_LONG);
		dbuf->used++;
		dbuf->used++;
		break;
	}
}
void ammx_vea   (dis_buffer_t * dbuf, uint16 op1) {
	uint16 ext;
	uint32 disp;
	uint32 bita = BIT(op1, 8);
	uint32 moda = DOWNTO(op1, 5, 3);
	uint32 rega = DOWNTO(op1, 2, 0);

	switch (moda) {
	case 0: // D0+n, E8+n
		addstr(dbuf, ammx_dregs[rega + (bita ? 16 : 0)]);
		break;
	case 1: // E0+n, E16+n
		addstr(dbuf, ammx_dregs[rega + (bita ? 24 : 8)]);
		break;
	case 2: // (An), (Bn)
		addchar('(');
		addstr(dbuf, ammx_aregs[rega + (bita ? 8 : 0)]);
		addchar(')');
		break;
	case 3: // (An)+, (Bn)+
		addchar('(');
		addstr(dbuf, ammx_aregs[rega + (bita ? 8 : 0)]);
		addchar(')');
		addchar('+');
		break;
	case 4: // -(An), -(Bn)
		addchar('-');
		addchar('(');
		addstr(dbuf, ammx_aregs[rega + (bita ? 8 : 0)]);
		addchar(')');
		break;
	case 5: // (d16,An), (d16,Bn) 
		disp = read16s(dbuf->val + 2);
		prints(dbuf, disp, SIZE_WORD);
		addchar('(');
		addstr(dbuf, ammx_aregs[rega + (bita ? 8 : 0)]);
		addchar(')');
		dbuf->used++;
		break;
	case 6: // (bd,An,Xn,od), (bd,Bn,Xn,od)
		ext = read16u(dbuf->val + 2);
		addchar('(');
		if (BIT(ext, 8)) {
			ammx_vea_bd(dbuf, op1, ext, 0);
			ammx_vea_an(dbuf, op1, ext);
			ammx_vea_xn(dbuf, op1, ext);
			ammx_vea_od(dbuf, op1, ext);
		} else {
			ammx_vea_d8(dbuf, op1, ext, 0);
			ammx_vea_an(dbuf, op1, ext);
			ammx_vea_xn(dbuf, op1, ext);
		}
		addchar(')');
		dbuf->used++;
		break;
	case 7:
		switch (rega) {
		case 0: // (xxx).W
			printu(dbuf, read16u(dbuf->val + 2), SIZE_WORD);
			addchar('.');
			addchar('w');
			dbuf->used++;
			break;
		case 1: // (xxx).L
			printu(dbuf, read32u(dbuf->val + 2), SIZE_LONG);
			addchar('.');
			addchar('l');
			dbuf->used++;
			dbuf->used++;
			break;
		case 2: // (d16,PC)
			disp = (((ulong) dbuf->sval) + 4);
			disp += read16s(dbuf->val + 2);
			prints(dbuf, disp, SIZE_WORD);
			addstr(dbuf, "(pc)");
			dbuf->used++;
			break;
		case 3: // (bd,PC,Xn,od)
			ext = read16u(dbuf->val + 2);
			addchar('(');
			if (BIT(ext, 8)) {
				ammx_vea_bd(dbuf, op1, ext, 1);
				ammx_vea_pc(dbuf, op1, ext);
				ammx_vea_xn(dbuf, op1, ext);
				ammx_vea_od(dbuf, op1, ext);
			} else {
				ammx_vea_d8(dbuf, op1, ext, 1);
				ammx_vea_pc(dbuf, op1, ext);
				ammx_vea_xn(dbuf, op1, ext);
			}
			addchar(')');
			dbuf->used++;
			break;
		case 4: // #<data>
			addchar('#');
			if (bita) {
				printu(dbuf, read16u(dbuf->val + 2), SIZE_WORD);
				addchar('.');
				addchar('w');
				dbuf->used++;
			} else {
				printu(dbuf, read64u(dbuf->val + 2), SIZE_QUAD);
				addchar('.');
				addchar('q');
				dbuf->used++;
				dbuf->used++;
				dbuf->used++;
				dbuf->used++;
			}
			break;
		case 5: // Reserved
		case 6: // Reserved
		case 7: // Reserved
			break;
		}
		break;
	}
}

void ammx_rega1(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	uint32 bita = BIT(op1, 8);
	uint32 rega = DOWNTO(op2, 3, 0);
	
	addstr(dbuf, ammx_dregs[rega + (bita ? 16 : 0)]);
}
void ammx_rega2(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	uint32 bita = BIT(op1, 8);
	uint32 rega = DOWNTO(op1, 2, 0);
	
	addstr(dbuf, ammx_dregs[((rega + 8) + (bita ? 16 : 0)) + 0]);
	addchar('-');
	addstr(dbuf, ammx_dregs[((rega + 8) + (bita ? 16 : 0)) + 3]);
}
void ammx_regaf(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	// Dummy
}
void ammx_regb1(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	uint32 bitb = BIT(op1, 7);
	uint32 regb = DOWNTO(op2, 15, 12);
	
	addstr(dbuf, ammx_dregs[regb + (bitb ? 16 : 0)]);
}
void ammx_regb2(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	// Dummy
}
void ammx_regbf(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	uint32 bitb = BIT(op1, 7);
	uint32 regb = DOWNTO(op2, 15, 12);
	
	addchar('[');
	addstr(dbuf, ammx_dregs[regb + (bitb ? 16 : 0)]);
	addchar(']');
}
void ammx_regd1(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	uint32 bitd = BIT(op1, 6);
	uint32 regd = DOWNTO(op2, 11, 8);
	
	addstr(dbuf, ammx_dregs[regd + (bitd ? 16 : 0)]);
}
void ammx_regd2(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	uint32 bitd = BIT(op1, 6);
	uint32 regd = DOWNTO(op2, 11, 8);
	
	addstr(dbuf, ammx_dregs[(regd + (bitd ? 16 : 0)) + 0]);
	addchar(':');
	addstr(dbuf, ammx_dregs[(regd + (bitd ? 16 : 0)) + 1]);
}
void ammx_regdf(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {
	uint32 bitd = BIT(op1, 6);
	uint32 regd = DOWNTO(op2, 11, 8);
	
	addchar('[');
	addstr(dbuf, ammx_dregs[regd + (bitd ? 16 : 0)]);
	addchar(']');
}

void ammx_vperm(dis_buffer_t * dbuf, uint16 op1, uint16 op2) {

	// VPERM #IMM32,A,B,D

	addstr(dbuf, "VPERM\t#");
	printu(dbuf, read32u(dbuf->val + 2), SIZE_LONG);
	addchar(',');
	ammx_rega1(dbuf, op1, op2);
	addchar(',');
	ammx_regb1(dbuf, op1, op2);
	addchar(',');
	ammx_regd1(dbuf, op1, op2);
	dbuf->used++;
	dbuf->used++;
}

/* publics */

void ammx_decode(dis_buffer_t * dbuf, uint16 op1) {

	// AMMX DECODER

	uint16 op2 = read16u(dbuf->val + 1);

	if (DOWNTO(op1, 5, 0) == 0b111111)
	{
		// AMMX MNEMONIC

		ammx_vperm(dbuf, op1, op2);
	}
	else
	{
		// AMMX MNEMONIC

		uint32 i  = 0;
		uint32 id = DOWNTO(op2, 5, 0);

		addstr(dbuf, ammx_opid[id]);

		switch (id) {
		case 1: // LOADi
		case 2: // TRANSLOi
		case 3: // TRANSHIi
			if(BIT(op2, 12)) addchar('i'), id += 64;
			break;
		case 4: // STOREi
			if(BIT(op2,  8)) addchar('i'), id += 64;
			break;
		}

		addchar('\t');

		// AMMX OPERANDS (up to 3 operands)

		for (i = 0; i < 3; i++) {
			switch(ammx_operand[id][i]) {
			case AMMX_VEA  : ammx_vea  (dbuf, op1); break;
			case AMMX_REGA1: ammx_rega1(dbuf, op1, op2); break;
			case AMMX_REGA2: ammx_rega2(dbuf, op1, op2); break;
			case AMMX_REGAF: ammx_regaf(dbuf, op1, op2); break;
			case AMMX_REGB1: ammx_regb1(dbuf, op1, op2); break;
			case AMMX_REGB2: ammx_regb2(dbuf, op1, op2); break;
			case AMMX_REGBF: ammx_regbf(dbuf, op1, op2); break;
			case AMMX_REGD1: ammx_regd1(dbuf, op1, op2); break;
			case AMMX_REGD2: ammx_regd2(dbuf, op1, op2); break;
			case AMMX_REGDF: ammx_regdf(dbuf, op1, op2); break;
			};
			if (i < 2 && ammx_operand[id][i + 1])
				addchar(',');
		}
	}

	dbuf->used++;
	addchar(0);
}

