/************************************************************************************
 * Program: DisLib080
 * Short:   A simple 68080 Disassembler
 * Authors: APOLLO-Team, flype
 * Update:  Oct-2016
 * Compile: gcc dislib.c -o dislib
 ************************************************************************************
 * OUTPUTS           ==> Push chars to a own buffer
 * OUTPUTS           ==> Illegal instructions
 * EFFECTIVE ADDRESS ==> Correct commas positioning
 * EFFECTIVE ADDRESS ==> #imm 16 or 32 (propagate size)
 * EFFECTIVE ADDRESS ==> Resolve PC Relative address
 * DECODE_LABEL()    ==> Resolve Correct Relative address
 * DIVxL             ==> Implements
 ************************************************************************************
 * Useful links
 * http://www.apollo-core.com/bringup/decoder_cpu.ods
 * https://www.tutorialspoint.com/c_standard_library/stdarg_h.htm
 * https://www.tutorialspoint.com/c_standard_library/stdio_h.htm
 * https://www.tutorialspoint.com/c_standard_library/stdlib_h.htm
 * https://www.tutorialspoint.com/c_standard_library/string_h.htm
 ***********************************************************************************/

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include "dislib.h"

/************************************************************************************
 * ARRAYS
 ***********************************************************************************/

char buf[200];
char* buff = &buf[0];

int wordcount = 0;

char cr[ 16]; // Control-Register
char ea[100]; // Effective-Address
char dump[50]; // Opcodes-HexDump

char AB[2] = { 'a', 'b' };
char DA[2] = { 'd', 'a' };
char LR[2] = { 'R', 'L' };
char WL[2] = { 'w', 'l' };
char SC[4] = { '1', '2', '4', '8' };
char SZ[4] = { 'b', 'w', 'l', 'q' };

char* CC[16] = { "T ", "F ", "HI", "LS", "CC", "CS", "NE", "EQ",
                 "VC", "VS", "PL", "MI", "GE", "LT", "GT", "LE" };

/************************************************************************************
 * DECODE - UTILS
 ***********************************************************************************/

void OUT(const char *fmt, ...)
{
	va_list argv;
	va_start(argv, fmt);
	buff += vsprintf(buff, fmt, argv);
	va_end(argv);
	return;
}

APTR READWORD(APTR p, APTR op) {
	*op = *p++;
	sprintf(dump + (5 * wordcount), "%04x ", *op);
	wordcount++;
	return p;
}
APTR READLONG(APTR p, APTR ex) {
	UINT16 h = *p++;
	UINT16 l = *p++;
	*ex = h << 16 | l;
	sprintf(dump + (wordcount*5), "%04x %04x", h, l);
	wordcount += 2;
	return p;
}

void DECODE_CREG(int reg) {
	sprintf(cr, "");
	switch (reg) {
		case 0x000: sprintf(cr, "SFC"        ); break;
		case 0x001: sprintf(cr, "DFC"        ); break;
		case 0x002: sprintf(cr, "CACR"       ); break;
		case 0x003: sprintf(cr, "TC"         ); break;
		case 0x004: sprintf(cr, "ITT0/IACR0" ); break;
		case 0x005: sprintf(cr, "ITT1/IACR1" ); break;
		case 0x006: sprintf(cr, "DACR0/DTT0" ); break;
		case 0x007: sprintf(cr, "DACR1/DTT1" ); break;
		case 0x800: sprintf(cr, "USP"        ); break;
		case 0x801: sprintf(cr, "VBR"        ); break;
		case 0x802: sprintf(cr, "CAAR"       ); break;
		case 0x803: sprintf(cr, "MSP"        ); break;
		case 0x804: sprintf(cr, "ISP"        ); break;
		case 0x805: sprintf(cr, "MMUSR"      ); break;
		case 0x806: sprintf(cr, "URP"        ); break;
		case 0x807: sprintf(cr, "SRP"        ); break;
	}
}
void DECODE_LIST(UINT16 op, UINT16 ex) {
	
	// Decode a MOVEM registers list.
	// The algorithm is borrowed from IRA 2.08
	
	int i = 0;
	
	if (!ex) {
		OUT("#0"); // No Register
		return;
	}
	
	if (DOWNTO(op, 5, 3) == 4) // EAMODE = -(An)
	{
		while(ex) {
			if (ex & 0x8000) {
				if (i < 8) OUT("d");
				else OUT("a");
				OUT("%i", i & 7);
				if ((ex & 0x4000) && (i & 7) < 7) {
					OUT("-");
					while ((ex & 0x4000) && (i & 7) < 7) {
						ex <<= 1;
						i++;
					}
					if (i < 8) OUT("d");
					else OUT("a");
					OUT("%i", i & 7);
				}
				if ((UINT16)(ex << 1)) OUT("/");
			}
			i++;
			ex <<= 1;
		}
	}
	else
	{
		while(ex || i < 16) {
			if (ex & 0x0001) {
				if (i < 8) OUT("d");
				else OUT("a");
				OUT("%i", i & 7);
				if ((ex & 0x0002) && (i & 7) < 7) {
					OUT("-");
					while((ex & 0x0002) && (i & 7) < 7) {
						ex >>= 1;
						i++;
					}
					if (i < 8) OUT("d");
					else OUT("a");
					OUT("%i", i & 7);
				}
				if (ex >> 1) OUT("/");
			}
			i++;
			ex >>= 1;
		}
	}
}

APTR DECODE_EA_EXT(APTR p, UINT16 mode, UINT16 reg, int breg) {
	UINT16 l, h, ex, iis;
	char bd[1+8+2+1];
	char an[1+  2+1];
	char xn[2+2+2+1];
	char od[1+8+2+1];
	if (mode == 7) sprintf(an, "PC");
	else sprintf(an, "%c%i", AB[breg], reg);
	p = READWORD(p, &ex);
	sprintf(xn, "%c%i.%c*%c",
		DA[BIT   (ex, 15    )],
		   DOWNTO(ex, 14, 12), 
		WL[BIT   (ex, 11    )],
		SC[DOWNTO(ex, 10,  9)] 
	);
	if (BIT(ex, 8)) {
		switch (DOWNTO(ex, 5, 4)) {
			case 3:
				p = READWORD(p, &h);
				p = READWORD(p, &l);
				sprintf(bd, "$%08x.l", h << 16 | l);
				break;
			case 2:
				p = READWORD(p, &l);
				sprintf(bd, "$%04x.w", l);
				break;
			case 1:
			case 0: sprintf(bd, ""); break;
		}
		iis = DOWNTO(ex, 2, 0);
		switch (iis) {
			case 3:
			case 7:
				p = READWORD(p, &h);
				p = READWORD(p, &l);
				sprintf(od, ",$%08x.l", h << 16 | l);
				break;
			case 2:
			case 6:
				p = READWORD(p, &l);
				sprintf(od, ",$%04x.w", l);
				break;
			default:
				sprintf(od, "");
				break;
		}
		sprintf(ea, "(%s%s%s%s%s%s%s)",
			( iis > 0    ) ? "[" : "", bd,
			( BIT(ex, 5) ) ? ""  : an,
			( iis > 4    ) ? "]" : "",
			( BIT(ex, 6) ) ? ""  : xn,
			( iis > 4    ) ? ""  : "]", od);
	}
	else {
		sprintf(ea, "$%02x(%s,%s)", DOWNTO(ex, 7,  0), an, xn);
	}
	return p;
}
APTR DECODE_EA2(APTR p, UINT16 mode, UINT16 reg, int breg, int size) {
	UINT16 h, l;
	sprintf(ea, "");
	switch (mode) {
		case 0: sprintf(ea, "d%i", reg); break;
		case 1: sprintf(ea, "%c%i", AB[breg], reg); break;
		case 2: sprintf(ea, "(%c%i)", AB[breg], reg); break;
		case 3: sprintf(ea, "(%c%i)+", AB[breg], reg); break;
		case 4: sprintf(ea, "-(%c%i)", AB[breg], reg); break;
		case 5:
			p = READWORD(p, &l);
			sprintf(ea, "$%x(%c%i)", l, AB[breg], reg);
			break;
		case 6:
			p = DECODE_EA_EXT(p, mode, reg, breg);
			break;
		case 7:
			switch (reg) {
				case 0:
					p = READWORD(p, &l);
					sprintf(ea, "$%04x.w", l);
					break;
				case 1:
					p = READWORD(p, &h);
					p = READWORD(p, &l);
					sprintf(ea, "$%08x.l", h << 16 | l);
					break;
				case 2:
					p = READWORD(p, &l);
					sprintf(ea, "$%x(pc)", ((int)p) - 2 + ((short)l));
					break;
				case 3:
					p = DECODE_EA_EXT(p, mode, reg, breg);
					break;
				case 4:
					switch (size) {
						case 0:
							p = READWORD(p, &h);
							sprintf(ea, "#$%02x", (UINT8)h);
							break;
						case 1:
							p = READWORD(p, &h);
							sprintf(ea, "#$%04x", h);
							break;
						case 2:
							p = READWORD(p, &h);
							p = READWORD(p, &l);
							sprintf(ea, "#$%08x", h << 16 | l);
							break;
						case 3:
							sprintf(ea, "<?>");
							break;
					}
					break;
				case 5:
				case 6:
				case 7:
					sprintf(ea, "<?>");
					break;
			}
			break;
	}
	return p;
}
APTR DECODE_EA1(APTR p, UINT16 op, int breg, int size) {
	return DECODE_EA2(p, DOWNTO(op, 5, 3), DOWNTO(op, 2, 0), breg, size);
}
APTR DECODE_EA(APTR p, UINT16 op) {
	return DECODE_EA2(p, DOWNTO(op, 5, 3), DOWNTO(op, 2, 0), 0, 0);
}

