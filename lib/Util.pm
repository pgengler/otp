package Util;

use strict;
use lib ('lib');

use Lingua::EN::Inflect qw/ ORD PL /;
use List::MoreUtils qw/ first_index /;

use base 'Exporter';

our @EXPORT_OK = qw/
	contains
	controller_name_from_package
	ordinalize
	pluralize
	tableize
	underscore
/;
our %EXPORT_TAGS = (
	'all' => [ @EXPORT_OK ],

	'array'  => [ qw/ contains / ],
	'string' => [ qw/ ordinalize pluralize tableize underscore / ],
);

sub controller_name_from_package($)
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

#####################
## STRING FUNCTIONS
##
## Some of these (underscore, for example) are shamlessly ported
## from Ruby on Rails' ActiveSupprot functions of the same names.
#####################

sub ordinalize($)
{
	my ($number) = @_;

	return ORD($number);
}

sub pluralize($)
{
	my ($word) = @_;

	return PL($word);
}

sub tableize($)
{
	my ($class_name) = @_;

	return pluralize(underscore($class_name));
}

sub underscore($)
{
	my ($camel_case_word) = @_;

	my $word = $camel_case_word;
	$word =~ s[::][/]g;
	$word =~ s/([A-Z\d]+)([A-Z][a-z])/$1_$2/g;
	$word =~ s/([a-z\d])([A-Z])/$1_$2/g;

	$word =~ tr/-/_/;

	return lc($word);
}

1;
