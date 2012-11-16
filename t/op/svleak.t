#!./perl

# A place to put some simple leak tests. Uses XS::APItest to make
# PL_sv_count available, allowing us to run a bit of code multiple times and
# see if the count increases.

BEGIN {
    chdir 't';
    @INC = '../lib';
    require './test.pl';

    eval { require XS::APItest; XS::APItest->import('sv_count'); 1 }
	or skip_all("XS::APItest not available");
}

use Config;

plan tests => 69;

# run some code N times. If the number of SVs at the end of loop N is
# greater than (N-1)*delta at the end of loop 1, we've got a leak
#
sub leak {
    my ($n, $delta, $code, @rest) = @_;
    my $sv0 = 0;
    my $sv1 = 0;
    for my $i (1..$n) {
	&$code();
	$sv1 = sv_count();
	$sv0 = $sv1 if $i == 1;
    }
    cmp_ok($sv1-$sv0, '<=', ($n-1)*$delta, @rest);
}

# Like leak, but run a string eval instead.
# The code is used instead of the test name
# if the name is absent.
sub eleak {
    my ($n,$delta,$code,@rest) = @_;
    leak $n, $delta, sub { eval $code },
         @rest ? @rest : $code
}

# run some expression N times. The expr is concatenated N times and then
# evaled, ensuring that that there are no scope exits between executions.
# If the number of SVs at the end of expr N is greater than (N-1)*delta at
# the end of expr 1, we've got a leak
#
sub leak_expr {
    my ($n, $delta, $expr, @rest) = @_;
    my $sv0 = 0;
    my $sv1 = 0;
    my $true = 1; # avoid stuff being optimised away
    my $code1 = "($expr || \$true)";
    my $code = "$code1 && (\$sv0 = sv_count())" . ("&& $code1" x 4)
		. " && (\$sv1 = sv_count())";
    if (eval $code) {
	cmp_ok($sv1-$sv0, '<=', ($n-1)*$delta, @rest);
    }
    else {
	fail("eval @rest: $@");
    }
}


my @a;

leak(5, 0, sub {},                 "basic check 1 of leak test infrastructure");
leak(5, 0, sub {push @a,1;pop @a}, "basic check 2 of leak test infrastructure");
leak(5, 1, sub {push @a,1;},       "basic check 3 of leak test infrastructure");

eleak(2, 0, 'sub{<*>}');

eleak(2, 0, 'goto sub {}', 'goto &sub in eval');
eleak(2, 0, '() = sort { goto sub {} } 1,2', 'goto &sub in sort');
eleak(2, 0, '/(?{ goto sub {} })/', 'goto &sub in regexp');

sub TIEARRAY	{ bless [], $_[0] }
sub FETCH	{ $_[0]->[$_[1]] }
sub STORE	{ $_[0]->[$_[1]] = $_[2] }

# local $tied_elem[..] leaks <20020502143736.N16831@dansat.data-plan.com>"
{
    tie my @a, 'main';
    leak(5, 0, sub {local $a[0]}, "local \$tied[0]");
}

# [perl #74484]  repeated tries leaked SVs on the tmps stack

leak_expr(5, 0, q{"YYYYYa" =~ /.+?(a(.+?)|b)/ }, "trie leak");

# [perl #48004] map/grep didn't free tmps till the end

{
    # qr/1/ just creates tmps that are hopefully freed per iteration

    my $s;
    my @a;
    my @count = (0) x 4; # pre-allocate

    grep qr/1/ && ($count[$_] = sv_count()) && 99,  0..3;
    is(@count[3] - @count[0], 0, "void   grep expr:  no new tmps per iter");
    grep { qr/1/ && ($count[$_] = sv_count()) && 99 }  0..3;
    is(@count[3] - @count[0], 0, "void   grep block: no new tmps per iter");

    $s = grep qr/1/ && ($count[$_] = sv_count()) && 99,  0..3;
    is(@count[3] - @count[0], 0, "scalar grep expr:  no new tmps per iter");
    $s = grep { qr/1/ && ($count[$_] = sv_count()) && 99 }  0..3;
    is(@count[3] - @count[0], 0, "scalar grep block: no new tmps per iter");

    @a = grep qr/1/ && ($count[$_] = sv_count()) && 99,  0..3;
    is(@count[3] - @count[0], 0, "list   grep expr:  no new tmps per iter");
    @a = grep { qr/1/ && ($count[$_] = sv_count()) && 99 }  0..3;
    is(@count[3] - @count[0], 0, "list   grep block: no new tmps per iter");


    map qr/1/ && ($count[$_] = sv_count()) && 99,  0..3;
    is(@count[3] - @count[0], 0, "void   map expr:  no new tmps per iter");
    map { qr/1/ && ($count[$_] = sv_count()) && 99 }  0..3;
    is(@count[3] - @count[0], 0, "void   map block: no new tmps per iter");

    $s = map qr/1/ && ($count[$_] = sv_count()) && 99,  0..3;
    is(@count[3] - @count[0], 0, "scalar map expr:  no new tmps per iter");
    $s = map { qr/1/ && ($count[$_] = sv_count()) && 99 }  0..3;
    is(@count[3] - @count[0], 0, "scalar map block: no new tmps per iter");

    @a = map qr/1/ && ($count[$_] = sv_count()) && 99,  0..3;
    is(@count[3] - @count[0], 3, "list   map expr:  one new tmp per iter");
    @a = map { qr/1/ && ($count[$_] = sv_count()) && 99 }  0..3;
    is(@count[3] - @count[0], 3, "list   map block: one new tmp per iter");

}

