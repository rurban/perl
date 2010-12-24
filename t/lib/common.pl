# This code is used by lib/charnames.t, lib/feature.t, lib/subs.t,
# lib/strict.t and lib/warnings.t
#
# On input, $::local_tests is the number of tests in the caller; or
# 'no_plan' if unknown, in which case it is the caller's responsibility
# to call cur_test() to find out how many this executed

BEGIN {
    require './test.pl';
}

use Config;
use File::Path;
use File::Spec::Functions qw(catfile curdir rel2abs);

use strict;
use warnings;
my (undef, $file) = caller;
my ($pragma_name) = $file =~ /([A-Za-z_0-9]+)\.t$/
    or die "Can't identify pragama to test from file name '$file'";

$| = 1;

my $tmpfile = tempfile();

my @prgs = () ;
my @w_files = () ;

if (@ARGV)
  { print "ARGV = [@ARGV]\n" ;
      @w_files = map { s#^#./lib/$pragma_name/#; $_ } @ARGV
  }
else
  { @w_files = sort glob(catfile(curdir(), "lib", $pragma_name, "*")) }

my $files = 0;
foreach my $file (@w_files) {

    next if $file =~ /(~|\.orig|,v)$/;
    next if $file =~ /perlio$/ && !(find PerlIO::Layer 'perlio');
    next if -d $file;

    open F, "<$file" or die "Cannot open $file: $!\n" ;
    my $line = 0;
    while (<F>) {
        $line++;
	last if /^__END__/ ;
    }

    {
        local $/ = undef;
        $files++;
        @prgs = (@prgs, $file, split "\n########\n", <F>) ;
    }
    close F ;
}

$^X = rel2abs($^X);
my $tempdir = tempfile;

mkdir $tempdir, 0700 or die "Can't mkdir '$tempdir': $!";
chdir $tempdir or die die "Can't chdir '$tempdir': $!";
unshift @INC, '../../lib';
my $cleanup = 1;
my %tempfiles;

END {
    if ($cleanup) {
	chdir '..' or die "Couldn't chdir .. for cleanup: $!";
	rmtree($tempdir);
    }
}

local $/ = undef;

my $tests = $::local_tests || 0;
$tests = scalar(@prgs)-$files + $tests if $tests !~ /\D/;
plan $tests;    # If input is 'no_plan', pass it on unchanged

for (@prgs){
    unless (/\n/)
     {
      print "# From $_\n";
      next;
     }
    my $switch = "";
    my @temps = () ;
    my @temp_path = () ;
    if (s/^\s*-\w+//){
        $switch = $&;
    }
    my($prog,$expected) = split(/\nEXPECT(?:\n|$)/, $_, 2);

    my %reason;
    foreach my $what (qw(skip todo)) {
	$prog =~ s/^#\s*\U$what\E\s*(.*)\n//m and $reason{$what} = $1;
	# If the SKIP reason starts ? then it's taken as a code snippet to
	# evaluate. This provides the flexibility to have conditional SKIPs
	if ($reason{$what} && $reason{$what} =~ s/^\?//) {
	    my $temp = eval $reason{$what};
	    if ($@) {
		die "# In \U$what\E code reason:\n# $reason{$what}\n$@";
	    }
	    $reason{$what} = $temp;
	}
    }

    if ( $prog =~ /--FILE--/) {
        my(@files) = split(/\n--FILE--\s*([^\s\n]*)\s*\n/, $prog) ;
	shift @files ;
	die "Internal error: test $_ didn't split into pairs, got " .
		scalar(@files) . "[" . join("%%%%", @files) ."]\n"
	    if @files % 2 ;
	while (@files > 2) {
	    my $filename = shift @files ;
	    my $code = shift @files ;
    	    push @temps, $filename ;
    	    if ($filename =~ m#(.*)/# && $filename !~ m#^\.\./#) {
                mkpath($1);
                push(@temp_path, $1);
	    }
	    open F, ">$filename" or die "Cannot open $filename: $!\n" ;
	    print F $code ;
	    close F or die "Cannot close $filename: $!\n";
	}
	shift @files ;
	$prog = shift @files ;
    }

    open TEST, ">$tmpfile" or die "Cannot open >$tmpfile: $!";
    print TEST q{
        BEGIN {
            open(STDERR, ">&STDOUT")
              or die "Can't dup STDOUT->STDERR: $!;";
        }
    };
    print TEST "\n#line 1\n";  # So the line numbers don't get messed up.
    print TEST $prog,"\n";
    close TEST or die "Cannot close $tmpfile: $!";
    my $results = runperl( switches => ["-I../../lib", $switch], nolib => 1,
			   stderr => 1, progfile => $tmpfile );
    my $status = $?;
    $results =~ s/\n+$//;
    # allow expected output to be written as if $prog is on STDIN
    $results =~ s/$::tempfile_regexp/-/g;
    if ($^O eq 'VMS') {
        # some tests will trigger VMS messages that won't be expected
        $results =~ s/\n?%[A-Z]+-[SIWEF]-[A-Z]+,.*//;

        # pipes double these sometimes
        $results =~ s/\n\n/\n/g;
    }
# bison says 'parse error' instead of 'syntax error',
# various yaccs may or may not capitalize 'syntax'.
    $results =~ s/^(syntax|parse) error/syntax error/mig;
    # allow all tests to run when there are leaks
    $results =~ s/Scalars leaked: \d+\n//g;

    $expected =~ s/\n+$//;
    my $prefix = ($results =~ s#^PREFIX(\n|$)##) ;
    # any special options? (OPTIONS foo bar zap)
    my $option_regex = 0;
    my $option_random = 0;
    if ($expected =~ s/^OPTIONS? (.+)\n//) {
	foreach my $option (split(' ', $1)) {
	    if ($option eq 'regex') { # allow regular expressions
		$option_regex = 1;
	    }
	    elsif ($option eq 'random') { # all lines match, but in any order
		$option_random = 1;
	    }
	    else {
		die "$0: Unknown OPTION '$option'\n";
	    }
	}
    }
    die "$0: can't have OPTION regex and random\n"
        if $option_regex + $option_random > 1;
    my $ok = 0;
    if ($results =~ s/^SKIPPED\n//) {
	print "$results\n" ;
	$ok = 1;
    }
    elsif ($option_random) {
        $ok = randomMatch($results, $expected);
    }
    elsif ($option_regex) {
	$ok = $results =~ /^$expected/;
    }
    elsif ($prefix) {
	$ok = $results =~ /^\Q$expected/;
    }
    else {
	$ok = $results eq $expected;
    }
 
    local $::TODO = $reason{todo};
    print_err_line( $switch, $prog, $expected, $results, $::TODO ) unless $ok;

    ok($ok);

    foreach (@temps)
	{ unlink $_ if $_ }
    foreach (@temp_path)
	{ rmtree $_ if -d $_ }
}

sub randomMatch
{
    my $got = shift ;
    my $expected = shift;

    my @got = sort split "\n", $got ;
    my @expected = sort split "\n", $expected ;

   return "@got" eq "@expected";

}

sub print_err_line {
    my($switch, $prog, $expected, $results, $todo) = @_;
    my $err_line = "PROG: $switch\n$prog\n" .
		   "EXPECTED:\n$expected\n" .
		   "GOT:\n$results\n";
    if ($todo) {
	$err_line =~ s/^/# /mg;
	print $err_line;  # Harness can't filter it out from STDERR.
    }
    else {
	print STDERR $err_line;
    }

    return 1;
}

1;
