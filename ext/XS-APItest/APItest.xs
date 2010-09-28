#define PERL_IN_XS_APITEST
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

typedef SV *SVREF;
typedef PTR_TBL_t *XS__APItest__PtrTable;

/* for my_cxt tests */

#define MY_CXT_KEY "XS::APItest::_guts" XS_VERSION

typedef struct {
    int i;
    SV *sv;
    GV *cscgv;
    AV *cscav;
    AV *bhkav;
    bool bhk_record;
    peep_t orig_peep;
    peep_t orig_rpeep;
    int peep_recording;
    AV *peep_recorder;
    AV *rpeep_recorder;
} my_cxt_t;

START_MY_CXT

/* indirect functions to test the [pa]MY_CXT macros */

int
my_cxt_getint_p(pMY_CXT)
{
    return MY_CXT.i;
}

void
my_cxt_setint_p(pMY_CXT_ int i)
{
    MY_CXT.i = i;
}

SV*
my_cxt_getsv_interp_context(void)
{
    dTHX;
    dMY_CXT_INTERP(my_perl);
    return MY_CXT.sv;
}

SV*
my_cxt_getsv_interp(void)
{
    dMY_CXT;
    return MY_CXT.sv;
}

void
my_cxt_setsv_p(SV* sv _pMY_CXT)
{
    MY_CXT.sv = sv;
}


/* from exception.c */
int apitest_exception(int);

/* from core_or_not.inc */
bool sv_setsv_cow_hashkey_core(void);
bool sv_setsv_cow_hashkey_notcore(void);

/* A routine to test hv_delayfree_ent
   (which itself is tested by testing on hv_free_ent  */

typedef void (freeent_function)(pTHX_ HV *, register HE *);

void
test_freeent(freeent_function *f) {
    dTHX;
    dSP;
    HV *test_hash = newHV();
    HE *victim;
    SV *test_scalar;
    U32 results[4];
    int i;

#ifdef PURIFY
    victim = (HE*)safemalloc(sizeof(HE));
#else
    /* Storing then deleting something should ensure that a hash entry is
       available.  */
    hv_store(test_hash, "", 0, &PL_sv_yes, 0);
    hv_delete(test_hash, "", 0, 0);

    /* We need to "inline" new_he here as it's static, and the functions we
       test expect to be able to call del_HE on the HE  */
    if (!PL_body_roots[HE_SVSLOT])
	croak("PL_he_root is 0");
    victim = (HE*) PL_body_roots[HE_SVSLOT];
    PL_body_roots[HE_SVSLOT] = HeNEXT(victim);
#endif

    victim->hent_hek = Perl_share_hek(aTHX_ "", 0, 0);

    test_scalar = newSV(0);
    SvREFCNT_inc(test_scalar);
    HeVAL(victim) = test_scalar;

    /* Need this little game else we free the temps on the return stack.  */
    results[0] = SvREFCNT(test_scalar);
    SAVETMPS;
    results[1] = SvREFCNT(test_scalar);
    f(aTHX_ test_hash, victim);
    results[2] = SvREFCNT(test_scalar);
    FREETMPS;
    results[3] = SvREFCNT(test_scalar);

    i = 0;
    do {
	mPUSHu(results[i]);
    } while (++i < sizeof(results)/sizeof(results[0]));

    /* Goodbye to our extra reference.  */
    SvREFCNT_dec(test_scalar);
}


static I32
bitflip_key(pTHX_ IV action, SV *field) {
    MAGIC *mg = mg_find(field, PERL_MAGIC_uvar);
    SV *keysv;
    if (mg && (keysv = mg->mg_obj)) {
	STRLEN len;
	const char *p = SvPV(keysv, len);

	if (len) {
	    SV *newkey = newSV(len);
	    char *new_p = SvPVX(newkey);

	    if (SvUTF8(keysv)) {
		const char *const end = p + len;
		while (p < end) {
		    STRLEN len;
		    UV chr = utf8_to_uvuni((U8 *)p, &len);
		    new_p = (char *)uvuni_to_utf8((U8 *)new_p, chr ^ 32);
		    p += len;
		}
		SvUTF8_on(newkey);
	    } else {
		while (len--)
		    *new_p++ = *p++ ^ 32;
	    }
	    *new_p = '\0';
	    SvCUR_set(newkey, SvCUR(keysv));
	    SvPOK_on(newkey);

	    mg->mg_obj = newkey;
	}
    }
    return 0;
}

