/*  -*- buffer-read-only: t -*-
 *
 *    embedvar.h
 *
 *    Copyright (C) 1993, 1994, 1995, 1996, 1997, 1998, 1999,
 *    2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, by Larry Wall and others
 *
 *    You may distribute under the terms of either the GNU General Public
 *    License or the Artistic License, as specified in the README file.
 *
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 * This file is built by embed.pl from data in embed.fnc, embed.pl,
 * pp.sym, intrpvar.h, and perlvars.h.
 * Any changes made here will be lost!
 *
 * Edit those files and run 'make regen_headers' to effect changes.
 */

/* (Doing namespace management portably in C is really gross.) */

/*
   The following combinations of MULTIPLICITY and PERL_IMPLICIT_CONTEXT
   are supported:
     1) none
     2) MULTIPLICITY	# supported for compatibility
     3) MULTIPLICITY && PERL_IMPLICIT_CONTEXT

   All other combinations of these flags are errors.

   only #3 is supported directly, while #2 is a special
   case of #3 (supported by redefining vTHX appropriately).
*/

#if defined(MULTIPLICITY)
/* cases 2 and 3 above */

#  if defined(PERL_IMPLICIT_CONTEXT)
#    define vTHX	aTHX
#  else
#    define vTHX	PERL_GET_INTERP
#  endif

