package VarController;

use strict;

use ApplicationController;
use parent 'ApplicationController';

sub index()
{
  my $self = shift;

  my $value = int(rand(100) + 1);

  $self->render('number', {
    'value' => $value,
  });
}

sub number()
{
  my $self = shift;
  my ($value) = @_;

  return {
    'value' => $value,
  };
}

1;