static I32
rot13_key(pTHX_ IV action, SV *field) {
    MAGIC *mg = mg_find(field, PERL_MAGIC_uvar);
    SV *keysv;
    if (mg && (keysv = mg->mg_obj)) {
	STRLEN len;
	const char *p = SvPV(keysv, len);

	if (len) {
	    SV *newkey = newSV(len);
	    char *new_p = SvPVX(newkey);

	    /* There's a deliberate fencepost error here to loop len + 1 times
	       to copy the trailing \0  */
	    do {
		char new_c = *p++;
		/* Try doing this cleanly and clearly in EBCDIC another way: */
		switch (new_c) {
		case 'A': new_c = 'N'; break;
		case 'B': new_c = 'O'; break;
		case 'C': new_c = 'P'; break;
		case 'D': new_c = 'Q'; break;
		case 'E': new_c = 'R'; break;
		case 'F': new_c = 'S'; break;
		case 'G': new_c = 'T'; break;
		case 'H': new_c = 'U'; break;
		case 'I': new_c = 'V'; break;
		case 'J': new_c = 'W'; break;
		case 'K': new_c = 'X'; break;
		case 'L': new_c = 'Y'; break;
		case 'M': new_c = 'Z'; break;
		case 'N': new_c = 'A'; break;
		case 'O': new_c = 'B'; break;
		case 'P': new_c = 'C'; break;
		case 'Q': new_c = 'D'; break;
		case 'R': new_c = 'E'; break;
		case 'S': new_c = 'F'; break;
		case 'T': new_c = 'G'; break;
		case 'U': new_c = 'H'; break;
		case 'V': new_c = 'I'; break;
		case 'W': new_c = 'J'; break;
		case 'X': new_c = 'K'; break;
		case 'Y': new_c = 'L'; break;
		case 'Z': new_c = 'M'; break;
		case 'a': new_c = 'n'; break;
		case 'b': new_c = 'o'; break;
		case 'c': new_c = 'p'; break;
		case 'd': new_c = 'q'; break;
		case 'e': new_c = 'r'; break;
		case 'f': new_c = 's'; break;
		case 'g': new_c = 't'; break;
		case 'h': new_c = 'u'; break;
		case 'i': new_c = 'v'; break;
		case 'j': new_c = 'w'; break;
		case 'k': new_c = 'x'; break;
		case 'l': new_c = 'y'; break;
		case 'm': new_c = 'z'; break;
		case 'n': new_c = 'a'; break;
		case 'o': new_c = 'b'; break;
		case 'p': new_c = 'c'; break;
		case 'q': new_c = 'd'; break;
		case 'r': new_c = 'e'; break;
		case 's': new_c = 'f'; break;
		case 't': new_c = 'g'; break;
		case 'u': new_c = 'h'; break;
		case 'v': new_c = 'i'; break;
		case 'w': new_c = 'j'; break;
		case 'x': new_c = 'k'; break;
		case 'y': new_c = 'l'; break;
		case 'z': new_c = 'm'; break;
		}
		*new_p++ = new_c;
	    } while (len--);
	    SvCUR_set(newkey, SvCUR(keysv));
	    SvPOK_on(newkey);
	    if (SvUTF8(keysv))
		SvUTF8_on(newkey);

	    mg->mg_obj = newkey;
	}
    }
    return 0;
}

STATIC I32
rmagical_a_dummy(pTHX_ IV idx, SV *sv) {
    return 0;
}

STATIC MGVTBL rmagical_b = { 0 };

STATIC void
blockhook_csc_start(pTHX_ int full)
{
    dMY_CXT;
    AV *const cur = GvAV(MY_CXT.cscgv);

    SAVEGENERICSV(GvAV(MY_CXT.cscgv));

    if (cur) {
        I32 i;
        AV *const new_av = newAV();

        for (i = 0; i <= av_len(cur); i++) {
            av_store(new_av, i, newSVsv(*av_fetch(cur, i, 0)));
        }

        GvAV(MY_CXT.cscgv) = new_av;
    }
}

STATIC void
blockhook_csc_pre_end(pTHX_ OP **o)
{
    dMY_CXT;

    /* if we hit the end of a scope we missed the start of, we need to
     * unconditionally clear @CSC */
    if (GvAV(MY_CXT.cscgv) == MY_CXT.cscav && MY_CXT.cscav) {
        av_clear(MY_CXT.cscav);
    }

}

STATIC void
blockhook_test_start(pTHX_ int full)
{
    dMY_CXT;
    AV *av;
    
    if (MY_CXT.bhk_record) {
        av = newAV();
        av_push(av, newSVpvs("start"));
        av_push(av, newSViv(full));
        av_push(MY_CXT.bhkav, newRV_noinc(MUTABLE_SV(av)));
    }
}

STATIC void
blockhook_test_pre_end(pTHX_ OP **o)
{
    dMY_CXT;

    if (MY_CXT.bhk_record)
        av_push(MY_CXT.bhkav, newSVpvs("pre_end"));
}

STATIC void
blockhook_test_post_end(pTHX_ OP **o)
{
    dMY_CXT;

    if (MY_CXT.bhk_record)
        av_push(MY_CXT.bhkav, newSVpvs("post_end"));
}

STATIC void
blockhook_test_eval(pTHX_ OP *const o)
{
    dMY_CXT;
    AV *av;

    if (MY_CXT.bhk_record) {
        av = newAV();
        av_push(av, newSVpvs("eval"));
        av_push(av, newSVpv(OP_NAME(o), 0));
        av_push(MY_CXT.bhkav, newRV_noinc(MUTABLE_SV(av)));
    }
}

STATIC BHK bhk_csc, bhk_test;

STATIC void
my_peep (pTHX_ OP *o)
{
    dMY_CXT;

    if (!o)
	return;

    MY_CXT.orig_peep(aTHX_ o);

    if (!MY_CXT.peep_recording)
	return;

    for (; o; o = o->op_next) {
	if (o->op_type == OP_CONST && cSVOPx_sv(o) && SvPOK(cSVOPx_sv(o))) {
	    av_push(MY_CXT.peep_recorder, newSVsv(cSVOPx_sv(o)));
	}
    }
}

STATIC void
my_rpeep (pTHX_ OP *o)
{
    dMY_CXT;

    if (!o)
	return;

    MY_CXT.orig_rpeep(aTHX_ o);

    if (!MY_CXT.peep_recording)
	return;

    for (; o; o = o->op_next) {
	if (o->op_type == OP_CONST && cSVOPx_sv(o) && SvPOK(cSVOPx_sv(o))) {
	    av_push(MY_CXT.rpeep_recorder, newSVsv(cSVOPx_sv(o)));
	}
    }
}

/** RPN keyword parser **/

#define sv_is_glob(sv) (SvTYPE(sv) == SVt_PVGV)
#define sv_is_regexp(sv) (SvTYPE(sv) == SVt_REGEXP)
#define sv_is_string(sv) \
    (!sv_is_glob(sv) && !sv_is_regexp(sv) && \
     (SvFLAGS(sv) & (SVf_IOK|SVf_NOK|SVf_POK|SVp_IOK|SVp_NOK|SVp_POK)))

static SV *hintkey_rpn_sv, *hintkey_calcrpn_sv, *hintkey_stufftest_sv;
static SV *hintkey_swaptwostmts_sv;
static int (*next_keyword_plugin)(pTHX_ char *, STRLEN, OP **);

/* low-level parser helpers */

#define PL_bufptr (PL_parser->bufptr)
#define PL_bufend (PL_parser->bufend)

/* RPN parser */

