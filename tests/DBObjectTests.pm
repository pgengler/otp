package DBObjectTests;

use strict;
use lib ('lib');

use EnhancedTestCase;
use parent 'EnhancedTestCase';

use SampleDBObject;

sub set_up()
{
	my $self = shift;

	$self->{'_object'} = new SampleDBObject();
}

test "_field_names method adds method", sub {
	my $self = shift;

	my $object = $self->{'_object'};

	$self->assert_not_null($object->can('field'));
};

test "added method saves and returns values", sub {
	my $self = shift;

	my $object = $self->{'_object'};

	my $val = 4;

	$object->field($val);
	$self->assert_equals($val, $object->field());
};

1;