SKIP:
{ # broken by 304474c3, fixed by cefd5c7c, but didn't seem to cause
  # any other test failures
  # base test case from ribasushi (Peter Rabbitson)
  eval { require Scalar::Util; Scalar::Util->import("weaken"); 1; }
    or skip "no weaken", 1;
  my $weak;
  {
    $weak = my $in = {};
    weaken($weak);
    my $out = { in => $in, in => undef }
  }
  ok(!$weak, "hash referenced weakened SV released");
}

# RT #72246: rcatline memory leak on bad $/

leak(2, 0,
    sub {
	my $f;
	open CATLINE, '<', \$f;
	local $/ = "\x{262E}";
	my $str = "\x{2622}";
	eval { $str .= <CATLINE> };
    },
    "rcatline leak"
);

{
    my $RE = qr/
      (?:
        <(?<tag>
          \s*
          [^>\s]+
        )>
      )??
    /xis;

    "<html><body></body></html>" =~ m/$RE/gcs;

    leak(5, 0, sub {
        my $tag = $+{tag};
    }, "named regexp captures");
}

eleak(2,0,'/[:]/');
eleak(2,0,'/[\xdf]/i');
eleak(2,0,'s![^/]!!');
eleak(2,0,'/[pp]/');
eleak(2,0,'/[[:ascii:]]/');
leak(2,0,sub { /(??{})/ }, '/(??{})/');

leak(2,0,sub { !$^V }, '[perl #109762] version object in boolean context');


# [perl #114356] run-time rexexp with unchanging pattern got
# inflated refcounts
eleak(2, 0, q{ my $x = "x"; "abc" =~ /$x/ for 1..5 }, '#114356');

eleak(2, 0, 'sub', '"sub" with nothing following');
eleak(2, 0, '+sub:a{}', 'anon subs with invalid attributes');
eleak(2, 0, 'no warnings; sub a{1 1}', 'sub with syntax error');
eleak(2, 0, 'no warnings; sub {1 1}', 'anon sub with syntax error');
eleak(2, 0, 'no warnings; use feature ":all"; my sub a{1 1}',
     'my sub with syntax error');