#define parse_var() THX_parse_var(aTHX)
static OP *THX_parse_var(pTHX)
{
    char *s = PL_bufptr;
    char *start = s;
    PADOFFSET varpos;
    OP *padop;
    if(*s != '$') croak("RPN syntax error");
    while(1) {
	char c = *++s;
	if(!isALNUM(c)) break;
    }
    if(s-start < 2) croak("RPN syntax error");
    lex_read_to(s);
    {
	/* because pad_findmy() doesn't really use length yet */
	SV *namesv = sv_2mortal(newSVpvn(start, s-start));
	varpos = pad_findmy(SvPVX(namesv), s-start, 0);
    }
    if(varpos == NOT_IN_PAD || PAD_COMPNAME_FLAGS_isOUR(varpos))
	croak("RPN only supports \"my\" variables");
    padop = newOP(OP_PADSV, 0);
    padop->op_targ = varpos;
    return padop;
}

#define push_rpn_item(o) \
    (tmpop = (o), tmpop->op_sibling = stack, stack = tmpop)
#define pop_rpn_item() \
    (!stack ? (croak("RPN stack underflow"), (OP*)NULL) : \
     (tmpop = stack, stack = stack->op_sibling, \
      tmpop->op_sibling = NULL, tmpop))

#define parse_rpn_expr() THX_parse_rpn_expr(aTHX)
static OP *THX_parse_rpn_expr(pTHX)
{
    OP *stack = NULL, *tmpop;
    while(1) {
	I32 c;
	lex_read_space(0);
	c = lex_peek_unichar(0);
	switch(c) {
	    case /*(*/')': case /*{*/'}': {
		OP *result = pop_rpn_item();
		if(stack) croak("RPN expression must return a single value");
		return result;
	    } break;
	    case '0': case '1': case '2': case '3': case '4':
	    case '5': case '6': case '7': case '8': case '9': {
		UV val = 0;
		do {
		    lex_read_unichar(0);
		    val = 10*val + (c - '0');
		    c = lex_peek_unichar(0);
		} while(c >= '0' && c <= '9');
		push_rpn_item(newSVOP(OP_CONST, 0, newSVuv(val)));
	    } break;
	    case '$': {
		push_rpn_item(parse_var());
	    } break;
	    case '+': {
		OP *b = pop_rpn_item();
		OP *a = pop_rpn_item();
		lex_read_unichar(0);
		push_rpn_item(newBINOP(OP_I_ADD, 0, a, b));
	    } break;
	    case '-': {
		OP *b = pop_rpn_item();
		OP *a = pop_rpn_item();
		lex_read_unichar(0);
		push_rpn_item(newBINOP(OP_I_SUBTRACT, 0, a, b));
	    } break;
	    case '*': {
		OP *b = pop_rpn_item();
		OP *a = pop_rpn_item();
		lex_read_unichar(0);
		push_rpn_item(newBINOP(OP_I_MULTIPLY, 0, a, b));
	    } break;
	    case '/': {
		OP *b = pop_rpn_item();
		OP *a = pop_rpn_item();
		lex_read_unichar(0);
		push_rpn_item(newBINOP(OP_I_DIVIDE, 0, a, b));
	    } break;
	    case '%': {
		OP *b = pop_rpn_item();
		OP *a = pop_rpn_item();
		lex_read_unichar(0);
		push_rpn_item(newBINOP(OP_I_MODULO, 0, a, b));
	    } break;
	    default: {
		croak("RPN syntax error");
	    } break;
	}
    }
}

#define parse_keyword_rpn() THX_parse_keyword_rpn(aTHX)
static OP *THX_parse_keyword_rpn(pTHX)
{
    OP *op;
    lex_read_space(0);
    if(lex_peek_unichar(0) != '('/*)*/)
	croak("RPN expression must be parenthesised");
    lex_read_unichar(0);
    op = parse_rpn_expr();
    if(lex_peek_unichar(0) != /*(*/')')
	croak("RPN expression must be parenthesised");
    lex_read_unichar(0);
    return op;
}

#define parse_keyword_calcrpn() THX_parse_keyword_calcrpn(aTHX)
static OP *THX_parse_keyword_calcrpn(pTHX)
{
    OP *varop, *exprop;
    lex_read_space(0);
    varop = parse_var();
    lex_read_space(0);
    if(lex_peek_unichar(0) != '{'/*}*/)
	croak("RPN expression must be braced");
    lex_read_unichar(0);
    exprop = parse_rpn_expr();
    if(lex_peek_unichar(0) != /*{*/'}')
	croak("RPN expression must be braced");
    lex_read_unichar(0);
    return newASSIGNOP(OPf_STACKED, varop, 0, exprop);
}

#define parse_keyword_stufftest() THX_parse_keyword_stufftest(aTHX)
static OP *THX_parse_keyword_stufftest(pTHX)
{
    I32 c;
    bool do_stuff;
    lex_read_space(0);
    do_stuff = lex_peek_unichar(0) == '+';
    if(do_stuff) {
	lex_read_unichar(0);
	lex_read_space(0);
    }
    c = lex_peek_unichar(0);
    if(c == ';') {
	lex_read_unichar(0);
    } else if(c != /*{*/'}') {
	croak("syntax error");
    }
    if(do_stuff) lex_stuff_pvs(" ", 0);
    return newOP(OP_NULL, 0);
}

#define parse_keyword_swaptwostmts() THX_parse_keyword_swaptwostmts(aTHX)
static OP *THX_parse_keyword_swaptwostmts(pTHX)
{
    OP *a, *b;
    a = parse_fullstmt(0);
    b = parse_fullstmt(0);
    if(a && b)
	PL_hints |= HINT_BLOCK_SCOPE;
    /* should use append_list(), but that's not part of the public API */
    return !a ? b : !b ? a : newLISTOP(OP_LINESEQ, 0, b, a);
}

/* plugin glue */

#define keyword_active(hintkey_sv) THX_keyword_active(aTHX_ hintkey_sv)
static int THX_keyword_active(pTHX_ SV *hintkey_sv)
{
    HE *he;
    if(!GvHV(PL_hintgv)) return 0;
    he = hv_fetch_ent(GvHV(PL_hintgv), hintkey_sv, 0,
		SvSHARED_HASH(hintkey_sv));
    return he && SvTRUE(HeVAL(he));
}

