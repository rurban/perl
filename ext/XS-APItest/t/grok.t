#!perl -w
use strict;

use Test::More;
use Config;
use XS::APItest;
use feature 'switch';
no warnings 'experimental::smartmatch';
use constant TRUTH => '0 but true';

# Tests for grok_number. Not yet comprehensive.
foreach my $leader ('', ' ', '  ') {
    foreach my $trailer ('', ' ', '  ') {
	foreach ((map {"0" x $_} 1 .. 12),
		 (map {("0" x $_) . "1"} 0 .. 12),
		 (map {"1" . ("0" x $_)} 1 .. 9),
		 (map {1 << $_} 0 .. 31),
		 (map {1 << $_} 0 .. 31),
		 (map {0xFFFFFFFF >> $_} reverse (0 .. 31)),
		) {
	    foreach my $sign ('', '-', '+') {
		my $string = $leader . $sign . $_ . $trailer;
		my ($flags, $value) = grok_number($string);
		is($flags & IS_NUMBER_IN_UV, IS_NUMBER_IN_UV,
		   "'$string' is a UV");
		is($flags & IS_NUMBER_NEG, $sign eq '-' ? IS_NUMBER_NEG : 0,
		   "'$string' sign");
		is($value, abs $string, "value is correct");
	    }
	}

	{
	    my (@UV, @NV);
	    given ($Config{ivsize}) {
		when (4) {
		    @UV = qw(429496729  4294967290 4294967294 4294967295);
		    @NV = qw(4294967296 4294967297 4294967300 4294967304);
		}
		when (8) {
		    @UV = qw(1844674407370955161  18446744073709551610
			     18446744073709551614 18446744073709551615);
		    @NV = qw(18446744073709551616 18446744073709551617
			     18446744073709551620 18446744073709551624);
		}
		default {
		    die "Unknown IV size $_";
		}
	    }
	    foreach (@UV) {
		my $string = $leader . $_ . $trailer;
		my ($flags, $value) = grok_number($string);
		is($flags & IS_NUMBER_IN_UV, IS_NUMBER_IN_UV,
		   "'$string' is a UV");
		is($value, abs $string, "value is correct");
	    }
	    foreach (@NV) {
		my $string = $leader . $_ . $trailer;
		my ($flags, $value) = grok_number($string);
		is($flags & IS_NUMBER_IN_UV, 0, "'$string' is an NV");
		is($value, undef, "value is correct");
	    }
	}

	my $string = $leader . TRUTH . $trailer;
	my ($flags, $value) = grok_number($string);

	if ($string eq TRUTH) {
	    is($flags & IS_NUMBER_IN_UV, IS_NUMBER_IN_UV, "'$string' is a UV");
	    is($value, 0);
	} else {
	    is($flags, 0, "'$string' is not a number");
	    is($value, undef);
	}
    }
}

# format tests
my @groks =
  (
   # input, in flags, out uv, out flags
   [ "1",    0,                  1,     IS_NUMBER_IN_UV ],
   [ "1x",   0,                  undef, 0 ],
   [ "1x",   PERL_SCAN_TRAILING, 1,     IS_NUMBER_IN_UV | IS_NUMBER_TRAILING ],
   [ "3.1",  0,                  3,     IS_NUMBER_IN_UV | IS_NUMBER_NOT_INT ],
   [ "3.1a", 0,                  undef, 0 ],
   [ "3.1a", PERL_SCAN_TRAILING, 3,
     IS_NUMBER_IN_UV | IS_NUMBER_NOT_INT | IS_NUMBER_TRAILING ],
   [ "3e5",  0,                  undef, IS_NUMBER_NOT_INT ],
   [ "3e",   0,                  undef, 0 ],
   [ "3e",   PERL_SCAN_TRAILING, 3,     IS_NUMBER_IN_UV | IS_NUMBER_TRAILING ],
   [ "3e+",  0,                  undef, 0 ],
   [ "3e+",  PERL_SCAN_TRAILING, 3,     IS_NUMBER_IN_UV | IS_NUMBER_TRAILING ],
   [ "Inf",  0,                  undef,
     IS_NUMBER_INFINITY | IS_NUMBER_NOT_INT ],
   [ "In",   0,                  undef, 0 ],
   [ "Infin",0,                  undef, 0 ],
   # this doesn't work and hasn't been needed yet
   #[ "Infin",PERL_SCAN_TRAILING, undef,
   #  IS_NUMBER_INFINITY | IS_NUMBER_NOT_INT | IS_NUMBER_TRAILING ],
   [ "nan",  0,                  undef, IS_NUMBER_NAN | IS_NUMBER_NOT_INT ],
   [ "nanx", 0,                  undef, 0 ],
   [ "nanx", PERL_SCAN_TRAILING, undef,
     IS_NUMBER_NAN | IS_NUMBER_NOT_INT | IS_NUMBER_TRAILING],
  );

