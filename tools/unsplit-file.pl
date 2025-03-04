#!/usr/bin/perl

use strict ;
use Data::Dumper ;
use Carp::Assert ;
use Getopt::Long;
use IPC::System::Simple qw(systemx runx capturex $EXITVAL);
use String::ShellQuote ;

our $verbose ;

while(@ARGV) {
  if ($ARGV[0] eq '-v') {
    shift @ARGV ;
    $verbose = 1 ;
  }
  else { last ; }
}

{

  my $fname = shift @ARGV ;

  my $froot = $fname ;
  $froot =~ s,\.tex,,;
  my $splitdir = "split/${froot}-pieces" ;
  my $fsplit = "split/${froot}-split.tex" ;

  my @ol = () ;

  open(FSPLIT, "<$fsplit") || die "cannot open $fsplit for reading" ;
  while($_ = <FSPLIT>) {
    if ($_ =~ m,\\input\{(${splitdir}/\S+.tex)\},) {
      my $fpiece = $1 ;
      my $txt = f_read($fpiece) ;
      push (@ol, $txt) ;
    }
    else {
      push(@ol, $_) ;
    }
  }
  close(FSPLIT) ;
  f_write($fname, join("",@ol)) ;
  print STDERR "[overwrote $fname]\n";
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