static int my_keyword_plugin(pTHX_
    char *keyword_ptr, STRLEN keyword_len, OP **op_ptr)
{
    if(keyword_len == 3 && strnEQ(keyword_ptr, "rpn", 3) &&
		    keyword_active(hintkey_rpn_sv)) {
	*op_ptr = parse_keyword_rpn();
	return KEYWORD_PLUGIN_EXPR;
    } else if(keyword_len == 7 && strnEQ(keyword_ptr, "calcrpn", 7) &&
		    keyword_active(hintkey_calcrpn_sv)) {
	*op_ptr = parse_keyword_calcrpn();
	return KEYWORD_PLUGIN_STMT;
    } else if(keyword_len == 9 && strnEQ(keyword_ptr, "stufftest", 9) &&
		    keyword_active(hintkey_stufftest_sv)) {
	*op_ptr = parse_keyword_stufftest();
	return KEYWORD_PLUGIN_STMT;
    } else if(keyword_len == 12 &&
		    strnEQ(keyword_ptr, "swaptwostmts", 12) &&
		    keyword_active(hintkey_swaptwostmts_sv)) {
	*op_ptr = parse_keyword_swaptwostmts();
	return KEYWORD_PLUGIN_STMT;
    } else {
	return next_keyword_plugin(aTHX_ keyword_ptr, keyword_len, op_ptr);
    }
}

#include "const-c.inc"

MODULE = XS::APItest		PACKAGE = XS::APItest

INCLUDE: const-xs.inc

INCLUDE: numeric.xs

MODULE = XS::APItest:Hash		PACKAGE = XS::APItest::Hash

void
rot13_hash(hash)
	HV *hash
	CODE:
	{
	    struct ufuncs uf;
	    uf.uf_val = rot13_key;
	    uf.uf_set = 0;
	    uf.uf_index = 0;

	    sv_magic((SV*)hash, NULL, PERL_MAGIC_uvar, (char*)&uf, sizeof(uf));
	}

void
bitflip_hash(hash)
	HV *hash
	CODE:
	{
	    struct ufuncs uf;
	    uf.uf_val = bitflip_key;
	    uf.uf_set = 0;
	    uf.uf_index = 0;

	    sv_magic((SV*)hash, NULL, PERL_MAGIC_uvar, (char*)&uf, sizeof(uf));
	}

#define UTF8KLEN(sv, len)   (SvUTF8(sv) ? -(I32)len : (I32)len)

bool
exists(hash, key_sv)
	PREINIT:
	STRLEN len;
	const char *key;
	INPUT:
	HV *hash
	SV *key_sv
	CODE:
	key = SvPV(key_sv, len);
	RETVAL = hv_exists(hash, key, UTF8KLEN(key_sv, len));
        OUTPUT:
        RETVAL

bool
exists_ent(hash, key_sv)
	PREINIT:
	INPUT:
	HV *hash
	SV *key_sv
	CODE:
	RETVAL = hv_exists_ent(hash, key_sv, 0);
        OUTPUT:
        RETVAL

SV *
delete(hash, key_sv, flags = 0)
	PREINIT:
	STRLEN len;
	const char *key;
	INPUT:
	HV *hash
	SV *key_sv
	I32 flags;
	CODE:
	key = SvPV(key_sv, len);
	/* It's already mortal, so need to increase reference count.  */
	RETVAL
	    = SvREFCNT_inc(hv_delete(hash, key, UTF8KLEN(key_sv, len), flags));
        OUTPUT:
        RETVAL

SV *
delete_ent(hash, key_sv, flags = 0)
	INPUT:
	HV *hash
	SV *key_sv
	I32 flags;
	CODE:
	/* It's already mortal, so need to increase reference count.  */
	RETVAL = SvREFCNT_inc(hv_delete_ent(hash, key_sv, flags, 0));
        OUTPUT:
        RETVAL

SV *
store_ent(hash, key, value)
	PREINIT:
	SV *copy;
	HE *result;
	INPUT:
	HV *hash
	SV *key
	SV *value
	CODE:
	copy = newSV(0);
	result = hv_store_ent(hash, key, copy, 0);
	SvSetMagicSV(copy, value);
	if (!result) {
	    SvREFCNT_dec(copy);
	    XSRETURN_EMPTY;
	}
	/* It's about to become mortal, so need to increase reference count.
	 */
	RETVAL = SvREFCNT_inc(HeVAL(result));
        OUTPUT:
        RETVAL

SV *
store(hash, key_sv, value)
	PREINIT:
	STRLEN len;
	const char *key;
	SV *copy;
	SV **result;
	INPUT:
	HV *hash
	SV *key_sv
	SV *value
	CODE:
	key = SvPV(key_sv, len);
	copy = newSV(0);
	result = hv_store(hash, key, UTF8KLEN(key_sv, len), copy, 0);
	SvSetMagicSV(copy, value);
	if (!result) {
	    SvREFCNT_dec(copy);
	    XSRETURN_EMPTY;
	}
	/* It's about to become mortal, so need to increase reference count.
	 */
	RETVAL = SvREFCNT_inc(*result);
        OUTPUT:
        RETVAL

SV *
fetch_ent(hash, key_sv)
	PREINIT:
	HE *result;
	INPUT:
	HV *hash
	SV *key_sv
	CODE:
	result = hv_fetch_ent(hash, key_sv, 0, 0);
	if (!result) {
	    XSRETURN_EMPTY;
	}
	/* Force mg_get  */
	RETVAL = newSVsv(HeVAL(result));
        OUTPUT:
        RETVAL

SV *
fetch(hash, key_sv)
	PREINIT:
	STRLEN len;
	const char *key;
	SV **result;
	INPUT:
	HV *hash
	SV *key_sv
	CODE:
	key = SvPV(key_sv, len);
	result = hv_fetch(hash, key, UTF8KLEN(key_sv, len), 0);
	if (!result) {
	    XSRETURN_EMPTY;
	}
	/* Force mg_get  */
	RETVAL = newSVsv(*result);
        OUTPUT:
        RETVAL

