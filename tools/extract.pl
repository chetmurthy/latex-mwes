#!/usr/bin/perl

use strict ;

our $comments ;
our $check_dollar ;
our $check_percent ;
our $check_caret ;
our $check_backslash ;
our $check_doublebackslash ;

while(@ARGV) {
  if ($ARGV[0] eq '-with-comments') {
    shift @ARGV ;
    $comments = 1 ;
  }
  elsif ($ARGV[0] eq '-check-all') {
    shift @ARGV ;
    $check_dollar = 1 ;
    $check_percent = 1 ;
    $check_caret = 1 ;
    $check_backslash = 1 ;
  }
  elsif ($ARGV[0] eq '-check-dollar') {
    shift @ARGV ;
    $check_dollar = 1 ;
  }
  elsif ($ARGV[0] eq '-check-percent') {
    shift @ARGV ;
    $check_percent = 1 ;
  }
  elsif ($ARGV[0] eq '-check-caret') {
    shift @ARGV ;
    $check_caret = 1 ;
  }
  elsif ($ARGV[0] eq '-check-backslash') {
    shift @ARGV ;
    $check_backslash = 1 ;
  }
  elsif ($ARGV[0] eq '-check-doublebackslash') {
    shift @ARGV ;
    $check_doublebackslash = 1 ;
  }
  else { last ; }
}

our $env = shift @ARGV ;


foreach my $f (@ARGV) {
  my $txt = f_read($f) ;
  #print $txt ;

  while ($txt =~ s,(?:\n(?:%[^\n]+)?\\)?begin\{$env\}.*?end\{$env\},,s) {
    my $e = $& ;
    unless ($comments) {
      next if ($e =~ m,^\n[^\n]*%,s) ;
    }
    $e =~ s,^\n+,,s ;
    my $mode = $e ;
    $mode =~ s,\\begin\{$env\},,s ;
    $mode =~ s,\\end\{$env\},,s ;
    my $baddollar ;
    if ($check_dollar && $mode =~ m,\$,s) {
      $baddollar = 1;
    }
    my $badpercent ;
    if ($check_percent && $mode =~ m,[^\n%]%[^%],s) {
      $badpercent = 1;
    }
    my $badcaret ;
    if ($check_caret && $mode =~ m,\^,s) {
      $badcaret = 1;
    }
    my $badbs ;
    if ($check_backslash && $mode =~ m,[^\\]\\[^\\],s) {
      $badbs = 1;
    }
    my $baddbs ;
    if ($check_doublebackslash && $mode =~ m,\\\\,s) {
      $baddbs = 1;
    }
    if ((!$check_percent &&
	 !$check_caret &&
	 !$check_backslash &&
	 !$check_doublebackslash &&
	 !$check_dollar) ||
	($check_percent && $badpercent) ||
	($check_caret && $badcaret) ||
	($check_dollar && $baddollar) ||
	($check_backslash && $badbs) ||
	($check_doublebackslash && $baddbs)) {
      print "BAD %\n" if ($badpercent) ;
      print "BAD ^\n" if ($badcaret) ;
      print "BAD \\\n" if ($badbs) ;
      print "BAD \\\\\n" if ($baddbs) ;
      print "BAD \$\n" if ($baddollar) ;
      print "$e\n\n";
    }
  }
}

sub f_read {
  my $f = shift;
  open(F,"<$f") || die "cannot open $f for reading";
  my @l = <F>;
  close(F);
  return (wantarray ? @l : join('', @l)) ;
}

sub f_write {
  my $f = shift;
  open(F,">$f") || die "cannot open $f for writing";
  print F @_;
  close(F);
}
sub v_systemx {
  my $codes ;
  $codes = shift if (ref($_[0]) eq 'ARRAY') ;
  my @cmd = @_ ;
  print STDERR join(' ', map { shell_quote($_) } @cmd)."\n" if ($main::verbose) ;

  if ($codes) {
    return runx($codes, @cmd) ;
  }
  else {
    return runx(@cmd) ;
  }
}

sub v_capturex {
  my $codes ;
  $codes = shift if (ref($_[0]) eq 'ARRAY') ;
  my @cmd = @_ ;
  print STDERR join(' ', map { shell_quote($_) } @cmd)."\n" if ($main::verbose) ;

  if ($codes) {
    return capturex($codes, @cmd) ;
  }
  else {
    return capturex(@cmd) ;
  }
}
