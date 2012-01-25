package DBObject;

use strict;

sub new()
{
	my $class = shift;

	my $self = {

	};

	return bless $self, $class;
}

##############
## SET FIELD NAMES
#######
## Set the list of field names this object handles from the DB.
##
## This is different from the Rails approach, which scans the DB and
## automatically determines names from the columns in the table. There's
## no technical reason that couldn't be done here, but since this code
## is loaded/run on every invocation of the script, instead of at the startup
## of an app server, it's a lot more efficient to avoid the overhead of
## retrieving the column list on every run.
#######
## Parameters:
##   $fields
##   - arrayref of field names
#######
## Return Value:
##   NONE
##############
sub _field_names()
{
	my $self = shift;
	my ($fields) = @_;

	foreach my $field (@$fields) {
		$self->_add_getter_setter($field);
	}
}

##############
## GET TABLE NAME
#######
## Return the name of the table to be used for this object.
##
## By default, the name is the name of the module, converted to lower case.
#######
## Parameters:
##   NONE
#######
## Return Value:
##   name of table to be used
##############
sub _table_name()
{
	my $self = shift;

	my $name = ref($self);

	return lc($name);
}

##############
## ADD GETTER/SETTER METHOD TO CURRENT CLASS
#######
## Add getter/setter method for the given name to the current class.
#######
## Parameters:
##   $name
##   - name of the getter/setter to be added
#######
## Return Value:
##   NONE
#######
## Side Effects:
##   the current class gets a new getter/setter method
##############
sub _add_getter_setter()
{
	my $self = shift;
	my ($name) = @_;

	my $class = ref($self);

	eval qq(
		\*$class::$name = sub {
			my \$self = shift;

			if (scalar(\@_) > 0) {
				\$self->{'_data'}->{ \$name } = shift;
			}

			return \$self->{'_data'}->{ \$name };
		};
	);
}

1;