#if defined (hv_common)

SV *
common(params)
	INPUT:
	HV *params
	PREINIT:
	HE *result;
	HV *hv = NULL;
	SV *keysv = NULL;
	const char *key = NULL;
	STRLEN klen = 0;
	int flags = 0;
	int action = 0;
	SV *val = NULL;
	U32 hash = 0;
	SV **svp;
	CODE:
	if ((svp = hv_fetchs(params, "hv", 0))) {
	    SV *const rv = *svp;
	    if (!SvROK(rv))
		croak("common passed a non-reference for parameter hv");
	    hv = (HV *)SvRV(rv);
	}
	if ((svp = hv_fetchs(params, "keysv", 0)))
	    keysv = *svp;
	if ((svp = hv_fetchs(params, "keypv", 0))) {
	    key = SvPV_const(*svp, klen);
	    if (SvUTF8(*svp))
		flags = HVhek_UTF8;
	}
	if ((svp = hv_fetchs(params, "action", 0)))
	    action = SvIV(*svp);
	if ((svp = hv_fetchs(params, "val", 0)))
	    val = newSVsv(*svp);
	if ((svp = hv_fetchs(params, "hash", 0)))
	    hash = SvUV(*svp);

	if ((svp = hv_fetchs(params, "hash_pv", 0))) {
	    PERL_HASH(hash, key, klen);
	}
	if ((svp = hv_fetchs(params, "hash_sv", 0))) {
	    STRLEN len;
	    const char *const p = SvPV(keysv, len);
	    PERL_HASH(hash, p, len);
	}

	result = (HE *)hv_common(hv, keysv, key, klen, flags, action, val, hash);
	if (!result) {
	    XSRETURN_EMPTY;
	}
	/* Force mg_get  */
	RETVAL = newSVsv(HeVAL(result));
        OUTPUT:
        RETVAL

#endif

void
test_hv_free_ent()
	PPCODE:
	test_freeent(&Perl_hv_free_ent);
	XSRETURN(4);

void
test_hv_delayfree_ent()
	PPCODE:
	test_freeent(&Perl_hv_delayfree_ent);
	XSRETURN(4);

SV *
test_share_unshare_pvn(input)
	PREINIT:
	STRLEN len;
	U32 hash;
	char *pvx;
	char *p;
	INPUT:
	SV *input
	CODE:
	pvx = SvPV(input, len);
	PERL_HASH(hash, pvx, len);
	p = sharepvn(pvx, len, hash);
	RETVAL = newSVpvn(p, len);
	unsharepvn(p, len, hash);
	OUTPUT:
	RETVAL

#if PERL_VERSION >= 9

bool
refcounted_he_exists(key, level=0)
	SV *key
	IV level
	CODE:
	if (level) {
	    croak("level must be zero, not %"IVdf, level);
	}
	RETVAL = (Perl_refcounted_he_fetch(aTHX_ PL_curcop->cop_hints_hash,
					   key, NULL, 0, 0, 0)
		  != &PL_sv_placeholder);
	OUTPUT:
	RETVAL

SV *
refcounted_he_fetch(key, level=0)
	SV *key
	IV level
	CODE:
	if (level) {
	    croak("level must be zero, not %"IVdf, level);
	}
	RETVAL = Perl_refcounted_he_fetch(aTHX_ PL_curcop->cop_hints_hash, key,
					  NULL, 0, 0, 0);
	SvREFCNT_inc(RETVAL);
	OUTPUT:
	RETVAL

#endif

=pod

sub TIEHASH  { bless {}, $_[0] }
sub STORE    { $_[0]->{$_[1]} = $_[2] }
sub FETCH    { $_[0]->{$_[1]} }
sub FIRSTKEY { my $a = scalar keys %{$_[0]}; each %{$_[0]} }
sub NEXTKEY  { each %{$_[0]} }
sub EXISTS   { exists $_[0]->{$_[1]} }
sub DELETE   { delete $_[0]->{$_[1]} }
sub CLEAR    { %{$_[0]} = () }

=cut

MODULE = XS::APItest:TempLv		PACKAGE = XS::APItest::TempLv

void
make_temp_mg_lv(sv)
SV* sv
    PREINIT:
	SV * const lv = newSV_type(SVt_PVLV);
	STRLEN len;
    PPCODE:
        SvPV(sv, len);

	sv_magic(lv, NULL, PERL_MAGIC_substr, NULL, 0);
	LvTYPE(lv) = 'x';
	LvTARG(lv) = SvREFCNT_inc_simple(sv);
	LvTARGOFF(lv) = len == 0 ? 0 : 1;
	LvTARGLEN(lv) = len < 2 ? 0 : len-2;

	EXTEND(SP, 1);
	ST(0) = sv_2mortal(lv);
	XSRETURN(1);


MODULE = XS::APItest::PtrTable	PACKAGE = XS::APItest::PtrTable PREFIX = ptr_table_

void
ptr_table_new(classname)
const char * classname
    PPCODE:
    PUSHs(sv_setref_pv(sv_newmortal(), classname, (void*)ptr_table_new()));

void
DESTROY(table)
XS::APItest::PtrTable table
    CODE:
    ptr_table_free(table);

void
ptr_table_store(table, from, to)
XS::APItest::PtrTable table
SVREF from
SVREF to
   CODE:
   ptr_table_store(table, from, to);

UV
ptr_table_fetch(table, from)
XS::APItest::PtrTable table
SVREF from
   CODE:
   RETVAL = PTR2UV(ptr_table_fetch(table, from));
   OUTPUT:
   RETVAL

void
ptr_table_split(table)
XS::APItest::PtrTable table

void
ptr_table_clear(table)
XS::APItest::PtrTable table

MODULE = XS::APItest		PACKAGE = XS::APItest

PROTOTYPES: DISABLE

