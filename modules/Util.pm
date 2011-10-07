package Util;

use strict;

use List::MoreUtils qw/ first_index /;

use base 'Exporter';

our @EXPORT_OK = qw/
  contains
  controllerNameFromPackage
/;
our %EXPORT_TAGS = (
  'all' => [ @EXPORT_OK ],
);

sub controllerNameFromPackage($)
{
  my ($package) = @_;

  $package =~ s/Controller$//;

  return $package;
}

sub contains($$)
{
  my ($needle, $haystack) = @_;

  my $index = first_index { $_ eq $needle } @$haystack;

  return $index != -1;
}  

1;
