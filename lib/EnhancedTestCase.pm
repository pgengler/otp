package EnhancedTestCase;

use strict;

use parent qw/ Test::Unit::TestCase Exporter /;

our @EXPORT = qw/ test /;

sub test($&)
{
	my ($name, $test) = @_;

	my $caller_package = scalar caller();

	# Convert 'name' to a valid subroutine name, making all text lower-case,
	# converting spaces to underscores, and removing punctuation characters.
	# 'test_' is prepended to this name.
	my $method_name = $name;
	$method_name =~ s/ /_/g;
	$method_name =~ s/[.'"]//g;
	$method_name = lc($method_name);
	$method_name = 'test_' . $method_name;

	{
		no strict 'refs';
		*{"$caller_package\::$method_name"} = sub { my $self = shift; $test->($self, @_) };
		push @{"$caller_package\::TESTS"}, $method_name;
	}
};

sub list_tests()
{
	my $class = ref($_[0]) || $_[0];

	if ($class eq __PACKAGE__) {
		return qw/ /;
	} else {
		return $class->SUPER::list_tests(@_);
	}
}

1;