BOOT:
{
    MY_CXT_INIT;

    MY_CXT.i  = 99;
    MY_CXT.sv = newSVpv("initial",0);

    MY_CXT.bhkav = get_av("XS::APItest::bhkav", GV_ADDMULTI);
    MY_CXT.bhk_record = 0;

    BhkENTRY_set(&bhk_test, start, blockhook_test_start);
    BhkENTRY_set(&bhk_test, pre_end, blockhook_test_pre_end);
    BhkENTRY_set(&bhk_test, post_end, blockhook_test_post_end);
    BhkENTRY_set(&bhk_test, eval, blockhook_test_eval);
    Perl_blockhook_register(aTHX_ &bhk_test);

    MY_CXT.cscgv = gv_fetchpvs("XS::APItest::COMPILE_SCOPE_CONTAINER",
        GV_ADDMULTI, SVt_PVAV);
    MY_CXT.cscav = GvAV(MY_CXT.cscgv);

    BhkENTRY_set(&bhk_csc, start, blockhook_csc_start);
    BhkENTRY_set(&bhk_csc, pre_end, blockhook_csc_pre_end);
    Perl_blockhook_register(aTHX_ &bhk_csc);

    MY_CXT.peep_recorder = newAV();
    MY_CXT.rpeep_recorder = newAV();

    MY_CXT.orig_peep = PL_peepp;
    MY_CXT.orig_rpeep = PL_rpeepp;
    PL_peepp = my_peep;
    PL_rpeepp = my_rpeep;
}

void
CLONE(...)
    CODE:
    MY_CXT_CLONE;
    MY_CXT.sv = newSVpv("initial_clone",0);
    MY_CXT.cscgv = gv_fetchpvs("XS::APItest::COMPILE_SCOPE_CONTAINER",
        GV_ADDMULTI, SVt_PVAV);
    MY_CXT.cscav = NULL;
    MY_CXT.bhkav = get_av("XS::APItest::bhkav", GV_ADDMULTI);
    MY_CXT.bhk_record = 0;
    MY_CXT.peep_recorder = newAV();
    MY_CXT.rpeep_recorder = newAV();

void
print_double(val)
        double val
        CODE:
        printf("%5.3f\n",val);

int
have_long_double()
        CODE:
#ifdef HAS_LONG_DOUBLE
        RETVAL = 1;
#else
        RETVAL = 0;
#endif
        OUTPUT:
        RETVAL

void
print_long_double()
        CODE:
#ifdef HAS_LONG_DOUBLE
#   if defined(PERL_PRIfldbl) && (LONG_DOUBLESIZE > DOUBLESIZE)
        long double val = 7.0;
        printf("%5.3" PERL_PRIfldbl "\n",val);
#   else
        double val = 7.0;
        printf("%5.3f\n",val);
#   endif
#endif

void
print_int(val)
        int val
        CODE:
        printf("%d\n",val);

void
print_long(val)
        long val
        CODE:
        printf("%ld\n",val);

void
print_float(val)
        float val
        CODE:
        printf("%5.3f\n",val);
	
void
print_flush()
    	CODE:
	fflush(stdout);

void
mpushp()
	PPCODE:
	EXTEND(SP, 3);
	mPUSHp("one", 3);
	mPUSHp("two", 3);
	mPUSHp("three", 5);
	XSRETURN(3);

void
mpushn()
	PPCODE:
	EXTEND(SP, 3);
	mPUSHn(0.5);
	mPUSHn(-0.25);
	mPUSHn(0.125);
	XSRETURN(3);

void
mpushi()
	PPCODE:
	EXTEND(SP, 3);
	mPUSHi(-1);
	mPUSHi(2);
	mPUSHi(-3);
	XSRETURN(3);

void
mpushu()
	PPCODE:
	EXTEND(SP, 3);
	mPUSHu(1);
	mPUSHu(2);
	mPUSHu(3);
	XSRETURN(3);

void
mxpushp()
	PPCODE:
	mXPUSHp("one", 3);
	mXPUSHp("two", 3);
	mXPUSHp("three", 5);
	XSRETURN(3);

void
mxpushn()
	PPCODE:
	mXPUSHn(0.5);
	mXPUSHn(-0.25);
	mXPUSHn(0.125);
	XSRETURN(3);

void
mxpushi()
	PPCODE:
	mXPUSHi(-1);
	mXPUSHi(2);
	mXPUSHi(-3);
	XSRETURN(3);

void
mxpushu()
	PPCODE:
	mXPUSHu(1);
	mXPUSHu(2);
	mXPUSHu(3);
	XSRETURN(3);


void
call_sv(sv, flags, ...)
    SV* sv
    I32 flags
    PREINIT:
	I32 i;
    PPCODE:
	for (i=0; i<items-2; i++)
	    ST(i) = ST(i+2); /* pop first two args */
	PUSHMARK(SP);
	SP += items - 2;
	PUTBACK;
	i = call_sv(sv, flags);
	SPAGAIN;
	EXTEND(SP, 1);
	PUSHs(sv_2mortal(newSViv(i)));

void
call_pv(subname, flags, ...)
    char* subname
    I32 flags
    PREINIT:
	I32 i;
    PPCODE:
	for (i=0; i<items-2; i++)
	    ST(i) = ST(i+2); /* pop first two args */
	PUSHMARK(SP);
	SP += items - 2;
	PUTBACK;
	i = call_pv(subname, flags);
	SPAGAIN;
	EXTEND(SP, 1);
	PUSHs(sv_2mortal(newSViv(i)));

void
call_method(methname, flags, ...)
    char* methname
    I32 flags
    PREINIT:
	I32 i;
    PPCODE:
	for (i=0; i<items-2; i++)
	    ST(i) = ST(i+2); /* pop first two args */
	PUSHMARK(SP);
	SP += items - 2;
	PUTBACK;
	i = call_method(methname, flags);
	SPAGAIN;
	EXTEND(SP, 1);
	PUSHs(sv_2mortal(newSViv(i)));

