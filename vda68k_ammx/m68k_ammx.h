/* $VER: m68k_ammx.h V0.1 (12.08.2018)
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

#ifndef M68K_AMMX_H
#define M68K_AMMX_H

#define M68KAMMX_VER 0
#define M68KAMMX_REV 1

#define BIT(a,b)      (((a)>>(b))&1)
#define DOWNTO(a,b,c) (((a)>>(c))&((1<<((b)-(c)+1))-1))

enum ammx_operands {
	AMMX_IGNORE, // Null operand
	AMMX_VEA,    // <VEA>
	AMMX_REGA1,  // Rn
	AMMX_REGA2,  // Rn:Rm
	AMMX_REGAF,  // REGFILE[Rn]
	AMMX_REGB1,  // Rn
	AMMX_REGB2,  // Rn:Rm
	AMMX_REGBF,  // REGFILE[Rn]
	AMMX_REGD1,  // Rn
	AMMX_REGD2,  // Rn:Rm
	AMMX_REGDF   // REGFILE[Rn]
};

void ammx_vea_d8 (dis_buffer_t*, uint16, uint16, uint16);
void ammx_vea_bd (dis_buffer_t*, uint16, uint16, uint16);
void ammx_vea_an (dis_buffer_t*, uint16, uint16);
void ammx_vea_pc (dis_buffer_t*, uint16, uint16);
void ammx_vea_xn (dis_buffer_t*, uint16, uint16);
void ammx_vea_od (dis_buffer_t*, uint16, uint16);
void ammx_vea    (dis_buffer_t*, uint16);

void ammx_rega1  (dis_buffer_t*, uint16, uint16);
void ammx_rega2  (dis_buffer_t*, uint16, uint16);
void ammx_regaf  (dis_buffer_t*, uint16, uint16);
void ammx_regb1  (dis_buffer_t*, uint16, uint16);
void ammx_regb2  (dis_buffer_t*, uint16, uint16);
void ammx_regbf  (dis_buffer_t*, uint16, uint16);
void ammx_regd1  (dis_buffer_t*, uint16, uint16);
void ammx_regd2  (dis_buffer_t*, uint16, uint16);
void ammx_regdf  (dis_buffer_t*, uint16, uint16);

void ammx_vperm  (dis_buffer_t*, uint16, uint16);

void ammx_decode (dis_buffer_t*, uint16);

#endif /* M68K_AMMX_H */