#define PL_Argv			(vTHX->IArgv)
#define PL_Cmd			(vTHX->ICmd)
#define PL_DBcv			(vTHX->IDBcv)
#define PL_DBgv			(vTHX->IDBgv)
#define PL_DBline		(vTHX->IDBline)
#define PL_DBsignal		(vTHX->IDBsignal)
#define PL_DBsingle		(vTHX->IDBsingle)
#define PL_DBsub		(vTHX->IDBsub)
#define PL_DBtrace		(vTHX->IDBtrace)
#define PL_Dir			(vTHX->IDir)
#define PL_Env			(vTHX->IEnv)
#define PL_LIO			(vTHX->ILIO)
#define PL_Mem			(vTHX->IMem)
#define PL_MemParse		(vTHX->IMemParse)
#define PL_MemShared		(vTHX->IMemShared)
#define PL_OpPtr		(vTHX->IOpPtr)
#define PL_OpSlab		(vTHX->IOpSlab)
#define PL_OpSpace		(vTHX->IOpSpace)
#define PL_Proc			(vTHX->IProc)
#define PL_Sock			(vTHX->ISock)
#define PL_StdIO		(vTHX->IStdIO)
#define PL_Sv			(vTHX->ISv)
#define PL_Xpv			(vTHX->IXpv)
#define PL_amagic_generation	(vTHX->Iamagic_generation)
#define PL_an			(vTHX->Ian)
#define PL_apiversion		(vTHX->Iapiversion)
#define PL_argvgv		(vTHX->Iargvgv)
#define PL_argvout_stack	(vTHX->Iargvout_stack)
#define PL_argvoutgv		(vTHX->Iargvoutgv)
#define PL_basetime		(vTHX->Ibasetime)
#define PL_beginav		(vTHX->Ibeginav)
#define PL_beginav_save		(vTHX->Ibeginav_save)
#define PL_blockhooks		(vTHX->Iblockhooks)
#define PL_body_arenas		(vTHX->Ibody_arenas)
#define PL_body_roots		(vTHX->Ibody_roots)
#define PL_bodytarget		(vTHX->Ibodytarget)
#define PL_breakable_sub_gen	(vTHX->Ibreakable_sub_gen)
#define PL_checkav		(vTHX->Icheckav)
#define PL_checkav_save		(vTHX->Icheckav_save)
#define PL_chopset		(vTHX->Ichopset)
#define PL_clocktick		(vTHX->Iclocktick)
#define PL_collation_ix		(vTHX->Icollation_ix)
#define PL_collation_name	(vTHX->Icollation_name)
#define PL_collation_standard	(vTHX->Icollation_standard)
#define PL_collxfrm_base	(vTHX->Icollxfrm_base)
#define PL_collxfrm_mult	(vTHX->Icollxfrm_mult)
#define PL_colors		(vTHX->Icolors)
#define PL_colorset		(vTHX->Icolorset)
#define PL_compcv		(vTHX->Icompcv)
#define PL_compiling		(vTHX->Icompiling)
#define PL_comppad		(vTHX->Icomppad)
#define PL_comppad_name		(vTHX->Icomppad_name)
#define PL_comppad_name_fill	(vTHX->Icomppad_name_fill)
#define PL_comppad_name_floor	(vTHX->Icomppad_name_floor)
#define PL_cop_seqmax		(vTHX->Icop_seqmax)
#define PL_cryptseen		(vTHX->Icryptseen)
#define PL_curcop		(vTHX->Icurcop)
#define PL_curcopdb		(vTHX->Icurcopdb)
#define PL_curpad		(vTHX->Icurpad)
#define PL_curpm		(vTHX->Icurpm)
#define PL_curstack		(vTHX->Icurstack)
#define PL_curstackinfo		(vTHX->Icurstackinfo)
#define PL_curstash		(vTHX->Icurstash)
#define PL_curstname		(vTHX->Icurstname)
#define PL_custom_op_descs	(vTHX->Icustom_op_descs)
#define PL_custom_op_names	(vTHX->Icustom_op_names)
#define PL_cv_has_eval		(vTHX->Icv_has_eval)
#define PL_dbargs		(vTHX->Idbargs)
#define PL_debstash		(vTHX->Idebstash)
#define PL_debug		(vTHX->Idebug)
#define PL_debug_pad		(vTHX->Idebug_pad)
#define PL_def_layerlist	(vTHX->Idef_layerlist)
#define PL_defgv		(vTHX->Idefgv)
#define PL_defoutgv		(vTHX->Idefoutgv)
#define PL_defstash		(vTHX->Idefstash)
#define PL_delaymagic		(vTHX->Idelaymagic)
#define PL_destroyhook		(vTHX->Idestroyhook)
#define PL_diehook		(vTHX->Idiehook)
#define PL_dirty		(vTHX->Idirty)
#define PL_doextract		(vTHX->Idoextract)
#define PL_doswitches		(vTHX->Idoswitches)
#define PL_dowarn		(vTHX->Idowarn)
#define PL_dumper_fd		(vTHX->Idumper_fd)
#define PL_dumpindent		(vTHX->Idumpindent)
#define PL_e_script		(vTHX->Ie_script)
#define PL_efloatbuf		(vTHX->Iefloatbuf)
#define PL_efloatsize		(vTHX->Iefloatsize)
#define PL_egid			(vTHX->Iegid)
#define PL_encoding		(vTHX->Iencoding)
#define PL_endav		(vTHX->Iendav)
#define PL_envgv		(vTHX->Ienvgv)
#define PL_errgv		(vTHX->Ierrgv)
#define PL_errors		(vTHX->Ierrors)
#define PL_euid			(vTHX->Ieuid)
#define PL_eval_root		(vTHX->Ieval_root)
#define PL_eval_start		(vTHX->Ieval_start)
#define PL_evalseq		(vTHX->Ievalseq)
#define PL_exit_flags		(vTHX->Iexit_flags)
#define PL_exitlist		(vTHX->Iexitlist)
#define PL_exitlistlen		(vTHX->Iexitlistlen)
#define PL_fdpid		(vTHX->Ifdpid)
#define PL_filemode		(vTHX->Ifilemode)
#define PL_firstgv		(vTHX->Ifirstgv)
#define PL_forkprocess		(vTHX->Iforkprocess)
#define PL_formfeed		(vTHX->Iformfeed)
#define PL_formtarget		(vTHX->Iformtarget)
#define PL_generation		(vTHX->Igeneration)
#define PL_gensym		(vTHX->Igensym)
#define PL_gid			(vTHX->Igid)
#define PL_glob_index		(vTHX->Iglob_index)
#define PL_globalstash		(vTHX->Iglobalstash)
#define PL_hash_seed		(vTHX->Ihash_seed)
#define PL_hintgv		(vTHX->Ihintgv)
#define PL_hints		(vTHX->Ihints)
#define PL_hv_fetch_ent_mh	(vTHX->Ihv_fetch_ent_mh)
#define PL_in_clean_all		(vTHX->Iin_clean_all)
#define PL_in_clean_objs	(vTHX->Iin_clean_objs)
#define PL_in_eval		(vTHX->Iin_eval)
#define PL_in_load_module	(vTHX->Iin_load_module)
#define PL_incgv		(vTHX->Iincgv)
#define PL_initav		(vTHX->Iinitav)
#define PL_inplace		(vTHX->Iinplace)
#define PL_isarev		(vTHX->Iisarev)
#define PL_known_layers		(vTHX->Iknown_layers)
#define PL_last_in_gv		(vTHX->Ilast_in_gv)
#define PL_last_swash_hv	(vTHX->Ilast_swash_hv)
#define PL_last_swash_key	(vTHX->Ilast_swash_key)
#define PL_last_swash_klen	(vTHX->Ilast_swash_klen)
#define PL_last_swash_slen	(vTHX->Ilast_swash_slen)
#define PL_last_swash_tmps	(vTHX->Ilast_swash_tmps)
#define PL_lastfd		(vTHX->Ilastfd)
#define PL_lastgotoprobe	(vTHX->Ilastgotoprobe)
#define PL_lastscream		(vTHX->Ilastscream)
#define PL_laststatval		(vTHX->Ilaststatval)
#define PL_laststype		(vTHX->Ilaststype)
#define PL_localizing		(vTHX->Ilocalizing)
#define PL_localpatches		(vTHX->Ilocalpatches)
#define PL_lockhook		(vTHX->Ilockhook)
#define PL_madskills		(vTHX->Imadskills)
#define PL_main_cv		(vTHX->Imain_cv)
#define PL_main_root		(vTHX->Imain_root)
#define PL_main_start		(vTHX->Imain_start)
#define PL_mainstack		(vTHX->Imainstack)
#define PL_markstack		(vTHX->Imarkstack)
#define PL_markstack_max	(vTHX->Imarkstack_max)
#define PL_markstack_ptr	(vTHX->Imarkstack_ptr)
#define PL_max_intro_pending	(vTHX->Imax_intro_pending)
#define PL_maxo			(vTHX->Imaxo)
#define PL_maxscream		(vTHX->Imaxscream)
#define PL_maxsysfd		(vTHX->Imaxsysfd)
#define PL_memory_debug_header	(vTHX->Imemory_debug_header)
#define PL_mess_sv		(vTHX->Imess_sv)
#define PL_min_intro_pending	(vTHX->Imin_intro_pending)
#define PL_minus_E		(vTHX->Iminus_E)
#define PL_minus_F		(vTHX->Iminus_F)
#define PL_minus_a		(vTHX->Iminus_a)
#define PL_minus_c		(vTHX->Iminus_c)
#define PL_minus_l		(vTHX->Iminus_l)
#define PL_minus_n		(vTHX->Iminus_n)
#define PL_minus_p		(vTHX->Iminus_p)
#define PL_modcount		(vTHX->Imodcount)
#define PL_modglobal		(vTHX->Imodglobal)
#define PL_my_cxt_keys		(vTHX->Imy_cxt_keys)
#define PL_my_cxt_list		(vTHX->Imy_cxt_list)
#define PL_my_cxt_size		(vTHX->Imy_cxt_size)
#define PL_na			(vTHX->Ina)
#define PL_nomemok		(vTHX->Inomemok)
#define PL_numeric_local	(vTHX->Inumeric_local)
#define PL_numeric_name		(vTHX->Inumeric_name)
#define PL_numeric_radix_sv	(vTHX->Inumeric_radix_sv)
#define PL_numeric_standard	(vTHX->Inumeric_standard)
#define PL_ofsgv		(vTHX->Iofsgv)
#define PL_oldname		(vTHX->Ioldname)
#define PL_op			(vTHX->Iop)
#define PL_op_mask		(vTHX->Iop_mask)
#define PL_opfreehook		(vTHX->Iopfreehook)
#define PL_opsave		(vTHX->Iopsave)
#define PL_origalen		(vTHX->Iorigalen)
#define PL_origargc		(vTHX->Iorigargc)
#define PL_origargv		(vTHX->Iorigargv)
#define PL_origenviron		(vTHX->Iorigenviron)
#define PL_origfilename		(vTHX->Iorigfilename)
#define PL_ors_sv		(vTHX->Iors_sv)
#define PL_osname		(vTHX->Iosname)
#define PL_pad_reset_pending	(vTHX->Ipad_reset_pending)
#define PL_padix		(vTHX->Ipadix)
#define PL_padix_floor		(vTHX->Ipadix_floor)
#define PL_parser		(vTHX->Iparser)
#define PL_patchlevel		(vTHX->Ipatchlevel)
#define PL_peepp		(vTHX->Ipeepp)
#define PL_perl_destruct_level	(vTHX->Iperl_destruct_level)
#define PL_perldb		(vTHX->Iperldb)
#define PL_perlio		(vTHX->Iperlio)
#define PL_pidstatus		(vTHX->Ipidstatus)
#define PL_ppid			(vTHX->Ippid)
#define PL_preambleav		(vTHX->Ipreambleav)
#define PL_profiledata		(vTHX->Iprofiledata)
#define PL_psig_name		(vTHX->Ipsig_name)
#define PL_psig_pend		(vTHX->Ipsig_pend)
#define PL_psig_ptr		(vTHX->Ipsig_ptr)
#define PL_ptr_table		(vTHX->Iptr_table)
#define PL_reentrant_buffer	(vTHX->Ireentrant_buffer)
#define PL_reentrant_retint	(vTHX->Ireentrant_retint)
#define PL_reg_state		(vTHX->Ireg_state)
#define PL_regdummy		(vTHX->Iregdummy)
#define PL_regex_pad		(vTHX->Iregex_pad)
#define PL_regex_padav		(vTHX->Iregex_padav)
#define PL_reginterp_cnt	(vTHX->Ireginterp_cnt)
#define PL_registered_mros	(vTHX->Iregistered_mros)
#define PL_regmatch_slab	(vTHX->Iregmatch_slab)
#define PL_regmatch_state	(vTHX->Iregmatch_state)
#define PL_rehash_seed		(vTHX->Irehash_seed)
#define PL_rehash_seed_set	(vTHX->Irehash_seed_set)
#define PL_replgv		(vTHX->Ireplgv)
#define PL_restartjmpenv	(vTHX->Irestartjmpenv)
#define PL_restartop		(vTHX->Irestartop)
#define PL_rpeepp		(vTHX->Irpeepp)
#define PL_rs			(vTHX->Irs)
#define PL_runops		(vTHX->Irunops)
#define PL_savebegin		(vTHX->Isavebegin)
#define PL_savestack		(vTHX->Isavestack)
#define PL_savestack_ix		(vTHX->Isavestack_ix)
#define PL_savestack_max	(vTHX->Isavestack_max)
#define PL_sawampersand		(vTHX->Isawampersand)
#define PL_scopestack		(vTHX->Iscopestack)
#define PL_scopestack_ix	(vTHX->Iscopestack_ix)
#define PL_scopestack_max	(vTHX->Iscopestack_max)
#define PL_scopestack_name	(vTHX->Iscopestack_name)
#define PL_screamfirst		(vTHX->Iscreamfirst)
#define PL_screamnext		(vTHX->Iscreamnext)
#define PL_secondgv		(vTHX->Isecondgv)
#define PL_sharehook		(vTHX->Isharehook)
#define PL_sig_pending		(vTHX->Isig_pending)
#define PL_sighandlerp		(vTHX->Isighandlerp)
#define PL_signalhook		(vTHX->Isignalhook)
#define PL_signals		(vTHX->Isignals)
#define PL_slab_count		(vTHX->Islab_count)
#define PL_slabs		(vTHX->Islabs)
#define PL_sort_RealCmp		(vTHX->Isort_RealCmp)
#define PL_sortcop		(vTHX->Isortcop)
#define PL_sortstash		(vTHX->Isortstash)
#define PL_splitstr		(vTHX->Isplitstr)
#define PL_srand_called		(vTHX->Isrand_called)
#define PL_stack_base		(vTHX->Istack_base)
#define PL_stack_max		(vTHX->Istack_max)
#define PL_stack_sp		(vTHX->Istack_sp)
#define PL_start_env		(vTHX->Istart_env)
#define PL_stashcache		(vTHX->Istashcache)
#define PL_statbuf		(vTHX->Istatbuf)
#define PL_statcache		(vTHX->Istatcache)
#define PL_statgv		(vTHX->Istatgv)
#define PL_statname		(vTHX->Istatname)
#define PL_statusvalue		(vTHX->Istatusvalue)
#define PL_statusvalue_posix	(vTHX->Istatusvalue_posix)
#define PL_statusvalue_vms	(vTHX->Istatusvalue_vms)
#define PL_stderrgv		(vTHX->Istderrgv)
#define PL_stdingv		(vTHX->Istdingv)
#define PL_strtab		(vTHX->Istrtab)
#define PL_sub_generation	(vTHX->Isub_generation)
#define PL_subline		(vTHX->Isubline)
#define PL_subname		(vTHX->Isubname)
#define PL_sv_arenaroot		(vTHX->Isv_arenaroot)
#define PL_sv_count		(vTHX->Isv_count)
#define PL_sv_no		(vTHX->Isv_no)
#define PL_sv_objcount		(vTHX->Isv_objcount)
#define PL_sv_root		(vTHX->Isv_root)
#define PL_sv_serial		(vTHX->Isv_serial)
#define PL_sv_undef		(vTHX->Isv_undef)
#define PL_sv_yes		(vTHX->Isv_yes)
#define PL_sys_intern		(vTHX->Isys_intern)
#define PL_taint_warn		(vTHX->Itaint_warn)
#define PL_tainted		(vTHX->Itainted)
#define PL_tainting		(vTHX->Itainting)
#define PL_threadhook		(vTHX->Ithreadhook)
#define PL_timesbuf		(vTHX->Itimesbuf)
#define PL_tmps_floor		(vTHX->Itmps_floor)
#define PL_tmps_ix		(vTHX->Itmps_ix)
#define PL_tmps_max		(vTHX->Itmps_max)
#define PL_tmps_stack		(vTHX->Itmps_stack)
#define PL_top_env		(vTHX->Itop_env)
#define PL_toptarget		(vTHX->Itoptarget)
#define PL_uid			(vTHX->Iuid)
#define PL_unicode		(vTHX->Iunicode)
#define PL_unitcheckav		(vTHX->Iunitcheckav)
#define PL_unitcheckav_save	(vTHX->Iunitcheckav_save)
#define PL_unlockhook		(vTHX->Iunlockhook)
#define PL_unsafe		(vTHX->Iunsafe)
#define PL_utf8_X_L		(vTHX->Iutf8_X_L)
#define PL_utf8_X_LV		(vTHX->Iutf8_X_LV)
#define PL_utf8_X_LVT		(vTHX->Iutf8_X_LVT)
#define PL_utf8_X_LV_LVT_V	(vTHX->Iutf8_X_LV_LVT_V)
#define PL_utf8_X_T		(vTHX->Iutf8_X_T)
#define PL_utf8_X_V		(vTHX->Iutf8_X_V)
#define PL_utf8_X_begin		(vTHX->Iutf8_X_begin)
#define PL_utf8_X_extend	(vTHX->Iutf8_X_extend)
#define PL_utf8_X_non_hangul	(vTHX->Iutf8_X_non_hangul)
#define PL_utf8_X_prepend	(vTHX->Iutf8_X_prepend)
#define PL_utf8_alnum		(vTHX->Iutf8_alnum)
#define PL_utf8_alpha		(vTHX->Iutf8_alpha)
#define PL_utf8_ascii		(vTHX->Iutf8_ascii)
#define PL_utf8_cntrl		(vTHX->Iutf8_cntrl)
#define PL_utf8_digit		(vTHX->Iutf8_digit)
#define PL_utf8_graph		(vTHX->Iutf8_graph)
#define PL_utf8_idcont		(vTHX->Iutf8_idcont)
#define PL_utf8_idstart		(vTHX->Iutf8_idstart)
#define PL_utf8_lower		(vTHX->Iutf8_lower)
#define PL_utf8_mark		(vTHX->Iutf8_mark)
#define PL_utf8_perl_space	(vTHX->Iutf8_perl_space)
#define PL_utf8_perl_word	(vTHX->Iutf8_perl_word)
#define PL_utf8_posix_digit	(vTHX->Iutf8_posix_digit)
#define PL_utf8_print		(vTHX->Iutf8_print)
#define PL_utf8_punct		(vTHX->Iutf8_punct)
#define PL_utf8_space		(vTHX->Iutf8_space)
#define PL_utf8_tofold		(vTHX->Iutf8_tofold)
#define PL_utf8_tolower		(vTHX->Iutf8_tolower)
#define PL_utf8_totitle		(vTHX->Iutf8_totitle)
#define PL_utf8_toupper		(vTHX->Iutf8_toupper)
#define PL_utf8_upper		(vTHX->Iutf8_upper)
#define PL_utf8_xdigit		(vTHX->Iutf8_xdigit)
#define PL_utf8cache		(vTHX->Iutf8cache)
#define PL_utf8locale		(vTHX->Iutf8locale)
#define PL_warnhook		(vTHX->Iwarnhook)
#define PL_watchaddr		(vTHX->Iwatchaddr)
#define PL_watchok		(vTHX->Iwatchok)
#define PL_xmlfp		(vTHX->Ixmlfp)