void
eval_sv(sv, flags)
    SV* sv
    I32 flags
    PREINIT:
    	I32 i;
    PPCODE:
	PUTBACK;
	i = eval_sv(sv, flags);
	SPAGAIN;
	EXTEND(SP, 1);
	PUSHs(sv_2mortal(newSViv(i)));

void
eval_pv(p, croak_on_error)
    const char* p
    I32 croak_on_error
    PPCODE:
	PUTBACK;
	EXTEND(SP, 1);
	PUSHs(eval_pv(p, croak_on_error));

void
require_pv(pv)
    const char* pv
    PPCODE:
	PUTBACK;
	require_pv(pv);

int
apitest_exception(throw_e)
    int throw_e
    OUTPUT:
        RETVAL

void
mycroak(sv)
    SV* sv
    CODE:
    if (SvOK(sv)) {
        Perl_croak(aTHX_ "%s", SvPV_nolen(sv));
    }
    else {
	Perl_croak(aTHX_ NULL);
    }

SV*
strtab()
   CODE:
   RETVAL = newRV_inc((SV*)PL_strtab);
   OUTPUT:
   RETVAL

int
my_cxt_getint()
    CODE:
	dMY_CXT;
	RETVAL = my_cxt_getint_p(aMY_CXT);
    OUTPUT:
        RETVAL

void
my_cxt_setint(i)
    int i;
    CODE:
	dMY_CXT;
	my_cxt_setint_p(aMY_CXT_ i);

void
my_cxt_getsv(how)
    bool how;
    PPCODE:
	EXTEND(SP, 1);
	ST(0) = how ? my_cxt_getsv_interp_context() : my_cxt_getsv_interp();
	XSRETURN(1);

void
my_cxt_setsv(sv)
    SV *sv;
    CODE:
	dMY_CXT;
	SvREFCNT_dec(MY_CXT.sv);
	my_cxt_setsv_p(sv _aMY_CXT);
	SvREFCNT_inc(sv);

bool
sv_setsv_cow_hashkey_core()

bool
sv_setsv_cow_hashkey_notcore()

void
rmagical_cast(sv, type)
    SV *sv;
    SV *type;
    PREINIT:
	struct ufuncs uf;
    PPCODE:
	if (!SvOK(sv) || !SvROK(sv) || !SvOK(type)) { XSRETURN_UNDEF; }
	sv = SvRV(sv);
	if (SvTYPE(sv) != SVt_PVHV) { XSRETURN_UNDEF; }
	uf.uf_val = rmagical_a_dummy;
	uf.uf_set = NULL;
	uf.uf_index = 0;
	if (SvTRUE(type)) { /* b */
	    sv_magicext(sv, NULL, PERL_MAGIC_ext, &rmagical_b, NULL, 0);
	} else { /* a */
	    sv_magic(sv, NULL, PERL_MAGIC_uvar, (char *) &uf, sizeof(uf));
	}
	XSRETURN_YES;

void
rmagical_flags(sv)
    SV *sv;
    PPCODE:
	if (!SvOK(sv) || !SvROK(sv)) { XSRETURN_UNDEF; }
	sv = SvRV(sv);
        EXTEND(SP, 3); 
	mXPUSHu(SvFLAGS(sv) & SVs_GMG);
	mXPUSHu(SvFLAGS(sv) & SVs_SMG);
	mXPUSHu(SvFLAGS(sv) & SVs_RMG);
        XSRETURN(3);

void
my_caller(level)
        I32 level
    PREINIT:
        const PERL_CONTEXT *cx, *dbcx;
        const char *pv;
        const GV *gv;
        HV *hv;
    PPCODE:
        cx = caller_cx(level, &dbcx);
        EXTEND(SP, 8);

        pv = CopSTASHPV(cx->blk_oldcop);
        ST(0) = pv ? sv_2mortal(newSVpv(pv, 0)) : &PL_sv_undef;
        gv = CvGV(cx->blk_sub.cv);
        ST(1) = isGV(gv) ? sv_2mortal(newSVpv(GvNAME(gv), 0)) : &PL_sv_undef;

        pv = CopSTASHPV(dbcx->blk_oldcop);
        ST(2) = pv ? sv_2mortal(newSVpv(pv, 0)) : &PL_sv_undef;
        gv = CvGV(dbcx->blk_sub.cv);
        ST(3) = isGV(gv) ? sv_2mortal(newSVpv(GvNAME(gv), 0)) : &PL_sv_undef;

        ST(4) = cop_hints_fetchpvs(cx->blk_oldcop, "foo");
        ST(5) = cop_hints_fetchpvn(cx->blk_oldcop, "foo", 3, 0, 0);
        ST(6) = cop_hints_fetchsv(cx->blk_oldcop, 
                sv_2mortal(newSVpvn("foo", 3)), 0);

        hv = cop_hints_2hv(cx->blk_oldcop);
        ST(7) = hv ? sv_2mortal(newRV_noinc((SV *)hv)) : &PL_sv_undef;

        XSRETURN(8);

void
DPeek (sv)
    SV   *sv

  PPCODE:
    ST (0) = newSVpv (Perl_sv_peek (aTHX_ sv), 0);
    XSRETURN (1);

void
BEGIN()
    CODE:
	sv_inc(get_sv("XS::APItest::BEGIN_called", GV_ADD|GV_ADDMULTI));

void
CHECK()
    CODE:
	sv_inc(get_sv("XS::APItest::CHECK_called", GV_ADD|GV_ADDMULTI));

void
UNITCHECK()
    CODE:
	sv_inc(get_sv("XS::APItest::UNITCHECK_called", GV_ADD|GV_ADDMULTI));

void
INIT()
    CODE:
	sv_inc(get_sv("XS::APItest::INIT_called", GV_ADD|GV_ADDMULTI));

void
END()
    CODE:
	sv_inc(get_sv("XS::APItest::END_called", GV_ADD|GV_ADDMULTI));

