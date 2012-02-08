#!./perl -w
# RT#81332 May not pollute the namespace for the compiler with all the XS constants
BEGIN {
	unshift @INC, 't';
	require Config;
	if (($Config::Config{'extensions'} !~ /\bB\b/) ){
		print "1..0 # Skip -- Perl configured without B module\n";
		exit 0;
	}
	require 'test.pl';
}

CHECK {
  plan(3);
  ok(SVp_IOK, "SVp_IOK imported as requested");

  my $found;
  while ( my ( $k, $v ) = each %B:: ) {
    $found++ if $k eq 'SVf_IOK';
  }
  ok(!$found, "RT#81332 B constants may not be initialized at BEGIN" );
}

use B qw(SVp_IOK);

{
  my $found;
  while ( my ( $k, $v ) = each %B:: ) {
    $found++ if $k eq 'SVf_IOK';
  }
  ok($found, "B constants initialized at run-time" );
}

1;
