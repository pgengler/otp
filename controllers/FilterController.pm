package FilterController;

use strict;

use ApplicationController;
use parent 'ApplicationController';

before_filter \&always_filter;
before_filter \&index_only_filter, 'only' => [ 'index' ];
before_filter \&not_index_filter, 'except' => [ 'index' ];

sub index()
{
  my $self = shift;

  $self->render('main', {
    'title'           => 'FilterController::index',

    'always_filter'     => $self->{'_always_filter'},
    'index_only_filter' => $self->{'_index_only_filter'},
    'not_index_filter'  => $self->{'_not_index_filter'},
  });
}

sub other()
{
  my $self = shift;

  $self->render('main', {
    'title'             => 'FilterController::other',
    'always_filter'     => $self->{'_always_filter'},
    'index_only_filter' => $self->{'_index_only_filter'},
    'not_index_filter'  => $self->{'_not_index_filter'},
  });
}

sub always_filter()
{
  my $self = shift;

  $self->{'_always_filter'} = 1;
}

sub index_only_filter()
{
  my $self = shift;

  $self->{'_index_only_filter'} = 1;
}

sub not_index_filter()
{
  my $self = shift;

  $self->{'_not_index_filter'} = 1;
}

1;