for my $grok (@groks) {
  my ($out_flags, $out_uv) = grok_number_flags($grok->[0], $grok->[1]);
  is($out_uv,    $grok->[2], "'$grok->[0]' flags $grok->[1] - check number");
  is($out_flags, $grok->[3], "'$grok->[0]' flags $grok->[1] - check flags");
}

my $ATOU_MAX = ~0;

# atou tests
my @atous =
  (
   # [ input, endsv, out uv, out len ]

   # Basic cases.
   [ "0",    "",   0,   1 ],
   [ "1",    "",   1,   1 ],
   [ "2",    "",   2,   1 ],
   [ "9",    "",   9,   1 ],
   [ "12",   "",   12,  2 ],
   [ "123",  "",   123, 3 ],

   # Trailing whitespace  is accepted or rejected, depending on endptr.
   [ "0 ",   " ",   0,  1 ],
   [ "1 ",   " ",   1,  1 ],
   [ "2 ",   " ",   2,  1 ],
   [ "12 ",  " ",   12, 2 ],

   # Trailing garbage is accepted or rejected, depending on endptr.
   [ "0x",   "x",   0,  1 ],
   [ "1x",   "x",   1,  1 ],
   [ "2x",   "x",   2,  1 ],
   [ "12x",  "x",   12, 2 ],

   # Leading whitespace is failure.
   [ " 0",   " 0",  0,  0 ],
   [ " 1",   " 1",  0,  0 ],
   [ " 12",  " 12", 0,  0 ],

   # Leading garbage is outright failure.
   [ "x0",   "x0",  0,  0 ],
   [ "x1",   "x1",  0,  0 ],
   [ "x12",  "x12", 0,  0 ],

   # We do not parse decimal point.
   [ "12.3",  ".3", 12, 2 ],

   # Leading pluses or minuses are no good.
   [ "+12", "+12",  0, 0 ],
   [ "-12", "-12",  0, 0 ],

   # Extra leading zeros cause overflow.
   [ "00",   "00",  $ATOU_MAX,  0 ],
   [ "01",   "01",  $ATOU_MAX,  0 ],
   [ "012",  "012", $ATOU_MAX,  0 ],
  );

if ($Config{sizesize} == 8) {
    push @atous,
      (
       [ "4294967294", "", 4294967294, 10, ],
       [ "4294967295", "", 4294967295, 10, ],
       [ "4294967296", "", 4294967296, 10, ],

       [ "9999999999", "", 9999999999, 10, ],

       [ "18446744073709551614", "", 18446744073709551614, 20, ],
       [ "18446744073709551615", "", $ATOU_MAX, 20, ],
       [ "18446744073709551616", "18446744073709551616", $ATOU_MAX, 0, ],
      );
} elsif ($Config{sizesize} == 4) {
    push @atous,
      (
       [ "4294967294", "", 4294967294, 10, ],
       [ "4294967295", "", $ATOU_MAX, 10, ],
       [ "4294967296", "", $ATOU_MAX, 0, ],

       [ "9999999999", "", $ATOU_MAX, 0, ],

       [ "18446744073709551614", "", $ATOU_MAX, 0, ],
       [ "18446744073709551615", "", $ATOU_MAX, 0, ],
       [ "18446744073709551616", "18446744073709551616", $ATOU_MAX, 0, ],
      );
}

# This will fail to fail once 128/256-bit systems arrive.
push @atous,
    (
       [ "99999999999999999999", "99999999999999999999", $ATOU_MAX, 0 ],
    );

for my $grok (@atous) {
    my $input = $grok->[0];
    my $endsv = $grok->[1];

    my ($out_uv, $out_len);

    # First with endsv.
    ($out_uv, $out_len) = grok_atou($input, $endsv);
    is($out_uv,  $grok->[2],
       "'$input' $endsv - number success (got $out_uv cf $grok->[2])");
    ok($grok->[3] <= length $input, "'$input' $endsv - length sanity 1");
    unless (length $grok->[1]) {
        is($out_len, $grok->[3], "'$input' $endsv - length sanity 2");
    } # else { ... } ?
    is($endsv, substr($input, $out_len), "'$input' $endsv - length success");

    # Then without endsv (undef == NULL).
    ($out_uv, $out_len) = grok_atou($input, undef);
    if (length $grok->[1]) {
        if ($grok->[2] == $ATOU_MAX) {
            is($out_uv,  $ATOU_MAX, "'$input' undef - number overflow");
        } else {
            is($out_uv,  0, "'$input' undef - number zero");
        }
    } else {
        is($out_uv,  $grok->[2],
           "'$input' undef - number success (got $out_uv cf $grok->[2])");
    }
}

done_testing();
