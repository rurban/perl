/*    run.c
 *
 *    Copyright (C) 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999,
 *    2000, 2001, 2004, 2005, 2006, 2010 by Larry Wall and others
 *
 *    You may distribute under the terms of either the GNU General Public
 *    License or the Artistic License, as specified in the README file.
 *
 */

/* This file contains the main Perl opcode execution loop. It just
 * calls the pp_foo() function associated with each op, and expects that
 * function to return a pointer to the next op to be executed, or null if
 * it's the end of the sub or program or whatever.
 *
 * There is a similar loop in dump.c, Perl_runops_debug(), which does
 * the same, but also checks for various debug flags each time round the
 * loop.
 *
 * Why this function requires a file all of its own is anybody's guess.
 * DAPM.
 */

#include "EXTERN.h"
#define PERL_IN_RUN_C
#include "perl.h"

/*
 * 'Away now, Shadowfax!  Run, greatheart, run as you have never run before!
 *  Now we are come to the lands where you were foaled, and every stone you
 *  know.  Run now!  Hope is in speed!'                    --Gandalf
 *
 *     [p.600 of _The Lord of the Rings_, III/xi: "The Palantír"]
 *
 * Instead of reading and writing to a global PL_op, we pass around a local op
 * (on %esp). 
 * The PL_op problem is only for unthreaded, as threaded uses PL_op as first 
 * member of the my_perl arg, at 4(%esp) in x86.
 * We already have to indirectly call the pp functions which cannot 
 * be prefetched by the CPU. With a static libperl.a those pp funcs need less 
 * indirection than with a shared libperl, but still CPU prefetching is lost.
 *
 * Threaded:
 *   my_perl->Iop = (PL_op->op_ppaddr)(my_perl);
 *   if (my_perl->Isig_pending) Perl_despatch_signals(my_perl);
 * Not threaded:
 *   op = (op->op_ppaddr)(op);
 *   if (PL_sig_pending) Perl_despatch_signals(); 
 */

int
Perl_runops_standard(pTHX)
{
    dVAR;
#if defined(USE_ITHREADS)
    while ((PL_op = CALL_FPTR(PL_op->op_ppaddr)(aTHX))) {
#else
    OP* op = PL_op;
    while ((op = CALL_FPTR(op->op_ppaddr)(op))) {
#endif
	PERL_ASYNC_CHECK();
    }

    TAINT_NOT;
    return 0;
}

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: t
 * End:
 *
 * ex: set ts=8 sts=4 sw=4 noet:
 */
