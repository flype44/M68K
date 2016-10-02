/************************************************************************************
 * Program: DisLib080
 * Short:   A simple 68080 Disassembler
 * Authors: APOLLO-Team, flype
 * Update:  Oct-2016
 ***********************************************************************************/

/* TODO:
 * OUTPUTS           ==> ALL lowercase
 * OUTPUTS           ==> Push chars to a own buffer
 * EFFECTIVE ADDRESS ==> Correct commas positioning
 * EFFECTIVE ADDRESS ==> #imm 16 or 32 (propagate size)
 * EFFECTIVE ADDRESS ==> %x instead of %0nx
 * EFFECTIVE ADDRESS ==> Resolve PC Relative address
 * DECODE_LABEL()    ==> Resolve Correct Relative address
 * DIVxL             ==> Implements
 * PACK, UNPK        ==> Implements
 */

#include <stdio.h>
#include <stdlib.h>
#include "dislib.h"

/************************************************************************************
 * ARRAYS
 ***********************************************************************************/

char cr  [ 16]; // Control-Register
char ea  [200]; // Effective-Address

char AB[2] = { 'a', 'b' };
char DA[2] = { 'd', 'a' };
char LR[2] = { 'R', 'L' };
char WL[2] = { 'w', 'l' };
char SC[4] = { '1', '2', '4', '8' };
char SZ[4] = { 'b', 'w', 'l', 'q' };

char* CC[16] = { "T ", "F ", "HI", "LS", "CC", "CS", "NE", "EQ",
                 "VC", "VS", "PL", "MI", "GE", "LT", "GT", "LE" };

/************************************************************************************
 * DECODE - EFFECTIVE ADDRESS MODES
 ***********************************************************************************/