# Syntax errors
eleak(2, 0, '"${<<END}"
                 ', 'unterminated here-doc in quotes in multiline eval');
eleak(2, 0, '"${<<END
               }"', 'unterminated here-doc in multiline quotes in eval');
leak(2, 0, sub { eval { do './op/svleak.pl' } },
        'unterminated here-doc in file');
eleak(2, 0, 'tr/9-0//');
eleak(2, 0, 'tr/a-z-0//');
eleak(2, 0, 'no warnings; nonexistent_function 33838',
        'bareword followed by number');
eleak(2, 0, '//dd;'x20, '"too many errors" when parsing m// flags');
eleak(2, 0, 's///dd;'x20, '"too many errors" when parsing s/// flags');
eleak(2, 0, 'no warnings; 2 2;BEGIN{}',
      'BEGIN block after syntax error');
{
    local %INC; # in case Errno is already loaded
    eleak(2, 0, 'no warnings; 2@!{',
                'implicit "use Errno" after syntax error');
}
eleak(2, 0, "\"\$\0\356\"", 'qq containing $ <null> something');
eleak(2, 0, 'END OF TERMS AND CONDITIONS', 'END followed by words');


# [perl #114764] Attributes leak scalars
leak(2, 0, sub { eval 'my $x : shared' }, 'my $x :shared used to leak');

eleak(2, 0, 'ref: 1', 'labels');

# Tied hash iteration was leaking if the hash was freed before itera-
# tion was over.
package t {
    sub TIEHASH { bless [] }
    sub FIRSTKEY { 0 }
}
leak(2, 0, sub {
    my $h = {};
    tie %$h, t;
    each %$h;
    undef $h;
}, 'tied hash iteration does not leak');

package explosive_scalar {
    sub TIESCALAR { my $self = shift; bless [undef, {@_}], $self  }
    sub FETCH     { die 'FETCH' if $_[0][1]{FETCH}; $_[0][0] }
    sub STORE     { die 'STORE' if $_[0][1]{STORE}; $_[0][0] = $_[1] }
}
tie my $die_on_fetch, 'explosive_scalar', FETCH => 1;

# List assignment was leaking when assigning explosive scalars to
# aggregates.
leak(2, 0, sub {
    eval {%a = ($die_on_fetch, 0)}; # key
    eval {%a = (0, $die_on_fetch)}; # value
    eval {%a = ($die_on_fetch, $die_on_fetch)}; # both
}, 'hash assignment does not leak');
leak(2, 0, sub {
    eval {@a = ($die_on_fetch)};
    eval {($die_on_fetch, $b) = ($b, $die_on_fetch)};
    # restore
    tie $die_on_fetch, 'explosive_scalar', FETCH => 1;
}, 'array assignment does not leak');

# [perl #107000]
package hhtie {
    sub TIEHASH { bless [] }
    sub STORE    { $_[0][0]{$_[1]} = $_[2] }
    sub FETCH    { die if $explosive; $_[0][0]{$_[1]} }
    sub FIRSTKEY { keys %{$_[0][0]}; each %{$_[0][0]} }
    sub NEXTKEY  { each %{$_[0][0]} }
}
leak(2, 0, sub {
    eval q`
    	BEGIN {
	    $hhtie::explosive = 0;
	    tie %^H, hhtie;
	    $^H{foo} = bar;
	    $hhtie::explosive = 1;
    	}
	{ 1; }
    `;
}, 'hint-hash copying does not leak');

package explosive_array {
    sub TIEARRAY  { bless [[], {}], $_[0]  }
    sub FETCH     { die if $_[0]->[1]{FETCH}; $_[0]->[0][$_[1]]  }
    sub FETCHSIZE { die if $_[0]->[1]{FETCHSIZE}; scalar @{ $_[0]->[0]  }  }
    sub STORE     { die if $_[0]->[1]{STORE}; $_[0]->[0][$_[1]] = $_[2]  }
    sub CLEAR     { die if $_[0]->[1]{CLEAR}; @{$_[0]->[0]} = ()  }
    sub EXTEND    { die if $_[0]->[1]{EXTEND}; return  }
    sub explode   { my $self = shift; $self->[1] = {@_} }
}

leak(2, 0, sub {
    tie my @a, 'explosive_array';
    tied(@a)->explode( STORE => 1 );
    my $x = 0;
    eval { @a = ($x)  };
}, 'explosive array assignment does not leak');

leak(2, 0, sub {
    my ($a, $b);
    eval { warn $die_on_fetch };
}, 'explosive warn argument');

leak(2, 0, sub {
    my $foo = sub { return $die_on_fetch };
    my $res = eval { $foo->() };
    my @res = eval { $foo->() };
}, 'function returning explosive does not leak');

leak(2, 0, sub {
    my $res = eval { {$die_on_fetch, 0} };
    $res = eval { {0, $die_on_fetch} };
}, 'building anon hash with explosives does not leak');

leak(2, 0, sub {
    my $res = eval { [$die_on_fetch] };
}, 'building anon array with explosives does not leak');

leak(2, 0, sub {
    my @a;
    eval { push @a, $die_on_fetch };
}, 'pushing exploding scalar does not leak');

leak(2, 0, sub {
    eval { push @-, '' };
}, 'pushing onto read-only array does not leak');


# Run-time regexp code blocks
{
    use re 'eval';
    my @tests = ('[(?{})]','(?{})');
    for my $t (@tests) {
	leak(2, 0, sub {
	    / $t/;
	}, "/ \$x/ where \$x is $t does not leak");
	leak(2, 0, sub {
	    /(?{})$t/;
	}, "/(?{})\$x/ where \$x is $t does not leak");
    }
}


{
    use warnings FATAL => 'all';
    leak(2, 0, sub {
	no warnings 'once';
	eval { printf uNopened 42 };
    }, 'printfing to bad handle under fatal warnings does not leak');
    open my $fh, ">", \my $buf;
    leak(2, 0, sub {
	eval { printf $fh chr 2455 };
    }, 'wide fatal warning does not make printf leak');
    close $fh or die $!;
}


leak(2,0,sub{eval{require untohunothu}}, 'requiring nonexistent module');