APTR DECODE_IM_EA(APTR p, UINT16 op, int size) {
	// INSTRUCTION #<data>,<ea>
	UINT16 l, h;
	switch (size) {
		case 0: // Byte
			p = READWORD(p, &h);
			OUT("#$%02x", (UINT8)h);
			break;
		case 1: // Word
			p = READWORD(p, &h);
			OUT("#$%04x", h);
			break;
		case 2: // Long
			p = READWORD(p, &h);
			p = READWORD(p, &l);
			OUT("#$%08x", h << 16 | l);
			break;
	}
	p = DECODE_EA(p, op);
	OUT(",%s", ea);
	return p;
}
APTR DECODE_RN_EA(APTR p, UINT16 op, UINT16 ex) {
	// INSTRUCTION <ea>,Rn
	// INSTRUCTION Rn,<ea>
	p = DECODE_EA1(p, op, BIT(op, 8), 0);
	if (BIT(ex, 11)) // Direction
		OUT("%c%i,%s", BIT(op, 7) ? 'b' : DA[BIT(ex, 15)], DOWNTO(ex, 14, 12), ea);
	else
		OUT("%s,%c%i", ea, BIT(op, 7) ? 'b' : DA[BIT(ex, 15)], DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_DN_EA(APTR p, UINT16 op, int dir) {
	// INSTRUCTION <ea>,Dn
	// INSTRUCTION Dn,<ea>
	p = DECODE_EA(p, op);
	if (dir)
		OUT("d%i,%s", DOWNTO(op, 11, 9), ea);
	else
		OUT("%s,d%i", ea, DOWNTO(op, 11, 9));
	return p;
}

APTR DECODE_LABEL(APTR p, UINT16 op, int size) { // FIXME: Resolve correct relative address
	// <label>
	UINT16 lo, hi;
	switch (size) {
		case 0:
			OUT("$%x", ((int)p) - 0 + ((char)(DOWNTO(op, 7, 0))));
			break;
		case 1:
			p = READWORD(p, &hi);
			OUT("$%x", ((int)p) - 2 + ((short)hi));
			break;
		case 2:
			p = READWORD(p, &hi);
			p = READWORD(p, &lo);
			OUT("$%x", ((int)p) - 4 + ((int)((hi << 16) | lo)));
			break;
	}
	return p;
}
APTR DECODE_BRANCH(APTR p, UINT16 op) {
	switch (DOWNTO(op, 7, 0)) {
		case 0x00: OUT(".w   "); return DECODE_LABEL(p, op, 1);
		case 0xff: OUT(".l   "); return DECODE_LABEL(p, op, 2);
		default:   OUT(".s   "); return DECODE_LABEL(p, op, 0);
	}
}

/************************************************************************************
 * DECODE - 68000 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_000_ABCD(APTR p, UINT16 op) {
	// ABCD Dx,Dy
	// ABCD -(Ax),-(Ay)
	OUT("ABCD    ");
	OUT(BIT(op, 3) ? "-(a%i),-(a%i)" : "d%i,d%i", 
		DOWNTO(op, 2, 0), DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_NBCD(APTR p, UINT16 op) {
	// NBCD <ea>
	p = DECODE_EA(p, op);
	OUT("NBCD    %s", ea);
	return p;
}
APTR DECODE_000_SBCD(APTR p, UINT16 op) {
	// SBCD Dx,Dy
	// SBCD -(Ax),-(Ay)
	OUT("SBCD    ");
	OUT(BIT(op, 3) ? "-(a%i),-(a%i)" : "d%i,d%i", 
		DOWNTO(op, 2, 0), DOWNTO(op, 11, 9));
	return p;
}

APTR DECODE_000_ADD(APTR p, UINT16 op, int size, int dir) {
	// ADD <ea>,Dn
	// ADD Dn,<ea>
	OUT("ADD.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_ADDA(APTR p, UINT16 op, int size) {
	// ADDA <ea>,An
	p = DECODE_EA(p, op);
	OUT("ADDA.%c  %s,a%i", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_ADDI(APTR p, UINT16 op, int size) {
	// ADDI #<data>,<ea>
	OUT("ADDI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_ADDQ(APTR p, UINT16 op, int size) {
	// ADDQ #<data>,<ea>
	int data = DOWNTO(op, 11, 9);
	p = DECODE_EA(p, op);
	OUT("ADDQ.%c  #$%x,%s", SZ[size], data == 0 ? 8 : data, ea);
	return p;
}
APTR DECODE_000_ADDX_DN_DN(APTR p, UINT16 op, int size) {
	// ADDX Dx,Dy
	OUT("ADDX.%c  d%i,d%i", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_ADDX_AN_AN(APTR p, UINT16 op, int size) {
	// ADDX -(Ay),-(Ax)
	OUT("ADDX.%c  -(a%i),-(a%i)", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_AND(APTR p, UINT16 op, int size, int dir) {
	// AND <ea>,Dn
	// AND Dn,<ea>
	OUT("AND.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_ANDI(APTR p, UINT16 op, int size) {
	// ANDI #<data>,<ea>
	OUT("ANDI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_ANDI_CCR(APTR p, UINT16 op) {
	// ANDI #<data>,CCR
	UINT16 h;
	p = READWORD(p, &h);
	OUT("ANDI    #%02x,CCR", (UINT8)h);
	return p;
}
APTR DECODE_000_ANDI_SR(APTR p, UINT16 op) {
	// ANDI #<data>,SR
	UINT16 h;
	p = READWORD(p, &h);
	OUT("ANDI    #%04x,SR", h);
	return p;
}
APTR DECODE_000_BKPT(APTR p, UINT16 op) {
	// BKPT #<data>
	OUT("BKPT    #$%x", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_BRA(APTR p, UINT16 op) {
	// BRA <label>
	OUT("BRA");
	return DECODE_BRANCH(p, op);
}
APTR DECODE_000_BSR(APTR p, UINT16 op) {
	// BSR <label>
	OUT("BSR");
	return DECODE_BRANCH(p, op);
}
APTR DECODE_000_BCC(APTR p, UINT16 op) {
	// Bcc <label>
	OUT("B%s", CC[DOWNTO(op, 11, 8)]);
	return DECODE_BRANCH(p, op);
}
APTR DECODE_000_DBCC(APTR p, UINT16 op) {
	// DBcc.W Dn,<label>
	OUT("DB%s.w  d%x,", CC[DOWNTO(op, 11, 8)], DOWNTO(op, 2, 0));
	return DECODE_LABEL(p, op, 1);
}
APTR DECODE_000_BIT_D(APTR p, UINT16 op, char* name) {
	// BCHG Dn,<ea>    BCLR Dn,<ea>
	// BSET Dn,<ea>    BTST Dn,<ea>
	p = DECODE_EA(p, op);
	OUT("%s    d%i,%s", name, DOWNTO(op, 11, 9), ea);
	return p;
}
APTR DECODE_000_BIT_S(APTR p, UINT16 op, char* name) {
	// BCHG #<data>,<ea>    BCLR #<data>,<ea>
	// BSET #<data>,<ea>    BTST #<data>,<ea>
	UINT16 h;
	p = READWORD(p, &h);
	p = DECODE_EA(p, op);
	OUT("%s    #$%x,%s", name, (UINT8)h, ea);
	return p;
}
APTR DECODE_000_CHK(APTR p, UINT16 op, int size) {
	// CHK <ea>,Dn
	p = DECODE_EA(p, op);
	OUT("CHK.%c   %s,d%i", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_CLR(APTR p, UINT16 op, int size) {
	// CLR <ea>
	p = DECODE_EA(p, op);
	OUT("CLR.%c   %s", SZ[size], ea);
	return p;
}
APTR DECODE_000_CMP(APTR p, UINT16 op, int size) {
	// CMP <ea>,Dn
	p = DECODE_EA(p, op);
	OUT("CMP.%c   %s,d%i", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_CMPA(APTR p, UINT16 op, int size) {
	// CMPA <ea>,An
	p = DECODE_EA(p, op);
	OUT("CMPA.%c  %s,a%i", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_CMPI(APTR p, UINT16 op, int size) {
	// CMPI #<data>,<ea>
	OUT("CMPI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_CMPM(APTR p, UINT16 op, int size) {
	// CMPM (Ax)+,(Ay)+
	OUT("CMPM.%c  (a%i)+,(a%i)+", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_DIVS(APTR p, UINT16 op) {
	// DIVS.W <ea>,Dn
	p = DECODE_EA(p, op);
	OUT("DIVS.W  %s,d%i", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_DIVU(APTR p, UINT16 op) {
	// DIVU.W <ea>,Dn
	p = DECODE_EA(p, op);
	OUT("DIVU.W  %s,d%i", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_EXG(APTR p, UINT16 op) {
	// EXG Dm,Dn
	// EXG Ax,Ay
	// EXG Dn,An
	OUT("EXG     ");
	switch (DOWNTO(op, 7, 3)) {
		case  8: OUT("d%i,d%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0)); break;
		case  9: OUT("a%i,a%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0)); break;
		case 17: OUT("d%i,a%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0)); break;
	}
	return p;
}
APTR DECODE_000_EOR(APTR p, UINT16 op, int size) {
	// EOR Dn,<ea>
	OUT("EOR.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, 1);
}
APTR DECODE_000_EORI(APTR p, UINT16 op, int size) {
	// EORI #<data>,<ea>
	OUT("EORI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_EORI_CCR(APTR p, UINT16 op) {
	// EORI #<data>,CCR
	UINT16 h;
	p = READWORD(p, &h);
	OUT("EORI    #$%02x,CCR", (UINT8)h);
	return p;
}
APTR DECODE_000_EORI_SR(APTR p, UINT16 op) {
	// EORI #<data>,SR
	UINT16 h;
	p = READWORD(p, &h);
	OUT("EORI    #$%04x,SR", h);
	return p;
}
APTR DECODE_000_EXT(APTR p, UINT16 op, int size) {
	// EXT Dn
	OUT("EXT.%c  d%i", SZ[size], DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_ILLEGAL(APTR p, UINT16 op) {
	// ILLEGAL
	OUT("ILLEGAL");
	return p;
}
APTR DECODE_000_JMP(APTR p, UINT16 op) {
	// JMP <ea>
	p = DECODE_EA(p, op);
	OUT("JMP     %s", ea);
	return p;
}
APTR DECODE_000_JSR(APTR p, UINT16 op) {
	// JSR <ea>
	p = DECODE_EA(p, op);
	OUT("JSR     %s", ea);
	return p;
}
APTR DECODE_000_LEA(APTR p, UINT16 op) {
	// LEA <ea>,An
	p = DECODE_EA(p, op);
	OUT("LEA     %s,a%i", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_LINK(APTR p, UINT16 op) {
	// LINK An,#<displacement>
	UINT16 h;
	p = READWORD(p, &h);
	OUT("LINK.W  a%i,#$%04x", DOWNTO(op, 2, 0), h);
	return p;
}
APTR DECODE_000_PEA(APTR p, UINT16 op) {
	// PEA <ea>
	p = DECODE_EA(p, op);
	OUT("PEA     %s", ea);
	return p;
}
APTR DECODE_000_MOVE_CCR(APTR p, UINT16 op, int dir) {
	// MOVE <ea>,CCR
	// MOVE CCR,<ea>
	p = DECODE_EA(p, op);
	OUT("MOVE   ");
	OUT(dir ? "%s,CCR" : "CCR,%s", ea);
	return p;
}
APTR DECODE_000_MOVE_SR(APTR p, UINT16 op, int dir) {
	// MOVE <ea>,SR
	// MOVE SR,<ea>
	p = DECODE_EA(p, op);
	OUT("MOVE   ");
	OUT(dir ? "%s,SR" : "SR,%s", ea);
	return p;
}
APTR DECODE_000_MOVE_USP(APTR p, UINT16 op, int dir) {
	// MOVE USP,An
	// MOVE An,USP
	OUT("MOVE    ");
	OUT(dir ? "USP,a%i" : "a%i,USP", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_MOVE(APTR p, UINT16 op, int size) {
	// MOVE <ea>,<ea>
	p = DECODE_EA2(p, DOWNTO(op, 5, 3), DOWNTO(op,  2, 0), 0, size); // src (mode,reg)
	OUT("MOVE.%c  %s", SZ[size], ea);
	p = DECODE_EA2(p, DOWNTO(op, 8, 6), DOWNTO(op, 11, 9), 0, size); // dst (reg,mode)
	OUT(",%s", ea);
	return p;
}
APTR DECODE_000_MOVEA(APTR p, UINT16 op, int size) {
	// MOVEA <ea>,An
	p = DECODE_EA(p, op);
	OUT("MOVEA.%c %s,a%i", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MOVEM(APTR p, UINT16 op, int size, int dir) {
	// MOVEM <ea>,<list>
	// MOVEM <list>,<ea>
	UINT16 list;
	p = READWORD(p, &list);
	OUT("MOVEM.%c ", SZ[size]);
	if(dir) {
		p = DECODE_EA(p, op);
		OUT("%s,", ea);
		DECODE_LIST(op, list);
	} else {
		DECODE_LIST(op, list);
		p = DECODE_EA(p, op);
		OUT(",%s", ea);
	}
	return p;
}
APTR DECODE_000_MOVEP(APTR p, UINT16 op) {
	// MOVEP (d16,An),Dn
	// MOVEP Dn,(d16,An)
	UINT16 d16;
	p = READWORD(p, &d16);
	OUT("MOVEP.%c ", SZ[1 + BIT(op, 6)]);
	if (BIT(op, 7))
		OUT("d%i,$%04x(a%i)", DOWNTO(op, 11, 9), d16, DOWNTO(op, 2, 0));
	else
		OUT("$%04x(a%i),d%i", d16, DOWNTO(op, 2, 0), DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MOVEQ(APTR p, UINT16 op) {
	// MOVEQ.L #<data>,Dn
	OUT("MOVEQ.L #$%02x,d%i", DOWNTO(op, 7, 0), DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MULS(APTR p, UINT16 op) {
	// MULS.W <ea>,Dn
	p = DECODE_EA(p, op);
	OUT("MULS.W  %s,d%x", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MULU(APTR p, UINT16 op) {
	// MULU.W <ea>,Dn
	p = DECODE_EA(p, op);
	OUT("MULU.W  %s,d%x", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_NEG(APTR p, UINT16 op, int size) {
	// NEG <ea>
	p = DECODE_EA(p, op);
	OUT("NEG.%c   %s", SZ[size], ea);
	return p;
}
APTR DECODE_000_NEGX(APTR p, UINT16 op, int size) {
	// NEGX <ea>
	p = DECODE_EA(p, op);
	OUT("NEGX.%c  %s", SZ[size], ea);
	return p;
}
APTR DECODE_000_NOP(APTR p, UINT16 op) {
	// NOP
	OUT("NOP");
	return p;
}
APTR DECODE_000_NOT(APTR p, UINT16 op, int size) {
	// NOT <ea>
	p = DECODE_EA(p, op);
	OUT("NOT.%c   %s", SZ[size], ea);
	return p;
}
APTR DECODE_000_OR(APTR p, UINT16 op, int size, int dir) {
	// OR <ea>,Dn
	// OR Dn,<ea>
	OUT("OR.%c    ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_ORI(APTR p, UINT16 op, int size) {
	// ORI #<data>,<ea>
	OUT("ORI.%c   ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_ORI_CCR(APTR p, UINT16 op) {
	// ORI #<data>,CCR
	UINT16 imm;
	p = READWORD(p, &imm);
	OUT("ORI     #$%02x,CCR", (UINT8)imm);
	return p;
}
APTR DECODE_000_ORI_SR(APTR p, UINT16 op) {
	// ORI #<data>,SR
	UINT16 imm;
	p = READWORD(p, &imm);
	OUT("ORI     #$%04x,SR", imm);
	return p;
}
APTR DECODE_000_RESET(APTR p, UINT16 op) {
	// RESET
	OUT("RESET");
	return p;
}
APTR DECODE_000_RTE(APTR p, UINT16 op) {
	// RTE
	OUT("RTE");
	return p;
}
APTR DECODE_000_RTR(APTR p, UINT16 op) {
	// RTR
	OUT("RTR");
	return p;
}
APTR DECODE_000_RTS(APTR p, UINT16 op) {
	// RTS
	OUT("RTS");
	return p;
}
APTR DECODE_000_SCC(APTR p, UINT16 op) {
	// Scc <ea>
	p = DECODE_EA(p, op);
	OUT("S%s     %s", CC[DOWNTO(op, 11, 8)], ea);
	return p;
}
APTR DECODE_000_SHIFT(APTR p, UINT16 op) {
	// ASd, LSd, ROd, ROXd Dx,Dy
	// ASd, LSd, ROd, ROXd #<data>,Dy
	// ASd, LSd, ROd, ROXd <ea>
	int value;
	if (DOWNTO(op, 7, 6) == 3) {
		switch (DOWNTO(op, 10 ,9)) {
			case 0: OUT("AS" ); break; // Arithmetic Shift
			case 1: OUT("LS" ); break; // Logical Shift
			case 2: OUT("ROX"); break; // Rotate with Extend
			case 3: OUT("RO" ); break; // Rotate without Extend
		}
		p = DECODE_EA(p, op);
		OUT("%c.%c %s", LR[BIT(op, 8)], SZ[DOWNTO(op, 7, 6)], ea);
	}
	else
	{
		switch (DOWNTO(op, 4, 3)) {
			case 0: OUT("AS" ); break; // Arithmetic Shift
			case 1: OUT("LS" ); break; // Logical Shift
			case 2: OUT("ROX"); break; // Rotate with Extend
			case 3: OUT("RO" ); break; // Rotate without Extend
		}
		value = DOWNTO(op, 11, 9);
		OUT("%c.%c   %s%x,d%x",
			LR[BIT(op, 8)],           // Direction
			SZ[DOWNTO(op, 7, 6)],     // Size
			BIT(op, 5) ? "D" : "#$",  // Imm or Reg Mode
			value == 0 ? 8 : value,   // Imm or Reg Value
			DOWNTO(op, 2, 0));        // Data Register
	}
	return p;
}
APTR DECODE_000_STOP(APTR p, UINT16 op) {
	// STOP #<data>
	UINT16 imm;
	p = READWORD(p, &imm);
	OUT("STOP #$%x", imm);
	return p;
}
APTR DECODE_000_SUB(APTR p, UINT16 op, int size, int dir) {
	// SUB <ea>,Dn
	// SUB Dn,<ea>
	OUT("SUB.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_SUBA(APTR p, UINT16 op, int size) {
	// SUBA <ea>,An
	p = DECODE_EA(p, op);
	OUT("SUBA.%c  %s,a%i", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_SUBI(APTR p, UINT16 op, int size) {
	// SUBI #<data>,<ea>
	OUT("SUBI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_SUBQ(APTR p, UINT16 op, int size) {
	// SUBQ #<data>,<ea>
	int data = DOWNTO(op, 11, 9);
	p = DECODE_EA(p, op);
	OUT("SUBQ.%c  #$%x,%s", SZ[size], data == 0 ? 8 : data, ea);
	return p;
}
APTR DECODE_000_SUBX_DN_DN(APTR p, UINT16 op, int size) {
	// SUBX Dx,Dy
	OUT("SUBX.%c  d%i,d%i", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_SUBX_AN_AN(APTR p, UINT16 op, int size) {
	// SUBX -(Ax),-(Ay)
	OUT("SUBX.%c  -(a%x),-(a%x)", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_SWAP(APTR p, UINT16 op) {
	// SWAP Dn
	OUT("SWAP    d%i", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_TAS(APTR p, UINT16 op) {
	// TAS <ea>
	p = DECODE_EA(p, op);
	OUT("TAS     %s", ea);
	return p;
}
APTR DECODE_000_TRAP(APTR p, UINT16 op) {
	// TRAP #<vector>
	OUT("TRAP    #$%x", DOWNTO(op, 3, 0));
	return p;
}
APTR DECODE_000_TRAPV(APTR p, UINT16 op) {
	// TRAPV
	OUT("TRAPV");
	return p;
}
APTR DECODE_000_TST(APTR p, UINT16 op, int size) {
	// TST <ea>
	p = DECODE_EA(p, op);
	OUT("TST.%c   %s", SZ[size], ea);
	return p;
}
APTR DECODE_000_UNLK(APTR p, UINT16 op) {
	// UNLK An
	OUT("UNLK    a%i", DOWNTO(op, 2, 0));
	return p;
}

/************************************************************************************
 * DECODE - 68010 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_010_RTD(APTR p, UINT16 op) {
	// RTD #<displacement>
	UINT16 d16;
	p = READWORD(p, &d16);
	OUT("RTD #$%x", d16);
	return p;
}
APTR DECODE_010_MOVEC(APTR p, UINT16 op) {
	// MOVEC Rc,Rn
	// MOVEC Rn,Rc
	UINT16 ex;
	p = READWORD(p, &ex);
	DECODE_CREG(DOWNTO(ex, 11, 0));
	OUT("MOVEC   ");
	if (BIT(op, 0))
		OUT("%c%i,%s", DA[BIT(ex, 15)], DOWNTO(ex, 14, 12), cr);
	else
		OUT("%s,%c%i", cr, DA[BIT(ex, 15)], DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_010_MOVES(APTR p, UINT16 op, UINT16 ex) {
	// MOVES Rn,<ea>
	// MOVES <ea>,Rn
	OUT("MOVES.%c ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}

/************************************************************************************
 * DECODE - 68020 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_020_BF(APTR p, UINT16 op, int reg, int dir, char* name) {
	// BFCHG  <ea>{offset:width}
	// BFCLR  <ea>{offset:width}
	// BFEXTS <ea>{offset:width},Dn
	// BFEXTU <ea>{offset:width},Dn
	// BFFFO  <ea>{offset:width},Dn
	// BFINS  Dn,<ea>{offset:width}
	// BFSET  <ea>{offset:width}
	// BFTST  <ea>{offset:width}
	UINT16 ex;
	p = READWORD(p, &ex);
	p = DECODE_EA(p, op);
	OUT("%s  ", name);
	if (reg && dir)
		OUT("d%i,", DOWNTO(ex, 14, 12));
	OUT("%s{%s%x:%s%x}",
		ea,
		BIT(ex, 11) ? "d" : "$",
		BIT(ex, 11) ? DOWNTO(ex, 8 ,6) : DOWNTO(ex, 10 ,6),
		BIT(ex,  5) ? "d" : "$",
		BIT(ex,  5) ? DOWNTO(ex, 2, 0) : DOWNTO(ex,  4, 0)
	);
	if (reg && !dir)
		OUT(",d%i", DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_020_CAS(APTR p, UINT16 op, int size) {
	// CAS Dc,Du,<ea>
	UINT16 ex;
	p = READWORD(p, &ex);
	p = DECODE_EA(p, op);
	OUT("CAS.%c   d%i,d%i,%s", SZ[size], DOWNTO(ex, 2, 0), DOWNTO(ex, 8, 6), ea);
	return p;
}
APTR DECODE_020_CAS2(APTR p, UINT16 op, int size) {
	// CAS2 Dc1:Dc2,Du1:Du2,(Rn1):(Rn2)
	UINT16 ex1, ex2;
	p = READWORD(p, &ex1);
	p = READWORD(p, &ex2);
	OUT("CAS2.%c  d%i:d%i,d%i:d%i,(%c%i):(%c%i)", 
		SZ[size], 
		DOWNTO(ex1, 2, 0), DOWNTO(ex2,  2,  0), // Dc1,Dc2
		DOWNTO(ex1, 8, 6), DOWNTO(ex2,  8,  6), // Du1,Du2
		DA[BIT(ex1, 15)],  DOWNTO(ex1, 14, 12), // Rn1
		DA[BIT(ex2, 15)],  DOWNTO(ex2, 14, 12)  // Rn2
	);
	return p;
}
APTR DECODE_020_CHK2(APTR p, UINT16 op, UINT16 ex, int size) {
	// CHK2 <ea>,Rn
	p = DECODE_EA(p, op);
	OUT("CHK2.%c  %s,%c%i", SZ[size], ea, DA[BIT(ex, 15)], DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_020_CMP2(APTR p, UINT16 op, UINT16 ex, int size) {
	// CMP2 <ea>,Rn
	p = DECODE_EA(p, op);
	OUT("CMP2.%c  %s,%c%i", SZ[size], ea, DA[BIT(ex, 15)], DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_020_DIV(APTR p, UINT16 op) { // TODO: DIVxL <ea>,Dr:Dq
	// DIVU.L  <ea>,Dq     32/16 => 32q
	// DIVU.L  <ea>,Dr:Dq  64/32 => 32r-32q
	// DIVUL.L <ea>,Dr:Dq  32/32 => 32r-32q    ==>   TODO: Implement
	// DIVS.L  <ea>,Dq     32/32 => 32q
	// DIVS.L  <ea>,Dr:Dq  64/32 => 32r-32q
	// DIVSL.L <ea>,Dr:Dq  32/32 => 32r-32q    ==>   TODO: Implement
	UINT16 ex;
	p = READWORD(p, &ex);
	p = DECODE_EA(p, op);
	OUT("DIV%s.L  %s,", BIT(ex, 11) ? "S" : "U", ea);
	if (BIT(ex, 10))
		OUT("d%i:", DOWNTO(ex, 14, 12));
	OUT("d%i", DOWNTO(ex, 2, 0));
	return p;
}
APTR DECODE_020_EXTB(APTR p, UINT16 op) {
	// EXTB.L  Dn
	OUT("EXTB.L  d%i", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_020_LINK(APTR p, UINT16 op) {
	// LINK.L  An,#<displacement>
	UINT16 l, h;
	p = READLONG(p, &h);
	p = READWORD(p, &l);
	OUT("LINK.L  a%i,#$%08x", DOWNTO(op, 2, 0), h << 16 | l);
	return p;
}
APTR DECODE_020_MUL(APTR p, UINT16 op) {
	// MULU.L <ea>,Dl
	// MULU.L <ea>,Dh:Dl
	// MULS.L <ea>,Dl
	// MULS.L <ea>,Dh:Dl
	UINT16 ex;
	p = READWORD(p, &ex);
	p = DECODE_EA(p, op);
	OUT("MUL%s.L  %s,", BIT(ex, 11) ? "S" : "U", ea);
	if (BIT(ex, 10))
		OUT("d%i:", DOWNTO(ex, 2, 0));
	OUT("d%i", DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_020_PACK_UNPK(APTR p, UINT16 op, int dir) {
	// PACK –(Ax),–(Ay),#<adjustment>
	// UNPK –(Ax),–(Ay),#<adjustment>
	// PACK Dx,Dy,#<adjustment>
	// UNPK Dx,Dy,#<adjustment>
	UINT16 ex;
	p = READWORD(p, &ex);
	OUT(dir ? "UNPK    " : "PACK    ");
	OUT(BIT(op, 3) ? "-(a%i),-(a%i)" : "d%x,d%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	OUT("#$%x", ex);
	return p;
}
APTR DECODE_020_TRAPCC(APTR p, UINT16 op, int mode) {
	// TRAPcc
	// TRAPcc.W #<data>
	// TRAPcc.L #<data>
	UINT16 l, h;
	OUT("TRAP%s", CC[DOWNTO(op, 11, 8)]);
	switch (mode) {
		case 2:
			p = READWORD(p, &h);
			OUT("  #$%04x", h);
			break;
		case 3:
			p = READWORD(p, &h);
			p = READWORD(p, &l);
			OUT("  #$%08x", h << 16 | l);
			break;
		case 4:
			// No Operand
			break;
	}
	return p;
}

/************************************************************************************
 * DECODE - 68040 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_040_MOVE16(APTR p, UINT16 op) {
	UINT16 l, h;
	p = READWORD(p, &h);
	OUT("MOVE16  ");
	switch (DOWNTO(op, 5, 3)) {
		case 0: p = READWORD(p, &l); OUT("(a%x)+,($%x).L", DOWNTO(op, 2, 0), h << 16 | l); break;
		case 1: p = READWORD(p, &l); OUT("($%x).L,(a%x)+", DOWNTO(op, 2, 0), h << 16 | l); break;
		case 2: p = READWORD(p, &l); OUT("(a%x),($%x).L",  DOWNTO(op, 2, 0), h << 16 | l); break;
		case 3: p = READWORD(p, &l); OUT("($%x).L,(a%x)",  DOWNTO(op, 2, 0), h << 16 | l); break;
		case 4: OUT("(a%x)+,(a%x)+",  DOWNTO(op, 2, 0), DOWNTO(h, 14, 12)); break;
	}
	return p;
}
APTR DECODE_040_CINV(APTR p, UINT16 op) {
	// CINVL <caches>,(An)   -- Line
	// CINVP <caches>,(An)   -- Page
	// CINVA <caches>        -- All
	OUT("CINV");
	switch (DOWNTO(op, 4, 3)) {
		case 0: OUT("    ILLEGAL" );
		case 1: OUT("L   %i,(A%i)", DOWNTO(op, 7, 6), DOWNTO(op, 2, 0));
		case 2: OUT("P   %i,(A%i)", DOWNTO(op, 7, 6), DOWNTO(op, 2, 0));
		case 3: OUT("A   %i"      , DOWNTO(op, 7, 6));
	}
	return p;
}

/************************************************************************************
 * DECODE - 68080 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_080_ABS(APTR p, UINT16 op, UINT16 ex) {
	// ABS <ea>,Rn
	// ABS Rn,<ea>
	OUT("ABS.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_ADDQ(APTR p, UINT16 op) {
	// ADDQ.L #<data>,Bn
	OUT("ADDQ.L  #%i,b%x", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADDIW(APTR p, UINT16 op) {
	// ADDIW.L #<data>,<ea>
	UINT16 imm;
	p = READWORD(p, &imm);
	p = DECODE_EA(p, op);
	OUT("ADDIW.L #$%04x,%s", imm, ea);
	return p;
}
APTR DECODE_080_ADD_BN_DN(APTR p, UINT16 op) {
	// ADD.L Bn,Dn
	OUT("ADD.L   b%i,d%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADD_BN_AN(APTR p, UINT16 op) {
	// ADDA.L Bn,An
	OUT("ADDA.L  b%i,a%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADD_BN_BN(APTR p, UINT16 op) {
	// ADDA.L Bn,Bn
	OUT("ADDA.L  b%i,b%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADD_EA_BN(APTR p, UINT16 op) {
	// ADDA.L <ea>,Bn
	p = DECODE_EA(p, op);
	OUT("ADDA.L  %s,b%i", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_AND(APTR p, UINT16 op, UINT16 ex) {
	// AND <ea>,Rn
	// AND Rn,<ea>
	OUT("AND.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_ANDN(APTR p, UINT16 op, UINT16 ex) {
	// ANDN <ea>,Rn
	// ANDN Rn,<ea>
	OUT("ANDN.%c  ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_CMPIW(APTR p, UINT16 op) {
	// CMPIW.L #<data>,<ea>
	UINT16 imm;
	p = READWORD(p, &imm);
	p = DECODE_EA(p, op);
	OUT("CMPIW.L #$%04x,%s", imm, ea);
	return p;
}
APTR DECODE_080_CMP_BN_DN(APTR p, UINT16 op) {
	// CMP.L Bn,Dn
	OUT("CMP.L   b%i,d%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_CMP_BN_AN(APTR p, UINT16 op) {
	// CMPA.L Bn,An
	OUT("CMPA.L  b%i,a%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_CMP_BN_BN(APTR p, UINT16 op) {
	// CMPA.L Bn,Bn
	OUT("CMPA.L  b%i,b%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_CMP_EA_BN(APTR p, UINT16 op) {
	// CMPA.L <ea>,Bn
	p = DECODE_EA(p, op);
	OUT("CMPA.L  %s,b%i", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_EOR(APTR p, UINT16 op, UINT16 ex) {
	// EOR <ea>,Rn
	// EOR Rn,<ea>
	OUT("EOR.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_LEA(APTR p, UINT16 op, int dir) {
	// LEA <ea>,Bn
	// LEA Bn,An
	OUT("LEA     ");
	if (dir) {
		p = DECODE_EA(p, op);
		OUT("%s,b", ea);
	} else {
		OUT("b%i,a", DOWNTO(op, 2, 0));
	}
	OUT("%i", DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_MAX(APTR p, UINT16 op, UINT16 ex) {
	// MAX <ea>,Rn
	// MAX Rn,<ea>
	OUT("MAX.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_MIN(APTR p, UINT16 op, UINT16 ex) {
	// MIN <ea>,Rn
	// MIN Rn,<ea>
	OUT("MIN.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_MOVE(APTR p, UINT16 op, int dir) {
	// MOVE.L  Bn,<ea>
	// MOVEA.L <ea>,Bn
	p = DECODE_EA(p, op);
	OUT("MOVE.L  ");
	if (dir)
		OUT("b%i,%s", DOWNTO(op, 11, 9), ea);
	else
		OUT("%s,b%i", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_MOVEX(APTR p, UINT16 op, UINT16 ex) {
	// MOVEX <ea>,Rn
	// MOVEX Rn,<ea>
	OUT("MOVEX.%c ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_OR(APTR p, UINT16 op, UINT16 ex) {
	// OR <ea>,Rn
	// OR Rn,<ea>
	OUT("OR.%c    ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_PERM(APTR p, UINT16 op) {
	// PERM #<data>,Rm,Rn
	UINT16 ex;
	p = READWORD(p, &ex);
	OUT("PERM    #$%s,%c%i,%c%i", 
	DOWNTO(ex, 11, 0),                    // Immediate 12-bits
	DA[BIT(op,  3)], DOWNTO(op,  2,  0),  // Register A
	DA[BIT(ex, 15)], DOWNTO(ex, 14, 12)); // Register B
	return p;
}
APTR DECODE_080_SUBQ(APTR p, UINT16 op) {
	// SUBQ.L #<data>,Bn
	OUT("SUBQ.L  #%i,b%x", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_BN_DN(APTR p, UINT16 op) {
	// SUB.L Bn,Dn
	OUT("SUB.L   b%i,d%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_BN_AN(APTR p, UINT16 op) {
	// SUBA.L Bn,An
	OUT("SUBA.L  b%i,a%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_BN_BN(APTR p, UINT16 op) {
	// SUBA.L Bn,Bn
	OUT("SUBA.L  b%i,b%i", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_EA_BN(APTR p, UINT16 op) {
	// SUBA.L <ea>,Bn
	p = DECODE_EA(p, op);
	OUT("SUBA.L  %s,b%i", ea, DOWNTO(op, 11, 9));
	return p;
}

/************************************************************************************
 * DECODE - LINES #0 to #F
 ***********************************************************************************/

APTR DECODE_LINE_0(APTR p, UINT16 op) {
	
	UINT16 ex;
	
	if (BIT(op, 8)) // MOVEP, BTST, BCHG, BCLR, BSET (dynamic)
	{
		if (DOWNTO(op, 5, 3) == 1)
			return DECODE_000_MOVEP(p, op);
		
		switch (DOWNTO(op, 7, 6)) {
			case 0: return DECODE_000_BIT_D(p, op, "BTST");
			case 1: return DECODE_000_BIT_D(p, op, "BCHG");
			case 2: return DECODE_000_BIT_D(p, op, "BCLR");
			case 3: return DECODE_000_BIT_D(p, op, "BSET");
		}
	}
	
	switch (DOWNTO(op, 11, 9))
	{
		case 0: // ORI, CHK2.B, CMP2.B
			
			switch (DOWNTO(op, 7, 6)) {
				case 0:
					if (DOWNTO(op, 5, 0) == 60) // 111 100
						return DECODE_000_ORI_CCR(p, op); 
					return DECODE_000_ORI(p, op, 0);
				case 1:
					if (DOWNTO(op, 5, 0) == 60) // 111 100
						return DECODE_000_ORI_SR(p, op); 
					return DECODE_000_ORI(p, op, 1);
				case 2:
					return DECODE_000_ORI(p, op, 2);
				case 3:
					
					if (BIT(ex, 11))
						return DECODE_020_CMP2(p, op, ex, 0);
					return DECODE_020_CHK2(p, op, ex, 0);
			}
			
		case 1: // ANDI, CHK2.W, CMP2.W
			
			switch (DOWNTO(op, 7, 6)) {
				case 0:
					if (DOWNTO(op, 5, 0) == 60) // 111 100
						return DECODE_000_ANDI_CCR(p, op); 
					return DECODE_000_ANDI(p, op, 0);
				case 1:
					if (DOWNTO(op, 5, 0) == 60) // 111 100
						return DECODE_000_ANDI_SR(p, op); 
					return DECODE_000_ANDI(p, op, 1);
				case 2:
					return DECODE_000_ANDI(p, op, 2);
				case 3:
					p = READWORD(p, &ex);
					if (BIT(ex, 11))
						return DECODE_020_CMP2(p, op, ex, 1);
					return DECODE_020_CHK2(p, op, ex, 1);
			}
			
		case 2: // SUBI, CHK2.L, CMP2.L
			
			switch (DOWNTO(op, 7, 6)) {
				case 0: return DECODE_000_SUBI(p, op, 0);
				case 1: return DECODE_000_SUBI(p, op, 1);
				case 2: return DECODE_000_SUBI(p, op, 2);
				case 3:
					p = READWORD(p, &ex);
					if (BIT(ex, 11))
						return DECODE_020_CMP2(p, op, ex, 2);
					return DECODE_020_CHK2(p, op, ex, 2);
			}
			
		case 3: // ADDI, ADDIW.L
			
			switch (DOWNTO(op, 7, 6)) {
				case 0: return DECODE_000_ADDI(p, op, 0);
				case 1: return DECODE_000_ADDI(p, op, 1);
				case 2: return DECODE_000_ADDI(p, op, 2);
				case 3: return DECODE_080_ADDIW(p, op);
			}
			
		case 4: // BTST, BCHG, BCLR, BSET (static)
			
			switch (DOWNTO(op, 7, 6)) {
				case 0: return DECODE_000_BIT_S(p, op, "BTST");
				case 1: return DECODE_000_BIT_S(p, op, "BCHG");
				case 2: return DECODE_000_BIT_S(p, op, "BCLR");
				case 3: return DECODE_000_BIT_S(p, op, "BSET");
			}
			
		case 5: // EORI, CAS.B
			
			switch (DOWNTO(op, 7, 6)) {
				case 0:
					if (DOWNTO(op, 5, 0) == 60) // 111 100
						return DECODE_000_EORI_CCR(p, op); 
					return DECODE_000_EORI(p, op, 0);
				case 1:
					if (DOWNTO(op, 5, 0) == 60) // 111 100
						return DECODE_000_EORI_SR (p, op); 
					return DECODE_000_EORI(p, op, 1);
				case 2:
					return DECODE_000_EORI(p, op, 2);
				case 3:
					return DECODE_020_CAS(p, op, 0);
			}
			
		case 6: // CMPI, CAS.W, CAS2.W
			
			switch (DOWNTO(op, 7, 6)) {
				case 0: return DECODE_000_CMPI(p, op, 0);
				case 1: return DECODE_000_CMPI(p, op, 1);
				case 2: return DECODE_000_CMPI(p, op, 2);
				case 3:
					if (DOWNTO(op, 5, 0) == 60) // 111 100
						return DECODE_020_CAS2(p, op, 1);
					return DECODE_020_CAS(p, op, 1);
			}
			
		case 7: // MOVES, CAS.L, CAS2.L, MOVEX, ABS, MIN, MAX, OR, EOR, AND, ANDN
			
			if (DOWNTO(op, 7, 6) == 3) {    // 011
				if (DOWNTO(op, 5, 0) == 60) // 111 100
					return DECODE_020_CAS2(p, op, 2);
				return DECODE_020_CAS(p, op, 2);
			}
			
			p = READWORD(p, &ex);
			
			if (BIT(ex, 4)) {
				switch (DOWNTO(ex, 3, 0)) {
					case 0: return DECODE_080_MOVEX(p, op, ex);
					case 1: return p; // FREE
					case 2: return p; // FREE
					case 3: return p; // FREE
					case 4: return p; // FREE
					case 5: return p; // FREE
					case 6: return p; // FREE
					case 7: return p; // FREE
				}
			}
			
			switch (DOWNTO(ex, 3, 0)) {
				case 0: return DECODE_010_MOVES(p, op, ex);
				case 1: return DECODE_080_ABS  (p, op, ex);
				case 2: return DECODE_080_MIN  (p, op, ex);
				case 3: return DECODE_080_MAX  (p, op, ex);
				case 4: return DECODE_080_OR   (p, op, ex);
				case 5: return DECODE_080_EOR  (p, op, ex);
				case 6: return DECODE_080_AND  (p, op, ex);
				case 7: return DECODE_080_ANDN (p, op, ex);
			}
	}
	
	return p;
}
APTR DECODE_LINE_1(APTR p, UINT16 op) {
	
	// MOVE.L Bn,<ea>
	if (DOWNTO(op, 5, 3) == 1)
		return DECODE_080_MOVE(p, op, 1);
	
	// MOVE.L <ea>,Bn
	if (DOWNTO(op, 8, 6) == 1)
		return DECODE_080_MOVE(p, op, 0);
	
	// MOVE.B  <ea>,<ea>
	return DECODE_000_MOVE(p, op, 0);      
}
APTR DECODE_LINE_2(APTR p, UINT16 op) {
	
	// MOVEA.L <ea>,An
	if (DOWNTO(op, 8, 6) == 1)
		return DECODE_000_MOVEA(p, op, 2);
	
	// MOVE.L  <ea>,<ea>
	return DECODE_000_MOVE(p, op, 2);
}
APTR DECODE_LINE_3(APTR p, UINT16 op) {
	
	// MOVEA.W <ea>,An
	if (DOWNTO(op, 8, 6) == 1)
		return DECODE_000_MOVEA(p, op, 1);
	
	// MOVE.W  <ea>,<ea>
	return DECODE_000_MOVE(p, op, 1);
}
APTR DECODE_LINE_4(APTR p, UINT16 op) {
	
	switch (BIT(op, 8)) {
		case 0:
			switch (DOWNTO(op, 11, 9)) {
				case 0:
					switch (DOWNTO(op, 7, 6)) {
						case 0: return DECODE_000_NEGX   (p, op, 0);
						case 1: return DECODE_000_NEGX   (p, op, 1);
						case 2: return DECODE_000_NEGX   (p, op, 2);
						case 3: return DECODE_000_MOVE_SR(p, op, 0);
					}
				case 1:
					switch (DOWNTO(op, 7, 6)) {
						case 0: return DECODE_000_CLR     (p, op, 0);
						case 1: return DECODE_000_CLR     (p, op, 1);
						case 2: return DECODE_000_CLR     (p, op, 2);
						case 3: return DECODE_000_MOVE_CCR(p, op, 0);
					}
				case 2:
					switch (DOWNTO(op, 7, 6)) {
						case 0: return DECODE_000_NEG     (p, op, 0);
						case 1: return DECODE_000_NEG     (p, op, 1);
						case 2: return DECODE_000_NEG     (p, op, 2);
						case 3: return DECODE_000_MOVE_CCR(p, op, 1);
					}
				case 3:
					switch (DOWNTO(op, 7, 6)) {
						case 0: return DECODE_000_NOT    (p, op, 0);
						case 1: return DECODE_000_NOT    (p, op, 1);
						case 2: return DECODE_000_NOT    (p, op, 2);
						case 3: return DECODE_000_MOVE_SR(p, op, 1);
					}
				case 4:
					switch (DOWNTO(op, 7, 6)) {
						case 0:
							switch (DOWNTO(op, 5, 3)) {
								case 0:  return DECODE_000_NBCD(p, op);
								case 1:  return DECODE_020_LINK(p, op);
							}
						case 1:
							switch (DOWNTO(op, 5, 3)) {
								case 0:  return DECODE_000_SWAP(p, op);
								case 1:  return DECODE_000_BKPT(p, op);
								default: return DECODE_000_PEA (p, op);
							}
						case 2:
							switch (DOWNTO(op, 5, 3)) {
								case 0:  return DECODE_000_EXT(p, op, 1);
								case 1:  return p; // FREE
								default: return DECODE_000_MOVEM(p, op, 1, 0);
							}
						case 3:
							switch (DOWNTO(op, 5, 3)) {
								case 0:  return DECODE_000_EXT(p, op, 2);
								case 1:  return p; // FREE
								default: return DECODE_000_MOVEM(p, op, 2, 0);
							}
					}
				case 5:
					switch (DOWNTO(op, 7, 6)) {
						case 0: return DECODE_000_TST(p, op, 0);
						case 1: return DECODE_000_TST(p, op, 1);
						case 2: return DECODE_000_TST(p, op, 2);
						case 3:
							if(DOWNTO(op, 5, 2) == 15)
								return DECODE_000_ILLEGAL(p, op);
							return DECODE_000_TAS(p, op);
					}
				case 6:
					switch (DOWNTO(op, 7, 6)) {
						case 0: return DECODE_020_MUL(p, op);
						case 1: return DECODE_020_DIV(p, op);
						case 2: return DECODE_000_MOVEM(p, op, 1, 1);
						case 3:
							if (DOWNTO(op, 5, 4))
								return DECODE_000_MOVEM(p, op, 2, 1);
							return DECODE_080_PERM(p, op);
					}
				case 7:
					switch (DOWNTO(op, 7, 6)) {
						case 0:
							return DECODE_080_CMPIW(p, op);
						case 1:
							switch (DOWNTO(op, 5, 3)) {
								case 0: 
								case 1: return DECODE_000_TRAP(p, op);
								case 2: return DECODE_000_LINK(p, op);
								case 3: return DECODE_000_UNLK(p, op);
								case 4: return DECODE_000_MOVE_USP(p, op, 0);
								case 5: return DECODE_000_MOVE_USP(p, op, 1);
								case 6:
									switch (DOWNTO(op, 2, 0)) {
										case 0: return DECODE_000_RESET(p, op);
										case 1: return DECODE_000_NOP  (p, op);
										case 2: return DECODE_000_STOP (p, op);
										case 3: return DECODE_000_RTE  (p, op);
										case 4: return DECODE_010_RTD  (p, op);
										case 5: return DECODE_000_RTS  (p, op);
										case 6: return DECODE_000_TRAPV(p, op);
										case 7: return DECODE_000_RTR  (p, op);
									}
								case 7:
									switch (DOWNTO(op, 2, 0)) {
										case 0: 
										case 1: return p; // FREE
										case 2: 
										case 3: return DECODE_010_MOVEC(p, op);
										case 4: 
										case 5: 
										case 6: 
										case 7: return p; // FREE
									}
							}
						case 2: return DECODE_000_JSR(p, op);
						case 3: return DECODE_000_JMP(p, op);
					}
			}
		case 1: // CHK, EXTB, LEA
			switch (DOWNTO(op, 7, 6)) {
				case 0: return DECODE_000_CHK(p, op, 2);
				case 1: return DECODE_080_LEA(p, op, 1);
				case 2: return DECODE_000_CHK(p, op, 1);
				case 3:
					switch(DOWNTO(op, 5, 3)) {
						case 0:
							if (DOWNTO(op, 11, 9) == 4)
								return DECODE_020_EXTB(p, op);
							return p; // FREE
						case 1:
							return DECODE_080_LEA(p, op, 0);
					}
					return DECODE_000_LEA(p, op);
			}
	}
	
	return p;
}
APTR DECODE_LINE_5(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 7, 6)) {
		case 0:
			if (BIT(op, 8)) {
				if (DOWNTO(op, 5, 3) == 1)
					return DECODE_080_SUBQ(p, op);
				return DECODE_000_SUBQ(p, op, 0);
			}
			if (DOWNTO(op, 5, 3) == 1)
				return DECODE_080_ADDQ(p, op);
			return DECODE_000_ADDQ(p, op, 0);
		case 1:
			if (BIT(op, 8))
				return DECODE_000_SUBQ(p, op, 1);
			return DECODE_000_ADDQ(p, op, 1);
		case 2:
			if (BIT(op, 8))
				return DECODE_000_SUBQ(p, op, 2);
			return DECODE_000_ADDQ(p, op, 2);
		case 3:
			switch (DOWNTO(op, 5, 3)) {
				case 1:
					return DECODE_000_DBCC(p, op);
				case 7:
					switch (DOWNTO(op, 2, 0)) {
						case 2: return DECODE_020_TRAPCC(p, op, 2);
						case 3: return DECODE_020_TRAPCC(p, op, 3);
						case 4: return DECODE_020_TRAPCC(p, op, 4);
					}
			}
			return DECODE_000_SCC(p, op);
	}
	
	return p;
}
APTR DECODE_LINE_6(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 11, 8)) {
		case 0: return DECODE_000_BRA(p, op);
		case 1: return DECODE_000_BSR(p, op);
	}
	
	return DECODE_000_BCC(p, op);
}
APTR DECODE_LINE_7(APTR p, UINT16 op) {
	
	if (BIT(op, 8)) {
		switch (DOWNTO(op, 7, 6)) {
			case 0: return DECODE_080_SUB_EA_BN(p, op);
			case 1: return DECODE_080_ADD_EA_BN(p, op);
			case 2: return DECODE_080_CMP_EA_BN(p, op);
			case 3:
				switch (DOWNTO(op, 5, 3)) {
					case 0: return DECODE_080_SUB_BN_BN(p, op);
					case 1: return DECODE_080_SUB_BN_AN(p, op);
					case 2: return DECODE_080_SUB_BN_DN(p, op);
					case 3: return DECODE_080_CMP_BN_BN(p, op);
					case 4: return DECODE_080_ADD_BN_BN(p, op);
					case 5: return DECODE_080_SUB_BN_AN(p, op);
					case 6: return DECODE_080_ADD_BN_DN(p, op);
					case 7: return DECODE_080_CMP_BN_AN(p, op);
				}
		}
	}
	
	return DECODE_000_MOVEQ(p, op);
}
APTR DECODE_LINE_8(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 8, 6)) {
		case 0: return DECODE_000_OR(p, op, 0, 0);
		case 1: return DECODE_000_OR(p, op, 1, 0);
		case 2: return DECODE_000_OR(p, op, 2, 0);
		case 3: return DECODE_000_DIVU(p, op);
		case 4: return DOWNTO(op, 5, 4) ? DECODE_000_OR(p, op, 0, 1) : DECODE_000_SBCD(p, op);
		case 5: return DOWNTO(op, 5, 4) ? DECODE_000_OR(p, op, 1, 1) : DECODE_020_PACK_UNPK(p, op, 0);
		case 6: return DOWNTO(op, 5, 4) ? DECODE_000_OR(p, op, 2, 1) : DECODE_020_PACK_UNPK(p, op, 1);
		case 7: return DECODE_000_DIVS(p, op);
	}
	
	return p;
}
APTR DECODE_LINE_9(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 8, 6)) {
		case 0: return DECODE_000_SUB (p, op, 0, 0);
		case 1: return DECODE_000_SUB (p, op, 1, 0);
		case 2: return DECODE_000_SUB (p, op, 2, 0);
		case 3: return DECODE_000_SUBA(p, op, 1   );
		case 4:
			switch (DOWNTO(op, 5, 3)) {
				case 0: return DECODE_000_SUBX_DN_DN(p, op, 0);
				case 1: return DECODE_000_SUBX_AN_AN(p, op, 0);
			}
			return DECODE_000_SUB(p, op, 0, 1);
		case 5:
			switch (DOWNTO(op, 5, 3)) {
				case 0: return DECODE_000_SUBX_DN_DN(p, op, 1);
				case 1: return DECODE_000_SUBX_AN_AN(p, op, 1);
			}
			return DECODE_000_SUB(p, op, 1, 1);
		case 6:
			switch (DOWNTO(op, 5, 3)) {
				case 0: return DECODE_000_SUBX_DN_DN(p, op, 2);
				case 1: return DECODE_000_SUBX_AN_AN(p, op, 2);
			}
			return DECODE_000_SUB(p, op, 2, 1);
		case 7:
			return DECODE_000_SUBA(p, op, 2);
	}
	
	return p;
}
APTR DECODE_LINE_A(APTR p, UINT16 op) {
	
	OUT("ATRAP   #$%04x", op);
	return p;
}
APTR DECODE_LINE_B(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 8, 6)) {
		case 0: return DECODE_000_CMP (p, op, 0);
		case 1: return DECODE_000_CMP (p, op, 1);
		case 2: return DECODE_000_CMP (p, op, 2);
		case 3: return DECODE_000_CMPA(p, op, 1);
		case 4: return (DOWNTO(op, 5, 4)) ? DECODE_000_CMPM(p, op, 0) : DECODE_000_EOR(p, op, 0);
		case 5: return (DOWNTO(op, 5, 4)) ? DECODE_000_CMPM(p, op, 1) : DECODE_000_EOR(p, op, 1);
		case 6: return (DOWNTO(op, 5, 4)) ? DECODE_000_CMPM(p, op, 2) : DECODE_000_EOR(p, op, 2);
		case 7: return DECODE_000_CMPA(p, op, 2);
	}
	
	return p;
}
APTR DECODE_LINE_C(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 8, 6)) {
		case 0: return DECODE_000_AND (p, op, 0, 0);
		case 1: return DECODE_000_AND (p, op, 1, 0);
		case 2: return DECODE_000_AND (p, op, 2, 0);
		case 3: return DECODE_000_MULU(p, op);
		case 4:
			switch (DOWNTO(op, 5, 3)) {
				case 0:
				case 1: return DECODE_000_ABCD(p, op);
			}
			return DECODE_000_AND(p, op, 0, 1);
		case 5:
			switch (DOWNTO(op, 5, 3)) {
				case 0:
				case 1: return DECODE_000_EXG(p, op);
			}
			return DECODE_000_AND(p, op, 1, 1);
		case 6:
			switch (DOWNTO(op, 5, 3)) {
				case 0: return DECODE_080_CMP_BN_DN(p, op);
				case 1: return DECODE_000_EXG(p, op);
			}
			return DECODE_000_AND(p, op, 2, 1);
		case 7:
			return DECODE_000_MULS(p, op);
	}
	
	return p;
}
APTR DECODE_LINE_D(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 8, 6)) {
		case 0: return DECODE_000_ADD (p, op, 0, 0);
		case 1: return DECODE_000_ADD (p, op, 1, 0);
		case 2: return DECODE_000_ADD (p, op, 2, 0);
		case 3: return DECODE_000_ADDA(p, op, 1);
		case 4:
			switch (DOWNTO(op, 5, 3)) {
				case 0: return DECODE_000_ADDX_DN_DN(p, op, 0);
				case 1: return DECODE_000_ADDX_AN_AN(p, op, 0);
			}
			return DECODE_000_ADD(p, op, 0, 1);
		case 5:
			switch (DOWNTO(op, 5, 3)) {
				case 0: return DECODE_000_ADDX_DN_DN(p, op, 1);
				case 1: return DECODE_000_ADDX_AN_AN(p, op, 1);
			}
			return DECODE_000_ADD(p, op, 1, 1);
		case 6:
			switch (DOWNTO(op, 5, 3)) {
				case 0: return DECODE_000_ADDX_DN_DN(p, op, 2);
				case 1: return DECODE_000_ADDX_AN_AN(p, op, 2);
			}
			return DECODE_000_ADD(p, op, 2, 1);
		case 7:
			return DECODE_000_ADDA(p, op, 2);
	}
	
	return p;
}
APTR DECODE_LINE_E(APTR p, UINT16 op) {
	
	if (BIT(op, 11)) {
		switch ((DOWNTO(op, 8, 6))) {
			case 3:
				switch (DOWNTO(op, 10, 9)) {
					case 0: return DECODE_020_BF(p, op, 0, 0, "BFTST ");
					case 1: return DECODE_020_BF(p, op, 0, 0, "BFCHG ");
					case 2: return DECODE_020_BF(p, op, 0, 0, "BFCLR ");
					case 3: return DECODE_020_BF(p, op, 0, 0, "BFSET ");
				}
			case 7:
				switch (DOWNTO(op, 10, 9)) {
					case 0: return DECODE_020_BF(p, op, 1, 0, "BFEXTU");
					case 1: return DECODE_020_BF(p, op, 1, 0, "BFEXTS");
					case 2: return DECODE_020_BF(p, op, 1, 0, "BFFFO ");
					case 3: return DECODE_020_BF(p, op, 1, 1, "BFINS ");
				}
		}
	}
	
	return DECODE_000_SHIFT(p, op);
}
APTR DECODE_LINE_F(APTR p, UINT16 op) {
	
	switch (DOWNTO(op, 11, 9)) {
		case 0: OUT("DC.w    $%04x", op); break;
		case 1: OUT("DC.w    $%04x", op); break;
		case 2: OUT("DC.w    $%04x", op); break;
		case 3: return DECODE_040_MOVE16(p, op);
		case 4: OUT("DC.w    $%04x", op); break;
		case 5: OUT("DC.w    $%04x", op); break;
		case 6: OUT("DC.w    $%04x", op); break;
		case 7: OUT("DC.w    $%04x", op); break;
	}
	
	return p;
}

