#!perl

use strict;
use warnings;

use Test::More tests => 26;

use_ok('XS::APItest');

sub method { 1 }

ok !XS::APItest::gv_fetchmethod_flags_type(\%::, "nothing", 1, 0);

for my $type ( 1..3 ) {
    is XS::APItest::gv_fetchmethod_flags_type(\%::, "method", $type, 0), "*main::method", "Sanity check";
}

{
  no strict 'syms';
  ok !XS::APItest::gv_fetchmethod_flags_type(\%::, "method\0not quite!", 1, 0), "gv_fetchmethod_flags_sv() is nul-clean";
  ok !XS::APItest::gv_fetchmethod_flags_type(\%::, "method\0not quite!", 3, 0), "gv_fetchmethod_flags_pvn() is nul-clean";

  ok XS::APItest::gv_fetchmethod_flags_type(\%::, "method\0not quite!", 0, 0), "gv_fetchmethod_flags() is not nul-clean";
  is XS::APItest::gv_fetchmethod_flags_type(\%::, "method\0not quite!", 2, 0), "*main::method", "gv_fetchmethod_flags_pv() is not nul-clean";
}

eval { XS::APItest::gv_fetchmethod_flags_type(\%::, "method\0not quite!", 1, 0); };
like("$@", qr/^Illegal symbolname/, "gv_fetchmethod_flags_sv() dies with nul methodname");
{
  my $h;
  no strict 'refs';
  { no strict 'syms'; $h = \%{"main\0xx::"}; }
  eval { XS::APItest::gv_fetchmethod_flags_type($h, "methodnot quite", 1, 0); };
}
like("$@", qr/^Illegal classname/, "gv_fetchmethod_flags_sv() dies with nul stash");

{
    use utf8;
    use open qw( :utf8 :std );

    package ｍａｉｎ;
    
    sub ｍｅｔｈｏｄ { 1 }
    sub method { 1 }

    my $meth_as_octets =
            "\357\275\215\357\275\205\357\275\224\357\275\210\357\275\217\357\275\204";

    for my $type ( 1..3 ) {
        ::is XS::APItest::gv_fetchmethod_flags_type(\%ｍａｉｎ::, "ｍｅｔｈｏｄ", $type, 0), "*ｍａｉｎ::ｍｅｔｈｏｄ";
        ::ok !XS::APItest::gv_fetchmethod_flags_type(\%ｍａｉｎ::, $meth_as_octets, $type, 0);
        ::is XS::APItest::gv_fetchmethod_flags_type(\%ｍａｉｎ::, "method", $type, 0), "*ｍａｉｎ::method";
        
        {
            no strict 'refs';
            ::ok !XS::APItest::gv_fetchmethod_flags_type(
                            \%{"\357\275\215\357\275\201\357\275\211\357\275\216::"},
                            "ｍｅｔｈｏｄ", $type, 0);
            ::ok !XS::APItest::gv_fetchmethod_flags_type(
                            \%{"\357\275\215\357\275\201\357\275\211\357\275\216::"},
                            "method", $type, 0);
        }
    }
}
