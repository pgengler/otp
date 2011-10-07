#!/usr/bin/perl

use strict;

use CGI qw/ header /;

if (exists $ENV{'SCRIPT_FILENAME'}) {
  print header({ 'type' => 'text/plain' });
}

foreach my $var (sort { $a cmp $b } keys %ENV) {
  printf "%s == %s\n", $var, $ENV{ $var };
}