#else	/* !MULTIPLICITY */

/* case 1 above */

#define PL_IArgv		PL_Argv
#define PL_ICmd			PL_Cmd
#define PL_IDBcv		PL_DBcv
#define PL_IDBgv		PL_DBgv
#define PL_IDBline		PL_DBline
#define PL_IDBsignal		PL_DBsignal
#define PL_IDBsingle		PL_DBsingle
#define PL_IDBsub		PL_DBsub
#define PL_IDBtrace		PL_DBtrace
#define PL_IDir			PL_Dir
#define PL_IEnv			PL_Env
#define PL_ILIO			PL_LIO
#define PL_IMem			PL_Mem
#define PL_IMemParse		PL_MemParse
#define PL_IMemShared		PL_MemShared
#define PL_IOpPtr		PL_OpPtr
#define PL_IOpSlab		PL_OpSlab
#define PL_IOpSpace		PL_OpSpace
#define PL_IProc		PL_Proc
#define PL_ISock		PL_Sock
#define PL_IStdIO		PL_StdIO
#define PL_ISv			PL_Sv
#define PL_IXpv			PL_Xpv
#define PL_Iamagic_generation	PL_amagic_generation
#define PL_Ian			PL_an
#define PL_Iapiversion		PL_apiversion
#define PL_Iargvgv		PL_argvgv
#define PL_Iargvout_stack	PL_argvout_stack
#define PL_Iargvoutgv		PL_argvoutgv
#define PL_Ibasetime		PL_basetime
#define PL_Ibeginav		PL_beginav
#define PL_Ibeginav_save	PL_beginav_save
#define PL_Iblockhooks		PL_blockhooks
#define PL_Ibody_arenas		PL_body_arenas
#define PL_Ibody_roots		PL_body_roots
#define PL_Ibodytarget		PL_bodytarget
#define PL_Ibreakable_sub_gen	PL_breakable_sub_gen
#define PL_Icheckav		PL_checkav
#define PL_Icheckav_save	PL_checkav_save
#define PL_Ichopset		PL_chopset
#define PL_Iclocktick		PL_clocktick
#define PL_Icollation_ix	PL_collation_ix
#define PL_Icollation_name	PL_collation_name
#define PL_Icollation_standard	PL_collation_standard
#define PL_Icollxfrm_base	PL_collxfrm_base
#define PL_Icollxfrm_mult	PL_collxfrm_mult
#define PL_Icolors		PL_colors
#define PL_Icolorset		PL_colorset
#define PL_Icompcv		PL_compcv
#define PL_Icompiling		PL_compiling
#define PL_Icomppad		PL_comppad
#define PL_Icomppad_name	PL_comppad_name
#define PL_Icomppad_name_fill	PL_comppad_name_fill
#define PL_Icomppad_name_floor	PL_comppad_name_floor
#define PL_Icop_seqmax		PL_cop_seqmax
#define PL_Icryptseen		PL_cryptseen
#define PL_Icurcop		PL_curcop
#define PL_Icurcopdb		PL_curcopdb
#define PL_Icurpad		PL_curpad
#define PL_Icurpm		PL_curpm
#define PL_Icurstack		PL_curstack
#define PL_Icurstackinfo	PL_curstackinfo
#define PL_Icurstash		PL_curstash
#define PL_Icurstname		PL_curstname
#define PL_Icustom_op_descs	PL_custom_op_descs
#define PL_Icustom_op_names	PL_custom_op_names
#define PL_Icv_has_eval		PL_cv_has_eval
#define PL_Idbargs		PL_dbargs
#define PL_Idebstash		PL_debstash
#define PL_Idebug		PL_debug
#define PL_Idebug_pad		PL_debug_pad
#define PL_Idef_layerlist	PL_def_layerlist
#define PL_Idefgv		PL_defgv
#define PL_Idefoutgv		PL_defoutgv
#define PL_Idefstash		PL_defstash
#define PL_Idelaymagic		PL_delaymagic
#define PL_Idestroyhook		PL_destroyhook
#define PL_Idiehook		PL_diehook
#define PL_Idirty		PL_dirty
#define PL_Idoextract		PL_doextract
#define PL_Idoswitches		PL_doswitches
#define PL_Idowarn		PL_dowarn
#define PL_Idumper_fd		PL_dumper_fd
#define PL_Idumpindent		PL_dumpindent
#define PL_Ie_script		PL_e_script
#define PL_Iefloatbuf		PL_efloatbuf
#define PL_Iefloatsize		PL_efloatsize
#define PL_Iegid		PL_egid
#define PL_Iencoding		PL_encoding
#define PL_Iendav		PL_endav
#define PL_Ienvgv		PL_envgv
#define PL_Ierrgv		PL_errgv
#define PL_Ierrors		PL_errors
#define PL_Ieuid		PL_euid
#define PL_Ieval_root		PL_eval_root
#define PL_Ieval_start		PL_eval_start
#define PL_Ievalseq		PL_evalseq
#define PL_Iexit_flags		PL_exit_flags
#define PL_Iexitlist		PL_exitlist
#define PL_Iexitlistlen		PL_exitlistlen
#define PL_Ifdpid		PL_fdpid
#define PL_Ifilemode		PL_filemode
#define PL_Ifirstgv		PL_firstgv
#define PL_Iforkprocess		PL_forkprocess
#define PL_Iformfeed		PL_formfeed
#define PL_Iformtarget		PL_formtarget
#define PL_Igeneration		PL_generation
#define PL_Igensym		PL_gensym
#define PL_Igid			PL_gid
#define PL_Iglob_index		PL_glob_index
#define PL_Iglobalstash		PL_globalstash
#define PL_Ihash_seed		PL_hash_seed
#define PL_Ihintgv		PL_hintgv
#define PL_Ihints		PL_hints
#define PL_Ihv_fetch_ent_mh	PL_hv_fetch_ent_mh
#define PL_Iin_clean_all	PL_in_clean_all
#define PL_Iin_clean_objs	PL_in_clean_objs
#define PL_Iin_eval		PL_in_eval
#define PL_Iin_load_module	PL_in_load_module
#define PL_Iincgv		PL_incgv
#define PL_Iinitav		PL_initav
#define PL_Iinplace		PL_inplace
#define PL_Iisarev		PL_isarev
#define PL_Iknown_layers	PL_known_layers
#define PL_Ilast_in_gv		PL_last_in_gv
#define PL_Ilast_swash_hv	PL_last_swash_hv
#define PL_Ilast_swash_key	PL_last_swash_key
#define PL_Ilast_swash_klen	PL_last_swash_klen
#define PL_Ilast_swash_slen	PL_last_swash_slen
#define PL_Ilast_swash_tmps	PL_last_swash_tmps
#define PL_Ilastfd		PL_lastfd
#define PL_Ilastgotoprobe	PL_lastgotoprobe
#define PL_Ilastscream		PL_lastscream
#define PL_Ilaststatval		PL_laststatval
#define PL_Ilaststype		PL_laststype
#define PL_Ilocalizing		PL_localizing
#define PL_Ilocalpatches	PL_localpatches
#define PL_Ilockhook		PL_lockhook
#define PL_Imadskills		PL_madskills
#define PL_Imain_cv		PL_main_cv
#define PL_Imain_root		PL_main_root
#define PL_Imain_start		PL_main_start
#define PL_Imainstack		PL_mainstack
#define PL_Imarkstack		PL_markstack
#define PL_Imarkstack_max	PL_markstack_max
#define PL_Imarkstack_ptr	PL_markstack_ptr
#define PL_Imax_intro_pending	PL_max_intro_pending
#define PL_Imaxo		PL_maxo
#define PL_Imaxscream		PL_maxscream
#define PL_Imaxsysfd		PL_maxsysfd
#define PL_Imemory_debug_header	PL_memory_debug_header
#define PL_Imess_sv		PL_mess_sv
#define PL_Imin_intro_pending	PL_min_intro_pending
#define PL_Iminus_E		PL_minus_E
#define PL_Iminus_F		PL_minus_F
#define PL_Iminus_a		PL_minus_a
#define PL_Iminus_c		PL_minus_c
#define PL_Iminus_l		PL_minus_l
#define PL_Iminus_n		PL_minus_n
#define PL_Iminus_p		PL_minus_p
#define PL_Imodcount		PL_modcount
#define PL_Imodglobal		PL_modglobal
#define PL_Imy_cxt_keys		PL_my_cxt_keys
#define PL_Imy_cxt_list		PL_my_cxt_list
#define PL_Imy_cxt_size		PL_my_cxt_size
#define PL_Ina			PL_na
#define PL_Inomemok		PL_nomemok
#define PL_Inumeric_local	PL_numeric_local
#define PL_Inumeric_name	PL_numeric_name
#define PL_Inumeric_radix_sv	PL_numeric_radix_sv
#define PL_Inumeric_standard	PL_numeric_standard
#define PL_Iofsgv		PL_ofsgv
#define PL_Ioldname		PL_oldname
#define PL_Iop			PL_op
#define PL_Iop_mask		PL_op_mask
#define PL_Iopfreehook		PL_opfreehook
#define PL_Iopsave		PL_opsave
#define PL_Iorigalen		PL_origalen
#define PL_Iorigargc		PL_origargc
#define PL_Iorigargv		PL_origargv
#define PL_Iorigenviron		PL_origenviron
#define PL_Iorigfilename	PL_origfilename
#define PL_Iors_sv		PL_ors_sv
#define PL_Iosname		PL_osname
#define PL_Ipad_reset_pending	PL_pad_reset_pending
#define PL_Ipadix		PL_padix
#define PL_Ipadix_floor		PL_padix_floor
#define PL_Iparser		PL_parser
#define PL_Ipatchlevel		PL_patchlevel
#define PL_Ipeepp		PL_peepp
#define PL_Iperl_destruct_level	PL_perl_destruct_level
#define PL_Iperldb		PL_perldb
#define PL_Iperlio		PL_perlio
#define PL_Ipidstatus		PL_pidstatus
#define PL_Ippid		PL_ppid
#define PL_Ipreambleav		PL_preambleav
#define PL_Iprofiledata		PL_profiledata
#define PL_Ipsig_name		PL_psig_name
#define PL_Ipsig_pend		PL_psig_pend
#define PL_Ipsig_ptr		PL_psig_ptr
#define PL_Iptr_table		PL_ptr_table
#define PL_Ireentrant_buffer	PL_reentrant_buffer
#define PL_Ireentrant_retint	PL_reentrant_retint
#define PL_Ireg_state		PL_reg_state
#define PL_Iregdummy		PL_regdummy
#define PL_Iregex_pad		PL_regex_pad
#define PL_Iregex_padav		PL_regex_padav
#define PL_Ireginterp_cnt	PL_reginterp_cnt
#define PL_Iregistered_mros	PL_registered_mros
#define PL_Iregmatch_slab	PL_regmatch_slab
#define PL_Iregmatch_state	PL_regmatch_state
#define PL_Irehash_seed		PL_rehash_seed
#define PL_Irehash_seed_set	PL_rehash_seed_set
#define PL_Ireplgv		PL_replgv
#define PL_Irestartjmpenv	PL_restartjmpenv
#define PL_Irestartop		PL_restartop
#define PL_Irpeepp		PL_rpeepp
#define PL_Irs			PL_rs
#define PL_Irunops		PL_runops
#define PL_Isavebegin		PL_savebegin
#define PL_Isavestack		PL_savestack
#define PL_Isavestack_ix	PL_savestack_ix
#define PL_Isavestack_max	PL_savestack_max
#define PL_Isawampersand	PL_sawampersand
#define PL_Iscopestack		PL_scopestack
#define PL_Iscopestack_ix	PL_scopestack_ix
#define PL_Iscopestack_max	PL_scopestack_max
#define PL_Iscopestack_name	PL_scopestack_name
#define PL_Iscreamfirst		PL_screamfirst
#define PL_Iscreamnext		PL_screamnext
#define PL_Isecondgv		PL_secondgv
#define PL_Isharehook		PL_sharehook
#define PL_Isig_pending		PL_sig_pending
#define PL_Isighandlerp		PL_sighandlerp
#define PL_Isignalhook		PL_signalhook
#define PL_Isignals		PL_signals
#define PL_Islab_count		PL_slab_count
#define PL_Islabs		PL_slabs
#define PL_Isort_RealCmp	PL_sort_RealCmp
#define PL_Isortcop		PL_sortcop
#define PL_Isortstash		PL_sortstash
#define PL_Isplitstr		PL_splitstr
#define PL_Isrand_called	PL_srand_called
#define PL_Istack_base		PL_stack_base
#define PL_Istack_max		PL_stack_max
#define PL_Istack_sp		PL_stack_sp
#define PL_Istart_env		PL_start_env
#define PL_Istashcache		PL_stashcache
#define PL_Istatbuf		PL_statbuf
#define PL_Istatcache		PL_statcache
#define PL_Istatgv		PL_statgv
#define PL_Istatname		PL_statname
#define PL_Istatusvalue		PL_statusvalue
#define PL_Istatusvalue_posix	PL_statusvalue_posix
#define PL_Istatusvalue_vms	PL_statusvalue_vms
#define PL_Istderrgv		PL_stderrgv
#define PL_Istdingv		PL_stdingv
#define PL_Istrtab		PL_strtab
#define PL_Isub_generation	PL_sub_generation
#define PL_Isubline		PL_subline
#define PL_Isubname		PL_subname
#define PL_Isv_arenaroot	PL_sv_arenaroot
#define PL_Isv_count		PL_sv_count
#define PL_Isv_no		PL_sv_no
#define PL_Isv_objcount		PL_sv_objcount
#define PL_Isv_root		PL_sv_root
#define PL_Isv_serial		PL_sv_serial
#define PL_Isv_undef		PL_sv_undef
#define PL_Isv_yes		PL_sv_yes
#define PL_Isys_intern		PL_sys_intern
#define PL_Itaint_warn		PL_taint_warn
#define PL_Itainted		PL_tainted
#define PL_Itainting		PL_tainting
#define PL_Ithreadhook		PL_threadhook
#define PL_Itimesbuf		PL_timesbuf
#define PL_Itmps_floor		PL_tmps_floor
#define PL_Itmps_ix		PL_tmps_ix
#define PL_Itmps_max		PL_tmps_max
#define PL_Itmps_stack		PL_tmps_stack
#define PL_Itop_env		PL_top_env
#define PL_Itoptarget		PL_toptarget
#define PL_Iuid			PL_uid
#define PL_Iunicode		PL_unicode
#define PL_Iunitcheckav		PL_unitcheckav
#define PL_Iunitcheckav_save	PL_unitcheckav_save
#define PL_Iunlockhook		PL_unlockhook
#define PL_Iunsafe		PL_unsafe
#define PL_Iutf8_X_L		PL_utf8_X_L
#define PL_Iutf8_X_LV		PL_utf8_X_LV
#define PL_Iutf8_X_LVT		PL_utf8_X_LVT
#define PL_Iutf8_X_LV_LVT_V	PL_utf8_X_LV_LVT_V
#define PL_Iutf8_X_T		PL_utf8_X_T
#define PL_Iutf8_X_V		PL_utf8_X_V
#define PL_Iutf8_X_begin	PL_utf8_X_begin
#define PL_Iutf8_X_extend	PL_utf8_X_extend
#define PL_Iutf8_X_non_hangul	PL_utf8_X_non_hangul
#define PL_Iutf8_X_prepend	PL_utf8_X_prepend
#define PL_Iutf8_alnum		PL_utf8_alnum
#define PL_Iutf8_alpha		PL_utf8_alpha
#define PL_Iutf8_ascii		PL_utf8_ascii
#define PL_Iutf8_cntrl		PL_utf8_cntrl
#define PL_Iutf8_digit		PL_utf8_digit
#define PL_Iutf8_graph		PL_utf8_graph
#define PL_Iutf8_idcont		PL_utf8_idcont
#define PL_Iutf8_idstart	PL_utf8_idstart
#define PL_Iutf8_lower		PL_utf8_lower
#define PL_Iutf8_mark		PL_utf8_mark
#define PL_Iutf8_perl_space	PL_utf8_perl_space
#define PL_Iutf8_perl_word	PL_utf8_perl_word
#define PL_Iutf8_posix_digit	PL_utf8_posix_digit
#define PL_Iutf8_print		PL_utf8_print
#define PL_Iutf8_punct		PL_utf8_punct
#define PL_Iutf8_space		PL_utf8_space
#define PL_Iutf8_tofold		PL_utf8_tofold
#define PL_Iutf8_tolower	PL_utf8_tolower
#define PL_Iutf8_totitle	PL_utf8_totitle
#define PL_Iutf8_toupper	PL_utf8_toupper
#define PL_Iutf8_upper		PL_utf8_upper
#define PL_Iutf8_xdigit		PL_utf8_xdigit
#define PL_Iutf8cache		PL_utf8cache
#define PL_Iutf8locale		PL_utf8locale
#define PL_Iwarnhook		PL_warnhook
#define PL_Iwatchaddr		PL_watchaddr
#define PL_Iwatchok		PL_watchok
#define PL_Ixmlfp		PL_xmlfp


