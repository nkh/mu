#!/usr/bin/pugs

use v6;
require Test;

=pod

Test that the C<--version> command in its various incantations
works.

=cut

my @tests = ("-v", "--version");
@tests = @tests.map():{ $_, "-w $_", "$_ -w", "-w $_ -w" };
#@tests = (); # unTODOme

plan +@tests;

diag "Running under $?OS";

my ($pugs,$redir) = ("./pugs", ">");

if ($?OS ~~ rx:perl5{MSWin32|msys|mingw}) {
  $pugs = 'pugs.exe';
};

for @tests -> $ex {
  my $command = "$pugs $ex $redir temp-ex-output";
  diag $command;
  system $command;

  my $got = slurp "temp-ex-output";
  unlink "temp-ex-output";

  like($got, rx:perl5/Version: 6\.0\.\d+ \(r\d+\)/, "'$ex' displays version");
};
