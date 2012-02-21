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

test "_field_names function adds method", sub {
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

test "constructor called with fields sets values", sub {
	my $self = shift;

	my $val = 7;

	my $object = new SampleDBObject('field' => $val);
	$self->assert_equals($val, $object->field);
};

#test "'find_by_id' returns undef when no record exists", sub {
#	my $self = shift;
#
#	my $record = SampleDBObject->find_by_id(-1);
#
#	$self->assert_null($record);
#};

1;