#endif	/* MULTIPLICITY */

#if defined(PERL_GLOBAL_STRUCT)

#define PL_No			(my_vars->GNo)
#define PL_GNo			(my_vars->GNo)
#define PL_Yes			(my_vars->GYes)
#define PL_GYes			(my_vars->GYes)
#define PL_appctx		(my_vars->Gappctx)
#define PL_Gappctx		(my_vars->Gappctx)
#define PL_charclass		(my_vars->Gcharclass)
#define PL_Gcharclass		(my_vars->Gcharclass)
#define PL_check		(my_vars->Gcheck)
#define PL_Gcheck		(my_vars->Gcheck)
#define PL_csighandlerp		(my_vars->Gcsighandlerp)
#define PL_Gcsighandlerp	(my_vars->Gcsighandlerp)
#define PL_curinterp		(my_vars->Gcurinterp)
#define PL_Gcurinterp		(my_vars->Gcurinterp)
#define PL_do_undump		(my_vars->Gdo_undump)
#define PL_Gdo_undump		(my_vars->Gdo_undump)
#define PL_dollarzero_mutex	(my_vars->Gdollarzero_mutex)
#define PL_Gdollarzero_mutex	(my_vars->Gdollarzero_mutex)
#define PL_fold_locale		(my_vars->Gfold_locale)
#define PL_Gfold_locale		(my_vars->Gfold_locale)
#define PL_global_struct_size	(my_vars->Gglobal_struct_size)
#define PL_Gglobal_struct_size	(my_vars->Gglobal_struct_size)
#define PL_hexdigit		(my_vars->Ghexdigit)
#define PL_Ghexdigit		(my_vars->Ghexdigit)
#define PL_hints_mutex		(my_vars->Ghints_mutex)
#define PL_Ghints_mutex		(my_vars->Ghints_mutex)
#define PL_interp_size		(my_vars->Ginterp_size)
#define PL_Ginterp_size		(my_vars->Ginterp_size)
#define PL_interp_size_5_10_0	(my_vars->Ginterp_size_5_10_0)
#define PL_Ginterp_size_5_10_0	(my_vars->Ginterp_size_5_10_0)
#define PL_keyword_plugin	(my_vars->Gkeyword_plugin)
#define PL_Gkeyword_plugin	(my_vars->Gkeyword_plugin)
#define PL_malloc_mutex		(my_vars->Gmalloc_mutex)
#define PL_Gmalloc_mutex	(my_vars->Gmalloc_mutex)
#define PL_mmap_page_size	(my_vars->Gmmap_page_size)
#define PL_Gmmap_page_size	(my_vars->Gmmap_page_size)
#define PL_my_ctx_mutex		(my_vars->Gmy_ctx_mutex)
#define PL_Gmy_ctx_mutex	(my_vars->Gmy_ctx_mutex)
#define PL_my_cxt_index		(my_vars->Gmy_cxt_index)
#define PL_Gmy_cxt_index	(my_vars->Gmy_cxt_index)
#define PL_op_mutex		(my_vars->Gop_mutex)
#define PL_Gop_mutex		(my_vars->Gop_mutex)
#define PL_op_seq		(my_vars->Gop_seq)
#define PL_Gop_seq		(my_vars->Gop_seq)
#define PL_op_sequence		(my_vars->Gop_sequence)
#define PL_Gop_sequence		(my_vars->Gop_sequence)
#define PL_patleave		(my_vars->Gpatleave)
#define PL_Gpatleave		(my_vars->Gpatleave)
#define PL_perlio_debug_fd	(my_vars->Gperlio_debug_fd)
#define PL_Gperlio_debug_fd	(my_vars->Gperlio_debug_fd)
#define PL_perlio_fd_refcnt	(my_vars->Gperlio_fd_refcnt)
#define PL_Gperlio_fd_refcnt	(my_vars->Gperlio_fd_refcnt)
#define PL_perlio_fd_refcnt_size	(my_vars->Gperlio_fd_refcnt_size)
#define PL_Gperlio_fd_refcnt_size	(my_vars->Gperlio_fd_refcnt_size)
#define PL_perlio_mutex		(my_vars->Gperlio_mutex)
#define PL_Gperlio_mutex	(my_vars->Gperlio_mutex)
#define PL_ppaddr		(my_vars->Gppaddr)
#define PL_Gppaddr		(my_vars->Gppaddr)
#define PL_revision		(my_vars->Grevision)
#define PL_Grevision		(my_vars->Grevision)
#define PL_runops_dbg		(my_vars->Grunops_dbg)
#define PL_Grunops_dbg		(my_vars->Grunops_dbg)
#define PL_runops_std		(my_vars->Grunops_std)
#define PL_Grunops_std		(my_vars->Grunops_std)
#define PL_sh_path		(my_vars->Gsh_path)
#define PL_Gsh_path		(my_vars->Gsh_path)
#define PL_sig_defaulting	(my_vars->Gsig_defaulting)
#define PL_Gsig_defaulting	(my_vars->Gsig_defaulting)
#define PL_sig_handlers_initted	(my_vars->Gsig_handlers_initted)
#define PL_Gsig_handlers_initted	(my_vars->Gsig_handlers_initted)
#define PL_sig_ignoring		(my_vars->Gsig_ignoring)
#define PL_Gsig_ignoring	(my_vars->Gsig_ignoring)
#define PL_sig_sv		(my_vars->Gsig_sv)
#define PL_Gsig_sv		(my_vars->Gsig_sv)
#define PL_sig_trapped		(my_vars->Gsig_trapped)
#define PL_Gsig_trapped		(my_vars->Gsig_trapped)
#define PL_sigfpe_saved		(my_vars->Gsigfpe_saved)
#define PL_Gsigfpe_saved	(my_vars->Gsigfpe_saved)
#define PL_subversion		(my_vars->Gsubversion)
#define PL_Gsubversion		(my_vars->Gsubversion)
#define PL_sv_placeholder	(my_vars->Gsv_placeholder)
#define PL_Gsv_placeholder	(my_vars->Gsv_placeholder)
#define PL_thr_key		(my_vars->Gthr_key)
#define PL_Gthr_key		(my_vars->Gthr_key)
#define PL_timesbase		(my_vars->Gtimesbase)
#define PL_Gtimesbase		(my_vars->Gtimesbase)
#define PL_use_safe_putenv	(my_vars->Guse_safe_putenv)
#define PL_Guse_safe_putenv	(my_vars->Guse_safe_putenv)
#define PL_version		(my_vars->Gversion)
#define PL_Gversion		(my_vars->Gversion)
#define PL_veto_cleanup		(my_vars->Gveto_cleanup)
#define PL_Gveto_cleanup	(my_vars->Gveto_cleanup)
#define PL_watch_pvx		(my_vars->Gwatch_pvx)
#define PL_Gwatch_pvx		(my_vars->Gwatch_pvx)