void DECODE_CREG(int reg) {
	sprintf(ea, "");
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
		printf("#0"); // No Register
		return;
	}
	
	if (DOWNTO(op, 5, 3) == 4) // EAMODE = -(An)
	{
		while(ex) {
			if (ex & 0x8000) {
				if (i < 8) printf("d");
				else printf("a");
				printf("%i", i & 7);
				if ((ex & 0x4000) && (i & 7) < 7) {
					printf("-");
					while ((ex & 0x4000) && (i & 7) < 7) {
						ex <<= 1;
						i++;
					}
					if (i < 8) printf("d");
					else printf("a");
					printf("%i", i & 7);
				}
				if ((UINT16)(ex << 1)) printf("/");
			}
			i++;
			ex <<= 1;
		}
	}
	else
	{
		while(ex || i < 16) {
			if (ex & 0x0001) {
				if (i < 8) printf("d");
				else printf("a");
				printf("%i", i & 7);
				if ((ex & 0x0002) && (i & 7) < 7) {
					printf("-");
					while((ex & 0x0002) && (i & 7) < 7) {
						ex >>= 1;
						i++;
					}
					if (i < 8) printf("d");
					else printf("a");
					printf("%i", i & 7);
				}
				if (ex >> 1) printf("/");
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
	ex = *p++;
	sprintf(xn, "%c%i.%c*%c",
		DA[BIT   (ex, 15    )],
		   DOWNTO(ex, 14, 12), 
		WL[BIT   (ex, 11    )],
		SC[DOWNTO(ex, 10,  9)] 
	);
	if (BIT(ex, 8)) {
		switch (DOWNTO(ex, 5, 4)) {
			case 3:
				h = *p++; l = *p++;
				sprintf(bd, "$%08x.l", h << 16 | l);
				break;
			case 2:
				l = *p++;
				sprintf(bd, "$%04x.w", l);
				break;
			case 1:
			case 0: sprintf(bd, ""); break;
		}
		iis = DOWNTO(ex, 2, 0);
		switch (iis) {
			case 3:
			case 7:
				h = *p++; l = *p++;
				sprintf(od, ",$%08x.l", h << 16 | l);
				break;
			case 2:
			case 6:
				l = *p++;
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
			l = *p++;
			sprintf(ea, "$%x(%c%i)", l, AB[breg], reg);
			break;
		case 6:
			p = DECODE_EA_EXT(p, mode, reg, breg);
			break;
		case 7:
			switch (reg) {
				case 0:
					l = *p++;
					sprintf(ea, "$%04x.w", l);
					break;
				case 1:
					h = *p++; l = *p++;
					sprintf(ea, "$%08x.l", h << 16 | l);
					break;
				case 2:
					l = *p++;
					sprintf(ea, "$%x(pc)", l);
					break;
				case 3:
					p = DECODE_EA_EXT(p, mode, reg, breg);
					break;
				case 4:
					switch (size) {
						case 0: h = *p++; sprintf(ea, "#$%02x", (UINT8)h); break;
						case 1: h = *p++; sprintf(ea, "#$%04x", h); break;
						case 2: h = *p++; l = *p++; sprintf(ea, "#$%08x", h << 16 | l); break;
						case 3: break;
					}
					break;
				case 5:
				case 6:
				case 7:
					sprintf(ea, "ILLEGAL_EA");
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
	UINT16 l, h = *p++;
	p = DECODE_EA(p, op);
	switch (size) {
		case 0: // Byte
			printf("#$%02x", (UINT8)h);
			break;
		case 1: // Word
			printf("#$%04x", h);
			break;
		case 2: // Long
			l = *p++;
			printf("#$%08x", h << 16 | l);
			break;
	}
	printf(",%s\n", ea);
	return p;
}
APTR DECODE_RN_EA(APTR p, UINT16 op, UINT16 ex) {
	// INSTRUCTION <ea>,Rn
	// INSTRUCTION Rn,<ea>
	p = DECODE_EA1(p, op, BIT(op, 8), 0);
	if (BIT(ex, 11)) // Direction
		printf("%c%i,%s\n", BIT(op, 7) ? 'b' : DA[BIT(ex, 15)], DOWNTO(ex, 14, 12), ea);
	else
		printf("%s,%c%i\n", ea, BIT(op, 7) ? 'b' : DA[BIT(ex, 15)], DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_DN_EA(APTR p, UINT16 op, int dir) {
	// INSTRUCTION <ea>,Dn
	// INSTRUCTION Dn,<ea>
	p = DECODE_EA(p, op);
	if (dir)
		printf("d%i,%s\n", DOWNTO(op, 11, 9), ea);
	else
		printf("%s,d%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}

APTR DECODE_LABEL(APTR p, UINT16 op, int size) { // FIXME: Resolve correct relative address
	// <label>
	UINT16 l, h;
	switch (size) {
		case 0:
			printf("$%x\n", (p + (DOWNTO(op, 7, 0) >> 1)));
			break;
		case 1:
			h = *p++;
			printf("$%x\n", (((long)p) + ((short)h)) - 2);
			break;
		case 2:
			h = *p++;
			l = *p++;
			printf("$%x\n", (((long)p) + ((long)(h << 16) | l)) - 4);
			break;
	}
	return p;
}
APTR DECODE_BRANCH(APTR p, UINT16 op) {
	switch (DOWNTO(op, 7, 0)) {
		case 0x00: printf(".w   "); return DECODE_LABEL(p, op, 1);
		case 0xff: printf(".l   "); return DECODE_LABEL(p, op, 2);
		default:   printf(".s   "); return DECODE_LABEL(p, op, 0);
	}
}

/************************************************************************************
 * DECODE - 68000 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_000_ABCD(APTR p, UINT16 op) {
	// ABCD Dx,Dy
	// ABCD -(Ax),-(Ay)
	printf("ABCD    ");
	printf(BIT(op, 3) ? "-(a%i),-(a%i)\n" : "d%i,d%i\n", 
		DOWNTO(op, 2, 0), DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_NBCD(APTR p, UINT16 op) {
	// NBCD <ea>
	p = DECODE_EA(p, op);
	printf("NBCD    %s\n", ea);
	return p;
}
APTR DECODE_000_SBCD(APTR p, UINT16 op) {
	// SBCD Dx,Dy
	// SBCD -(Ax),-(Ay)
	printf("SBCD    ");
	printf(BIT(op, 3) ? "-(a%i),-(a%i)\n" : "d%i,d%i\n", 
		DOWNTO(op, 2, 0), DOWNTO(op, 11, 9));
	return p;
}

APTR DECODE_000_ADD(APTR p, UINT16 op, int size, int dir) {
	// ADD <ea>,Dn
	// ADD Dn,<ea>
	printf("ADD.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_ADDA(APTR p, UINT16 op, int size) {
	// ADDA <ea>,An
	p = DECODE_EA(p, op);
	printf("ADDA.%c  %s,a%i\n", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_ADDI(APTR p, UINT16 op, int size) {
	// ADDI #<data>,<ea>
	printf("ADDI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_ADDQ(APTR p, UINT16 op, int size) {
	// ADDQ #<data>,<ea>
	int data = DOWNTO(op, 11, 9);
	p = DECODE_EA(p, op);
	printf("ADDQ.%c  #$%x,%s\n", SZ[size], data == 0 ? 8 : data, ea);
	return p;
}
APTR DECODE_000_ADDX_DN_DN(APTR p, UINT16 op, int size) {
	// ADDX Dx,Dy
	printf("ADDX.%c  d%i,d%i\n", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_ADDX_AN_AN(APTR p, UINT16 op, int size) {
	// ADDX -(Ay),-(Ax)
	printf("ADDX.%c  -(a%i),-(a%i)\n", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_AND(APTR p, UINT16 op, int size, int dir) {
	// AND <ea>,Dn
	// AND Dn,<ea>
	printf("AND.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_ANDI(APTR p, UINT16 op, int size) {
	// ANDI #<data>,<ea>
	printf("ANDI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_ANDI_CCR(APTR p, UINT16 op) {
	// ANDI #<data>,CCR
	UINT16 h = *p++;
	printf("ANDI    #%02x,CCR\n", (UINT8)h);
	return p;
}
APTR DECODE_000_ANDI_SR(APTR p, UINT16 op) {
	// ANDI #<data>,SR
	UINT16 h = *p++;
	printf("ANDI    #%04x,SR\n", h);
	return p;
}
APTR DECODE_000_BKPT(APTR p, UINT16 op) {
	// BKPT #<data>
	printf("BKPT    #$%x\n", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_BRA(APTR p, UINT16 op) {
	// BRA <label>
	printf("BRA");
	return DECODE_BRANCH(p, op);
}
APTR DECODE_000_BSR(APTR p, UINT16 op) {
	// BSR <label>
	printf("BSR");
	return DECODE_BRANCH(p, op);
}
APTR DECODE_000_BCC(APTR p, UINT16 op) {
	// Bcc <label>
	printf("B%s", CC[DOWNTO(op, 11, 8)]);
	return DECODE_BRANCH(p, op);
}
APTR DECODE_000_DBCC(APTR p, UINT16 op) {
	// DBcc.W Dn,<label>
	printf("DB%s.w  d%x,", CC[DOWNTO(op, 11, 8)], DOWNTO(op, 2, 0));
	return DECODE_LABEL(p, op, 1);
}
APTR DECODE_000_BIT_D(APTR p, UINT16 op, char* name) {
	// BCHG Dn,<ea>    BCLR Dn,<ea>
	// BSET Dn,<ea>    BTST Dn,<ea>
	p = DECODE_EA(p, op);
	printf("%s    d%i,%s\n", name, DOWNTO(op, 11, 9), ea);
	return p;
}
APTR DECODE_000_BIT_S(APTR p, UINT16 op, char* name) {
	// BCHG #<data>,<ea>    BCLR #<data>,<ea>
	// BSET #<data>,<ea>    BTST #<data>,<ea>
	UINT16 h = *p++;
	p = DECODE_EA(p, op);
	printf("%s    #$%x,%s\n", name, (UINT8)h, ea);
	return p;
}
APTR DECODE_000_CHK(APTR p, UINT16 op, int size) {
	// CHK <ea>,Dn
	p = DECODE_EA(p, op);
	printf("CHK.%c   %s,d%i\n", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_CLR(APTR p, UINT16 op, int size) {
	// CLR <ea>
	p = DECODE_EA(p, op);
	printf("CLR.%c   %s\n", SZ[size], ea);
	return p;
}
APTR DECODE_000_CMP(APTR p, UINT16 op, int size) {
	// CMP <ea>,Dn
	p = DECODE_EA(p, op);
	printf("CMP.%c   %s,d%i\n", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_CMPA(APTR p, UINT16 op, int size) {
	// CMPA <ea>,An
	p = DECODE_EA(p, op);
	printf("CMPA.%c  %s,a%i\n", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_CMPI(APTR p, UINT16 op, int size) {
	// CMPI #<data>,<ea>
	printf("CMPI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_CMPM(APTR p, UINT16 op, int size) {
	// CMPM (Ax)+,(Ay)+
	printf("CMPM.%c  (a%i)+,(a%i)+\n", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_DIVS(APTR p, UINT16 op) {
	// DIVS.W <ea>,Dn
	p = DECODE_EA(p, op);
	printf("DIVS.W  %s,d%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_DIVU(APTR p, UINT16 op) {
	// DIVU.W <ea>,Dn
	p = DECODE_EA(p, op);
	printf("DIVU.W  %s,d%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_EXG(APTR p, UINT16 op) {
	// EXG Dm,Dn
	// EXG Ax,Ay
	// EXG Dn,An
	printf("EXG     ");
	switch (DOWNTO(op, 7, 3)) {
		case  8: printf("d%i,d%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0)); break;
		case  9: printf("a%i,a%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0)); break;
		case 17: printf("d%i,a%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0)); break;
	}
	return p;
}
APTR DECODE_000_EOR(APTR p, UINT16 op, int size) {
	// EOR Dn,<ea>
	printf("EOR.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, 1);
}
APTR DECODE_000_EORI(APTR p, UINT16 op, int size) {
	// EORI #<data>,<ea>
	printf("EORI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_EORI_CCR(APTR p, UINT16 op) {
	// EORI #<data>,CCR
	UINT16 h = *p++;
	printf("EORI    #$%02x,CCR\n", (UINT8)h);
	return p;
}
APTR DECODE_000_EORI_SR(APTR p, UINT16 op) {
	// EORI #<data>,SR
	UINT16 h = *p++;
	printf("EORI    #$%04x,SR\n", h);
	return p;
}
APTR DECODE_000_EXT(APTR p, UINT16 op, int size) {
	// EXT Dn
	printf("EXT.%c  d%i", SZ[size], DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_ILLEGAL(APTR p, UINT16 op) {
	// ILLEGAL
	printf("ILLEGAL\n");
	return p;
}
APTR DECODE_000_JMP(APTR p, UINT16 op) {
	// JMP <ea>
	p = DECODE_EA(p, op);
	printf("JMP     %s\n", ea);
	return p;
}
APTR DECODE_000_JSR(APTR p, UINT16 op) {
	// JSR <ea>
	p = DECODE_EA(p, op);
	printf("JSR     %s\n", ea);
	return p;
}
APTR DECODE_000_LEA(APTR p, UINT16 op) {
	// LEA <ea>,An
	p = DECODE_EA(p, op);
	printf("LEA     %s,a%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_LINK(APTR p, UINT16 op) {
	// LINK An,#<displacement>
	UINT16 h = *p++;
	printf("LINK.W  a%i,#$%04x\n", DOWNTO(op, 2, 0), h);
	return p;
}
APTR DECODE_000_PEA(APTR p, UINT16 op) {
	// PEA <ea>
	p = DECODE_EA(p, op);
	printf("PEA     %s\n", ea);
	return p;
}
APTR DECODE_000_MOVE_CCR(APTR p, UINT16 op, int dir) {
	// MOVE <ea>,CCR
	// MOVE CCR,<ea>
	p = DECODE_EA(p, op);
	printf("MOVE   ");
	printf(dir ? "%s,CCR\n" : "CCR,%s\n", ea);
	return p;
}
APTR DECODE_000_MOVE_SR(APTR p, UINT16 op, int dir) {
	// MOVE <ea>,SR
	// MOVE SR,<ea>
	p = DECODE_EA(p, op);
	printf("MOVE   ");
	printf(dir ? "%s,SR\n" : "SR,%s\n", ea);
	return p;
}
APTR DECODE_000_MOVE_USP(APTR p, UINT16 op, int dir) {
	// MOVE USP,An
	// MOVE An,USP
	printf("MOVE    ");
	printf(dir ? "USP,a%i\n" : "a%i,USP\n", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_MOVE(APTR p, UINT16 op, int size) {
	// MOVE <ea>,<ea>
	p = DECODE_EA2(p, DOWNTO(op, 5, 3), DOWNTO(op,  2, 0), 0, size); // src (mode,reg)
	printf("MOVE.%c  %s", SZ[size], ea);
	p = DECODE_EA2(p, DOWNTO(op, 8, 6), DOWNTO(op, 11, 9), 0, size); // dst (reg,mode)
	printf(",%s\n", ea);
	return p;
}
APTR DECODE_000_MOVEA(APTR p, UINT16 op, int size) {
	// MOVEA <ea>,An
	p = DECODE_EA(p, op);
	printf("MOVEA.%c %s,a%i\n", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MOVEM(APTR p, UINT16 op, int size, int dir) {
	// MOVEM <ea>,<list>
	// MOVEM <list>,<ea>
	UINT16 list = *p++;
	printf("MOVEM.%c ", SZ[size]);
	if(dir) {
		p = DECODE_EA(p, op);
		printf("%s,", ea);
		DECODE_LIST(op, list);
	} else {
		DECODE_LIST(op, list);
		p = DECODE_EA(p, op);
		printf(",%s", ea);
	}
	printf("\n", ea);
	return p;
}
APTR DECODE_000_MOVEP(APTR p, UINT16 op) {
	// MOVEP (d16,An),Dn
	// MOVEP Dn,(d16,An)
	UINT16 d16 = *p++;
	printf("MOVEP.%c ", SZ[1 + BIT(op, 6)]);
	if (BIT(op, 7))
		printf("d%i,$%04x(a%i)\n", DOWNTO(op, 11, 9), d16, DOWNTO(op, 2, 0));
	else
		printf("$%04x(a%i),d%i\n", d16, DOWNTO(op, 2, 0), DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MOVEQ(APTR p, UINT16 op) {
	// MOVEQ.L #<data>,Dn
	printf("MOVEQ.L #$%02x,d%i\n", DOWNTO(op, 7, 0), DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MULS(APTR p, UINT16 op) {
	// MULS.W <ea>,Dn
	p = DECODE_EA(p, op);
	printf("MULS.W  %s,d%x\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_MULU(APTR p, UINT16 op) {
	// MULU.W <ea>,Dn
	p = DECODE_EA(p, op);
	printf("MULU.W  %s,d%x\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_NEG(APTR p, UINT16 op, int size) {
	// NEG <ea>
	p = DECODE_EA(p, op);
	printf("NEG.%c   %s\n", SZ[size], ea);
	return p;
}
APTR DECODE_000_NEGX(APTR p, UINT16 op, int size) {
	// NEGX <ea>
	p = DECODE_EA(p, op);
	printf("NEGX.%c  %s\n", SZ[size], ea);
	return p;
}
APTR DECODE_000_NOP(APTR p, UINT16 op) {
	// NOP
	printf("NOP\n");
	return p;
}
APTR DECODE_000_NOT(APTR p, UINT16 op, int size) {
	// NOT <ea>
	p = DECODE_EA(p, op);
	printf("NOT.%c   %s\n", SZ[size], ea);
	return p;
}
APTR DECODE_000_OR(APTR p, UINT16 op, int size, int dir) {
	// OR <ea>,Dn
	// OR Dn,<ea>
	printf("OR.%c    ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_ORI(APTR p, UINT16 op, int size) {
	// ORI #<data>,<ea>
	printf("ORI.%c   ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_ORI_CCR(APTR p, UINT16 op) {
	// ORI #<data>,CCR
	UINT16 h = *p++;
	printf("ORI     #$%02x,CCR\n", (UINT8)h);
	return p;
}
APTR DECODE_000_ORI_SR(APTR p, UINT16 op) {
	// ORI #<data>,SR
	UINT16 h = *p++;
	printf("ORI     #$%04x,SR\n", h);
	return p;
}
APTR DECODE_000_RESET(APTR p, UINT16 op) {
	// RESET
	printf("RESET\n");
	return p;
}
APTR DECODE_000_RTE(APTR p, UINT16 op) {
	// RTE
	printf("RTE\n");
	return p;
}
APTR DECODE_000_RTR(APTR p, UINT16 op) {
	// RTR
	printf("RTR\n");
	return p;
}
APTR DECODE_000_RTS(APTR p, UINT16 op) {
	// RTS
	printf("RTS\n");
	return p;
}
APTR DECODE_000_SCC(APTR p, UINT16 op) {
	// Scc <ea>
	p = DECODE_EA(p, op);
	printf("S%s     %s\n", CC[DOWNTO(op, 11, 8)], ea);
	return p;
}
APTR DECODE_000_SHIFT(APTR p, UINT16 op) {
	// ASd, LSd, ROd, ROXd Dx,Dy
	// ASd, LSd, ROd, ROXd #<data>,Dy
	// ASd, LSd, ROd, ROXd <ea>
	int value;
	if (DOWNTO(op, 7, 6) == 3) {
		switch (DOWNTO(op, 10 ,9)) {
			case 0: printf("AS" ); break; // Arithmetic Shift
			case 1: printf("LS" ); break; // Logical Shift
			case 2: printf("ROX"); break; // Rotate with Extend
			case 3: printf("RO" ); break; // Rotate without Extend
		}
		p = DECODE_EA(p, op);
		printf("%c.%c %s\n", LR[BIT(op, 8)], SZ[DOWNTO(op, 7, 6)], ea);
	}
	else
	{
		switch (DOWNTO(op, 4, 3)) {
			case 0: printf("AS" ); break; // Arithmetic Shift
			case 1: printf("LS" ); break; // Logical Shift
			case 2: printf("ROX"); break; // Rotate with Extend
			case 3: printf("RO" ); break; // Rotate without Extend
		}
		value = DOWNTO(op, 11, 9);
		printf("%c.%c   %s%x,d%x\n",
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
	UINT16 l = *p++;
	printf("STOP #$%x\n", l);
	return p;
}
APTR DECODE_000_SUB(APTR p, UINT16 op, int size, int dir) {
	// SUB <ea>,Dn
	// SUB Dn,<ea>
	printf("SUB.%c   ", SZ[size]);
	return DECODE_DN_EA(p, op, dir);
}
APTR DECODE_000_SUBA(APTR p, UINT16 op, int size) {
	// SUBA <ea>,An
	p = DECODE_EA(p, op);
	printf("SUBA.%c  %s,a%i\n", SZ[size], ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_000_SUBI(APTR p, UINT16 op, int size) {
	// SUBI #<data>,<ea>
	printf("SUBI.%c  ", SZ[size]);
	return DECODE_IM_EA(p, op, size);
}
APTR DECODE_000_SUBQ(APTR p, UINT16 op, int size) {
	// SUBQ #<data>,<ea>
	int data = DOWNTO(op, 11, 9);
	p = DECODE_EA(p, op);
	printf("SUBQ.%c  #$%x,%s\n", SZ[size], data == 0 ? 8 : data, ea);
	return p;
}
APTR DECODE_000_SUBX_DN_DN(APTR p, UINT16 op, int size) {
	// SUBX Dx,Dy
	printf("SUBX.%c  d%i,d%i\n", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_SUBX_AN_AN(APTR p, UINT16 op, int size) {
	// SUBX -(Ax),-(Ay)
	printf("SUBX.%c  -(a%x),-(a%x)\n", SZ[size], DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_SWAP(APTR p, UINT16 op) {
	// SWAP Dn
	printf("SWAP    d%i\n", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_000_TAS(APTR p, UINT16 op) {
	// TAS <ea>
	p = DECODE_EA(p, op);
	printf("TAS     %s\n", ea);
	return p;
}
APTR DECODE_000_TRAP(APTR p, UINT16 op) {
	// TRAP #<vector>
	printf("TRAP    #$%x\n", DOWNTO(op, 3, 0));
	return p;
}
APTR DECODE_000_TRAPV(APTR p, UINT16 op) {
	// TRAPV
	printf("TRAPV\n");
	return p;
}
APTR DECODE_000_TST(APTR p, UINT16 op, int size) {
	// TST <ea>
	p = DECODE_EA(p, op);
	printf("TST.%c   %s\n", SZ[size], ea);
	return p;
}
APTR DECODE_000_UNLK(APTR p, UINT16 op) {
	// UNLK An
	printf("UNLK    a%i\n", DOWNTO(op, 2, 0));
	return p;
}

/************************************************************************************
 * DECODE - 68010 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_010_RTD(APTR p, UINT16 op) {
	// RTD #<displacement>
	UINT16 l = *p++;
	printf("RTD #$%x\n", l);
	return p;
}
APTR DECODE_010_MOVEC(APTR p, UINT16 op) {
	// MOVEC Rc,Rn
	// MOVEC Rn,Rc
	UINT16 h = *p++;
	DECODE_CREG(DOWNTO(h, 11, 0));
	printf("MOVEC   ");
	if (BIT(op, 0))
		printf("%c%i,%s\n", DA[BIT(h, 15)], DOWNTO(h, 14, 12), cr);
	else
		printf("%s,%c%i\n", cr, DA[BIT(h, 15)], DOWNTO(h, 14, 12));
	return p;
}
APTR DECODE_010_MOVES(APTR p, UINT16 op, UINT16 ex) {
	// MOVES Rn,<ea>
	// MOVES <ea>,Rn
	printf("MOVES.%c ", SZ[DOWNTO(op, 7, 6)]);
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
	UINT16 ex = *p++;
	p = DECODE_EA(p, op);
	printf("%s  ", name);
	if (reg && dir)
		printf("d%i,", DOWNTO(ex, 14, 12));
	printf("%s{%s%x:%s%x}",
		ea,
		BIT(ex, 11) ? "d" : "$",
		BIT(ex, 11) ? DOWNTO(ex, 8 ,6) : DOWNTO(ex, 10 ,6),
		BIT(ex,  5) ? "d" : "$",
		BIT(ex,  5) ? DOWNTO(ex, 2, 0) : DOWNTO(ex,  4, 0)
	);
	if (reg && !dir)
		printf(",d%i", DOWNTO(ex, 14, 12));
	printf("\n");
	return p;
}

APTR DECODE_020_CAS(APTR p, UINT16 op, int size) {
	// CAS Dc,Du,<ea>
	UINT16 ex = *p++;
	p = DECODE_EA(p, op);
	printf("CAS.%c   d%i,d%i,%s\n", SZ[size], DOWNTO(ex, 2, 0), DOWNTO(ex, 8, 6), ea);
	return p;
}
APTR DECODE_020_CAS2(APTR p, UINT16 op, int size) {
	// CAS2 Dc1:Dc2,Du1:Du2,(Rn1):(Rn2)
	UINT16 ex1 = *p++;
	UINT16 ex2 = *p++;
	printf("CAS2.%c  d%i:d%i,d%i:d%i,(%c%i):(%c%i)\n", 
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
	printf("CHK2.%c  %s,%c%i\n", SZ[size], ea, DA[BIT(ex, 15)], DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_020_CMP2(APTR p, UINT16 op, UINT16 ex, int size) {
	// CMP2 <ea>,Rn
	p = DECODE_EA(p, op);
	printf("CMP2.%c  %s,%c%i\n", SZ[size], ea, DA[BIT(ex, 15)], DOWNTO(ex, 14, 12));
	return p;
}
APTR DECODE_020_DIV(APTR p, UINT16 op) { // TODO: DIVxL <ea>,Dr:Dq
	// DIVU.L  <ea>,Dq     32/16 => 32q
	// DIVU.L  <ea>,Dr:Dq  64/32 => 32r-32q
	// DIVUL.L <ea>,Dr:Dq  32/32 => 32r-32q
	// DIVS.L  <ea>,Dq     32/32 => 32q
	// DIVS.L  <ea>,Dr:Dq  64/32 => 32r-32q
	// DIVSL.L <ea>,Dr:Dq  32/32 => 32r-32q
	UINT16 ex = *p++;
	p = DECODE_EA(p, op);
	printf("DIV%s.L  %s,", BIT(ex, 11) ? "S" : "U", ea);
	if (BIT(ex, 10))
		printf("d%i:", DOWNTO(ex, 14, 12));
	printf("d%i\n", DOWNTO(ex, 2, 0));
	return p;
}
APTR DECODE_020_MUL(APTR p, UINT16 op) {
	// MULU.L <ea>,Dl
	// MULU.L <ea>,Dh:Dl
	// MULS.L <ea>,Dl
	// MULS.L <ea>,Dh:Dl
	UINT16 ex = *p++;
	p = DECODE_EA(p, op);
	printf("MUL%s.L  %s,", BIT(ex, 11) ? "S" : "U", ea);
	if (BIT(ex, 10))
		printf("d%i:", DOWNTO(ex, 2, 0));
	printf("d%i\n", DOWNTO(ex, 14, 12));
	return p;
}

APTR DECODE_020_EXTB(APTR p, UINT16 op) {
	// EXTB.L  Dn
	printf("EXTB.L  d%i", DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_020_LINK(APTR p, UINT16 op) {
	// LINK.L  An,#<displacement>
	UINT16 l = *p++;
	UINT16 h = *p++;
	printf("LINK.L  a%i,#$%08x\n", DOWNTO(op, 2, 0), h << 16 | l);
	return p;
}
APTR DECODE_020_PACK(APTR p, UINT16 op) { // TODO
	// PACK –(Ax),–(Ay),#<adjustment>
	// PACK Dx,Dy,#<adjustment>
	UINT16 ex = *p++;
	printf("PACK\n");
	return p;
}
APTR DECODE_020_UNPK(APTR p, UINT16 op) { // TODO
	// UNPK –(Ax),–(Ay),#<adjustment>
	// UNPK Dx,Dy,#<adjustment>
	UINT16 ex = *p++;
	printf("UNPK\n");
	return p;
}
APTR DECODE_020_TRAPCC(APTR p, UINT16 op, int mode) {
	// TRAPcc
	// TRAPcc.W #<data>
	// TRAPcc.L #<data>
	UINT16 l, h;
	printf("TRAP%s", CC[DOWNTO(op, 11, 8)]);
	switch (mode) {
		case 2:
			h = *p++;
			printf("  #$%04x\n", h);
			break;
		case 3:
			h = *p++;
			l = *p++;
			printf("  #$%08x\n", h << 16 | l);
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
	UINT16 l, h = *p++;
	printf("MOVE16  ");
	switch (DOWNTO(op, 5, 3)) {
		case 0: l = *p++; printf("(a%x)+,($%x).L", DOWNTO(op, 2, 0), (( h << 16 ) | l)); break;
		case 1: l = *p++; printf("($%x).L,(a%x)+", DOWNTO(op, 2, 0), (( h << 16 ) | l)); break;
		case 2: l = *p++; printf("(a%x),($%x).L",  DOWNTO(op, 2, 0), (( h << 16 ) | l)); break;
		case 3: l = *p++; printf("($%x).L,(a%x)",  DOWNTO(op, 2, 0), (( h << 16 ) | l)); break;
		case 4:           printf("(a%x)+,(a%x)+",  DOWNTO(op, 2, 0), DOWNTO(h, 14, 12)); break;
	}
	printf("\n");
	return p;
}
APTR DECODE_040_CINV(APTR p, UINT16 op) {
	// CINVL <caches>,(An)   -- Line
	// CINVP <caches>,(An)   -- Page
	// CINVA <caches>        -- All
	printf("CINV");
	switch (DOWNTO(op, 4, 3)) {
		case 0: printf("    ILLEGAL\n" );
		case 1: printf("L   %i,(A%i)\n", DOWNTO(op, 7, 6), DOWNTO(op, 2, 0));
		case 2: printf("P   %i,(A%i)\n", DOWNTO(op, 7, 6), DOWNTO(op, 2, 0));
		case 3: printf("A   %i\n"      , DOWNTO(op, 7, 6));
	}
	return p;
}

/************************************************************************************
 * DECODE - 68080 INSTRUCTIONS
 ***********************************************************************************/

APTR DECODE_080_ABS(APTR p, UINT16 op, UINT16 ex) {
	// ABS <ea>,Rn
	// ABS Rn,<ea>
	printf("ABS.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_ADDQ(APTR p, UINT16 op) {
	// ADDQ.L #<data>,Bn
	printf("ADDQ.L  #%i,b%x\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADDIW(APTR p, UINT16 op) {
	// ADDIW.L #<data>,<ea>
	UINT16 h = *p++;
	p = DECODE_EA(p, op);
	printf("ADDIW.L #$%04x,%s\n", h, ea);
	return p;
}
APTR DECODE_080_ADD_BN_DN(APTR p, UINT16 op) {
	// ADD.L Bn,Dn
	printf("ADD.L   b%i,d%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADD_BN_AN(APTR p, UINT16 op) {
	// ADDA.L Bn,An
	printf("ADDA.L  b%i,a%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADD_BN_BN(APTR p, UINT16 op) {
	// ADDA.L Bn,Bn
	printf("ADDA.L  b%i,b%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_ADD_EA_BN(APTR p, UINT16 op) {
	// ADDA.L <ea>,Bn
	p = DECODE_EA(p, op);
	printf("ADDA.L  %s,b%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_AND(APTR p, UINT16 op, UINT16 ex) {
	// AND <ea>,Rn
	// AND Rn,<ea>
	printf("AND.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_ANDN(APTR p, UINT16 op, UINT16 ex) {
	// ANDN <ea>,Rn
	// ANDN Rn,<ea>
	printf("ANDN.%c  ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_CMPIW(APTR p, UINT16 op) {
	// CMPIW.L #<data>,<ea>
	UINT16 h = *p++;
	p = DECODE_EA(p, op);
	printf("CMPIW.L #$%04x,%s\n", h, ea);
	return p;
}
APTR DECODE_080_CMP_BN_DN(APTR p, UINT16 op) {
	// CMP.L Bn,Dn
	printf("CMP.L   b%i,d%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_CMP_BN_AN(APTR p, UINT16 op) {
	// CMPA.L Bn,An
	printf("CMPA.L  b%i,a%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_CMP_BN_BN(APTR p, UINT16 op) {
	// CMPA.L Bn,Bn
	printf("CMPA.L  b%i,b%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_CMP_EA_BN(APTR p, UINT16 op) {
	// CMPA.L <ea>,Bn
	p = DECODE_EA(p, op);
	printf("CMPA.L  %s,b%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_EOR(APTR p, UINT16 op, UINT16 ex) {
	// EOR <ea>,Rn
	// EOR Rn,<ea>
	printf("EOR.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_LEA(APTR p, UINT16 op, int dir) {
	// LEA <ea>,Bn
	// LEA Bn,An
	printf("LEA     ");
	if (dir) {
		p = DECODE_EA(p, op);
		printf("%s,b", ea);
	} else {
		printf("b%i,a", DOWNTO(op, 2, 0));
	}
	printf("%i\n", DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_MAX(APTR p, UINT16 op, UINT16 ex) {
	// MAX <ea>,Rn
	// MAX Rn,<ea>
	printf("MAX.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_MIN(APTR p, UINT16 op, UINT16 ex) {
	// MIN <ea>,Rn
	// MIN Rn,<ea>
	printf("MIN.%c   ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_MOVE(APTR p, UINT16 op, int dir) {
	// MOVE.L  Bn,<ea>
	// MOVEA.L <ea>,Bn
	p = DECODE_EA(p, op);
	printf("MOVE.L  ");
	if (dir)
		printf("b%i,%s\n", DOWNTO(op, 11, 9), ea);
	else
		printf("%s,b%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}
APTR DECODE_080_MOVEX(APTR p, UINT16 op, UINT16 ex) {
	// MOVEX <ea>,Rn
	// MOVEX Rn,<ea>
	printf("MOVEX.%c ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_OR(APTR p, UINT16 op, UINT16 ex) {
	// OR <ea>,Rn
	// OR Rn,<ea>
	printf("OR.%c    ", SZ[DOWNTO(op, 7, 6)]);
	return DECODE_RN_EA(p, op, ex);
}
APTR DECODE_080_PERM(APTR p, UINT16 op) {
	// PERM #<data>,Rm,Rn
	UINT16 ex = *p++;
	printf("PERM    #$%s,%c%i,%c%i", 
	DOWNTO(op, 11, 0),                    // Immediate 12-bits
	DA[BIT(op,  4)], DOWNTO(op,  3,  0),  // Regiser A
	DA[BIT(ex, 15)], DOWNTO(op, 14, 12)); // Regiser B
	return p;
}
APTR DECODE_080_SUBQ(APTR p, UINT16 op) {
	// SUBQ.L #<data>,Bn
	printf("SUBQ.L  #%i,b%x\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_BN_DN(APTR p, UINT16 op) {
	// SUB.L Bn,Dn
	printf("SUB.L   b%i,d%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_BN_AN(APTR p, UINT16 op) {
	// SUBA.L Bn,An
	printf("SUBA.L  b%i,a%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_BN_BN(APTR p, UINT16 op) {
	// SUBA.L Bn,Bn
	printf("SUBA.L  b%i,b%i\n", DOWNTO(op, 11, 9), DOWNTO(op, 2, 0));
	return p;
}
APTR DECODE_080_SUB_EA_BN(APTR p, UINT16 op) {
	// SUBA.L <ea>,Bn
	p = DECODE_EA(p, op);
	printf("SUBA.L  %s,b%i\n", ea, DOWNTO(op, 11, 9));
	return p;
}

/************************************************************************************
 * DECODE - LINES #0 to #F
 ***********************************************************************************/

APTR LINE_0(APTR p) {
	
	UINT16 ex, op = *p++;
	
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
					ex = *p++;
					if (BIT(ex, 11))
						return DECODE_020_CHK2(p, op, ex, 0);
					return DECODE_020_CMP2(p, op, ex, 0);
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
					ex = *p++;
					if (BIT(ex, 11))
						return DECODE_020_CHK2(p, op, ex, 1);
					return DECODE_020_CMP2(p, op, ex, 1);
			}
			
		case 2: // SUBI, CHK2.L, CMP2.L
			
			switch (DOWNTO(op, 7, 6)) {
				case 0: return DECODE_000_SUBI(p, op, 0);
				case 1: return DECODE_000_SUBI(p, op, 1);
				case 2: return DECODE_000_SUBI(p, op, 2);
				case 3:
					ex = *p++;
					if (BIT(ex, 11))
						return DECODE_020_CHK2(p, op, ex, 2);
					return DECODE_020_CMP2(p, op, ex, 2);
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
			
			ex = *p++;
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
APTR LINE_1(APTR p) {
	UINT16 op = *p++;
	// MOVE.L Bn,<ea>
	if (DOWNTO(op, 5, 3) == 1)
		return DECODE_080_MOVE(p, op, 1);
	// MOVE.L <ea>,Bn
	if (DOWNTO(op, 8, 6) == 1)
		return DECODE_080_MOVE(p, op, 0);
	// MOVE.B  <ea>,<ea>
	return DECODE_000_MOVE(p, op, 0);      
}
APTR LINE_2(APTR p) {
	UINT16 op = *p++;
	// MOVEA.L <ea>,An
	if (DOWNTO(op, 8, 6) == 1)
		return DECODE_000_MOVEA(p, op, 2);
	// MOVE.L  <ea>,<ea>
	return DECODE_000_MOVE(p, op, 2);
}
APTR LINE_3(APTR p) {
	UINT16 op = *p++;
	// MOVEA.W <ea>,An
	if (DOWNTO(op, 8, 6) == 1)
		return DECODE_000_MOVEA(p, op, 1);
	// MOVE.W  <ea>,<ea>
	return DECODE_000_MOVE(p, op, 1);
}
APTR LINE_4(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_5(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_6(APTR p) {
	UINT16 op = *p++;
	switch (DOWNTO(op, 11, 8)) {
		case 0: return DECODE_000_BRA(p, op);
		case 1: return DECODE_000_BSR(p, op);
	}
	return DECODE_000_BCC(p, op);
}
APTR LINE_7(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_8(APTR p) {
	
	UINT16 op = *p++;
	
	switch (DOWNTO(op, 8, 6)) {
		case 0: return DECODE_000_OR(p, op, 0, 0);
		case 1: return DECODE_000_OR(p, op, 1, 0);
		case 2: return DECODE_000_OR(p, op, 2, 0);
		case 3: return DECODE_000_DIVU(p, op);
		case 4: return DOWNTO(op, 5, 4) ? DECODE_000_OR(p, op, 0, 1) : DECODE_000_SBCD(p, op);
		case 5: return DOWNTO(op, 5, 4) ? DECODE_000_OR(p, op, 1, 1) : DECODE_020_PACK(p, op);
		case 6: return DOWNTO(op, 5, 4) ? DECODE_000_OR(p, op, 2, 1) : DECODE_020_UNPK(p, op);
		case 7: return DECODE_000_DIVS(p, op);
	}
	
	return p;
}
APTR LINE_9(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_A(APTR p) {
	
	UINT16 op = *p++;
	printf("ATRAP   #$%04x\n", op);
	
	return p;
}
APTR LINE_B(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_C(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_D(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_E(APTR p) {
	
	UINT16 op = *p++;
	
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
APTR LINE_F(APTR p) {
	
	UINT16 op = *p++;
	
	switch (DOWNTO(op, 11, 9)) {
		case 0: printf("DC.w    $%04x  ; illegal opcode\n", op); break;
		case 1: printf("DC.w    $%04x  ; illegal opcode\n", op); break;
		case 2: printf("DC.w    $%04x  ; illegal opcode\n", op); break;
		case 3: return DECODE_040_MOVE16(p, op);
		case 4: printf("DC.w    $%04x  ; illegal opcode\n", op); break;
		case 5: printf("DC.w    $%04x  ; illegal opcode\n", op); break;
		case 6: printf("DC.w    $%04x  ; illegal opcode\n", op); break;
		case 7: printf("DC.w    $%04x  ; illegal opcode\n", op); break;
	}
	
	return p;
}

int DECODE(APTR mem, int size) {
	
	APTR p = mem;
	int count = 0;
	
	while ( size > ( p - mem ) ) {
		
		printf("%08x : %04x    ", p, *p);
		
		switch (DOWNTO(*p, 15, 12)) {
			case 0x0: p = LINE_0(p); break;
			case 0x1: p = LINE_1(p); break;
			case 0x2: p = LINE_2(p); break;
			case 0x3: p = LINE_3(p); break;
			case 0x4: p = LINE_4(p); break;
			case 0x5: p = LINE_5(p); break;
			case 0x6: p = LINE_6(p); break;
			case 0x7: p = LINE_7(p); break;
			case 0x8: p = LINE_8(p); break;
			case 0x9: p = LINE_9(p); break;
			case 0xA: p = LINE_A(p); break;
			case 0xB: p = LINE_B(p); break;
			case 0xC: p = LINE_C(p); break;
			case 0xD: p = LINE_D(p); break;
			case 0xE: p = LINE_E(p); break;
			case 0xF: p = LINE_F(p); break;
		}
		
		count++;
	}
	
	return count;
}

/************************************************************************************
 * ENTRY POINT
 ***********************************************************************************/

int main(int argc, char *argv[]) {
	
	if (argc > 1)
	{
		return DECODE((APTR)strtol(argv[1], NULL, 16), 80);
	}
	else
	{
		UINT16 p2[100] = {
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
		
		return DECODE(p2, 32);
	}
 }

/************************************************************************************
 * 68K RULEZ!
 ***********************************************************************************/
