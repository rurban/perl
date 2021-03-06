#!./perl

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require './test.pl';
}

use strict;

use Config;

plan(tests => 79);

# Test hexfloat literals.

is(0x0p0, 0);
is(0x0.p0, 0);
is(0x.0p0, 0);
is(0x0.0p0, 0);
is(0x0.00p0, 0);

is(0x1p0, 1);
is(0x1.p0, 1);
is(0x1.0p0, 1);
is(0x1.00p0, 1);

is(0x2p0, 2);
is(0x2.p0, 2);
is(0x2.0p0, 2);
is(0x2.00p0, 2);

is(0x1p1, 2);
is(0x1.p1, 2);
is(0x1.0p1, 2);
is(0x1.00p1, 2);

is(0x.1p0, 0.0625);
is(0x0.1p0, 0.0625);
is(0x0.10p0, 0.0625);
is(0x0.100p0, 0.0625);

# Positive exponents.
is(0x1p2, 4);
is(0x1p+2, 4);
is(0x0p+0, 0);

# Negative exponents.
is(0x1p-1, 0.5);
is(0x1.p-1, 0.5);
is(0x1.0p-1, 0.5);
is(0x0p-0, 0);

is(0x1p+2, 4);
is(0x1p-2, 0.25);

is(0x3p+2, 12);
is(0x3p-2, 0.75);

# Shifting left.
is(0x1p2, 1 << 2);
is(0x1p3, 1 << 3);
is(0x3p4, 3 << 4);
is(0x3p5, 3 << 5);
is(0x12p23, 0x12 << 23);

# Shifting right.
is(0x1p-2, 1 / (1 << 2));
is(0x1p-3, 1 / (1 << 3));
is(0x3p-4, 3 / (1 << 4));
is(0x3p-5, 3 / (1 << 5));
is(0x12p-23, 0x12 / (1 << 23));

# Negative sign.
is(-0x1p+2, -4);
is(-0x1p-2, -0.25);
is(-0x0p+0, 0);
is(-0x0p-0, 0);

is(0x0.10p0, 0.0625);
is(0x0.1p0, 0.0625);
is(0x.1p0, 0.0625);

is(0x12p+3, 144);
is(0x12p-3, 2.25);

# Hexdigits (lowercase).
is(0x9p+0, 9);
is(0xap+0, 10);
is(0xfp+0, 15);
is(0x10p+0, 16);
is(0x11p+0, 17);
is(0xabp+0, 171);
is(0xab.cdp+0, 171.80078125);

# Uppercase hexdigits and exponent prefix.
is(0xAp+0, 10);
is(0xFp+0, 15);
is(0xABP+0, 171);
is(0xAB.CDP+0, 171.80078125);

# Underbars.
is(0xa_b.c_dp+1_2, 703696);

# Note that the hexfloat representation is not unique since the
# exponent can be shifted, and the hexdigits with it: this is no
# different from 3e4 cf 30e3 cf 30000.  The shifting of the hexdigits
# makes it look stranger, though: 0xap1 == 0x5p2.

# Needs to use within() instead of is() because of long doubles.
within(0x1.99999999999ap-4, 0.1, 1e-9);
within(0x3.333333333333p-5, 0.1, 1e-9);
within(0xc.cccccccccccdp-7, 0.1, 1e-9);

my $warn;

local $SIG{__WARN__} = sub { $warn = shift };

sub get_warn() {
    my $save = $warn;
    undef $warn;
    return $save;
}

{ # Test certain things that are not hexfloats and should stay that way.
    eval '0xp3';
    like(get_warn(), qr/Missing operator before p3/);

    eval '5p3';
    like(get_warn(), qr/Missing operator before p3/);

    my @a;
    eval '@a = 0x3..5';
    is("@a", "3 4 5");

    eval '$a = eval "0x.3"';
    is($a, '03');

    eval '$a = eval "0xc.3"';
    is($a, '123');
}

# Test warnings.
SKIP:
{
    if ($Config{nv_preserves_uv_bits} == 53) {
        local $^W = 1;

        eval '0x1_0000_0000_0000_0p0';
        is(get_warn(), undef);

        eval '0x2_0000_0000_0000_0p0';
        like(get_warn(), qr/^Hexadecimal float: mantissa overflow/);

        eval '0x1.0000_0000_0000_0p0';
        is(get_warn(), undef);

        eval '0x2.0000_0000_0000_0p0';
        like(get_warn(), qr/^Hexadecimal float: mantissa overflow/);

        eval '0x.1p-1021';
        is(get_warn(), undef);

        eval '0x.1p-1023';
        like(get_warn(), qr/^Hexadecimal float: exponent underflow/);

        eval '0x1.fffffffffffffp+1023';
        is(get_warn(), undef);

        eval '0x1.fffffffffffffp+1024';
        like(get_warn(), qr/^Hexadecimal float: exponent overflow/);
    } else {
        print "# skipping warning tests\n";
        skip "nv_preserves_uv_bits is $Config{nv_preserves_uv_bits} not 53", 8;
    }
}

# sprintf %a/%A testing is done in sprintf2.t,
# trickier than necessary because of long doubles,
# and because looseness of the spec.