int DECODE(APTR p, int max) {
	
	APTR addr;
	UINT16 op;
	int count = 0;
	
	while (count < max) {
		addr = p;
		buff = &buf[0];
		p = READWORD(p, &op);
		switch (DOWNTO(op, 15, 12)) {
			case 0x0: p = DECODE_LINE_0(p, op); break;
			case 0x1: p = DECODE_LINE_1(p, op); break;
			case 0x2: p = DECODE_LINE_2(p, op); break;
			case 0x3: p = DECODE_LINE_3(p, op); break;
			case 0x4: p = DECODE_LINE_4(p, op); break;
			case 0x5: p = DECODE_LINE_5(p, op); break;
			case 0x6: p = DECODE_LINE_6(p, op); break;
			case 0x7: p = DECODE_LINE_7(p, op); break;
			case 0x8: p = DECODE_LINE_8(p, op); break;
			case 0x9: p = DECODE_LINE_9(p, op); break;
			case 0xA: p = DECODE_LINE_A(p, op); break;
			case 0xB: p = DECODE_LINE_B(p, op); break;
			case 0xC: p = DECODE_LINE_C(p, op); break;
			case 0xD: p = DECODE_LINE_D(p, op); break;
			case 0xE: p = DECODE_LINE_E(p, op); break;
			case 0xF: p = DECODE_LINE_F(p, op); break;
		}
		printf("%08x :  %-30s  %-40s ; %i\n", addr, dump, buf, p - addr);
		sprintf(dump, ""); // Reset Opcodes-HexDump
		wordcount = 0;     // Reset Word count
		count++;           // Increment Instruction count
	}
	return count;
}

