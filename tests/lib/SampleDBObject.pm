package SampleDBObject;

use strict;

use lib ('../lib');

use parent 'DBObject';

sub new()
{
	my $class = shift;

	my $self = $class->SUPER::new(@_);

	$self->_field_names([ 'field' ]);

	return bless $self, $class;
}

1;
