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

test "'ordinalize' function generates correct values", sub {
	my $self = shift;

	$self->assert_str_equals('1st', ordinalize(1));
	$self->assert_str_equals('2nd', ordinalize(2));
	$self->assert_str_equals('3rd', ordinalize(3));
	$self->assert_str_equals('15th', ordinalize(15));
};

test "'pluralize' function generates correct plurals", sub {
	my $self = shift;

	# map singular to plural
	my $tests = {
		'apple' => 'apples',
		'goose' => 'geese',
		'mouse' => 'mice',
	};

	while (my ($singular, $plural) = each %$tests) {
		$self->assert_str_equals($plural, pluralize($singular));
	}
};

test "'tableize' function generates correct names", sub {
	my $self = shift;

	$self->assert_str_equals('books', tableize('Book'));
	$self->assert_str_equals('post_offices', tableize('PostOffice'));
};

test "'underscore' function converts properly", sub {
	my $self = shift;

	$self->assert_str_equals('camel_case', underscore('CamelCase'));
	$self->assert_str_equals('a_new_name', underscore('ANewName'));
};

1;