/************************************************************************************
 * ENTRY POINT
 ***********************************************************************************/

int main(int argc, char *argv[]) {
	
	int count = 0;
	
	UINT16 sample[100] = {
		0x4cdf,0x7cfc,
		0x3228,0x001c,
		0x690f,
		0x69f0,
		0xe000,
		0x1401,
		0x3040,
		0x2618,
		0x2221,
		0x4e75,
		0x8127,
		0x4cdf,0x7cfc,
		0x3228,0x001c,
		0xe000,
		0x1401,
		0x3040,
		0x2618,
		0x2221,
		0x4e75,
		0x8127,
		0xffff,0xffff
	};
	
	switch (argc) {
		case 1: 
			// SAMPLE TEST
			count = DECODE(sample, 20);
			break;
		case 2:
			// ADDRESS [DEFAULT SIZE]
			count = DECODE((APTR)strtol(argv[1], NULL, 16), 30);
			break;
		default:
			// ADDRESS SIZE
			count = DECODE((APTR)strtol(argv[1], NULL, 16), strtol(argv[2], NULL, 10));
			break;
	}
	
	
	/*
	foo("toto\n");
	foo("a:%i,b:%i,c:%i\n", 1, 2, 3);
	foo("%i,%i,%i,%i,%i\n", 1, 2, 3, 4, 5);
	*/
	
	return count;
 }

/************************************************************************************
 * 68K RULEZ!
 ***********************************************************************************/
