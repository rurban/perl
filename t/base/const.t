#!./perl
BEGIN { $| = 1; print "1..19\n"; }
BEGIN { unshift @INC, '../lib', 'lib'; }
my $test=1;
{
  use feature "const";
  # parse valid const
  my $result = eval 'my const $a=1;print "# \$a=",$a,"\n";$a';
  if (!$@ and $result == 1) { print "ok $test\n"; } else { print "not ok $test - declare and set const \$i\n"; }
  $test++;
  $result = eval 'my const @a=(1);print "# \$a[0]=",$a[0],"\n";$a[0]';
  if (!$@ and $result == 1) { print "ok $test\n"; } else { print "not ok $test - declare and set const \@a\n"; }
  $test++;
  $result = eval 'my const %a=("a"=>"ok");print "# \$a{a}=",$a{a},"\n";$a{a}';
  if (!$@ and $result eq 'ok') { print "ok $test\n"; } else { print "not ok $test - declare and set const \%a $@\n"; }
  $test++;
  $result = eval 'my const($a,$b)=(1,2);print "# \$a,\$b=",$a,$b,"\n";$a';
  if (!$@ and $result == 1) { print "ok $test\n"; } else { print "not ok $test - list_assignment $@\n"; }
  $test++;
  # TODO [#21979]: Can't declare subroutine entry in "my" (type=entersub)
  $result = eval 'my (const $a, const $b)=(1,2);print "# \$a,\$b=",$a,$b,"\n";$a';
  if (!$@ and $result == 1) { print "ok $test\n"; } else { print "not ok $test - #TODO #21979 my (const \$a, const \$b)=(1,2);\n"; }
  $test++;

  # compile-time errors
  eval 'my const $a=1; $a=0';
  if ($@ =~ /Invalid assignment to const variable/) { print "ok $test\n"; } else { print "not ok $test - #Invalid assignment to const variable $@\n"; }
  $test++;
  eval 'my const @a=(1,2,3); @a=(0);';
  if ($@ =~ /Invalid assignment to const variable/) { print "ok $test\n"; } else { print "not ok $test - #Invalid assignment to const variable $@\n"; }
  $test++;
  eval 'my const %a=(0=>1); %a=(1=>2);';
  if ($@ =~ /Invalid assignment to const variable/) { print "ok $test\n"; } else { print "not ok $test - #Invalid assignment to const variable $@\n"; }
  $test++;

  # run-time readonly-ness of elements
  eval 'my const %a=("a"=>"ok"); $a{b}=0'; # no new element
  if ($@ =~ /Attempt to access disallowed key/) { print "ok $test\n"; } else { print "not ok $test - # \$a{b}=0 $@\n"; }
  $test++;
  eval 'my const %a=("a"=>"ok"); $a{a}=0'; # allow changing existing element
  if ($@ !~ /Attempt to access disallowed key/) { print "ok $test\n"; } else { print "not ok $test - # \$a{a}=0 $@\n"; }
  $test++;
  eval 'my const @a=(1,2,3); $a[5]=0';
  if ($@ =~ /Modification of a read-only value attempted/) { print "ok $test\n"; } else { print "not ok $test - # \$a[5]=0 $@\n"; }
  $test++;

  # run-time readonly errors
  $result = eval ' my const($a,$b)=(1,2); eval q($b=0);';
  if ($@ =~ /Modification of a read-only value attempted/) { print "ok $test\n"; } else { print "not ok $test - #TODO set const \$b in (\$a,\$b)\n"; }
  $test++;
  # const @a is not deep, protects only the structure, not the elements
  $result = eval 'my const @a=(1,2,3); $a[0]=0;$a[0]';
  if (!$@ and $result == 0) { print "ok $test\n"; } else { print "not ok $test - set \$[0] elem\n"; }
  $test++;

  # more run-time errors
  eval 'my const @a=(1,2,3); push @a,0';
  if ($@ =~ /Modification of a read-only value attempted/) { print "ok $test\n"; } else { print "not ok $test - # push const \@a\n"; }
  $test++;
  eval 'my const %a=(0=>1,1=>2); delete $a{0}';
  if ($@ =~ /Attempt to delete readonly key/) { print "ok $test\n"; } else { print "not ok $test - #delete from restricted hash\n"; }
  $test++;

  # mixed with types
  $result = eval '$int::x=0;my const int $a=1;$a';
  if (!$@ and $result == 1) { print "ok $test\n"; } else { print "not ok $test - declare and set const int \$i\n"; }
  $test++;
  $result = eval 'my unknown $a=1;$a;';
  if ($@ =~ /No such class unknown/) { print "ok $test\n"; } else { print "not ok $test - No such class unknown\n"; }
  $test++;
  $result = eval 'my const unknown $a=1;$a;';
  if ($@ =~ /No such class unknown/) { print "ok $test\n"; } else { print "not ok $test - No such class unknown with const\n"; }
  $test++;
}

# lexical types without const
$result = eval '$int::x=0;my int $a=1;$a;';
if (!$@ and $result == 1) { print "ok $test\n"; } else { print "not ok $test - my int \$i\n"; }
$test++;
