/* -*- buffer-read-only: t -*-
 *
 *    opnames.h
 *
 *    Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007,
 *    2008 by Larry Wall and others
 *
 *    You may distribute under the terms of either the GNU General Public
 *    License or the Artistic License, as specified in the README file.
 *
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 * This file is built by regen/opcode.pl from its data.
 * Any changes made here will be lost!
 */

typedef enum opcode {
	OP_NULL		 = 0,
	OP_STUB		 = 1,
	OP_SCALAR	 = 2,
	OP_PUSHMARK	 = 3,
	OP_WANTARRAY	 = 4,
	OP_CONST	 = 5,
	OP_GVSV		 = 6,
	OP_GV		 = 7,
	OP_GELEM	 = 8,
	OP_PADSV	 = 9,
	OP_PADAV	 = 10,
	OP_PADHV	 = 11,
	OP_PADANY	 = 12,
	OP_PUSHRE	 = 13,
	OP_RV2GV	 = 14,
	OP_RV2SV	 = 15,
	OP_AV2ARYLEN	 = 16,
	OP_RV2CV	 = 17,
	OP_ANONCODE	 = 18,
	OP_PROTOTYPE	 = 19,
	OP_REFGEN	 = 20,
	OP_SREFGEN	 = 21,
	OP_REF		 = 22,
	OP_BLESS	 = 23,
	OP_BACKTICK	 = 24,
	OP_GLOB		 = 25,
	OP_READLINE	 = 26,
	OP_RCATLINE	 = 27,
	OP_REGCMAYBE	 = 28,
	OP_REGCRESET	 = 29,
	OP_REGCOMP	 = 30,
	OP_MATCH	 = 31,
	OP_QR		 = 32,
	OP_SUBST	 = 33,
	OP_SUBSTCONT	 = 34,
	OP_TRANS	 = 35,
	OP_TRANSR	 = 36,
	OP_SASSIGN	 = 37,
	OP_AASSIGN	 = 38,
	OP_CHOP		 = 39,
	OP_SCHOP	 = 40,
	OP_CHOMP	 = 41,
	OP_SCHOMP	 = 42,
	OP_DEFINED	 = 43,
	OP_UNDEF	 = 44,
	OP_STUDY	 = 45,
	OP_POS		 = 46,
	OP_PREINC	 = 47,
	OP_I_PREINC	 = 48,
	OP_PREDEC	 = 49,
	OP_I_PREDEC	 = 50,
	OP_POSTINC	 = 51,
	OP_I_POSTINC	 = 52,
	OP_POSTDEC	 = 53,
	OP_I_POSTDEC	 = 54,
	OP_POW		 = 55,
	OP_MULTIPLY	 = 56,
	OP_I_MULTIPLY	 = 57,
	OP_DIVIDE	 = 58,
	OP_I_DIVIDE	 = 59,
	OP_MODULO	 = 60,
	OP_I_MODULO	 = 61,
	OP_REPEAT	 = 62,
	OP_ADD		 = 63,
	OP_I_ADD	 = 64,
	OP_SUBTRACT	 = 65,
	OP_I_SUBTRACT	 = 66,
	OP_CONCAT	 = 67,
	OP_STRINGIFY	 = 68,
	OP_LEFT_SHIFT	 = 69,
	OP_RIGHT_SHIFT	 = 70,
	OP_LT		 = 71,
	OP_I_LT		 = 72,
	OP_GT		 = 73,
	OP_I_GT		 = 74,
	OP_LE		 = 75,
	OP_I_LE		 = 76,
	OP_GE		 = 77,
	OP_I_GE		 = 78,
	OP_EQ		 = 79,
	OP_I_EQ		 = 80,
	OP_NE		 = 81,
	OP_I_NE		 = 82,
	OP_NCMP		 = 83,
	OP_I_NCMP	 = 84,
	OP_SLT		 = 85,
	OP_SGT		 = 86,
	OP_SLE		 = 87,
	OP_SGE		 = 88,
	OP_SEQ		 = 89,
	OP_SNE		 = 90,
	OP_SCMP		 = 91,
	OP_BIT_AND	 = 92,
	OP_BIT_XOR	 = 93,
	OP_BIT_OR	 = 94,
	OP_NEGATE	 = 95,
	OP_I_NEGATE	 = 96,
	OP_NOT		 = 97,
	OP_COMPLEMENT	 = 98,
	OP_SMARTMATCH	 = 99,
	OP_ATAN2	 = 100,
	OP_SIN		 = 101,
	OP_COS		 = 102,
	OP_RAND		 = 103,
	OP_SRAND	 = 104,
	OP_EXP		 = 105,
	OP_LOG		 = 106,
	OP_SQRT		 = 107,
	OP_INT		 = 108,
	OP_HEX		 = 109,
	OP_OCT		 = 110,
	OP_ABS		 = 111,
	OP_LENGTH	 = 112,
	OP_SUBSTR	 = 113,
	OP_VEC		 = 114,
	OP_INDEX	 = 115,
	OP_RINDEX	 = 116,
	OP_SPRINTF	 = 117,
	OP_FORMLINE	 = 118,
	OP_ORD		 = 119,
	OP_CHR		 = 120,
	OP_CRYPT	 = 121,
	OP_UCFIRST	 = 122,
	OP_LCFIRST	 = 123,
	OP_UC		 = 124,
	OP_LC		 = 125,
	OP_QUOTEMETA	 = 126,
	OP_RV2AV	 = 127,
	OP_AELEMFAST	 = 128,
	OP_AELEMFAST_LEX = 129,
	OP_AELEM	 = 130,
	OP_ASLICE	 = 131,
	OP_AEACH	 = 132,
	OP_AKEYS	 = 133,
	OP_AVALUES	 = 134,
	OP_EACH		 = 135,
	OP_VALUES	 = 136,
	OP_KEYS		 = 137,
	OP_DELETE	 = 138,
	OP_EXISTS	 = 139,
	OP_RV2HV	 = 140,
	OP_HELEM	 = 141,
	OP_HSLICE	 = 142,
	OP_BOOLKEYS	 = 143,
	OP_UNPACK	 = 144,
	OP_PACK		 = 145,
	OP_SPLIT	 = 146,
	OP_JOIN		 = 147,
	OP_LIST		 = 148,
	OP_LSLICE	 = 149,
	OP_ANONLIST	 = 150,
	OP_ANONHASH	 = 151,
	OP_SPLICE	 = 152,
	OP_PUSH		 = 153,
	OP_POP		 = 154,
	OP_SHIFT	 = 155,
	OP_UNSHIFT	 = 156,
	OP_SORT		 = 157,
	OP_REVERSE	 = 158,
	OP_GREPSTART	 = 159,
	OP_GREPWHILE	 = 160,
	OP_MAPSTART	 = 161,
	OP_MAPWHILE	 = 162,
	OP_RANGE	 = 163,
	OP_FLIP		 = 164,
	OP_FLOP		 = 165,
	OP_AND		 = 166,
	OP_OR		 = 167,
	OP_XOR		 = 168,
	OP_DOR		 = 169,
	OP_COND_EXPR	 = 170,
	OP_ANDASSIGN	 = 171,
	OP_ORASSIGN	 = 172,
	OP_DORASSIGN	 = 173,
	OP_METHOD	 = 174,
	OP_ENTERSUB	 = 175,
	OP_LEAVESUB	 = 176,
	OP_LEAVESUBLV	 = 177,
	OP_CALLER	 = 178,
	OP_WARN		 = 179,
	OP_DIE		 = 180,
	OP_RESET	 = 181,
	OP_LINESEQ	 = 182,
	OP_NEXTSTATE	 = 183,
	OP_DBSTATE	 = 184,
	OP_UNSTACK	 = 185,
	OP_ENTER	 = 186,
	OP_LEAVE	 = 187,
	OP_SCOPE	 = 188,
	OP_ENTERITER	 = 189,
	OP_ITER		 = 190,
	OP_ENTERLOOP	 = 191,
	OP_LEAVELOOP	 = 192,
	OP_RETURN	 = 193,
	OP_LAST		 = 194,
	OP_NEXT		 = 195,
	OP_REDO		 = 196,
	OP_DUMP		 = 197,
	OP_GOTO		 = 198,
	OP_EXIT		 = 199,
	OP_METHOD_NAMED	 = 200,
	OP_ENTERGIVEN	 = 201,
	OP_LEAVEGIVEN	 = 202,
	OP_ENTERWHEN	 = 203,
	OP_LEAVEWHEN	 = 204,
	OP_BREAK	 = 205,
	OP_CONTINUE	 = 206,
	OP_OPEN		 = 207,
	OP_CLOSE	 = 208,
	OP_PIPE_OP	 = 209,
	OP_FILENO	 = 210,
	OP_UMASK	 = 211,
	OP_BINMODE	 = 212,
	OP_TIE		 = 213,
	OP_UNTIE	 = 214,
	OP_TIED		 = 215,
	OP_DBMOPEN	 = 216,
	OP_DBMCLOSE	 = 217,
	OP_SSELECT	 = 218,
	OP_SELECT	 = 219,
	OP_GETC		 = 220,
	OP_READ		 = 221,
	OP_ENTERWRITE	 = 222,
	OP_LEAVEWRITE	 = 223,
	OP_PRTF		 = 224,
	OP_PRINT	 = 225,
	OP_SAY		 = 226,
	OP_SYSOPEN	 = 227,
	OP_SYSSEEK	 = 228,
	OP_SYSREAD	 = 229,
	OP_SYSWRITE	 = 230,
	OP_EOF		 = 231,
	OP_TELL		 = 232,
	OP_SEEK		 = 233,
	OP_TRUNCATE	 = 234,
	OP_FCNTL	 = 235,
	OP_IOCTL	 = 236,
	OP_FLOCK	 = 237,
	OP_SEND		 = 238,
	OP_RECV		 = 239,
	OP_SOCKET	 = 240,
	OP_SOCKPAIR	 = 241,
	OP_BIND		 = 242,
	OP_CONNECT	 = 243,
	OP_LISTEN	 = 244,
	OP_ACCEPT	 = 245,
	OP_SHUTDOWN	 = 246,
	OP_GSOCKOPT	 = 247,
	OP_SSOCKOPT	 = 248,
	OP_GETSOCKNAME	 = 249,
	OP_GETPEERNAME	 = 250,
	OP_LSTAT	 = 251,
	OP_STAT		 = 252,
	OP_FTRREAD	 = 253,
	OP_FTRWRITE	 = 254,
	OP_FTREXEC	 = 255,
	OP_FTEREAD	 = 256,
	OP_FTEWRITE	 = 257,
	OP_FTEEXEC	 = 258,
	OP_FTIS		 = 259,
	OP_FTSIZE	 = 260,
	OP_FTMTIME	 = 261,
	OP_FTATIME	 = 262,
	OP_FTCTIME	 = 263,
	OP_FTROWNED	 = 264,
	OP_FTEOWNED	 = 265,
	OP_FTZERO	 = 266,
	OP_FTSOCK	 = 267,
	OP_FTCHR	 = 268,
	OP_FTBLK	 = 269,
	OP_FTFILE	 = 270,
	OP_FTDIR	 = 271,
	OP_FTPIPE	 = 272,
	OP_FTSUID	 = 273,
	OP_FTSGID	 = 274,
	OP_FTSVTX	 = 275,
	OP_FTLINK	 = 276,
	OP_FTTTY	 = 277,
	OP_FTTEXT	 = 278,
	OP_FTBINARY	 = 279,
	OP_CHDIR	 = 280,
	OP_CHOWN	 = 281,
	OP_CHROOT	 = 282,
	OP_UNLINK	 = 283,
	OP_CHMOD	 = 284,
	OP_UTIME	 = 285,
	OP_RENAME	 = 286,
	OP_LINK		 = 287,
	OP_SYMLINK	 = 288,
	OP_READLINK	 = 289,
	OP_MKDIR	 = 290,
	OP_RMDIR	 = 291,
	OP_OPEN_DIR	 = 292,
	OP_READDIR	 = 293,
	OP_TELLDIR	 = 294,
	OP_SEEKDIR	 = 295,
	OP_REWINDDIR	 = 296,
	OP_CLOSEDIR	 = 297,
	OP_FORK		 = 298,
	OP_WAIT		 = 299,
	OP_WAITPID	 = 300,
	OP_SYSTEM	 = 301,
	OP_EXEC		 = 302,
	OP_KILL		 = 303,
	OP_GETPPID	 = 304,
	OP_GETPGRP	 = 305,
	OP_SETPGRP	 = 306,
	OP_GETPRIORITY	 = 307,
	OP_SETPRIORITY	 = 308,
	OP_TIME		 = 309,
	OP_TMS		 = 310,
	OP_LOCALTIME	 = 311,
	OP_GMTIME	 = 312,
	OP_ALARM	 = 313,
	OP_SLEEP	 = 314,
	OP_SHMGET	 = 315,
	OP_SHMCTL	 = 316,
	OP_SHMREAD	 = 317,
	OP_SHMWRITE	 = 318,
	OP_MSGGET	 = 319,
	OP_MSGCTL	 = 320,
	OP_MSGSND	 = 321,
	OP_MSGRCV	 = 322,
	OP_SEMOP	 = 323,
	OP_SEMGET	 = 324,
	OP_SEMCTL	 = 325,
	OP_REQUIRE	 = 326,
	OP_DOFILE	 = 327,
	OP_HINTSEVAL	 = 328,
	OP_ENTEREVAL	 = 329,
	OP_LEAVEEVAL	 = 330,
	OP_ENTERTRY	 = 331,
	OP_LEAVETRY	 = 332,
	OP_GHBYNAME	 = 333,
	OP_GHBYADDR	 = 334,
	OP_GHOSTENT	 = 335,
	OP_GNBYNAME	 = 336,
	OP_GNBYADDR	 = 337,
	OP_GNETENT	 = 338,
	OP_GPBYNAME	 = 339,
	OP_GPBYNUMBER	 = 340,
	OP_GPROTOENT	 = 341,
	OP_GSBYNAME	 = 342,
	OP_GSBYPORT	 = 343,
	OP_GSERVENT	 = 344,
	OP_SHOSTENT	 = 345,
	OP_SNETENT	 = 346,
	OP_SPROTOENT	 = 347,
	OP_SSERVENT	 = 348,
	OP_EHOSTENT	 = 349,
	OP_ENETENT	 = 350,
	OP_EPROTOENT	 = 351,
	OP_ESERVENT	 = 352,
	OP_GPWNAM	 = 353,
	OP_GPWUID	 = 354,
	OP_GPWENT	 = 355,
	OP_SPWENT	 = 356,
	OP_EPWENT	 = 357,
	OP_GGRNAM	 = 358,
	OP_GGRGID	 = 359,
	OP_GGRENT	 = 360,
	OP_SGRENT	 = 361,
	OP_EGRENT	 = 362,
	OP_GETLOGIN	 = 363,
	OP_SYSCALL	 = 364,
	OP_LOCK		 = 365,
	OP_ONCE		 = 366,
	OP_CUSTOM	 = 367,
	OP_REACH	 = 368,
	OP_RKEYS	 = 369,
	OP_RVALUES	 = 370,
	OP_max		
} opcode;

#define MAXO 371

/* the OP_IS_(SOCKET|FILETEST) macros are optimized to a simple range
    check because all the member OPs are contiguous in opcode.pl
    <OPS> table.  opcode.pl verifies the range contiguity.  */

#define OP_IS_SOCKET(op)	\
	((op) >= OP_SEND && (op) <= OP_GETPEERNAME)

#define OP_IS_FILETEST(op)	\
	((op) >= OP_FTRREAD && (op) <= OP_FTBINARY)

#define OP_IS_FILETEST_ACCESS(op)	\
	((op) >= OP_FTRREAD && (op) <= OP_FTEEXEC)

/* ex: set ro: */
