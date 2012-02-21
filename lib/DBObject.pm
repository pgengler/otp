package DBObject;

use strict;

use Util qw/ :all /;

use parent 'Exporter';

# need to export these so subclasses can call them
our @EXPORT = qw/ _add_getter_setter _field_names /;

our $_db;
our $_fields = { };

sub new()
{
	my $class = shift;
	my (%data) = @_;

	my $self = {
		'_dirty' => 0,
	};

	bless $self, $class;

	foreach my $field (keys %data) {
		if ($self->can($field)) {
			$self->$field($data{ $field });
		}
	}

	return $self;
}

##############
## FIND BY ID
#######
## Find a single record with the given ID.
######
## Parameters:
##   $id
##   - ID for item to get
######
## Return Value:
##   if the ID is valid and found, returns an object of
##   the appropriate type populated with data. Otherwise,
##   returns undef.
##############
sub find_by_id()
{
	my $class = shift;
	my ($id) = @_;

	my $field_list = join(', ', @{ $_fields->{ $class } });
	my $table_name = _table_name($class);

	my $sql = qq(
		SELECT ${field_list}
		FROM ${table_name}
		WHERE id = ?
	);
	my $result = _db()->statement($sql)->execute($id)->fetch();

	return undef unless defined $result;

	my $object = $class->new();
	foreach my $field (@{ $_fields->{ $class } }) {
		$object->$field($result->{ $field });
	}
	$object->{'_dirty'} = 0;

	return $object;
}

##############
## SAVE OBJECT
#######
## Save the current object in the database.
##
## If the object is new, inserts a new row.
## Otherwise, updates the row for the item.
#######
## Parameters:
##   NONE
#######
## Return Value:
#    1 if the object was saved successfully, 0 otherwise
##############
sub save()
{
	my $self = shift;
	my $class = ref($self);

	return unless $self->{'_dirty'};

	my $table_name = _table_name($class);

	if (defined $self->id) {
		my @update_clauses = ( );
		my @parameters = ( );

		foreach my $field (@{ $_fields->{ $class } }) {
			next if $field eq 'id';

			push @update_clauses, sprintf('%s = ?', $field);
			push @parameters, $self->$field();
		}

		my $update_clauses = join("\n", @update_clauses);

		my $sql = qq(
			UPDATE ${table_name} SET
				${update_clauses}
			WHERE id = ?
		);
		_db()->statement($sql)->execute(@parameters, $self->id);
	} else {
		my @field_list       = grep { $_ ne 'id' } @{ $_fields->{ $class } };
		my @placeholder_list = map { '?' } @field_list;

		my @parameters = map { $self->$_() } @field_list;

		my $field_list_str  = join(', ', @field_list);
		my $placeholder_str = join(', ', @placeholder_list);

		my $sql = qq(
			INSERT INTO ${table_name}
			($field_list_str)
			VALUES
			($placeholder_str)
		);
		my $statement = _db()->statement($sql)->execute(@parameters);
		$self->id(_db()->insert_id);
	}

	$self->{'_dirty'} = 0;

	return 1;
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
sub _field_names($)
{
	my $class = _class();
	my ($fields) = @_;

	foreach my $field (('id', @$fields)) {
		push @{ $_fields->{ $class } }, $field;
		$class->_add_getter_setter($field);
	}
}

##############
## GET TABLE NAME
#######
## Return the name of the table to be used for this object.
#######
## Parameters:
##   NONE
#######
## Return Value:
##   name of table to be used
##############
sub _table_name()
{
	my $class = shift;

	return tableize($class);
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
	my $class = shift;
	my ($name) = @_;

	{
		no strict 'refs';
		*{"$class\::$name"} = sub {
			my $self = shift;

			if (scalar(@_) > 0) {
				$self->{'_data'}->{ $name } = shift;
				$self->{'_dirty'} = 1;
			}

			return $self->{'_data'}->{ $name };
		};
	}
}

##############
## GET CLASS NAME
#######
## Get the class name (package name) for the caller of the
## function that called _class().
##
## This function is only useful in certain situtations and relies
## on being called at a certain point in the process, so it probably
## isn't generally useful.
#######
## Parameters:
##   NONE
#######
## Return Value:
##   string with the class name for the caller
##############
sub _class()
{
	my @caller = caller(1);
	return $caller[0];
}

##############
## GET DATABASE CONNECTION
#######
## Return an object for communicating with the DB.
##
## On the first call, saves the object (in $_db); subsequent calls will
## return this saved object.
#######
## Parameters:
##   NONE
#######
## Return Value:
##   object for database connection
##############
sub _db()
{
	if (not defined $_db) {
		# TODO: connect to database
	}

	return $_db;
}

1;
