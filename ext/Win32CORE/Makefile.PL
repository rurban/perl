use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Win32CORE',
    'VERSION_FROM'	=> 'Win32CORE.pm',
);

# undef USEIMPORTLIB for static compilation
sub MY::cflags {
  package MY;         # so that "SUPER" works right
  my ($self, $libperl)=@_;
  return '' unless $self->needs_linking();
  my $base = $self->SUPER::cflags($libperl);
  if ($self->{LINKTYPE} eq 'static') {
    $base =~ s/-DUSEIMPORTLIB/-UUSEIMPORTLIB/mg;
  }
  return $base;
}

sub MY::static {
  package MY;         # so that "SUPER" works right
  my $self = shift;
  return $self->SUPER::static(@_) unless $^O eq 'cygwin';
  '
# cygwin with libtool cannot link this as .a, required for mod_perl e.g.
# So we add it directly to libperl.
$(PERL_SRC)/$(OBJECT) : $(FIRST_MAKEFILE) $(OBJECT)
	$(RM_RF) $(PERL_SRC)/$(OBJECT)
	$(CP) $(OBJECT) $(PERL_SRC)/$(OBJECT)

static :: $(FIRST_MAKEFILE) $(PERL_SRC)/$(OBJECT) $(INST_STATIC)
';
}
