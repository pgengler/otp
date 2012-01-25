package UtilTests;

use strict;

use EnhancedTestCase;
use parent 'EnhancedTestCase';

use Util qw/ :all /;

test "'contains' returns true when array contains given item", sub {
	my $self = shift;

	my @list = qw/ 1 2 3 4 /;

	$self->assert(contains(4, \@list));
};

test "'contains' returns false when array does not contain given item", sub {
	my $self = shift;

	my @list = qw/ 1 2 3 4 /;

	$self->assert(!contains(5, \@list));
};

test "'underscore' method converts properly", sub {
	my $self = shift;

	$self->assert_str_equals('camel_case', underscore('CamelCase'));
	$self->assert_str_equals('a_new_name', underscore('ANewName'));
};

1;
