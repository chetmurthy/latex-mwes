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
  my $txt = f_read($fname) ;

  my $froot = $fname ;
  $froot =~ s,\.tex,,;
  my $splitdir = "split/${froot}-pieces" ;
  my $fsplit = "split/${froot}-split.tex" ;

  v_systemx("rm","-rf",$splitdir,$fsplit) ;
  v_systemx("mkdir","-p",$splitdir) ;

  my @parts = split(/^(\\(?:sub)*(?:section|chapter|part)\*?.*)$/m, $txt) ;

  my @ol = () ;
  my $i = 0 ;
  foreach my $p (@parts) {
    if (iscomment($p)) {
      push(@ol, $p) ;
      next ;
    }
    if ($p =~ /^(\\(?:sub)*(?:section|chapter|part)\*?.*)$/) {
      push (@ol, $p) ;
      next ;
    }

    my ($leading, $rest) = split_leading($p) ;
    push(@ol, $leading) ;

    # a piece to be put in a separate file
    my $fpart = sprintf("${splitdir}/piece-%04d.tex", $i) ;
    f_write($fpart, $rest) ;
    print STDERR "[write $fpart]\n";
    push (@ol, "\\input{$fpart}\n") ;
    $i++ ;
  }
  f_write($fsplit, join('',@ol)) ;
  print STDERR "[write $fsplit]\n";
}

sub split_leading {
  my $txt = shift ;

  my @l = split(/(\n)/, $txt) ;
  my @ol = () ;
  while (@l) {
    if ($l[0] eq "") {
      push(@ol, shift @l) ;
      next ;
    }
    if ($l[0] eq "\n") {
      push(@ol, shift @l) ;
      next ;
    }
    if ($l[0] =~ m,^\s*\\index,,) {
      push(@ol, shift @l) ;
      next ;
    }
    if ($l[0] =~ m,^\s*\\label,,) {
      push(@ol, shift @l) ;
      next ;
    }
    last ;
  }
  my $leading = join("",@ol) ;
  my $rest = join("",@l) ;
  return ($leading, $rest) ;
}

sub iscomment {
  my $txt = shift ;
  $txt =~ s,^%.*$,,gm ;
  return ($txt !~ /\S/s) ;
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