#else /* !PERL_GLOBAL_STRUCT */

#define PL_GNo			PL_No
#define PL_GYes			PL_Yes
#define PL_Gappctx		PL_appctx
#define PL_Gcharclass		PL_charclass
#define PL_Gcheck		PL_check
#define PL_Gcsighandlerp	PL_csighandlerp
#define PL_Gcurinterp		PL_curinterp
#define PL_Gdo_undump		PL_do_undump
#define PL_Gdollarzero_mutex	PL_dollarzero_mutex
#define PL_Gfold_locale		PL_fold_locale
#define PL_Gglobal_struct_size	PL_global_struct_size
#define PL_Ghexdigit		PL_hexdigit
#define PL_Ghints_mutex		PL_hints_mutex
#define PL_Ginterp_size		PL_interp_size
#define PL_Ginterp_size_5_10_0	PL_interp_size_5_10_0
#define PL_Gkeyword_plugin	PL_keyword_plugin
#define PL_Gmalloc_mutex	PL_malloc_mutex
#define PL_Gmmap_page_size	PL_mmap_page_size
#define PL_Gmy_ctx_mutex	PL_my_ctx_mutex
#define PL_Gmy_cxt_index	PL_my_cxt_index
#define PL_Gop_mutex		PL_op_mutex
#define PL_Gop_seq		PL_op_seq
#define PL_Gop_sequence		PL_op_sequence
#define PL_Gpatleave		PL_patleave
#define PL_Gperlio_debug_fd	PL_perlio_debug_fd
#define PL_Gperlio_fd_refcnt	PL_perlio_fd_refcnt
#define PL_Gperlio_fd_refcnt_size	PL_perlio_fd_refcnt_size
#define PL_Gperlio_mutex	PL_perlio_mutex
#define PL_Gppaddr		PL_ppaddr
#define PL_Grevision		PL_revision
#define PL_Grunops_dbg		PL_runops_dbg
#define PL_Grunops_std		PL_runops_std
#define PL_Gsh_path		PL_sh_path
#define PL_Gsig_defaulting	PL_sig_defaulting
#define PL_Gsig_handlers_initted	PL_sig_handlers_initted
#define PL_Gsig_ignoring	PL_sig_ignoring
#define PL_Gsig_sv		PL_sig_sv
#define PL_Gsig_trapped		PL_sig_trapped
#define PL_Gsigfpe_saved	PL_sigfpe_saved
#define PL_Gsubversion		PL_subversion
#define PL_Gsv_placeholder	PL_sv_placeholder
#define PL_Gthr_key		PL_thr_key
#define PL_Gtimesbase		PL_timesbase
#define PL_Guse_safe_putenv	PL_use_safe_putenv
#define PL_Gversion		PL_version
#define PL_Gveto_cleanup	PL_veto_cleanup
#define PL_Gwatch_pvx		PL_watch_pvx

#endif /* PERL_GLOBAL_STRUCT */

/* ex: set ro: */