void
utf16_to_utf8 (sv, ...)
    SV* sv
	ALIAS:
	    utf16_to_utf8_reversed = 1
    PREINIT:
        STRLEN len;
	U8 *source;
	SV *dest;
	I32 got; /* Gah, badly thought out APIs */
    CODE:
	source = (U8 *)SvPVbyte(sv, len);
	/* Optionally only convert part of the buffer.  */ 	
	if (items > 1) {
	    len = SvUV(ST(1));
 	}
	/* Mortalise this right now, as we'll be testing croak()s  */
	dest = sv_2mortal(newSV(len * 3 / 2 + 1));
	if (ix) {
	    utf16_to_utf8_reversed(source, (U8 *)SvPVX(dest), len, &got);
	} else {
	    utf16_to_utf8(source, (U8 *)SvPVX(dest), len, &got);
	}
	SvCUR_set(dest, got);
	SvPVX(dest)[got] = '\0';
	SvPOK_on(dest);
 	ST(0) = dest;
	XSRETURN(1);

void
my_exit(int exitcode)
        PPCODE:
        my_exit(exitcode);

I32
sv_count()
        CODE:
	    RETVAL = PL_sv_count;
	OUTPUT:
	    RETVAL

void
bhk_record(bool on)
    CODE:
        dMY_CXT;
        MY_CXT.bhk_record = on;
        if (on)
            av_clear(MY_CXT.bhkav);

void
test_savehints()
    PREINIT:
	SV **svp, *sv;
    CODE:
#define store_hint(KEY, VALUE) \
		sv_setiv_mg(*hv_fetchs(GvHV(PL_hintgv), KEY, 1), (VALUE))
#define hint_ok(KEY, EXPECT) \
		((svp = hv_fetchs(GvHV(PL_hintgv), KEY, 0)) && \
		    (sv = *svp) && SvIV(sv) == (EXPECT) && \
		    (sv = cop_hints_fetchpvs(&PL_compiling, KEY)) && \
		    SvIV(sv) == (EXPECT))
#define check_hint(KEY, EXPECT) \
		do { if (!hint_ok(KEY, EXPECT)) croak("fail"); } while(0)
	PL_hints |= HINT_LOCALIZE_HH;
	ENTER;
	SAVEHINTS();
	PL_hints &= HINT_INTEGER;
	store_hint("t0", 123);
	store_hint("t1", 456);
	if (PL_hints & HINT_INTEGER) croak("fail");
	check_hint("t0", 123); check_hint("t1", 456);
	ENTER;
	SAVEHINTS();
	if (PL_hints & HINT_INTEGER) croak("fail");
	check_hint("t0", 123); check_hint("t1", 456);
	PL_hints |= HINT_INTEGER;
	store_hint("t0", 321);
	if (!(PL_hints & HINT_INTEGER)) croak("fail");
	check_hint("t0", 321); check_hint("t1", 456);
	LEAVE;
	if (PL_hints & HINT_INTEGER) croak("fail");
	check_hint("t0", 123); check_hint("t1", 456);
	ENTER;
	SAVEHINTS();
	if (PL_hints & HINT_INTEGER) croak("fail");
	check_hint("t0", 123); check_hint("t1", 456);
	store_hint("t1", 654);
	if (PL_hints & HINT_INTEGER) croak("fail");
	check_hint("t0", 123); check_hint("t1", 654);
	LEAVE;
	if (PL_hints & HINT_INTEGER) croak("fail");
	check_hint("t0", 123); check_hint("t1", 456);
	LEAVE;
#undef store_hint
#undef hint_ok
#undef check_hint

void
test_copyhints()
    PREINIT:
	HV *a, *b;
    CODE:
	PL_hints |= HINT_LOCALIZE_HH;
	ENTER;
	SAVEHINTS();
	sv_setiv_mg(*hv_fetchs(GvHV(PL_hintgv), "t0", 1), 123);
	if (SvIV(cop_hints_fetchpvs(&PL_compiling, "t0")) != 123) croak("fail");
	a = newHVhv(GvHV(PL_hintgv));
	sv_2mortal((SV*)a);
	sv_setiv_mg(*hv_fetchs(a, "t0", 1), 456);
	if (SvIV(cop_hints_fetchpvs(&PL_compiling, "t0")) != 123) croak("fail");
	b = hv_copy_hints_hv(a);
	sv_2mortal((SV*)b);
	sv_setiv_mg(*hv_fetchs(b, "t0", 1), 789);
	if (SvIV(cop_hints_fetchpvs(&PL_compiling, "t0")) != 789) croak("fail");
	LEAVE;

void
peep_enable ()
    PREINIT:
	dMY_CXT;
    CODE:
	av_clear(MY_CXT.peep_recorder);
	av_clear(MY_CXT.rpeep_recorder);
	MY_CXT.peep_recording = 1;

void
peep_disable ()
    PREINIT:
	dMY_CXT;
    CODE:
	MY_CXT.peep_recording = 0;

SV *
peep_record ()
    PREINIT:
	dMY_CXT;
    CODE:
	RETVAL = newRV_inc((SV *)MY_CXT.peep_recorder);
    OUTPUT:
	RETVAL

SV *
rpeep_record ()
    PREINIT:
	dMY_CXT;
    CODE:
	RETVAL = newRV_inc((SV *)MY_CXT.rpeep_recorder);
    OUTPUT:
	RETVAL

BOOT:
	{
	HV* stash;
	SV** meth = NULL;
	CV* cv;
	stash = gv_stashpv("XS::APItest::TempLv", 0);
	if (stash)
	    meth = hv_fetchs(stash, "make_temp_mg_lv", 0);
	if (!meth)
	    croak("lost method 'make_temp_mg_lv'");
	cv = GvCV(*meth);
	CvLVALUE_on(cv);
	}

BOOT:
{
    hintkey_rpn_sv = newSVpvs_share("XS::APItest/rpn");
    hintkey_calcrpn_sv = newSVpvs_share("XS::APItest/calcrpn");
    hintkey_stufftest_sv = newSVpvs_share("XS::APItest/stufftest");
    hintkey_swaptwostmts_sv = newSVpvs_share("XS::APItest/swaptwostmts");
    next_keyword_plugin = PL_keyword_plugin;
    PL_keyword_plugin = my_keyword_plugin;
}
