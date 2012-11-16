
# WARNING! This script can be dangerous.  It executes every line in every
# file in the build directory and its subdirectories, so it could do some
# harm if the line contains `rm *` or something similar.
#
# Run this as ./perl -Ilib Porting/leakfinder.pl after building perl.
#
# This is a quick non-portable hack that evaluates pieces of code in an
# eval twice and sees whether the number of SVs goes up.  Any lines that
# leak are printed to STDOUT.
#
# push and unshift will give false positives.  Some lines (listed at the
# bottom) are explicitly skipped.  Some patterns (at the beginning of the
# inner for loop) are also skipped.

use XS::APItest "sv_count";
use Data::Dumper;
$Data::Dumper::Useqq++;
for(`find .`) {
 warn $_;
 chomp;
 for(`cat \Q$_\E 2>/dev/null`) {
    next if exists $exceptions{s/^\s+//r};
    next if /rm -rf/; # Could be an example from perlsec, e.g.
     # Creating one of these special blocks creates SVs, obviously
    next if /(?:END|CHECK|INIT)\s*\{/;
    next if /^\s*(?:push|unshift|(?:\@r = )?splice|binmode|sleep)/;
    next if /\bselect(?:\s*\()[^()]+,/; # 4-arg select hangs
    my $q = s/[\\']/sprintf "\\%02x", ord $&/gore
         =~ s/\0/'."\\0".'/grid;
    $prog = <<end;   
            open oUt, ">&", STDOUT;
            open STDOUT, ">/dev/null";
            open STDIN, "</dev/null";
            open STDERR, ">/dev/null";
            \$unused_variable = '$q';
            eval \$unused_variable while \$also_unused++ < 4;
            print oUt sv_count, "\n";
            eval \$unused_variable;
            print oUt sv_count, "\n";
end
    open my $fh, "-|", $^X, "-Ilib", "-MXS::APItest=sv_count",
                 '-e', $prog or warn($!), next;
    local $/;
    $out = <$fh>;
    close $fh;
    @_ = split ' ', $out;
    if (@_ == 2 && $_[1] > $_[0]) { print Dumper $_ }
 }
}

BEGIN {
 @exceptions = split /^/, <<'end';
1 while some_condition_with_side_effects;  */
$a{buttons}[2*$a{default_button}] = [$a{buttons}[2*$a{default_button}]];
$aliases{$code_point} = [ $aliases{$code_point} ];
$aliases_maps->[$i] = [ $aliases_maps->[$i] ]
$allow ? $hash{$acc} = $allow : push @list, $acc;
A rare race condition that would lead to L<sleep|perlfunc/sleep> taking more
$args{include_dirs} = [ $args{include_dirs} ] 
$ARRAY[++$#ARRAY] = $value;
@a = sort ($b, @a)
$a = {x => $a};
BEGIN { unshift(@INC, "./blib") }
BEGIN { unshift @INC, "lib" }
BEGIN { unshift(@INC, LIST) }
binmode *STDERR, ":encoding(utf8)";
binmode *STDOUT, ":encoding(utf8)";
$char++ while substr( $got, $char, 1 ) eq substr( $wanted, $char, 1 );
CHECK { $main::phase++ }
$config{$k} = [ $config{$k} ]
const char *file = __FILE__;
const char* file = __FILE__;
$data = [ $data ];
do { $tainted_value = shift @ENV_values  } while(!$tainted_value || ref $tainted_value);
do {$x[$x] = $x;} while ($x++) < 10;
eval 'v23: $counter++; goto v23 unless $counter == 2';
eval 'v23 : $counter++; goto v23 unless $counter == 2';
$formdata->{$key} = [ $formdata->{$key}, $value ];
$func = $next{$func} until $pod{$func};
$got_arrayref ? unshift(@{$args[0]}, $cmd) : unshift(@args, $cmd);
$h{ []} = 123;
{ $h[++$i] = $_ }
High resolution alarm, sleep, gettimeofday, interval timers
$i = int($i/2) until defined $self->[$i/2];
$invmap_ref->[$i] = [ $invmap_ref->[$i] ];
$i++ while $self->{ids}{"$t$i"}++;
$mod_hash->{$k} = [ $mod_hash->{$k} ];
$modlibname =~ s,[\5c\5c/][^\5c\5c/]+$,, while $c--;    # Q&D basename
my $nfound = select($_[0], $_[1], $_[2], $_[3]);
my $nfound = select($_[0], $_[1], $_[2], $gran);
my @result = splice @temp, $self, $offset, $length, @_;
my @r = splice @a, 0, 1, "x", "y";
$_ = {name=>$_};
$n = push @a, "rec0", "rec1", "rec2";
$n = push @a, "rec3", "rec4$:";
$n = unshift @a, "rec0", "rec1", "rec2";
$n = unshift @a, "rec3", "rec4$:";
@$obj = ($meth, (bless [@$obj]), 1); # Avoid circular reference
@old = splice(@h, 1, 2, qw(bananas just before));
package XS::APItest; require XSLoader; XSLoader::load()
$pa = { -exitval => $pa };
$pa = { -message => $pa };
pop @lines while $lines[-1] eq "";
pop @to while $#to and $to[$#to] == $to[$#to -1];
print "LA LA LA\n" while 1;          # loops forever
prog => 'use Config; CHECK { $Config{awk} }',
$p->{share_dir} = { dist => [ $p->{share_dir} ] };
$p->{share_dir} = { dist => $p->{share_dir} };
{ push (@Bad, $key) }
( push @hard, $file ), next
{ push @keep, $_ }
{ push (@values, $value) }
$resp = [$resp]
$self->{DIR} = [grep $_, split ":", $self->{DIR}];
$share_dir->{dist} = [ $share_dir->{dist} ];
s![^/+]*$!man!&&-d&&!$s{$_}++&&push@m,#_;END{print"@m"}'
$spec = [$spec, $_[0]];
$stack[$i++] &= ~1;
$step = [$step];
system("find . -type f -print     | xargs chmod 0444");
the while clause.  */
Time::HiRes - High resolution alarm, sleep, gettimeofday, interval timers
*tmpl = ~*tmpl;
*tmps = ~*tmps;
weaken($objs[@objs] = $h{$_} = []);
weaken($objs[@objs] = $$h{$_} = []);
while (1) { my $k; }
while(1) { sleep(1); }
while($foo--) { print("In thread $thread\n"); }
$x->[$j] -= $BASE if $car = (($x->[$j] += $car) >= $BASE) ? 1 : 0; $j++;
$x->[scalar @$x] = 0;		# avoid || 0 test inside loop
$z = splice @a, 3, 1, "recordZ";
end
 @exceptions{@exceptions} = ();
}
