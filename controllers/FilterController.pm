package FilterController;

use strict;

use Controller;
use base 'Controller';

beforeFilter \&alwaysFilter;
beforeFilter \&indexOnlyFilter, 'only' => [ 'index' ];
beforeFilter \&notIndexFilter, 'except' => [ 'index' ];

sub index()
{
  my $self = shift;

  $self->render('main', {
    'title'           => 'FilterController::index',

    'alwaysFilter'    => $self->{'_alwaysFilter'},
    'indexOnlyFilter' => $self->{'_indexOnlyFilter'},
    'notIndexFilter'  => $self->{'_notIndexFilter'},
  });
}

sub other()
{
  my $self = shift;

  $self->render('main', {
    'title'           => 'FilterController::other',
    'alwaysFilter'    => $self->{'_alwaysFilter'},
    'indexOnlyFilter' => $self->{'_indexOnlyFilter'},
    'notIndexFilter'  => $self->{'_notIndexFilter'},
  });
}

sub alwaysFilter()
{
  my $self = shift;

  $self->{'_alwaysFilter'} = 1;
}

sub indexOnlyFilter()
{
  my $self = shift;

  $self->{'_indexOnlyFilter'} = 1;
}

sub notIndexFilter()
{
  my $self = shift;

  $self->{'_notIndexFilter'} = 1;
}

1;
